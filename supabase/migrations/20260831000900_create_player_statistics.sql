create table public.player_statistics (
  id uuid primary key default gen_random_uuid(),
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  matches_played integer not null default 0 check (matches_played >= 0),
  goals integer not null default 0 check (goals >= 0),
  assists integer not null default 0 check (assists >= 0),
  yellow_cards integer not null default 0 check (yellow_cards >= 0),
  red_cards integer not null default 0 check (red_cards >= 0),
  average_vote numeric(5, 2),
  fantavote_average numeric(5, 2),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (player_season_id)
);

create table public.player_market_data (
  id uuid primary key default gen_random_uuid(),
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  source_name text not null,
  quotation_type text not null check (quotation_type in ('initial', 'current')),
  price numeric(10, 2) not null check (price >= 0),
  recorded_at timestamptz not null default timezone('utc', now()),
  unique (player_season_id, source_name, recorded_at, quotation_type)
);

create table public.player_match_statistics (
  id uuid primary key default gen_random_uuid(),
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  fixture_id uuid not null references public.fixtures (id) on delete restrict,
  minutes_played integer not null default 0 check (minutes_played between 0 and 130),
  goals integer not null default 0 check (goals >= 0),
  assists integer not null default 0 check (assists >= 0),
  vote numeric(5, 2),
  bonus_malus numeric(6, 2) not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (player_season_id, fixture_id)
);

create table public.player_advanced_metrics (
  id uuid primary key default gen_random_uuid(),
  player_season_id uuid not null references public.player_season_data (id) on delete restrict,
  fixture_id uuid references public.fixtures (id) on delete restrict,
  provider text not null,
  metric_key text not null,
  metric_value numeric not null,
  raw_payload jsonb,
  recorded_at timestamptz not null default timezone('utc', now()),
  check (raw_payload is null or jsonb_typeof(raw_payload) in ('object', 'array'))
);