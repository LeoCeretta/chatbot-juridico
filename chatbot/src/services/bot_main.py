import os
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, MessageHandler, filters
from telegram.constants import ChatAction
from bot_backend import process_query
from cloudwatch_logs import send_logs
from chroma_db import chroma_db

load_dotenv()

# Verifica se a pasta com os vetores existem
if os.path.exists("./chroma_index"):
    send_logs("Chroma index encontrado. Carregando vector store...")
else:
    send_logs("Parece que os documentos não foram carregados, aguarde um instante.")
    # Cria os vetores e armazena na pasta chroma_index
    chroma_db()
    send_logs("Documentos carregados com sucesso!")

bot_name = "LexScripta"

# Função que lida com o comando /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.TYPING)
    await update.message.reply_text(f'Olá, eu sou o {bot_name}, estou aqui para te auxiliar. Em que posso te ajudar hoje?')

# Função que lida com as mensagens de texto do usuário
async def handle_message(update, context):
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action=ChatAction.TYPING)
    await update.message.reply_text(process_query(update.message.text))

def main():
    # Autenticação com Token do Bot
    application = ApplicationBuilder().token(os.getenv("BOT_TOKEN")).read_timeout(60).write_timeout(60).build()

    # Processa o comando /start
    application.add_handler(CommandHandler("start", start))

    # Processa as mensagens de texto recebidas
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    # Ativa o bot até que o comando para parar seja enviado (Ctrl + C)
    application.run_polling()

if __name__ == '__main__':
    main()