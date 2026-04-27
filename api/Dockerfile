# Use the official lightweight Python image
FROM python:3.11-slim

# Set the working directory to /app
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the backend code
COPY . .

# Expose default Cloud Run port
EXPOSE 8080

# Run uvicorn server, using the PORT environment variable
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
