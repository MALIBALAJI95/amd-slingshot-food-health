import { motion } from 'framer-motion'

export default function AgenticOrb() {
  return (
    <motion.div
      initial={{ opacity: 0, y: -30 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -30 }}
      className="fixed top-5 left-1/2 -translate-x-1/2 z-[100]"
      aria-live="polite"
      aria-label="AI agent is thinking"
    >
      <div className="flex items-center gap-3 px-6 py-3 rounded-full bg-black/80 border border-cyan-400/30 shadow-[0_0_30px_rgba(0,255,204,0.4)]">
        {/* Pulsing multi-layer orb */}
        <div className="relative w-5 h-5">
          <motion.div
            animate={{ scale: [1, 1.6, 1], opacity: [0.6, 0, 0.6] }}
            transition={{ duration: 1.5, repeat: Infinity }}
            className="absolute inset-0 rounded-full bg-cyan-400"
          />
          <motion.div
            animate={{ scale: [1, 1.3, 1], opacity: [0.8, 0.3, 0.8] }}
            transition={{ duration: 1, repeat: Infinity }}
            className="absolute inset-0 rounded-full bg-emerald-400"
          />
          <div className="absolute inset-1 rounded-full bg-white" />
        </div>
        <span className="text-white font-semibold text-sm tracking-wide">
          Gemini Deep Think…
        </span>
      </div>
    </motion.div>
  )
}
