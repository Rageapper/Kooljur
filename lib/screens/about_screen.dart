import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'О программе',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.school,
                color: AppColors.getWhite(context),
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Электронный дневник',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Версия 1.0.0',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoCard(
            context: context,
            icon: Icons.info_outline,
            title: 'Описание',
            content: 'Приложение для просмотра оценок, расписания и общения с учителями.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            icon: Icons.developer_mode,
            title: 'Разработчик',
            content: 'Разработано для образовательных учреждений',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            icon: Icons.email,
            title: 'Контакты',
            content: 'support@diary.app',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            icon: Icons.copyright,
            title: 'Авторские права',
            content: '© 2025 Электронный дневник. Все права защищены.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.getWhite(context), size: 24),
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
                  content,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
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
}
