# CLARITY – BACKEND DOCUMENTATION

This repository contains the backend for **Clarity**, an accessibility-first, AI-powered application designed to support neurodivergent students (ADHD, dyslexia, anxiety).

The backend is intentionally built as the system of record and decision maker.
All application logic, session management, database writes, and AI orchestration live here.

The frontend (implemented in Flutter) is treated as a replaceable client that consumes backend APIs.


## CORE ARCHITECTURAL PHILOSOPHY

Clarity follows a strict separation of concerns:

- Backend = brain
- Database = source of truth
- Frontend = presentation layer
- AI = assistant, not controller

The backend:
- generates and owns session IDs
- controls navigation flow
- validates AI output
- persists all user-visible state

The AI:
- never generates IDs
- never touches the database
- never controls routing or UI
- only transforms text when requested


## TECH STACK

Backend:
- FastAPI (Python)
- SQLite
- SQLAlchemy ORM

Frontend:
- Flutter (Material 3, accessibility-first UI)

AI:
- Gemini, accessed via a separate Firebase / Genkit service

The backend and AI engine are intentionally decoupled.


## SESSION MODEL

Clarity is fully session-based.

- There are NO user accounts
- There is NO authentication
- Every interaction belongs to a backend-generated session_id
- session_id is included in all relevant API calls
- The frontend never generates or mutates session IDs

This design keeps the system simple and demo-friendly while remaining extensible.


## APPLICATION MODULES

The backend supports three independent modules.


### MODULE 1: TASK DECONSTRUCTOR

**Purpose:**
Convert unstructured input into a clear, actionable checklist.

**Flow:**
Home (Flutter)
→ Input screen
→ Backend processing
→ Task output screen

**Backend behavior:**
- receives user input
- sends input to AI engine
- validates structured AI output
- stores task and steps in the database
- tracks step completion and task status

The AI only suggests structure.
The backend owns task state.


### MODULE 2: SENSORY-SAFE READER

**Purpose:**
Rewrite text into a calm, sensory-safe, easy-to-read format.

**Flow:**
Home (Flutter)
→ Input screen
→ Backend processing
→ Reading screen

**Backend behavior:**
- sends text to AI engine
- receives adapted text
- stores the result as a reader session
- returns content to the frontend

This module has no progress tracking.


### MODULE 3: CHATBOT

**Purpose:**
Provide a simple, session-based conversational assistant.

**Flow:**
Home (Flutter)
→ Chat screen
→ Backend chat session
→ AI-assisted responses

**Backend behavior:**
- creates chat sessions
- stores all user and AI messages
- sends message history to AI engine
- validates and persists AI replies
- cleanly ends sessions on user action

The frontend never communicates with the AI directly.


## AI INTEGRATION MODEL

AI is implemented as a separate Firebase / Genkit service.

- The backend calls the AI service over HTTP
- The AI service is stateless
- The AI service does not manage sessions
- The AI service does not store data

Each module uses a dedicated AI function:
- tasker_ai
- paragraph_ai
- chatbot_ai

Each function loads its own prompt files and returns strictly structured output.


## DATABASE RESPONSIBILITY

The database is the single source of truth.

- All sessions are created by the backend
- All AI outputs that affect the UI are persisted
- The frontend never writes directly to the database
- The AI service never writes to the database


## GOAL OF THIS BACKEND

This backend is optimized for:
- clarity over complexity
- predictable behavior
- resilience to AI failure
- rapid iteration for demos and hackathons

The architecture intentionally avoids:
- premature abstraction
- hidden state
- frontend-owned logic
- AI-driven control flow

---

## Installation & Setup

1.  **Install Dependencies:**
    ```bash
    pip install "fastapi[standard]" fastapi uvicorn sqlalchemy python-dotenv
    ```
    *Note: It's recommended to use a virtual environment.*
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    pip install -r requirements.txt
    ```

2.  **Environment Variables:**
    Ensure you have a `.env` file with your `GEMINI_API_KEY`.

3.  **Run the Server:**
    ```bash
    python main.py
    ```
    The server will start at `http://0.0.0.0:8000`.
