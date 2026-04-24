# 🎯 Habit Tracker - Трекер Привычек

Красивое и функциональное мобильное приложение для отслеживания привычек, созданное на **Flutter**.

## ✨ Особенности

- 🎨 **Современный дизайн** - градиенты, анимации, тёмная тема
- 📊 **Статистика** - отслеживайте прогресс выполнения привычек
- 🔥 **Серии** - мотивирующие streak-счетчики
- 🏆 **Достижения** - система наград за успехи
- 📱 **Кроссплатформенность** - работает на iOS и Android
- 💾 **Сохранение данных** - локальное хранилище через SharedPreferences

## 🚀 Установка

### Требования
- Flutter SDK 3.0 или выше
- Dart 3.0 или выше

### Шаги установки

1. Клонируйте репозиторий:
```bash
git clone https://github.com/acdcrokrulit-hub/habit-tracker.git
cd habit-tracker
```

2. Установите зависимости:
```bash
flutter pub get
```

3. Запустите приложение:

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Windows:**
```bash
flutter run -d windows
```

**Android/iOS (эмулятор):**
```bash
flutter run
```

## 📸 Скриншоты

| Главная | Добавление | Статистика |
|---------|------------|------------|
| 📱 Список привычек | ➕ Форма | 📊 Графики |

## 📱 Поддерживаемые платформы

- ✅ **Android** (min SDK 21)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Safari, Edge)
- ✅ **Windows** (10/11)

## 🏗️ Структура проекта

```
lib/
├── main.dart                 # Точка входа и тема приложения
├── models/
│   └── habit.dart           # Модель привычки
├── providers/
│   └── habit_provider.dart  # State management (Provider)
├── screens/
│   ├── home_screen.dart     # Главный экран
│   ├── add_habit_screen.dart # Экран добавления привычки
│   └── stats_screen.dart    # Экран статистики
└── widgets/
    └── habit_card.dart      # Карточка привычки
```

## 🛠️ Используемые технологии

- **Flutter** - фреймворк для кроссплатформенной разработки
- **Provider** - управление состоянием приложения
- **SharedPreferences** - локальное хранилище данных
- **FL Chart** - красивые графики и диаграммы
- **Material Design 3** - современный UI

## 🎨 Цветовая палитра

| Цвет | Hex | Использование |
|------|-----|--------------|
| Primary | `#6C63FF` | Основные элементы |
| Secondary | `#4ECDC4` | Акценты |
| Background | `#0F0F1A` | Фон приложения |
| Surface | `#1A1A2E` | Карточки |

## 📱 Сборка релиза

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 👨‍💻 Автор

**Rinatik**

## 📄 Лицензия

Этот проект создан в образовательных целях.

## � Supabase

Для работы с Supabase нужно создать таблицу `habits` в вашей базе. Вот SQL-запрос, который можно выполнить в SQL-редакторе Supabase:

```sql
create table habits (
  id text primary key,
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

Затем убедитесь, что `lib/main.dart` и `lib/services/supabase_service.dart` подключены к вашему проекту Supabase с правильным URL и `anonKey`.

## �🤝 Вклад

Pull requests приветствуются! Для серьезных изменений, пожалуйста, откройте issue сначала.

---

<div align="center">

</div>
