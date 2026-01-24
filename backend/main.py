from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from pathlib import Path
from dotenv import load_dotenv
import os

# 1. Load your .env file
load_dotenv()

# 2. MAPPING (This fixes the Genkit error)
# Genkit looks for GOOGLE_GENAI_API_KEY. We map your existing key to it.
if os.getenv("GEMINI_API_KEY"):
    os.environ["GOOGLE_GENAI_API_KEY"] = os.getenv("GEMINI_API_KEY")

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
async def start_chatbot_redirect():
    from fastapi.responses import RedirectResponse
    return RedirectResponse(url="/chat/start")

@app.get("/meditate", response_class=HTMLResponse)
async def read_meditate():
    return HTMLResponse(content=Path("temp/meditate.html").read_text())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
