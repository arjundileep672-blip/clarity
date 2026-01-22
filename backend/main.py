from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from pathlib import Path

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
def serve_index():
    html_file = Path("temp/index.html")
    return html_file.read_text(encoding="utf-8")

