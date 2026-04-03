import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../models/habit.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final Function(double)? onAddProgress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.onAddProgress,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _showStats = false;

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.habit.isCompletedToday();
    final color = _hexToColor(widget.habit.color);
    final hasProgress = widget.habit.hasProgress;
    final progress = hasProgress ? widget.habit.getTodayProgress() : 0.0;
    final progressPercent = hasProgress ? widget.habit.getProgressPercentage() : (isCompleted ? 100.0 : 0.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasProgress ? null : widget.onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [color.withOpacity(0.8), color.withOpacity(0.6)]
                    : [color.withOpacity(0.3), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? color : color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: isCompleted ? 2 : 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(color),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.habit.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!hasProgress) ...[
                      _buildCheckbox(color, isCompleted),
                      const SizedBox(width: 8),
                    ],
                    _buildMenu(color, context),
                  ],
                ),
                // Статистика за неделю и месяц
                Consumer<HabitProvider>(
                  builder: (context, habitProvider, _) {
                    final t = _getTranslations(habitProvider.language);
                    return Row(
                      children: [
                        _buildMiniStat('📅', '${widget.habit.getWeekCompletions()}/7', t['week']!),
                        const SizedBox(width: 16),
                        _buildMiniStat('📊', '${widget.habit.getMonthCompletions()}', t['month']!),
                        const SizedBox(width: 16),
                        _buildMiniStat('🔥', '${widget.habit.getBestStreak()}', t['best']!),
                        const Spacer(),
                        InkWell(
                          onTap: () => setState(() => _showStats = !_showStats),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  t['stats']!,
                                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Icon(
                                  _showStats ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: color,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_showStats) ...[
                  const SizedBox(height: 12),
                  _buildDetailedStats(color),
                ],
                if (hasProgress) ...[
                  const SizedBox(height: 16),
                  _buildProgressBar(context, color, progress, progressPercent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.habit.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Color color, bool isCompleted) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? color : Colors.transparent,
        border: Border.all(
          color: isCompleted ? color : Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            )
          : null,
    );
  }

  Widget _buildProgressBar(BuildContext context, Color color, double progress, double progressPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.toStringAsFixed(0)} / ${widget.habit.targetValue.toStringAsFixed(0)} ${widget.habit.unit}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            Text(
              '${progressPercent.round()}%',
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressPercent / 100,
            backgroundColor: color.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProgressButton(context, color, widget.habit.targetValue * 0.1, '10%', progress),
            _buildProgressButton(context, color, widget.habit.targetValue * 0.25, '25%', progress),
            _buildProgressButton(context, color, widget.habit.targetValue * 0.5, '50%', progress),
            _buildProgressButton(context, color, -widget.habit.targetValue * 0.25, '-25%', progress),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressButton(BuildContext context, Color color, double addValue, String label, double currentProgress) {
    final canAdd = currentProgress < widget.habit.targetValue || addValue < 0;
    return InkWell(
      onTap: canAdd ? () {
        setState(() {
          widget.onAddProgress?.call(addValue);
        });
      } : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: canAdd ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: canAdd ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: canAdd ? color : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(Color color, BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.white.withOpacity(0.7),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1A1A2E),
      onSelected: (value) {
        if (value == 'delete') {
          widget.onDelete();
        } else if (value == 'edit') {
          widget.onEdit?.call();
        } else if (value == 'reset') {
          widget.onAddProgress?.call(-99999); // Reset progress
        } else if (value == 'past_date') {
          _showPastDateDialog(color);
        }
      },
      itemBuilder: (context) {
        final t = _getTranslations(HabitProvider.of(context).language);
        return [
        PopupMenuItem(
          value: 'past_date',
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: color,
              ),
              const SizedBox(width: 12),
              Text(
                t['mark_date']!,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        if (widget.habit.hasProgress)
          PopupMenuItem(
            value: 'reset',
            child: Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  t['reset_progress']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: color,
              ),
              const SizedBox(width: 12),
              Text(
                t['edit']!,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_rounded,
                color: color,
              ),
              const SizedBox(width: 12),
              Text(
                t['delete']!,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ];
    },
    );
  }

  Widget _buildMiniStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(Color color) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final t = _getTranslations(habitProvider.language);
        final bestStreak = widget.habit.getBestStreak();
        final currentStreak = widget.habit.streak;
        final totalCompletions = widget.habit.completedDates.length;
        final completionRate = widget.habit.completedDates.isNotEmpty
            ? ((widget.habit.getWeekCompletions() / 7) * 100).round()
            : 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailStatItem('🎯', '$totalCompletions', t['total']!),
                  _buildDetailStatItem('🔥', '$currentStreak', t['current']!),
                  _buildDetailStatItem('⭐', '$bestStreak', t['record']!),
                  _buildDetailStatItem('📈', '$completionRate%', t['weekly']!),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }

  void _showPastDateDialog(Color color) {
    DateTime? selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        final t = _getTranslations(HabitProvider.of(context).language);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              t['select_date']!,
              style: const TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF6C63FF),
                      onSurface: Colors.white,
                      surface: Color(0xFF1A1A2E),
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: widget.habit.createdAt,
                    lastDate: DateTime.now(),
                    onDateChanged: (date) {
                      setDialogState(() => selectedDate = date);
                    },
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t['cancel']!, style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final dateStr = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';

                  if (widget.habit.hasProgress && widget.onAddProgress != null) {
                    Navigator.pop(context);
                    _showProgressDialog(color, dateStr);
                  } else {
                    final provider = context.read<HabitProvider>();
                    provider.toggleHabitForDate(widget.habit.id, dateStr);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${t['mark']} ${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'),
                        backgroundColor: const Color(0xFF4ECDC4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(t['mark']!, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProgressDialog(Color color, String dateStr) {
    final currentProgress = widget.habit.getProgressForDate(DateTime.parse(dateStr));
    double tempProgress = currentProgress;

    showDialog(
      context: context,
      builder: (context) {
        final t = _getTranslations(HabitProvider.of(context).language);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              '${t['progress_for']} ${dateStr.split('-').reversed.join('.')}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${t['current_val']}: ${tempProgress.toStringAsFixed(0)} / ${widget.habit.targetValue.toStringAsFixed(0)} ${widget.habit.unit}',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProgressButtonDialog(color, -widget.habit.targetValue * 0.25, '-25%', setDialogState, tempProgress, dateStr),
                    _buildProgressButtonDialog(color, widget.habit.targetValue * 0.1, '+10%', setDialogState, tempProgress, dateStr),
                    _buildProgressButtonDialog(color, widget.habit.targetValue * 0.25, '+25%', setDialogState, tempProgress, dateStr),
                    _buildProgressButtonDialog(color, widget.habit.targetValue * 0.5, '+50%', setDialogState, tempProgress, dateStr),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t['cancel']!, style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${t['mark']} ${dateStr.split('-').reversed.join('.')}'),
                      backgroundColor: const Color(0xFF4ECDC4),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(t['done']!, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressButtonDialog(Color color, double value, String label, Function(Function()) setDialogState, double currentProgress, String dateStr) {
    return InkWell(
      onTap: () {
        final provider = context.read<HabitProvider>();
        provider.updateProgressForDate(widget.habit.id, dateStr, value);
        setDialogState(() {});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Map<String, String> _getTranslations(String language) {
    if (language == 'en') {
      return {
        'week': 'Week',
        'month': 'Month',
        'best': 'Best',
        'stats': 'Stats',
        'mark_date': 'Mark for date',
        'reset_progress': 'Reset progress',
        'edit': 'Edit',
        'delete': 'Delete',
        'total': 'Total',
        'current': 'Current',
        'record': 'Record',
        'weekly': 'Weekly',
        'select_date': 'Select date',
        'cancel': 'Cancel',
        'mark': 'Mark',
        'progress_for': 'Progress for',
        'current_val': 'Current',
        'done': 'Done',
      };
    }
    return {
      'week': 'Неделя',
      'month': 'Месяц',
      'best': 'Лучшая',
      'stats': 'Статистика',
      'mark_date': 'Отметить за дату',
      'reset_progress': 'Сбросить прогресс',
      'edit': 'Редактировать',
      'delete': 'Удалить',
      'total': 'Всего',
      'current': 'Текущая',
      'record': 'Рекорд',
      'weekly': 'За неделю',
      'select_date': 'Выберите дату',
      'cancel': 'Отмена',
      'mark': 'Отметить',
      'progress_for': 'Прогресс за',
      'current_val': 'Текущий',
      'done': 'Готово',
    };
  }
}
