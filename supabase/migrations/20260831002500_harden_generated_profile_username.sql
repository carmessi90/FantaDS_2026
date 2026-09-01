create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    'u_' || left(replace(new.id::text, '-', ''), 30)
  );

  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public;