import pytest
from unittest.mock import MagicMock
from api.intelligence import get_predictive_meal_nudge, RecommendationRequest

def test_get_predictive_meal_nudge_success():
    req = RecommendationRequest(heart_rate=70, mood="Energetic")
    
    # Mock GenerativeModel
    mock_model = MagicMock()
    mock_response = MagicMock()
    # Mocking the JSON string returned by Vertex AI
    mock_response.text = '{"south_indian_dish": {"name": "Test Dosa", "why": "Mocked why"}, "global_dish": {"name": "Test Pasta", "why": "Mocked why"}, "overall_rationale": "Mocked rationale"}'
    mock_model.generate_content.return_value = mock_response

    response = get_predictive_meal_nudge(req, mock_model)
    
    assert response.south_indian_dish.name == "Test Dosa"
    assert response.global_dish.name == "Test Pasta"
    assert mock_model.generate_content.called

def test_get_predictive_meal_nudge_invalid_json():
    req = RecommendationRequest(heart_rate=70, mood="Energetic")
    mock_model = MagicMock()
    mock_response = MagicMock()
    mock_response.text = 'invalid json'
    mock_model.generate_content.return_value = mock_response

    with pytest.raises(RuntimeError):
        get_predictive_meal_nudge(req, mock_model)
