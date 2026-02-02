class HomeworkModel {
  final String id;
  final String userId;
  final String subject;
  final DateTime date;
  final String description;
  final bool isCompleted;

  HomeworkModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.date,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'date': date.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
