import { ArrowRight, ClipboardList, KeyRound, Plus } from 'lucide-react'

const actions = [
  {
    icon: Plus,
    title: 'Crea nuova asta',
    description: 'Crea e gestisci una nuova asta',
    accent: true,
  },
  {
    icon: KeyRound,
    title: 'Partecipa a un\'asta',
    description: 'Inserisci il codice invito',
    accent: false,
  },
  {
    icon: ClipboardList,
    title: 'Le mie strategie',
    description: 'Visualizza e gestisci le tue strategie',
    accent: false,
  },
]

export function QuickActions() {
  return (
    <div className="space-y-2">
      {actions.map(({ accent, description, icon: Icon, title }) => (
        <button
          key={title}
          type="button"
          disabled
          title="Funzione in arrivo"
          className={
            accent
              ? 'group flex w-full items-center gap-3 rounded-md border border-emerald-400/30 bg-emerald-500/15 p-3 text-left transition-all duration-200'
              : 'group flex w-full items-center gap-3 rounded-md border border-white/8 bg-white/[0.025] p-3 text-left transition-all duration-200'
          }
        >
          <span className={accent ? 'action-icon action-icon-accent' : 'action-icon'}>
            <Icon className="size-[18px]" aria-hidden="true" />
          </span>
          <span className="min-w-0 flex-1">
            <span className="block text-sm font-semibold text-slate-100">{title}</span>
            <span className="mt-0.5 block text-xs text-slate-400">{description}</span>
          </span>
          <ArrowRight className="size-4 shrink-0 text-slate-500" aria-hidden="true" />
        </button>
      ))}
    </div>
  )
}