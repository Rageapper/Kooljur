import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });
    final currentUser = await DataService.getCurrentUser();
    final announcements =
        await DataService.getAnnouncementsForUser(currentUser?.id);
    setState(() {
      _announcements = announcements;
      _isLoading = false;
    });
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
          'Объявления',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.getAccentColor(context),
              ),
            )
          : _announcements.isEmpty
              ? Center(
                  child: Text(
                    'Нет объявлений',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnnouncements,
                  color: AppColors.getAccentColor(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: _announcements.map((announcement) {
                      return _buildAnnouncementCard(
                        context: context,
                        title: announcement.title,
                        author: announcement.author,
                        date: DateFormat('dd.MM.yyyy').format(announcement.date),
                        content: announcement.content,
                        isImportant: announcement.isImportant,
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required String title,
    required String author,
    required String date,
    required String content,
    required bool isImportant,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: isImportant
            ? Border.all(color: Colors.orange, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Важно',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isImportant) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, color: AppColors.getTextSecondary(context), size: 16),
              const SizedBox(width: 4),
              Text(
                author,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today,
                  color: AppColors.getTextSecondary(context), size: 16),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
