import os
import uvicorn
from fastapi import FastAPI

app = FastAPI()

# ... (your existing routes) ...

if __name__ == "__main__":
    # Get port from environment or default to 8080
    port = int(os.environ.get("PORT", 8080))
    # MUST listen on 0.0.0.0 to be visible to Cloud Run
    uvicorn.run(app, host="0.0.0.0", port=port)