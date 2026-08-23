-- ============================================================
-- Shri Sai Dwar Housing Group — Supabase Schema
-- Run this once in Supabase Dashboard → SQL Editor → Run
-- ============================================================

create extension if not exists "uuid-ossp";

-- ============================================================
-- PROPERTIES
-- ============================================================
create table if not exists properties (
  id            uuid default uuid_generate_v4() primary key,
  title         text not null,
  listing_type  text not null,        -- 'sale' | 'rent'
  property_type text,                 -- 'Apartment' | 'Villa' | 'Plot' | 'Commercial'
  price         numeric not null,
  city          text,
  locality      text,
  bhk           integer,
  bathrooms     integer,
  area          integer,
  description   text,
  amenities     jsonb default '[]',
  tag           text default 'none',  -- 'none' | 'trending' | 'new-launch' | 'best-value'
  images        jsonb default '[]',
  video_url     text,
  created_at    timestamptz default now()
);

-- ============================================================
-- HIGHLIGHTS ("Why invest with us" cards)
-- ============================================================
create table if not exists highlights (
  id          uuid default uuid_generate_v4() primary key,
  title       text not null,
  description text,
  sort_order  integer default 0
);

-- ============================================================
-- TEAM MEMBERS
-- ============================================================
create table if not exists team_members (
  id         uuid default uuid_generate_v4() primary key,
  name       text not null,
  role       text,
  bio        text,
  photo_url  text,
  sort_order integer default 0
);

-- ============================================================
-- LEADS (enquiries / consultation / sell requests)
-- ============================================================
create table if not exists leads (
  id          uuid default uuid_generate_v4() primary key,
  type        text not null,          -- 'enquiry' | 'consultation' | 'sell-inquiry'
  name        text not null,
  phone       text not null,
  email       text,
  message     text,
  ref         text,
  property_id uuid references properties(id) on delete set null,
  created_at  timestamptz default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table properties   enable row level security;
alter table highlights    enable row level security;
alter table team_members  enable row level security;
alter table leads         enable row level security;

-- Public (anonymous) can READ properties, highlights, team_members
create policy "public read properties"    on properties   for select using (true);
create policy "public read highlights"    on highlights   for select using (true);
create policy "public read team_members"  on team_members for select using (true);

-- Public can INSERT leads (submit enquiry forms) but never read/update/delete them
create policy "public insert leads" on leads for insert with check (true);

-- Logged-in admin (any authenticated user) can do everything
create policy "admin all properties"   on properties   for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin all highlights"   on highlights   for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin all team_members" on team_members for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin all leads"        on leads        for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ============================================================
-- SEED: default highlight cards (so the Highlights admin tab has rows to edit)
-- Skipped automatically if you re-run this script (won't duplicate)
-- ============================================================
insert into highlights (title, description, sort_order)
select * from (values
  ('Verified & Legally Vetted', 'Every property is checked for clear title and paperwork before it goes live.', 1),
  ('Dedicated Relationship Manager', 'One point of contact from first visit to registry.', 2),
  ('Transparent Pricing', 'No hidden charges, no last-minute surprises.', 3),
  ('End-to-End Support', 'Home loans, documentation, and possession — we stay with you.', 4)
) as v(title, description, sort_order)
where not exists (select 1 from highlights);
