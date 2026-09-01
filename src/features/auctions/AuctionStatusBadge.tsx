import { cn } from '@/lib/cn'
import type { AuctionRoomStatus } from '@/types/auction'

const statusLabels: Record<AuctionRoomStatus, string> = {
  draft: 'Bozza',
  active: 'Attiva',
  paused: 'In pausa',
  completed: 'Completata',
  cancelled: 'Annullata',
}

const statusClasses: Record<AuctionRoomStatus, string> = {
  draft: 'border-slate-400/20 bg-slate-400/10 text-slate-300',
  active: 'border-emerald-400/25 bg-emerald-400/10 text-emerald-300',
  paused: 'border-amber-400/25 bg-amber-400/10 text-amber-300',
  completed: 'border-sky-400/25 bg-sky-400/10 text-sky-300',
  cancelled: 'border-red-400/25 bg-red-400/10 text-red-300',
}

export function AuctionStatusBadge({ status }: { status: AuctionRoomStatus }) {
  return (
    <span
      className={cn(
        'inline-flex h-6 items-center rounded-md border px-2 text-xs font-semibold',
        statusClasses[status],
      )}
    >
      {statusLabels[status]}
    </span>
  )
}