from langchain_aws import ChatBedrock,BedrockEmbeddings
from langchain.prompts import PromptTemplate
from langchain_community.vectorstores import Chroma
from langchain.chains.retrieval_qa.base import RetrievalQA
from cloudwatch_logs import send_logs
from dotenv import load_dotenv
import os
import boto3

load_dotenv()

persist_directory = 'chroma_index'
chroma_search_k = 6

# Conectando cliente Bedrock 
bedrock = boto3.client('bedrock-runtime', region_name = os.getenv('REGION_NAME'))
# Gerar embedding
titan_embedding = BedrockEmbeddings(model_id = 'amazon.titan-embed-text-v2:0', client=bedrock)

# Função para carregar LLM
def load_llm():
    return ChatBedrock (
        model_id = 'meta.llama3-8b-instruct-v1:0',
        client = bedrock,
        temperature = 0.3,
        max_tokens = 512,
    )

# Prompt
PROMPT_TEMPLATE = """
Você é um assistente virtual especializado em questões jurídicas. Sua função é analisar os documentos a seguir e responder perguntas baseada na informações presentes nele.
Você deve analisar todos os documentos antes de responder e limitar suas respostas às informações presentes neles.

Documentos: {context}

As informações presentes nos documentos foram retiradas de processos judiciais diferentes e também devem ser referenciado quando a pergunta fizer menção a "suas informações" ou "documentos".
Lembre-se que as pessoas com quem você está conversando são pessoas que buscam aconselhamento jurídico e profissionais do direito em busca de informações específicas.

Pergunta: {question}
Resposta:
"""
PROMPT = PromptTemplate(template=PROMPT_TEMPLATE, input_variables=["context", "question"])




# Pipeline QA
def process_query(question):
    try:
        # Carrega o índice Chroma
        vector_store = Chroma(persist_directory=persist_directory, embedding_function=titan_embedding)

        llm = load_llm()

        # Configuração da cadeia de QA
        qa_chain = RetrievalQA.from_chain_type(
            llm = llm,
            retriever = vector_store.as_retriever(search_kwargs = {"k": chroma_search_k}),
            return_source_documents = True,
            chain_type_kwargs = {'prompt': PROMPT}
        )
        
        response = qa_chain.invoke({'query': question})
        send_logs(response)
        return response['result']
    except Exception as e:
        send_logs(f'Erro durante o processamento da consulta: {e}')
        return 'Desculpe, não consegui encontrar uma resposta para sua pergunta.'
