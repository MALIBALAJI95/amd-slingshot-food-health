import { motion } from 'framer-motion'
import { useState } from 'react'

function DishCard({ dish, label, colorClass, delay }) {
  const [imgLoaded, setImgLoaded] = useState(false)
  const imgUrl = dish?.image_prompt
    ? `https://image.pollinations.ai/prompt/${encodeURIComponent(
        'professional food photography, ' + dish.image_prompt + ', on ceramic plate, soft lighting, 4k, shallow depth of field'
      )}?width=512&height=384`
    : null

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      className={`rounded-xl overflow-hidden ${colorClass}`}
    >
      {/* Image */}
      {imgUrl && (
        <div className="relative h-48 overflow-hidden bg-slate-800">
          {!imgLoaded && (
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-8 h-8 border-2 border-emerald-400 border-t-transparent rounded-full animate-spin" />
            </div>
          )}
          <img
            src={imgUrl}
            alt={`Photo of ${dish.name}`}
            onLoad={() => setImgLoaded(true)}
            className={`w-full h-full object-cover transition-opacity duration-500 ${imgLoaded ? 'opacity-100' : 'opacity-0'}`}
          />
        </div>
      )}

      <div className="p-4">
        <p className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
          {label}
        </p>
        <h3 className="text-xl font-bold text-white mb-1">{dish?.name || 'N/A'}</h3>
        {dish?.calories && (
          <span className="inline-block px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 text-xs font-medium mb-2">
            {dish.calories} kcal
          </span>
        )}
        <p className="text-sm text-slate-300 leading-relaxed">{dish?.why || ''}</p>
      </div>
    </motion.div>
  )
}

export default function RecommendationCard({ result, error }) {
  if (error) {
    return (
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="glass rounded-2xl p-6"
        role="alert"
      >
        <h2 className="text-sm font-semibold text-red-400 uppercase tracking-wider mb-3">Error</h2>
        <p className="text-red-300">{error}</p>
      </motion.div>
    )
  }

  if (!result) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="glass rounded-2xl p-8 flex flex-col items-center justify-center text-center min-h-[300px]"
      >
        <div className="text-6xl mb-4">🧠</div>
        <h2 className="text-xl font-bold text-slate-300 mb-2">Ready for Deep Think</h2>
        <p className="text-slate-500 max-w-md">
          Click "Generate Nudge" to activate the Gemini agentic engine. It will analyze your
          circadian phase, local weather, biometrics, and calendar schedule to predict the
          optimal meal for you.
        </p>
      </motion.div>
    )
  }

  const rc = result.reasoning_chain || {}

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1 }}
      className="glass rounded-2xl p-6"
      role="region"
      aria-label="AI meal recommendation results"
    >
      <h2 className="text-sm font-semibold text-emerald-400 uppercase tracking-wider mb-4">
        Agentic Recommendation
      </h2>

      {/* Reasoning Chain */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.2 }}
        className="mb-6 p-4 rounded-xl bg-purple-500/10 border border-purple-500/20"
      >
        <h3 className="text-xs font-semibold text-purple-400 uppercase tracking-wider mb-3">
          Agent Reasoning Chain
        </h3>
        <div className="space-y-2 text-sm">
          <div className="flex gap-2">
            <span className="text-purple-400 font-bold shrink-0">1.</span>
            <span className="text-slate-300">{rc.step_1_circadian_analysis || 'N/A'}</span>
          </div>
          <div className="flex gap-2">
            <span className="text-purple-400 font-bold shrink-0">2.</span>
            <span className="text-slate-300">{rc.step_2_weather_impact || 'N/A'}</span>
          </div>
          <div className="flex gap-2">
            <span className="text-purple-400 font-bold shrink-0">3.</span>
            <span className="text-slate-300">{rc.step_3_biomarker_correlation || 'N/A'}</span>
          </div>
          {rc.step_4_schedule_adaptation && (
            <div className="flex gap-2">
              <span className="text-purple-400 font-bold shrink-0">4.</span>
              <span className="text-slate-300">{rc.step_4_schedule_adaptation}</span>
            </div>
          )}
        </div>
      </motion.div>

      {/* Dish Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        <DishCard
          dish={result.south_indian_dish}
          label="Local South Indian"
          colorClass="bg-amber-500/5 border border-amber-500/10"
          delay={0.3}
        />
        <DishCard
          dish={result.global_dish}
          label="Global Alternative"
          colorClass="bg-blue-500/5 border border-blue-500/10"
          delay={0.4}
        />
      </div>

      {/* Restaurant Suggestion */}
      {result.restaurant_suggestion && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="p-4 rounded-xl bg-cyan-500/10 border border-cyan-500/20 mb-4"
        >
          <h3 className="text-xs font-semibold text-cyan-400 uppercase tracking-wider mb-2">
            🍽️ Restaurant Suggestion
          </h3>
          <p className="text-sm text-slate-300">{result.restaurant_suggestion}</p>
          {result.google_maps_link && (
            <a
              href={result.google_maps_link}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block mt-2 text-xs text-cyan-400 hover:text-cyan-300 underline"
              aria-label="Open restaurant in Google Maps"
            >
              Open in Google Maps →
            </a>
          )}
        </motion.div>
      )}

      {/* Overall Rationale */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.6 }}
        className="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/20"
      >
        <h3 className="text-xs font-semibold text-emerald-400 uppercase tracking-wider mb-2">
          Circadian Rationale
        </h3>
        <p className="text-sm text-slate-300 leading-relaxed">{result.overall_rationale}</p>
      </motion.div>
    </motion.div>
  )
}
