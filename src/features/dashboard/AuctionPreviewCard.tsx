import { ArrowUpRight, UsersRound } from 'lucide-react'
import { AuctionStatusBadge } from '@/features/auctions/AuctionStatusBadge'
import type { AuctionSummary } from '@/types/auction'

const roleLabels = {
  owner: 'Organizzatore',
  admin: 'Admin',
  member: 'Partecipante',
} as const

export function AuctionPreviewCard({ auction }: { auction: AuctionSummary }) {
  return (
    <article className="group border-b border-white/8 py-4 first:pt-0 last:border-0 last:pb-0">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="truncate font-semibold text-slate-100">{auction.name}</p>
          <p className="mt-1 text-sm text-slate-400">{auction.seasonLabel ?? 'Stagione non indicata'}</p>
        </div>
        <AuctionStatusBadge status={auction.status} />
      </div>
      <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-sm">
        <span className="flex items-center gap-1.5 text-slate-400">
          <UsersRound className="size-4 text-emerald-400" aria-hidden="true" />
          {auction.participantCount} partecipanti
        </span>
        <span className="font-medium text-slate-300">{roleLabels[auction.accessRole]}</span>
        <button type="button" disabled title="Sala asta in arrivo" className="manager-inline-action">
          Apri sala
          <ArrowUpRight className="size-4" aria-hidden="true" />
        </button>
      </div>
    </article>
  )
}