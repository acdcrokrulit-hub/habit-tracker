import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      _nameController.text = provider.userName;
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final isDark = provider.isDarkTheme;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subtextColor = isDark 
            ? Colors.white.withOpacity(0.6) 
            : const Color(0xFF1A1A2E).withOpacity(0.6);
        final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        final inputColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0F0F1A),
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                      ]
                    : const [
                        Color(0xFFF5F7FA),
                        Color(0xFFE8ECF1),
                        Color(0xFFDDE2E9),
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
                        children: [
                          _buildHeader(provider, textColor, subtextColor),
                          const SizedBox(height: 32),
                          _buildNameInput(provider, cardColor, inputColor, textColor),
                          const SizedBox(height: 24),
                          _buildStatsSection(provider, cardColor, textColor, subtextColor),
                          const SizedBox(height: 24),
                          _buildSettingsSection(provider, cardColor, textColor, isDark),
                          const SizedBox(height: 24),
                          _buildLanguageSection(provider, cardColor, textColor),
                          const SizedBox(height: 24),
                          _buildAboutSection(cardColor, textColor, subtextColor),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNav(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(HabitProvider provider) {
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
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
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

  Widget _buildHeader(HabitProvider provider, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          provider.userName,
          style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          provider.language == 'en' ? 'Habit Tracker' : 'Трекер привычек',
          style: TextStyle(color: subtextColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNameInput(HabitProvider provider, Color cardColor, Color inputColor, Color textColor) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['edit_name']!, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: t['enter_name'],
                hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF6C63FF)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF4ECDC4)),
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      provider.setUserName(_nameController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t['name_saved']!),
                          backgroundColor: const Color(0xFF4ECDC4),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(HabitProvider provider, Color cardColor, Color textColor, Color subtextColor) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['my_stats']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildStatRow('📊', t['total_habits']!, '${provider.totalHabits}', textColor),
          _buildDivider(),
          _buildStatRow('✅', t['completed_today']!, '${provider.completedToday}', textColor),
          _buildDivider(),
          _buildStatRow('🔥', t['best_streak']!, '${provider.bestStreak}', textColor),
          _buildDivider(),
          _buildStatRow('⭐', t['completion_rate']!, '${provider.completionRate}%', textColor),
        ],
      ),
    );
  }

  Widget _buildStatRow(String emoji, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14)),
          ]),
          Text(value, style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(color: Color(0xFF6C63FF), height: 24, thickness: 1);

  Widget _buildSettingsSection(HabitProvider provider, Color cardColor, Color textColor, bool isDark) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['settings']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSettingItem(
            Icons.notifications_rounded,
            t['notifications']!,
            provider.notificationsEnabled ? (t['on'] ?? 'Вкл') : (t['off'] ?? 'Выкл'),
            provider.notificationsEnabled,
            (v) => provider.toggleNotifications(v),
          ),
          _buildSettingItem(
            Icons.dark_mode_rounded,
            t['dark_theme']!,
            isDark ? (t['dark'] ?? 'Тёмная') : (t['light'] ?? 'Светлая'),
            provider.isDarkTheme,
            (v) => provider.toggleTheme(v),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6C63FF)),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(HabitProvider provider, Color cardColor, Color textColor) {
    final currentLang = provider.language;
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['language']!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildLanguageOption('🇷🇺', 'Русский', currentLang == 'ru', () => provider.setLanguage('ru'), textColor),
          const SizedBox(height: 8),
          _buildLanguageOption('🇬🇧', 'English', currentLang == 'en', () => provider.setLanguage('en'), textColor),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, bool isSelected, VoidCallback onTap, Color textColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: TextStyle(color: textColor, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF6C63FF), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getTranslations(_getTranslations('ru')['language']!)['about']!, 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Habit Tracker', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Версия 1.0.0', style: TextStyle(color: subtextColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _getTranslations(String language) {
    if (language == 'en') {
      return {
        'edit_name': 'Edit Name',
        'enter_name': 'Enter your name',
        'name_saved': 'Name saved! ✓',
        'my_stats': 'My Statistics',
        'total_habits': 'Total habits',
        'completed_today': 'Completed today',
        'best_streak': 'Best streak',
        'completion_rate': 'Completion rate',
        'settings': 'Settings',
        'notifications': 'Notifications',
        'dark_theme': 'Dark Theme',
        'dark': 'Dark',
        'light': 'Light',
        'language': 'Language',
        'on': 'On',
        'off': 'Off',
        'about': 'About',
      };
    }
    return {
      'edit_name': 'Изменить имя',
      'enter_name': 'Введите ваше имя',
      'name_saved': 'Имя сохранено! ✓',
      'my_stats': 'Моя статистика',
      'total_habits': 'Всего привычек',
      'completed_today': 'Выполнено сегодня',
      'best_streak': 'Лучшая серия',
      'completion_rate': 'Процент выполнения',
      'settings': 'Настройки',
      'notifications': 'Уведомления',
      'dark_theme': 'Тёмная тема',
      'dark': 'Тёмная',
      'light': 'Светлая',
      'language': 'Язык',
      'on': 'Вкл',
      'off': 'Выкл',
      'about': 'О приложении',
    };
  }
}
