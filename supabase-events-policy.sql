-- ============================================================
--  Events table + RLS policy  (click analytics)
--  Run in Supabase -> SQL Editor -> New query -> Run.
--
--  Table: public."Events"  (id, created_at, event, meta)
--  Mirrors the Emails pattern: the public (anon) key can INSERT
--  events only. It CANNOT read, update, or delete rows. You read
--  the numbers yourself in the Dashboard / SQL editor (service
--  role bypasses RLS).
-- ============================================================

-- 1. Create the table (safe to re-run).
create table if not exists public."Events" (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  event      text not null,
  meta       jsonb
);

-- 2. Turn on Row Level Security.
alter table public."Events" enable row level security;

-- 3. Allow anonymous + logged-in visitors to log a known event.
--    The WITH CHECK whitelists event names so the public key can't
--    stuff arbitrary junk into the table.
create policy "Public can log events"
  on public."Events"
  for insert
  to anon, authenticated
  with check (
    event in (
      'download_click',
      'waitlist_submit',
      'waitlist_success'
    )
  );

-- 4. (Intentional) No SELECT / UPDATE / DELETE policies exist, so
--    anon and authenticated users cannot read or change the log.
--    Read it yourself in the Dashboard, or from a trusted backend
--    using the service_role key (never ship that key to the browser).

-- ------------------------------------------------------------
--  Handy queries once data is flowing (run as service role in the
--  SQL editor):
--
--  -- Totals per event:
--  --   select event, count(*) from public."Events" group by event;
--
--  -- Clicks per day:
--  --   select date_trunc('day', created_at) as day, event, count(*)
--  --   from public."Events" group by day, event order by day desc;
-- ------------------------------------------------------------
