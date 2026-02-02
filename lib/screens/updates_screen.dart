import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getCardColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getWhite(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Обновления',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        children: [
          _buildUpdateCard(
            context: context,
            title: 'Новое расписание',
            description: 'Обновлено расписание на следующую неделю',
            date: '25.01.2025',
            icon: Icons.calendar_today,
          ),
          _buildUpdateCard(
            context: context,
            title: 'Новые оценки',
            description: 'Добавлены оценки по математике и физике',
            date: '24.01.2025',
            icon: Icons.grade,
          ),
          _buildUpdateCard(
            context: context,
            title: 'Объявление от классного руководителя',
            description: 'Родительское собрание перенесено на следующую неделю',
            date: '23.01.2025',
            icon: Icons.announcement,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard({
    required BuildContext context,
    required String title,
    required String description,
    required String date,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.getWhite(context), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
