import { Card, CardContent, CardHeader, CardTitle, Container } from '@/components/ui'

export function HomePage() {
  return (
    <Container className="py-8">
      <Card>
        <CardHeader>
          <CardTitle>Benvenuto su FantaDS</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-slate-600">
            Pagina placeholder: qui troveranno spazio listone, strategie e asta.
          </p>
        </CardContent>
      </Card>
    </Container>
  )
}
