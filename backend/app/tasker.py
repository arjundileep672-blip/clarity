from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime
import uuid

router = APIRouter()

class TaskInput(BaseModel):
    input_method: str # paragraph | audio | image
    input_data: str

@router.post("/api/tasker/input")
async def process_task_input(data: TaskInput):
    # 1. Generate session and task IDs
    session_id = str(uuid.uuid4())
    task_id = 101 # Mock ID from DB
    
    # 2. Mock AI Logic for static TODO list
    # In production, this would call an AI module
    steps_text = [
        "Find all trash and put it in a bag",
        "Clear items off the floor",
        "Make the bed",
        "Dust the desk surfaces"
    ]
    
    steps_response = []
    for i, text in enumerate(steps_text):
        steps_response.append({
            "step_index": i,
            "step_text": text,
            "is_completed": False
        })
        
    # 3. Store in DB (Logic assumed in database.py)
    # create_task(session_id, data.input_method, data.input_data)
    # create_steps(task_id, steps_response)

    return {
        "status": "success",
        "task_id": task_id,
        "session_id": session_id,
        "steps": steps_response
    }
