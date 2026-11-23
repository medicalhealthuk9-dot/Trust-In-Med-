-- TRUST IN MED Full Cloud Sync Schema (Schedules + Batch Vault + Access Codes)
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

create policy "Public read workspace" on public.tim_workspace_state for select using (true);
create policy "Public write workspace" on public.tim_workspace_state for all using (true) with check (true);
create policy "Public read vault" on public.tim_vault_files for select using (true);
create policy "Public write vault" on public.tim_vault_files for all using (true) with check (true);
-- Remember to create a Public Storage Bucket named: trustinmed-vault
