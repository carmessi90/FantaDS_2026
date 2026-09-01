create table public.auction_calls (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  nominated_by_team_id uuid not null,
  status text not null default 'open' check (
    status in ('open', 'closed', 'assigned', 'cancelled')
  ),
  current_price numeric(10, 2) not null default 0 check (current_price >= 0),
  timer_ends_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, room_id),
  foreign key (nominated_by_team_id, room_id)
    references public.auction_teams (id, room_id) on delete restrict
);

create table public.auction_bids (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null,
  call_id uuid not null,
  team_id uuid not null,
  amount numeric(10, 2) not null check (amount > 0),
  created_at timestamptz not null default timezone('utc', now()),
  foreign key (call_id, room_id)
    references public.auction_calls (id, room_id) on delete restrict,
  foreign key (team_id, room_id)
    references public.auction_teams (id, room_id) on delete restrict
);

create table public.auction_rosters (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  team_id uuid not null,
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  call_id uuid not null references public.auction_calls (id) on delete restrict,
  price_paid numeric(10, 2) not null check (price_paid >= 0),
  role_at_purchase public.fantasy_role not null,
  acquired_at timestamptz not null default timezone('utc', now()),
  unique (room_id, player_season_id),
  unique (call_id),
  foreign key (team_id, room_id)
    references public.auction_teams (id, room_id) on delete restrict
);

create table public.auction_events (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  check (jsonb_typeof(payload) = 'object')
);