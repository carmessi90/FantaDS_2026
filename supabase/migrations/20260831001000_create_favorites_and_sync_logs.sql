create table public.player_favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  player_id uuid not null references public.players (id) on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, player_id)
);

create table public.data_sync_logs (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  sync_type text not null,
  status text not null check (status in ('success', 'failed', 'partial')),
  error_message text,
  started_at timestamptz not null default timezone('utc', now()),
  finished_at timestamptz,
  check (finished_at is null or finished_at >= started_at)
);