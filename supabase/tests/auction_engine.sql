begin;

insert into auth.users (id, aud, role, email, encrypted_password, created_at, updated_at)
values
  ('a0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'owner-auction-test@example.test', 'test', now(), now()),
  ('b0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'member-auction-test@example.test', 'test', now(), now());

insert into public.seasons (id, label, is_current)
values ('20000000-0000-0000-0000-000000000001', 'test-season', true);

insert into public.clubs (id, name, short_name)
values ('30000000-0000-0000-0000-000000000001', 'Test Club', 'TST');

insert into public.players (id, first_name, last_name)
values
  ('40000000-0000-0000-0000-000000000001', 'First', 'Player'),
  ('40000000-0000-0000-0000-000000000002', 'Second', 'Player');

insert into public.player_season_data (id, player_id, season_id, club_id, role_fantasy)
values
  ('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'D'),
  ('50000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'D');

insert into public.auction_rooms (id, season_id, owner_id, name, status, total_budget, timer_seconds)
values ('60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Test Auction', 'active', 100, 60);

insert into public.auction_participants (id, room_id, user_id, role, status, joined_at)
values
  ('70000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'owner', 'joined', now()),
  ('70000000-0000-0000-0000-000000000002', '60000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', 'member', 'joined', now());

insert into public.auction_teams (id, room_id, participant_id, name, budget_total)
values
  ('80000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', 'Owner Team', 100),
  ('80000000-0000-0000-0000-000000000002', '60000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000002', 'Member Team', 100);

insert into public.auction_role_limits (room_id, role_fantasy, max_count)
values
  ('60000000-0000-0000-0000-000000000001', 'P', 3),
  ('60000000-0000-0000-0000-000000000001', 'D', 8),
  ('60000000-0000-0000-0000-000000000001', 'C', 8),
  ('60000000-0000-0000-0000-000000000001', 'A', 6);

set local role authenticated;

set local request.jwt.claim.sub = 'b0000000-0000-0000-0000-000000000002';
do $$
begin
  perform public.start_auction_call(
    '60000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000001',
    '80000000-0000-0000-0000-000000000002',
    1
  );
  raise exception 'Unauthorized member started a call';
exception
  when others then
    if position('Only an auction owner or admin' in sqlerrm) = 0 then
      raise;
    end if;
end;
$$;

set local request.jwt.claim.sub = 'a0000000-0000-0000-0000-000000000001';
select * from public.start_auction_call(
  '60000000-0000-0000-0000-000000000001',
  '50000000-0000-0000-0000-000000000001',
  '80000000-0000-0000-0000-000000000001',
  1
);

set local request.jwt.claim.sub = 'b0000000-0000-0000-0000-000000000002';
select * from public.place_auction_bid(
  '60000000-0000-0000-0000-000000000001',
  (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001'),
  '80000000-0000-0000-0000-000000000002',
  10
);

do $$
begin
  perform public.place_auction_bid(
    '60000000-0000-0000-0000-000000000001',
    (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001'),
    '80000000-0000-0000-0000-000000000002',
    10
  );
  raise exception 'Equal bid was accepted';
exception
  when others then
    if position('Bid amount must exceed the current price' in sqlerrm) = 0 then
      raise;
    end if;
end;
$$;

do $$
begin
  perform public.place_auction_bid(
    '60000000-0000-0000-0000-000000000001',
    (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001'),
    '80000000-0000-0000-0000-000000000002',
    101
  );
  raise exception 'Over-budget bid was accepted';
exception
  when others then
    if position('Bid amount exceeds the available team budget' in sqlerrm) = 0 then
      raise;
    end if;
end;
$$;

set local request.jwt.claim.sub = 'a0000000-0000-0000-0000-000000000001';
select * from public.close_auction_call(
  '60000000-0000-0000-0000-000000000001',
  (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001')
);

do $$
begin
  if (select count(*) from public.auction_rosters) <> 1
    or (select budget_spent from public.auction_teams where id = '80000000-0000-0000-0000-000000000002') <> 10
    or (select status from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001') <> 'assigned' then
    raise exception 'Winning call did not produce the expected roster, budget, and status';
  end if;
end;
$$;

set local request.jwt.claim.sub = 'b0000000-0000-0000-0000-000000000002';
do $$
begin
  perform public.place_auction_bid(
    '60000000-0000-0000-0000-000000000001',
    (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001'),
    '80000000-0000-0000-0000-000000000002',
    11
  );
  raise exception 'Bid on a closed call was accepted';
exception
  when others then
    if position('Auction call is not active or has expired' in sqlerrm) = 0 then
      raise;
    end if;
end;
$$;

set local request.jwt.claim.sub = 'a0000000-0000-0000-0000-000000000001';
do $$
begin
  perform public.close_auction_call(
    '60000000-0000-0000-0000-000000000001',
    (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000001')
  );
  raise exception 'A closed call was closed twice';
exception
  when others then
    if position('Auction call is already closed or unavailable' in sqlerrm) = 0 then
      raise;
    end if;
end;
$$;

do $$
begin
  perform public.start_auction_call(
    '60000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000001',
    '80000000-0000-0000-0000-000000000001',
    1
  );
  raise exception 'An assigned player was called a second time';
exception
  when others then
    if position('Player has already been assigned' in sqlerrm) = 0 then
      raise;
    end if;
end;
$$;

select * from public.start_auction_call(
  '60000000-0000-0000-0000-000000000001',
  '50000000-0000-0000-0000-000000000002',
  '80000000-0000-0000-0000-000000000001',
  1
);

select * from public.close_auction_call(
  '60000000-0000-0000-0000-000000000001',
  (select id from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000002')
);

do $$
begin
  if (select count(*) from public.auction_rosters) <> 1
    or (select status from public.auction_calls where player_season_id = '50000000-0000-0000-0000-000000000002') <> 'closed' then
    raise exception 'No-bid call produced an unexpected assignment';
  end if;
end;
$$;

rollback;