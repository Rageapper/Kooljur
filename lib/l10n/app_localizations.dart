import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'Дневник'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройка уведомлений'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Вы будете получать уведомления о сообщениях и объявлениях'**
  String get pushNotificationsDescription;

  /// No description provided for @pushNotificationsDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления отключены'**
  String get pushNotificationsDisabled;

  /// No description provided for @pushNotificationsEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления включены'**
  String get pushNotificationsEnabled;

  /// No description provided for @pushNotificationsDisabledMessage.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления отключены'**
  String get pushNotificationsDisabledMessage;

  /// No description provided for @russian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @kazakh.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get kazakh;

  /// No description provided for @english.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get login;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPassword;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get register;

  /// No description provided for @diary.
  ///
  /// In ru, this message translates to:
  /// **'Дневник'**
  String get diary;

  /// No description provided for @announcements.
  ///
  /// In ru, this message translates to:
  /// **'Объявления'**
  String get announcements;

  /// No description provided for @grades.
  ///
  /// In ru, this message translates to:
  /// **'Отметки'**
  String get grades;

  /// No description provided for @messages.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти из аккаунта?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @school.
  ///
  /// In ru, this message translates to:
  /// **'Школа'**
  String get school;

  /// No description provided for @selectAnotherSchool.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать другую школу'**
  String get selectAnotherSchool;

  /// No description provided for @updates.
  ///
  /// In ru, this message translates to:
  /// **'Обновления'**
  String get updates;

  /// No description provided for @finalGrades.
  ///
  /// In ru, this message translates to:
  /// **'Итоговые отметки'**
  String get finalGrades;

  /// No description provided for @schedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get schedule;

  /// No description provided for @sferum.
  ///
  /// In ru, this message translates to:
  /// **'Сферум'**
  String get sferum;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О программе'**
  String get about;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In ru, this message translates to:
  /// **'Системное'**
  String get systemTheme;

  /// No description provided for @darkTheme.
  ///
  /// In ru, this message translates to:
  /// **'Темное'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In ru, this message translates to:
  /// **'Светлое'**
  String get lightTheme;

  /// No description provided for @appIcon.
  ///
  /// In ru, this message translates to:
  /// **'Иконка запуска'**
  String get appIcon;

  /// No description provided for @defaultIcon.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get defaultIcon;

  /// No description provided for @classicIcon.
  ///
  /// In ru, this message translates to:
  /// **'Классическая'**
  String get classicIcon;

  /// No description provided for @autumnIcon.
  ///
  /// In ru, this message translates to:
  /// **'Осень'**
  String get autumnIcon;

  /// No description provided for @darkIcon.
  ///
  /// In ru, this message translates to:
  /// **'Темная'**
  String get darkIcon;

  /// No description provided for @winterIcon.
  ///
  /// In ru, this message translates to:
  /// **'Зима'**
  String get winterIcon;

  /// No description provided for @additional.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get additional;

  /// No description provided for @clearCache.
  ///
  /// In ru, this message translates to:
  /// **'Очистить кэш'**
  String get clearCache;

  /// No description provided for @clearCacheDescription.
  ///
  /// In ru, this message translates to:
  /// **'Освободить место'**
  String get clearCacheDescription;

  /// No description provided for @cacheCleared.
  ///
  /// In ru, this message translates to:
  /// **'Кэш очищен'**
  String get cacheCleared;

  /// No description provided for @enterLogin.
  ///
  /// In ru, this message translates to:
  /// **'Введите логин'**
  String get enterLogin;

  /// No description provided for @enterPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный логин или пароль'**
  String get invalidCredentials;

  /// No description provided for @registrationError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка регистрации'**
  String get registrationError;

  /// No description provided for @userExists.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь с таким логином уже существует'**
  String get userExists;

  /// No description provided for @registrationSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация успешна'**
  String get registrationSuccess;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsDoNotMatch;

  /// No description provided for @lastNameFirstName.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия Имя'**
  String get lastNameFirstName;

  /// No description provided for @middleName.
  ///
  /// In ru, this message translates to:
  /// **'Отчество'**
  String get middleName;

  /// No description provided for @languageChanged.
  ///
  /// In ru, this message translates to:
  /// **'Язык изменен. Перезапустите приложение для применения изменений.'**
  String get languageChanged;

  /// No description provided for @logoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выход из аккаунта'**
  String get logoutTitle;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? '**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? '**
  String get haveAccount;

  /// No description provided for @passwordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не менее 3 символов'**
  String get passwordMinLength;

  /// No description provided for @enterAccount.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в свой аккаунт'**
  String get enterAccount;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создайте новый аккаунт'**
  String get createAccount;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск школы...'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In ru, this message translates to:
  /// **'Школы не найдены'**
  String get noResults;

  /// Сообщение о выбранной школе
  ///
  /// In ru, this message translates to:
  /// **'Школа \"{name}\" выбрана'**
  String schoolSelected(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
