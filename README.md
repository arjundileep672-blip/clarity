
🌱 CLARITY
=========

**Clarity** is an accessibility-first, AI-powered application built to support neurodivergent students (ADHD, dyslexia, anxiety) in thinking, reading, and learning with less cognitive overload 💙

It is designed with a **backend-first philosophy**, where logic, state, and AI orchestration live on the server — and the frontend (Flutter) focuses purely on delivering a calm, human-friendly experience.


🧠 CORE DESIGN PRINCIPLES
------------------------

- 🧠 Backend owns all logic and decisions  
- 🗄️ Database is the single source of truth  
- 🎨 Frontend is calm, minimal, and replaceable  
- 🤖 AI assists — it never controls  
- 🔑 Everything is session-based  
- 🚫 No user accounts, no authentication  

This keeps the system predictable, resilient, and easy to reason about.


🛠️ TECH STACK
--------------

**Frontend**
- 📱 Flutter (Material 3, accessibility-first design)

**Backend**
- 🧠 FastAPI (Python)
- 🗄️ SQLite
- 🧩 SQLAlchemy ORM

**AI**
- 🤖 Gemini via Firebase + Genkit

The AI engine is fully **decoupled** from the backend.


🔑 SESSION MODEL
----------------

Clarity does **not** use user accounts.

Instead:
- 🔁 Every interaction belongs to a backend-generated `session_id`
- 🧠 `session_id` is created and owned by FastAPI
- 🔗 `session_id` is passed between frontend and backend
- 🚫 The frontend never generates or mutates session IDs

This keeps things simple while preserving continuity.


🧩 APPLICATION MODULES
---------------------

Clarity consists of **three independent modules**, all powered by the same backend and database.


✅ MODULE 1: TASK DECONSTRUCTOR
------------------------------

**Purpose**  
Break large, overwhelming tasks into small, actionable steps 🧩

**Flow**
📱 Flutter Home  
→ ✍️ Task Input  
→ 🧠 FastAPI  
→ 🤖 Firebase AI  
→ 🧠 FastAPI  
→ 📋 Task Output  

**Behavior**
- User submits input
- Backend sends input to AI
- AI returns a task title and ordered steps
- Backend validates and stores the task
- User checks off steps as they go
- Backend tracks progress and completion 🎯

AI suggests structure.  
Backend owns task state.


📖 MODULE 2: SENSORY-SAFE READER
-------------------------------

**Purpose**  
Rewrite text into a calm, sensory-safe, easy-to-read format 🌿

**Flow**
📱 Flutter Home  
→ 📝 Text Input  
→ 🧠 FastAPI  
→ 🤖 Firebase AI  
→ 🧠 FastAPI  
→ 📖 Reading View  

**Behavior**
- Backend sends text to AI
- AI returns adapted text
- Backend stores the result
- User reads without distraction

No progress tracking. No clutter.


💬 MODULE 3: CHATBOT
-------------------

**Purpose**  
A simple, session-based conversational assistant 🤝

**Flow**
📱 Flutter Home  
→ 💬 Chat Screen  
→ 🧠 FastAPI  
→ 🤖 Firebase AI  
→ 🧠 FastAPI  
→ 💬 Chat Screen  

**Behavior**
- Backend creates a chat session
- User sends messages
- Backend stores user messages
- Backend sends full chat history to AI
- AI returns a reply
- Backend stores AI responses
- Session ends explicitly when the user is done 🛑

The frontend never talks to the AI directly.


🤖 AI ARCHITECTURE
------------------

AI is implemented as a **separate Firebase / Genkit service**.

FastAPI:
- 📤 sends input to AI
- 🔍 validates AI output
- 🛟 applies fallbacks on failure
- 🗄️ persists all results


🗄️ DATABASE RESPONSIBILITY
--------------------------

The database is the **source of truth**.

- 🧠 Backend creates and manages all sessions
- 🤖 AI outputs that affect UI are stored
- 🎨 Frontend never writes to the database
- 🤖 AI service never writes to the database


🎯 WHY THIS ARCHITECTURE
-----------------------

This architecture is intentionally strict to avoid:
- ❌ frontend-owned logic
- ❌ hidden state
- ❌ AI-driven control flow
- ❌ overengineering

It enables:
- ✅ predictable behavior
- ✅ resilience to AI failure
- ✅ fast iteration for demos and hackathons
- ✅ easy replacement of frontend or AI engine


🌟 PROJECT GOAL
---------------

Clarity demonstrates how **accessibility-focused design** and **AI assistance** can coexist without sacrificing reliability, control, or clarity.

The system values:
- ✨ simplicity over cleverness
- 🔍 explicit flows over magic
- 🧠 backend authority over distributed logic

Built with care, clarity, and compassion 💙
