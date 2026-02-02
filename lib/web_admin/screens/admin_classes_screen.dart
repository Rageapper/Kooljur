import 'package:flutter/material.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/school_model.dart';
import 'package:myapp/core/models/class_model.dart';
import 'package:myapp/core/models/user_model.dart';

class AdminClassesScreen extends StatefulWidget {
  final SchoolModel school;

  const AdminClassesScreen({super.key, required this.school});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  List<ClassModel> _classes = [];
  List<UserModel> _users = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final classes = await DataService.getClassesBySchool(widget.school.id);
    final users = await DataService.getUsersBySchool(widget.school.name);
    
    if (mounted) {
      setState(() {
        _classes = classes;
        _users = users;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddClassDialog() async {
    _nameController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить класс'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Название класса',
            border: OutlineInputBorder(),
            hintText: 'Например: 10А, 11Б',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите название класса')),
                );
                return;
              }

              final classModel = ClassModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                schoolId: widget.school.id,
                schoolName: widget.school.name,
                name: _nameController.text.trim(),
                createdAt: DateTime.now(),
              );

              final success = await DataService.createClass(classModel);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Класс добавлен')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка при добавлении класса')),
                  );
                }
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClass(ClassModel classModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить класс?'),
        content: Text('Вы уверены, что хотите удалить класс "${classModel.name}"?'),
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

    if (confirm == true) {
      final success = await DataService.deleteClass(classModel.id);
      if (mounted) {
        if (success) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Класс удален')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении класса')),
          );
        }
      }
    }
  }

  Future<void> _showUsersInClass(ClassModel classModel) async {
    final users = await DataService.getUsersByClass(classModel.name);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ученики класса ${classModel.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: users.isEmpty
              ? const Text('В классе нет учеников')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text('${user.lastName} ${user.firstName} ${user.middleName}'),
                      subtitle: Text(user.login),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMoveUserDialog() async {
    if (_users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет пользователей в этой школе')),
      );
      return;
    }

    UserModel? selectedUser;
    ClassModel? selectedClass;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Переместить пользователя в класс'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Выбор пользователя
              DropdownButtonFormField<UserModel>(
                decoration: const InputDecoration(
                  labelText: 'Пользователь',
                  border: OutlineInputBorder(),
                ),
                items: _users.map((user) {
                  return DropdownMenuItem<UserModel>(
                    value: user,
                    child: Text('${user.lastName} ${user.firstName} ${user.middleName} (${user.login})'),
                  );
                }).toList(),
                onChanged: (user) {
                  setDialogState(() {
                    selectedUser = user;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Выбор класса
              DropdownButtonFormField<ClassModel>(
                decoration: const InputDecoration(
                  labelText: 'Класс',
                  border: OutlineInputBorder(),
                ),
                items: _classes.map((classModel) {
                  return DropdownMenuItem<ClassModel>(
                    value: classModel,
                    child: Text(classModel.name),
                  );
                }).toList(),
                onChanged: (classModel) {
                  setDialogState(() {
                    selectedClass = classModel;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: selectedUser != null && selectedClass != null
                  ? () async {
                      final updatedUser = selectedUser!.copyWith(
                        className: selectedClass!.name,
                      );
                      final success = await DataService.updateUser(updatedUser);
                      if (mounted) {
                        Navigator.pop(context);
                        if (success) {
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пользователь перемещен в класс')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ошибка при перемещении пользователя')),
                          );
                        }
                      }
                    }
                  : null,
              child: const Text('Переместить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Классы: ${widget.school.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showMoveUserDialog,
            tooltip: 'Переместить пользователя в класс',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddClassDialog,
            tooltip: 'Добавить класс',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Статистика
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Классов', _classes.length.toString()),
                      _buildStatCard('Учеников', _users.length.toString()),
                    ],
                  ),
                ),
                const Divider(),
                // Список классов
                Expanded(
                  child: _classes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.class_, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('Нет классов'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _showAddClassDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Добавить класс'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _classes.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final classModel = _classes[index];
                            final usersInClass = _users.where((u) => u.className == classModel.name).length;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(Icons.class_),
                                title: Text(classModel.name),
                                subtitle: Text('Учеников: $usersInClass'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.people, color: Colors.blue),
                                      tooltip: 'Показать учеников',
                                      onPressed: () => _showUsersInClass(classModel),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteClass(classModel),
                                    ),
                                  ],
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

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
