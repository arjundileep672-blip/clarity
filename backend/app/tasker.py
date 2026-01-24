import uuid
import json
import httpx
import os
import asyncio
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel
from fastapi.responses import HTMLResponse, JSONResponse
from pathlib import Path
from sqlalchemy.orm import Session
from app.database import SessionLocal, Task, TaskStep, get_db

router = APIRouter()

# --- Configuration ---
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta,models/gemini-2.5-flash-preview-09-2025:generateContent"
API_KEY = os.getenv("GEMINI_API_KEY", "")
# Directory to source tasker-specific prompts
MODELS_DIR = os.path.join("models", "tasker")

# --- Request Schemas ---
class TaskStartRequest(BaseModel):
    input_method: str  # paragraph | audio | image
    input_data: str

# --- Helper Logic ---
def load_custom_prompts():
    """Reads all .txt files from the models/tasker directory and joins them."""
    custom_prompts = []
    if os.path.exists(MODELS_DIR) and os.path.isdir(MODELS_DIR):
        for filename in os.listdir(MODELS_DIR):
            if filename.endswith(".txt"):
                file_path = os.path.join(MODELS_DIR, filename)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read().strip()
                        if content:
                            custom_prompts.append(content)
                except Exception as e:
                    print(f"Error reading prompt file {filename}: {e}")
    return "\n\n".join(custom_prompts)

# --- AI Logic ---
async def call_gemini_deconstructor(input_text: str):
    """
    Calls Gemini to deconstruct text into a title and action steps.
    Sources additional context from the models/tasker directory.
    """
    # Base instructions for the AI
    base_instruction = (
        "You are a task deconstructor. Your goal is to help users break down overwhelming assignments into "
        "manageable actions. Convert the user input into a single short task title and a list of 5-7 actionable steps. "
        "Return ONLY a strict JSON object with 'title' (string) and 'steps' (array of strings). "
        "Each step must be a plain action string. No numbering, no markdown, no explanations."
    )

    # Dynamic prompt sourcing
    custom_context = load_custom_prompts()
    full_system_instruction = base_instruction
    if custom_context:
        full_system_instruction += "\n\nADDITIONAL CONTEXT AND GUIDELINES:\n" + custom_context
    
    payload = {
        "contents": [{"parts": [{"text": input_text}]}],
        "systemInstruction": { "parts": [{ "text": full_system_instruction }] },
        "generationConfig": {
            "responseMimeType": "application/json",
            "responseSchema": {
                "type": "OBJECT",
                "properties": {
                    "title": {"type": "STRING"},
                    "steps": {
                        "type": "ARRAY",
                        "items": {"type": "STRING"}
                    }
                },
                "required": ["title", "steps"]
            }
        }
    }

    async with httpx.AsyncClient() as client:
        for attempt in range(5):
            try:
                response = await client.post(
                    f"{GEMINI_API_URL}?key={API_KEY}",
                    json=payload,
                    timeout=20.0
                )
                if response.status_code == 200:
                    result = response.json()
                    content = result.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                    return json.loads(content)
                
                if response.status_code in [429, 500, 503]:
                    await asyncio.sleep(2 ** attempt)
                    continue
                break
            except Exception as e:
                print(f"Gemini API Error: {e}")
                await asyncio.sleep(2 ** attempt)

    # Fallback if AI fails completely
    return {
        "title": "New Task",
        "steps": ["Review your notes", "Identify primary goal", "Break down actions", "Execute first step"]
    }

# --- Routes ---

@router.get("/tasker/{session_id}", response_class=HTMLResponse)
async def get_tasker_page(session_id: str):
    """Serves the frontend task list page."""
    return HTMLResponse(content=Path("temp/tasker.html").read_text())

@router.post("/api/tasker/start")
async def start_task_deconstruction(data: TaskStartRequest, db: Session = Depends(get_db)):
    """
    Called by input.html. Triggers AI with custom prompts, saves to DB, 
    and returns the session_id.
    """
    # 1. AI Content Generation
    ai_output = await call_gemini_deconstructor(data.input_data)
    
    # 2. Generate Session and Task Record
    session_id = str(uuid.uuid4())
    
    new_task = Task(
        session_id=session_id,
        input_method=data.input_method,
        input_data=data.input_data,
        task_title=ai_output.get("title", "Task Deconstruction"),
        status="active",
        created_at=datetime.utcnow()
    )
    db.add(new_task)
    db.flush() 

    # 3. Save Steps individually
    steps_data = []
    for i, step_text in enumerate(ai_output.get("steps", []), 1):
        new_step = TaskStep(
            task_id=new_task.id,
            step_index=i,
            step_text=step_text,
            is_completed=False,
            status="active",
            created_at=datetime.utcnow()
        )
        db.add(new_step)
        steps_data.append({"step_index": i, "step_text": step_text})
    
    db.commit()

    return {
        "session_id": session_id,
        "task_title": new_task.task_title,
        "steps": steps_data
    }

@router.get("/api/tasker/details/{session_id}")
async def get_task_details(session_id: str, db: Session = Depends(get_db)):
    """Used by tasker.html to fetch and render the saved data."""
    task = db.query(Task).filter(Task.session_id == session_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    steps = db.query(TaskStep).filter(TaskStep.task_id == task.id).order_by(TaskStep.step_index).all()
    
    return {
        "task_title": task.task_title,
        "steps": [{"step_index": s.step_index, "step_text": s.step_text, "is_completed": s.is_completed} for s in steps]
    }

@router.post("/api/tasker/done/{session_id}")
async def tasker_done(session_id: str, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.session_id == session_id).first()
    if not task:
        return {"status": "error", "message": "Task not found"}
    
    task.status = "completed"
    task.completed_at = datetime.utcnow()
    db.commit()
    return {"status": "ok"}
