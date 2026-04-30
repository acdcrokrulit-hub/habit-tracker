-- Check and fix habits table columns
-- Run this in Supabase SQL Editor

-- Create habits table if not exists with correct lowercase columns
create table if not exists habits (
  id text primary key,
  userid text not null,
  title text not null,
  description text,
  color text,
  icon text,
  completeddates jsonb,
  createdat timestamptz,
  streak int,
  hasprogress boolean,
  targetvalue numeric,
  unit text,
  progresshistory jsonb
);

-- Enable RLS
alter table habits enable row level security;

-- RLS Policies
drop policy if exists "Users can view own habits" on habits;
create policy "Users can view own habits"
on habits for select
using (auth.uid()::text = userid);

drop policy if exists "Users can insert own habits" on habits;
create policy "Users can insert own habits"
on habits for insert
with check (auth.uid()::text = userid);

drop policy if exists "Users can update own habits" on habits;
create policy "Users can update own habits"
on habits for update
using (auth.uid()::text = userid);

drop policy if exists "Users can delete own habits" on habits;
create policy "Users can delete own habits"
on habits for delete
using (auth.uid()::text = userid);

-- Indexes
create index if not exists idx_habits_userid on habits(userid);
create index if not exists idx_habits_createdat on habits(createdat);
