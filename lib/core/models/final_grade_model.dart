class FinalGradeModel {
  final String id;
  final String userId;
  final String subject;
  final int grade;
  final String period; // "1 четверть", "2 четверть", "Годовая" и т.д.
  final DateTime date;

  FinalGradeModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.grade,
    required this.period,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'grade': grade,
      'period': period,
      'date': date.toIso8601String(),
    };
  }

  factory FinalGradeModel.fromJson(Map<String, dynamic> json) {
    return FinalGradeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as int,
      period: json['period'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
