from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.chat_routes import router as chat_router

app = FastAPI(
    title="EcoScan Chatbot API",
    description="API du chatbot intelligent EcoBot pour EcoScan",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router, tags=["Chatbot"])

@app.get("/")
def root():
    return {"message": "EcoScan Chatbot API fonctionne correctement."}

@app.get("/health")
def health_check():
    return {"status": "healthy"}