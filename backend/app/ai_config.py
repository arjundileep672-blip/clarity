import os
import asyncio
from genkit.ai import Genkit
from google import genai
from genkit.core.typing import GenerateResponse, Message, Part
from genkit.blocks.model import GenerateResponseWrapper
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Genkit
ai = Genkit()

# Map API keys for consistency
api_key = os.getenv("GOOGLE_GENAI_API_KEY") or os.getenv("GEMINI_API_KEY")
if api_key:
    os.environ["GOOGLE_GENAI_API_KEY"] = api_key

# Initialize Google GenAI client
client = genai.Client(api_key=api_key)

# Use a model that we know works in this environment
# From our available_models.txt: models/gemini-flash-latest
MODEL_ID = "gemini-flash-latest"

async def google_ai_model(request, streaming_callback=None):
    """A wrapper for google-genai to act as a Genkit model."""
    try:
        # Extract context from messages
        contents = []
        for msg in request.messages:
            role = "user" if msg.role == "user" else "model"
            msg_text = "".join([p.text for p in msg.content if hasattr(p, 'text')])
            contents.append({"role": role, "parts": [{"text": msg_text}]})
        
        print(f"Genkit Wrapper: Generating with {MODEL_ID} for {len(contents)} messages")
        
        # Perform generation
        def sync_gen():
            return client.models.generate_content(
                model=MODEL_ID,
                contents=contents
            )

        response = await asyncio.to_thread(sync_gen)
        
        print(f"Genkit Wrapper: Generation successful. Response: {response.text[:50]}...")
        
        return GenerateResponse(
            message=Message(
                role="model",
                content=[Part(text=response.text)]
            ),
            finish_reason="STOP",
            usage={}
        )
    except Exception as e:
        print(f"Genkit Wrapper ERROR: {e}")
        import traceback
        traceback.print_exc()
        raise e

# Register the model with Genkit
# This registers under multiple names to ensure all modules find it
for name in ["googleai/gemini-1.5-pro", "gemini-1.5-pro", "googleai/gemini-2.0-flash", "gemini-2.0-flash"]:
    ai.define_model(
        name=name,
        fn=google_ai_model
    )

print(f"Genkit initialized with manual model registration for {MODEL_ID}")
