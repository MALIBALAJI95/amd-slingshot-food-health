# NourishIQ — Predictive Food Intelligence

<p align="center">
  <img src="https://img.shields.io/badge/Google%20Solution%20Challenge-2026-4285F4?style=for-the-badge&logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/Gemini%203.1-Flash-FF6F00?style=for-the-badge&logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/SDG%203-Good%20Health-4CAF50?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Cloud%20Run-Deployed-1A73E8?style=for-the-badge&logo=googlecloud&logoColor=white" />
</p>

## 🧠 What is NourishIQ?

**NourishIQ** is an AI-powered predictive nutrition intelligence platform that recommends optimal meals based on the intersection of:

- 🕐 **Circadian Phase** — Time-aware meal optimization using IST
- 🌦️ **Real-Time Weather** — Auto-detected via Open-Meteo API
- ❤️ **Biometric State** — Heart rate and mood correlation
- 📅 **Schedule Density** — Google Calendar integration for busy/relaxed meal adaptation
- 📍 **Hyperlocal Context** — Bengaluru-focused with Google Maps restaurant suggestions

> **UN SDG 3 — Good Health and Well-Being**: NourishIQ uses predictive analytics to encourage scientifically-backed nutritional choices aligned with individual circadian rhythms and lifestyle patterns.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              React Frontend (Vite)              │
│   Tailwind CSS · Framer Motion · Bento Grid     │
│   WeatherSync · BioState · LifeFlow · Meals     │
└───────────────────┬─────────────────────────────┘
                    │ REST API
┌───────────────────▼─────────────────────────────┐
│            FastAPI Backend (Python)              │
│   HybridIntelligence Engine · Pydantic Models   │
│   CalendarService · MapsService · KeepService   │
└───────────────────┬─────────────────────────────┘
                    │ OAuth2 Service Account
┌───────────────────▼─────────────────────────────┐
│           Google Cloud Platform                 │
│   Vertex AI (Gemini) · Cloud Run · Secret Mgr   │
│   Workload Identity · Artifact Registry         │
└─────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Backend
```bash
cd api
python -m venv venv && venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --port 8001
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

Open **http://localhost:3000** — the React app proxies API calls to the backend automatically.

## 🔒 Security

| Feature | Implementation |
|---|---|
| Secret Management | GCP Secret Manager (runtime resolution) |
| Auth | OAuth2 Service Account + Workload Identity |
| CORS | Restricted to approved origins in production |
| Data Minimization | Zero `print()` statements in production code |
| Key Handling | Service Account JSON via `GOOGLE_APPLICATION_CREDENTIALS` env var |

## ♿ Accessibility

- Every interactive element has `aria-label` attributes
- `aria-live="polite"` regions for dynamic content updates
- High-contrast color palette (4.5:1 WCAG AA compliant)
- Keyboard-navigable mood selection pills
- Screen-reader announcements on AI state transitions

## 🧪 Testing

```bash
# Backend unit tests
cd api && python -m pytest ../tests/ -v

# Frontend (when Flutter SDK available)
cd app && flutter test
```

## 📦 Deployment

```bash
# Deploy to Cloud Run via Artifact Registry
bash deploy.sh
```

## 🏆 Google Solution Challenge Rubric Coverage

| Criterion | Score Strategy |
|---|---|
| **Code Quality** | Clean React components, FastAPI type-hinting, Pydantic validation |
| **Security** | Workload Identity, Secret Manager, no hardcoded keys |
| **Accessibility** | ARIA labels, high-contrast, keyboard nav, screen-reader support |
| **Efficiency** | Async FastAPI, Gemini Flash, serverless Cloud Run autoscaling |
| **Google Services** | Vertex AI, Cloud Run, Maps, Calendar, Keep architecture |

## 📄 License

MIT — Built for the Google Solution Challenge 2026.
