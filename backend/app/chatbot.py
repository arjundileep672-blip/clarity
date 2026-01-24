import uuid
import asyncio
import httpx
import os
from fastapi import APIRouter, Request, HTTPException, Depends
from fastapi.responses import RedirectResponse, FileResponse
from sqlalchemy.orm import Session
from datetime import datetime

# Import existing models and DB config from your project
from app.database import SessionLocal, ChatSession, ChatMessage

router = APIRouter()

# --- Configuration ---
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent"

# Retrieve API Key from environment variables loaded in main.py
API_KEY = os.getenv("GEMINI_API_KEY")

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 1) START CHAT: Generate session and redirect (Strict Navigation Flow)
@router.get("/chat/start")
async def start_chat(db: Session = Depends(get_db)):
    session_id = str(uuid.uuid4())
    
    new_session = ChatSession(
        id=session_id,
        module="chatbot",
        status="active",
        created_at=datetime.utcnow()
    )
    
    db.add(new_session)
    db.commit()
    
    # Redirect to the dynamic chat page
    return RedirectResponse(url=f"/chat/{session_id}")

# 2) SERVE CHAT PAGE: Serve the static HTML file
@router.get("/chat/{session_id}")
async def serve_chat_page(session_id: str, db: Session = Depends(get_db)):
    # Verify session exists in DB before serving the page
    session = db.query(ChatSession).filter(ChatSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Chat session not found")
    
    return FileResponse("temp/chat.html")

# 3) HANDLE CHAT MESSAGE: Logic, AI Call, and Storage
@router.post("/api/chat/message")
async def handle_message(request: Request, db: Session = Depends(get_db)):
    data = await request.json()
    session_id = data.get("session_id")
    user_text = data.get("message")

    if not session_id or not user_text:
        raise HTTPException(status_code=400, detail="Missing session_id or message")

    # Validate session
    session = db.query(ChatSession).filter(ChatSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Save User Message to SQLite
    user_msg = ChatMessage(
        session_id=session_id,
        sender="user",
        message_text=user_text,
        created_at=datetime.utcnow()
    )
    db.add(user_msg)
    db.commit()

    # Call Gemini AI (Backend only)
    ai_reply = await call_gemini_api(user_text)

    # Save AI Reply to SQLite
    ai_msg = ChatMessage(
        session_id=session_id,
        sender="ai",
        message_text=ai_reply,
        created_at=datetime.utcnow()
    )
    db.add(ai_msg)
    db.commit()

    return {"reply": ai_reply}

async def call_gemini_api(user_prompt: str):
    """Calls Gemini API with exponential backoff retries."""
    if not API_KEY:
        return "Configuration Error: GEMINI_API_KEY is missing from the environment."

    system_prompt = "You are a helpful assistant. Keep answers concise."
    payload = {
        "contents": [{"parts": [{"text": user_prompt}]}],
        "systemInstruction": {"parts": [{"text": system_prompt}]}
    }

    async with httpx.AsyncClient() as client:
        for attempt in range(6): 
            try:
                response = await client.post(
                    f"{GEMINI_API_URL}?key={API_KEY}",
                    json=payload,
                    timeout=20.0
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return result.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "No response generated.")
                
                # Retry on rate limit or server errors
                if response.status_code in [429, 500, 503]:
                    await asyncio.sleep(2 ** attempt)
                    continue
                
                # Log other errors
                print(f"API Error: {response.status_code} - {response.text}")
                break
            except Exception as e:
                print(f"Connection Error: {str(e)}")
                await asyncio.sleep(2 ** attempt)
    
    return "The assistant is temporarily unavailable. Please try again later."
