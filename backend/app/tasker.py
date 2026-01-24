import uuid
import os
import json
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from fastapi.responses import HTMLResponse
from pathlib import Path
from sqlalchemy.orm import Session

# AI Configuration
from app.ai_config import ai

# Database Imports
from app.database import Task, TaskStep, get_db

router = APIRouter()



MODELS_DIR = os.path.join("models", "tasker")

class TaskStartRequest(BaseModel):
    input_method: str
    input_data: str

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

async def call_genkit_tasker(input_text: str):
    base_instruction = (
        "You are a task deconstructor. Break down the user's input into a short title "
        "and 5-7 actionable steps. Return ONLY a strict JSON object with 'title' and 'steps'. "
        "Format: {'title': '...', 'steps': ['...', '...']}"
    )
    
    custom_context = load_custom_prompts()
    full_instruction = base_instruction + ("\n\nContext:\n" + custom_context if custom_context else "")

    try:
        # Note: Genkit handles the model selection internally or via plugin registration
        response = await ai.generate(
            model="gemini-1.5-pro",
            prompt=f"{full_instruction}\n\nUser Input: {input_text}"
        )
        return json.loads(response.text)
    except Exception as e:
        print(f"Genkit Tasker Error: {e}")
        return {
            "title": "Task Deconstruction",
            "steps": ["Step 1: Analyze input", "Step 2: Define goals", "Step 3: Organize actions"]
        }

@router.get("/tasker/{session_id}", response_class=HTMLResponse)
async def get_tasker_page(session_id: str):
    return HTMLResponse(content=Path("temp/tasker.html").read_text())

@router.post("/api/tasker/start")
async def start_task_deconstruction(data: TaskStartRequest, db: Session = Depends(get_db)):
    ai_output = await call_genkit_tasker(data.input_data)
    session_id = str(uuid.uuid4())
    new_task = Task(
        session_id=session_id, 
        input_method=data.input_method, 
        input_data=data.input_data, 
        task_title=ai_output.get("title", "Task"), 
        status="active", 
        created_at=datetime.utcnow()
    )
    db.add(new_task)
    db.flush() 

    steps = ai_output.get("steps", [])
    for i, step_text in enumerate(steps, 1):
        db.add(TaskStep(
            task_id=new_task.id, 
            step_index=i, 
            step_text=step_text, 
            is_completed=False, 
            status="active", 
            created_at=datetime.utcnow()
        ))
    
    db.commit()
    return {"session_id": session_id}

@router.get("/api/tasker/details/{session_id}")
async def get_task_details(session_id: str, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.session_id == session_id).first()
    if not task: raise HTTPException(status_code=404)
    steps = db.query(TaskStep).filter(TaskStep.task_id == task.id).order_by(TaskStep.step_index).all()
    return {"task_title": task.task_title, "steps": [{"step_text": s.step_text, "is_completed": s.is_completed} for s in steps]}

@router.post("/api/tasker/done/{session_id}")
async def tasker_done(session_id: str, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.session_id == session_id).first()
    if task:
        task.status = "completed"
        task.completed_at = datetime.utcnow()
        db.commit()
    return {"status": "ok"}
