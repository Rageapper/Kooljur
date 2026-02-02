import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/final_grade_model.dart';
import 'package:intl/intl.dart';

class FinalGradesScreen extends StatefulWidget {
  const FinalGradesScreen({super.key});

  @override
  State<FinalGradesScreen> createState() => _FinalGradesScreenState();
}

class _FinalGradesScreenState extends State<FinalGradesScreen> {
  List<FinalGradeModel> _finalGrades = [];
  bool _isLoading = true;
  Map<String, List<FinalGradeModel>> _gradesBySubject = {};

  @override
  void initState() {
    super.initState();
    _loadFinalGrades();
  }

  Future<void> _loadFinalGrades() async {
    setState(() {
      _isLoading = true;
    });
    final currentUser = await DataService.getCurrentUser();
    if (currentUser != null) {
      final grades = await DataService.getFinalGradesByUserId(currentUser.id);
      // Группируем оценки по предметам
      final Map<String, List<FinalGradeModel>> grouped = {};
      for (final grade in grades) {
        if (!grouped.containsKey(grade.subject)) {
          grouped[grade.subject] = [];
        }
        grouped[grade.subject]!.add(grade);
      }
      // Сортируем оценки в каждом предмете по дате
      for (final key in grouped.keys) {
        grouped[key]!.sort((a, b) => b.date.compareTo(a.date));
      }
      setState(() {
        _finalGrades = grades;
        _gradesBySubject = grouped;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getSubjectIcon(String subject) {
    final lowerSubject = subject.toLowerCase();
    if (lowerSubject.contains('матем')) return Icons.calculate;
    if (lowerSubject.contains('физик')) return Icons.science;
    if (lowerSubject.contains('русск')) return Icons.menu_book;
    if (lowerSubject.contains('истори')) return Icons.history_edu;
    if (lowerSubject.contains('английск')) return Icons.language;
    if (lowerSubject.contains('хими')) return Icons.science_outlined;
    if (lowerSubject.contains('биолог')) return Icons.eco;
    if (lowerSubject.contains('географ')) return Icons.map;
    return Icons.book;
  }

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
          'Итоговые отметки',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.getAccentColor(context),
              ),
            )
          : _gradesBySubject.isEmpty
              ? Center(
                  child: Text(
                    'Нет итоговых оценок',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFinalGrades,
                  color: AppColors.getAccentColor(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: _gradesBySubject.entries.map((entry) {
                      final subject = entry.key;
                      final grades = entry.value;
                      return _buildSubjectCard(
                        context: context,
                        subject: subject,
                        grades: grades,
                        icon: _getSubjectIcon(subject),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildSubjectCard({
    required BuildContext context,
    required String subject,
    required List<FinalGradeModel> grades,
    required IconData icon,
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.getWhite(context), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...grades.map((grade) {
            Color gradeColor = grade.grade == 5
                ? Colors.green
                : grade.grade == 4
                    ? Colors.blue
                    : grade.grade == 3
                        ? Colors.orange
                        : Colors.red;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: gradeColor, width: 2),
                    ),
                    child: Text(
                      grade.grade.toString(),
                      style: TextStyle(
                        color: gradeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      grade.period,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy').format(grade.date),
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 12,
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
