import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:myapp/core/models/final_grade_model.dart';
import 'package:myapp/core/models/announcement_model.dart';
import 'package:myapp/core/models/message_model.dart';
import 'package:myapp/core/models/school_model.dart';
import 'package:myapp/core/models/class_model.dart';
import 'package:myapp/core/models/schedule_model.dart';
import 'package:myapp/core/models/homework_model.dart';
import 'package:myapp/core/services/firestore_service.dart';

class DataService {
  static const String _currentUserIdKey = 'current_user_id';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Users - используем Firestore
  static Future<List<UserModel>> getAllUsers() async {
    return await FirestoreService.getAllUsers();
  }

  static Future<UserModel?> getUserById(String id) async {
    return await FirestoreService.getUserById(id);
  }

  static Future<UserModel?> getUserByLogin(String login) async {
    return await FirestoreService.getUserByLogin(login);
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    return await FirestoreService.getUserByEmail(email);
  }

  static Future<String> generateUniqueUserId() async {
    return await FirestoreService.generateUniqueUserId();
  }

  static Future<bool> createUser(UserModel user) async {
    return await FirestoreService.createUser(user);
  }

  static Future<bool> updateUser(UserModel user) async {
    return await FirestoreService.updateUser(user);
  }

  static Future<bool> deleteUser(String id) async {
    return await FirestoreService.deleteUser(id);
  }

  // Current User - используем shared_preferences для локального хранения сессии
  static Future<String?> getCurrentUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_currentUserIdKey);
  }

  static Future<bool> setCurrentUserId(String? userId) async {
    final prefs = await _prefs;
    if (userId == null) {
      return await prefs.remove(_currentUserIdKey);
    }
    return await prefs.setString(_currentUserIdKey, userId);
  }

  static Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    debugPrint('DataService: getCurrentUser - userId from storage: $userId');
    if (userId == null) {
      debugPrint('DataService: getCurrentUser - No userId found in storage');
      return null;
    }
    final user = await getUserById(userId);
    debugPrint('DataService: getCurrentUser - User found: ${user?.id}, Login: ${user?.login}');
    return user;
  }

  // Grades - используем Firestore
  static Future<List<GradeModel>> getGradesByUserId(String userId) async {
    return await FirestoreService.getGradesByUserId(userId);
  }

  static Future<List<GradeModel>> getAllGrades() async {
    return await FirestoreService.getAllGrades();
  }

  static Future<bool> addGrade(GradeModel grade) async {
    return await FirestoreService.addGrade(grade);
  }

  static Future<bool> deleteGrade(String id) async {
    return await FirestoreService.deleteGrade(id);
  }

  static Future<bool> deleteGradesByUserId(String userId) async {
    return await FirestoreService.deleteGradesByUserId(userId);
  }

  // Final Grades - используем Firestore
  static Future<List<FinalGradeModel>> getFinalGradesByUserId(String userId) async {
    return await FirestoreService.getFinalGradesByUserId(userId);
  }

  static Future<List<FinalGradeModel>> getAllFinalGrades() async {
    return await FirestoreService.getAllFinalGrades();
  }

  static Future<bool> addFinalGrade(FinalGradeModel grade) async {
    return await FirestoreService.addFinalGrade(grade);
  }

  static Future<bool> deleteFinalGrade(String id) async {
    return await FirestoreService.deleteFinalGrade(id);
  }

  static Future<bool> deleteFinalGradesByUserId(String userId) async {
    return await FirestoreService.deleteFinalGradesByUserId(userId);
  }

  // Announcements - используем Firestore
  static Future<List<AnnouncementModel>> getAnnouncementsForUser(String? userId) async {
    return await FirestoreService.getAnnouncementsForUser(userId);
  }

  static Future<List<AnnouncementModel>> getAllAnnouncements() async {
    return await FirestoreService.getAllAnnouncements();
  }

  static Future<bool> addAnnouncement(AnnouncementModel announcement) async {
    return await FirestoreService.addAnnouncement(announcement);
  }

  static Future<bool> deleteAnnouncement(String id) async {
    return await FirestoreService.deleteAnnouncement(id);
  }

  // Messages - используем Firestore
  static Future<List<MessageModel>> getMessagesByUserId(String userId) async {
    return await FirestoreService.getMessagesByUserId(userId);
  }

  static Future<List<MessageModel>> getAllMessages() async {
    return await FirestoreService.getAllMessages();
  }

  static Future<bool> addMessage(MessageModel message) async {
    return await FirestoreService.addMessage(message);
  }

  static Future<bool> markMessageAsRead(String id) async {
    return await FirestoreService.markMessageAsRead(id);
  }

  static Future<bool> deleteMessage(String id) async {
    return await FirestoreService.deleteMessage(id);
  }

  static Future<bool> deleteMessagesByUserId(String userId) async {
    return await FirestoreService.deleteMessagesByUserId(userId);
  }

  // Schools - используем Firestore
  static Future<List<SchoolModel>> getAllSchools() async {
    return await FirestoreService.getAllSchools();
  }

  static Future<SchoolModel?> getSchoolById(String id) async {
    return await FirestoreService.getSchoolById(id);
  }

  static Future<SchoolModel?> getSchoolByName(String name) async {
    return await FirestoreService.getSchoolByName(name);
  }

  static Future<bool> createSchool(SchoolModel school) async {
    return await FirestoreService.createSchool(school);
  }

  static Future<bool> updateSchool(SchoolModel school) async {
    return await FirestoreService.updateSchool(school);
  }

  static Future<bool> deleteSchool(String id) async {
    return await FirestoreService.deleteSchool(id);
  }

  static Future<List<UserModel>> getUsersBySchool(String schoolName) async {
    return await FirestoreService.getUsersBySchool(schoolName);
  }

  // Classes - используем Firestore
  static Future<List<ClassModel>> getAllClasses() async {
    return await FirestoreService.getAllClasses();
  }

  static Future<List<ClassModel>> getClassesBySchool(String schoolId) async {
    return await FirestoreService.getClassesBySchool(schoolId);
  }

  static Future<ClassModel?> getClassById(String id) async {
    return await FirestoreService.getClassById(id);
  }

  static Future<bool> createClass(ClassModel classModel) async {
    return await FirestoreService.createClass(classModel);
  }

  static Future<bool> updateClass(ClassModel classModel) async {
    return await FirestoreService.updateClass(classModel);
  }

  static Future<bool> deleteClass(String id) async {
    return await FirestoreService.deleteClass(id);
  }

  static Future<List<UserModel>> getUsersByClass(String className) async {
    return await FirestoreService.getUsersByClass(className);
  }

  // Schedule
  static Future<List<ScheduleModel>> getScheduleByUserId(String userId) async {
    return await FirestoreService.getScheduleByUserId(userId);
  }

  static Future<bool> createSchedule(ScheduleModel schedule) async {
    return await FirestoreService.createSchedule(schedule);
  }

  static Future<bool> updateSchedule(ScheduleModel schedule) async {
    return await FirestoreService.updateSchedule(schedule);
  }

  static Future<bool> deleteSchedule(String id) async {
    return await FirestoreService.deleteSchedule(id);
  }

  // Homework
  static Future<List<HomeworkModel>> getHomeworkByUserIdAndDate(String userId, DateTime date) async {
    return await FirestoreService.getHomeworkByUserIdAndDate(userId, date);
  }

  static Future<List<HomeworkModel>> getHomeworkByUserIdAndSubject(String userId, String subject, DateTime date) async {
    return await FirestoreService.getHomeworkByUserIdAndSubject(userId, subject, date);
  }

  static Future<bool> createHomework(HomeworkModel homework) async {
    return await FirestoreService.createHomework(homework);
  }

  // Grades by date
  static Future<List<GradeModel>> getGradesByUserIdAndDate(String userId, DateTime date) async {
    final allGrades = await getGradesByUserId(userId);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return allGrades.where((grade) {
      return grade.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             grade.date.isBefore(endOfDay);
    }).toList();
  }
}
