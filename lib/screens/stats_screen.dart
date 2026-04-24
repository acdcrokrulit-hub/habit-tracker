import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().goStats();
    });
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAppBar(),
                          const SizedBox(height: 24),
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildStatsGrid(),
                          const SizedBox(height: 24),
                          _buildInsights(),
                          const SizedBox(height: 24),
                          _buildExtraMetrics(),
                          const SizedBox(height: 24),
                          _buildWeeklyChart(),
                          const SizedBox(height: 24),
                          _buildCalendarSection(),
                          const SizedBox(height: 24),
                          _buildMonthlyTrendChart(),
                          const SizedBox(height: 24),
                          _buildAchievements(),
                          const SizedBox(height: 80),
                        ],
                      ),
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
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: provider.completionRate / 100),
          builder: (context, value, _) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
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
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(begin: 0, end: provider.completionRate / 100),
                          builder: (context, animValue, _) {
                            return CircularProgressIndicator(
                              value: animValue,
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          },
                        ),
                      ),
                      Column(
                        children: [
                          TweenAnimationBuilder<int>(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            tween: IntTween(begin: 0, end: provider.completionRate),
                            builder: (context, animValue, _) {
                              return Text(
                                '$animValue%',
                                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
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
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildAnimatedStatCard('📊', '${provider.totalHabits}', t['total_habits']!, const Color(0xFFFF6B6B), 0),
            _buildAnimatedStatCard('✅', '${provider.completedToday}', t['completed']!, const Color(0xFF4ECDC4), 1),
            _buildAnimatedStatCard('🔥', '${provider.bestStreak}', t['best_streak']!, const Color(0xFFF7DC6F), 2),
            _buildAnimatedStatCard('⭐', '${provider.habits.where((h) => h.streak >= 7).length}', t['achievements']!, const Color(0xFFBB8FCE), 3),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedStatCard(String emoji, String value, String label, Color color, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, animValue, _) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(
            opacity: animValue,
            child: _buildStatCard(emoji, value, label, color),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final insights = provider.getInsights();
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final t = _getInsightsTranslations(provider.language);

        if (insights.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['insights']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...insights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 500 + (index * 100)),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, _) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildInsightCard(insight),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (insight['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (insight['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(insight['icon'] as String, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['value'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

        if (provider.totalHabits == 0) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.insights_rounded, size: 64, color: Color(0xFF6C63FF)),
                const SizedBox(height: 16),
                Text(
                  t['no_data']!,
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  t['no_data_desc']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
                ),
              ],
            ),
          );
        }

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
                    maxY: (provider.totalHabits.toDouble() + 1).clamp(1, 100),
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
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildCalendarSection() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getStatsTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        final events = _buildCalendarEvents(provider);

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
              Text(t['calendar_title']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
                lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                focusedDay: _focusedDay,
                locale: provider.language == 'ru' ? 'ru_RU' : 'en_US',
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) {
                  final normalized = DateTime(day.year, day.month, day.day);
                  return events[normalized] ?? [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                  ),
                  markerSize: 5,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                  leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                  rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 16),
              _buildCalendarSummary(provider, provider.isDarkTheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarSummary(HabitProvider provider, bool isDark) {
    final t = _getStatsTranslations(provider.language);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }

    final dateStr = '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
    final completedHabits = provider.habits.where((habit) => habit.completedDates.contains(dateStr)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t['selected_day']!}: ${_selectedDay!.day.toString().padLeft(2, '0')}.${_selectedDay!.month.toString().padLeft(2, '0')}.${_selectedDay!.year}',
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          completedHabits.isNotEmpty
              ? '${completedHabits.length} ${t['completed_habits']!}'
              : t['no_habits_day']!,
          style: TextStyle(color: textColor.withOpacity(0.75), fontSize: 14),
        ),
      ],
    );
  }

  Map<DateTime, List<String>> _buildCalendarEvents(HabitProvider provider) {
    final Map<DateTime, List<String>> events = {};
    for (final habit in provider.habits) {
      for (final dateStr in habit.completedDates) {
        try {
          final date = DateTime.parse(dateStr);
          final normalized = DateTime(date.year, date.month, date.day);
          events.putIfAbsent(normalized, () => []);
          if (!events[normalized]!.contains(habit.title)) {
            events[normalized]!.add(habit.title);
          }
        } catch (_) {
          continue;
        }
      }
    }
    return events;
  }

  Widget _buildMonthlyTrendChart() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        if (provider.totalHabits == 0) return const SizedBox.shrink();

        final t = _getStatsTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

        final trendData = provider.getMonthlyTrendData();
        final spots = trendData.entries
            .map((e) => FlSpot(double.parse(e.key), e.value))
            .toList();

        if (spots.isEmpty) return const SizedBox.shrink();

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
              Text(t['monthly_trend']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6C63FF).withOpacity(0.3),
                              const Color(0xFF4ECDC4).withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: const LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Color(0xFF6C63FF),
                        tooltipPadding: EdgeInsets.all(8),
                        tooltipMargin: 8,
                      ),
                    ),
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
            ...achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final achievement = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, _) {
                  return Transform.translate(
                    offset: Offset(0, 15 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAchievementItem(achievement, isDark),
                      ),
                    ),
                  );
                },
              );
            }),
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
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0.8, end: 1.0),
            builder: (context, value, _) {
              return Transform.scale(
                scale: value,
                child: Container(
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
              );
            },
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
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, _) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  isUnlocked ? Icons.check_circle : Icons.lock_outline,
                  color: isUnlocked ? const Color(0xFF4ECDC4) : Colors.grey.withOpacity(0.5),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExtraMetrics() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final t = _getStatsTranslations(provider.language);
        final isDark = provider.isDarkTheme;
        final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

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
              Text(t['more_metrics']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('📅', '${provider.activeDays}', t['active_days']!, provider)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('📈', '${provider.averageMonthlyCompletion.round()}%', t['monthly_avg']!, provider)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String emoji, String value, String label, HabitProvider provider) {
    final isDark = provider.isDarkTheme;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
        ],
      ),
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
                navProvider.goCalendar();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
              } else if (index == 2) {
                navProvider.goStats();
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
        'monthly_trend': 'Monthly Trend',
        'calendar_title': 'Calendar',
        'selected_day': 'Selected day',
        'completed_habits': 'completed habits',
        'no_habits_day': 'No habits completed',
        'more_metrics': 'More metrics',
        'active_days': 'Active days',
        'monthly_avg': 'Monthly average',
        'first_step': 'First Step',
        'first_step_desc': 'Create your first habit',
        'fire_streak': 'Fire Streak',
        'fire_streak_desc': 'Reach a 7-day streak',
        'habit_master': 'Habit Master',
        'habit_master_desc': 'Create 5 habits',
        'champion': 'Champion',
        'champion_desc': '100% completion today',
        'no_data': 'No Data',
        'no_data_desc': 'Add habits to track statistics',
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
      'monthly_trend': 'Тренд за месяц',
      'calendar_title': 'Календарь',
      'selected_day': 'Выбранный день',
      'completed_habits': 'выполнено привычек',
      'no_habits_day': 'Привычки не выполнены',
      'more_metrics': 'Дополнительные метрики',
      'active_days': 'Активных дней',
      'monthly_avg': 'Среднее за месяц',
      'first_step': 'Первый шаг',
      'first_step_desc': 'Создайте первую привычку',
      'fire_streak': 'Огненная серия',
      'fire_streak_desc': 'Достигните серии из 7 дней',
      'habit_master': 'Мастер привычек',
      'habit_master_desc': 'Создайте 5 привычек',
      'champion': 'Чемпион',
      'champion_desc': '100% выполнение сегодня',
      'no_data': 'Нет данных',
      'no_data_desc': 'Добавьте привычки для отслеживания статистики',
    };
  }

  Map<String, String> _getInsightsTranslations(String language) {
    if (language == 'en') {
      return {
        'insights': 'Insights',
      };
    }
    return {
      'insights': 'Инсайты',
    };
  }
}
