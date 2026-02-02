class GradeModel {
  final String id;
  final String userId;
  final String subject;
  final int grade;
  final DateTime date;
  final String? comment;

  GradeModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.grade,
    required this.date,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'grade': grade,
      'date': date.toIso8601String(),
      'comment': comment,
    };
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as int,
      date: DateTime.parse(json['date'] as String),
      comment: json['comment'] as String?,
    );
  }
}
