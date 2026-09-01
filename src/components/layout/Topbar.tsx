import { Bell, ChevronDown, Menu, Search } from 'lucide-react'
import { useAuth } from '@/hooks/useAuth'

export function Topbar({ onOpenSidebar }: { onOpenSidebar: () => void }) {
  const { profile } = useAuth()
  const displayName = getDisplayName(profile?.full_name, profile?.username)
  const initial = displayName.charAt(0).toUpperCase()

  return (
    <header className="sticky top-0 z-30 flex h-16 shrink-0 items-center justify-between border-b border-white/8 bg-[#091522]/85 px-4 backdrop-blur-xl sm:px-6 lg:px-8">
      <button
        type="button"
        aria-label="Apri menu"
        className="rounded-md p-2 text-slate-300 transition-colors hover:bg-white/5 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400 lg:hidden"
        onClick={onOpenSidebar}
      >
        <Menu className="size-5" aria-hidden="true" />
      </button>
      <div className="hidden text-sm text-slate-500 sm:block">Centro di comando</div>
      <div className="ml-auto flex items-center gap-1.5 sm:gap-3">
        <button type="button" aria-label="Cerca" className="topbar-icon-button">
          <Search className="size-[18px]" aria-hidden="true" />
        </button>
        <button type="button" aria-label="Notifiche" className="topbar-icon-button">
          <Bell className="size-[18px]" aria-hidden="true" />
        </button>
        <div className="ml-1 flex items-center gap-2 border-l border-white/8 pl-3 sm:gap-3">
          <div className="flex size-9 items-center justify-center overflow-hidden rounded-full border border-emerald-400/35 bg-emerald-400/15 text-sm font-bold text-emerald-200">
            {profile?.avatar_url ? (
              <img src={profile.avatar_url} alt="Avatar profilo" className="size-full object-cover" />
            ) : (
              initial
            )}
          </div>
          <div className="hidden text-left sm:block">
            <p className="max-w-32 truncate text-sm font-semibold text-slate-100">{displayName}</p>
            <p className="text-xs text-emerald-400">Allenatore</p>
          </div>
          <ChevronDown className="hidden size-4 text-slate-500 sm:block" aria-hidden="true" />
        </div>
      </div>
    </header>
  )
}

function getDisplayName(fullName: string | null | undefined, username: string | null | undefined) {
  if (fullName) return fullName
  if (username && !username.startsWith('u_')) return username
  return 'Manager'
}