import { Award } from 'lucide-react'
import type { Profile } from '@/contexts/auth'

export function ProfileCard({ profile }: { profile: Profile | null }) {
  const name = getManagerName(profile)

  return (
    <div className="manager-panel h-full p-5">
      <p className="manager-eyebrow">IL TUO PROFILO</p>
      <div className="mt-6 flex items-center gap-3">
        <div className="flex size-14 items-center justify-center overflow-hidden rounded-full border border-emerald-400/35 bg-emerald-500/15 text-lg font-bold text-emerald-200">
          {profile?.avatar_url ? (
            <img src={profile.avatar_url} alt="Avatar manager" className="size-full object-cover" />
          ) : (
            name.charAt(0).toUpperCase()
          )}
        </div>
        <div className="min-w-0">
          <p className="truncate font-bold text-white">{name}</p>
          <p className="mt-0.5 text-sm text-emerald-400">Allenatore</p>
        </div>
      </div>
      <div className="mt-8 border-t border-white/8 pt-5">
        <div className="flex items-center justify-between">
          <span className="flex items-center gap-2 text-sm text-slate-300">
            <Award className="size-4 text-emerald-400" aria-hidden="true" />
            Livello Manager
          </span>
          <span className="text-sm font-bold text-white">Liv. 12</span>
        </div>
        <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-white/10">
          <div className="h-full w-[62.5%] rounded-full bg-emerald-400" />
        </div>
        <p className="mt-2 text-xs text-slate-500">1250 / 2000 XP</p>
      </div>
    </div>
  )
}

function getManagerName(profile: Profile | null) {
  if (profile?.full_name) return profile.full_name
  if (profile?.username && !profile.username.startsWith('u_')) return profile.username
  return 'Manager'
}