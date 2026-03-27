class Habit {
  final String id;
  final String title;
  final String description;
  final String color;
  final String icon;
  final List<String> completedDates;
  final DateTime createdAt;
  final int streak;
  final bool hasProgress;
  final double targetValue;
  final String unit;
  final Map<String, double> progressHistory;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.completedDates,
    required this.createdAt,
    this.streak = 0,
    this.hasProgress = false,
    this.targetValue = 1.0,
    this.unit = 'раз',
    Map<String, double>? progressHistory,
  }) : progressHistory = progressHistory ?? {};

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? color,
    String? icon,
    List<String>? completedDates,
    DateTime? createdAt,
    int? streak,
    bool? hasProgress,
    double? targetValue,
    String? unit,
    Map<String, double>? progressHistory,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      streak: streak ?? this.streak,
      hasProgress: hasProgress ?? this.hasProgress,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      progressHistory: progressHistory ?? this.progressHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
      'streak': streak,
      'hasProgress': hasProgress,
      'targetValue': targetValue,
      'unit': unit,
      'progressHistory': progressHistory,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#6C63FF',
      icon: json['icon'] ?? '🎯',
      completedDates: List<String>.from(json['completedDates'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      streak: json['streak'] ?? 0,
      hasProgress: json['hasProgress'] ?? false,
      targetValue: (json['targetValue'] ?? 1.0).toDouble(),
      unit: json['unit'] ?? 'раз',
      progressHistory: json['progressHistory'] != null
          ? Map<String, double>.from(json['progressHistory'])
          : {},
    );
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(todayStr);
  }

  double getTodayProgress() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return progressHistory[todayStr] ?? 0.0;
  }

  double getProgressPercentage() {
    if (!hasProgress || targetValue <= 0) return isCompletedToday() ? 100 : 0;
    return (getTodayProgress() / targetValue * 100).clamp(0, 100);
  }

  int calculateStreak() {
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

  // Получить статистику за неделю
  int getWeekCompletions() {
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (completedDates.contains(dateStr)) {
        count++;
      }
    }
    return count;
  }

  // Получить статистику за месяц
  int getMonthCompletions() {
    final now = DateTime.now();
    int count = 0;
    for (final dateStr in completedDates) {
      final date = DateTime.parse(dateStr);
      if (date.month == now.month && date.year == now.year) {
        count++;
      }
    }
    return count;
  }

  // Получить лучшую серию
  int getBestStreak() {
    if (completedDates.isEmpty) return 0;

    final sortedDates = [...completedDates]..sort();
    int bestStreak = 1;
    int currentStreak = 1;
    DateTime? prevDate;

    for (final dateStr in sortedDates) {
      final currentDate = DateTime.parse(dateStr);

      if (prevDate != null) {
        final diff = currentDate.difference(prevDate).inDays;
        if (diff == 1) {
          currentStreak++;
          bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
        } else if (diff > 1) {
          currentStreak = 1;
        }
      }
      prevDate = currentDate;
    }

    return bestStreak;
  }

  // Получить прогресс за конкретную дату
  double getProgressForDate(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return progressHistory[dateStr] ?? 0.0;
  }

  // Отметить/снять отметку за конкретную дату
  Habit toggleDate(String dateStr) {
    final newDates = List<String>.from(completedDates);
    if (newDates.contains(dateStr)) {
      newDates.remove(dateStr);
    } else {
      newDates.add(dateStr);
    }
    return copyWith(
      completedDates: newDates,
      streak: _calculateStreakFromDates(newDates),
    );
  }

  // Обновить прогресс за конкретную дату
  Habit updateProgressForDate(String dateStr, double addedValue) {
    final newProgressHistory = Map<String, double>.from(progressHistory);
    final currentProgress = newProgressHistory[dateStr] ?? 0.0;
    final newProgress = (currentProgress + addedValue).clamp(0.0, targetValue);
    newProgressHistory[dateStr] = newProgress;

    final newDates = List<String>.from(completedDates);
    if (newProgress >= targetValue && !newDates.contains(dateStr)) {
      newDates.add(dateStr);
    } else if (newProgress < targetValue && newDates.contains(dateStr)) {
      newDates.remove(dateStr);
    }

    return copyWith(
      progressHistory: newProgressHistory,
      completedDates: newDates,
      streak: _calculateStreakFromDates(newDates),
    );
  }

  int _calculateStreakFromDates(List<String> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = [...dates]..sort((a, b) => b.compareTo(a));
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
}
