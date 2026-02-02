import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';

class SferumScreen extends StatelessWidget {
  const SferumScreen({super.key});

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
          'Сферум',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.groups,
                color: AppColors.getWhite(context),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Сферум',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Интеграция с платформой Сферум будет доступна в ближайшее время',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Открыть браузер с Сферум
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Открыть в браузере',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
