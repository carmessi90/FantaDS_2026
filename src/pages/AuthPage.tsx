import { type FormEvent, useState } from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { Button, Card, CardContent, CardHeader, CardTitle, Container } from '@/components/ui'
import { useAuth } from '@/hooks/useAuth'

type AuthMode = 'sign-in' | 'sign-up'

export function AuthPage() {
  const { loading, signIn, signUp, user } = useAuth()
  const location = useLocation()
  const [mode, setMode] = useState<AuthMode>('sign-in')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const destination =
    (location.state as { from?: { pathname?: string } } | null)?.from?.pathname ??
    '/dashboard'

  if (!loading && user) {
    return <Navigate to={destination} replace />
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setSubmitting(true)
    setMessage(null)

    const error =
      mode === 'sign-in' ? await signIn(email, password) : await signUp(email, password)

    setMessage(
      error
        ? error.message
        : mode === 'sign-up'
          ? 'Registrazione completata. Controlla la tua email per confermare l’account.'
          : null,
    )
    setSubmitting(false)
  }

  return (
    <Container className="flex min-h-[calc(100vh-4rem)] items-center justify-center py-8">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>{mode === 'sign-in' ? 'Accedi' : 'Crea un account'}</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={handleSubmit}>
            <label className="block text-sm font-medium text-slate-700">
              Email
              <input
                className="mt-1 h-10 w-full rounded-md border border-slate-300 px-3 text-slate-900 outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100"
                type="email"
                autoComplete="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
              />
            </label>
            <label className="block text-sm font-medium text-slate-700">
              Password
              <input
                className="mt-1 h-10 w-full rounded-md border border-slate-300 px-3 text-slate-900 outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100"
                type="password"
                autoComplete={mode === 'sign-in' ? 'current-password' : 'new-password'}
                minLength={6}
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                required
              />
            </label>
            {message && <p className="text-sm text-slate-600">{message}</p>}
            <Button className="w-full" type="submit" disabled={submitting || loading}>
              {submitting
                ? 'Attendere...'
                : mode === 'sign-in'
                  ? 'Accedi'
                  : 'Registrati'}
            </Button>
          </form>
          <button
            type="button"
            className="mt-4 text-sm font-medium text-emerald-700 hover:text-emerald-800"
            onClick={() => {
              setMode((currentMode) =>
                currentMode === 'sign-in' ? 'sign-up' : 'sign-in',
              )
              setMessage(null)
            }}
          >
            {mode === 'sign-in'
              ? 'Non hai un account? Registrati'
              : 'Hai già un account? Accedi'}
          </button>
        </CardContent>
      </Card>
    </Container>
  )
}