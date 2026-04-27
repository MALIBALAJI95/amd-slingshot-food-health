import { motion } from 'framer-motion'

const weatherGradients = {
  'Clear sky': 'from-amber-500/20 to-orange-500/10',
  'Mainly clear': 'from-amber-500/20 to-yellow-500/10',
  'Partly cloudy': 'from-slate-500/20 to-blue-500/10',
  'Overcast': 'from-slate-600/20 to-gray-500/10',
  'Fog': 'from-gray-500/20 to-slate-400/10',
  'Light drizzle': 'from-blue-500/20 to-cyan-500/10',
  'Drizzle': 'from-blue-500/20 to-cyan-500/10',
  'Slight rain': 'from-blue-600/20 to-indigo-500/10',
  'Moderate rain': 'from-blue-700/20 to-indigo-600/10',
  'Heavy rain': 'from-indigo-700/20 to-purple-600/10',
  'Thunderstorm': 'from-purple-700/20 to-red-600/10',
  'Loading...': 'from-slate-500/20 to-slate-400/10',
  'Sunny': 'from-amber-500/20 to-orange-500/10',
}

const weatherIcons = {
  'Clear sky': '☀️', 'Mainly clear': '🌤️', 'Partly cloudy': '⛅',
  'Overcast': '☁️', 'Fog': '🌫️', 'Light drizzle': '🌦️',
  'Drizzle': '🌧️', 'Slight rain': '🌧️', 'Moderate rain': '🌧️',
  'Heavy rain': '⛈️', 'Thunderstorm': '⛈️', 'Loading...': '⏳', 'Sunny': '☀️',
}

export default function WeatherSync({ location, weather }) {
  const gradient = weatherGradients[weather.condition] || weatherGradients['Clear sky']
  const icon = weatherIcons[weather.condition] || '🌍'

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1 }}
      whileHover={{ scale: 1.02, rotateX: 2, rotateY: -2 }}
      className={`glass rounded-2xl p-5 bg-gradient-to-br ${gradient}`}
      role="region"
      aria-label="Weather and location information"
    >
      <h2 className="text-sm font-semibold text-emerald-400 uppercase tracking-wider mb-3">
        Weather Sync
      </h2>
      <div className="flex items-center gap-4">
        <span className="text-5xl" aria-hidden="true">{icon}</span>
        <div>
          <p className="text-2xl font-bold text-white">{weather.temp}</p>
          <p className="text-sm text-slate-300">{weather.condition}</p>
        </div>
      </div>
      <div className="mt-4 flex items-center gap-2 text-slate-400 text-sm">
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span>{location}</span>
        {weather.windspeed && <span className="ml-auto">💨 {weather.windspeed}</span>}
      </div>
    </motion.div>
  )
}
