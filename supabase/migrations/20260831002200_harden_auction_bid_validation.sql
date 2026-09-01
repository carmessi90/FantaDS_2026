create function public.validate_auction_bid_v2()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  call_price numeric(10, 2);
  available_budget numeric(10, 2);
begin
  select call.current_price into call_price
  from public.auction_calls call
  join public.auction_rooms room on room.id = call.room_id
  where call.id = new.call_id
    and call.room_id = new.room_id
    and call.status = 'open'
    and room.status = 'active'
    and (call.timer_ends_at is null or call.timer_ends_at > timezone('utc', now()))
  for update of call;

  if call_price is null then
    raise exception 'Bids are accepted only for an active, unexpired call';
  end if;

  if new.amount <= call_price then
    raise exception 'Bid amount must exceed the current price';
  end if;

  select team.budget_total - team.budget_spent into available_budget
  from public.auction_teams team
  where team.id = new.team_id
    and team.room_id = new.room_id;

  if available_budget is null or new.amount > available_budget then
    raise exception 'Bid amount exceeds the available team budget';
  end if;

  if auth.uid() is not null and not exists (
    select 1
    from public.auction_teams team
    join public.auction_participants participant on participant.id = team.participant_id
    where team.id = new.team_id
      and team.room_id = new.room_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
  ) then
    raise exception 'Bid team must belong to the authenticated participant';
  end if;

  update public.auction_calls
  set current_price = new.amount
  where id = new.call_id;

  return new;
end;
$$;

create trigger validate_auction_bid_v2_trigger
before insert on public.auction_bids
for each row execute function public.validate_auction_bid_v2();

revoke execute on function public.validate_auction_bid_v2() from public;

drop policy "calls_manage_admin" on public.auction_calls;