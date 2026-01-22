from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
import uuid
from typing import List, Optional

# Assuming database logic is imported from database.py in a real scenario
# from .database import SessionLocal, ChatSession, ChatMessage

router = APIRouter()

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
async def create_chat_session(request: ChatStartRequest):
    """
    Step 1: Create a new chat session.
    """
    session_id = str(uuid.uuid4())
    
    # Logic to insert into 'chat_sessions' table would go here:
    # new_session = ChatSession(id=session_id, module=request.module, status="active")
    
    return {
        "session_id": session_id,
        "status": "active",
        "messages": []
    }

@router.post("/api/chatbot/message")
async def send_message(data: MessageRequest):
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
    # save_message(session_id, sender="user", text=user_text)

    # 2. Generate AI Reply (Socratic Logic)
    # In a real scenario, this would call an AI utility module
    ai_reply_text = generate_socratic_reply(user_text)

    # 3. Store AI Message in DB
    # save_message(session_id, sender="ai", text=ai_reply_text)

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
