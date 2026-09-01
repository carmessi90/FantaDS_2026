create function public.is_auction_participant(target_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.auction_participants participant
    where participant.room_id = target_room_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
  );
$$;

create function public.is_auction_admin(target_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.auction_rooms room
    where room.id = target_room_id
      and room.owner_id = auth.uid()
  ) or exists (
    select 1
    from public.auction_participants participant
    where participant.room_id = target_room_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
      and participant.role in ('owner', 'admin')
  );
$$;

alter table public.profiles enable row level security;
alter table public.clubs enable row level security;
alter table public.seasons enable row level security;
alter table public.tactical_positions enable row level security;
alter table public.players enable row level security;
alter table public.player_season_data enable row level security;
alter table public.player_statistics enable row level security;
alter table public.player_market_data enable row level security;
alter table public.player_match_statistics enable row level security;
alter table public.player_advanced_metrics enable row level security;
alter table public.strategies enable row level security;
alter table public.strategy_tiers enable row level security;
alter table public.strategy_players enable row level security;
alter table public.auction_rooms enable row level security;
alter table public.auction_participants enable row level security;
alter table public.auction_teams enable row level security;
alter table public.auction_role_limits enable row level security;
alter table public.auction_calls enable row level security;
alter table public.auction_bids enable row level security;
alter table public.auction_rosters enable row level security;
alter table public.auction_events enable row level security;
alter table public.player_favorites enable row level security;
alter table public.lineup_sources enable row level security;
alter table public.fixtures enable row level security;
alter table public.predicted_lineups enable row level security;
alter table public.predicted_lineup_players enable row level security;
alter table public.data_sync_logs enable row level security;

create policy "profiles_select_own" on public.profiles for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_update_own" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy "authenticated_read_clubs" on public.clubs for select to authenticated using (true);
create policy "authenticated_read_seasons" on public.seasons for select to authenticated using (true);
create policy "authenticated_read_tactical_positions" on public.tactical_positions for select to authenticated using (true);
create policy "authenticated_read_players" on public.players for select to authenticated using (true);
create policy "authenticated_read_player_season_data" on public.player_season_data for select to authenticated using (true);
create policy "authenticated_read_player_statistics" on public.player_statistics for select to authenticated using (true);
create policy "authenticated_read_player_market_data" on public.player_market_data for select to authenticated using (true);
create policy "authenticated_read_player_match_statistics" on public.player_match_statistics for select to authenticated using (true);
create policy "authenticated_read_player_advanced_metrics" on public.player_advanced_metrics for select to authenticated using (true);
create policy "authenticated_read_lineup_sources" on public.lineup_sources for select to authenticated using (true);
create policy "authenticated_read_fixtures" on public.fixtures for select to authenticated using (true);
create policy "authenticated_read_predicted_lineups" on public.predicted_lineups for select to authenticated using (true);
create policy "authenticated_read_predicted_lineup_players" on public.predicted_lineup_players for select to authenticated using (true);

create policy "strategies_manage_own" on public.strategies for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "strategy_tiers_manage_owner" on public.strategy_tiers for all to authenticated using (exists (select 1 from public.strategies strategy where strategy.id = strategy_id and strategy.user_id = (select auth.uid()))) with check (exists (select 1 from public.strategies strategy where strategy.id = strategy_id and strategy.user_id = (select auth.uid())));
create policy "strategy_players_manage_owner" on public.strategy_players for all to authenticated using (exists (select 1 from public.strategy_tiers tier join public.strategies strategy on strategy.id = tier.strategy_id where tier.id = tier_id and strategy.user_id = (select auth.uid()))) with check (exists (select 1 from public.strategy_tiers tier join public.strategies strategy on strategy.id = tier.strategy_id where tier.id = tier_id and strategy.user_id = (select auth.uid())));

create policy "favorites_manage_own" on public.player_favorites for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "rooms_create_own" on public.auction_rooms for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "rooms_read_authorized" on public.auction_rooms for select to authenticated using ((select auth.uid()) = owner_id or public.is_auction_participant(id));
create policy "rooms_update_admin" on public.auction_rooms for update to authenticated using (public.is_auction_admin(id)) with check (public.is_auction_admin(id));
create policy "participants_read_authorized" on public.auction_participants for select to authenticated using (public.is_auction_admin(room_id) or public.is_auction_participant(room_id));
create policy "participants_manage_admin" on public.auction_participants for all to authenticated using (public.is_auction_admin(room_id)) with check (public.is_auction_admin(room_id));

create policy "teams_read_authorized" on public.auction_teams for select to authenticated using (public.is_auction_participant(room_id));
create policy "teams_manage_admin" on public.auction_teams for all to authenticated using (public.is_auction_admin(room_id)) with check (public.is_auction_admin(room_id));
create policy "limits_read_authorized" on public.auction_role_limits for select to authenticated using (public.is_auction_participant(room_id));
create policy "limits_manage_admin" on public.auction_role_limits for all to authenticated using (public.is_auction_admin(room_id)) with check (public.is_auction_admin(room_id));
create policy "calls_read_authorized" on public.auction_calls for select to authenticated using (public.is_auction_participant(room_id));
create policy "calls_manage_admin" on public.auction_calls for all to authenticated using (public.is_auction_admin(room_id)) with check (public.is_auction_admin(room_id));
create policy "bids_read_authorized" on public.auction_bids for select to authenticated using (public.is_auction_participant(room_id));
create policy "bids_insert_own_team" on public.auction_bids for insert to authenticated with check (public.is_auction_participant(auction_bids.room_id) and exists (select 1 from public.auction_teams team join public.auction_participants participant on participant.id = team.participant_id where team.id = auction_bids.team_id and team.room_id = auction_bids.room_id and participant.user_id = (select auth.uid())));
create policy "rosters_read_authorized" on public.auction_rosters for select to authenticated using (public.is_auction_participant(room_id));
create policy "rosters_manage_admin" on public.auction_rosters for all to authenticated using (public.is_auction_admin(room_id)) with check (public.is_auction_admin(room_id));
create policy "events_read_authorized" on public.auction_events for select to authenticated using (public.is_auction_participant(room_id));
create policy "events_manage_admin" on public.auction_events for all to authenticated using (public.is_auction_admin(room_id)) with check (public.is_auction_admin(room_id));