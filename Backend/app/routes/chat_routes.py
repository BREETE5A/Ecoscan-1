from fastapi import APIRouter

from app.schemas.chat_schema import ChatRequest, ChatResponse
from app.services.rag_chatbot import chatbot

router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    response = chatbot.ask(request.message)

    return ChatResponse(response=response)