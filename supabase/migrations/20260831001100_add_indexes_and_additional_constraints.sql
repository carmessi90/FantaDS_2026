create unique index seasons_one_current_idx
  on public.seasons (is_current)
  where is_current;

create unique index profiles_username_lower_idx
  on public.profiles (lower(username));

create index players_name_trgm_idx
  on public.players using gin ((lower(first_name || ' ' || last_name)) gin_trgm_ops);

create index player_season_data_listone_idx
  on public.player_season_data (season_id, role_fantasy, club_id);

create index player_season_data_quotation_idx
  on public.player_season_data (season_id, quotation_current);

create index player_market_data_history_idx
  on public.player_market_data (player_season_id, recorded_at desc);

create index player_match_statistics_fixture_idx
  on public.player_match_statistics (fixture_id);

create index player_advanced_metrics_lookup_idx
  on public.player_advanced_metrics (player_season_id, metric_key);

create unique index player_advanced_metrics_fixture_unique_idx
  on public.player_advanced_metrics (player_season_id, fixture_id, provider, metric_key)
  where fixture_id is not null;

create unique index player_advanced_metrics_season_unique_idx
  on public.player_advanced_metrics (player_season_id, provider, metric_key)
  where fixture_id is null;

create index strategies_owner_idx
  on public.strategies (user_id, deleted_at);

create index strategy_players_tier_idx
  on public.strategy_players (tier_id, sort_order);

create index auction_rooms_owner_idx
  on public.auction_rooms (owner_id, created_at desc);

create index auction_participants_user_idx
  on public.auction_participants (user_id, status);

create index auction_teams_room_idx
  on public.auction_teams (room_id);

create unique index auction_calls_one_open_per_room_idx
  on public.auction_calls (room_id)
  where status = 'open';

create index auction_calls_room_status_idx
  on public.auction_calls (room_id, status, created_at desc);

create index auction_bids_call_idx
  on public.auction_bids (call_id, created_at desc);

create index auction_rosters_team_role_idx
  on public.auction_rosters (team_id, role_at_purchase);

create index auction_events_room_idx
  on public.auction_events (room_id, created_at desc);

create index fixtures_season_matchday_idx
  on public.fixtures (season_id, matchday);

create index predicted_lineups_fixture_club_idx
  on public.predicted_lineups (fixture_id, club_id);