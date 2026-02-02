import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/message_model.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    
    try {
      final currentUser = await DataService.getCurrentUser();
      debugPrint('MessagesScreen: Current user: ${currentUser?.id}');
      debugPrint('MessagesScreen: Current user login: ${currentUser?.login}');
      
      if (currentUser != null) {
        debugPrint('MessagesScreen: Loading messages for user: ${currentUser.id}');
        final messages = await DataService.getMessagesByUserId(currentUser.id);
        debugPrint('MessagesScreen: Loaded ${messages.length} messages');
        
        // Логируем каждое сообщение для диагностики
        for (var msg in messages) {
          debugPrint('MessagesScreen: Message - id: ${msg.id}, sender: ${msg.sender}, content: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
        }
        
        if (!mounted) return;
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      } else {
        debugPrint('MessagesScreen: ❌ No current user found - user is not logged in');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('MessagesScreen: ❌ Error loading messages: $e');
      debugPrint('MessagesScreen: Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ru').format(date);
    } else {
      return DateFormat('dd.MM').format(date);
    }
  }

  IconData _getSenderIcon(String sender) {
    final lowerSender = sender.toLowerCase();
    if (lowerSender.contains('классн')) return Icons.person;
    if (lowerSender.contains('матем')) return Icons.calculate;
    if (lowerSender.contains('физик')) return Icons.science;
    if (lowerSender.contains('админ')) return Icons.admin_panel_settings;
    return Icons.school;
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
          'Сообщения',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.getWhite(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.getAccentColor(context),
              ),
            )
          : _messages.isEmpty
              ? Center(
                  child: Text(
                    'Нет сообщений',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMessages,
                  color: AppColors.getAccentColor(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: _messages.map((message) {
                      return _buildMessageCard(
                        context: context,
                        sender: message.sender,
                        preview: message.content,
                        time: _formatTime(message.date),
                        unread: !message.isRead,
                        icon: _getSenderIcon(message.sender),
                        onTap: () async {
                          if (!message.isRead) {
                            await DataService.markMessageAsRead(message.id);
                            _loadMessages();
                          }
                          // Можно открыть детальный просмотр сообщения
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.getCardColor(context),
                              title: Text(
                                message.sender,
                                style: TextStyle(
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                              content: Text(
                                message.content,
                                style: TextStyle(
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Закрыть',
                                    style: TextStyle(
                                      color: AppColors.getAccentColor(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildMessageCard({
    required BuildContext context,
    required String sender,
    required String preview,
    required String time,
    required bool unread,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: unread
              ? Border.all(color: Colors.blue.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.getWhite(context), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 16,
                            fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 12,
                          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
