import { Clock3 } from 'lucide-react'

export function ActivityItem({ description, time }: { description: string; time: string }) {
  return (
    <li className="flex gap-3 border-b border-white/8 py-3 first:pt-0 last:border-0 last:pb-0">
      <span className="mt-1.5 size-2 shrink-0 rounded-full bg-emerald-400 shadow-[0_0_10px_rgba(34,197,94,0.7)]" />
      <div className="min-w-0">
        <p className="text-sm leading-5 text-slate-300">{description}</p>
        <p className="mt-1 flex items-center gap-1 text-xs text-slate-500">
          <Clock3 className="size-3" aria-hidden="true" />
          {time}
        </p>
      </div>
    </li>
  )
}