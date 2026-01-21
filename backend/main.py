from fastapi import FastAPI, Depends, Request
from sqlalchemy.orm import Session
from . import models, database
from .database import engine, get_db
import uuid

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Clarity Backend")

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.post("/sessions", status_code=201)
def create_session(request: Request, db: Session = Depends(get_db)):
    """
    Generate a new session_id and store it in the database.
    This mimics the frontend generating a UUID and the backend logging it.
    """
    new_session_id = str(uuid.uuid4())
    db_session = models.Session(
        session_id=new_session_id,
        user_agent=request.headers.get("user-agent"),
        client_ip=request.client.host
    )
    db.add(db_session)
    db.commit()
    db.refresh(db_session)
    return {"session_id": new_session_id}

