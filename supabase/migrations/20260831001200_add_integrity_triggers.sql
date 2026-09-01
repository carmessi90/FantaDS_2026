create function public.validate_auction_team_strategy()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.imported_strategy_id is not null and not exists (
    select 1
    from public.strategies strategy
    join public.auction_participants participant on participant.id = new.participant_id
    join public.auction_rooms room on room.id = new.room_id
    where strategy.id = new.imported_strategy_id
      and strategy.user_id = participant.user_id
      and strategy.season_id = room.season_id
      and strategy.deleted_at is null
  ) then
    raise exception 'Imported strategy must belong to the participant and match the auction season';
  end if;

  return new;
end;
$$;

create function public.validate_auction_roster()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  role_limit integer;
  current_count integer;
begin
  perform 1
  from public.auction_teams
  where id = new.team_id
  for update;

  if not exists (
    select 1
    from public.auction_rooms room
    join public.player_season_data player_season on player_season.id = new.player_season_id
    where room.id = new.room_id
      and room.season_id = player_season.season_id
      and player_season.role_fantasy = new.role_at_purchase
  ) then
    raise exception 'Player season and roster role must match the auction season data';
  end if;

  select max_count into role_limit
  from public.auction_role_limits
  where room_id = new.room_id
    and role_fantasy = new.role_at_purchase;

  if role_limit is null then
    raise exception 'No roster limit configured for role %', new.role_at_purchase;
  end if;

  select count(*) into current_count
  from public.auction_rosters
  where team_id = new.team_id
    and role_at_purchase = new.role_at_purchase;

  if current_count >= role_limit then
    raise exception 'Roster limit reached for role %', new.role_at_purchase;
  end if;

  return new;
end;
$$;

create function public.validate_auction_bid()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.auction_calls call
    join public.auction_rooms room on room.id = call.room_id
    where call.id = new.call_id
      and call.room_id = new.room_id
      and call.status = 'open'
      and room.status = 'active'
  ) then
    raise exception 'Bids are accepted only for an open call in an active auction';
  end if;

  return new;
end;
$$;

create trigger validate_auction_team_strategy_trigger
before insert or update of imported_strategy_id, participant_id, room_id
on public.auction_teams
for each row execute function public.validate_auction_team_strategy();

create trigger validate_auction_roster_trigger
before insert on public.auction_rosters
for each row execute function public.validate_auction_roster();

create trigger validate_auction_bid_trigger
before insert on public.auction_bids
for each row execute function public.validate_auction_bid();

create trigger set_updated_at_profiles
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger set_updated_at_seasons
before update on public.seasons
for each row execute function public.set_updated_at();

create trigger set_updated_at_clubs
before update on public.clubs
for each row execute function public.set_updated_at();

create trigger set_updated_at_tactical_positions
before update on public.tactical_positions
for each row execute function public.set_updated_at();

create trigger set_updated_at_players
before update on public.players
for each row execute function public.set_updated_at();

create trigger set_updated_at_player_season_data
before update on public.player_season_data
for each row execute function public.set_updated_at();

create trigger set_updated_at_player_statistics
before update on public.player_statistics
for each row execute function public.set_updated_at();

create trigger set_updated_at_player_match_statistics
before update on public.player_match_statistics
for each row execute function public.set_updated_at();

create trigger set_updated_at_strategies
before update on public.strategies
for each row execute function public.set_updated_at();

create trigger set_updated_at_strategy_tiers
before update on public.strategy_tiers
for each row execute function public.set_updated_at();

create trigger set_updated_at_strategy_players
before update on public.strategy_players
for each row execute function public.set_updated_at();

create trigger set_updated_at_auction_rooms
before update on public.auction_rooms
for each row execute function public.set_updated_at();

create trigger set_updated_at_auction_participants
before update on public.auction_participants
for each row execute function public.set_updated_at();

create trigger set_updated_at_auction_teams
before update on public.auction_teams
for each row execute function public.set_updated_at();

create trigger set_updated_at_auction_role_limits
before update on public.auction_role_limits
for each row execute function public.set_updated_at();

create trigger set_updated_at_auction_calls
before update on public.auction_calls
for each row execute function public.set_updated_at();

create trigger set_updated_at_lineup_sources
before update on public.lineup_sources
for each row execute function public.set_updated_at();

create trigger set_updated_at_fixtures
before update on public.fixtures
for each row execute function public.set_updated_at();

create trigger set_updated_at_predicted_lineups
before update on public.predicted_lineups
for each row execute function public.set_updated_at();

create trigger set_updated_at_predicted_lineup_players
before update on public.predicted_lineup_players
for each row execute function public.set_updated_at();