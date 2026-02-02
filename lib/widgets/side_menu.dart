import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/utils/page_transitions.dart';
import 'package:myapp/core/providers/theme_inherited_widget.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/services/school_service.dart';
import 'package:myapp/core/services/avatar_service.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/main.dart' show navigatorKey;
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/updates_screen.dart';
import 'package:myapp/screens/grades_screen.dart';
import 'package:myapp/screens/final_grades_screen.dart';
import 'package:myapp/screens/schedule_screen.dart';
import 'package:myapp/screens/announcements_screen.dart';
import 'package:myapp/screens/messages_screen.dart';
import 'package:myapp/screens/sferum_screen.dart';
import 'package:myapp/screens/about_screen.dart';
import 'package:myapp/screens/select_school_screen.dart';
import 'package:myapp/screens/profile_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  UserModel? _user;
  String? _selectedSchoolName;
  String? _selectedSchoolAddress;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSchool();
    _loadAvatar();
  }

  Future<void> _loadUser() async {
    final user = await DataService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _loadAvatar() async {
    final avatarFile = await AvatarService.getAvatarFile();
    if (mounted) {
      setState(() {
        _avatarFile = avatarFile;
      });
    }
  }

  Future<void> _loadSchool() async {
    final schoolName = await SchoolService.getSelectedSchoolName();
    final schoolAddress = await SchoolService.getSelectedSchoolAddress();
    if (mounted) {
      setState(() {
        _selectedSchoolName = schoolName;
        _selectedSchoolAddress = schoolAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width:
          255, // Ширина рассчитана: 14px (отступ слева) + 227px (ширина разделителя) + 14px (отступ справа)
      backgroundColor: AppColors.getCardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Убираем закругленные края
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Профиль пользователя
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  SmoothPageRoute(child: const ProfileScreen()),
                );
                // Обновляем данные после возврата из профиля
                _loadUser();
                _loadAvatar();
              },
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(
                padding: const EdgeInsets.only(top: 23, bottom: 20, left: 14),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.getBackgroundColor(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.getAccentColor(context),
                          width: 2,
                        ),
                      ),
                      child: _avatarFile != null
                          ? ClipOval(
                              child: Image.file(
                                _avatarFile!,
                                fit: BoxFit.cover,
                                width: 54,
                                height: 54,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: AppColors.getWhite(context),
                              size: 32,
                            ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user != null
                              ? "${_user!.lastName} ${_user!.firstName}"
                              : AppLocalizations.of(context)?.lastNameFirstName ?? "Фамилия Имя",
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _user?.middleName ?? AppLocalizations.of(context)?.middleName ?? "Отчество",
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Разделитель
            Container(
              color: AppColors.getTextSecondary(context),
              margin: const EdgeInsets.only(bottom: 3, left: 14),
              width: 227,
              height: 1,
            ),

            // Школа
            Container(
              margin: const EdgeInsets.only(bottom: 4, left: 14),
              child: Text(
                AppLocalizations.of(context)?.school ?? "Школа",
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Разделитель
            Container(
              color: AppColors.getTextSecondary(context),
              margin: const EdgeInsets.only(bottom: 19, left: 14, right: 14),
              width: 227,
              height: 1,
            ),

            // Информация о школе
            Container(
              margin: const EdgeInsets.only(bottom: 20, left: 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 27),
                    width: 25,
                    height: 25,
                    child: Icon(
                      Icons.school,
                      color: AppColors.getIconColor(context),
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedSchoolName ?? 
                          (_user?.school != null && _user!.school.isNotEmpty
                              ? _user!.school
                              : "ГАУ КО ПОО \"Колледж...\""),
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user != null
                              ? "${_user!.lastName} ${_user!.firstName}"
                              : AppLocalizations.of(context)?.lastNameFirstName ?? "Имя Фамилия",
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Выбрать другую школу
            _buildMenuItem(
              icon: Icons.edit_outlined,
              title: AppLocalizations.of(context)?.selectAnotherSchool ?? "Выбрать другую школу",
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  SmoothPageRoute(child: const SelectSchoolScreen()),
                );
                // Обновляем школу после возврата
                _loadSchool();
              },
            ),

            // Разделитель
            Container(
              color: AppColors.getTextSecondary(context),
              margin: const EdgeInsets.only(bottom: 10, left: 14, right: 14),
              width: 227,
              height: 1,
            ),

            // Пункты меню (в порядке согласно дизайну) - занимают оставшееся пространство
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem(
                      icon: Icons.update_outlined,
                      title: AppLocalizations.of(context)?.updates ?? "Обновления",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const UpdatesScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.menu_book_outlined,
                      title: AppLocalizations.of(context)?.diary ?? "Дневник",
                      onTap: () {
                        Navigator.pop(context);
                        // Уже на главном экране дневника
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.grade_outlined,
                      title: AppLocalizations.of(context)?.grades ?? "Отметки",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const GradesScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.assessment_outlined,
                      title: AppLocalizations.of(context)?.finalGrades ?? "Итоговые отметки",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const FinalGradesScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.calendar_today_outlined,
                      title: AppLocalizations.of(context)?.schedule ?? "Расписание",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const ScheduleScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.campaign_outlined,
                      title: AppLocalizations.of(context)?.announcements ?? "Объявления",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const AnnouncementsScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.message_outlined,
                      title: AppLocalizations.of(context)?.messages ?? "Сообщения",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const MessagesScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.public_outlined,
                      title: AppLocalizations.of(context)?.sferum ?? "Сферум",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const SferumScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: AppLocalizations.of(context)?.about ?? "О программе",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const AboutScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Разделитель
            Container(
              color: AppColors.getTextSecondary(context),
              margin: const EdgeInsets.only(bottom: 10, top: 10, left: 14),
              width: 227,
              height: 1,
            ),

            // Выйти
            _buildMenuItem(
              icon: Icons.logout_outlined,
              title: AppLocalizations.of(context)?.logout ?? "Выйти",
              onTap: () {
                final localizations = AppLocalizations.of(context);
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      backgroundColor: AppColors.getCardColor(dialogContext),
                      title: Text(
                        localizations?.logoutTitle ?? 'Выход из аккаунта',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(dialogContext),
                        ),
                      ),
                      content: Text(
                        localizations?.logoutConfirmation ?? 'Вы уверены, что хотите выйти из аккаунта?',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(dialogContext),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            localizations?.cancel ?? 'Отмена',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(dialogContext),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Сбрасываем тему на светлую
                            try {
                              final themeProvider = ThemeInheritedWidget.of(
                                context,
                              );
                              themeProvider.resetToLightTheme();
                            } catch (e) {
                              debugPrint('Не удалось сбросить тему: $e');
                            }

                            // Закрываем диалог
                            Navigator.pop(dialogContext);

                            // Используем WidgetsBinding для выполнения навигации после закрытия диалога
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // Используем глобальный navigatorKey для навигации
                              // Это должно закрыть все экраны включая drawer и перейти на login
                              navigatorKey.currentState
                                  ?.pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                            });
                          },
                          child: Text(
                            localizations?.logout ?? 'Выйти',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final brightness = Theme.of(context).brightness;
        return InkWell(
          onTap: onTap,
          splashColor: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          highlightColor: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 28),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 27),
                  width: 25,
                  height: 25,
                  child: Icon(
                    icon,
                    color: AppColors.getIconColor(context),
                    size: 25,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
