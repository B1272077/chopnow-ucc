-- =========================================================================
-- CHOPNOW UCC (GROUP 36) — SUPABASE POSTGRESQL SCHEMA & RLS SECURITY
-- Paste and run this entire script in your Supabase Dashboard -> SQL Editor
-- =========================================================================

-- 1. VENDORS TABLE
create table if not exists public.vendors (
  id text primary key,
  passcode text not null,
  name text not null,
  zone text not null,
  location text not null,
  phone text not null default '0539262509',
  is_open boolean not null default true,
  base_ids text[] not null
);

-- 2. BASE MEALS TABLE
create table if not exists public.base_meals (
  id text primary key,
  name text not null,
  price numeric(10,2) not null,
  in_stock boolean not null default true
);

-- 3. ADDON ITEMS TABLE
create table if not exists public.addon_items (
  id text primary key,
  name text not null,
  price numeric(10,2) not null,
  icon text not null default '🍽️',
  in_stock boolean not null default true
);

-- 4. ORDERS TABLE
create table if not exists public.orders (
  id text primary key,
  student_index text not null,
  vendor_id text references public.vendors(id),
  vendor_name text not null,
  base_name text not null,
  addons_text text not null,
  price numeric(10,2) not null,
  network text not null,
  slot text not null,
  token text unique not null,
  status text not null default 'CONFIRMED',
  created_at timestamptz default now()
);

-- 5. MAKER-CHECKER PENDING VENDOR EDITS TABLE
create table if not exists public.pending_vendor_edits (
  id text primary key,
  vendor_id text references public.vendors(id),
  vendor_name text not null,
  edit_type text not null, -- 'PRICE_CHANGE' or 'NEW_ITEM'
  target_type text not null, -- 'base' or 'addon'
  target_id text,
  item_name text not null,
  old_price numeric(10,2),
  new_price numeric(10,2) not null,
  status text not null default 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
  reviewed_by text,
  created_at timestamptz default now()
);

-- 6. STUDENT FEEDBACKS TABLE
create table if not exists public.feedbacks (
  id text primary key,
  student_index text not null,
  rating text not null,
  comment text not null,
  status text not null default 'OPEN',
  created_at timestamptz default now()
);

-- 7. MASTER SECURITY AUDIT LOGS
create table if not exists public.audit_logs (
  id bigserial primary key,
  event_text text not null,
  created_at timestamptz default now()
);

-- SEED THE 5 CAMPUS VENDORS
insert into public.vendors (id, passcode, name, zone, location, phone, is_open, base_ids) values
  ('SALAMATU-01', '1122', 'Salamatu''s Special Waakye', 'CODE Market', 'CODE Market — Closer to NLT, CODE & CALC (~5 min walk)', '0539262509', true, array['b_waakye']),
  ('BECKY-02', '2233', 'Becky''s Waakye', 'CODE Market', 'CODE Market — Closer to NLT, CODE & CALC (~5 min walk)', '0539262509', true, array['b_waakye']),
  ('AMA-03', '3344', 'Auntie Ama''s Jollof & Fried Rice', 'Science Market', 'Science Market — Closer to LT & Science Complex (~10 min walk)', '0539262509', true, array['b_jollof', 'b_friedrice']),
  ('ADWOA-04', '4455', 'Auntie Adwoa''s Classic Gobɛ', 'Science Market', 'Science Market — Closer to LT & Science Complex (~10 min walk)', '0539262509', true, array['b_gobe']),
  ('JANE-05', '5566', 'Madam Jane''s Special Waakye', 'Ayensu Roadside', 'Ayensu Roadside — Closer to SWLT & near Ayensu Plaza (~10 min walk)', '0539262509', true, array['b_waakye'])
on conflict (id) do nothing;

-- SEED BASE MEALS
insert into public.base_meals (id, name, price, in_stock) values
  ('b_waakye', 'Base Waakye + Stew + Shito', 10.00, true),
  ('b_jollof', 'Base Jollof Rice + Sauce', 12.00, true),
  ('b_gobe', 'Base Gobɛ (Beans + Gari + Oil)', 10.00, true),
  ('b_friedrice', 'Base Fried Rice', 15.00, true)
on conflict (id) do nothing;

-- SEED 9 CUSTOM ADD-ONS
insert into public.addon_items (id, name, price, icon, in_stock) values
  ('a_wele', 'Wele', 5.00, '🥩', true),
  ('a_egg', 'Boiled Egg', 3.50, '🥚', true),
  ('a_plantain', 'Fried Ripe Plantain', 2.00, '🍌', true),
  ('a_fish', 'Fried Fish / Tilapia', 10.00, '🐟', true),
  ('a_chicken', 'Fried Chicken', 10.00, '🍗', true),
  ('a_sausage', 'Sausage', 3.00, '🌭', true),
  ('a_spaghetti', 'Spaghetti', 2.00, '🍝', true),
  ('a_gari', 'Gari', 2.00, '🥣', true),
  ('a_salad', 'Salad', 2.00, '🥗', true)
on conflict (id) do nothing;

-- ENABLE ROW-LEVEL SECURITY (RLS) ON ALL TABLES
alter table public.vendors enable row level security;
alter table public.base_meals enable row level security;
alter table public.addon_items enable row level security;
alter table public.orders enable row level security;
alter table public.pending_vendor_edits enable row level security;
alter table public.feedbacks enable row level security;
alter table public.audit_logs enable row level security;

-- DEMO POLICIES (Allows authenticated/anon frontend demo access; tighten per JWT in production)
create policy "Allow public read vendors" on public.vendors for select using (true);
create policy "Allow public update vendors" on public.vendors for update using (true);
create policy "Allow public read base_meals" on public.base_meals for select using (true);
create policy "Allow public write base_meals" on public.base_meals for all using (true);
create policy "Allow public read addon_items" on public.addon_items for select using (true);
create policy "Allow public write addon_items" on public.addon_items for all using (true);
create policy "Allow public access orders" on public.orders for all using (true);
create policy "Allow public access pending_edits" on public.pending_vendor_edits for all using (true);
create policy "Allow public access feedbacks" on public.feedbacks for all using (true);
create policy "Allow public access audit_logs" on public.audit_logs for all using (true);
