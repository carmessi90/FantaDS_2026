import { CalendarDays, ArrowRight } from 'lucide-react'
import { upcomingAuctions } from './dashboardMockData'

export function UpcomingAuctions() {
  return (
    <div className="manager-panel p-5">
      <p className="manager-eyebrow">PROSSIME ASTE</p>
      <div className="mt-5 space-y-3">
        {upcomingAuctions.map(([name, date, time]) => (
          <div key={name} className="flex items-center gap-3 rounded-md border border-white/8 bg-white/[0.025] p-3">
            <div className="flex size-9 shrink-0 items-center justify-center rounded-md bg-emerald-500/10 text-emerald-300">
              <CalendarDays className="size-[18px]" aria-hidden="true" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-slate-100">{name}</p>
              <p className="text-xs text-slate-500">{date} · {time}</p>
            </div>
            <button type="button" disabled title="Iscrizione in arrivo" className="manager-inline-action">Iscriviti</button>
          </div>
        ))}
      </div>
      <button type="button" disabled title="Calendario aste in arrivo" className="manager-text-action mt-5">
        Vedi calendario aste
        <ArrowRight className="size-4" aria-hidden="true" />
      </button>
    </div>
  )
}