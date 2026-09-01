import { supabase } from '@/lib/supabase'
import type {
  AuctionBid,
  AuctionCall,
  AuctionPlayer,
  AuctionRoomData,
  AuctionRoomDetail,
  AuctionRoomStatus,
  AuctionRosterEntry,
  AuctionTeam,
} from '@/types/auction'

type PlayerSeasonRecord = {
  id: string
  role_fantasy: AuctionPlayer['roleFantasy']
  players: { id: string; first_name: string; last_name: string } | null
  clubs: { name: string } | null
}

export async function getAuctionRoom(roomId: string, userId: string): Promise<AuctionRoomData | null> {
  const roomResult = await supabase
    .from('auction_rooms')
    .select('id, name, status, season_id, total_budget, timer_seconds, seasons(label)')
    .eq('id', roomId)
    .maybeSingle()

  if (roomResult.error) throw roomResult.error
  if (!roomResult.data) return null

  const [participantsResult, teamsResult, callsResult, rostersResult, eventsResult] = await Promise.all([
    supabase.from('auction_participants').select('id, user_id, role').eq('room_id', roomId).eq('status', 'joined'),
    supabase.from('auction_teams').select('id, participant_id, name, budget_total, budget_spent').eq('room_id', roomId),
    supabase
      .from('auction_calls')
      .select('id, status, current_price, timer_ends_at, player_season_id')
      .eq('room_id', roomId)
      .eq('status', 'open')
      .maybeSingle(),
    supabase
      .from('auction_rosters')
      .select('id, team_id, role_at_purchase, price_paid, acquired_at, player_season_id')
      .eq('room_id', roomId)
      .order('acquired_at', { ascending: false }),
    supabase
      .from('auction_events')
      .select('id, event_type, payload, created_at')
      .eq('room_id', roomId)
      .order('created_at', { ascending: false })
      .limit(20),
  ])

  for (const result of [participantsResult, teamsResult, callsResult, rostersResult, eventsResult]) {
    if (result.error) throw result.error
  }

  const participantRows = participantsResult.data ?? []
  const teamRows = teamsResult.data ?? []
  const rosterRows = rostersResult.data ?? []
  const currentCallRow = callsResult.data
  const playerSeasonIds = [
    ...rosterRows.map((roster) => roster.player_season_id),
    ...(currentCallRow ? [currentCallRow.player_season_id] : []),
  ]
  const playersBySeasonId = await getPlayersBySeasonId(playerSeasonIds)
  const participantsById = new Map(participantRows.map((participant) => [participant.id, participant]))
  const rosterCountByTeamId = new Map<string, number>()

  for (const roster of rosterRows) {
    const count = rosterCountByTeamId.get(roster.team_id) ?? 0
    rosterCountByTeamId.set(roster.team_id, count + 1)
  }

  const teams = teamRows.map((team) => {
    const participant = participantsById.get(team.participant_id)
    const budgetTotal = Number(team.budget_total)
    const budgetSpent = Number(team.budget_spent)

    return {
      id: team.id,
      participantId: team.participant_id,
      name: team.name,
      budgetTotal,
      budgetSpent,
      budgetAvailable: budgetTotal - budgetSpent,
      role: participant?.role ?? 'member',
      isCurrentUser: participant?.user_id === userId,
      rosterCount: rosterCountByTeamId.get(team.id) ?? 0,
    } satisfies AuctionTeam
  })

  const currentCall = currentCallRow
    ? await toAuctionCall(currentCallRow, roomId, playersBySeasonId)
    : null

  const currentParticipant = participantRows.find((participant) => participant.user_id === userId)
  const room: AuctionRoomDetail = {
    id: roomResult.data.id,
    name: roomResult.data.name,
    status: roomResult.data.status as AuctionRoomStatus,
    seasonId: roomResult.data.season_id,
    seasonLabel: (roomResult.data.seasons as { label: string }[] | null)?.[0]?.label ?? null,
    totalBudget: Number(roomResult.data.total_budget),
    timerSeconds: roomResult.data.timer_seconds,
    accessRole: currentParticipant?.role ?? 'owner',
    myTeamId: teams.find((team) => team.isCurrentUser)?.id ?? null,
  }

  return {
    room,
    teams,
    currentCall,
    rosters: rosterRows.flatMap((roster) => {
      const player = playersBySeasonId.get(roster.player_season_id)
      return player ? [{
        id: roster.id,
        role: roster.role_at_purchase as AuctionRosterEntry['role'],
        pricePaid: Number(roster.price_paid),
        acquiredAt: roster.acquired_at,
        player,
      }] : []
    }),
    events: (eventsResult.data ?? []).map((event) => ({
      id: event.id,
      eventType: event.event_type,
      payload: event.payload as Record<string, unknown>,
      createdAt: event.created_at,
    })),
  }
}

export async function getAvailableAuctionPlayers(roomId: string, seasonId: string): Promise<AuctionPlayer[]> {
  const [playersResult, assignedResult, activeCallsResult] = await Promise.all([
    supabase
      .from('player_season_data')
      .select('id, role_fantasy, players(id, first_name, last_name), clubs(name)')
      .eq('season_id', seasonId)
      .order('role_fantasy'),
    supabase.from('auction_rosters').select('player_season_id').eq('room_id', roomId),
    supabase.from('auction_calls').select('player_season_id').eq('room_id', roomId).eq('status', 'open'),
  ])

  if (playersResult.error) throw playersResult.error
  if (assignedResult.error) throw assignedResult.error
  if (activeCallsResult.error) throw activeCallsResult.error

  const unavailableIds = new Set([
    ...(assignedResult.data ?? []).map((roster) => roster.player_season_id),
    ...(activeCallsResult.data ?? []).map((call) => call.player_season_id),
  ])

  return ((playersResult.data ?? []) as unknown as PlayerSeasonRecord[])
    .filter((player) => !unavailableIds.has(player.id))
    .map((player) => toAuctionPlayer(player))
}

export async function startAuctionCall(
  roomId: string,
  playerSeasonId: string,
  teamId: string,
  initialPrice: number,
) {
  const { data, error } = await supabase.rpc('start_auction_call', {
    p_room_id: roomId,
    p_player_season_id: playerSeasonId,
    p_nominated_by_team_id: teamId,
    p_initial_price: initialPrice,
  })
  if (error) throw error
  return data
}

export async function placeAuctionBid(roomId: string, callId: string, teamId: string, amount: number) {
  const { data, error } = await supabase.rpc('place_auction_bid', {
    p_room_id: roomId,
    p_call_id: callId,
    p_team_id: teamId,
    p_amount: amount,
  })
  if (error) throw error
  return data
}

export async function closeAuctionCall(roomId: string, callId: string) {
  const { data, error } = await supabase.rpc('close_auction_call', {
    p_room_id: roomId,
    p_call_id: callId,
  })
  if (error) throw error
  return data
}

async function toAuctionCall(
  call: { id: string; status: string; current_price: number | string; timer_ends_at: string | null; player_season_id: string },
  roomId: string,
  playersBySeasonId: Map<string, AuctionPlayer>,
): Promise<AuctionCall> {
  const bidResult = await supabase
    .from('auction_bids')
    .select('id, team_id, amount, created_at')
    .eq('room_id', roomId)
    .eq('call_id', call.id)
    .order('amount', { ascending: false })
    .order('created_at', { ascending: true })
    .limit(1)

  if (bidResult.error) throw bidResult.error
  const leadingBid = (bidResult.data?.[0] as AuctionBid | undefined) ?? null
  const player = playersBySeasonId.get(call.player_season_id)
  if (!player) throw new Error('Player data for the active call is unavailable.')

  return {
    id: call.id,
    status: call.status as AuctionCall['status'],
    currentPrice: Number(call.current_price),
    timerEndsAt: call.timer_ends_at,
    player,
    leadingTeamId: leadingBid?.teamId ?? null,
  }
}

async function getPlayersBySeasonId(playerSeasonIds: string[]) {
  const distinctIds = [...new Set(playerSeasonIds)]
  if (distinctIds.length === 0) return new Map<string, AuctionPlayer>()

  const result = await supabase
    .from('player_season_data')
    .select('id, role_fantasy, players(id, first_name, last_name), clubs(name)')
    .in('id', distinctIds)

  if (result.error) throw result.error

  return new Map(
    ((result.data ?? []) as unknown as PlayerSeasonRecord[]).map((player) => [
      player.id,
      toAuctionPlayer(player),
    ]),
  )
}

function toAuctionPlayer(player: PlayerSeasonRecord): AuctionPlayer {
  return {
    id: player.players?.id ?? player.id,
    playerSeasonId: player.id,
    name: player.players ? `${player.players.first_name} ${player.players.last_name}` : 'Giocatore non disponibile',
    clubName: player.clubs?.name ?? 'Club non disponibile',
    roleFantasy: player.role_fantasy,
    seasonLabel: null,
  }
}