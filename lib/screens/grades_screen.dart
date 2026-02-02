import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:intl/intl.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<GradeModel> _grades = [];
  bool _isLoading = true;
  Map<String, List<GradeModel>> _gradesBySubject = {};

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
    });
    final currentUser = await DataService.getCurrentUser();
    if (currentUser != null) {
      final grades = await DataService.getGradesByUserId(currentUser.id);
      // Группируем оценки по предметам
      final Map<String, List<GradeModel>> grouped = {};
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
        _grades = grades;
        _gradesBySubject = grouped;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateAverage(List<GradeModel> grades) {
    if (grades.isEmpty) return 0.0;
    final sum = grades.fold<int>(0, (sum, grade) => sum + grade.grade);
    return sum / grades.length;
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
          'Отметки',
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
                    'Нет оценок',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGrades,
                  color: AppColors.getAccentColor(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: _gradesBySubject.entries.map((entry) {
                      final subject = entry.key;
                      final grades = entry.value;
                      final average = _calculateAverage(grades);
                      return _buildSubjectCard(
                        context: context,
                        subject: subject,
                        grades: grades.map((g) => g.grade).toList(),
                        average: average,
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
    required List<int> grades,
    required double average,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  average.toStringAsFixed(1),
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grades.map((grade) {
              Color gradeColor = grade == 5
                  ? Colors.green
                  : grade == 4
                      ? Colors.blue
                      : grade == 3
                          ? Colors.orange
                          : Colors.red;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: gradeColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    grade.toString(),
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
