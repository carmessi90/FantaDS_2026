create table public.auction_rooms (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons (id) on delete restrict,
  owner_id uuid not null references public.profiles (id) on delete restrict,
  name text not null,
  status public.auction_room_status not null default 'draft',
  total_budget numeric(10, 2) not null check (total_budget > 0),
  timer_seconds integer check (timer_seconds is null or timer_seconds > 0),
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, season_id),
  check (ended_at is null or started_at is null or ended_at >= started_at)
);

create table public.auction_participants (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  user_id uuid not null references public.profiles (id) on delete restrict,
  role text not null default 'member' check (role in ('owner', 'admin', 'member')),
  status text not null default 'invited' check (
    status in ('invited', 'joined', 'left', 'removed')
  ),
  joined_at timestamptz,
  left_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (room_id, user_id),
  unique (id, room_id),
  check (left_at is null or joined_at is null or left_at >= joined_at)
);

create table public.auction_teams (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  participant_id uuid not null,
  imported_strategy_id uuid references public.strategies (id) on delete set null,
  name text not null,
  budget_total numeric(10, 2) not null check (budget_total > 0),
  budget_spent numeric(10, 2) not null default 0 check (
    budget_spent >= 0 and budget_spent <= budget_total
  ),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (participant_id),
  unique (id, room_id),
  unique (room_id, name),
  foreign key (participant_id, room_id)
    references public.auction_participants (id, room_id) on delete restrict
);

create table public.auction_role_limits (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  role_fantasy public.fantasy_role not null,
  max_count integer not null check (max_count >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (room_id, role_fantasy)
);