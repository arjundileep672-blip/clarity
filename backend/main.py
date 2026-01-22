from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from pathlib import Path
from app import tasker, paragraph, chatbot

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

# For simplicity in temp testing, /chatbot can lead to index.html 
# where the chat logic currently lives or its own file
@app.get("/chatbot", response_class=HTMLResponse)
async def read_chatbot():
    return HTMLResponse(content=Path("temp/index.html").read_text())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
