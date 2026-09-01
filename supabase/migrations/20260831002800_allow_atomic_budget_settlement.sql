create or replace function public.validate_auction_team_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  room_budget numeric(10, 2);
begin
  if tg_op = 'UPDATE' and (
    new.room_id is distinct from old.room_id
    or new.participant_id is distinct from old.participant_id
    or new.budget_total is distinct from old.budget_total
    or (
      new.budget_spent is distinct from old.budget_spent
      and coalesce(current_setting('app.auction_engine_budget_settlement', true), '') <> 'true'
    )
  ) then
    raise exception 'Team room, participant and budgets cannot be changed directly';
  end if;

  if tg_op = 'INSERT' then
    select total_budget into room_budget
    from public.auction_rooms
    where id = new.room_id;

    if new.budget_total <> room_budget or new.budget_spent <> 0 then
      raise exception 'A new team must use the room budget and start with no spend';
    end if;
  end if;

  return new;
end;
$$;

create or replace function public.close_auction_call(
  p_room_id uuid,
  p_call_id uuid
)
returns table (
  call_id uuid,
  call_status text,
  winning_team_id uuid,
  final_price numeric
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  locked_call public.auction_calls;
  winning_bid public.auction_bids;
  player_role public.fantasy_role;
  available_budget numeric(10, 2);
begin
  if auth.uid() is null then
    raise exception 'Authentication is required';
  end if;

  if not public.is_auction_admin(p_room_id) then
    raise exception 'Only an auction owner or admin can close a call';
  end if;

  select call.* into locked_call
  from public.auction_calls call
  join public.auction_rooms room on room.id = call.room_id
  where call.id = p_call_id
    and call.room_id = p_room_id
    and call.status = 'open'
    and room.status = 'active'
  for update of call;

  if not found then
    raise exception 'Auction call is already closed or unavailable';
  end if;

  select bid.* into winning_bid
  from public.auction_bids bid
  where bid.call_id = p_call_id
    and bid.room_id = p_room_id
  order by bid.amount desc, bid.created_at asc, bid.id asc
  limit 1;

  if winning_bid.id is null then
    update public.auction_calls
    set status = 'closed', closed_at = timezone('utc', now())
    where id = p_call_id
    returning * into locked_call;

    insert into public.auction_events (room_id, event_type, payload)
    values (p_room_id, 'call_closed_without_bids', jsonb_build_object('call_id', p_call_id));

    return query select locked_call.id, locked_call.status, null::uuid, locked_call.current_price;
    return;
  end if;

  select player_season.role_fantasy into player_role
  from public.player_season_data player_season
  where player_season.id = locked_call.player_season_id;

  select team.budget_total - team.budget_spent into available_budget
  from public.auction_teams team
  where team.id = winning_bid.team_id
    and team.room_id = p_room_id
  for update;

  if available_budget is null or winning_bid.amount > available_budget then
    raise exception 'Winning team no longer has sufficient budget';
  end if;

  update public.auction_calls
  set status = 'closed', closed_at = timezone('utc', now())
  where id = p_call_id
  returning * into locked_call;

  insert into public.auction_rosters (
    room_id,
    team_id,
    player_season_id,
    call_id,
    price_paid,
    role_at_purchase
  )
  values (
    p_room_id,
    winning_bid.team_id,
    locked_call.player_season_id,
    p_call_id,
    winning_bid.amount,
    player_role
  );

  perform set_config('app.auction_engine_budget_settlement', 'true', true);

  update public.auction_teams
  set budget_spent = budget_spent + winning_bid.amount
  where id = winning_bid.team_id;

  update public.auction_calls
  set status = 'assigned'
  where id = p_call_id
  returning * into locked_call;

  insert into public.auction_events (room_id, event_type, payload)
  values (
    p_room_id,
    'player_assigned',
    jsonb_build_object(
      'call_id', p_call_id,
      'player_season_id', locked_call.player_season_id,
      'team_id', winning_bid.team_id,
      'price_paid', winning_bid.amount
    )
  );

  return query select locked_call.id, locked_call.status, winning_bid.team_id, winning_bid.amount;
end;
$$;

revoke all on function public.close_auction_call(uuid, uuid) from public, anon;
grant execute on function public.close_auction_call(uuid, uuid) to authenticated;