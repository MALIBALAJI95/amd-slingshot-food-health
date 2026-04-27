import { motion } from 'framer-motion'

export default function BioState({ heartRate, setHeartRate, mood, setMood }) {
  const moods = ['Energetic', 'Stressed', 'Fatigued', 'Calm', 'Anxious']

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.2 }}
      whileHover={{ scale: 1.02, rotateX: 2, rotateY: 2 }}
      className="glass rounded-2xl p-5"
      role="region"
      aria-label="Biometric state inputs"
    >
      <h2 className="text-sm font-semibold text-emerald-400 uppercase tracking-wider mb-4">
        Bio-State
      </h2>

      {/* Heart Rate */}
      <div className="mb-5">
        <div className="flex justify-between items-center mb-2">
          <label htmlFor="heartRate" className="text-sm text-slate-300">Heart Rate</label>
          <span className="text-2xl font-bold text-rose-400" aria-live="polite">
            {heartRate} <span className="text-sm font-normal text-slate-400">bpm</span>
          </span>
        </div>
        <input
          id="heartRate"
          type="range"
          min="40"
          max="180"
          value={heartRate}
          onChange={(e) => setHeartRate(Number(e.target.value))}
          className="w-full h-2 bg-slate-700 rounded-lg appearance-none cursor-pointer
                     accent-rose-400"
          aria-label={`Heart rate slider: ${heartRate} bpm`}
        />
        <div className="flex justify-between text-xs text-slate-500 mt-1">
          <span>40</span><span>110</span><span>180</span>
        </div>
      </div>

      {/* Mood */}
      <div>
        <label className="text-sm text-slate-300 block mb-2">Current Mood</label>
        <div className="flex flex-wrap gap-2">
          {moods.map((m) => (
            <button
              key={m}
              onClick={() => setMood(m)}
              aria-pressed={mood === m}
              aria-label={`Select mood: ${m}`}
              className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200
                ${mood === m
                  ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/30'
                  : 'bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white'
                }`}
            >
              {m}
            </button>
          ))}
        </div>
      </div>
    </motion.div>
  )
}
