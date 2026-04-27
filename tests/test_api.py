from fastapi.testclient import TestClient
from api.main import app
from api.dependencies import get_vertex_model
from unittest.mock import MagicMock

client = TestClient(app)

def get_mock_vertex_model():
    mock_model = MagicMock()
    mock_response = MagicMock()
    mock_response.text = '{"south_indian_dish": {"name": "Idli", "why": "Test"}, "global_dish": {"name": "Oats", "why": "Test"}, "overall_rationale": "Test"}'
    mock_model.generate_content.return_value = mock_response
    return mock_model

# Override the dependency for testing
app.dependency_overrides[get_vertex_model] = get_mock_vertex_model

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to NourishIQ API"}

def test_recommend_success():
    payload = {"heart_rate": 72, "mood": "Calm", "weather": "Sunny"}
    response = client.post("/api/recommend", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "south_indian_dish" in data
    assert data["south_indian_dish"]["name"] == "Idli"

def test_recommend_validation_error_422():
    # Missing required field "mood"
    payload = {"heart_rate": 72}
    response = client.post("/api/recommend", json=payload)
    assert response.status_code == 422
