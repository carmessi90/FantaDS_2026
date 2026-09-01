alter table public.auction_calls
  add unique (id, room_id, player_season_id);

alter table public.auction_rosters
  drop constraint auction_rosters_call_id_fkey,
  add constraint auction_rosters_call_room_player_fkey
    foreign key (call_id, room_id, player_season_id)
    references public.auction_calls (id, room_id, player_season_id)
    on delete restrict;

create function public.validate_auction_roster_winner()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  winning_team_id uuid;
begin
  select bid.team_id into winning_team_id
  from public.auction_bids bid
  where bid.call_id = new.call_id
    and bid.room_id = new.room_id
  order by bid.amount desc, bid.created_at asc, bid.id asc
  limit 1;

  if winning_team_id is null or winning_team_id <> new.team_id then
    raise exception 'Roster team must be the current highest bidder for the call';
  end if;

  if not exists (
    select 1
    from public.auction_calls call
    where call.id = new.call_id
      and call.room_id = new.room_id
      and call.player_season_id = new.player_season_id
      and call.status = 'closed'
  ) then
    raise exception 'A roster can be created only from a closed call';
  end if;

  return new;
end;
$$;

create trigger validate_auction_roster_winner_trigger
before insert on public.auction_rosters
for each row execute function public.validate_auction_roster_winner();