import { ArrowRight } from 'lucide-react'
import { ActivityItem } from './ActivityItem'
import { recentActivities } from './dashboardMockData'

export function RecentActivity() {
  return (
    <div className="manager-panel p-5">
      <p className="manager-eyebrow">ATTIVITA RECENTE</p>
      <ul className="mt-5">
        {recentActivities.map(([description, time]) => (
          <ActivityItem key={description} description={description} time={time} />
        ))}
      </ul>
      <button type="button" disabled title="Storico completo in arrivo" className="manager-text-action mt-5">
        Vedi tutte le attivita
        <ArrowRight className="size-4" aria-hidden="true" />
      </button>
    </div>
  )
}