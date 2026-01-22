from fastapi import APIRouter, Depends
from pydantic import BaseModel
import uuid
from fastapi.responses import HTMLResponse
from pathlib import Path
from sqlalchemy.orm import Session
from app.database import SessionLocal, ReaderSession, get_db

router = APIRouter()

@router.get("/paragraph/{session_id}", response_class=HTMLResponse)
async def get_paragraph_page(session_id: str):
    return HTMLResponse(content=Path("temp/paragraph.html").read_text())

class ReaderInput(BaseModel):
    input_method: str
    input_data: str

@router.post("/api/reader/input")
async def process_reader_input(data: ReaderInput, db: Session = Depends(get_db)):
    session_id = str(uuid.uuid4())
    
    # Mock AI Logic for text adaptation
    adapted_text = f"Simplified version of your {data.input_method} input:\n\n"
    adapted_text += data.input_data.replace(". ", ".\n\n• ")
    
    # Store in DB
    new_session = ReaderSession(
        session_id=session_id,
        input_method=data.input_method,
        input_text=data.input_data,
        output_text=adapted_text
    )
    db.add(new_session)
    db.commit()

    return {
        "session_id": session_id,
        "input_method": data.input_method,
        "output_text": adapted_text
    }

@router.post("/api/paragraph/done/{session_id}")
async def paragraph_done(session_id: str, db: Session = Depends(get_db)):
    # Verify session exists
    session = db.query(ReaderSession).filter(ReaderSession.session_id == session_id).first()
    return {"status": "ok"}
