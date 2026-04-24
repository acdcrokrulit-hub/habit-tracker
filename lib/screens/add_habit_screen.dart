import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasProgress = false;
  final _targetController = TextEditingController(text: '10');
  String _selectedUnit = 'ml';

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

  Map<String, String> _getUITranslations(String language) {
    if (language == 'en') {
      return {
        'new_habit': 'New Habit',
        'create_habit': 'Create Habit',
        'start_journey': 'Start your journey to success!',
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
        'goal_example': 'e.g., Goal 2000 ml = 2 liters of water per day',
        'tip': 'Tip',
        'tip_text': 'Start with small habits. Better to do them regularly than set too ambitious goals.',
        'create': 'Create Habit',
        'enter_title': 'Enter habit title',
        'invalid_goal': 'Enter a valid goal value',
        'habit_created_progress': 'Habit with progress created! 📊',
        'habit_created': 'Habit successfully created! 🎉',
        'fill_fields': 'Please fill in all required fields',
      };
    }
    return {
      'new_habit': 'Новая привычка',
      'create_habit': 'Создайте привычку',
      'start_journey': 'Начните свой путь к успеху!',
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
      'goal_example': 'Пример: Цель 2000 мл = 2 литра воды в день',
      'tip': 'Совет',
      'tip_text': 'Начните с маленьких привычек. Лучше выполнять их регулярно, чем ставить слишком амбициозные цели.',
      'create': 'Создать привычку',
      'enter_title': 'Введите название привычки',
      'invalid_goal': 'Введите корректное значение цели',
      'habit_created_progress': 'Привычка с прогрессом создана! 📊',
      'habit_created': 'Привычка успешно создана! 🎉',
      'fill_fields': 'Пожалуйста, заполните все обязательные поля',
    };
  }

  Map<String, String> _getTranslations(String language) {
    if (language == 'en') {
      return {
        'new_habit': 'New Habit',
        'create_habit': 'Create Habit',
        'start_journey': 'Start your journey to success!',
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
        'goal_example': 'e.g., Goal 2000 ml = 2 liters of water per day',
        'tip': 'Tip',
        'tip_text': 'Start with small habits. Better to do them regularly than set too ambitious goals.',
        'create': 'Create Habit',
        'enter_title': 'Enter habit title',
        'invalid_goal': 'Enter a valid goal value',
        'habit_created_progress': 'Habit with progress created! 📊',
        'habit_created': 'Habit successfully created! 🎉',
        'fill_fields': 'Please fill in all required fields',
      };
    }
    return {
      'new_habit': 'Новая привычка',
      'create_habit': 'Создайте привычку',
      'start_journey': 'Начните свой путь к успеху!',
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
      'goal_example': 'Пример: Цель 2000 мл = 2 литра воды в день',
      'tip': 'Совет',
      'tip_text': 'Начните с маленьких привычек. Лучше выполнять их регулярно, чем ставить слишком амбициозные цели.',
      'create': 'Создать привычку',
      'enter_title': 'Введите название привычки',
      'invalid_goal': 'Введите корректное значение цели',
      'habit_created_progress': 'Привычка с прогрессом создана! 📊',
      'habit_created': 'Привычка успешно создана! 🎉',
      'fill_fields': 'Пожалуйста, заполните все обязательные поля',
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
              final uiT = _getUITranslations(language);
              final units = _getUnits(language);

              return Column(
                children: [
                  _buildAppBar(uiT),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(uiT),
                            const SizedBox(height: 32),
                            _buildFormFields(uiT),
                            const SizedBox(height: 24),
                            _buildProgressToggle(uiT),
                            if (_hasProgress) ...[
                              const SizedBox(height: 24),
                              _buildProgressSettings(uiT, units),
                            ],
                            const SizedBox(height: 32),
                            _buildInfoCard(uiT),
                            const SizedBox(height: 32),
                            _buildSubmitButton(t, provider),
                          ],
                        ),
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
          Consumer<HabitProvider>(
            builder: (context, provider, _) {
              return Text(
                t['new_habit']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
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
      child: Row(
        children: [
          const Icon(
            Icons.add_task_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['create_habit']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t['start_journey']!,
                  style: const TextStyle(
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return t['enter_title'];
            }
            return null;
          },
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
    String? Function(String?)? validator,
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
            validator: validator,
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
                activeThumbColor: const Color(0xFF6C63FF),
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
                        initialValue: _selectedUnit,
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
          const SizedBox(height: 12),
          Text(
            t['goal_example']!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, String> t) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                t['tip']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t['tip_text']!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Map<String, String> t, HabitProvider provider) {
    final uiT = _getUITranslations(provider.language);
    return InkWell(
      onTap: () => _submitForm(t, provider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
          ),
          borderRadius: BorderRadius.circular(16),
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
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              uiT['create']!,
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

  void _submitForm(Map<String, String> t, HabitProvider provider) {
    final uiT = _getUITranslations(provider.language);
    
    if (_formKey.currentState!.validate()) {
      double targetValue = 1.0;
      if (_hasProgress) {
        try {
          targetValue = double.parse(_targetController.text.trim());
          if (targetValue <= 0) {
            throw const FormatException();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uiT['invalid_goal']!),
              backgroundColor: const Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }

      provider.addHabit(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        hasProgress: _hasProgress,
        targetValue: targetValue,
        unit: _selectedUnit,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hasProgress
              ? t['habit_created_progress']!  // Russian notification
              : t['habit_created']!),         // Russian notification
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t['fill_fields']!),  // Russian notification
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
