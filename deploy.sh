#!/bin/bash

# Elite Deployment Script for NourishIQ Backend to Google Cloud Run
PROJECT_ID="local-axis-494608-r6"
REGION="asia-south1"
SERVICE_NAME="nourishiq-api"

echo "=== Enterprise Deployment using Cloud Run Source Deploy ==="
# We use '--source' to automatically build and deploy without manually creating Artifact Registry repos.
# This avoids the "Image not found" and "Permission Denied" errors associated with manual docker tags.

gcloud run deploy $SERVICE_NAME \
    --source ./api \
    --region $REGION \
    --project $PROJECT_ID \
    --cpu 1 \
    --memory 512Mi \
    --concurrency 80 \
    --allow-unauthenticated \
    --set-env-vars="GEMINI_MODEL=gemini-2.0-flash"

echo "Deployment Hardened & Complete!"
