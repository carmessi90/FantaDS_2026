import {
  Activity,
  CalendarClock,
  ClipboardList,
  ShieldCheck,
  Target,
} from 'lucide-react'
import type { LucideIcon } from 'lucide-react'

export interface DashboardStatData {
  icon: LucideIcon
  value: string
  label: string
}

export const dashboardStats: DashboardStatData[] = [
  { icon: Activity, value: '2', label: 'Aste attive' },
  { icon: ShieldCheck, value: '6/8', label: 'Partecipanti' },
  { icon: Target, value: '500', label: 'Credito iniziale' },
  { icon: CalendarClock, value: '2025/26', label: 'Stagione' },
  { icon: ClipboardList, value: '3', label: 'Strategie salvate' },
]

export const recentActivities = [
  ['Hai creato l\'asta "Asta Juventus 2025/26"', '2 ore fa'],
  ['Un partecipante si e unito all\'asta', '5 ore fa'],
  ['Strategia "Equilibrata" aggiornata', '1 giorno fa'],
  ['Nuova offerta registrata', '1 giorno fa'],
] as const

export const upcomingAuctions = [
  ['Asta Inter Club', '01/09/2026', '21:00'],
  ['Asta Primavera', '04/09/2026', '20:30'],
] as const