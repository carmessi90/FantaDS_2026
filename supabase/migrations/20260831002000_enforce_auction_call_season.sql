create function public.validate_auction_call_season()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.auction_rooms room
    join public.player_season_data player_season on player_season.id = new.player_season_id
    where room.id = new.room_id
      and room.season_id = player_season.season_id
  ) then
    raise exception 'Auction call player must belong to the room season';
  end if;

  return new;
end;
$$;

create trigger validate_auction_call_season_trigger
before insert or update of room_id, player_season_id on public.auction_calls
for each row execute function public.validate_auction_call_season();