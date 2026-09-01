import { supabase } from '@/lib/supabase'
import type {
  AuctionAccessRole,
  AuctionRoomStatus,
  AuctionSummary,
} from '@/types/auction'

interface RoomRecord {
  id: string
  name: string
  status: AuctionRoomStatus
  created_at: string
  seasons: { label: string } | null
  auction_participants: { count: number }[]
}

interface ParticipantRecord {
  role: AuctionAccessRole
  auction_rooms: RoomRecord | null
}

export async function getAccessibleAuctions(userId: string): Promise<AuctionSummary[]> {
  const [ownedResult, participantResult] = await Promise.all([
    supabase
      .from('auction_rooms')
      .select('id, name, status, created_at, seasons(label), auction_participants(count)')
      .eq('owner_id', userId)
      .order('created_at', { ascending: false }),
    supabase
      .from('auction_participants')
      .select('role, auction_rooms(id, name, status, created_at, seasons(label), auction_participants(count))')
      .eq('user_id', userId)
      .eq('status', 'joined'),
  ])

  if (ownedResult.error) throw ownedResult.error
  if (participantResult.error) throw participantResult.error

  const auctions = new Map<string, AuctionSummary>()
  const ownedRooms = (ownedResult.data ?? []) as unknown as RoomRecord[]
  const participantRows = (participantResult.data ?? []) as unknown as ParticipantRecord[]

  for (const room of ownedRooms) {
    auctions.set(room.id, toAuctionSummary(room, 'owner'))
  }

  for (const participant of participantRows) {
    if (participant.auction_rooms && !auctions.has(participant.auction_rooms.id)) {
      auctions.set(
        participant.auction_rooms.id,
        toAuctionSummary(participant.auction_rooms, participant.role),
      )
    }
  }

  return [...auctions.values()].sort(
    (firstAuction, secondAuction) =>
      Date.parse(secondAuction.createdAt) - Date.parse(firstAuction.createdAt),
  )
}

function toAuctionSummary(
  room: RoomRecord,
  accessRole: AuctionAccessRole,
): AuctionSummary {
  return {
    id: room.id,
    name: room.name,
    status: room.status,
    createdAt: room.created_at,
    seasonLabel: room.seasons?.label ?? null,
    participantCount: room.auction_participants[0]?.count ?? 0,
    accessRole,
  }
}