import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  String _userName = 'Пользователь';
  bool _notificationsEnabled = true;
  bool _isDarkTheme = true;
  String _language = 'ru';

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
    '💪', '📚', '🏃', '💧', '🧘', '✍️', '🎯', '💤', '🥗', '📱',
    '🎨', '🎸', '🚴', '🍎', '🌅', '📝', '🔥', '⭐', '💎', '🎵',
  ];

  List<Habit> get habits => _habits;
  String get userName => _userName;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkTheme => _isDarkTheme;
  String get language => _language;

  HabitProvider() {
    _loadHabits();
    _loadSettings();
  }

  Future<void> _loadHabits() async {
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
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
    _language = prefs.getString('language') ?? 'ru';
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setString('language', _language);
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    _saveSettings();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _saveSettings();
  }

  void toggleTheme(bool isDark) {
    _isDarkTheme = isDark;
    _saveSettings();
  }

  void setLanguage(String lang) {
    _language = lang;
    _saveSettings();
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = json.encode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', habitsJson);
    notifyListeners();
  }

  void addHabit(String title, String description) {
    final random = SystemRandom();
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      color: colors[random.nextInt(colors.length)],
      icon: icons[random.nextInt(icons.length)],
      completedDates: [],
      createdAt: DateTime.now(),
    );
    _habits.add(habit);
    _saveHabits();
  }

  void toggleHabit(String habitId) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
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
    
    _saveHabits();
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

  void deleteHabit(String habitId) {
    _habits.removeWhere((habit) => habit.id == habitId);
    _saveHabits();
  }

  void updateHabit(Habit habit) {
    _habits = _habits.map((h) => h.id == habit.id ? habit : h).toList();
    _saveHabits();
  }

  int get completedToday {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return _habits.where((h) => h.completedDates.contains(todayStr)).length;
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
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayName = date.weekday == 1 
          ? 'Пн' 
          : date.weekday == 2 
              ? 'Вт' 
              : date.weekday == 3 
                  ? 'Ср' 
                  : date.weekday == 4 
                      ? 'Чт' 
                      : date.weekday == 5 
                          ? 'Пт' 
                          : date.weekday == 6 
                              ? 'Сб' 
                              : 'Вс';
      
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
}

class SystemRandom {
  final _random = DateTime.now().millisecondsSinceEpoch;
  int _counter = 0;
  
  int nextInt(int max) {
    _counter++;
    return (_random + _counter) % max;
  }
}
