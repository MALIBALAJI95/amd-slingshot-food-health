import { useState, useEffect } from 'react'
import { AnimatePresence } from 'framer-motion'
import AgenticOrb from './components/AgenticOrb'
import WeatherSync from './components/WeatherSync'
import LifeFlow from './components/LifeFlow'
import BioState from './components/BioState'
import RecommendationCard from './components/RecommendationCard'
import ShoppingList from './components/ShoppingList'
import './App.css'

function App() {
  const [heartRate, setHeartRate] = useState(75)
  const [mood, setMood] = useState('Energetic')
  const [weather, setWeather] = useState({ condition: 'Loading...', temp: '--' })
  const [location, setLocation] = useState('Detecting...')
  const [coords, setCoords] = useState({ lat: 12.97, lon: 77.59 })
  const [isThinking, setIsThinking] = useState(false)
  const [result, setResult] = useState(null)
  const [error, setError] = useState(null)

  // Auto-fetch geolocation + weather on mount
  useEffect(() => {
    async function fetchEnv() {
      try {
        const locRes = await fetch('https://ipapi.co/json/')
        const locData = await locRes.json()
        const city = locData.city || 'Bengaluru'
        const lat = locData.latitude || 12.97
        const lon = locData.longitude || 77.59
        setLocation(city)
        setCoords({ lat, lon })

        const weatherRes = await fetch(
          `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true`
        )
        const weatherData = await weatherRes.json()
        const wmoCodes = {
          0: 'Clear sky', 1: 'Mainly clear', 2: 'Partly cloudy', 3: 'Overcast',
          45: 'Fog', 48: 'Rime fog', 51: 'Light drizzle', 53: 'Drizzle',
          61: 'Slight rain', 63: 'Moderate rain', 65: 'Heavy rain',
          71: 'Light snow', 80: 'Rain showers', 95: 'Thunderstorm',
        }
        const cw = weatherData.current_weather
        setWeather({
          condition: wmoCodes[cw.weathercode] || 'Clear',
          temp: `${cw.temperature}°C`,
          windspeed: `${cw.windspeed} km/h`,
        })
      } catch (err) {
        console.error('Env fetch failed:', err)
        setLocation('Bengaluru')
        setWeather({ condition: 'Sunny', temp: '28°C' })
      }
    }
    fetchEnv()
  }, [])

  const handlePredict = async () => {
    setIsThinking(true)
    setError(null)
    setResult(null)

    try {
      const res = await fetch('/api/predict', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          heart_rate: heartRate,
          mood,
          weather: `${weather.condition}, ${weather.temp}`,
          location,
          latitude: coords.lat,
          longitude: coords.lon,
        }),
      })

      const data = await res.json()
      if (!res.ok) throw new Error(data.detail || data.error || 'API Error')
      setResult(data)
    } catch (err) {
      setError(err.message)
    } finally {
      setIsThinking(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-emerald-950 text-white">
      {/* Agentic Orb */}
      <AnimatePresence>
        {isThinking && <AgenticOrb />}
      </AnimatePresence>

      {/* Header */}
      <header className="px-6 py-4 flex items-center justify-between border-b border-white/10">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-emerald-400 to-cyan-400 bg-clip-text text-transparent"
            aria-label="NourishIQ Application Title">
          NourishIQ
        </h1>
        <span className="text-xs text-slate-400">Powered by Gemini &bull; Vertex AI</span>
      </header>

      {/* Main Bento Grid */}
      <main className="max-w-7xl mx-auto p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {/* Weather Sync — Top Left */}
          <WeatherSync location={location} weather={weather} />

          {/* Bio State — Top Center */}
          <BioState
            heartRate={heartRate}
            setHeartRate={setHeartRate}
            mood={mood}
            setMood={setMood}
          />

          {/* Life Flow — Top Right */}
          <LifeFlow events={result?._meta?.all_events} />

          {/* Recommendation Card — Full width bottom */}
          <div className="lg:col-span-2">
            <RecommendationCard result={result} error={error} />
          </div>

          {/* Shopping List */}
          <ShoppingList items={result?.keep_shopping_list} />
        </div>

        {/* FAB */}
        <button
          onClick={handlePredict}
          disabled={isThinking}
          aria-label="Generate AI meal prediction"
          className="fixed bottom-8 right-8 bg-emerald-500 hover:bg-emerald-400 disabled:bg-slate-600
                     text-white font-bold px-8 py-4 rounded-full shadow-2xl shadow-emerald-500/30
                     transition-all duration-300 hover:scale-105 active:scale-95 disabled:cursor-not-allowed
                     flex items-center gap-3 text-lg z-50"
        >
          <span className="text-2xl">✨</span>
          {isThinking ? 'Deep Thinking...' : 'Generate Nudge'}
        </button>
      </main>
    </div>
  )
}

export default App
