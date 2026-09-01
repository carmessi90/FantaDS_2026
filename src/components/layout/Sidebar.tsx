import {
  BarChart3,
  Heart,
  LayoutDashboard,
  Settings,
  ShieldCheck,
  Trophy,
  UsersRound,
  X,
} from 'lucide-react'
import { NavLink } from 'react-router-dom'
import { useState } from 'react'
import { cn } from '@/lib/cn'

interface SidebarProps {
  isOpen: boolean
  onClose: () => void
}

const navigationItems = [
  { label: 'Dashboard', icon: LayoutDashboard, path: '/dashboard' },
  { label: 'Le mie aste', icon: Trophy },
  { label: 'Giocatori', icon: UsersRound },
  { label: 'Strategie', icon: ShieldCheck },
  { label: 'Preferiti', icon: Heart },
  { label: 'Statistiche', icon: BarChart3 },
  { label: 'Impostazioni', icon: Settings },
]

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  const [managerMode, setManagerMode] = useState(true)

  return (
    <>
      {isOpen && (
        <button
          type="button"
          aria-label="Chiudi menu"
          className="fixed inset-0 z-40 bg-slate-950/70 lg:hidden"
          onClick={onClose}
        />
      )}
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-50 flex w-72 -translate-x-full flex-col border-r border-white/8 bg-[#081421] px-4 py-5 transition-transform duration-200 lg:translate-x-0',
          isOpen && 'translate-x-0 shadow-2xl shadow-black/50',
        )}
      >
        <div className="flex items-center justify-between px-2">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-lg border border-emerald-400/35 bg-emerald-500/10 text-emerald-300 shadow-[0_0_24px_rgba(34,197,94,0.16)]">
              <ShieldCheck className="size-5" aria-hidden="true" />
            </div>
            <div>
              <p className="text-lg font-bold tracking-wide text-slate-50">FantaDS</p>
              <p className="text-[10px] font-semibold tracking-[0.18em] text-emerald-400">MANAGER</p>
            </div>
          </div>
          <button
            type="button"
            aria-label="Chiudi menu"
            className="rounded-md p-2 text-slate-400 hover:bg-white/5 hover:text-white lg:hidden"
            onClick={onClose}
          >
            <X className="size-5" aria-hidden="true" />
          </button>
        </div>

        <nav className="mt-10 space-y-1" aria-label="Navigazione manager">
          {navigationItems.map((item) => {
            const Icon = item.icon
            if (!item.path) {
              return (
                <button
                  key={item.label}
                  type="button"
                  disabled
                  title="Sezione in arrivo"
                  className="flex w-full items-center gap-3 rounded-md px-3 py-3 text-left text-sm font-medium text-slate-500"
                >
                  <Icon className="size-[18px]" aria-hidden="true" />
                  {item.label}
                </button>
              )
            }

            return (
              <NavLink
                key={item.label}
                to={item.path}
                onClick={onClose}
                className={({ isActive }) =>
                  cn(
                    'flex items-center gap-3 rounded-md border-l-2 border-transparent px-3 py-3 text-sm font-medium transition-all duration-200',
                    isActive
                      ? 'border-emerald-400 bg-emerald-500/12 text-emerald-100 shadow-[0_0_20px_rgba(34,197,94,0.1)]'
                      : 'text-slate-400 hover:bg-white/5 hover:text-slate-100',
                  )
                }
              >
                <Icon className="size-[18px]" aria-hidden="true" />
                {item.label}
              </NavLink>
            )
          })}
        </nav>

        <div className="mt-auto space-y-4">
          <div className="rounded-lg border border-emerald-400/15 bg-emerald-500/5 p-4">
            <p className="text-sm leading-6 text-slate-300">
              Il talento vince le partite, ma il lavoro di squadra e l&apos;intelligenza vincono i campionati.
            </p>
            <p className="mt-3 text-xs font-medium text-emerald-400">Il tuo taccuino da manager</p>
          </div>
          <div className="flex items-center justify-between px-1">
            <span className="text-sm font-medium text-slate-300">Modalita Manager</span>
            <button
              type="button"
              role="switch"
              aria-checked={managerMode}
              aria-label="Modalita Manager"
              className={cn(
                'relative h-6 w-11 rounded-full transition-colors duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400 focus-visible:ring-offset-2 focus-visible:ring-offset-[#081421]',
                managerMode ? 'bg-emerald-500' : 'bg-slate-700',
              )}
              onClick={() => setManagerMode((isEnabled) => !isEnabled)}
            >
              <span
                className={cn(
                  'absolute top-1 size-4 rounded-full bg-white shadow-sm transition-transform duration-200',
                  managerMode ? 'translate-x-6' : 'translate-x-1',
                )}
              />
            </button>
          </div>
        </div>
      </aside>
    </>
  )
}