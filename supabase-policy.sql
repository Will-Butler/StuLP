-- ============================================================
--  Emails table RLS policy
--  Run in Supabase -> SQL Editor -> New query -> Run.
--
--  Table: public."Emails"  (id, created_at, email)
--  NOTE: the table was created with a capital E, so the name is
--  case-sensitive and must be double-quoted everywhere in SQL.
--
--  Goal: the public (anon) key can INSERT emails only.
--  It CANNOT read, update, or delete rows. With RLS on and no
--  SELECT/UPDATE/DELETE policy, those actions are denied by default.
--  You still see every row in the Dashboard (service role bypasses RLS).
-- ============================================================

-- 1. Turn on Row Level Security for the table.
alter table public."Emails" enable row level security;

-- 2. Allow anonymous + logged-in visitors to add themselves.
--    The WITH CHECK runs on the row being inserted:
--    require a non-empty, roughly-valid email address.
create policy "Public can join waitlist"
  on public."Emails"
  for insert
  to anon, authenticated
  with check (
    email is not null
    and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'
  );

-- 3. (Intentional) No SELECT / UPDATE / DELETE policies exist,
--    so anon and authenticated users cannot read or change the list.
--    Read it yourself in the Dashboard, or from a trusted backend
--    using the service_role key (never ship that key to the browser).

-- ------------------------------------------------------------
--  Optional hardening (uncomment if you want them):
--
--  -- Reject duplicate signups at the database level:
--  -- alter table public."Emails"
--  --   add constraint emails_email_unique unique (email);
--
--  -- Store a lowercase copy so 'A@x.com' and 'a@x.com' don't both get in
--  -- (pair this with the unique constraint above):
--  -- create or replace function public.lowercase_email()
--  -- returns trigger language plpgsql as $$
--  -- begin
--  --   new.email := lower(trim(new.email));
--  --   return new;
--  -- end $$;
--  -- create trigger emails_lowercase_email
--  --   before insert on public."Emails"
--  --   for each row execute function public.lowercase_email();
-- ------------------------------------------------------------
