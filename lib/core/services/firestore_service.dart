import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:myapp/core/models/final_grade_model.dart';
import 'package:myapp/core/models/announcement_model.dart';
import 'package:myapp/core/models/message_model.dart';
import 'package:myapp/core/models/school_model.dart';
import 'package:myapp/core/models/class_model.dart';
import 'package:myapp/core/models/schedule_model.dart';
import 'package:myapp/core/models/homework_model.dart';

// Вспомогательные функции для конвертации дат
Map<String, dynamic> _convertToFirestore(Map<String, dynamic> json) {
  final result = Map<String, dynamic>.from(json);
  // Конвертируем строки ISO8601 в Timestamp для Firestore
  result.forEach((key, value) {
    if (value is String && (key == 'date' || key == 'createdAt' || key == 'birthDate')) {
      try {
        final date = DateTime.parse(value);
        result[key] = Timestamp.fromDate(date);
        debugPrint('FirestoreService: Converted $key from String to Timestamp');
      } catch (e) {
        debugPrint('FirestoreService: Failed to parse date for $key: $e');
        // Если не удалось распарсить, оставляем как есть
      }
    } else if (value is DateTime) {
      result[key] = Timestamp.fromDate(value);
      debugPrint('FirestoreService: Converted $key from DateTime to Timestamp');
    }
    // Убеждаемся, что userId всегда строка
    if (key == 'userId' && value != null) {
      result[key] = value.toString();
      debugPrint('FirestoreService: Converted userId to string: ${result[key]}');
    }
  });
  // Удаляем id из данных, так как он используется как document ID
  result.remove('id');
  return result;
}

Map<String, dynamic> _convertFromFirestore(Map<String, dynamic> json) {
  final result = Map<String, dynamic>.from(json);
  // Конвертируем Timestamp обратно в строки ISO8601
  result.forEach((key, value) {
    if (value is Timestamp && (key == 'date' || key == 'createdAt' || key == 'birthDate')) {
      result[key] = value.toDate().toIso8601String();
    } else if (value is Timestamp) {
      result[key] = value.toDate().toIso8601String();
    }
  });
  return result;
}

class FirestoreService {
  static FirebaseFirestore? _firestoreInstance;
  
  static FirebaseFirestore get _firestore {
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance!;
  }

  // Users Collection
  static CollectionReference get _usersCollection => _firestore.collection('users');
  static CollectionReference get _gradesCollection => _firestore.collection('grades');
  static CollectionReference get _finalGradesCollection => _firestore.collection('final_grades');
  static CollectionReference get _announcementsCollection => _firestore.collection('announcements');
  static CollectionReference get _messagesCollection => _firestore.collection('messages');
  static CollectionReference get _schoolsCollection => _firestore.collection('schools');
  static CollectionReference get _classesCollection => _firestore.collection('classes');
  static CollectionReference get _scheduleCollection => _firestore.collection('schedule');
  static CollectionReference get _homeworkCollection => _firestore.collection('homework');

  // Users
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return UserModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();
      if (!doc.exists) return null;
      final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
      return UserModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel?> getUserByLogin(String login) async {
    try {
      final snapshot = await _usersCollection.where('login', isEqualTo: login).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
      return UserModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
      return UserModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('FirestoreService: Error getting user by email: $e');
      return null;
    }
  }

  static Future<String> generateUniqueUserId() async {
    try {
      // Получаем всех пользователей и находим максимальный ID
      final users = await getAllUsers();
      int maxId = 0;
      
      for (var user in users) {
        try {
          final userId = int.parse(user.id);
          if (userId > maxId) {
            maxId = userId;
          }
        } catch (e) {
          // Если ID не число, пропускаем
          continue;
        }
      }
      
      // Возвращаем следующий ID
      return (maxId + 1).toString();
    } catch (e) {
      debugPrint('FirestoreService: Error generating unique user ID: $e');
      // В случае ошибки используем временную метку
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  static Future<bool> createUser(UserModel user) async {
    try {
      debugPrint('FirestoreService: Starting user creation for login: ${user.login}');
      
      // Проверка на существование пользователя с таким логином
      debugPrint('FirestoreService: Checking if user exists...');
      final existing = await getUserByLogin(user.login);
      if (existing != null) {
        debugPrint('FirestoreService: User with login ${user.login} already exists');
        return false;
      }
      debugPrint('FirestoreService: User does not exist, proceeding with creation');

      final json = user.toJson();
      debugPrint('FirestoreService: User JSON: $json');
      final firestoreData = _convertToFirestore(json);
      debugPrint('FirestoreService: Firestore data (after conversion): $firestoreData');
      debugPrint('FirestoreService: Creating user with document ID: ${user.id}');
      
      // Сохраняем в Firestore
      await _usersCollection.doc(user.id).set(firestoreData, SetOptions(merge: false));
      debugPrint('FirestoreService: ✅ User created successfully in Firestore');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('FirestoreService: ❌ FirebaseException: ${e.code} - ${e.message}');
      debugPrint('FirestoreService: Firebase error details: ${e.toString()}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('FirestoreService: ❌ Unexpected error creating user: $e');
      debugPrint('FirestoreService: Error type: ${e.runtimeType}');
      debugPrint('FirestoreService: Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> updateUser(UserModel user) async {
    try {
      final json = user.toJson();
      await _usersCollection.doc(user.id).update(_convertToFirestore(json));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      await _usersCollection.doc(id).delete();
      // Удаляем связанные данные
      await deleteGradesByUserId(id);
      await deleteFinalGradesByUserId(id);
      await deleteMessagesByUserId(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Grades
  static Future<List<GradeModel>> getGradesByUserId(String userId) async {
    try {
      final snapshot = await _gradesCollection.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return GradeModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<GradeModel>> getAllGrades() async {
    try {
      final snapshot = await _gradesCollection.get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return GradeModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addGrade(GradeModel grade) async {
    try {
      final json = grade.toJson();
      await _gradesCollection.doc(grade.id).set(_convertToFirestore(json));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteGrade(String id) async {
    try {
      await _gradesCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteGradesByUserId(String userId) async {
    try {
      final snapshot = await _gradesCollection.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Final Grades
  static Future<List<FinalGradeModel>> getFinalGradesByUserId(String userId) async {
    try {
      final snapshot = await _finalGradesCollection.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return FinalGradeModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<FinalGradeModel>> getAllFinalGrades() async {
    try {
      final snapshot = await _finalGradesCollection.get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return FinalGradeModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addFinalGrade(FinalGradeModel grade) async {
    try {
      final json = grade.toJson();
      await _finalGradesCollection.doc(grade.id).set(_convertToFirestore(json));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteFinalGrade(String id) async {
    try {
      await _finalGradesCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteFinalGradesByUserId(String userId) async {
    try {
      final snapshot = await _finalGradesCollection.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Announcements
  static Future<List<AnnouncementModel>> getAnnouncementsForUser(String? userId) async {
    try {
      // Получаем все объявления
      final snapshot = await _announcementsCollection.orderBy('date', descending: true).get();
      
      final allAnnouncements = snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return AnnouncementModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
      
      // Фильтруем: показываем объявления для всех или для конкретного пользователя
      if (userId == null) {
        return allAnnouncements;
      }
      
      return allAnnouncements.where((a) {
        return a.targetUserIds.isEmpty || a.targetUserIds.contains(userId);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<AnnouncementModel>> getAllAnnouncements() async {
    try {
      final snapshot = await _announcementsCollection.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return AnnouncementModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addAnnouncement(AnnouncementModel announcement) async {
    try {
      final json = announcement.toJson();
      await _announcementsCollection.doc(announcement.id).set(_convertToFirestore(json));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteAnnouncement(String id) async {
    try {
      await _announcementsCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Messages
  static Future<List<MessageModel>> getMessagesByUserId(String userId) async {
    try {
      debugPrint('FirestoreService: Getting messages for user: $userId (type: ${userId.runtimeType})');
      
      // Конвертируем userId в строку для сравнения (на случай если в БД хранится как число)
      final userIdString = userId.toString();
      debugPrint('FirestoreService: userId as string: $userIdString');
      
      // Сначала попробуем получить все сообщения для отладки
      final allSnapshot = await _messagesCollection.limit(10).get();
      debugPrint('FirestoreService: Sample messages in database (showing first 10):');
      for (var doc in allSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final msgUserId = data['userId'];
        final msgUserIdString = msgUserId?.toString() ?? 'null';
        final matches = msgUserIdString == userIdString || msgUserId == userId;
        debugPrint('FirestoreService: Message doc - id: ${doc.id}, userId: $msgUserId (type: ${msgUserId.runtimeType}, asString: $msgUserIdString), matches: $matches');
      }
      
      // Пробуем найти сообщения - пробуем и как строку, и как число
      QuerySnapshot? snapshot;
      List<MessageModel> messages = [];
      
      // Попытка 1: как строка
      try {
        snapshot = await _messagesCollection
            .where('userId', isEqualTo: userIdString)
            .orderBy('date', descending: true)
            .get();
        debugPrint('FirestoreService: Found ${snapshot.docs.length} messages for userId (as string): $userIdString');
        if (snapshot.docs.isNotEmpty) {
          messages = snapshot.docs
              .map((doc) {
                final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
                return MessageModel.fromJson({...data, 'id': doc.id});
              })
              .toList();
        }
      } catch (e) {
        debugPrint('FirestoreService: Error with string userId: $e');
      }
      
      // Попытка 2: как число (если userId можно преобразовать в число)
      if (messages.isEmpty) {
        try {
          final userIdNum = int.tryParse(userIdString);
          if (userIdNum != null) {
            final snapshot2 = await _messagesCollection
                .where('userId', isEqualTo: userIdNum)
                .orderBy('date', descending: true)
                .get();
            debugPrint('FirestoreService: Found ${snapshot2.docs.length} messages for userId (as number): $userIdNum');
            if (snapshot2.docs.isNotEmpty) {
              messages = snapshot2.docs
                  .map((doc) {
                    final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
                    return MessageModel.fromJson({...data, 'id': doc.id});
                  })
                  .toList();
            }
          }
        } catch (e) {
          debugPrint('FirestoreService: Error with number userId: $e');
        }
      }
      
      // Попытка 3: без orderBy (если нужен индекс)
      if (messages.isEmpty) {
        try {
          // Пробуем как строка без orderBy
          final snapshot3 = await _messagesCollection
              .where('userId', isEqualTo: userIdString)
              .get();
          debugPrint('FirestoreService: Found ${snapshot3.docs.length} messages for userId (as string, no orderBy): $userIdString');
          if (snapshot3.docs.isNotEmpty) {
            messages = snapshot3.docs
                .map((doc) {
                  final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
                  return MessageModel.fromJson({...data, 'id': doc.id});
                })
                .toList();
            messages.sort((a, b) => b.date.compareTo(a.date));
          }
        } catch (e) {
          debugPrint('FirestoreService: Error without orderBy: $e');
        }
      }
      
      debugPrint('FirestoreService: Total messages found: ${messages.length}');
      return messages;
    } catch (e, stackTrace) {
      debugPrint('FirestoreService: Error getting messages with orderBy: $e');
      debugPrint('FirestoreService: Stack trace: $stackTrace');
      // Если ошибка из-за отсутствия индекса, попробуем без orderBy
      try {
        debugPrint('FirestoreService: Retrying without orderBy...');
        final snapshot = await _messagesCollection
            .where('userId', isEqualTo: userId)
            .get();
        debugPrint('FirestoreService: Found ${snapshot.docs.length} messages without orderBy');
        final messages = snapshot.docs
            .map((doc) {
              final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
              return MessageModel.fromJson({...data, 'id': doc.id});
            })
            .toList();
        // Сортируем вручную
        messages.sort((a, b) => b.date.compareTo(a.date));
        return messages;
      } catch (e2) {
        debugPrint('FirestoreService: Retry also failed: $e2');
        return [];
      }
    }
  }

  static Future<List<MessageModel>> getAllMessages() async {
    try {
      final snapshot = await _messagesCollection.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return MessageModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addMessage(MessageModel message) async {
    try {
      debugPrint('FirestoreService: Adding message with id: ${message.id}');
      debugPrint('FirestoreService: Message userId: ${message.userId} (type: ${message.userId.runtimeType})');
      final json = message.toJson();
      debugPrint('FirestoreService: Message JSON: $json');
      final firestoreData = _convertToFirestore(json);
      // Убеждаемся, что userId всегда строка
      if (firestoreData['userId'] != null) {
        firestoreData['userId'] = firestoreData['userId'].toString();
      }
      debugPrint('FirestoreService: Firestore data (after userId conversion): $firestoreData');
      await _messagesCollection.doc(message.id).set(firestoreData);
      debugPrint('FirestoreService: ✅ Message added successfully');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('FirestoreService: ❌ FirebaseException: ${e.code} - ${e.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('FirestoreService: ❌ Error adding message: $e');
      debugPrint('FirestoreService: Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> markMessageAsRead(String id) async {
    try {
      await _messagesCollection.doc(id).update({'isRead': true});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteMessage(String id) async {
    try {
      await _messagesCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteMessagesByUserId(String userId) async {
    try {
      final snapshot = await _messagesCollection.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Schools Collection
  static Future<List<SchoolModel>> getAllSchools() async {
    try {
      final snapshot = await _schoolsCollection.get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return SchoolModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting schools: $e');
      return [];
    }
  }

  static Future<SchoolModel?> getSchoolById(String id) async {
    try {
      final doc = await _schoolsCollection.doc(id).get();
      if (!doc.exists) return null;
      final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
      return SchoolModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('FirestoreService: Error getting school by id: $e');
      return null;
    }
  }

  static Future<SchoolModel?> getSchoolByName(String name) async {
    try {
      final snapshot = await _schoolsCollection.where('name', isEqualTo: name).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
      return SchoolModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('FirestoreService: Error getting school by name: $e');
      return null;
    }
  }

  static Future<bool> createSchool(SchoolModel school) async {
    try {
      debugPrint('FirestoreService: Creating school: ${school.name}');
      final json = school.toJson();
      final firestoreData = _convertToFirestore(json);
      await _schoolsCollection.doc(school.id).set(firestoreData, SetOptions(merge: false));
      debugPrint('FirestoreService: ✅ School created successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: ❌ Error creating school: $e');
      return false;
    }
  }

  static Future<bool> updateSchool(SchoolModel school) async {
    try {
      final json = school.toJson();
      await _schoolsCollection.doc(school.id).update(_convertToFirestore(json));
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error updating school: $e');
      return false;
    }
  }

  static Future<bool> deleteSchool(String id) async {
    try {
      await _schoolsCollection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error deleting school: $e');
      return false;
    }
  }

  static Future<List<UserModel>> getUsersBySchool(String schoolName) async {
    try {
      final snapshot = await _usersCollection.where('school', isEqualTo: schoolName).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return UserModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting users by school: $e');
      return [];
    }
  }

  // Classes Collection
  static Future<List<ClassModel>> getAllClasses() async {
    try {
      final snapshot = await _classesCollection.get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return ClassModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting classes: $e');
      return [];
    }
  }

  static Future<List<ClassModel>> getClassesBySchool(String schoolId) async {
    try {
      final snapshot = await _classesCollection.where('schoolId', isEqualTo: schoolId).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return ClassModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting classes by school: $e');
      return [];
    }
  }

  static Future<ClassModel?> getClassById(String id) async {
    try {
      final doc = await _classesCollection.doc(id).get();
      if (!doc.exists) return null;
      final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
      return ClassModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('FirestoreService: Error getting class by id: $e');
      return null;
    }
  }

  static Future<bool> createClass(ClassModel classModel) async {
    try {
      debugPrint('FirestoreService: Creating class: ${classModel.name}');
      final json = classModel.toJson();
      final firestoreData = _convertToFirestore(json);
      await _classesCollection.doc(classModel.id).set(firestoreData, SetOptions(merge: false));
      debugPrint('FirestoreService: ✅ Class created successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: ❌ Error creating class: $e');
      return false;
    }
  }

  static Future<bool> updateClass(ClassModel classModel) async {
    try {
      final json = classModel.toJson();
      await _classesCollection.doc(classModel.id).update(_convertToFirestore(json));
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error updating class: $e');
      return false;
    }
  }

  static Future<bool> deleteClass(String id) async {
    try {
      await _classesCollection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error deleting class: $e');
      return false;
    }
  }

  static Future<List<UserModel>> getUsersByClass(String className) async {
    try {
      final snapshot = await _usersCollection.where('className', isEqualTo: className).get();
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return UserModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting users by class: $e');
      return [];
    }
  }

  // Schedule
  static Future<List<ScheduleModel>> getScheduleByUserId(String userId) async {
    try {
      final snapshot = await _scheduleCollection.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ScheduleModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting schedule: $e');
      return [];
    }
  }

  static Future<bool> createSchedule(ScheduleModel schedule) async {
    try {
      final json = schedule.toJson();
      await _scheduleCollection.doc(schedule.id).set(json);
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error creating schedule: $e');
      return false;
    }
  }

  static Future<bool> updateSchedule(ScheduleModel schedule) async {
    try {
      final json = schedule.toJson();
      json.remove('id');
      await _scheduleCollection.doc(schedule.id).update(json);
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error updating schedule: $e');
      return false;
    }
  }

  static Future<bool> deleteSchedule(String id) async {
    try {
      await _scheduleCollection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error deleting schedule: $e');
      return false;
    }
  }

  // Homework
  static Future<List<HomeworkModel>> getHomeworkByUserIdAndDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final snapshot = await _homeworkCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return HomeworkModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting homework: $e');
      return [];
    }
  }

  static Future<List<HomeworkModel>> getHomeworkByUserIdAndSubject(String userId, String subject, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final snapshot = await _homeworkCollection
          .where('userId', isEqualTo: userId)
          .where('subject', isEqualTo: subject)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = _convertFromFirestore(doc.data() as Map<String, dynamic>);
            return HomeworkModel.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      debugPrint('FirestoreService: Error getting homework by subject: $e');
      return [];
    }
  }

  static Future<bool> createHomework(HomeworkModel homework) async {
    try {
      final json = homework.toJson();
      final firestoreData = _convertToFirestore(json);
      await _homeworkCollection.doc(homework.id).set(firestoreData);
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error creating homework: $e');
      return false;
    }
  }
}
