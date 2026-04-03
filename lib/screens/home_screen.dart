import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/habit_card.dart';
import '../screens/add_habit_screen.dart';
import '../screens/edit_habit_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Установить индекс 0 при загрузке home экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().goHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final isDark = provider.isDarkTheme;
          final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
          final subtextColor = isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF1A1A2E).withOpacity(0.7);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF0F0F1A), Color(0xFF1A1A2E), Color(0xFF16213E)]
                    : const [Color(0xFFF5F7FA), Color(0xFFE8ECF1), Color(0xFFDDE2E9)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildHeader(provider, textColor, subtextColor),
                        Expanded(
                          child: provider.habits.isEmpty
                              ? _buildEmptyState(provider, textColor, subtextColor)
                              : _buildHabitsList(provider),
                        ),
                      ],
                    ),
                  ),
                  _buildBottomNav(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<HabitProvider>(
        builder: (context, provider, _) => _buildFab(provider),
      ),
    );
  }

  Widget _buildHeader(HabitProvider provider, Color textColor, Color subtextColor) {
    final t = _getTranslations(provider.language);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['good_day']!,
                    style: TextStyle(color: subtextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t['my_habits']!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildProgressCircle(provider),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickStats(provider, t),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(HabitProvider provider) {
    final percentage = provider.totalHabits > 0 ? (provider.completedToday / provider.totalHabits) : 0.0;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${(percentage * 100).round()}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('%', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(HabitProvider provider, Map<String, String> t) {
    final isDark = provider.isDarkTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📊', '${provider.totalHabits}', t['total']!, provider),
          _buildDivider(provider),
          _buildStatItem('✅', '${provider.completedToday}', t['completed']!, provider),
          _buildDivider(provider),
          _buildStatItem('🔥', '${provider.bestStreak}', t['streak']!, provider),
          _buildDivider(provider),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF6C63FF),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label, HabitProvider provider) {
    final isDark = provider.isDarkTheme;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF1A1A2E).withOpacity(0.5);
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: subtextColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider(HabitProvider provider) {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFF6C63FF).withOpacity(0.3),
    );
  }

  Widget _buildEmptyState(HabitProvider provider, Color textColor, Color subtextColor) {
    final t = _getTranslations(provider.language);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_task_rounded, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(t['no_habits']!, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(t['add_first']!, textAlign: TextAlign.center, style: TextStyle(color: subtextColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHabitsList(HabitProvider provider) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final t = _getTranslations(habitProvider.language);
        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 10),
          itemCount: provider.habits.length,
          itemBuilder: (context, index) {
            final habit = provider.habits[index];
            return HabitCard(
              habit: habit,
              onToggle: () {
                try {
                  provider.toggleHabit(habit.id);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t['error_update']!),
                      backgroundColor: const Color(0xFFFF6B6B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onDelete: () {
                try {
                  provider.deleteHabit(habit.id);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t['error_delete']!),
                      backgroundColor: const Color(0xFFFF6B6B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onEdit: () {
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditHabitScreen(habit: habit)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t['error_edit']!),
                      backgroundColor: const Color(0xFFFF6B6B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onAddProgress: habit.hasProgress
                  ? (value) {
                      try {
                        if (value < -1000) {
                          provider.resetProgress(habit.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t['progress_reset']!),
                              backgroundColor: const Color(0xFF4ECDC4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          provider.updateProgress(habit.id, value);
                          final newProgress = habit.getTodayProgress() + value;
                          if (newProgress >= habit.targetValue) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t['goal_reached']!),
                                backgroundColor: const Color(0xFF4ECDC4),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t['error_progress']!),
                            backgroundColor: const Color(0xFFFF6B6B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildFab(HabitProvider provider) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen())),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Icon(Icons.add_rounded, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(HabitProvider provider) {
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
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        final isActive = navProvider.selectedIndex == index;
        return Expanded(
          child: InkWell(
            onTap: () {
              if (index == 0) {
                // Already on home screen
                navProvider.goHome();
              } else if (index == 1) {
                navProvider.goCalendar();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
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
                  Icon(icon, color: isActive ? const Color(0xFF6C63FF) : Colors.grey, size: 24),
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
        'good_day': 'Good day! 👋',
        'my_habits': 'My Habits',
        'total': 'Total',
        'completed': 'Completed',
        'streak': 'Streak',
        'no_habits': 'No Habits',
        'add_first': 'Add your first habit\nand start your journey!',
        'add_habit': 'Add Habit',
        'error_update': 'Error updating habit',
        'error_delete': 'Error deleting habit',
        'error_edit': 'Error editing',
        'progress_reset': 'Progress reset',
        'goal_reached': '🎉 Goal reached!',
        'error_progress': 'Error updating progress',
      };
    }
    return {
      'good_day': 'Добрый день! 👋',
      'my_habits': 'Мои привычки',
      'total': 'Всего',
      'completed': 'Выполнено',
      'streak': 'Серия',
      'no_habits': 'Нет привычек',
      'add_first': 'Добавьте первую привычку\nи начните свой путь к успеху!',
      'add_habit': 'Добавить привычку',
      'error_update': 'Ошибка при обновлении привычки',
      'error_delete': 'Ошибка при удалении привычки',
      'error_edit': 'Ошибка при редактировании',
      'progress_reset': 'Прогресс сброшен',
      'goal_reached': '🎉 Цель достигнута!',
      'error_progress': 'Ошибка при обновлении прогресса',
    };
  }
}
