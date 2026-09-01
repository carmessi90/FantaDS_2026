create function public.start_auction_call(
  p_room_id uuid,
  p_player_season_id uuid,
  p_nominated_by_team_id uuid,
  p_initial_price numeric
)
returns table (
  call_id uuid,
  current_price numeric,
  expires_at timestamptz,
  call_status text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  room_timer_seconds integer;
  created_call public.auction_calls;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required';
  end if;

  if p_initial_price < 0 then
    raise exception 'Initial price cannot be negative';
  end if;

  perform 1
  from public.auction_rooms room
  where room.id = p_room_id
    and room.status = 'active'
  for update;

  if not found or not public.is_auction_admin(p_room_id) then
    raise exception 'Only an auction owner or admin can start a call in an active room';
  end if;

  select room.timer_seconds into room_timer_seconds
  from public.auction_rooms room
  where room.id = p_room_id;

  if not exists (
    select 1
    from public.auction_teams team
    where team.id = p_nominated_by_team_id
      and team.room_id = p_room_id
  ) then
    raise exception 'Nominating team must belong to the auction room';
  end if;

  if not exists (
    select 1
    from public.player_season_data player_season
    join public.auction_rooms room on room.season_id = player_season.season_id
    where player_season.id = p_player_season_id
      and room.id = p_room_id
  ) then
    raise exception 'Player must belong to the auction room season';
  end if;

  if exists (
    select 1
    from public.auction_rosters roster
    where roster.room_id = p_room_id
      and roster.player_season_id = p_player_season_id
  ) or exists (
    select 1
    from public.auction_calls call
    where call.room_id = p_room_id
      and call.player_season_id = p_player_season_id
      and call.status = 'assigned'
  ) then
    raise exception 'Player has already been assigned in this auction room';
  end if;

  insert into public.auction_calls (
    room_id,
    player_season_id,
    nominated_by_team_id,
    status,
    current_price,
    timer_ends_at
  )
  values (
    p_room_id,
    p_player_season_id,
    p_nominated_by_team_id,
    'open',
    p_initial_price,
    case
      when room_timer_seconds is null then null
      else timezone('utc', now()) + make_interval(secs => room_timer_seconds)
    end
  )
  returning * into created_call;

  insert into public.auction_events (room_id, event_type, payload)
  values (
    p_room_id,
    'call_started',
    jsonb_build_object(
      'call_id', created_call.id,
      'player_season_id', p_player_season_id,
      'nominated_by_team_id', p_nominated_by_team_id,
      'initial_price', p_initial_price,
      'timer_ends_at', created_call.timer_ends_at
    )
  );

  return query
  select created_call.id, created_call.current_price, created_call.timer_ends_at, created_call.status;
end;
$$;

create function public.place_auction_bid(
  p_room_id uuid,
  p_call_id uuid,
  p_team_id uuid,
  p_amount numeric
)
returns table (
  call_id uuid,
  current_price numeric,
  leading_team_id uuid,
  expires_at timestamptz,
  call_status text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  locked_call public.auction_calls;
  available_budget numeric(10, 2);
begin
  if auth.uid() is null then
    raise exception 'Authentication is required';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Bid amount must be positive';
  end if;

  select call.* into locked_call
  from public.auction_calls call
  join public.auction_rooms room on room.id = call.room_id
  where call.id = p_call_id
    and call.room_id = p_room_id
    and call.status = 'open'
    and room.status = 'active'
    and (call.timer_ends_at is null or call.timer_ends_at > timezone('utc', now()))
  for update of call;

  if not found then
    raise exception 'Auction call is not active or has expired';
  end if;

  select team.budget_total - team.budget_spent into available_budget
  from public.auction_teams team
  join public.auction_participants participant on participant.id = team.participant_id
  where team.id = p_team_id
    and team.room_id = p_room_id
    and participant.user_id = auth.uid()
    and participant.status = 'joined'
  for update of team;

  if available_budget is null then
    raise exception 'Bid team must belong to the authenticated participant';
  end if;

  if p_amount <= locked_call.current_price then
    raise exception 'Bid amount must exceed the current price';
  end if;

  if p_amount > available_budget then
    raise exception 'Bid amount exceeds the available team budget';
  end if;

  insert into public.auction_bids (room_id, call_id, team_id, amount)
  values (p_room_id, p_call_id, p_team_id, p_amount);

  update public.auction_calls
  set current_price = p_amount
  where id = p_call_id
  returning * into locked_call;

  insert into public.auction_events (room_id, event_type, payload)
  values (
    p_room_id,
    'bid_placed',
    jsonb_build_object(
      'call_id', p_call_id,
      'team_id', p_team_id,
      'amount', p_amount
    )
  );

  return query
  select locked_call.id, locked_call.current_price, p_team_id, locked_call.timer_ends_at, locked_call.status;
end;
$$;

create function public.close_auction_call(
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
    values (
      p_room_id,
      'call_closed_without_bids',
      jsonb_build_object('call_id', p_call_id)
    );

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

drop policy "bids_insert_own_team" on public.auction_bids;

revoke all on function public.start_auction_call(uuid, uuid, uuid, numeric) from public, anon;
revoke all on function public.place_auction_bid(uuid, uuid, uuid, numeric) from public, anon;
revoke all on function public.close_auction_call(uuid, uuid) from public, anon;
grant execute on function public.start_auction_call(uuid, uuid, uuid, numeric) to authenticated;
grant execute on function public.place_auction_bid(uuid, uuid, uuid, numeric) to authenticated;
grant execute on function public.close_auction_call(uuid, uuid) to authenticated;