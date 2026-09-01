create function public.validate_auction_team_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  room_budget numeric(10, 2);
begin
  if tg_op = 'UPDATE' and (
    new.room_id is distinct from old.room_id
    or new.participant_id is distinct from old.participant_id
    or new.budget_total is distinct from old.budget_total
    or new.budget_spent is distinct from old.budget_spent
  ) then
    raise exception 'Team room, participant and budgets cannot be changed directly';
  end if;

  if tg_op = 'INSERT' then
    select total_budget into room_budget
    from public.auction_rooms
    where id = new.room_id;

    if new.budget_total <> room_budget or new.budget_spent <> 0 then
      raise exception 'A new team must use the room budget and start with no spend';
    end if;
  end if;

  return new;
end;
$$;

create trigger validate_auction_team_mutation_trigger
before insert or update on public.auction_teams
for each row execute function public.validate_auction_team_mutation();

drop policy "teams_manage_admin" on public.auction_teams;

create policy "teams_insert_own"
on public.auction_teams
for insert
to authenticated
with check (
  exists (
    select 1
    from public.auction_participants participant
    where participant.id = auction_teams.participant_id
      and participant.room_id = auction_teams.room_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
  )
);

create policy "teams_update_own"
on public.auction_teams
for update
to authenticated
using (
  exists (
    select 1
    from public.auction_participants participant
    where participant.id = auction_teams.participant_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
  )
)
with check (
  exists (
    select 1
    from public.auction_participants participant
    where participant.id = auction_teams.participant_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
  )
);

create policy "teams_delete_own"
on public.auction_teams
for delete
to authenticated
using (
  exists (
    select 1
    from public.auction_participants participant
    where participant.id = auction_teams.participant_id
      and participant.user_id = auth.uid()
      and participant.status = 'joined'
  )
);