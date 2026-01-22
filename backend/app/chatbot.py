from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from datetime import datetime
import uuid
from typing import List, Optional
from sqlalchemy.orm import Session
from app.database import ChatSession, ChatMessage, get_db

from fastapi.responses import HTMLResponse
from pathlib import Path

router = APIRouter()

@router.get("/chat/{session_id}", response_class=HTMLResponse)
async def get_chat_page(session_id: str, db: Session = Depends(get_db)):
    # Ensure session exists in DB
    existing_session = db.query(ChatSession).filter(ChatSession.id == session_id).first()
    if not existing_session:
        new_session = ChatSession(id=session_id, module="chatbot", status="active")
        db.add(new_session)
        db.commit()
    return HTMLResponse(content=Path("temp/chat.html").read_text())

# --- Request/Response Models ---

class ChatStartRequest(BaseModel):
    module: str = "chatbot"

class MessageRequest(BaseModel):
    session_id: str
    message_text: str

class ChatMessageResponse(BaseModel):
    id: int
    sender: str
    message_text: str
    created_at: datetime

class ChatSessionResponse(BaseModel):
    session_id: str
    status: str
    messages: List[ChatMessageResponse]

# --- API Endpoints ---

@router.post("/api/chatbot/session", response_model=ChatSessionResponse)
async def create_chat_session(request: ChatStartRequest, db: Session = Depends(get_db)):
    """
    Step 1: Create a new chat session.
    """
    session_id = str(uuid.uuid4())
    
    new_session = ChatSession(id=session_id, module=request.module, status="active")
    db.add(new_session)
    db.commit()
    
    return {
        "session_id": session_id,
        "status": "active",
        "messages": []
    }

@router.get("/api/chatbot/session/{session_id}", response_model=ChatSessionResponse)
async def get_chat_session(session_id: str, db: Session = Depends(get_db)):
    """
    Step 2: Retrieve an existing chat session with messages.
    """
    session = db.query(ChatSession).filter(ChatSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return {
        "session_id": session.id,
        "status": session.status,
        "messages": [
            {
                "id": m.id,
                "sender": m.sender,
                "message_text": m.message_text,
                "created_at": m.created_at
            }
            for m in session.messages
        ]
    }

@router.post("/api/chatbot/message")
async def send_message(data: MessageRequest, db: Session = Depends(get_db)):
    """
    Flow: 
    1. Store user message
    2. Get AI reply (Socratic/Guided)
    3. Store AI message
    4. Return AI response
    """
    session_id = data.session_id
    user_text = data.message_text

    # 1. Store User Message in DB
    user_msg = ChatMessage(session_id=session_id, sender="user", message_text=user_text)
    db.add(user_msg)

    # 2. Generate AI Reply (Socratic Logic)
    ai_reply_text = generate_socratic_reply(user_text)

    # 3. Store AI Message in DB
    ai_msg = ChatMessage(session_id=session_id, sender="ai", message_text=ai_reply_text)
    db.add(ai_msg)
    
    db.commit()

    return {
        "session_id": session_id,
        "sender": "ai",
        "message_text": ai_reply_text,
        "created_at": datetime.now()
    }

@router.post("/api/chatbot/end")
async def end_chat_session(session_id: str):
    """
    Mark a session as ended and record the timestamp.
    """
    # Logic to update 'chat_sessions' table:
    # update chat_sessions set status='ended', ended_at=now() where id=session_id
    
    return {"status": "success", "session_id": session_id, "message": "Session ended"}

# --- Helper Logic (Simulated AI) ---

def generate_socratic_reply(user_input: str) -> str:
    """
    Simulates a Socratic AI response. 
    Instead of giving answers, it asks guided questions.
    """
    input_lower = user_input.lower()
    
    if "don't know" in input_lower or "help" in input_lower:
        return "That's okay! What is the very first step you think you might need to take?"
    
    if "essay" in input_lower or "write" in input_lower:
        return "If you had to explain the main idea of your writing to a friend in one sentence, what would you say?"
    
    if "math" in input_lower or "problem" in input_lower:
        return "Before we look at the numbers, what is this problem asking us to find?"

    # Default Socratic nudge
    return "Interesting. What makes you say that, and how does it relate to your goal?"
