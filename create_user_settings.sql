-- Supabase schema - Create user_settings table
-- Run this in Supabase SQL Editor

-- Create user_settings table with lowercase columns
create table if not exists user_settings (
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

-- Enable RLS
alter table user_settings enable row level security;

-- RLS Policies
drop policy if exists "Users can view own settings" on user_settings;
create policy "Users can view own settings"
on user_settings for select
using (auth.uid()::text = userid);

drop policy if exists "Users can insert own settings" on user_settings;
create policy "Users can insert own settings"
on user_settings for insert
with check (auth.uid()::text = userid);

drop policy if exists "Users can update own settings" on user_settings;
create policy "Users can update own settings"
on user_settings for update
using (auth.uid()::text = userid);

-- Trigger for updatedAt
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updatedat = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_user_settings_updatedAt on user_settings;
create trigger update_user_settings_updatedAt
  before update on user_settings
  for each row
  execute function update_updated_at_column();
