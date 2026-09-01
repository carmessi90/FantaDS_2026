export function DashboardHero({ managerName }: { managerName: string }) {
  return (
    <section className="manager-hero overflow-hidden rounded-lg border border-white/10 px-6 py-10 sm:px-9 sm:py-14">
      <div className="relative z-10 max-w-2xl">
        <p className="text-xs font-bold tracking-[0.2em] text-emerald-300">BENTORNATO</p>
        <h1 className="mt-3 text-4xl font-black tracking-wide text-white sm:text-5xl">
          {managerName}
        </h1>
        <p className="mt-4 max-w-md text-base leading-7 text-slate-300">
          Ogni decisione. Ogni scelta. Ogni vittoria inizia qui.
        </p>
      </div>
    </section>
  )
}