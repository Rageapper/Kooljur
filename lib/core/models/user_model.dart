class UserModel {
  final String id;
  final String login;
  final String password;
  final String firstName;
  final String lastName;
  final String middleName;
  final String email;
  final String phone;
  final String birthDate;
  final String school;
  final String className;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.login,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.school,
    required this.className,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'school': school,
      'className': className,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      login: json['login'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: json['birthDate'] as String,
      school: json['school'] as String,
      className: json['className'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  UserModel copyWith({
    String? id,
    String? login,
    String? password,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phone,
    String? birthDate,
    String? school,
    String? className,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      school: school ?? this.school,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
