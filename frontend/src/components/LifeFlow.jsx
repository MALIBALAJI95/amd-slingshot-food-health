import { motion } from 'framer-motion'

const defaultEvents = [
  { title: 'Sprint Standup', start_time: '09:00', end_time: '09:30' },
  { title: 'Design Review', start_time: '09:30', end_time: '10:15' },
  { title: 'Project Pitch', start_time: '10:30', end_time: '11:30', location: 'Google Office' },
  { title: 'Team Lunch', start_time: '12:30', end_time: '13:30', location: 'Marriott' },
  { title: 'Deep Work Block', start_time: '14:00', end_time: '16:00' },
  { title: '1-on-1 Manager', start_time: '16:00', end_time: '16:30' },
]

function getCurrentHour() {
  return new Date().getHours()
}

export default function LifeFlow({ events }) {
  const schedule = events || defaultEvents
  const currentHour = getCurrentHour()

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.3 }}
      whileHover={{ scale: 1.02, rotateX: -2, rotateY: 2 }}
      className="glass rounded-2xl p-5"
      role="region"
      aria-label="Schedule and calendar timeline"
    >
      <h2 className="text-sm font-semibold text-emerald-400 uppercase tracking-wider mb-3">
        Life Flow &middot; Calendar
      </h2>

      <div className="space-y-2 max-h-52 overflow-y-auto pr-1">
        {schedule.map((event, i) => {
          const eventHour = parseInt(event.start_time.split(':')[0])
          const isCurrent = eventHour <= currentHour && currentHour < parseInt(event.end_time.split(':')[0])
          const isPast = parseInt(event.end_time.split(':')[0]) <= currentHour

          return (
            <motion.div
              key={i}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 * i }}
              className={`flex items-center gap-3 p-2.5 rounded-xl transition-all text-sm
                ${isCurrent
                  ? 'bg-emerald-500/20 border border-emerald-500/30'
                  : isPast
                    ? 'opacity-40'
                    : 'bg-white/3 hover:bg-white/5'
                }`}
              aria-label={`${event.title} from ${event.start_time} to ${event.end_time}`}
            >
              {/* Timeline dot */}
              <div className={`w-2.5 h-2.5 rounded-full shrink-0
                ${isCurrent ? 'bg-emerald-400 shadow-lg shadow-emerald-400/50' : isPast ? 'bg-slate-600' : 'bg-slate-500'}`}
              />

              <div className="flex-1 min-w-0">
                <p className={`font-medium truncate ${isCurrent ? 'text-emerald-300' : 'text-slate-300'}`}>
                  {event.title}
                </p>
                {event.location && (
                  <p className="text-xs text-slate-500 truncate">📍 {event.location}</p>
                )}
              </div>

              <span className={`text-xs shrink-0 ${isCurrent ? 'text-emerald-400' : 'text-slate-500'}`}>
                {event.start_time}
              </span>
            </motion.div>
          )
        })}
      </div>
    </motion.div>
  )
}
