import 'package:flutter/material.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/services/schedule_seed_service.dart';
import 'package:myapp/core/models/schedule_model.dart';
import 'package:myapp/core/models/user_model.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  List<ScheduleModel> _schedule = [];
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _selectedUserId;
  
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _dayOfWeekController = TextEditingController();
  final TextEditingController _lessonNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _classroomController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();

  final List<String> _daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _dayOfWeekController.dispose();
    _lessonNumberController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _classroomController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final users = await DataService.getAllUsers();
    final schedule = await DataService.getScheduleByUserId(_selectedUserId ?? '');
    
    if (mounted) {
      setState(() {
        _users = users;
        _schedule = schedule;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadScheduleForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      setState(() {
        _schedule = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final schedule = await DataService.getScheduleByUserId(userId);
    
    if (mounted) {
      setState(() {
        _schedule = schedule;
        _schedule.sort((a, b) {
          final dayOrder = _daysOfWeek.indexOf(a.dayOfWeek) - _daysOfWeek.indexOf(b.dayOfWeek);
          if (dayOrder != 0) return dayOrder;
          return a.lessonNumber.compareTo(b.lessonNumber);
        });
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddScheduleDialog() async {
    if (_selectedUserId == null || _selectedUserId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите пользователя')),
      );
      return;
    }

    _subjectController.clear();
    _dayOfWeekController.clear();
    _lessonNumberController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _classroomController.clear();
    _teacherController.clear();

    String? selectedDay = _daysOfWeek.first;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить урок'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Предмет',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'День недели',
                    border: OutlineInputBorder(),
                  ),
                  items: _daysOfWeek.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDay = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lessonNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Номер урока',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Время начала (например, 09:00)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Время окончания (например, 09:45)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _classroomController,
                  decoration: const InputDecoration(
                    labelText: 'Кабинет (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Учитель (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_subjectController.text.isEmpty ||
                    selectedDay == null ||
                    _lessonNumberController.text.isEmpty ||
                    _startTimeController.text.isEmpty ||
                    _endTimeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните все обязательные поля')),
                  );
                  return;
                }

                final lessonNumber = int.tryParse(_lessonNumberController.text);
                if (lessonNumber == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Номер урока должен быть числом')),
                  );
                  return;
                }

                final schedule = ScheduleModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: _selectedUserId!,
                  subject: _subjectController.text.trim(),
                  dayOfWeek: selectedDay!,
                  lessonNumber: lessonNumber,
                  startTime: _startTimeController.text.trim(),
                  endTime: _endTimeController.text.trim(),
                  classroom: _classroomController.text.trim().isEmpty
                      ? null
                      : _classroomController.text.trim(),
                  teacher: _teacherController.text.trim().isEmpty
                      ? null
                      : _teacherController.text.trim(),
                );

                final success = await DataService.createSchedule(schedule);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Урок добавлен')),
                    );
                    _loadScheduleForUser(_selectedUserId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ошибка при добавлении урока')),
                    );
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

  Future<void> _deleteSchedule(ScheduleModel schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить урок?'),
        content: Text('Удалить урок "${schedule.subject}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DataService.deleteSchedule(schedule.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Урок удален')),
          );
          _loadScheduleForUser(_selectedUserId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении урока')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и выбор пользователя
          Row(
            children: [
              const Text(
                'Расписание',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 24),
              DropdownButton<String>(
                value: _selectedUserId,
                hint: const Text('Выберите пользователя'),
                items: _users.map((user) {
                  final displayName = '${user.lastName} ${user.firstName} ${user.middleName}'.trim();
                  final name = displayName.isEmpty ? user.email : displayName;
                  return DropdownMenuItem(
                    value: user.id,
                    child: Text('$name (${user.className})'),
                  );
                }).toList(),
                onChanged: (userId) {
                  setState(() {
                    _selectedUserId = userId;
                  });
                  _loadScheduleForUser(userId);
                },
              ),
              const Spacer(),
              if (_selectedUserId != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    await ScheduleSeedService.createSampleSchedule(_selectedUserId!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Примерное расписание создано')),
                      );
                      _loadScheduleForUser(_selectedUserId);
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Создать пример'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddScheduleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Добавить урок'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Список расписания
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _schedule.isEmpty
                    ? Center(
                        child: Text(
                          _selectedUserId == null
                              ? 'Выберите пользователя'
                              : 'Расписание не найдено',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _schedule.length,
                        itemBuilder: (context, index) {
                          final lesson = _schedule[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                lesson.subject,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${lesson.dayOfWeek}, ${lesson.lessonNumber} урок'),
                                  Text('${lesson.startTime} - ${lesson.endTime}'),
                                  if (lesson.classroom != null)
                                    Text('Кабинет: ${lesson.classroom}'),
                                  if (lesson.teacher != null)
                                    Text('Учитель: ${lesson.teacher}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSchedule(lesson),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
