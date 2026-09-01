import type { LucideIcon } from 'lucide-react'

interface DashboardStatProps {
  icon: LucideIcon
  value: string
  label: string
}

export function DashboardStat({ icon: Icon, value, label }: DashboardStatProps) {
  return (
    <div className="manager-panel flex min-w-0 items-center gap-3 px-4 py-4">
      <div className="flex size-9 shrink-0 items-center justify-center rounded-md bg-emerald-500/10 text-emerald-300">
        <Icon className="size-[18px]" aria-hidden="true" />
      </div>
      <div className="min-w-0">
        <p className="truncate text-xl font-bold text-white">{value}</p>
        <p className="truncate text-xs text-slate-400">{label}</p>
      </div>
    </div>
  )
}