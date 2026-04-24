-- Supabase schema for Habit Tracker
-- Выполните этот запрос в SQL-редакторе Supabase

-- Таблица для привычек
create table habits (
  id text primary key,
  userId text not null,
  title text not null,
  description text,
  color text,
  icon text,
  completedDates jsonb,
  createdAt timestamptz,
  streak int,
  hasProgress boolean,
  targetValue numeric,
  unit text,
  progressHistory jsonb
);

-- Таблица для настроек пользователя
create table user_settings (
  userId text primary key,
  userName text not null default 'Пользователь',
  profilePhotoPath text,
  notificationsEnabled boolean default true,
  isDarkTheme boolean default true,
  language text default 'ru',
  reminderTime text default '20:00',
  createdAt timestamptz default now(),
  updatedAt timestamptz default now()
);

-- Индексы для улучшения производительности
create index if not exists idx_habits_userId on habits(userId);
create index if not exists idx_habits_createdAt on habits(createdAt);

-- Включаем Row Level Security
alter table habits enable row level security;
alter table user_settings enable row level security;

-- Политики для habits
drop policy if exists "Users can view own habits" on habits;
create policy "Users can view own habits"
on habits for select
using (auth.uid()::text = userId);

drop policy if exists "Users can insert own habits" on habits;
create policy "Users can insert own habits"
on habits for insert
with check (auth.uid()::text = userId);

drop policy if exists "Users can update own habits" on habits;
create policy "Users can update own habits"
on habits for update
using (auth.uid()::text = userId);

drop policy if exists "Users can delete own habits" on habits;
create policy "Users can delete own habits"
on habits for delete
using (auth.uid()::text = userId);

-- Политики для user_settings
drop policy if exists "Users can view own settings" on user_settings;
create policy "Users can view own settings"
on user_settings for select
using (auth.uid()::text = userId);

drop policy if exists "Users can insert own settings" on user_settings;
create policy "Users can insert own settings"
on user_settings for insert
with check (auth.uid()::text = userId);

drop policy if exists "Users can update own settings" on user_settings;
create policy "Users can update own settings"
on user_settings for update
using (auth.uid()::text = userId);

-- Функция для автоматического обновления updatedAt
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updatedAt = now();
  return new;
end;
$$ language plpgsql;

-- Триггер для обновления updatedAt
drop trigger if exists update_user_settings_updatedAt on user_settings;
create trigger update_user_settings_updatedAt
  before update on user_settings
  for each row
  execute function update_updated_at_column();