create table public.players (
  id uuid primary key default gen_random_uuid(),
  first_name text not null,
  last_name text not null,
  birth_date date,
  provider text,
  provider_player_id text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (provider, provider_player_id),
  check (
    (provider is null and provider_player_id is null)
    or (provider is not null and provider_player_id is not null)
  )
);

create table public.player_season_data (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.players (id) on delete restrict,
  season_id uuid not null references public.seasons (id) on delete restrict,
  club_id uuid not null references public.clubs (id) on delete restrict,
  role_fantasy public.fantasy_role not null,
  quotation_initial numeric(10, 2) not null default 0 check (quotation_initial >= 0),
  quotation_current numeric(10, 2) not null default 0 check (quotation_current >= 0),
  status text not null default 'active' check (
    status in ('active', 'injured', 'suspended', 'unavailable')
  ),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (player_id, season_id)
);