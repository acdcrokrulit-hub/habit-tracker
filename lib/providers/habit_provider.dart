import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  String? _userId;
  String _userName = 'Пользователь';
  String? _profilePhotoPath;
  bool _notificationsEnabled = true;
  bool _isDarkTheme = true;
  String _language = 'ru';
  String _reminderTime = '20:00';
  bool _initialized = false;

  // Auth state subscription
  StreamSubscription? _authSubscription;

  List<Habit> get habits => _habits;
  String? get userId => _userId;
  String get userName => _userName;
  String? get profilePhotoPath => _profilePhotoPath;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkTheme => _isDarkTheme;
  String get language => _language;
  String get reminderTime => _reminderTime;
  bool get initialized => _initialized;

  static const List<String> colors = [
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFEAA7',
    '#DDA0DD',
    '#98D8C8',
    '#F7DC6F',
    '#BB8FCE',
    '#85C1E9',
    '#6C63FF',
    '#FF8E8E',
  ];

  static const List<String> icons = [
    '💪',
    '📚',
    '🏃',
    '💧',
    '🧘',
    '✍️',
    '🎯',
    '💤',
    '🥗',
    '📱',
    '🎨',
    '🎸',
    '🚴',
    '🍎',
    '🌅',
    '📝',
    '🔥',
    '⭐',
    '💎',
    '🎵',
  ];

  TimeOfDay get reminderTimeOfDay {
    final parts = _reminderTime.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 20, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String get reminderTimeDisplay {
    final time = reminderTimeOfDay;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  HabitProvider() {
    _init();
  }

  Future<void> _init() async {
    await NotificationService.instance.init();

    // Check actual Supabase session - don't auto-login from stored userId
    final currentUser = SupabaseService.instance.getCurrentUser();
    if (currentUser != null) {
      _userId = currentUser.id;
      await _loadHabits();
    }
    // If no session, _userId stays null and auth screen will show

    await _loadSettings();

    // Listen to Supabase auth state changes
    _authSubscription =
        SupabaseService.instance.onAuthStateChange().listen((AuthState data) {
      final session = data.session;
      final user = session?.user;

      if (user != null) {
        // User signed in
        if (_userId != user.id) {
          _userId = user.id;
          _saveUserId();
          notifyListeners();
          // Reload habits for new user
          _loadHabits();
        }
      } else {
        // User signed out or session expired
        if (_userId != null) {
          _userId = null;
          _removeUserId();
          _habits.clear();
          notifyListeners();
        }
      }
    });

    _initialized = true;
    notifyListeners();
    if (_notificationsEnabled) {
      await _scheduleDailyReminder();
    }
  }

  Future<void> _loadHabits() async {
    if (_userId == null) return;
    await _loadHabitsLocal();

    try {
      final remoteHabits = await SupabaseService.instance.fetchHabits(_userId!);
      if (remoteHabits.isNotEmpty) {
        _habits = remoteHabits;
        notifyListeners();
      } else if (_habits.isNotEmpty) {
        await SupabaseService.instance.upsertHabits(_habits, _userId!);
      }
    } catch (_) {
      // Если Supabase недоступна, оставляем локальные данные.
    }
  }

  Future<void> _loadHabitsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> decoded = json.decode(habitsJson);
      _habits = decoded.map((h) => Habit.fromJson(h)).toList();
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? 'Пользователь';
    _profilePhotoPath = prefs.getString('profilePhotoPath');
    if (_profilePhotoPath?.isEmpty ?? true) {
      _profilePhotoPath = null;
    }
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
    _language = prefs.getString('language') ?? 'ru';
    _reminderTime = prefs.getString('reminderTime') ?? '20:00';
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('profilePhotoPath', _profilePhotoPath ?? '');
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setString('language', _language);
    await prefs.setString('reminderTime', _reminderTime);
    notifyListeners();
  }

  Future<void> setProfilePhoto(String path) async {
    _profilePhotoPath = path;
    await _saveSettings();
  }

  Future<void> removeProfilePhoto() async {
    _profilePhotoPath = null;
    await _saveSettings();
  }

  void setUserName(String name) {
    _userName = name;
    _saveSettings();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _saveSettings();
    if (_notificationsEnabled) {
      await _scheduleDailyReminder();
    } else {
      await NotificationService.instance.cancelReminder(1);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkTheme = isDark;
    await _saveSettings();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    await _saveSettings();
    if (_notificationsEnabled) {
      await _scheduleDailyReminder();
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _saveSettings();
    if (_notificationsEnabled) {
      await _scheduleDailyReminder();
    }
  }

  Future<void> signUp(String email, String password) async {
    print('Attempting to sign up with email: $email');
    try {
      final response = await SupabaseService.instance.signUp(email, password);
      print('Sign up response user: ${response.user}');
      print('Sign up response user id: ${response.user?.id}');
      _userId = response.user?.id;
      print('Setting _userId to: $_userId');
      await _saveUserId();
      await _loadHabits();
      notifyListeners();
    } catch (e) {
      print('Sign up error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('429') || errorStr.contains('rate limit')) {
        throw Exception(
            'Слишком много запросов. Подождите немного и попробуйте снова.');
      } else if (errorStr.contains('400') &&
          errorStr.contains('already been registered')) {
        throw Exception(
            'Пользователь с таким email уже существует. Попробуйте войти.');
      } else if (errorStr.contains('weak_password')) {
        throw Exception(
            'Пароль слишком слабый. Используйте минимум 6 символов.');
      } else if (errorStr.contains('confirmed') ||
          errorStr.contains(' confirmation')) {
        throw Exception(
            'Требуется подтверждение email. Проверьте почту или запросите повторное отправление.');
      }
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    print('Attempting to sign in with email: $email');
    try {
      // Clear any existing session to avoid conflicts
      try {
        await SupabaseService.instance.signOut();
      } catch (_) {}

      final response = await SupabaseService.instance.signIn(email, password);
      print('Sign in response: ${response.user?.id}');
      _userId = response.user?.id;
      await _saveUserId();
      await _loadHabits();
      notifyListeners();
    } catch (e) {
      print('Sign in error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('400') ||
          errorStr.contains('Invalid login credentials')) {
        throw Exception('Неверный email или пароль.');
      } else if (errorStr.contains('429') || errorStr.contains('rate limit')) {
        throw Exception(
            'Слишком много запросов. Подождите немного и попробуйте снова.');
      } else if (errorStr.contains('Email not confirmed') ||
          errorStr.contains('confirmed') ||
          errorStr.contains('confirmation')) {
        throw Exception(
            'Email не подтвержден. Проверьте почту или нажмите "Отправить повторно".');
      }
      rethrow;
    }
  }

  Future<void> resendConfirmation(String email) async {
    await SupabaseService.instance.resendConfirmation(email);
  }

  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
    _userId = null;
    await _removeUserId();
    _habits.clear();
    // Force clear any cached auth state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    notifyListeners();
  }

  Future<void> _scheduleDailyReminder() async {
    if (!_notificationsEnabled) return;
    await NotificationService.instance.scheduleDailyReminder(
      1,
      _language == 'en' ? 'Habit reminder' : 'Напоминание',
      _language == 'en'
          ? 'Don’t forget to complete your habits today!'
          : 'Не забудь выполнить свои привычки сегодня!',
      reminderTimeOfDay,
    );
  }

  Future<void> _saveHabits() async {
    print(
        '_saveHabits called. UserId: $_userId, Habits count: ${_habits.length}');
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = json.encode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', habitsJson);
    notifyListeners();

    if (_userId != null) {
      try {
        print('Attempting to save habits to Supabase for userId: $_userId');
        await SupabaseService.instance.upsertHabits(_habits, _userId!);
        print('Successfully saved habits to Supabase');
      } catch (e) {
        print('Error saving habits to Supabase: $e');
        // Если Supabase недоступна, сохраняем только локально.
      }
    } else {
      print('UserId is null, skipping Supabase save');
    }
  }

  Future<void> addHabit(String title, String description,
      {bool hasProgress = false,
      double targetValue = 1.0,
      String unit = 'раз'}) async {
    final random = math.Random();
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId ?? '',
      title: title,
      description: description,
      color: HabitProvider.colors[random.nextInt(HabitProvider.colors.length)],
      icon: HabitProvider.icons[random.nextInt(HabitProvider.icons.length)],
      completedDates: [],
      createdAt: DateTime.now(),
      hasProgress: hasProgress,
      targetValue: targetValue,
      unit: unit,
    );
    _habits.add(habit);
    await _saveHabits();
  }

  Future<void> toggleHabit(String habitId) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _habits = _habits.map((habit) {
      if (habit.id == habitId) {
        final isCompleted = habit.completedDates.contains(todayStr);
        List<String> newDates;
        if (isCompleted) {
          newDates = habit.completedDates.where((d) => d != todayStr).toList();
        } else {
          newDates = [...habit.completedDates, todayStr];
        }

        final updatedHabit = habit.copyWith(
          completedDates: newDates,
          streak: _calculateStreak(newDates),
        );
        return updatedHabit;
      }
      return habit;
    }).toList();

    await _saveHabits();
  }

  Future<void> updateProgress(String habitId, double addedValue) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _habits = _habits.map((habit) {
      if (habit.id == habitId && habit.hasProgress) {
        final currentProgress = habit.progressHistory[todayStr] ?? 0.0;
        final newProgress = currentProgress + addedValue;

        final newProgressHistory =
            Map<String, double>.from(habit.progressHistory);
        newProgressHistory[todayStr] = newProgress.clamp(0, habit.targetValue);

        List<String> newDates = List<String>.from(habit.completedDates);
        if (newProgress >= habit.targetValue && !newDates.contains(todayStr)) {
          newDates.add(todayStr);
        } else if (newProgress < habit.targetValue &&
            newDates.contains(todayStr)) {
          newDates.remove(todayStr);
        }

        final updatedHabit = habit.copyWith(
          progressHistory: newProgressHistory,
          completedDates: newDates,
          streak: _calculateStreak(newDates),
        );
        return updatedHabit;
      }
      return habit;
    }).toList();

    await _saveHabits();
  }

  Future<void> resetProgress(String habitId) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _habits = _habits.map((habit) {
      if (habit.id == habitId && habit.hasProgress) {
        final newProgressHistory =
            Map<String, double>.from(habit.progressHistory);
        newProgressHistory.remove(todayStr);

        final updatedHabit = habit.copyWith(
          progressHistory: newProgressHistory,
        );
        return updatedHabit;
      }
      return habit;
    }).toList();

    await _saveHabits();
  }

  // Отметить привычку за конкретную дату
  Future<void> toggleHabitForDate(String habitId, String dateStr) async {
    _habits = _habits.map((habit) {
      if (habit.id == habitId) {
        final isCompleted = habit.completedDates.contains(dateStr);
        List<String> newDates;
        if (isCompleted) {
          newDates = habit.completedDates.where((d) => d != dateStr).toList();
        } else {
          newDates = [...habit.completedDates, dateStr];
        }

        final updatedHabit = habit.copyWith(
          completedDates: newDates,
          streak: _calculateStreak(newDates),
        );
        return updatedHabit;
      }
      return habit;
    }).toList();

    await _saveHabits();
  }

  // Обновить прогресс за конкретную дату
  Future<void> updateProgressForDate(
      String habitId, String dateStr, double addedValue) async {
    _habits = _habits.map((habit) {
      if (habit.id == habitId && habit.hasProgress) {
        final currentProgress = habit.progressHistory[dateStr] ?? 0.0;
        final newProgress = currentProgress + addedValue;

        final newProgressHistory =
            Map<String, double>.from(habit.progressHistory);
        newProgressHistory[dateStr] = newProgress.clamp(0, habit.targetValue);

        List<String> newDates = List<String>.from(habit.completedDates);
        if (newProgress >= habit.targetValue && !newDates.contains(dateStr)) {
          newDates.add(dateStr);
        } else if (newProgress < habit.targetValue &&
            newDates.contains(dateStr)) {
          newDates.remove(dateStr);
        }

        final updatedHabit = habit.copyWith(
          progressHistory: newProgressHistory,
          completedDates: newDates,
          streak: _calculateStreak(newDates),
        );
        return updatedHabit;
      }
      return habit;
    }).toList();

    _saveHabits();
  }

  // Получить привычку по ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  int _calculateStreak(List<String> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sortedDates = [...completedDates]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime? prevDate;

    for (final dateStr in sortedDates) {
      final currentDate = DateTime.parse(dateStr);

      if (prevDate == null) {
        streak = 1;
      } else {
        final diff = prevDate.difference(currentDate).inDays;
        if (diff == 1) {
          streak++;
        } else if (diff > 1) {
          break;
        }
      }
      prevDate = currentDate;
    }

    return streak;
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
    await _saveHabits();
    if (_userId != null) {
      try {
        await SupabaseService.instance.deleteHabit(habitId, _userId!);
      } catch (_) {}
    }
  }

  Future<void> updateHabit(Habit habit) async {
    _habits = _habits.map((h) => h.id == habit.id ? habit : h).toList();
    await _saveHabits();
  }

  int get completedToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return _habits.where((h) => h.completedDates.contains(todayStr)).length;
  }

  int completedForDate(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _habits.where((h) => h.completedDates.contains(dateStr)).length;
  }

  int get totalHabits => _habits.length;

  int get completionRate {
    if (_habits.isEmpty) return 0;
    return ((completedToday / _habits.length) * 100).round();
  }

  int get bestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
  }

  Map<String, int> getWeeklyData() {
    final Map<String, int> weeklyData = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayNamesRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      final dayNamesEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayName = _language == 'en'
          ? dayNamesEn[date.weekday - 1]
          : dayNamesRu[date.weekday - 1];

      int completed = 0;
      for (final habit in _habits) {
        if (habit.completedDates.contains(dateStr)) {
          completed++;
        }
      }
      weeklyData[dayName] = completed;
    }

    return weeklyData;
  }

  // Получить данные за месяц (для линейного графика тренда)
  Map<String, double> getMonthlyTrendData() {
    final Map<String, double> trendData = {};
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      int completed = 0;
      for (final habit in _habits) {
        if (habit.completedDates.contains(dateStr)) {
          completed++;
        }
      }

      final percentage = _habits.isEmpty
          ? 0.0
          : (completed.toDouble() / _habits.length.toDouble()) * 100.0;
      trendData[day.toString()] = percentage;
    }

    return trendData;
  }

  // Получить лучший день недели
  Map<String, dynamic> getBestDayOfWeek() {
    final Map<String, int> dayCounts = {
      'Пн': 0,
      'Вт': 0,
      'Ср': 0,
      'Чт': 0,
      'Пт': 0,
      'Сб': 0,
      'Вс': 0
    };
    final Map<String, int> dayOccurrences = {
      'Пн': 0,
      'Вт': 0,
      'Ср': 0,
      'Чт': 0,
      'Пт': 0,
      'Сб': 0,
      'Вс': 0
    };

    for (final habit in _habits) {
      for (final dateStr in habit.completedDates) {
        final date = DateTime.parse(dateStr);
        final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
        final dayName = dayNames[date.weekday - 1];
        dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;
        dayOccurrences[dayName] = (dayOccurrences[dayName] ?? 0) + 1;
      }
    }

    String bestDay = 'Пн';
    int maxCount = 0;
    for (final entry in dayCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        bestDay = entry.key;
      }
    }

    return {'day': bestDay, 'count': maxCount};
  }

  // Получить инсайты на основе данных
  List<Map<String, dynamic>> getInsights() {
    final List<Map<String, dynamic>> insights = [];

    if (_habits.isEmpty) return insights;

    // Инсайт 1: Общая статистика
    final totalCompletions =
        _habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    if (totalCompletions > 0) {
      insights.add({
        'type': 'total',
        'icon': '📈',
        'title': _language == 'en' ? 'Total completions' : 'Всего выполнений',
        'value': totalCompletions.toString(),
        'color': const Color(0xFF6C63FF),
      });
    }

    // Инсайт 2: Лучшая привычка
    if (_habits.isNotEmpty) {
      final bestHabit = _habits.reduce(
          (a, b) => a.completedDates.length > b.completedDates.length ? a : b);
      if (bestHabit.completedDates.isNotEmpty) {
        insights.add({
          'type': 'best_habit',
          'icon': '🏆',
          'title': _language == 'en' ? 'Most consistent' : 'Самая стабильная',
          'value': bestHabit.title,
          'color': const Color(0xFF4ECDC4),
        });
      }
    }

    // Инсайт 3: Лучший день
    final bestDay = getBestDayOfWeek();
    if ((bestDay['count'] as int) > 0) {
      final dayNamesEn = {
        'Пн': 'Monday',
        'Вт': 'Tuesday',
        'Ср': 'Wednesday',
        'Чт': 'Thursday',
        'Пт': 'Friday',
        'Сб': 'Saturday',
        'Вс': 'Sunday'
      };
      insights.add({
        'type': 'best_day',
        'icon': '⭐',
        'title': _language == 'en' ? 'Best day' : 'Лучший день',
        'value':
            _language == 'en' ? dayNamesEn[bestDay['day']]! : bestDay['day'],
        'color': const Color(0xFFF7DC6F),
      });
    }

    // Инсайт 4: Серия
    if (bestStreak >= 3) {
      insights.add({
        'type': 'streak',
        'icon': '🔥',
        'title': _language == 'en' ? 'Current best streak' : 'Текущая серия',
        'value': '$bestStreak ${_language == 'en' ? 'days' : 'дней'}',
        'color': const Color(0xFFFF6B6B),
      });
    }

    // Инсайт 5: Процент за неделю
    final weeklyData = getWeeklyData();
    final weekTotal = weeklyData.values.fold<int>(0, (a, b) => a + b);
    final weekMax = _habits.length * 7;
    if (weekMax > 0) {
      final weekPercentage = ((weekTotal / weekMax) * 100).round();
      insights.add({
        'type': 'week_percentage',
        'icon': '📊',
        'title': _language == 'en' ? 'Week completion' : 'За неделю',
        'value': '$weekPercentage%',
        'color': const Color(0xFFBB8FCE),
      });
    }

    return insights;
  }

  // Получить данные для круговой диаграммы по категориям (дни недели)
  Map<String, int> getCompletionByCategory() {
    final Map<String, int> data = {};

    // Считаем привычки по их средней успешности
    for (final habit in _habits) {
      final completionRate = habit.completedDates.length > 14
          ? 'high'
          : habit.completedDates.length > 7
              ? 'medium'
              : 'low';
      data[completionRate] = (data[completionRate] ?? 0) + 1;
    }

    return data;
  }

  // Получить привычки с сериями >= 7 дней
  List<Habit> get habitsWithLongStreaks {
    return _habits.where((h) => h.streak >= 7).toList();
  }

  // Общее количество дней, когда была выполнена хотя бы одна привычка
  int get activeDays {
    final allDates = <String>{};
    for (final habit in _habits) {
      allDates.addAll(habit.completedDates);
    }
    return allDates.length;
  }

  // Средний процент выполнения за последние 30 дней
  double get averageMonthlyCompletion {
    final now = DateTime.now();
    int totalPossible = _habits.length * 30;
    int totalCompleted = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      for (final habit in _habits) {
        if (habit.completedDates.contains(dateStr)) {
          totalCompleted++;
        }
      }
    }

    return totalPossible > 0 ? (totalCompleted / totalPossible) * 100 : 0;
  }

  Future<void> _saveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _userId ?? '');
  }

  Future<void> _removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('current_user_email');
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    // Don't notify here; will be synced via auth state listener
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
