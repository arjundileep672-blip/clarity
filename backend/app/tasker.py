from fastapi import APIRouter, Depends
from pydantic import BaseModel
from datetime import datetime
import uuid
from fastapi.responses import HTMLResponse
from pathlib import Path
from sqlalchemy.orm import Session
from app.database import SessionLocal, Task, TaskStep, get_db

router = APIRouter()

@router.get("/tasker/{session_id}", response_class=HTMLResponse)
async def get_tasker_page(session_id: str):
    return HTMLResponse(content=Path("temp/tasker.html").read_text())

class TaskInput(BaseModel):
    input_method: str # paragraph | audio | image
    input_data: str

@router.post("/api/tasker/input")
async def process_task_input(data: TaskInput, db: Session = Depends(get_db)):
    # 1. Generate session ID
    session_id = str(uuid.uuid4())
    
    # 2. Mock AI Logic for static TODO list
    steps_text = [
        "Find all trash and put it in a bag",
        "Clear items off the floor",
        "Make the bed",
        "Dust the desk surfaces"
    ]
    
    # 3. Create Task in DB
    new_task = Task(
        session_id=session_id,
        input_method=data.input_method,
        input_data=data.input_data,
        task_title="Manual Task Deconstruction",
        status="active"
    )
    db.add(new_task)
    db.flush() # To get the task.id
    
    steps_response = []
    for i, text in enumerate(steps_text):
        new_step = TaskStep(
            task_id=new_task.id,
            step_index=i,
            step_text=text,
            is_completed=False,
            status="active"
        )
        db.add(new_step)
        steps_response.append({
            "step_index": i,
            "step_text": text,
            "is_completed": False
        })
    
    db.commit()

    return {
        "status": "success",
        "task_id": new_task.id,
        "session_id": session_id,
        "steps": steps_response
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
