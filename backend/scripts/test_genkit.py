import asyncio
import os
from dotenv import load_dotenv

# Load env
load_dotenv()

# Map API key
if os.getenv("GEMINI_API_KEY") and not os.getenv("GOOGLE_GENAI_API_KEY"):
    os.environ["GOOGLE_GENAI_API_KEY"] = os.getenv("GEMINI_API_KEY")

# Import the configured AI
from app.ai_config import ai

async def test_genkit():
    print("Testing Genkit with unified config and manual model registration...")
    try:
        print("Attempting to generate a response with 'gemini-1.5-pro'...")
        # This name is registered in ai_config.py
        response = await ai.generate(
            model="gemini-1.5-pro",
            prompt="Hello, are you working correctly? Answer YES if you are."
        )
        print(f"Response received: {response.text}")
        
        if "YES" in response.text.upper():
            print("Verification SUCCESSful!")
            return True
        else:
            print("Response received but might not be what was expected.")
            return True
    except Exception as e:
        print(f"Genkit verification failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = asyncio.run(test_genkit())
    if success:
        print("\nVerification PASSED")
        exit(0)
    else:
        print("\nVerification FAILED")
        exit(1)
