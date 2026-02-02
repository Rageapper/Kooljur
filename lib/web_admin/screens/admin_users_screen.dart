import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:myapp/core/models/final_grade_model.dart';
import 'package:myapp/core/models/announcement_model.dart';
import 'package:myapp/core/models/message_model.dart';
import 'package:myapp/core/models/school_model.dart';
import 'package:myapp/core/models/class_model.dart';
import 'package:myapp/web_admin/services/notification_service.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserModel> _users = [];
  List<SchoolModel> _schools = [];
  List<ClassModel> _classes = [];
  bool _isLoading = true;
  String? _selectedSchoolFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final users = await DataService.getAllUsers();
    final schools = await DataService.getAllSchools();
    final classes = await DataService.getAllClasses();
    if (mounted) {
      setState(() {
        _users = users;
        _schools = schools;
        _classes = classes;
        _isLoading = false;
      });
    }
  }

  List<UserModel> get _filteredUsers {
    if (_selectedSchoolFilter == null || _selectedSchoolFilter!.isEmpty) {
      return _users;
    }
    return _users.where((user) => user.school == _selectedSchoolFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Управление пользователями',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Фильтр по школе
              DropdownButton<String>(
                value: _selectedSchoolFilter,
                hint: const Text('Все школы'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Все школы'),
                  ),
                  ..._schools.map((school) {
                    return DropdownMenuItem<String>(
                      value: school.name,
                      child: Text(school.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSchoolFilter = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Пользователи регистрируются через мобильное приложение',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          if (_selectedSchoolFilter != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Показано пользователей: ${_filteredUsers.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Card(
                    child: _filteredUsers.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('Нет пользователей'),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Логин')),
                                DataColumn(label: Text('ФИО')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Телефон')),
                                DataColumn(label: Text('Школа')),
                                DataColumn(label: Text('Класс')),
                                DataColumn(label: Text('Дата регистрации')),
                                DataColumn(label: Text('Действия')),
                              ],
                              rows: _filteredUsers.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user.login)),
                                    DataCell(Text(
                                        '${user.lastName} ${user.firstName} ${user.middleName}')),
                                    DataCell(Text(user.email)),
                                    DataCell(Text(user.phone)),
                                    DataCell(Text(user.school)),
                                    DataCell(Text(user.className)),
                                    DataCell(Text(DateFormat('dd.MM.yyyy')
                                        .format(user.createdAt))),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.message, size: 18, color: Colors.blue),
                                            tooltip: 'Отправить сообщение',
                                            onPressed: () =>
                                                _showSendMessageDialog(context, user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.announcement, size: 18, color: Colors.orange),
                                            tooltip: 'Создать объявление',
                                            onPressed: () =>
                                                _showCreateAnnouncementDialog(context, user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.grade, size: 18, color: Colors.green),
                                            tooltip: 'Поставить оценку',
                                            onPressed: () =>
                                                _showAddGradeDialog(context, user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            tooltip: 'Редактировать',
                                            onPressed: () =>
                                                _showEditUserDialog(context, user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 18, color: Colors.red),
                                            tooltip: 'Удалить',
                                            onPressed: () => _deleteUser(user),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final loginController = TextEditingController(text: user.login);
    final passwordController = TextEditingController(text: user.password);
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final middleNameController = TextEditingController(text: user.middleName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final birthDateController = TextEditingController(text: user.birthDate);
    final schoolController = TextEditingController(text: user.school);
    final classNameController = TextEditingController(text: user.className);
    DateTime? selectedBirthDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Редактировать пользователя'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: loginController,
                      decoration: const InputDecoration(
                        labelText: 'Логин',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите логин' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите пароль' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите фамилию' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: middleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Отчество',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Дата рождения',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedBirthDate ??
                              DateTime.now()
                                  .subtract(const Duration(days: 365 * 15)),
                          firstDate: DateTime(1990),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          selectedBirthDate = date;
                          birthDateController.text =
                              DateFormat('dd.MM.yyyy').format(date);
                          setDialogState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: schoolController,
                      decoration: const InputDecoration(
                        labelText: 'Школа',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите школу' : null,
                    ),
                    const SizedBox(height: 16),
                    // Выбор класса из списка
                    FutureBuilder<List<ClassModel>>(
                      future: DataService.getClassesBySchool(
                        _schools.firstWhere(
                          (s) => s.name == user.school,
                          orElse: () => _schools.isNotEmpty ? _schools.first : SchoolModel(
                            id: '',
                            name: '',
                            address: '',
                            createdAt: DateTime.now(),
                          ),
                        ).id,
                      ),
                      builder: (context, snapshot) {
                        final classes = snapshot.data ?? [];
                        ClassModel? selectedClass;
                        
                        if (classes.isNotEmpty) {
                          selectedClass = classes.firstWhere(
                            (c) => c.name == user.className,
                            orElse: () => classes.first,
                          );
                        }

                        if (classes.isEmpty) {
                          // Если нет классов, показываем текстовое поле
                          return TextFormField(
                            controller: classNameController,
                            decoration: const InputDecoration(
                              labelText: 'Класс (введите вручную)',
                              border: OutlineInputBorder(),
                            ),
                          );
                        }

                        return DropdownButtonFormField<ClassModel>(
                          value: selectedClass,
                          decoration: const InputDecoration(
                            labelText: 'Класс',
                            border: OutlineInputBorder(),
                          ),
                          items: classes.map((classModel) {
                            return DropdownMenuItem<ClassModel>(
                              value: classModel,
                              child: Text(classModel.name),
                            );
                          }).toList(),
                          onChanged: (classModel) {
                            if (classModel != null) {
                              classNameController.text = classModel.name;
                            }
                          },
                          validator: (value) => value == null ? 'Выберите класс' : null,
                        );
                      },
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
                if (formKey.currentState!.validate()) {
                  final updatedUser = user.copyWith(
                    login: loginController.text.trim(),
                    password: passwordController.text.trim(),
                    firstName: firstNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    middleName: middleNameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    birthDate: birthDateController.text.trim(),
                    school: schoolController.text.trim(),
                    className: classNameController.text.trim(),
                  );

                  final success = await DataService.updateUser(updatedUser);
                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пользователь обновлен')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка при обновлении')),
                      );
                    }
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя'),
        content: Text(
            'Вы уверены, что хотите удалить пользователя ${user.lastName} ${user.firstName}?'),
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
      final success = await DataService.deleteUser(user.id);
      if (mounted) {
        if (success) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пользователь удален')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении')),
          );
        }
      }
    }
  }

  void _showSendMessageDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Отправить сообщение: ${user.login}'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Тема сообщения',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Введите тему' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Содержание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Введите содержание' : null,
                ),
              ],
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
              if (formKey.currentState!.validate()) {
                try {
                  final message = MessageModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: user.id,
                    sender: 'Администратор',
                    content: '${subjectController.text.trim()}\n\n${contentController.text.trim()}',
                    date: DateTime.now(),
                    isRead: false,
                  );

                  debugPrint('AdminUsersScreen: Sending message to user ${user.id}');
                  final success = await DataService.addMessage(message);
                  
                  // Отправляем push-уведомление
                  if (success) {
                    await NotificationService.sendNotification(
                      userId: user.id,
                      title: 'Новое сообщение',
                      body: subjectController.text.trim().isNotEmpty 
                          ? subjectController.text.trim()
                          : 'У вас новое сообщение от администратора',
                      data: {
                        'type': 'message',
                        'messageId': message.id,
                      },
                    );
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Сообщение отправлено'
                            : 'Ошибка при отправке. Проверьте консоль для деталей.'),
                        backgroundColor:
                            success ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e, stackTrace) {
                  debugPrint('AdminUsersScreen: Error sending message: $e');
                  debugPrint('AdminUsersScreen: Stack trace: $stackTrace');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isImportant = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Создать объявление для: ${user.login}'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Заголовок',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Введите заголовок' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Содержание',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Введите содержание' : null,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Важное объявление'),
                    value: isImportant,
                    onChanged: (value) {
                      setDialogState(() {
                        isImportant = value ?? false;
                      });
                    },
                  ),
                ],
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
                if (formKey.currentState!.validate()) {
                  final announcement = AnnouncementModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    author: 'Администратор',
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    date: DateTime.now(),
                    isImportant: isImportant,
                    targetUserIds: [user.id],
                  );

                  final success =
                      await DataService.addAnnouncement(announcement);
                  
                  // Отправляем push-уведомление
                  if (success) {
                    await NotificationService.sendNotification(
                      userId: user.id,
                      title: isImportant ? '⚠️ Важное объявление' : 'Новое объявление',
                      body: titleController.text.trim(),
                      data: {
                        'type': 'announcement',
                        'announcementId': announcement.id,
                      },
                    );
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Объявление создано'
                            : 'Ошибка при создании'),
                        backgroundColor:
                            success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final gradeController = TextEditingController();
    final commentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isFinalGrade = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Поставить оценку: ${user.login}'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text('Итоговая оценка'),
                      value: isFinalGrade,
                      onChanged: (value) {
                        setDialogState(() {
                          isFinalGrade = value ?? false;
                        });
                      },
                    ),
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
                    TextFormField(
                      controller: gradeController,
                      decoration: const InputDecoration(
                        labelText: 'Оценка',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Введите оценку';
                        }
                        final grade = int.tryParse(value!);
                        if (grade == null || grade < 1 || grade > 5) {
                          return 'Оценка должна быть от 1 до 5';
                        }
                        return null;
                      },
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
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Дата: ${DateFormat('dd.MM.yyyy').format(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    if (isFinalGrade) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Период',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('1 четверть')),
                          DropdownMenuItem(value: '2', child: Text('2 четверть')),
                          DropdownMenuItem(value: '3', child: Text('3 четверть')),
                          DropdownMenuItem(value: '4', child: Text('4 четверть')),
                          DropdownMenuItem(value: 'year', child: Text('Годовая')),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
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
                if (formKey.currentState!.validate()) {
                  bool success = false;
                  
                  if (isFinalGrade) {
                    final finalGrade = FinalGradeModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user.id,
                      subject: subjectController.text.trim(),
                      grade: int.parse(gradeController.text.trim()),
                      period: '1', // Можно добавить выбор периода
                      date: selectedDate,
                    );
                    success = await DataService.addFinalGrade(finalGrade);
                  } else {
                    final grade = GradeModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user.id,
                      subject: subjectController.text.trim(),
                      grade: int.parse(gradeController.text.trim()),
                      date: selectedDate,
                      comment: commentController.text.trim(),
                    );
                    success = await DataService.addGrade(grade);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Оценка добавлена'
                            : 'Ошибка при добавлении'),
                        backgroundColor:
                            success ? Colors.green : Colors.red,
                      ),
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
}
