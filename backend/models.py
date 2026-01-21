from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

class Session(Base):
    __tablename__ = "sessions"

    session_id = Column(String, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    user_agent = Column(Text, nullable=True)
    client_ip = Column(String, nullable=True)

    tasks = relationship("Task", back_populates="session")
    panic_events = relationship("PanicEvent", back_populates="session")
    ai_logs = relationship("AILog", back_populates="session")

class Task(Base):
    __tablename__ = "tasks"

    task_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(String, ForeignKey("sessions.session_id"), nullable=False)
    original_input = Column(Text, nullable=False)
    task_title = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship("Session", back_populates="tasks")
    steps = relationship("TaskStep", back_populates="task")

class TaskStep(Base):
    __tablename__ = "task_steps"

    step_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    task_id = Column(Integer, ForeignKey("tasks.task_id"), nullable=False)
    step_number = Column(Integer, nullable=False)
    step_text = Column(Text, nullable=False)
    is_optional = Column(Boolean, default=False)

    task = relationship("Task", back_populates="steps")

class PanicEvent(Base):
    __tablename__ = "panic_events"

    panic_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(String, ForeignKey("sessions.session_id"), nullable=False)
    trigger_reason = Column(Text, nullable=True)
    ai_response = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship("Session", back_populates="panic_events")
    grounding_exercises = relationship("GroundingExercise", back_populates="panic_event")

class GroundingExercise(Base):
    __tablename__ = "grounding_exercises"

    exercise_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    panic_id = Column(Integer, ForeignKey("panic_events.panic_id"), nullable=False)
    exercise_type = Column(String, nullable=False) # e.g., breathing, sensory
    instruction_text = Column(Text, nullable=False)

    panic_event = relationship("PanicEvent", back_populates="grounding_exercises")

class AILog(Base):
    __tablename__ = "ai_logs"

    log_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(String, ForeignKey("sessions.session_id"), nullable=False)
    endpoint_name = Column(String, nullable=False)
    prompt_sent = Column(Text, nullable=False)
    raw_ai_response = Column(Text, nullable=False)
    parsed_successfully = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship("Session", back_populates="ai_logs")
