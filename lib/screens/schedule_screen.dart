import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      {'day': 'Понедельник', 'lessons': ['Математика', 'Физика', 'Русский язык', 'История']},
      {'day': 'Вторник', 'lessons': ['Английский язык', 'Математика', 'Физика', 'Физкультура']},
      {'day': 'Среда', 'lessons': ['Русский язык', 'История', 'Математика', 'Английский язык']},
      {'day': 'Четверг', 'lessons': ['Физика', 'Математика', 'Русский язык', 'История']},
      {'day': 'Пятница', 'lessons': ['Английский язык', 'Физика', 'Математика', 'Физкультура']},
    ];

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getCardColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getWhite(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Расписание',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        children: days.map((dayData) => _buildDayCard(
          context: context,
          day: dayData['day'] as String,
          lessons: dayData['lessons'] as List<String>,
        )).toList(),
      ),
    );
  }

  Widget _buildDayCard({
    required BuildContext context,
    required String day,
    required List<String> lessons,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...lessons.asMap().entries.map((entry) {
            int index = entry.key;
            String lesson = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
