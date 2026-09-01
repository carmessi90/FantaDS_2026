import { useEffect, useState } from 'react'
import { Button, Container } from '@/components/ui'
import { AuctionPreviewCard } from '@/features/dashboard/AuctionPreviewCard'
import { DashboardHero } from '@/features/dashboard/DashboardHero'
import { DashboardStat } from '@/features/dashboard/DashboardStat'
import { FormationPreview } from '@/features/dashboard/FormationPreview'
import { ProfileCard } from '@/features/dashboard/ProfileCard'
import { QuickActions } from '@/features/dashboard/QuickActions'
import { RecentActivity } from '@/features/dashboard/RecentActivity'
import { UpcomingAuctions } from '@/features/dashboard/UpcomingAuctions'
import { dashboardStats } from '@/features/dashboard/dashboardMockData'
import { useAuth } from '@/hooks/useAuth'
import { getAccessibleAuctions } from '@/services/auctions'
import type { AuctionSummary } from '@/types/auction'

export function DashboardView() {
  const { profile, user } = useAuth()
  const [auctions, setAuctions] = useState<AuctionSummary[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const displayName = getDisplayName(profile?.username, profile?.full_name, user?.email)

  useEffect(() => {
    if (!user) return

    const userId = user.id
    let isCurrent = true

    async function loadAuctions() {
      setIsLoading(true)
      const result = await getAccessibleAuctions(userId).then(
        (data) => ({ data, error: null }),
        () => ({ data: [], error: 'Impossibile caricare le tue aste.' }),
      )

      if (!isCurrent) return

      setAuctions(result.data)
      setError(result.error)
      setIsLoading(false)
    }

    void loadAuctions()

    return () => {
      isCurrent = false
    }
  }, [user])

  return (
    <Container className="space-y-6 py-6 sm:space-y-8 sm:py-8">
      <DashboardHero managerName={displayName ?? 'Manager'} />

      <section className="grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-5">
        {dashboardStats.map((stat) => (
          <DashboardStat key={stat.label} {...stat} />
        ))}
      </section>

      <section className="grid gap-5 xl:grid-cols-[minmax(0,1.3fr)_minmax(18rem,0.7fr)_minmax(16rem,0.55fr)]">
        <div className="manager-panel p-5 xl:row-span-2">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="manager-eyebrow">LE MIE ASTE</p>
              <p className="mt-2 text-sm text-slate-400">Aste create da te o a cui partecipi.</p>
            </div>
            <button type="button" disabled title="Archivio aste in arrivo" className="manager-text-action shrink-0">Vedi tutte</button>
          </div>
          <div className="mt-6">
            {isLoading && <p className="text-sm text-slate-400">Caricamento aste...</p>}
            {error && <p className="text-sm text-red-300">{error}</p>}
            {!isLoading && !error && auctions.length === 0 && (
              <div className="rounded-md border border-dashed border-white/15 p-5">
                <p className="text-sm text-slate-300">Non partecipi ancora a nessuna asta.</p>
                <Button className="mt-4" disabled>Crea la tua prima asta</Button>
              </div>
            )}
            {!isLoading && !error && auctions.map((auction) => (
              <AuctionPreviewCard key={auction.id} auction={auction} />
            ))}
          </div>
        </div>
        <div className="manager-panel p-5">
          <p className="manager-eyebrow">AZIONI RAPIDE</p>
          <div className="mt-5"><QuickActions /></div>
        </div>
        <ProfileCard profile={profile} />
        <FormationPreview />
        <RecentActivity />
        <UpcomingAuctions />
      </section>
    </Container>
  )
}

function getDisplayName(
  username: string | null | undefined,
  fullName: string | null | undefined,
  email: string | undefined,
) {
  if (username && !username.startsWith('u_')) return username
  if (fullName) return fullName
  if (email) return email.split('@')[0]
  return 'benvenuto'
}