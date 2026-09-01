import { useState } from 'react'
import { NavLink } from 'react-router-dom'
import { Button } from '@/components/ui'
import { useAuth } from '@/hooks/useAuth'
import { cn } from '@/lib/cn'
import { routes } from '@/lib/router'

const navLinkClass = ({ isActive }: { isActive: boolean }) =>
  cn(
    'rounded-md px-3 py-2 text-sm font-medium transition-colors',
    isActive
      ? 'bg-emerald-600 text-white'
      : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900',
  )

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false)
  const { loading, signOut, user } = useAuth()
  const visibleRoutes = routes.filter((route) => !route.requiresAuth || user)

  async function handleSignOut() {
    await signOut()
    setIsOpen(false)
  }

  return (
    <nav className="relative">
      <button
        type="button"
        className="inline-flex items-center justify-center rounded-md p-2 text-slate-600 hover:bg-slate-100 sm:hidden"
        aria-label="Apri menu"
        aria-expanded={isOpen}
        onClick={() => setIsOpen((prev) => !prev)}
      >
        <span className="sr-only">Menu</span>
        <svg
          className="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          aria-hidden="true"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d={isOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'}
          />
        </svg>
      </button>

      <ul className="hidden items-center gap-1 sm:flex">
        {visibleRoutes.map((route) => (
          <li key={route.path}>
            <NavLink to={route.path} end={route.path === '/'} className={navLinkClass}>
              {route.label}
            </NavLink>
          </li>
        ))}
        {!loading &&
          (user ? (
            <li>
              <Button variant="ghost" size="sm" onClick={handleSignOut}>
                Esci
              </Button>
            </li>
          ) : (
            <li>
              <NavLink to="/login" className={navLinkClass}>
                Accedi
              </NavLink>
            </li>
          ))}
      </ul>

      {isOpen && (
        <ul className="absolute right-0 top-full mt-2 flex w-48 flex-col gap-1 rounded-md border border-slate-200 bg-white p-2 shadow-md sm:hidden">
          {visibleRoutes.map((route) => (
            <li key={route.path}>
              <NavLink
                to={route.path}
                end={route.path === '/'}
                className={navLinkClass}
                onClick={() => setIsOpen(false)}
              >
                {route.label}
              </NavLink>
            </li>
          ))}
          {!loading &&
            (user ? (
              <li>
                <Button
                  className="w-full justify-start"
                  variant="ghost"
                  size="sm"
                  onClick={handleSignOut}
                >
                  Esci
                </Button>
              </li>
            ) : (
              <li>
                <NavLink to="/login" className={navLinkClass} onClick={() => setIsOpen(false)}>
                  Accedi
                </NavLink>
              </li>
            ))}
        </ul>
      )}
    </nav>
  )
}
