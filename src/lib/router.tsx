export interface AppRoute {
  path: string
  label: string
  requiresAuth?: boolean
}

/**
 * Definizione centralizzata delle route dell'app, usata sia dal router
 * che dalla navigazione (Navbar) per restare sempre allineati.
 */
export const routes: AppRoute[] = [
  { path: '/', label: 'Home' },
  { path: '/dashboard', label: 'Dashboard', requiresAuth: true },
]
