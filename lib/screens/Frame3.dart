import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/core/providers/theme_provider.dart';
import 'package:myapp/core/providers/theme_inherited_widget.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/notification_settings_service.dart';
import 'package:myapp/core/services/fcm_service.dart';
import 'package:myapp/core/services/language_service.dart';
import 'package:myapp/core/services/cache_service.dart';

class Frame3 extends StatefulWidget {
  final ThemeProvider? themeProvider;
  final Function(Locale)? onLocaleChanged;

  const Frame3({super.key, this.themeProvider, this.onLocaleChanged});

  @override
  Frame3State createState() => Frame3State();
}

class Frame3State extends State<Frame3> with SingleTickerProviderStateMixin {
  late String _selectedTheme;
  String _selectedIcon = 'autumn';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  ThemeProvider? _themeProvider;

  @override
  void initState() {
    super.initState();
    _selectedTheme = 'dark'; // Значение по умолчанию
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeProvider = widget.themeProvider ?? ThemeInheritedWidget.of(context);
    if (_selectedTheme == 'dark') {
      _selectedTheme = _themeProvider!.getThemeString();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getThemeBorderColor(BuildContext context, String theme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? const Color(0xFF6C6B70) : Colors.black26;
    return _selectedTheme == theme
        ? AppColors.getAccentColor(context)
        : defaultColor;
  }

  Color _getIconBorderColor(BuildContext context, String icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? const Color(0xFF6C6B70) : Colors.black26;
    return _selectedIcon == icon
        ? AppColors.getAccentColor(context)
        : defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF0F0E13) : Colors.white;
    final cardColor = isDarkMode
        ? const Color(0xFF202125)
        : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                children: [
                  // Заголовок с улучшенным дизайном
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 30),
                        Text(
                          AppLocalizations.of(context)?.settings ?? "Настройки",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.getTextSecondary(context),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Контент с прокруткой
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Секция "Оформление"
                          _buildSectionHeader(
                            AppLocalizations.of(context)?.theme ?? "Оформление",
                            Icons.palette_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildThemeSelector(),
                          const SizedBox(height: 24),
                          // Секция "Иконка запуска"
                          _buildSectionHeader(AppLocalizations.of(context)?.appIcon ?? "Иконка запуска", Icons.apps),
                          const SizedBox(height: 12),
                          _buildIconSelector(),
                          const SizedBox(height: 16),
                          // Предупреждение
                          _buildWarningCard(),
                          const SizedBox(height: 24),
                          // Дополнительные настройки
                          _buildSectionHeader(
                            AppLocalizations.of(context)?.additional ?? "Дополнительно",
                            Icons.settings_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsOption(
                            icon: Icons.notifications_outlined,
                            title: AppLocalizations.of(context)?.notifications ?? "Уведомления",
                            subtitle: AppLocalizations.of(context)?.notificationSettings ?? "Настройка уведомлений",
                            onTap: () {
                              _showNotificationSettingsDialog(context);
                            },
                          ),
                          _buildSettingsOption(
                            icon: Icons.language_outlined,
                            title: AppLocalizations.of(context)?.language ?? "Язык",
                            subtitle: _getCurrentLanguageName(),
                            onTap: () {
                              _showLanguageSelectionDialog(context);
                            },
                          ),
                          _buildSettingsOption(
                            icon: Icons.storage_outlined,
                            title: AppLocalizations.of(context)?.clearCache ?? "Очистить кэш",
                            subtitle: AppLocalizations.of(context)?.clearCacheDescription ?? "Освободить место",
                            onTap: () async {
                              if (!context.mounted) return;
                              
                              debugPrint('Frame3: Clear cache button tapped');
                              
                              // Показываем диалог с индикатором загрузки
                              if (!context.mounted) return;
                              
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) => _ClearCacheDialog(dialogContext: dialogContext),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.getTextSecondary(context), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            theme: 'system',
            icon: Icons.phone_android,
            label: AppLocalizations.of(context)?.systemTheme ?? 'Системное',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            theme: 'dark',
            icon: Icons.dark_mode,
            label: AppLocalizations.of(context)?.darkTheme ?? 'Темное',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            theme: 'light',
            icon: Icons.light_mode,
            label: AppLocalizations.of(context)?.lightTheme ?? 'Светлое',
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required String theme,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTheme == theme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode
        ? const Color(0xFF202125)
        : const Color(0xFFF5F5F5);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
        (_themeProvider ??
                widget.themeProvider ??
                ThemeInheritedWidget.of(context))
            .setThemeFromString(theme);
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.getAccentColor(context).withOpacity(0.2),
      highlightColor: AppColors.getAccentColor(context).withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getAccentColor(context).withOpacity(0.1)
              : cardColor,
          border: Border.all(
            color: _getThemeBorderColor(context, theme),
            width: isSelected ? 2.5 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.getAccentColor(context)
                  : AppColors.getTextSecondary(context),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.getAccentColor(context)
                    : AppColors.getTextSecondary(context),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildIconOption(
                icon: 'default',
                iconData: Icons.school,
                label: AppLocalizations.of(context)?.defaultIcon ?? 'По умолчанию',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIconOption(
                icon: 'classic',
                iconData: Icons.star,
                label: AppLocalizations.of(context)?.classicIcon ?? 'Классическая',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIconOption(
                icon: 'autumn',
                iconData: Icons.eco,
                label: AppLocalizations.of(context)?.autumnIcon ?? 'Осень',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildIconOption(
                icon: 'dark',
                iconData: Icons.nightlight,
                label: AppLocalizations.of(context)?.darkIcon ?? 'Темная',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIconOption(
                icon: 'winter',
                iconData: Icons.ac_unit,
                label: AppLocalizations.of(context)?.winterIcon ?? 'Зима',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildIconOption({
    required String icon,
    required IconData iconData,
    required String label,
  }) {
    final isSelected = _selectedIcon == icon;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode
        ? const Color(0xFF202125)
        : const Color(0xFFF5F5F5);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.getAccentColor(context).withOpacity(0.2),
      highlightColor: AppColors.getAccentColor(context).withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getAccentColor(context).withOpacity(0.1)
              : cardColor,
          border: Border.all(
            color: _getIconBorderColor(context, icon),
            width: isSelected ? 2.5 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              iconData,
              color: isSelected
                  ? AppColors.getAccentColor(context)
                  : AppColors.getTextSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.getAccentColor(context)
                    : AppColors.getTextSecondary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    final warningColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warningColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: warningColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "При изменении иконки приложение может быть скрыто. Вам потребуется запустить его заново.",
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode
        ? const Color(0xFF202125)
        : const Color(0xFFF5F5F5);
    final backgroundColor = isDarkMode ? const Color(0xFF0F0E13) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: isDarkMode
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.05),
      highlightColor: isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.02),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.getTextSecondary(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.getTextSecondary(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Диалог настроек уведомлений
  Future<void> _showNotificationSettingsDialog(BuildContext context) async {
    bool pushNotificationsEnabled = await NotificationSettingsService.arePushNotificationsEnabled();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.getCardColor(dialogContext),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.getTextPrimary(dialogContext),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(dialogContext)?.notificationSettings ?? 'Настройки уведомлений',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(dialogContext),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(dialogContext)?.pushNotificationsDescription ?? 'Управляйте push-уведомлениями в приложении',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(dialogContext),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Переключатель push-уведомлений
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(dialogContext).brightness == Brightness.dark
                          ? const Color(0xFF202125)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(dialogContext)?.pushNotifications ?? 'Push-уведомления',
                                style: TextStyle(
                                  color: AppColors.getTextPrimary(dialogContext),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pushNotificationsEnabled
                                    ? (AppLocalizations.of(dialogContext)?.pushNotificationsDescription ?? 'Вы будете получать уведомления о сообщениях и объявлениях')
                                    : (AppLocalizations.of(dialogContext)?.pushNotificationsDisabled ?? 'Уведомления отключены'),
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(dialogContext),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Switch(
                          value: pushNotificationsEnabled,
                          onChanged: (value) async {
                            setState(() {
                              pushNotificationsEnabled = value;
                            });
                            await NotificationSettingsService.setPushNotificationsEnabled(value);
                            
                            // Если включили - инициализируем FCM, если отключили - удаляем токен
                            if (value) {
                              await FCMService.reinitialize();
                            } else {
                              await FCMService.disableNotifications();
                            }
                            
                            // Убрано уведомление - изменения применяются автоматически
                          },
                          activeColor: AppColors.getAccentColor(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Информационное сообщение
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(dialogContext)?.pushNotificationsDescription ?? 'При включении уведомлений вам будет предложено разрешить их в настройках устройства',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(dialogContext),
                              fontSize: 11,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    AppLocalizations.of(dialogContext)?.close ?? 'Закрыть',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(dialogContext),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Получить название текущего языка
  String _getCurrentLanguageName() {
    final locale = Localizations.localeOf(context);
    return LanguageService.getLanguageName(locale);
  }

  // Виджет опции языка
  Widget _buildLanguageOption({
    required BuildContext dialogContext,
    required Locale locale,
    required String name,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(dialogContext).brightness == Brightness.dark;
    final cardColor = isDarkMode
        ? const Color(0xFF202125)
        : const Color(0xFFF5F5F5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.getAccentColor(dialogContext).withOpacity(0.2),
      highlightColor: AppColors.getAccentColor(dialogContext).withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getAccentColor(dialogContext).withOpacity(0.1)
              : cardColor,
          border: Border.all(
            color: isSelected
                ? AppColors.getAccentColor(dialogContext)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.getAccentColor(dialogContext)
                      : AppColors.getTextPrimary(dialogContext),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.getAccentColor(dialogContext),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // Диалог выбора языка
  Future<void> _showLanguageSelectionDialog(BuildContext context) async {
    final currentLocale = Localizations.localeOf(context);
    final localizations = AppLocalizations.of(context);
    
    // Используем ValueNotifier для сохранения выбранного языка
    final selectedLocaleNotifier = ValueNotifier<Locale>(currentLocale);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ValueListenableBuilder<Locale>(
          valueListenable: selectedLocaleNotifier,
          builder: (context, selectedLocale, _) {
            return AlertDialog(
              backgroundColor: AppColors.getCardColor(dialogContext),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.language_outlined,
                    color: AppColors.getTextPrimary(dialogContext),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.language ?? "Язык",
                    style: TextStyle(
                      color: AppColors.getTextPrimary(dialogContext),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Русский
                  _buildLanguageOption(
                    dialogContext: dialogContext,
                    locale: const Locale('ru', ''),
                    name: localizations?.russian ?? "Русский",
                    flag: '🇷🇺',
                    isSelected: selectedLocale.languageCode == 'ru',
                    onTap: () {
                      selectedLocaleNotifier.value = const Locale('ru', '');
                    },
                  ),
                  const SizedBox(height: 12),
                  // Казахский
                  _buildLanguageOption(
                    dialogContext: dialogContext,
                    locale: const Locale('kk', ''),
                    name: localizations?.kazakh ?? "Қазақша",
                    flag: '🇰🇿',
                    isSelected: selectedLocale.languageCode == 'kk',
                    onTap: () {
                      selectedLocaleNotifier.value = const Locale('kk', '');
                    },
                  ),
                  const SizedBox(height: 12),
                  // Английский
                  _buildLanguageOption(
                    dialogContext: dialogContext,
                    locale: const Locale('en', ''),
                    name: localizations?.english ?? "English",
                    flag: '🇬🇧',
                    isSelected: selectedLocale.languageCode == 'en',
                    onTap: () {
                      selectedLocaleNotifier.value = const Locale('en', '');
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    localizations?.cancel ?? "Отмена",
                    style: TextStyle(
                      color: AppColors.getTextSecondary(dialogContext),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final selectedLocale = selectedLocaleNotifier.value;
                    if (selectedLocale.languageCode != currentLocale.languageCode) {
                      // Сохраняем язык
                      LanguageService.setLocale(selectedLocale);
                      // Уведомляем родительский виджет об изменении
                      if (widget.onLocaleChanged != null) {
                        widget.onLocaleChanged!(selectedLocale);
                      }
                      // Перезагружаем приложение для применения изменений
                      Navigator.pop(dialogContext);
                      Navigator.pop(context); // Закрываем настройки
                      // Убрано уведомление - изменения применяются автоматически
                    } else {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(
                    localizations?.save ?? "Сохранить",
                    style: TextStyle(
                      color: AppColors.getAccentColor(dialogContext),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Виджет диалога очистки кеша
class _ClearCacheDialog extends StatefulWidget {
  final BuildContext dialogContext;

  const _ClearCacheDialog({required this.dialogContext});

  @override
  State<_ClearCacheDialog> createState() => _ClearCacheDialogState();
}

class _ClearCacheDialogState extends State<_ClearCacheDialog> {
  bool? _cacheResult;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _startClearing();
  }

  Future<void> _startClearing() async {
    if (_isClearing) return;
    _isClearing = true;

    try {
      debugPrint('Frame3: Starting cache clear...');
      final success = await CacheService.clearCache();
      debugPrint('Frame3: Cache clear completed. Success: $success');

      if (mounted) {
        setState(() {
          _cacheResult = success;
        });

        // Ждем 3 секунды перед закрытием
        await Future.delayed(const Duration(seconds: 3));

        // Закрываем диалог
        if (mounted && widget.dialogContext.mounted) {
          Navigator.pop(widget.dialogContext);
          debugPrint('Frame3: Dialog closed');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Frame3: Error clearing cache: $e');
      debugPrint('Frame3: Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _cacheResult = false;
        });

        // Ждем 3 секунды перед закрытием
        await Future.delayed(const Duration(seconds: 3));

        // Закрываем диалог
        if (mounted && widget.dialogContext.mounted) {
          Navigator.pop(widget.dialogContext);
          debugPrint('Frame3: Dialog closed after error');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Показываем либо индикатор загрузки, либо иконку успеха
              if (_cacheResult == null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.getAccentColor(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.clearCache ?? "Очистка кэша...",
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                  ],
                )
              else if (_cacheResult == true)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.cacheCleared ?? 'Кэш очищен',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка при очистке кэша',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
