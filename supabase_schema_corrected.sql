-- Supabase schema for Habit Tracker
-- Run this in Supabase SQL Editor
-- This will DROP and RECREATE tables - backup your data first!

-- Drop existing objects
drop trigger if exists update_user_settings_updatedAt on user_settings;
drop trigger if exists update_habits_updatedAt on habits;
drop function if exists update_updated_at_column();
drop policy if exists "Users can view own settings" on user_settings;
drop policy if exists "Users can insert own settings" on user_settings;
drop policy if exists "Users can update own settings" on user_settings;
drop policy if exists "Users can view own habits" on habits;
drop policy if exists "Users can insert own habits" on habits;
drop policy if exists "Users can update own habits" on habits;
drop policy if exists "Users can delete own habits" on habits;
drop index if exists idx_habits_userId;
drop index if exists idx_habits_createdAt;
alter table if exists user_settings drop constraint if exists user_settings_pkey;
alter table if exists habits drop constraint if exists habits_pkey;
drop table if exists user_settings;
drop table if exists habits;

-- Create habits table with lowercase column names
create table habits (
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

-- Create user_settings table with lowercase column names
create table user_settings (
  userid text primary key,
  username text not null default 'Пользователь',
  profilephotopath text,
  notificationsenabled boolean default true,
  isdarktheme boolean default true,
  language text default 'ru',
  remindertime text default '20:00',
  createdat timestamptz default now(),
  updatedat timestamptz default now()
);

-- Indexes
create index idx_habits_userid on habits(userid);
create index idx_habits_createdat on habits(createdat);

-- Enable Row Level Security
alter table habits enable row level security;
alter table user_settings enable row level security;

-- Policies for habits (using lowercase column names)
create policy "Users can view own habits"
on habits for select
using (auth.uid()::text = userid);

create policy "Users can insert own habits"
on habits for insert
with check (auth.uid()::text = userid);

create policy "Users can update own habits"
on habits for update
using (auth.uid()::text = userid);

create policy "Users can delete own habits"
on habits for delete
using (auth.uid()::text = userid);

-- Policies for user_settings (using lowercase column names)
create policy "Users can view own settings"
on user_settings for select
using (auth.uid()::text = userid);

create policy "Users can insert own settings"
on user_settings for insert
with check (auth.uid()::text = userid);

create policy "Users can update own settings"
on user_settings for update
using (auth.uid()::text = userid);

-- Function to update updatedAt
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updatedat = now();
  return new;
end;
$$ language plpgsql;

-- Trigger for user_settings
create trigger update_user_settings_updatedAt
  before update on user_settings
  for each row
  execute function update_updated_at_column();

-- Trigger for habits (optional)
create trigger update_habits_updatedAt
  before update on habits
  for each row
  execute function update_updated_at_column();
