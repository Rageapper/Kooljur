class ScheduleModel {
  final String id;
  final String userId;
  final String subject;
  final String dayOfWeek; // Понедельник, Вторник и т.д.
  final int lessonNumber; // Номер урока (1, 2, 3...)
  final String startTime; // "09:00"
  final String endTime; // "09:45"
  final String? classroom; // Кабинет
  final String? teacher; // Учитель

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.dayOfWeek,
    required this.lessonNumber,
    required this.startTime,
    required this.endTime,
    this.classroom,
    this.teacher,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'dayOfWeek': dayOfWeek,
      'lessonNumber': lessonNumber,
      'startTime': startTime,
      'endTime': endTime,
      'classroom': classroom,
      'teacher': teacher,
    };
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      lessonNumber: json['lessonNumber'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      classroom: json['classroom'] as String?,
      teacher: json['teacher'] as String?,
    );
  }
}
