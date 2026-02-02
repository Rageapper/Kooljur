import 'package:flutter/material.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:myapp/core/models/final_grade_model.dart';
import 'package:intl/intl.dart';

class AdminGradesScreen extends StatefulWidget {
  const AdminGradesScreen({super.key});

  @override
  State<AdminGradesScreen> createState() => _AdminGradesScreenState();
}

class _AdminGradesScreenState extends State<AdminGradesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GradeModel> _grades = [];
  List<FinalGradeModel> _finalGrades = [];
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final grades = await DataService.getAllGrades();
    final finalGrades = await DataService.getAllFinalGrades();
    final users = await DataService.getAllUsers();
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _finalGrades = finalGrades;
      _users = users;
      _isLoading = false;
    });
  }

  String _getUserName(String userId) {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      // Если ФИО пустое, показываем логин
      final fullName = '${user.lastName} ${user.firstName} ${user.middleName}'.trim();
      if (fullName.isEmpty || fullName == '  ') {
        return user.login.isNotEmpty ? user.login : 'Пользователь ${user.id}';
      }
      return fullName;
    } catch (e) {
      // Если пользователь не найден, показываем ID
      return 'Пользователь $userId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Управление оценками',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_tabController.index == 0) {
                    _showAddGradeDialog(context);
                  } else {
                    _showAddFinalGradeDialog(context);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(_tabController.index == 0
                    ? 'Добавить оценку'
                    : 'Добавить итоговую оценку'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Обычные оценки'),
              Tab(text: 'Итоговые оценки'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGradesTab(),
                      _buildFinalGradesTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTab() {
    if (_grades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Нет оценок'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Ученик')),
            DataColumn(label: Text('Предмет')),
            DataColumn(label: Text('Оценка')),
            DataColumn(label: Text('Дата')),
            DataColumn(label: Text('Комментарий')),
            DataColumn(label: Text('Действия')),
          ],
          rows: _grades.map((grade) {
            return DataRow(
              cells: [
                DataCell(Text(_getUserName(grade.userId))),
                DataCell(Text(grade.subject)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(grade.grade),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      grade.grade.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(DateFormat('dd.MM.yyyy').format(grade.date))),
                DataCell(Text(grade.comment ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _deleteGrade(grade),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinalGradesTab() {
    if (_finalGrades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Нет итоговых оценок'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Ученик')),
            DataColumn(label: Text('Предмет')),
            DataColumn(label: Text('Оценка')),
            DataColumn(label: Text('Период')),
            DataColumn(label: Text('Дата')),
            DataColumn(label: Text('Действия')),
          ],
          rows: _finalGrades.map((grade) {
            return DataRow(
              cells: [
                DataCell(Text(_getUserName(grade.userId))),
                DataCell(Text(grade.subject)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(grade.grade),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      grade.grade.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(grade.period)),
                DataCell(Text(DateFormat('dd.MM.yyyy').format(grade.date))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _deleteFinalGrade(grade),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddGradeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    UserModel? selectedUser;
    final subjectController = TextEditingController();
    int? selectedGrade;
    DateTime? selectedDate;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить оценку'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<UserModel>(
                      decoration: const InputDecoration(
                        labelText: 'Ученик',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedUser,
                      items: _users.map((user) {
                        return DropdownMenuItem(
                          value: user,
                          child: Text(
                              '${user.lastName} ${user.firstName} ${user.middleName}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUser = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Выберите ученика' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Предмет',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите предмет' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Оценка',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedGrade,
                      items: [2, 3, 4, 5].map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(grade.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGrade = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Выберите оценку' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Дата',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedDate != null
                            ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                            : '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      validator: (value) =>
                          selectedDate == null ? 'Выберите дату' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Комментарий (необязательно)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedUser != null &&
                    selectedGrade != null &&
                    selectedDate != null) {
                  final grade = GradeModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: selectedUser!.id,
                    subject: subjectController.text.trim(),
                    grade: selectedGrade!,
                    date: selectedDate!,
                    comment: commentController.text.trim().isEmpty
                        ? null
                        : commentController.text.trim(),
                  );

                  final success = await DataService.addGrade(grade);
                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Оценка добавлена')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка при добавлении')),
                      );
                    }
                  }
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFinalGradeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    UserModel? selectedUser;
    final subjectController = TextEditingController();
    int? selectedGrade;
    final periodController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить итоговую оценку'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<UserModel>(
                      decoration: const InputDecoration(
                        labelText: 'Ученик',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedUser,
                      items: _users.map((user) {
                        return DropdownMenuItem(
                          value: user,
                          child: Text(
                              '${user.lastName} ${user.firstName} ${user.middleName}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUser = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Выберите ученика' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Предмет',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите предмет' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Оценка',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedGrade,
                      items: [2, 3, 4, 5].map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(grade.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGrade = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Выберите оценку' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: periodController,
                      decoration: const InputDecoration(
                        labelText: 'Период (например: 1 четверть, Годовая)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите период' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Дата',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedDate != null
                            ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                            : '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      validator: (value) =>
                          selectedDate == null ? 'Выберите дату' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedUser != null &&
                    selectedGrade != null &&
                    selectedDate != null) {
                  final grade = FinalGradeModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: selectedUser!.id,
                    subject: subjectController.text.trim(),
                    grade: selectedGrade!,
                    period: periodController.text.trim(),
                    date: selectedDate!,
                  );

                  final success = await DataService.addFinalGrade(grade);
                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Итоговая оценка добавлена')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка при добавлении')),
                      );
                    }
                  }
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGrade(GradeModel grade) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить оценку'),
        content: const Text('Вы уверены, что хотите удалить эту оценку?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DataService.deleteGrade(grade.id);
      if (mounted) {
        if (success) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Оценка удалена')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении')),
          );
        }
      }
    }
  }

  Future<void> _deleteFinalGrade(FinalGradeModel grade) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить итоговую оценку'),
        content: const Text('Вы уверены, что хотите удалить эту итоговую оценку?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DataService.deleteFinalGrade(grade.id);
      if (mounted) {
        if (success) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Итоговая оценка удалена')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении')),
          );
        }
      }
    }
  }
}
