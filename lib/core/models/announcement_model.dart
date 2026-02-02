class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final bool isImportant;
  final List<String> targetUserIds; // Пустой список = для всех

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    this.isImportant = false,
    this.targetUserIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'date': date.toIso8601String(),
      'isImportant': isImportant,
      'targetUserIds': targetUserIds,
    };
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      date: DateTime.parse(json['date'] as String),
      isImportant: json['isImportant'] as bool? ?? false,
      targetUserIds: (json['targetUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
