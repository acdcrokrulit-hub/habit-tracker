class Habit {
  final String id;
  final String title;
  final String description;
  final String color;
  final String icon;
  final List<String> completedDates;
  final DateTime createdAt;
  final int streak;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.completedDates,
    required this.createdAt,
    this.streak = 0,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? color,
    String? icon,
    List<String>? completedDates,
    DateTime? createdAt,
    int? streak,
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
    );
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(todayStr);
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
}
