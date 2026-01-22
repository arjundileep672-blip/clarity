from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    Text,
    Boolean,
    DateTime,
    ForeignKey,
    event
)
from sqlalchemy.orm import declarative_base, relationship, sessionmaker
from datetime import datetime

# -----------------------------
# Database configuration
# -----------------------------

DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

# Enable foreign key support for SQLite (SAFE, NO EXTRA WORK)
@event.listens_for(engine, "connect")
def enable_sqlite_foreign_keys(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()

# -----------------------------
# Task Deconstructor
# -----------------------------

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String, nullable=False)

    input_method = Column(String, nullable=False)      # paragraph | audio | photo
    input_data = Column(Text, nullable=False)

    task_title = Column(String)
    status = Column(String, nullable=False, default="active")  # active | completed

    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)

    steps = relationship(
        "TaskStep",
        back_populates="task",
        cascade="all, delete-orphan"
    )


class TaskStep(Base):
    __tablename__ = "task_steps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(Integer, ForeignKey("tasks.id"), nullable=False)

    step_index = Column(Integer, nullable=False)
    step_text = Column(Text, nullable=False)

    is_completed = Column(Boolean, nullable=False, default=False)
    status = Column(String, nullable=False, default="active")

    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)

    task = relationship("Task", back_populates="steps")

# -----------------------------
# Sensory-Safe Reader
# -----------------------------

class ReaderSession(Base):
    __tablename__ = "reader_sessions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String, nullable=False)

    input_method = Column(String, nullable=False)
    input_text = Column(Text, nullable=False)

    output_text = Column(Text, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

# -----------------------------
# Chatbot
# -----------------------------

class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(String, primary_key=True)   # UUID
    module = Column(String, nullable=False, default="chatbot")
    status = Column(String, nullable=False, default="active")  # active | ended

    created_at = Column(DateTime, default=datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)

    messages = relationship(
        "ChatMessage",
        back_populates="session",
        cascade="all, delete-orphan"
    )


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String, ForeignKey("chat_sessions.id"), nullable=False)

    sender = Column(String, nullable=False)   # user | ai
    message_text = Column(Text, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    session = relationship("ChatSession", back_populates="messages")

# -----------------------------
# FastAPI dependency
# -----------------------------

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# -----------------------------
# Init DB
# -----------------------------

def init_db():
    Base.metadata.create_all(bind=engine)

