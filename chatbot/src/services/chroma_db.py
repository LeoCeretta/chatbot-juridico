from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from tempfile import NamedTemporaryFile
from langchain_aws import BedrockEmbeddings
from langchain_community.vectorstores import Chroma
from cloudwatch_logs import send_logs
import boto3
import os
import io
from dotenv import load_dotenv
load_dotenv()

# Inicialização do client S3
s3_client = boto3.client('s3')
bucket_name = os.getenv('AWS_BUCKET_NAME')

response = s3_client.list_objects_v2(Bucket=bucket_name)

# Criação da lista com path para todos os arquivos no bucket
if 'Contents' in response:
    pdf_files = [obj['Key'] for obj in response['Contents'] if obj['Key'].endswith('.pdf')]
    send_logs(f"PDF files:{str(pdf_files)}")
else:
    send_logs("No files found.")

# Função para criação e armazenamento dos vetores em memória.
def chroma_db():
    documents = []

    for pdf_file in pdf_files:
        #Baixar o PDF em memória
        response = s3_client.get_object(Bucket=bucket_name, Key=pdf_file)
        pdf_data = io.BytesIO(response['Body'].read())  # PDF em bytes

        #Criar arquivo temporário para armazenar o PDF
        with NamedTemporaryFile(delete=False, suffix='.pdf') as temp_file:
            temp_file.write(pdf_data.getvalue())
            temp_file_path = temp_file.name
      
        #Carregar o PDF com PyPDFLoader
        loader = PyPDFLoader(temp_file_path)
        documents.extend(loader.load())
            
        #Remover o arquivo temporário
        os.unlink(temp_file_path)
    
    #Usar RecursiveCharacterTextSplitter para dividir o texto
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000, 
            chunk_overlap=100, 
            separators=["\n\n", "\n"]
        )
        docs = text_splitter.split_documents(documents)

    # Conectando cliente Bedrock 
    bedrock = boto3.client('bedrock-runtime', region_name = os.getenv('REGION_NAME'))
    # Gerar o embedding
    titan_embedding = BedrockEmbeddings(model_id = 'amazon.titan-embed-text-v2:0', client=bedrock)

    # Gerar os vetores com o Chroma
    persist_directory = 'chroma_index'    
    vector_store = Chroma.from_documents (
        documents = docs,
        persist_directory = persist_directory,
        embedding = titan_embedding
    )

    #Persistir os vetores no disco
    vector_store.persist()

    send_logs("Vectors stored successfully in 'chroma_index' directory.")
    
    return vector_store  # Retorna o objeto Chroma para consultas futuras
