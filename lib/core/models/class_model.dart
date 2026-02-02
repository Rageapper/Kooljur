class ClassModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final String name;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      schoolName: json['schoolName'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ClassModel copyWith({
    String? id,
    String? schoolId,
    String? schoolName,
    String? name,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
