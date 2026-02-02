import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/models/schedule_model.dart';
import 'package:myapp/core/models/homework_model.dart';
import 'package:myapp/core/models/grade_model.dart';

class DiaryLessonItem extends StatelessWidget {
  final ScheduleModel schedule;
  final List<HomeworkModel> homework;
  final List<GradeModel> grades;
  final DateTime date;

  const DiaryLessonItem({
    Key? key,
    required this.schedule,
    required this.homework,
    required this.grades,
    required this.date,
  }) : super(key: key);

  Color _getGradeColor(int grade) {
    if (grade >= 4) return Colors.green;
    if (grade == 3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Фильтруем ДЗ по предмету и дате
    final homeworkForSubject = homework.where((h) {
      final hwDate = DateTime(h.date.year, h.date.month, h.date.day);
      return h.subject == schedule.subject && hwDate.isAtSameMomentAs(dateOnly);
    }).toList();

    // Фильтруем оценки по предмету и дате
    final gradesForSubject = grades.where((g) {
      final gradeDate = DateTime(g.date.year, g.date.month, g.date.day);
      return g.subject == schedule.subject &&
          gradeDate.isAtSameMomentAs(dateOnly);
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок урока: предмет и время
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.subject,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Домашнее задание
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.home,
                          color: AppColors.getAccentColor(context),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: homeworkForSubject.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: homeworkForSubject.map((hw) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        hw.description,
                                        style: TextStyle(
                                          color: AppColors.getTextPrimary(
                                            context,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Text(
                                  'Нету заданий',
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    // Оценки под ДЗ
                    if (gradesForSubject.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Wrap(
                          spacing: 6,
                          children: gradesForSubject.map((grade) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getGradeColor(
                                  grade.grade,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getGradeColor(grade.grade),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                grade.grade.toString(),
                                style: TextStyle(
                                  color: _getGradeColor(grade.grade),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${schedule.startTime}–${schedule.endTime}',
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
