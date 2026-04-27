import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="NourishIQ API")

# Essential for React Frontend to communicate
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def health_check():
    return {"status": "online", "service": "NourishIQ Agentic Engine"}

@app.get("/api/predict")
async def predict():
    # Final Hybrid Mock Response for Rank 1
    return {
        "dish": "Citrus Kale & Quinoa Power Bowl",
        "reasoning": "High Vitamin C for morning oxidative stress and Quinoa for sustained glucose during your 3PM deep-work session.",
        "weather": "Sunny Bengaluru",
        "image_url": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd"
    }

if __name__ == "__main__":
    # This is the exact fix for the Cloud Run "failed to start" error
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)