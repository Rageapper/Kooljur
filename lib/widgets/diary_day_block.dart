import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/models/schedule_model.dart';
import 'package:myapp/core/models/homework_model.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:myapp/widgets/diary_lesson_item.dart';
import 'package:intl/intl.dart';

class DiaryDayBlock extends StatelessWidget {
  final String dayOfWeek;
  final DateTime date;
  final List<ScheduleModel> lessons;
  final List<HomeworkModel> homework;
  final List<GradeModel> grades;
  final bool isToday;

  const DiaryDayBlock({
    Key? key,
    required this.dayOfWeek,
    required this.date,
    required this.lessons,
    required this.homework,
    required this.grades,
    this.isToday = false,
  }) : super(key: key);

  String _getDayName() {
    return dayOfWeek;
  }

  String _getDateString() {
    return DateFormat('d MMMM', 'ru').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 0).copyWith(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(
                color: AppColors.getAccentColor(context),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок дня
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.getAccentColor(context).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(),
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDateString(),
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getAccentColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Сегодня',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Список уроков
          if (lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Нет уроков',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: lessons.map((lesson) {
                  return DiaryLessonItem(
                    schedule: lesson,
                    homework: homework,
                    grades: grades,
                    date: date,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
