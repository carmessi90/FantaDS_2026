create function public.validate_predicted_lineup()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.fixtures fixture
    where fixture.id = new.fixture_id
      and new.club_id in (fixture.home_club_id, fixture.away_club_id)
  ) then
    raise exception 'Predicted lineup club must play in the fixture';
  end if;

  return new;
end;
$$;

create function public.validate_predicted_lineup_player()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.predicted_lineups lineup
    join public.fixtures fixture on fixture.id = lineup.fixture_id
    join public.player_season_data player_season on player_season.player_id = new.player_id
    where lineup.id = new.predicted_lineup_id
      and player_season.season_id = fixture.season_id
      and player_season.club_id = lineup.club_id
  ) then
    raise exception 'Predicted lineup player must belong to the lineup club in the fixture season';
  end if;

  return new;
end;
$$;

create function public.validate_player_match_statistics()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.player_season_data player_season
    join public.fixtures fixture on fixture.id = new.fixture_id
    where player_season.id = new.player_season_id
      and player_season.season_id = fixture.season_id
  ) then
    raise exception 'Player match statistics must use the fixture season';
  end if;

  return new;
end;
$$;

create trigger validate_predicted_lineup_trigger
before insert or update of fixture_id, club_id on public.predicted_lineups
for each row execute function public.validate_predicted_lineup();

create trigger validate_predicted_lineup_player_trigger
before insert or update of predicted_lineup_id, player_id on public.predicted_lineup_players
for each row execute function public.validate_predicted_lineup_player();

create trigger validate_player_match_statistics_trigger
before insert or update of player_season_id, fixture_id on public.player_match_statistics
for each row execute function public.validate_player_match_statistics();

create index auction_bids_room_created_at_idx
  on public.auction_bids (room_id, created_at desc);

create index auction_rosters_room_acquired_at_idx
  on public.auction_rosters (room_id, acquired_at desc);