create type public.fantasy_role as enum ('P', 'D', 'C', 'A');
create type public.auction_room_status as enum (
  'draft',
  'active',
  'paused',
  'completed',
  'cancelled'
);

create table public.seasons (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  is_current boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (label)
);

create table public.clubs (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  short_name text not null,
  logo_url text,
  provider text,
  provider_club_id text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (name),
  unique (provider, provider_club_id),
  check (
    (provider is null and provider_club_id is null)
    or (provider is not null and provider_club_id is not null)
  )
);

create table public.tactical_positions (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  tactical_group text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (code)
);