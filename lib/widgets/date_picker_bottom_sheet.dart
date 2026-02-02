import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerBottomSheet({
    Key? key,
    this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  DateTime? _selectedDate;
  final List<DateTime> _weeks = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _generateWeeks();
    _animationController.forward();
  }

  void _generateWeeks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Начинаем с понедельника текущей недели
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    
    // Генерируем 7 недель (3 недели назад, текущая, 3 недели вперед)
    for (int i = -3; i <= 3; i++) {
      final weekStart = currentWeekStart.add(Duration(days: i * 7));
      _weeks.add(weekStart);
    }
  }

  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final startFormat = DateFormat('dd.MM');
    final endFormat = DateFormat('dd.MM');
    return '${startFormat.format(weekStart)}-${endFormat.format(weekEnd)}';
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    return weekStart.year == currentWeekStart.year &&
        weekStart.month == currentWeekStart.month &&
        weekStart.day == currentWeekStart.day;
  }

  bool _isSelectedWeek(DateTime weekStart) {
    if (_selectedDate == null) return false;
    final selectedWeekStart = _selectedDate!.subtract(
      Duration(days: _selectedDate!.weekday - 1),
    );
    return weekStart.year == selectedWeekStart.year &&
        weekStart.month == selectedWeekStart.month &&
        weekStart.day == selectedWeekStart.day;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF0F0E13) : Colors.white;
    final cardColor = isDarkMode
        ? const Color(0xFF202125)
        : const Color(0xFFF5F5F5);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 30),
                      Text(
                        "Выбор недели",
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.getTextSecondary(context),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Список недель
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: _weeks.length,
                    itemBuilder: (context, index) {
                      final weekStart = _weeks[index];
                      final isSelected = _isSelectedWeek(weekStart);
                      final isCurrent = _isCurrentWeek(weekStart);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = weekStart;
                          });
                          widget.onDateSelected(weekStart);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        splashColor: AppColors.getAccentColor(context)
                            .withOpacity(0.2),
                        highlightColor: AppColors.getAccentColor(context)
                            .withOpacity(0.1),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.getAccentColor(context)
                                    .withOpacity(0.1)
                                : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.getAccentColor(context)
                                  : Colors.transparent,
                              width: isSelected ? 2 : 0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _formatWeekRange(weekStart),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.getAccentColor(context)
                                        : AppColors.getTextPrimary(context),
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.getAccentColor(context)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Текущая',
                                    style: TextStyle(
                                      color: AppColors.getAccentColor(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (isSelected)
                                const SizedBox(width: 8),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.getAccentColor(context),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
