import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/providers/theme_inherited_widget.dart';
import 'package:myapp/core/utils/page_transitions.dart';
import 'package:myapp/widgets/header.dart';
import 'package:myapp/widgets/user_info_section.dart';
import 'package:myapp/widgets/navigation_bar.dart' as custom;
import 'package:myapp/widgets/side_menu.dart';
import 'package:myapp/widgets/date_picker_bottom_sheet.dart';
import 'package:myapp/screens/Frame3.dart';
import 'package:myapp/screens/grades_screen.dart';
import 'package:myapp/screens/messages_screen.dart';
import 'package:myapp/screens/announcements_screen.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/schedule_model.dart';
import 'package:myapp/core/models/homework_model.dart';
import 'package:myapp/core/models/grade_model.dart';
import 'package:myapp/widgets/diary_day_block.dart';
import 'package:intl/intl.dart';

class Frame1 extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  
  const Frame1({super.key, this.onLocaleChanged});

  @override
  Frame1State createState() => Frame1State();
}

class Frame1State extends State<Frame1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _selectedDate = DateTime.now();
  Map<String, List<ScheduleModel>> _scheduleByDay = {};
  List<HomeworkModel> _homework = [];
  List<GradeModel> _grades = [];
  bool _isLoading = true;
  String? _currentUserId;

  void _onProfileTap() {
    final themeProvider = ThemeInheritedWidget.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => Frame3(
        themeProvider: themeProvider,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUserId = await DataService.getCurrentUserId();
    if (_currentUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await _loadDayData();
  }

  Future<void> _loadDayData() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    // Получаем начало недели (понедельник)
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    // Загружаем расписание для пользователя
    final allSchedule = await DataService.getScheduleByUserId(_currentUserId!);
    
    // Группируем расписание по дням недели
    _scheduleByDay = {};
    final daysOfWeek = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    
    for (var day in daysOfWeek) {
      final dayLessons = allSchedule
          .where((s) => s.dayOfWeek == day)
          .toList();
      dayLessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
      _scheduleByDay[day] = dayLessons;
    }

    // Загружаем домашние задания и оценки на всю неделю
    _homework = [];
    _grades = [];
    
    for (int i = 0; i < 7; i++) {
      final dayDate = weekStart.add(Duration(days: i));
      final dayHomework = await DataService.getHomeworkByUserIdAndDate(_currentUserId!, dayDate);
      final dayGrades = await DataService.getGradesByUserIdAndDate(_currentUserId!, dayDate);
      
      _homework.addAll(dayHomework);
      _grades.addAll(dayGrades);
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildWeekBlocks() {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final daysOfWeek = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final List<Widget> blocks = [];

    for (int i = 0; i < 7; i++) {
      final dayDate = weekStart.add(Duration(days: i));
      final dayDateOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);
      final dayOfWeek = daysOfWeek[i];
      final lessons = _scheduleByDay[dayOfWeek] ?? [];
      
      // Фильтруем ДЗ и оценки для этого дня
      final dayHomework = _homework.where((hw) {
        final hwDate = DateTime(hw.date.year, hw.date.month, hw.date.day);
        return hwDate.isAtSameMomentAs(dayDateOnly);
      }).toList();
      
      final dayGrades = _grades.where((grade) {
        final gradeDate = DateTime(grade.date.year, grade.date.month, grade.date.day);
        return gradeDate.isAtSameMomentAs(dayDateOnly);
      }).toList();

      final isToday = dayDateOnly.isAtSameMomentAs(todayDate);

      blocks.add(
        DiaryDayBlock(
          dayOfWeek: dayOfWeek,
          date: dayDate,
          lessons: lessons,
          homework: dayHomework,
          grades: dayGrades,
          isToday: isToday,
        ),
      );
    }

    return blocks;
  }

  void _onInfoTap() {
    // Открываем модальное окно выбора даты
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DatePickerBottomSheet(
        selectedDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
          _loadDayData();
        },
      ),
    );
  }
  
  String _getWeekRange() {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));
    final startFormat = DateFormat('dd.MM');
    final endFormat = DateFormat('dd.MM');
    return '${startFormat.format(weekStart)}-${endFormat.format(weekEnd)}';
  }

  void _onNavigationButtonTap(int buttonIndex) {
    switch (buttonIndex) {
      case 1:
        // Дневник - уже на главном экране
        break;
      case 2:
        // Объявления
        Navigator.push(
          context,
          SmoothPageRoute(child: const AnnouncementsScreen()),
        );
        break;
      case 3:
        // Отметки
        Navigator.push(
          context,
          SmoothPageRoute(child: const GradesScreen()),
        );
        break;
      case 4:
        // Сообщения
        Navigator.push(
          context,
          SmoothPageRoute(child: const MessagesScreen()),
        );
        break;
      case 5:
        // Боковое меню
      _scaffoldKey.currentState?.openDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      drawerEnableOpenDragGesture: false, // Отключаем открытие свайпом
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Статичная верхняя панель
              Header(
                onProfileTap: _onProfileTap,
              ),
              UserInfoSection(
                onInfoTap: _onInfoTap,
                weekRange: _getWeekRange(),
              ),
              // Прокручиваемый контент дневника
              Expanded(
                child: Container(
                  color: AppColors.getBackgroundColor(context),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildWeekBlocks(),
                          ),
                        ),
                ),
              ),
              custom.NavigationBar(
                onFirstButtonTap: () => _onNavigationButtonTap(1),
                onSecondButtonTap: () => _onNavigationButtonTap(2),
                onThirdButtonTap: () => _onNavigationButtonTap(3),
                onFourthButtonTap: () => _onNavigationButtonTap(4),
                onFifthButtonTap: () => _onNavigationButtonTap(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
