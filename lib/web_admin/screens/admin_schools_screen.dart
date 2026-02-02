import 'package:flutter/material.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/school_model.dart';
import 'admin_classes_screen.dart';

class AdminSchoolsScreen extends StatefulWidget {
  const AdminSchoolsScreen({super.key});

  @override
  State<AdminSchoolsScreen> createState() => _AdminSchoolsScreenState();
}

class _AdminSchoolsScreenState extends State<AdminSchoolsScreen> {
  List<SchoolModel> _schools = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() {
      _isLoading = true;
    });

    final schools = await DataService.getAllSchools();
    if (mounted) {
      setState(() {
        _schools = schools;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddSchoolDialog() async {
    _nameController.clear();
    _addressController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить школу'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название школы',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Адрес',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                  const SnackBar(content: Text('Введите название школы')),
                );
                return;
              }

              final school = SchoolModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text.trim(),
                address: _addressController.text.trim(),
                createdAt: DateTime.now(),
              );

              final success = await DataService.createSchool(school);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _loadSchools();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Школа добавлена')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка при добавлении школы')),
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

  Future<void> _deleteSchool(SchoolModel school) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить школу?'),
        content: Text('Вы уверены, что хотите удалить школу "${school.name}"?'),
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
      final success = await DataService.deleteSchool(school.id);
      if (mounted) {
        if (success) {
          _loadSchools();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Школа удалена')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении школы')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление школами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSchoolDialog,
            tooltip: 'Добавить школу',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schools.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Нет школ'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddSchoolDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить школу'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _schools.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final school = _schools[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.school),
                        title: Text(school.name),
                        subtitle: school.address.isNotEmpty
                            ? Text(school.address)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.class_, color: Colors.blue),
                              tooltip: 'Управление классами',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminClassesScreen(school: school),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSchool(school),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
