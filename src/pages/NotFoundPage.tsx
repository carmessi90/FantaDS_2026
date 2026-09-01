import { Link } from 'react-router-dom'
import { Container } from '@/components/ui'

export function NotFoundPage() {
  return (
    <Container className="flex flex-col items-center gap-4 py-24 text-center">
      <h1 className="text-4xl font-bold text-slate-900">404</h1>
      <p className="text-sm text-slate-600">Pagina non trovata.</p>
      <Link
        to="/"
        className="inline-flex h-10 items-center justify-center rounded-md bg-emerald-600 px-4 text-sm font-medium text-white transition-colors hover:bg-emerald-700"
      >
        Torna alla home
      </Link>
    </Container>
  )
}
