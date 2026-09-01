insert into public.tactical_positions (code, name, tactical_group)
values
  ('GK', 'Portiere', 'goalkeeping'),
  ('CB', 'Difensore centrale', 'defence'),
  ('FB', 'Terzino', 'defence'),
  ('WB', 'Esterno a tutta fascia', 'defence'),
  ('DM', 'Mediano', 'midfield'),
  ('CM', 'Centrocampista centrale', 'midfield'),
  ('AM', 'Trequartista', 'midfield'),
  ('WG', 'Ala', 'attack'),
  ('SS', 'Seconda punta', 'attack'),
  ('CF', 'Centravanti', 'attack')
on conflict (code) do nothing;