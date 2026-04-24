-- Fix RLS policies for habits table
-- Выполните этот скрипт в SQL Editor Supabase

-- Enable RLS on habits table
alter table habits enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Users can view own habits" on habits;
drop policy if exists "Users can insert own habits" on habits;
drop policy if exists "Users can update own habits" on habits;
drop policy if exists "Users can delete own habits" on habits;

-- Create new policies
-- Policy: Users can only see their own habits
create policy "Users can view own habits"
on habits for select
using (auth.uid()::text = userId);

-- Policy: Users can insert their own habits
create policy "Users can insert own habits"
on habits for insert
with check (auth.uid()::text = userId);

-- Policy: Users can update their own habits
create policy "Users can update own habits"
on habits for update
using (auth.uid()::text = userId);

-- Policy: Users can delete their own habits
create policy "Users can delete own habits"
on habits for delete
using (auth.uid()::text = userId);