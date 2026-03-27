import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetController;
  late String _selectedColor;
  late String _selectedIcon;
  late bool _hasProgress;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _targetController = TextEditingController(text: widget.habit.targetValue.toString());
    _selectedColor = widget.habit.color;
    _selectedIcon = widget.habit.icon;
    _hasProgress = widget.habit.hasProgress;
    // Normalize unit to English value
    _selectedUnit = _normalizeUnit(widget.habit.unit);
  }

  String _normalizeUnit(String unit) {
    // Map Cyrillic units to Latin/English equivalents
    final unitMap = {
      'раз': 'times',
      'мл': 'ml',
      'л': 'l',
      'кг': 'kg',
      'г': 'g',
      'км': 'km',
      'м': 'm',
      'мин': 'min',
      'час': 'hrs',
    };
    return unitMap[unit] ?? unit;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  List<String> _getUnits(String language) {
    // Always use Latin/English units for consistency
    return ['times', 'ml', 'l', 'kg', 'g', 'km', 'm', 'min', 'hrs'];
  }

  Map<String, String> _getTranslations(String language) {
    if (language == 'en') {
      return {
        'edit': 'Edit',
        'edit_habit': 'Edit Habit',
        'save_changes': 'Save Changes',
        'title': 'Title',
        'title_hint': 'e.g., Drink water',
        'description': 'Description',
        'description_hint': 'e.g., 2 liters of water daily',
        'progress_tracking': 'Progress Tracking',
        'progress_desc': 'For habits with quantity (water, steps, etc.)',
        'progress_settings': 'Progress Settings',
        'goal': 'Goal',
        'goal_hint': 'e.g., 2000',
        'unit': 'Unit',
        'color': 'Color',
        'icon': 'Icon',
        'save': 'Save',
        'delete': 'Delete Habit',
        'enter_title': 'Enter habit title',
        'invalid_goal': 'Enter a valid goal value',
        'habit_updated': 'Habit updated! ✓',
        'delete_confirm': 'Delete habit?',
        'delete_message': 'This action cannot be undone',
        'cancel': 'Cancel',
        'delete_btn': 'Delete',
      };
    }
    return {
      'edit': 'Редактировать',
      'edit_habit': 'Изменение привычки',
      'save_changes': 'Сохранить изменения',
      'title': 'Название',
      'title_hint': 'Например: Пить воду',
      'description': 'Описание',
      'description_hint': 'Например: 2 литра воды каждый день',
      'progress_tracking': 'Отслеживание прогресса',
      'progress_desc': 'Для привычек с количеством (вода, шаги и т.д.)',
      'progress_settings': 'Настройки прогресса',
      'goal': 'Цель',
      'goal_hint': 'Например: 2000',
      'unit': 'Ед. измерения',
      'color': 'Цвет',
      'icon': 'Иконка',
      'save': 'Сохранить',
      'delete': 'Удалить привычку',
      'enter_title': 'Введите название привычки',
      'invalid_goal': 'Введите корректное значение цели',
      'habit_updated': 'Привычка обновлена! ✓',
      'delete_confirm': 'Удалить привычку?',
      'delete_message': 'Это действие нельзя отменить',
      'cancel': 'Отмена',
      'delete_btn': 'Удалить',
    };
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
          child: Consumer<HabitProvider>(
            builder: (context, provider, _) {
              final language = provider.language;
              final t = _getTranslations(language);
              final units = _getUnits(language);

              return Column(
                children: [
                  _buildAppBar(t),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(t),
                          const SizedBox(height: 32),
                          _buildFormFields(t),
                          const SizedBox(height: 24),
                          _buildProgressToggle(t),
                          if (_hasProgress) ...[
                            const SizedBox(height: 24),
                            _buildProgressSettings(t, units),
                          ],
                          const SizedBox(height: 24),
                          _buildColorPicker(t),
                          const SizedBox(height: 24),
                          _buildIconPicker(t),
                          const SizedBox(height: 32),
                          _buildSaveButton(t),
                          const SizedBox(height: 16),
                          _buildDeleteButton(t),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Map<String, String> t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            t['edit']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.edit_rounded,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Habit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Make changes and save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _titleController,
          label: t['title']!,
          hint: t['title_hint']!,
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _descriptionController,
          label: t['description']!,
          hint: t['description_hint']!,
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF6C63FF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressToggle(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['progress_tracking']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      t['progress_desc']!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _hasProgress,
                onChanged: (value) => setState(() => _hasProgress = value),
                activeColor: const Color(0xFF6C63FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSettings(Map<String, String> t, List<String> units) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['progress_settings']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _targetController,
                  label: t['goal']!,
                  hint: t['goal_hint']!,
                  icon: Icons.flag_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['unit']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        items: units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedUnit = value!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t['color']!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: HabitProvider.colors.map((color) {
            final isSelected = _selectedColor == color;
            return InkWell(
              onTap: () => setState(() => _selectedColor = color),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: HexColor(color),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HexColor(color).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconPicker(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t['icon']!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: HabitProvider.icons.map((icon) {
            final isSelected = _selectedIcon == icon;
            return InkWell(
              onTap: () => setState(() => _selectedIcon = icon),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Map<String, String> t) {
    return InkWell(
      onTap: () => _saveHabit(t),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.save_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 14),
            Text(
              t['save']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(Map<String, String> t) {
    return InkWell(
      onTap: () => _deleteHabit(t),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_rounded,
              color: Color(0xFFFF6B6B),
              size: 26,
            ),
            const SizedBox(width: 14),
            Text(
              t['delete']!,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveHabit(Map<String, String> t) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t['enter_title']!),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    double targetValue = 1.0;
    if (_hasProgress) {
      try {
        targetValue = double.parse(_targetController.text.trim());
        if (targetValue <= 0) {
          throw FormatException();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t['invalid_goal']!),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    final provider = Provider.of<HabitProvider>(context, listen: false);
    final updatedHabit = widget.habit.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      hasProgress: _hasProgress,
      targetValue: targetValue,
      unit: _selectedUnit,
    );

    provider.updateHabit(updatedHabit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t['habit_updated']!),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  void _deleteHabit(Map<String, String> t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t['delete_confirm']!,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          t['delete_message']!,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t['cancel']!,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<HabitProvider>(context, listen: false);
              provider.deleteHabit(widget.habit.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
            ),
            child: Text(t['delete_btn']!),
          ),
        ],
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
