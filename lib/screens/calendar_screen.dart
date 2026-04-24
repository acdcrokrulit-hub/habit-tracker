import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/habit_provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().goCalendar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(),
                      const SizedBox(height: 24),
                      _buildCalendar(),
                      const SizedBox(height: 24),
                      _buildSelectedDayInfo(),
                      const SizedBox(height: 24),
                      _buildMonthlyStats(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

        return Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                ),
                child: Icon(Icons.arrow_back_rounded, color: textColor),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              t['title']!,
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final habits = provider.habits;
        
        // Build events map from all habits
        final events = <DateTime, List<String>>{};
        for (final habit in habits) {
          for (final dateStr in habit.completedDates) {
            final date = DateTime.parse(dateStr);
            final normalizedDate = DateTime(date.year, date.month, date.day);
            if (!events.containsKey(normalizedDate)) {
              events[normalizedDate] = [];
            }
            events[normalizedDate]!.add(habit.title);
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  locale: provider.language == 'ru' ? 'ru_RU' : 'en_US',
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) {
                    final normalizedDate = DateTime(day.year, day.month, day.day);
                    return events[normalizedDate] ?? [];
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: Color(0xFFFF6B6B)),
                    holidayTextStyle: const TextStyle(color: Color(0xFFFF6B6B)),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4ECDC4), width: 2),
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF4ECDC4),
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Color(0xFF6C63FF),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white, fontSize: 12),
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    weekendStyle: TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayInfo() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subtextColor = isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF1A1A2E).withOpacity(0.6);

        if (_selectedDay == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  t['select_day']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDay = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(t['show_today']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        final selectedDateStr = '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
        final completedHabits = provider.habits.where((h) => h.completedDates.contains(selectedDateStr)).toList();
        final uncompletedHabits = provider.habits.where((h) => !h.completedDates.contains(selectedDateStr)).toList();
        final totalHabits = provider.habits.length;
        final completedCount = completedHabits.length;
        final percentage = totalHabits > 0 ? ((completedCount / totalHabits) * 100).round() : 0;

        final isToday = isSameDay(_selectedDay, DateTime.now());
        final isPastOrToday = !_selectedDay!.isAfter(DateTime.now());
        final dateTitle = isToday
            ? t['today']!
            : '${_selectedDay!.day.toString().padLeft(2, '0')}.${_selectedDay!.month.toString().padLeft(2, '0')}.${_selectedDay!.year}';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '$dateTitle - ${t['habits_completed']!}',
                      style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$percentage%',
                      style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              if (isPastOrToday) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    for (final habit in uncompletedHabits) {
                      provider.toggleHabitForDate(habit.id, selectedDateStr);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${t['all_habits_marked']!} $dateTitle'),
                        backgroundColor: const Color(0xFF4ECDC4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4ECDC4), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t['mark_all_habits']!,
                            style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 14, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                '$completedCount / $totalHabits ${t['habits']!}',
                style: TextStyle(color: subtextColor, fontSize: 14),
              ),
              if (completedHabits.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '✅ ${t['completed']!}',
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...completedHabits.map((habit) => _buildHabitItem(habit, isDark, true, provider, selectedDateStr)),
              ],
              if (uncompletedHabits.isNotEmpty && isPastOrToday) ...[
                const SizedBox(height: 16),
                Text(
                  '⭕ ${t['uncompleted']!}',
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...uncompletedHabits.map((habit) => _buildHabitItem(habit, isDark, false, provider, selectedDateStr)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitItem(dynamic habit, bool isDark, bool isCompleted, HabitProvider provider, String dateStr) {
    final cardColor = isDark ? const Color(0xFF0F0F1A) : Colors.white;
    final color = Color(int.parse(habit.color.substring(1, 7), radix: 16) + 0xFF000000);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(habit.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          InkWell(
            onTap: () {
              provider.toggleHabitForDate(habit.id, dateStr);
            },
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isCompleted ? const Color(0xFF4ECDC4) : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subtextColor = isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF1A1A2E).withOpacity(0.6);

        // Calculate monthly stats
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;

        int totalCompletions = 0;
        int totalPossibleHabits = 0;
        int bestStreakInMonth = 0;

        for (final habit in provider.habits) {
          int monthCompletions = 0;
          for (final dateStr in habit.completedDates) {
            final date = DateTime.parse(dateStr);
            if (date.month == currentMonth && date.year == currentYear) {
              monthCompletions++;
            }
          }
          totalCompletions += monthCompletions;
          
          if (provider.habits.isNotEmpty) {
            totalPossibleHabits += DateTime(currentYear, currentMonth + 1, 0).day;
          }
          
          if (habit.streak > bestStreakInMonth) {
            bestStreakInMonth = habit.streak;
          }
        }

        final completionRate = totalPossibleHabits > 0 
            ? ((totalCompletions / totalPossibleHabits) * 100).round() 
            : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['monthly_stats']!,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMonthlyStatItem('📊', '$totalCompletions', t['completions']!, subtextColor),
                  _buildMonthlyStatItem('✅', '$completionRate%', t['rate']!, subtextColor),
                  _buildMonthlyStatItem('🔥', '$bestStreakInMonth', t['streak']!, subtextColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyStatItem(String emoji, String value, String label, Color subtextColor) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: subtextColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final isDark = provider.isDarkTheme;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isDark ? const Color(0xFF6C63FF) : const Color(0xFF1A1A2E)).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_rounded, _getLabel(provider.language, 'home'), 0),
                _buildNavItem(Icons.calendar_month_rounded, _getLabel(provider.language, 'calendar'), 1),
                _buildNavItem(Icons.analytics_rounded, _getLabel(provider.language, 'stats'), 2),
                _buildNavItem(Icons.person_rounded, _getLabel(provider.language, 'profile'), 3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        final isActive = navProvider.selectedIndex == index;
        return Expanded(
          child: InkWell(
            onTap: () {
              if (index == 0) {
                navProvider.goHome();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              } else if (index == 1) {
                // Already on calendar screen
                navProvider.goCalendar();
              } else if (index == 2) {
                navProvider.goStats();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              } else if (index == 3) {
                navProvider.goProfile();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLabel(String language, String key) {
    final translations = {
      'ru': {'home': 'Главная', 'stats': 'Статистика', 'profile': 'Профиль', 'calendar': 'Календарь'},
      'en': {'home': 'Home', 'stats': 'Stats', 'profile': 'Profile', 'calendar': 'Calendar'},
    };
    return translations[language]?[key] ?? translations['ru']![key]!;
  }

  Map<String, String> _getTranslations(String language) {
    if (language == 'en') {
      return {
        'title': 'Calendar',
        'select_day': 'Select a day to see completed habits',
        'today': 'Today',
        'habits_completed': 'Habits Completed',
        'habits': 'habits',
        'mark_all_habits': 'Mark all habits for this day',
        'all_habits_marked': '✅ All habits marked for',
        'show_today': 'Show today',
        'completed': 'Completed',
        'uncompleted': 'Uncompleted',
        'monthly_stats': 'Monthly Statistics',
        'completions': 'Completions',
        'rate': 'Completion Rate',
        'streak': 'Best Streak',
      };
    }
    return {
      'title': 'Календарь',
      'select_day': 'Выберите день, чтобы увидеть выполненные привычки',
      'today': 'Сегодня',
      'habits_completed': 'Выполненные привычки',
      'habits': 'привычек',
      'mark_all_habits': 'Отметить все привычки за этот день',
      'all_habits_marked': '✅ Все привычки отмечены за',
      'show_today': 'Показать сегодня',
      'completed': 'Выполненные',
      'uncompleted': 'Не выполненные',
      'monthly_stats': 'Статистика за месяц',
      'completions': 'Выполнений',
      'rate': 'Процент',
      'streak': 'Серия',
    };
  }
}
