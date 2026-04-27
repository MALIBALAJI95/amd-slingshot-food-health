import { motion } from 'framer-motion'

export default function ShoppingList({ items }) {
  if (!items || items.length === 0) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        whileHover={{ scale: 1.02 }}
        className="glass rounded-2xl p-5"
        role="region"
        aria-label="Google Keep shopping list"
      >
        <h2 className="text-sm font-semibold text-emerald-400 uppercase tracking-wider mb-3">
          🛒 Smart Shopping List
        </h2>
        <p className="text-sm text-slate-500 text-center py-4">
          Generate a nudge to see your auto-generated ingredient list.
        </p>
      </motion.div>
    )
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.5 }}
      whileHover={{ scale: 1.02 }}
      className="glass rounded-2xl p-5"
      role="region"
      aria-label="Google Keep shopping list with missing ingredients"
    >
      <h2 className="text-sm font-semibold text-emerald-400 uppercase tracking-wider mb-3">
        🛒 Smart Shopping List
      </h2>
      <p className="text-xs text-slate-500 mb-3">Auto-generated for Google Keep</p>

      <ul className="space-y-2">
        {items.map((item, i) => (
          <motion.li
            key={i}
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1 * i }}
            className="flex items-center gap-3 p-2 rounded-lg bg-white/3 hover:bg-white/5 transition-colors"
          >
            <div className="w-5 h-5 rounded border-2 border-emerald-500/40 flex items-center justify-center shrink-0">
              <span className="text-emerald-400 text-xs">✓</span>
            </div>
            <span className="text-sm text-slate-300 flex-1">{item.item}</span>
            <span className="text-xs text-slate-500">{item.quantity}</span>
          </motion.li>
        ))}
      </ul>
    </motion.div>
  )
}
