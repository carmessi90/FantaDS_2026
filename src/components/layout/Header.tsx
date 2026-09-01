import { Container } from '@/components/ui'
import { Navbar } from './Navbar'

export function Header() {
  return (
    <header className="sticky top-0 z-40 border-b border-slate-200 bg-white/80 backdrop-blur">
      <Container className="flex h-16 items-center justify-between">
        <span className="text-lg font-bold text-slate-900">FantaDS</span>
        <Navbar />
      </Container>
    </header>
  )
}
