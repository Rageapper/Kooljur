import 'package:flutter/material.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/announcement_model.dart';
import 'package:myapp/core/models/message_model.dart';
import 'package:myapp/web_admin/services/notification_service.dart';
import 'package:intl/intl.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  List<AnnouncementModel> _announcements = [];
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final announcements = await DataService.getAllAnnouncements();
    final users = await DataService.getAllUsers();
    setState(() {
      _announcements = announcements;
      _users = users;
      _isLoading = false;
    });
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
                'Управление объявлениями',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showSendMessageDialog(context),
                    icon: const Icon(Icons.message),
                    label: const Text('Отправить сообщение'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAnnouncementDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Создать объявление'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _announcements.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('Нет объявлений'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            final announcement = _announcements[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: Icon(
                                  announcement.isImportant
                                      ? Icons.priority_high
                                      : Icons.info_outline,
                                  color: announcement.isImportant
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        announcement.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (announcement.isImportant)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Важно',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(announcement.content),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Автор: ${announcement.author}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Дата: ${DateFormat('dd.MM.yyyy').format(announcement.date)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (announcement.targetUserIds.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Для: ${announcement.targetUserIds.length} пользователей',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAnnouncement(announcement),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final authorController = TextEditingController(text: 'Администратор');
    bool isImportant = false;
    List<String> selectedUserIds = [];
    bool sendToAll = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Создать объявление'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    TextFormField(
                      controller: authorController,
                      decoration: const InputDecoration(
                        labelText: 'Автор',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите автора' : null,
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
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Отправить всем пользователям'),
                      value: sendToAll,
                      onChanged: (value) {
                        setDialogState(() {
                          sendToAll = value ?? true;
                          if (sendToAll) {
                            selectedUserIds = [];
                          }
                        });
                      },
                    ),
                    if (!sendToAll) ...[
                      const SizedBox(height: 16),
                      const Text('Выберите пользователей:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final isSelected =
                                selectedUserIds.contains(user.id);
                            return CheckboxListTile(
                              title: Text(
                                  '${user.lastName} ${user.firstName} ${user.middleName}'),
                              subtitle: Text(user.className),
                              value: isSelected,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selectedUserIds.add(user.id);
                                  } else {
                                    selectedUserIds.remove(user.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
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
                  final announcement = AnnouncementModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    author: authorController.text.trim(),
                    date: DateTime.now(),
                    isImportant: isImportant,
                    targetUserIds: sendToAll ? [] : selectedUserIds,
                  );

                  final success =
                      await DataService.addAnnouncement(announcement);
                  
                  // Отправляем push-уведомления
                  if (success) {
                    final targetUserIds = sendToAll ? _users.map((u) => u.id).toList() : selectedUserIds;
                    if (targetUserIds.isNotEmpty) {
                      await NotificationService.sendNotificationsToUsers(
                        userIds: targetUserIds,
                        title: isImportant ? '⚠️ Важное объявление' : 'Новое объявление',
                        body: titleController.text.trim(),
                        data: {
                          'type': 'announcement',
                          'announcementId': announcement.id,
                        },
                      );
                    }
                  }
                  
                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Объявление создано')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка при создании')),
                      );
                    }
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

  void _showSendMessageDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final senderController = TextEditingController(text: 'Администратор');
    final contentController = TextEditingController();
    List<String> selectedUserIds = [];
    bool sendToAll = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Отправить сообщение'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: senderController,
                      decoration: const InputDecoration(
                        labelText: 'Отправитель',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите отправителя' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Сообщение',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите сообщение' : null,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Отправить всем пользователям'),
                      value: sendToAll,
                      onChanged: (value) {
                        setDialogState(() {
                          sendToAll = value ?? false;
                          if (sendToAll) {
                            selectedUserIds = [];
                          }
                        });
                      },
                    ),
                    if (!sendToAll) ...[
                      const SizedBox(height: 16),
                      const Text('Выберите получателя(ей):'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final isSelected = selectedUserIds.contains(user.id);
                            return CheckboxListTile(
                              title: Text(
                                  '${user.lastName} ${user.firstName} ${user.middleName}'),
                              subtitle: Text('${user.login} - ${user.className}'),
                              value: isSelected,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selectedUserIds.add(user.id);
                                  } else {
                                    selectedUserIds.remove(user.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      if (selectedUserIds.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Выберите хотя бы одного получателя',
                            style: TextStyle(color: Colors.red[700], fontSize: 12),
                          ),
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
                  if (sendToAll) {
                    // Отправка всем пользователям
                    int successCount = 0;
                    for (final user in _users) {
                      final message = MessageModel(
                        id:
                            '${DateTime.now().millisecondsSinceEpoch}_${user.id}',
                        userId: user.id,
                        sender: senderController.text.trim(),
                        content: contentController.text.trim(),
                        date: DateTime.now(),
                        isRead: false,
                      );
                      final success = await DataService.addMessage(message);
                      if (success) successCount++;
                    }
                    
                    // Отправляем push-уведомления всем пользователям
                    if (successCount > 0) {
                      final allUserIds = _users.map((u) => u.id).toList();
                      await NotificationService.sendNotificationsToUsers(
                        userIds: allUserIds,
                        title: 'Новое сообщение',
                        body: senderController.text.trim().isNotEmpty 
                            ? senderController.text.trim()
                            : 'У вас новое сообщение',
                        data: {
                          'type': 'message',
                        },
                      );
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Сообщение отправлено $successCount пользователям')),
                      );
                    }
                  } else {
                    // Отправка выбранным пользователям
                    if (selectedUserIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Выберите хотя бы одного получателя')),
                      );
                      return;
                    }
                    
                    int successCount = 0;
                    for (final userId in selectedUserIds) {
                      final message = MessageModel(
                        id:
                            '${DateTime.now().millisecondsSinceEpoch}_$userId',
                        userId: userId,
                        sender: senderController.text.trim(),
                        content: contentController.text.trim(),
                        date: DateTime.now(),
                        isRead: false,
                      );

                      final success = await DataService.addMessage(message);
                      if (success) successCount++;
                    }
                    
                    // Отправляем push-уведомления выбранным пользователям
                    if (successCount > 0) {
                      await NotificationService.sendNotificationsToUsers(
                        userIds: selectedUserIds,
                        title: 'Новое сообщение',
                        body: senderController.text.trim().isNotEmpty 
                            ? senderController.text.trim()
                            : 'У вас новое сообщение',
                        data: {
                          'type': 'message',
                        },
                      );
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Отправлено $successCount из ${selectedUserIds.length} сообщений'),
                          backgroundColor:
                              successCount == selectedUserIds.length
                                  ? Colors.green
                                  : Colors.orange,
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
      ),
    );
  }

  Future<void> _deleteAnnouncement(AnnouncementModel announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить объявление'),
        content: const Text('Вы уверены, что хотите удалить это объявление?'),
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
      final success = await DataService.deleteAnnouncement(announcement.id);
      if (mounted) {
        if (success) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Объявление удалено')),
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
