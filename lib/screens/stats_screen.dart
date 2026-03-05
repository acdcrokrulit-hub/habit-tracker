import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(),
                        const SizedBox(height: 24),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        _buildWeeklyChart(),
                        const SizedBox(height: 24),
                        _buildAchievements(),
                      ],
                    ),
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
        final t = _getStatsTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        
        return Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
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

  Widget _buildHeader() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getStatsTranslations(provider.language);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              Text(t['your_progress']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: provider.completionRate / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    children: [
                      Text('${provider.completionRate}%',
                          style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                      Text(t['completed_today']!,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getStatsTranslations(provider.language);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('📊', '${provider.totalHabits}', t['total_habits']!, const Color(0xFFFF6B6B)),
            _buildStatCard('✅', '${provider.completedToday}', t['completed']!, const Color(0xFF4ECDC4)),
            _buildStatCard('🔥', '${provider.bestStreak}', t['best_streak']!, const Color(0xFFF7DC6F)),
            _buildStatCard('⭐', '${provider.habits.where((h) => h.streak >= 7).length}', t['achievements']!, const Color(0xFFBB8FCE)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String emoji,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getStatsTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        
        final weeklyData = provider.getWeeklyData();
        final entries = weeklyData.entries.toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['weekly_activity']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: provider.totalHabits.toDouble() + 1,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: const Color(0xFF6C63FF),
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= entries.length) {
                              return const Text('');
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                entries[value.toInt()].key,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final isToday = index == entries.length - 1;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.value.toDouble(),
                            gradient: LinearGradient(
                              colors: isToday
                                  ? [const Color(0xFF6C63FF), const Color(0xFF4ECDC4)]
                                  : [const Color(0xFF6C63FF).withOpacity(0.5), const Color(0xFF6C63FF).withOpacity(0.3)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 24,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievements() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getStatsTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        
        final achievements = [
          {'emoji': '🌟', 'title': t['first_step']!, 'description': t['first_step_desc']!, 'unlocked': provider.totalHabits > 0},
          {'emoji': '🔥', 'title': t['fire_streak']!, 'description': t['fire_streak_desc']!, 'unlocked': provider.bestStreak >= 7},
          {'emoji': '💎', 'title': t['habit_master']!, 'description': t['habit_master_desc']!, 'unlocked': provider.totalHabits >= 5},
          {'emoji': '🏆', 'title': t['champion']!, 'description': t['champion_desc']!, 'unlocked': provider.completionRate == 100 && provider.totalHabits > 0},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['achievements']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => _buildAchievementItem(achievement, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement, bool isDark) {
    final isUnlocked = achievement['unlocked'] as bool;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF1A1A2E).withOpacity(0.4);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF4ECDC4).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFF4ECDC4).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(achievement['emoji'] as String, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement['title'] as String,
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(achievement['description'] as String, style: TextStyle(color: subtextColor, fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock_outline,
            color: isUnlocked ? const Color(0xFF4ECDC4) : Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final isDark = provider.isDarkTheme;
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? const Color(0xFF6C63FF) : const Color(0xFF1A1A2E)).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, _getLabel(provider.language, 'home'), 0),
              _buildNavItem(Icons.analytics_rounded, _getLabel(provider.language, 'stats'), 1),
              _buildNavItem(Icons.person_rounded, _getLabel(provider.language, 'profile'), 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(String language, String key) {
    final translations = {
      'ru': {'home': 'Главная', 'stats': 'Статистика', 'profile': 'Профиль'},
      'en': {'home': 'Home', 'stats': 'Stats', 'profile': 'Profile'},
    };
    return translations[language]?[key] ?? translations['ru']![key]!;
  }

  Map<String, String> _getStatsTranslations(String language) {
    if (language == 'en') {
      return {
        'title': 'Statistics',
        'your_progress': 'Your Progress',
        'completed_today': 'completed today',
        'total_habits': 'Total Habits',
        'completed': 'Completed',
        'best_streak': 'Best Streak',
        'achievements': 'Achievements',
        'weekly_activity': 'Weekly Activity',
        'first_step': 'First Step',
        'first_step_desc': 'Create your first habit',
        'fire_streak': 'Fire Streak',
        'fire_streak_desc': 'Reach a 7-day streak',
        'habit_master': 'Habit Master',
        'habit_master_desc': 'Create 5 habits',
        'champion': 'Champion',
        'champion_desc': '100% completion today',
      };
    }
    return {
      'title': 'Статистика',
      'your_progress': 'Ваш прогресс',
      'completed_today': 'выполнено сегодня',
      'total_habits': 'Всего привычек',
      'completed': 'Выполнено',
      'best_streak': 'Лучшая серия',
      'achievements': 'Достижения',
      'weekly_activity': 'Активность за неделю',
      'first_step': 'Первый шаг',
      'first_step_desc': 'Создайте первую привычку',
      'fire_streak': 'Огненная серия',
      'fire_streak_desc': 'Достигните серии из 7 дней',
      'habit_master': 'Мастер привычек',
      'habit_master_desc': 'Создайте 5 привычек',
      'champion': 'Чемпион',
      'champion_desc': '100% выполнение сегодня',
    };
  }
}
