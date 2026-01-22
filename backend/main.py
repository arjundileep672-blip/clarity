from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from pathlib import Path
from app import tasker, paragraph, chatbot
from app.database import init_db

# Initialize database tables
init_db()

app = FastAPI()

# Mount Module Routers
app.include_router(tasker.router)
app.include_router(paragraph.router)
app.include_router(chatbot.router)

@app.get("/", response_class=HTMLResponse)
async def read_index():
    return HTMLResponse(content=Path("temp/index.html").read_text())

@app.get("/input", response_class=HTMLResponse)
async def read_input():
    return HTMLResponse(content=Path("temp/input.html").read_text())

@app.get("/chatbot")
async def start_chatbot():
    import uuid
    from fastapi.responses import RedirectResponse
    session_id = str(uuid.uuid4())
    return RedirectResponse(url=f"/chat/{session_id}")

@app.get("/meditate", response_class=HTMLResponse)
async def read_meditate():
    return HTMLResponse(content=Path("temp/meditate.html").read_text())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
