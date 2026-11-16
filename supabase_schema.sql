-- =========================================================================
-- CHOPNOW UCC (GROUP 36) — SUPABASE POSTGRESQL SCHEMA & RLS SECURITY
-- =========================================================================

create table if not exists public.vendors (
  id text primary key,
  passcode text not null,
  name text not null,
  zone text not null,
  location text not null,
  phone text not null default '0539262509',
  is_open boolean not null default true,
  base_ids text[] not null,
  menu_data jsonb
);

create table if not exists public.base_meals (
  id text primary key,
  name text not null,
  price numeric(10,2) not null,
  in_stock boolean not null default true
);

create table if not exists public.addon_items (
  id text primary key,
  name text not null,
  price numeric(10,2) not null,
  icon text not null default '🍽️',
  in_stock boolean not null default true
);

create table if not exists public.orders (
  id text primary key,
  student_index text not null,
  vendor_id text references public.vendors(id) on delete set null,
  vendor_name text not null,
  base_name text not null,
  addons_text text not null,
  price numeric(10,2) not null,
  network text not null,
  slot_key text default 'slot1',
  slot text not null,
  token text unique not null,
  status text not null default 'CONFIRMED',
  created_at timestamptz default now()
);

create table if not exists public.pending_vendor_edits (
  id text primary key,
  vendor_id text references public.vendors(id) on delete cascade,
  vendor_name text not null,
  edit_type text not null,
  target_type text not null,
  target_id text,
  item_name text not null,
  old_price numeric(10,2),
  new_price numeric(10,2) not null,
  status text not null default 'PENDING',
  reviewed_by text,
  created_at timestamptz default now()
);

create table if not exists public.feedbacks (
  id text primary key,
  student_index text not null,
  rating text not null,
  comment text not null,
  status text not null default 'OPEN',
  created_at timestamptz default now()
);

create table if not exists public.audit_logs (
  id bigserial primary key,
  event_text text not null,
  created_at timestamptz default now()
);

alter table public.vendors add column if not exists menu_data jsonb;
alter table public.orders add column if not exists slot_key text default 'slot1';

alter table public.vendors enable row level security;
alter table public.base_meals enable row level security;
alter table public.addon_items enable row level security;
alter table public.orders enable row level security;
alter table public.pending_vendor_edits enable row level security;
alter table public.feedbacks enable row level security;
alter table public.audit_logs enable row level security;

drop policy if exists "Allow public all vendors" on public.vendors;
create policy "Allow public all vendors" on public.vendors for all using (true) with check (true);
create policy "Allow public all base_meals" on public.base_meals for all using (true) with check (true);
create policy "Allow public all addon_items" on public.addon_items for all using (true) with check (true);
create policy "Allow public all orders" on public.orders for all using (true) with check (true);
create policy "Allow public all pending_edits" on public.pending_vendor_edits for all using (true) with check (true);
create policy "Allow public all feedbacks" on public.feedbacks for all using (true) with check (true);
create policy "Allow public all audit_logs" on public.audit_logs for all using (true) with check (true);
