import os
import json
from datetime import datetime
import pytz
from pydantic import BaseModel, Field
from typing import List, Optional
import httpx
from google.oauth2 import service_account
from google.auth.transport.requests import Request

# ── SERVICE ACCOUNT AUTH ──
SA_PATH = os.environ.get(
    "GOOGLE_APPLICATION_CREDENTIALS",
    os.path.join(os.path.dirname(__file__), "service_account.json")
)
_cached_credentials = None

def _get_credentials():
    global _cached_credentials
    if _cached_credentials is None or not _cached_credentials.valid:
        _cached_credentials = service_account.Credentials.from_service_account_file(
            SA_PATH, scopes=["https://www.googleapis.com/auth/cloud-platform",
                             "https://www.googleapis.com/auth/generative-language"])
        _cached_credentials.refresh(Request())
    elif _cached_credentials.expired:
        _cached_credentials.refresh(Request())
    return _cached_credentials

# ── PYDANTIC MODELS ──
class CalendarEvent(BaseModel):
    title: str
    start_time: str
    end_time: str
    location: Optional[str] = None

class NearbyRestaurant(BaseModel):
    name: str
    cuisine: str
    rating: float
    maps_link: str

class ShoppingItem(BaseModel):
    item: str
    quantity: str

class PredictRequest(BaseModel):
    heart_rate: int = 75
    mood: str = "Energetic"
    weather: str = ""
    location: str = ""
    latitude: float = 12.97
    longitude: float = 77.59

class DishOutput(BaseModel):
    name: str
    calories: int
    why: str
    image_prompt: str

class PredictResponse(BaseModel):
    reasoning_chain: dict
    south_indian_dish: DishOutput
    global_dish: DishOutput
    overall_rationale: str
    google_maps_link: Optional[str] = None
    restaurant_suggestion: Optional[str] = None
    keep_shopping_list: List[ShoppingItem] = []

# ── CALENDAR SERVICE (Google Calendar API Architecture) ──
class CalendarService:
    @staticmethod
    def get_schedule_context():
        ist = pytz.timezone("Asia/Kolkata")
        hour = datetime.now(ist).hour
        events = [
            CalendarEvent(title="Sprint Standup", start_time="09:00", end_time="09:30"),
            CalendarEvent(title="Design Review", start_time="09:30", end_time="10:15"),
            CalendarEvent(title="Project Pitch", start_time="10:30", end_time="11:30", location="Google Bengaluru Office"),
            CalendarEvent(title="Team Lunch", start_time="12:30", end_time="13:30", location="Marriott Convention Centre"),
            CalendarEvent(title="Deep Work Block", start_time="14:00", end_time="16:00"),
            CalendarEvent(title="1-on-1 with Manager", start_time="16:00", end_time="16:30"),
        ]
        busy = 0
        for i in range(len(events) - 1):
            eh, em = map(int, events[i].end_time.split(":"))
            sh, sm = map(int, events[i+1].start_time.split(":"))
            if (sh*60+sm) - (eh*60+em) < 30:
                busy += 1
        density = "Very Busy" if busy >= 3 else ("Moderate" if busy >= 1 else "Relaxed")
        upcoming = None
        for e in events:
            if int(e.start_time.split(":")[0]) >= hour:
                upcoming = e
                break
        return {"density": density, "upcoming_event": upcoming, "all_events": events, "busy_blocks": busy}

# ── MAPS SERVICE (Google Maps Places API Architecture) ──
class MapsService:
    @staticmethod
    def get_nearby_restaurants(location):
        return [
            NearbyRestaurant(name="MTR (Mavalli Tiffin Rooms)", cuisine="South Indian Vegetarian", rating=4.5, maps_link="https://maps.google.com/?q=MTR+Bengaluru"),
            NearbyRestaurant(name="Vidyarthi Bhavan", cuisine="Traditional Karnataka", rating=4.4, maps_link="https://maps.google.com/?q=Vidyarthi+Bhavan+Bengaluru"),
            NearbyRestaurant(name="The Permit Room", cuisine="Modern South Indian", rating=4.3, maps_link="https://maps.google.com/?q=The+Permit+Room+Bengaluru"),
        ]

# ── HYBRID INTELLIGENCE ENGINE ──
SYSTEM_PROMPT = """You are an Elite Clinical Nutritionist with "Deep Think" agentic reasoning.
You analyze the intersection of Circadian Phase, Real-time Weather, Bio-Markers, and Schedule Density.

SCHEDULE-ADAPTIVE RULES:
- If Schedule = "Very Busy": Weight "Ease of Prep" and "Portability" at 90%.
- If Schedule = "Relaxed": Weight "Cooking Skill" and "Nutrient Density" at 90%.
- If user has a dining-out event: Suggest the "Best Health Bet" from nearby restaurants.

AGENTIC GUARDRAIL: If time is after 9 PM IST, strictly prohibit high-sugar or heavy-carb suggestions.

Return STRICTLY as JSON (no markdown):
{
  "reasoning_chain": {
    "step_1_circadian_analysis": "...",
    "step_2_weather_impact": "...",
    "step_3_biomarker_correlation": "...",
    "step_4_schedule_adaptation": "..."
  },
  "south_indian_dish": {"name": "...", "calories": 350, "why": "...", "image_prompt": "..."},
  "global_dish": {"name": "...", "calories": 400, "why": "...", "image_prompt": "..."},
  "overall_rationale": "...",
  "restaurant_suggestion": "..." or null,
  "google_maps_link": "..." or null,
  "keep_shopping_list": [{"item": "...", "quantity": "..."}, ...]
}

'image_prompt' must vividly describe the plated dish for an AI image generator.
'keep_shopping_list' should have 4-6 ingredients."""


class HybridIntelligence:
    """Fail-safe engine: tries live Gemini, falls back to high-fidelity mock."""

    @staticmethod
    def _get_circadian():
        ist = pytz.timezone("Asia/Kolkata")
        now = datetime.now(ist)
        hour = now.hour
        ts = now.strftime("%I:%M %p")
        if 5 <= hour < 12: phase = "Morning"
        elif 12 <= hour < 17: phase = "Afternoon"
        elif 17 <= hour < 21: phase = "Evening"
        else: phase = "Night"
        return ts, hour, phase

    @staticmethod
    def _fallback(req, ts, phase, density, upcoming, restaurants):
        is_night = phase == "Night"
        is_busy = "Very Busy" in density
        dining_out = upcoming is not None and upcoming.location is not None

        if is_night:
            south = {"name": "Light Pepper Rasam with Rice", "calories": 220,
                     "why": "Low-glycemic, warm soup for night digestion. Guardrail: zero sugar, minimal carbs.",
                     "image_prompt": "A steaming bowl of golden pepper rasam with curry leaves and mustard seeds, served with white rice on a brass plate"}
            globe = {"name": "Warm Chamomile Oat Bowl", "calories": 180,
                     "why": "Melatonin-precursor rich, promotes sleep. Guardrail-compliant: no added sugar.",
                     "image_prompt": "Warm steel-cut oats topped with almonds, honey drizzle, and chamomile flowers on a wooden table"}
        elif is_busy:
            south = {"name": "Masala Dosa Wrap (Portable)", "calories": 340,
                     "why": "High-energy portable format for back-to-back meetings. Complex carbs for sustained focus.",
                     "image_prompt": "Crispy golden masala dosa rolled into a wrap with spiced potato, coconut chutney and sambar in containers"}
            globe = {"name": "Mediterranean Hummus Power Bowl", "calories": 380,
                     "why": "Grab-and-go protein bowl. Chickpea-based sustained energy for a busy schedule.",
                     "image_prompt": "Colorful Mediterranean bowl with hummus, cherry tomatoes, cucumber, feta, olives, olive oil in a takeaway bowl"}
        else:
            south = {"name": "Bisi Bele Bath with Papad", "calories": 450,
                     "why": "Classic Karnataka comfort food. Rich in lentil protein and seasonal vegetables.",
                     "image_prompt": "Generous plate of Bisi Bele Bath topped with roasted cashews, served with crispy papad and raita on banana leaf"}
            globe = {"name": "Grilled Salmon with Quinoa Salad", "calories": 520,
                     "why": "Omega-3 rich protein with complex carbs. Nutrient-dense for a relaxed schedule.",
                     "image_prompt": "Grilled salmon fillet with crispy skin alongside quinoa salad with avocado, tomatoes, microgreens on white plate"}

        rest_sug = None
        maps_link = None
        if dining_out and restaurants:
            rest_sug = "Since you are heading to " + upcoming.location + ", " + restaurants[0].name + " (" + restaurants[0].cuisine + ") is your best health-aligned option."
            maps_link = restaurants[0].maps_link

        energy_type = "sustained energy" if phase == "Afternoon" else ("metabolic activation" if phase == "Morning" else "wind-down nutrition")
        if is_night:
            circ_text = "Current IST: " + ts + ". Night phase. Post-9PM guardrail active."
        else:
            circ_text = "Current IST: " + ts + ". " + phase + " phase — optimizing for " + energy_type + "."

        wloc = req.location or "Bengaluru"
        wval = req.weather or "Partly cloudy, 28C"
        is_warm = "Sunny" in wval or "Clear" in wval
        w_text = "Weather in " + wloc + ": " + wval + ". " + ("Warm — prioritizing hydration and lighter foods." if is_warm else "Cool — favoring warm, comforting meals.")

        hr_note = "Elevated HR — recovery nutrition." if req.heart_rate > 100 else "Normal resting HR."
        mood_note = "Stress detected: magnesium-rich foods." if req.mood == "Stressed" else "Mood: " + req.mood + " — maintaining state."
        bio_text = "HR: " + str(req.heart_rate) + " bpm. " + hr_note + " " + mood_note

        sched_text = "Schedule: " + density + ". " + ("Back-to-back — portability 90%." if is_busy else "Open — nutrient-dense home meals.")

        night_extra = " Night guardrail enforced." if is_night else ""
        rationale = "Optimized for " + phase.lower() + " phase, " + req.mood.lower() + " mood, " + density.lower() + " schedule." + night_extra

        return {
            "reasoning_chain": {
                "step_1_circadian_analysis": circ_text,
                "step_2_weather_impact": w_text,
                "step_3_biomarker_correlation": bio_text,
                "step_4_schedule_adaptation": sched_text,
            },
            "south_indian_dish": south,
            "global_dish": globe,
            "overall_rationale": rationale,
            "restaurant_suggestion": rest_sug,
            "google_maps_link": maps_link,
            "keep_shopping_list": [
                {"item": south["name"].split("(")[0].strip().split(" with ")[0], "quantity": "2 servings"},
                {"item": "Fresh Curry Leaves", "quantity": "1 bunch"},
                {"item": "Coconut (fresh)", "quantity": "1 medium"},
                {"item": "Greek Yogurt", "quantity": "200g"},
                {"item": "Mixed Nuts", "quantity": "100g"},
                {"item": "Seasonal Vegetables", "quantity": "500g"},
            ],
        }

    @staticmethod
    async def predict(req):
        ts, hour, phase = HybridIntelligence._get_circadian()
        cal = CalendarService.get_schedule_context()
        density = cal["density"]
        upcoming = cal["upcoming_event"]
        restaurants = []
        dining_out = False
        if upcoming and upcoming.location:
            restaurants = MapsService.get_nearby_restaurants(upcoming.location)
            dining_out = True

        rest_ctx = ""
        if restaurants:
            rest_ctx = "Nearby: " + ", ".join(r.name + " (" + r.cuisine + ")" for r in restaurants)

        prompt = (
            "Context:\n"
            "- Location: " + (req.location or "Bengaluru") + "\n"
            "- Time (IST): " + ts + "\n"
            "- Circadian Phase: " + phase + "\n"
            "- Mood: " + req.mood + "\n"
            "- Heart Rate: " + str(req.heart_rate) + " bpm\n"
            "- Weather: " + (req.weather or "Unknown") + "\n"
            "- Schedule Density: " + density + "\n"
            "- Upcoming Event: " + (upcoming.model_dump_json() if upcoming else "None") + "\n"
            "- Dining Out: " + str(dining_out) + "\n"
            "- " + rest_ctx + "\n\n"
            "Execute your full reasoning chain."
        )

        # ── TRY LIVE GEMINI ──
        try:
            creds = _get_credentials()
            token = creds.token
            model = "gemini-2.0-flash"
            endpoints = [
                "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent",
                "https://asia-south1-aiplatform.googleapis.com/v1/projects/local-axis-494608-r6/locations/asia-south1/publishers/google/models/" + model + ":generateContent",
            ]
            headers = {"Authorization": "Bearer " + token, "Content-Type": "application/json"}
            payload = {
                "contents": [{"role": "user", "parts": [{"text": SYSTEM_PROMPT + "\n\n" + prompt}]}],
                "generationConfig": {"temperature": 0.25, "maxOutputTokens": 4096, "responseMimeType": "application/json"},
            }
            async with httpx.AsyncClient(timeout=30.0) as client:
                for url in endpoints:
                    resp = await client.post(url, headers=headers, json=payload)
                    if resp.status_code == 200:
                        body = resp.json()
                        text = body["candidates"][0]["content"]["parts"][0]["text"].strip()
                        if text.startswith("```"):
                            text = text.split("\n", 1)[1]
                        if text.endswith("```"):
                            text = text.rsplit("```", 1)[0]
                        data = json.loads(text.strip())
                        if dining_out and restaurants and not data.get("google_maps_link"):
                            data["google_maps_link"] = restaurants[0].maps_link
                        data["_meta"] = {"source": "gemini-live", "schedule_density": density,
                                         "upcoming_event": upcoming.model_dump() if upcoming else None,
                                         "all_events": [e.model_dump() for e in cal["all_events"]],
                                         "dining_out": dining_out,
                                         "nearby_restaurants": [r.model_dump() for r in restaurants]}
                        return data
            raise RuntimeError("All endpoints failed")
        except Exception:
            # ── FAIL-SAFE FALLBACK ──
            data = HybridIntelligence._fallback(req, ts, phase, density, upcoming, restaurants)
            data["_meta"] = {"source": "hybrid-fallback", "schedule_density": density,
                             "upcoming_event": upcoming.model_dump() if upcoming else None,
                             "all_events": [e.model_dump() for e in cal["all_events"]],
                             "dining_out": dining_out,
                             "nearby_restaurants": [r.model_dump() for r in restaurants]}
            return data
