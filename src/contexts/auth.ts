import { createContext } from 'react'
import type { Session, User } from '@supabase/supabase-js'

export interface Profile {
  id: string
  username: string
  full_name: string | null
  avatar_url: string | null
}

export interface AuthContextValue {
  session: Session | null
  user: User | null
  profile: Profile | null
  loading: boolean
  signUp: (email: string, password: string) => Promise<Error | null>
  signIn: (email: string, password: string) => Promise<Error | null>
  signOut: () => Promise<Error | null>
  refreshProfile: () => Promise<void>
}

export const AuthContext = createContext<AuthContextValue | null>(null)