create function public.is_auction_owner(target_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.auction_rooms room
    where room.id = target_room_id
      and room.owner_id = auth.uid()
  );
$$;

create function public.validate_auction_participant()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  room_owner_id uuid;
begin
  if tg_op = 'UPDATE' and (
    new.room_id is distinct from old.room_id
    or new.user_id is distinct from old.user_id
  ) then
    raise exception 'Participant room and user cannot be changed';
  end if;

  select owner_id into room_owner_id
  from public.auction_rooms
  where id = new.room_id;

  if new.role = 'owner' and new.user_id <> room_owner_id then
    raise exception 'Only the room owner can hold the owner participant role';
  end if;

  return new;
end;
$$;

create unique index auction_participants_one_owner_idx
  on public.auction_participants (room_id)
  where role = 'owner';

create trigger validate_auction_participant_trigger
before insert or update on public.auction_participants
for each row execute function public.validate_auction_participant();

drop policy "participants_manage_admin" on public.auction_participants;

create policy "participants_manage_owner"
on public.auction_participants
for all
to authenticated
using (public.is_auction_owner(room_id))
with check (public.is_auction_owner(room_id));

revoke execute on function public.is_auction_participant(uuid) from public;
revoke execute on function public.is_auction_admin(uuid) from public;
revoke execute on function public.is_auction_owner(uuid) from public;
grant execute on function public.is_auction_participant(uuid) to authenticated;
grant execute on function public.is_auction_admin(uuid) to authenticated;
grant execute on function public.is_auction_owner(uuid) to authenticated;