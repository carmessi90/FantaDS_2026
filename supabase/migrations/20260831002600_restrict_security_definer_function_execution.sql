revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.validate_auction_bid_v2() from public, anon, authenticated;
revoke all on function public.is_auction_participant(uuid) from public, anon;
revoke all on function public.is_auction_admin(uuid) from public, anon;
revoke all on function public.is_auction_owner(uuid) from public, anon;

grant execute on function public.is_auction_participant(uuid) to authenticated;
grant execute on function public.is_auction_admin(uuid) to authenticated;
grant execute on function public.is_auction_owner(uuid) to authenticated;