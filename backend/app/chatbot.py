import uuid
import os
from datetime import datetime
from fastapi import APIRouter, Request, HTTPException, Depends
from fastapi.responses import RedirectResponse, FileResponse
from sqlalchemy.orm import Session

# AI Configuration
from app.ai_config import ai

# Database Imports
from app.database import SessionLocal, ChatSession, ChatMessage

router = APIRouter()



MODELS_DIR = os.path.join("models", "chatbot")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def load_custom_prompts():
    custom_prompts = []
    if os.path.exists(MODELS_DIR) and os.path.isdir(MODELS_DIR):
        for filename in os.listdir(MODELS_DIR):
            if filename.endswith(".txt"):
                file_path = os.path.join(MODELS_DIR, filename)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read().strip()
                        if content: custom_prompts.append(content)
                except Exception as e:
                    print(f"Genkit Prompt Load Error: {e}")
    return "\n\n".join(custom_prompts)

@router.get("/chat/start")
async def start_chat(db: Session = Depends(get_db)):
    session_id = str(uuid.uuid4())
    new_session = ChatSession(id=session_id, module="chatbot", status="active", created_at=datetime.utcnow())
    db.add(new_session)
    db.commit()
    return RedirectResponse(url=f"/chat/{session_id}")

@router.get("/chat/{session_id}")
async def serve_chat_page(session_id: str, db: Session = Depends(get_db)):
    session = db.query(ChatSession).filter(ChatSession.id == session_id).first()
    if not session: raise HTTPException(status_code=404, detail="Session not found")
    return FileResponse("temp/chat.html")

@router.post("/api/chat/message")
async def handle_message(request: Request, db: Session = Depends(get_db)):
    data = await request.json()
    session_id, user_text = data.get("session_id"), data.get("message")
    
    session = db.query(ChatSession).filter(ChatSession.id == session_id).first()
    if not session: raise HTTPException(status_code=404, detail="Session not found")

    user_msg = ChatMessage(session_id=session_id, sender="user", message_text=user_text, created_at=datetime.utcnow())
    db.add(user_msg)
    db.commit()

    history = db.query(ChatMessage).filter(ChatMessage.session_id == session_id).order_by(ChatMessage.created_at.asc()).all()
    context_text = "\n".join([f"{msg.sender}: {msg.message_text}" for msg in history])

    ai_reply = await call_genkit_chat(user_text, context_text)

    ai_msg = ChatMessage(session_id=session_id, sender="ai", message_text=ai_reply, created_at=datetime.utcnow())
    db.add(ai_msg)
    db.commit()

    return {"reply": ai_reply}

async def call_genkit_chat(user_prompt: str, context: str):
    base_instruction = "You are 'NexusAI'. Use Markdown. Be concise and professional."
    custom_context = load_custom_prompts()
    full_instruction = base_instruction + ("\n\nCustom Rules:\n" + custom_context if custom_context else "")

    try:
        response = await ai.generate(
            model="gemini-1.5-pro",
            prompt=f"{full_instruction}\n\nContext:\n{context}\n\nNexusAI:"
        )
        return response.text
    except Exception as e:
        print(f"Genkit Chat Error: {e}")
        return "I'm having trouble responding right now. Please try again later."
