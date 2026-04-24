# Подключение Supabase к проекту Habit Tracker

## Шаг 1: Создание проекта в Supabase

1. Перейдите на [https://supabase.com](https://supabase.com) и войдите в аккаунт
2. Нажмите "New project"
3. Заполните форму:
   - Organization: выберите свою организацию
   - Project name: например, "habit-tracker"
   - Database password: установите надежный пароль
   - Region: выберите ближайший к вам регион
4. Нажмите "Create new project" и дождитесь завершения создания

## Шаг 2: Получение credentials

1. После создания проекта перейдите в настройки проекта (Settings)
2. Выберите раздел "API"
3. Скопируйте два значения:
   - **URL** (например, `https://xyzcompany.supabase.co`)
   - **anon public** (anon key)

## Шаг 3: Настройка проекта Flutter

1. Откройте файл `lib/main.dart`
2. Замените placeholder значения на реальные:
   ```dart
   await SupabaseService.initialize(
     url: 'ВАШ_РЕАЛЬНЫЙ_URL', // Например: https://xyzcompany.supabase.co
     anonKey: 'ВАШ_РЕАЛЬНЫЙ_ANON_KEY',
   );
   ```

## Шаг 4: Настройка базы данных

1. В проекте Supabase перейдите в раздел "SQL Editor"
2. Создайте новый запрос
3. Скопируйте содержимое файла `supabase_schema.sql`:
   ```sql
   -- Supabase schema for Habit Tracker
   -- Выполните этот запрос в SQL-редакторе Supabase

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
   ```
4. Нажмите "Run" чтобы выполнить запрос и создать таблицу

## Шаг 5: Безопасность (RLS policies)

Для обеспечения безопасности данных необходимо настроить Row Level Security (RLS) policies:

1. В SQL Editor выполните следующие команды:
    ```sql
    -- Enable RLS on habits table
    alter table habits enable row level security;

    -- Policy: Users can only see their own habits
    drop policy if exists "Users can view own habits" on habits;
    create policy "Users can view own habits"
    on habits for select
    using (auth.uid()::text = userId);

    -- Policy: Users can insert their own habits
    drop policy if exists "Users can insert own habits" on habits;
    create policy "Users can insert own habits"
    on habits for insert
    with check (auth.uid()::text = userId);

    -- Policy: Users can update their own habits
    drop policy if exists "Users can update own habits" on habits;
    create policy "Users can update own habits"
    on habits for update
    using (auth.uid()::text = userId);

    -- Policy: Users can delete their own habits
    drop policy if exists "Users can delete own habits" on habits;
    create policy "Users can delete own habits"
    on habits for delete
    using (auth.uid()::text = userId);
    ```

> **Примечание**: Мы используем `DROP POLICY IF EXISTS` перед созданием каждой политики, чтобы избежать ошибки "policy already exists", если вы запускаете этот скрипт повторно или политики уже были созданы ранее.

## Шаг 6: Использование SupabaseService в приложении

Существующий сервис `SupabaseService` предоставляет следующие методы:

### Аутентификация
```dart
// Регистрация
final response = await SupabaseService.instance.signUp(email, password);

// Вход
final response = await SupabaseService.instance.signIn(email, password);

// Выход
await SupabaseService.instance.signOut();

// Получение текущего пользователя
final user = SupabaseService.instance.getCurrentUser();
```

### Работа с привычками
```dart
// Получение привычек пользователя
final habits = await SupabaseService.instance.fetchHabits(userId);

// Сохранение/обновление привычек
await SupabaseService.instance.upsertHabits(habits, userId);

// Удаление привычки
await SupabaseService.instance.deleteHabit(habitId, userId);
```

## Шаг 7: Переменные окружения (рекомендуется для production)

Для повышения безопасности рекомендуется использовать переменные окружения вместо хранения ключей в коде:

1. Создайте файл `.env` в корне проекта:
   ```
   SUPABASE_URL=ваш_реальный_url
   SUPABASE_ANON_KEY=ваш_реальный_anon_key
   ```

2. Добавьте в `.gitignore`:
   ```
   .env
   ```

3. Установите пакет `flutter_dotenv`:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

4. Измените `lib/main.dart`:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await dotenv.load(fileName: ".env");
     await NotificationService.instance.init();
     await SupabaseService.initialize(
       url: dotenv.env['SUPABASE_URL']!,
       anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
     );
     runApp(const MyApp());
   }
   ```

## Шаг 8: Тестирование подключения

1. Запустите приложение: `flutter run`
2. Приложение должно попытаться выполнить автоматический вход с учетными данными:
   - email: `mukhanovr@icloud.com`
   - password: `mukhanov06`
3. Если учетная запись не существует, приложение покажет экран входа/регистрации

## Устранение неполадок

### Ошибка "Failed to connect to Supabase"
- Проверьте правильность URL и anon key
- Убедитесь, что ваш проект Supabase активен (не приостановлен)
- Проверьте подключение к интернету

### Ошибка аутентификации
- Убедитесь, что вы используете правильные email и password
- Проверьте, что в Supabase включена аутентификация по email/password
- В настройках проекта Supabase перейдите в Authentication → Settings и убедитесь, что включен "Email" провайдер

### Ошибка при работе с базой данных
- Проверьте, что таблица `habits` создана правильно
- Убедитесь, что RLS policies настроены корректно
- Проверьте, что пользователь авторизован перед выполнением запросов к БД

## Дополнительные ресурсы

- [Supabase Flutter Documentation](https://supabase.com/docs/guides/flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter Environment Variables](https://flutter.dev/docs/development/tools/env)