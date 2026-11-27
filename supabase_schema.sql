-- TRUST IN MED — FIXED Supabase schema (security fix, 2026-11-28)
-- CHANGES vs the original supabase_schema.sql:
--   1. REMOVED the critical flaw: policies "Public write workspace" and
--      "Public write vault" allowed ANYONE on the internet (no login)
--      to insert/update/delete ALL rows (using (true) with check (true)).
--   2. Writes now require a signed-in user (auth.uid() is not null).
--   3. Reads are ALSO restricted to signed-in users: the workspace
--      payload can contain access codes (see schema title), and the
--      old public-read policy exposed them to anyone, making the
--      codes useless. Students must sign in to sync.
--   4. Storage: do NOT make the bucket fully public for writes.
--      Create bucket "trustinmed-vault" as Public READ only, and add
--      Storage policies so uploads/deletes require authentication.
-- NOTE: This schema has no roles table, so "any signed-in user can
-- write" is the strongest rule it can express. For admin-only writes,
-- migrate to the trustmed-academy schema (profiles + is_admin_or_above())
-- and replace auth.uid() checks with that helper.
-- Run in Supabase Dashboard > SQL Editor. Safe to re-run.

create table if not exists public.tim_workspace_state (
  id text primary key default 'batch_11_official',
  payload jsonb not null,
  updated_by text,
  updated_at timestamptz not null default now()
);

create table if not exists public.tim_vault_files (
  id text primary key,
  title text not null,
  file_name text not null,
  subject text not null,
  category text not null,
  lec_num text,
  doctor text,
  author text,
  batch text not null,
  description text,
  high_yield boolean default false,
  size_bytes bigint default 0,
  version int default 1,
  storage_path text,
  public_url text,
  uploaded_at timestamptz default now()
);

alter table public.tim_workspace_state enable row level security;
alter table public.tim_vault_files enable row level security;

-- Drop the old (insecure) policies if they exist
drop policy if exists "Public read workspace" on public.tim_workspace_state;
drop policy if exists "Public write workspace" on public.tim_workspace_state;
drop policy if exists "Public read vault" on public.tim_vault_files;
drop policy if exists "Public write vault" on public.tim_vault_files;
drop policy if exists "Authenticated write workspace" on public.tim_workspace_state;
drop policy if exists "Authenticated write vault" on public.tim_vault_files;

-- Read: signed-in users ONLY (was public — exposed access codes)
create policy "Public read workspace"
  on public.tim_workspace_state for select using (auth.uid() is not null);
create policy "Public read vault"
  on public.tim_vault_files for select using (auth.uid() is not null);

-- Writes: signed-in users ONLY (was: anyone, using (true))
create policy "Authenticated write workspace"
  on public.tim_workspace_state for all
  using (auth.uid() is not null)
  with check (auth.uid() is not null);
create policy "Authenticated write vault"
  on public.tim_vault_files for all
  using (auth.uid() is not null)
  with check (auth.uid() is not null);
