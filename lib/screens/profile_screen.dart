import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/habit_provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'calendar_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().goProfile();
      final provider = Provider.of<HabitProvider>(context, listen: false);
      _nameController.text = provider.userName;
      setState(() => _isLoading = false);
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        // Copy the image to app documents directory to prevent temp file deletion
        final appDir = await getApplicationDocumentsDirectory();
        final profilePhotosDir = Directory('${appDir.path}/profile_photos');
        if (!await profilePhotosDir.exists()) {
          await profilePhotosDir.create(recursive: true);
        }

        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final permanentPath = '${profilePhotosDir.path}/$fileName';
        await File(photo.path).copy(permanentPath);

        final provider = Provider.of<HabitProvider>(context, listen: false);
        await provider.setProfilePhoto(permanentPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(_getTranslations(provider.language)['photo_saved']!),
              backgroundColor: const Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getTranslations(
                Provider.of<HabitProvider>(context, listen: false)
                    .language)['photo_error']!),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
        final inputColor =
            isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5);

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 100,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  _buildHeader(
                                      provider, textColor, subtextColor),
                                  const SizedBox(height: 32),
                                  _buildNameInput(provider, cardColor,
                                      inputColor, textColor),
                                  const SizedBox(height: 24),
                                  _buildStatsSection(provider, cardColor,
                                      textColor, subtextColor),
                                  const SizedBox(height: 24),
                                  _buildSettingsSection(
                                      provider, cardColor, textColor, isDark),
                                  const SizedBox(height: 24),
                                  _buildLanguageSection(
                                      provider, cardColor, textColor),
                                  const SizedBox(height: 24),
                                  _buildLogoutButton(provider),
                                  const SizedBox(height: 20),
                                  _buildAboutSection(
                                      cardColor, textColor, subtextColor),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildBottomNav(provider),
                    ],
                  );
                },
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? const Color(0xFF6C63FF) : const Color(0xFF1A1A2E))
                .withOpacity(0.3),
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
            _buildNavItem(
                Icons.home_rounded, _getLabel(provider.language, 'home'), 0),
            _buildNavItem(Icons.calendar_month_rounded,
                _getLabel(provider.language, 'calendar'), 1),
            _buildNavItem(Icons.analytics_rounded,
                _getLabel(provider.language, 'stats'), 2),
            _buildNavItem(Icons.person_rounded,
                _getLabel(provider.language, 'profile'), 3),
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
                navProvider.goHome();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()));
              } else if (index == 1) {
                navProvider.goCalendar();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const CalendarScreen()));
              } else if (index == 2) {
                navProvider.goStats();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const StatsScreen()));
              } else if (index == 3) {
                // Already on profile screen
                navProvider.goProfile();
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
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
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
      'ru': {
        'home': 'Главная',
        'stats': 'Статистика',
        'profile': 'Профиль',
        'calendar': 'Календарь'
      },
      'en': {
        'home': 'Home',
        'stats': 'Stats',
        'profile': 'Profile',
        'calendar': 'Calendar'
      },
    };
    return translations[language]?[key] ?? translations['ru']![key]!;
  }

  Widget _buildHeader(
      HabitProvider provider, Color textColor, Color subtextColor) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
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
                child: provider.profilePhotoPath != null &&
                        provider.profilePhotoPath!.isNotEmpty &&
                        File(provider.profilePhotoPath!).existsSync()
                    ? ClipOval(
                        child: Image.file(
                          File(provider.profilePhotoPath!),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        size: 60, color: Colors.white),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      debugPrint('Camera button tapped!');
                      _pickImage();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          provider.userName,
          style: TextStyle(
              color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          provider.language == 'en' ? 'Habit Tracker' : 'Трекер привычек',
          style: TextStyle(color: subtextColor, fontSize: 14),
        ),
        if (provider.profilePhotoPath != null &&
            provider.profilePhotoPath!.isNotEmpty) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              await provider.removeProfilePhoto();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        _getTranslations(provider.language)['photo_removed']!),
                    backgroundColor: const Color(0xFFFF6B6B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5)),
              ),
              child: Text(
                provider.language == 'en' ? 'Remove Photo' : 'Удалить фото',
                style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameInput(HabitProvider provider, Color cardColor,
      Color inputColor, Color textColor) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['edit_name']!,
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: inputColor, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: t['enter_name'],
                hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                prefixIcon:
                    const Icon(Icons.edit_rounded, color: Color(0xFF6C63FF)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF4ECDC4)),
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      provider.setUserName(_nameController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t['name_saved']!),
                          backgroundColor: const Color(0xFF4ECDC4),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

  Widget _buildStatsSection(HabitProvider provider, Color cardColor,
      Color textColor, Color subtextColor) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['my_stats']!,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildStatRow(
              '📊', t['total_habits']!, '${provider.totalHabits}', textColor),
          _buildDivider(),
          _buildStatRow('✅', t['completed_today']!,
              '${provider.completedToday}', textColor),
          _buildDivider(),
          _buildStatRow(
              '🔥', t['best_streak']!, '${provider.bestStreak}', textColor),
          _buildDivider(),
          _buildStatRow('⭐', t['completion_rate']!,
              '${provider.completionRate}%', textColor),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String emoji, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(label,
                style:
                    TextStyle(color: textColor.withOpacity(0.8), fontSize: 14)),
          ]),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(color: Color(0xFF6C63FF), height: 24, thickness: 1);

  Widget _buildSettingsSection(
      HabitProvider provider, Color cardColor, Color textColor, bool isDark) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['settings']!,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSettingItem(
            Icons.notifications_rounded,
            t['notifications']!,
            provider.notificationsEnabled
                ? (t['on'] ?? 'Вкл')
                : (t['off'] ?? 'Выкл'),
            provider.notificationsEnabled,
            (v) => provider.toggleNotifications(v),
          ),
          _buildReminderItem(
            Icons.alarm_rounded,
            t['reminder_time']!,
            provider.notificationsEnabled
                ? provider.reminderTimeDisplay
                : (t['off'] ?? 'Выкл'),
            provider.notificationsEnabled,
            () async {
              if (!provider.notificationsEnabled) return;
              final localContext = context;
              final selectedTime = await showTimePicker(
                context: localContext,
                initialTime: provider.reminderTimeOfDay,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme:
                          const ColorScheme.light(primary: Color(0xFF6C63FF)),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
              if (!mounted || selectedTime == null) return;
              await provider.setReminderTime(selectedTime);
              ScaffoldMessenger.of(localContext).showSnackBar(
                SnackBar(content: Text(t['reminder_saved']!)),
              );
            },
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

  Widget _buildSettingItem(IconData icon, String title, String subtitle,
      bool value, Function(bool) onChanged) {
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
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF6C63FF)),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    IconData icon,
    String title,
    String value,
    bool enabled,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(value,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: enabled ? Colors.white : Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
      HabitProvider provider, Color cardColor, Color textColor) {
    final currentLang = provider.language;
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['language']!,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildLanguageOption('🇷🇺', 'Русский', currentLang == 'ru',
              () => provider.setLanguage('ru'), textColor),
          const SizedBox(height: 8),
          _buildLanguageOption('🇬🇧', 'English', currentLang == 'en',
              () => provider.setLanguage('en'), textColor),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, bool isSelected,
      VoidCallback onTap, Color textColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(name,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal))),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF6C63FF), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(HabitProvider provider) {
    final t = _getTranslations(provider.language);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Text(
            t['logout']!,
            style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Provider.of<HabitProvider>(context, listen: false)
                    .signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: Text(
                provider.language == 'en' ? 'Sign Out' : 'Выйти',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(
      Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final lang = provider.language;
          final t = _getTranslations(lang);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['about']!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Habit Tracker',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(lang == 'en' ? 'Version 1.0.0' : 'Версия 1.0.0',
                            style:
                                TextStyle(color: subtextColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
        'reminder_time': 'Reminder time',
        'reminder_saved': 'Reminder saved! 📅',
        'dark_theme': 'Dark Theme',
        'dark': 'Dark',
        'light': 'Light',
        'language': 'Language',
        'on': 'On',
        'off': 'Off',
        'about': 'About',
        'photo_saved': 'Photo saved! ✓',
        'photo_removed': 'Photo removed',
        'photo_error': 'Error loading photo',
        'logout': 'Logout',
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
      'reminder_time': 'Время напоминания',
      'reminder_saved': 'Напоминание сохранено! 📅',
      'dark_theme': 'Тёмная тема',
      'dark': 'Тёмная',
      'light': 'Светлая',
      'language': 'Язык',
      'on': 'Вкл',
      'off': 'Выкл',
      'about': 'О приложении',
      'photo_saved': 'Фото сохранено! ✓',
      'photo_removed': 'Фото удалено',
      'photo_error': 'Ошибка при загрузке фото',
      'logout': 'Выход',
    };
  }
}
