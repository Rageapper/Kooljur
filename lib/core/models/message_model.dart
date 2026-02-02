class MessageModel {
  final String id;
  final String userId;
  final String sender;
  final String content;
  final DateTime date;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.userId,
    required this.sender,
    required this.content,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sender': sender,
      'content': content,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  MessageModel copyWith({
    String? id,
    String? userId,
    String? sender,
    String? content,
    DateTime? date,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}
