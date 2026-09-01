import { ClipboardList } from 'lucide-react'

const positions = [
  ['50%', '82%'],
  ['18%', '64%'], ['39%', '67%'], ['61%', '67%'], ['82%', '64%'],
  ['20%', '42%'], ['42%', '47%'], ['65%', '47%'], ['82%', '37%'],
  ['35%', '24%'], ['65%', '24%'],
]

export function FormationPreview() {
  return (
    <div className="manager-panel overflow-hidden p-5">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="manager-eyebrow">LA TUA ULTIMA FORMAZIONE SALVATA</p>
          <p className="mt-2 text-sm text-slate-400">Modulo <span className="font-bold text-slate-100">3-4-3</span></p>
        </div>
        <ClipboardList className="size-5 text-emerald-400" aria-hidden="true" />
      </div>
      <div className="pitch-preview relative mt-5 aspect-[1.55] overflow-hidden rounded-md border border-emerald-300/20">
        {positions.map(([left, top], index) => (
          <span
            key={`${left}-${top}`}
            className="absolute flex size-7 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full border border-white/50 bg-[#d8fbe4] text-[9px] font-black text-emerald-950 shadow-md"
            style={{ left, top }}
          >
            {index + 1}
          </span>
        ))}
      </div>
      <button type="button" disabled title="Strategie in arrivo" className="manager-text-action mt-5">
        Vedi strategie
      </button>
    </div>
  )
}