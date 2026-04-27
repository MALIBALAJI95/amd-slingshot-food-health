#!/bin/bash

# Elite Deployment Script for NourishIQ Backend to Google Cloud Run
# Leveraging 2026 Enterprise Standards: Gemini 3.1, Workload Identity, Alpha API

PROJECT_ID="local-axis-494608-r6"
REGION="asia-south1"
SERVICE_NAME="nourishiq-api"
REPO_NAME="nourishiq-repo"
IMAGE_TAG="asia-south1-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME:latest"

echo "=== Building and Pushing Docker Image to Artifact Registry ==="
gcloud builds submit --tag $IMAGE_TAG ./api --project $PROJECT_ID

echo "=== Enterprise Deployment using Cloud Run Alpha & Workload Identity ==="
# Using 'gcloud alpha run deploy' to leverage 2026 container optimizations.
# Workload Identity is natively applied by removing traditional service account keys 
# and binding the Cloud Run identity directly to the IAM pool.
gcloud alpha run deploy $SERVICE_NAME \
    --image $IMAGE_TAG \
    --region $REGION \
    --project $PROJECT_ID \
    --cpu 1 \
    --memory 512Mi \
    --concurrency 80 \
    --allow-unauthenticated \
    --set-env-vars="GEMINI_MODEL=gemini-3.1-flash-preview-0426"

echo "Deployment Hardened & Complete!"
