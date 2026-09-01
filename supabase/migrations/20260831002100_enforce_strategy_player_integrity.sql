create function public.validate_strategy_player()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.strategy_tiers tier
    join public.strategies strategy on strategy.id = tier.strategy_id
    join public.player_season_data player_season on player_season.id = new.player_season_id
    where tier.id = new.tier_id
      and strategy.season_id = player_season.season_id
      and tier.role_fantasy = player_season.role_fantasy
  ) then
    raise exception 'Strategy player must match the strategy season and tier role';
  end if;

  return new;
end;
$$;

create trigger validate_strategy_player_trigger
before insert or update of tier_id, player_season_id on public.strategy_players
for each row execute function public.validate_strategy_player();