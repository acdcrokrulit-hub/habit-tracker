#!/usr/bin/env python3
"""
Fix HabitProvider to sync settings to Supabase with correct column names.
"""

import re

with open('lib/providers/habit_provider.dart', 'r') as f:
    content = f.read()

# 1. After _saveSettings() method, insert _loadSettingsFromSupabase and _saveSettingsToSupabase
insertion_point = content.find('  Future<void> _saveSettings() async {\n')
if insertion_point == -1:
    print('ERROR: Could not find _saveSettings method')
    exit(1)

# Find end of _saveSettings method: look for the closing brace after notifyListeners();
# We assume exact formatting as in repo.
save_settings_method = '''  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('profilePhotoPath', _profilePhotoPath ?? '');
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setString('language', _language);
    await prefs.setString('reminderTime', _reminderTime);
    notifyListeners();
  }'''

new_methods = '''
  Future<void> _loadSettingsFromSupabase() async {
    if (_userId == null) return;
    try {
      final settings = await SupabaseService.instance.fetchUserSettings(_userId!);
      if (settings != null) {
        // Use lowercase keys as stored in PostgreSQL
        _userName = settings['username'] ??
                    settings['userName'] ??
                    _userName;
        var photo = settings['profilephotopath'] ??
                    settings['profilePhotoPath'];
        _profilePhotoPath = (photo != null && photo.isNotEmpty) ? photo : null;
        _notificationsEnabled = settings['notificationsenabled'] ??
                                settings['notificationsEnabled'] ??
                                _notificationsEnabled;
        _isDarkTheme = settings['isdarktheme'] ??
                       settings['isDarkTheme'] ??
                       _isDarkTheme;
        _language = settings['language'] ?? _language;
        _reminderTime = settings['remindertime'] ??
                        settings['reminderTime'] ??
                        _reminderTime;
        notifyListeners();
        await _saveSettings();
      }
    } catch (e) {
      print('Error loading settings from Supabase: $e');
    }
  }

  Future<void> _saveSettingsToSupabase() async {
    if (_userId == null) return;
    try {
      await SupabaseService.instance.upsertUserSettings(_userId!, {
        'userid': _userId,
        'username': _userName,
        'profilephotopath': _profilePhotoPath ?? '',
        'notificationsenabled': _notificationsEnabled,
        'isdarktheme': _isDarkTheme,
        'language': _language,
        'remindertime': _reminderTime,
      });
    } catch (e) {
      print('Error saving settings to Supabase: $e');
    }
  }
'''

if save_settings_method not in content:
    print('ERROR: Could not find exact _saveSettings block')
    exit(1)

# Replace
content = content.replace(save_settings_method, save_settings_method + new_methods)

# 2. Update _init to call _loadSettingsFromSupabase after initial _loadHabits
content = content.replace(
    '      if (currentUser != null) {\n        _userId = currentUser.id;\n        await _loadHabits();\n      }',
    '      if (currentUser != null) {\n        _userId = currentUser.id;\n        await _loadHabits();\n        await _loadSettingsFromSupabase();\n      }'
)

# 3. Update auth listener inside _init to call _loadSettingsFromSupabase after _loadHabits
content = content.replace(
    '          _loadHabits();\n        }',
    '          _loadHabits();\n          await _loadSettingsFromSupabase();\n        }'
)

# 4. Update signIn to await _loadSettingsFromSupabase after _loadHabits
content = content.replace(
    '      await _loadHabits();\n      _loadSettingsFromSupabase();\n      notifyListeners();',
    '      await _loadHabits();\n      await _loadSettingsFromSupabase();\n      notifyListeners();'
)

# 5. Update signUp similarly (if not already)
content = content.replace(
    '      await _loadHabits();\n      _loadSettingsFromSupabase();\n      notifyListeners();',
    '      await _loadHabits();\n      await _loadSettingsFromSupabase();\n      notifyListeners();'
)

# 6. Update setUserName to async and call remote save
content = content.replace(
    '  void setUserName(String name) {\n    _userName = name;\n    _saveSettings();\n  }',
    '  void setUserName(String name) async {\n    _userName = name;\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n  }'
)

# 7. Ensure setProfilePhoto calls remote
content = content.replace(
    '  Future<void> setProfilePhoto(String path) async {\n    _profilePhotoPath = path;\n    await _saveSettings();\n  }',
    '  Future<void> setProfilePhoto(String path) async {\n    _profilePhotoPath = path;\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n  }'
)

# 8. removeProfilePhoto
content = content.replace(
    '  Future<void> removeProfilePhoto() async {\n    _profilePhotoPath = null;\n    await _saveSettings();\n  }',
    '  Future<void> removeProfilePhoto() async {\n    _profilePhotoPath = null;\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n  }'
)

# 9. toggleNotifications
content = content.replace(
    '  Future<void> toggleNotifications(bool value) async {\n    _notificationsEnabled = value;\n    await _saveSettings();\n    if (_notificationsEnabled) {',
    '  Future<void> toggleNotifications(bool value) async {\n    _notificationsEnabled = value;\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n    if (_notificationsEnabled) {'
)

# 10. toggleTheme
content = content.replace(
    '  Future<void> toggleTheme(bool isDark) async {\n    _isDarkTheme = isDark;\n    await _saveSettings();\n  }',
    '  Future<void> toggleTheme(bool isDark) async {\n    _isDarkTheme = isDark;\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n  }'
)

# 11. setLanguage
content = content.replace(
    '  Future<void> setLanguage(String lang) async {\n    _language = lang;\n    notifyListeners();\n    await _saveSettings();\n    if (_notificationsEnabled) {',
    '  Future<void> setLanguage(String lang) async {\n    _language = lang;\n    notifyListeners();\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n    if (_notificationsEnabled) {'
)

# 12. setReminderTime
content = content.replace(
    '  Future<void> setReminderTime(TimeOfDay time) async {\n    _reminderTime =\n        \'${time.hour.toString().padLeft(2, \'0\')}:${time.minute.toString().padLeft(2, \'0\')}\';\n    await _saveSettings();\n    if (_notificationsEnabled) {',
    '  Future<void> setReminderTime(TimeOfDay time) async {\n    _reminderTime =\n        \'${time.hour.toString().padLeft(2, \'0\')}:${time.minute.toString().padLeft(2, \'0\')}\';\n    await _saveSettings();\n    await _saveSettingsToSupabase();\n    if (_notificationsEnabled) {'
)

# 13. Clean signOut: remove the extra prefs removal lines
content = content.replace(
    '  Future<void> signOut() async {\n    await SupabaseService.instance.signOut();\n    _userId = null;\n    await _removeUserId();\n    _habits.clear();\n    // Force clear any cached auth state\n    final prefs = await SharedPreferences.getInstance();\n    await prefs.remove(\'user_id\');\n    notifyListeners();\n  }',
    '  Future<void> signOut() async {\n    await SupabaseService.instance.signOut();\n    _userId = null;\n    await _removeUserId();\n    _habits.clear();\n    notifyListeners();\n  }'
)

with open('lib/providers/habit_provider.dart', 'w') as f:
    f.write(content)

print('All modifications applied successfully.')
PYEOF
