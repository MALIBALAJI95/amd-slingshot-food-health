import os
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from intelligence import HybridIntelligence, PredictRequest

app = FastAPI(
    title="NourishIQ Life-Sync API",
    description="Agentic Nutrition Intelligence powered by Gemini & GCP",
    version="3.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"error": str(exc)})

@app.get("/")
async def root():
    return {"service": "NourishIQ Life-Sync API", "version": "3.1.0", "status": "healthy"}

@app.post("/api/predict")
async def predict(req: PredictRequest):
    """Fully async agentic prediction — Gemini live with fail-safe fallback."""
    try:
        return await HybridIntelligence.predict(req)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
