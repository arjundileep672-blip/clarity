import uuid
import os
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from fastapi.responses import HTMLResponse
from pathlib import Path
from sqlalchemy.orm import Session

# AI Configuration
from app.ai_config import ai

# Database Imports
from app.database import ReaderSession, get_db

router = APIRouter()



MODELS_DIR = os.path.join("models", "paragraph")

class ReaderInput(BaseModel):
    input_method: str
    input_data: str

def load_custom_prompts():
    """Reads all .txt files from the models/paragraph directory."""
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

async def call_genkit_paragraph(input_text: str):
    base_instruction = (
        "You are a sensory-safe reading assistant. Your task is to adapt the following "
        "text for a user who needs low cognitive load. Use short sentences, a calm tone, "
        "and clear paragraphs or bullet points. Output only the adapted text in Markdown."
    )
    
    custom_context = load_custom_prompts()
    full_instruction = base_instruction + ("\n\nContext:\n" + custom_context if custom_context else "")

    try:
        response = await ai.generate(
            model="gemini-1.5-pro",
            prompt=f"{full_instruction}\n\nText to adapt: {input_text}"
        )
        return response.text
    except Exception as e:
        print(f"Genkit Paragraph Error: {e}")
        return f"We're having trouble simplifying this text right now. Original content:\n\n{input_text}"

@router.get("/paragraph/{session_id}", response_class=HTMLResponse)
async def get_paragraph_page(session_id: str):
    return HTMLResponse(content=Path("temp/paragraph.html").read_text())

@router.post("/api/paragraph/start")
async def start_paragraph_adaptation(data: ReaderInput, db: Session = Depends(get_db)):
    adapted_content = await call_genkit_paragraph(data.input_data)
    session_id = str(uuid.uuid4())
    new_session = ReaderSession(
        session_id=session_id, 
        input_method=data.input_method, 
        input_text=data.input_data, 
        output_text=adapted_content, 
        created_at=datetime.utcnow()
    )
    db.add(new_session)
    db.commit()
    return {"session_id": session_id}

@router.get("/api/paragraph/details/{session_id}")
async def get_paragraph_details(session_id: str, db: Session = Depends(get_db)):
    session = db.query(ReaderSession).filter(ReaderSession.session_id == session_id).first()
    if not session: raise HTTPException(status_code=404)
    return {"output_text": session.output_text}

@router.post("/api/paragraph/done/{session_id}")
async def paragraph_done(session_id: str, db: Session = Depends(get_db)):
    return {"status": "ok"}
