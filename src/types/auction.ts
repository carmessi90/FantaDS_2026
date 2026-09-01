export type AuctionRoomStatus =
  | 'draft'
  | 'active'
  | 'paused'
  | 'completed'
  | 'cancelled'

export type AuctionAccessRole = 'owner' | 'admin' | 'member'

export interface AuctionSummary {
  id: string
  name: string
  status: AuctionRoomStatus
  createdAt: string
  seasonLabel: string | null
  participantCount: number
  accessRole: AuctionAccessRole
}

export interface AuctionRoomDetail {
  id: string
  name: string
  status: AuctionRoomStatus
  seasonId: string
  seasonLabel: string | null
  totalBudget: number
  timerSeconds: number | null
  accessRole: AuctionAccessRole
  myTeamId: string | null
}

export interface AuctionTeam {
  id: string
  participantId: string
  name: string
  budgetTotal: number
  budgetSpent: number
  budgetAvailable: number
  role: AuctionAccessRole
  isCurrentUser: boolean
  rosterCount: number
}

export interface AuctionPlayer {
  id: string
  playerSeasonId: string
  name: string
  clubName: string
  roleFantasy: 'P' | 'D' | 'C' | 'A'
  seasonLabel: string | null
}

export interface AuctionCall {
  id: string
  status: 'open' | 'closed' | 'assigned' | 'cancelled'
  currentPrice: number
  timerEndsAt: string | null
  player: AuctionPlayer
  leadingTeamId: string | null
}

export interface AuctionBid {
  id: string
  teamId: string
  amount: number
  createdAt: string
}

export interface AuctionRosterEntry {
  id: string
  role: 'P' | 'D' | 'C' | 'A'
  pricePaid: number
  acquiredAt: string
  player: AuctionPlayer
}

export interface AuctionEvent {
  id: string
  eventType: string
  payload: Record<string, unknown>
  createdAt: string
}

export interface AuctionRoomData {
  room: AuctionRoomDetail
  teams: AuctionTeam[]
  currentCall: AuctionCall | null
  rosters: AuctionRosterEntry[]
  events: AuctionEvent[]
}