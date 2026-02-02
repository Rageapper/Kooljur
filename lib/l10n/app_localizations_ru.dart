// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Дневник';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationSettings => 'Настройка уведомлений';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get pushNotificationsDescription =>
      'Вы будете получать уведомления о сообщениях и объявлениях';

  @override
  String get pushNotificationsDisabled => 'Уведомления отключены';

  @override
  String get pushNotificationsEnabled => 'Push-уведомления включены';

  @override
  String get pushNotificationsDisabledMessage => 'Push-уведомления отключены';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get english => 'English';

  @override
  String get login => 'Вход';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get register => 'Регистрация';

  @override
  String get diary => 'Дневник';

  @override
  String get announcements => 'Объявления';

  @override
  String get grades => 'Отметки';

  @override
  String get messages => 'Сообщения';

  @override
  String get profile => 'Профиль';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirmation => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get save => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get school => 'Школа';

  @override
  String get selectAnotherSchool => 'Выбрать другую школу';

  @override
  String get updates => 'Обновления';

  @override
  String get finalGrades => 'Итоговые отметки';

  @override
  String get schedule => 'Расписание';

  @override
  String get sferum => 'Сферум';

  @override
  String get about => 'О программе';

  @override
  String get theme => 'Оформление';

  @override
  String get systemTheme => 'Системное';

  @override
  String get darkTheme => 'Темное';

  @override
  String get lightTheme => 'Светлое';

  @override
  String get appIcon => 'Иконка запуска';

  @override
  String get defaultIcon => 'По умолчанию';

  @override
  String get classicIcon => 'Классическая';

  @override
  String get autumnIcon => 'Осень';

  @override
  String get darkIcon => 'Темная';

  @override
  String get winterIcon => 'Зима';

  @override
  String get additional => 'Дополнительно';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearCacheDescription => 'Освободить место';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get enterLogin => 'Введите логин';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get invalidCredentials => 'Неверный логин или пароль';

  @override
  String get registrationError => 'Ошибка регистрации';

  @override
  String get userExists => 'Пользователь с таким логином уже существует';

  @override
  String get registrationSuccess => 'Регистрация успешна';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get lastNameFirstName => 'Фамилия Имя';

  @override
  String get middleName => 'Отчество';

  @override
  String get languageChanged =>
      'Язык изменен. Перезапустите приложение для применения изменений.';

  @override
  String get logoutTitle => 'Выход из аккаунта';

  @override
  String get noAccount => 'Нет аккаунта? ';

  @override
  String get haveAccount => 'Уже есть аккаунт? ';

  @override
  String get passwordMinLength => 'Пароль должен быть не менее 3 символов';

  @override
  String get enterAccount => 'Войдите в свой аккаунт';

  @override
  String get createAccount => 'Создайте новый аккаунт';

  @override
  String get search => 'Поиск школы...';

  @override
  String get noResults => 'Школы не найдены';

  @override
  String schoolSelected(String name) {
    return 'Школа \"$name\" выбрана';
  }
}
