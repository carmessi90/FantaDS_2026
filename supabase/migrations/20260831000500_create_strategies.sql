create table public.strategies (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  season_id uuid not null references public.seasons (id) on delete restrict,
  name text not null,
  description text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  check (char_length(trim(name)) between 1 and 100)
);

create table public.strategy_tiers (
  id uuid primary key default gen_random_uuid(),
  strategy_id uuid not null references public.strategies (id) on delete cascade,
  role_fantasy public.fantasy_role not null,
  name text not null,
  position_order integer not null check (position_order >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (strategy_id, role_fantasy, position_order)
);

create table public.strategy_players (
  id uuid primary key default gen_random_uuid(),
  tier_id uuid not null references public.strategy_tiers (id) on delete cascade,
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  symbolic_price numeric(10, 2) not null check (symbolic_price >= 0),
  notes text,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (tier_id, player_season_id)
);