create table public.auction_invites (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.auction_rooms (id) on delete restrict,
  code text not null,
  created_by uuid not null references public.profiles (id) on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  expires_at timestamptz,
  max_uses integer not null default 1 check (max_uses > 0),
  uses integer not null default 0 check (uses >= 0 and uses <= max_uses),
  is_active boolean not null default true,
  unique (code)
);

create index auction_invites_room_active_idx
  on public.auction_invites (room_id, is_active);

alter table public.auction_invites enable row level security;