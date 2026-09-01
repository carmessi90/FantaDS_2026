create table public.lineup_sources (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text,
  requires_consent boolean not null default true,
  reliability_score numeric(5, 2) check (
    reliability_score is null or reliability_score between 0 and 100
  ),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (name)
);

create table public.fixtures (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons (id) on delete restrict,
  matchday integer not null check (matchday > 0),
  home_club_id uuid not null references public.clubs (id) on delete restrict,
  away_club_id uuid not null references public.clubs (id) on delete restrict,
  kickoff_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (season_id, matchday, home_club_id, away_club_id),
  check (home_club_id <> away_club_id)
);

create table public.predicted_lineups (
  id uuid primary key default gen_random_uuid(),
  fixture_id uuid not null references public.fixtures (id) on delete restrict,
  club_id uuid not null references public.clubs (id) on delete restrict,
  source_id uuid not null references public.lineup_sources (id) on delete restrict,
  formation_module text,
  confidence_score numeric(5, 2) check (
    confidence_score is null or confidence_score between 0 and 100
  ),
  published_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (fixture_id, club_id, source_id)
);

create table public.predicted_lineup_players (
  id uuid primary key default gen_random_uuid(),
  predicted_lineup_id uuid not null references public.predicted_lineups (id) on delete cascade,
  player_id uuid not null references public.players (id) on delete restrict,
  tactical_position_id uuid not null references public.tactical_positions (id) on delete restrict,
  starting_probability numeric(5, 2) not null check (
    starting_probability between 0 and 100
  ),
  lineup_order integer not null check (lineup_order between 1 and 11),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (predicted_lineup_id, player_id),
  unique (predicted_lineup_id, lineup_order)
);