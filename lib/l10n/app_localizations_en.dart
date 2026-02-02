// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Diary';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsDescription =>
      'You will receive notifications about messages and announcements';

  @override
  String get pushNotificationsDisabled => 'Notifications disabled';

  @override
  String get pushNotificationsEnabled => 'Push notifications enabled';

  @override
  String get pushNotificationsDisabledMessage => 'Push notifications disabled';

  @override
  String get russian => 'Russian';

  @override
  String get kazakh => 'Kazakh';

  @override
  String get english => 'English';

  @override
  String get login => 'Login';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get register => 'Register';

  @override
  String get diary => 'Diary';

  @override
  String get announcements => 'Announcements';

  @override
  String get grades => 'Grades';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get school => 'School';

  @override
  String get selectAnotherSchool => 'Select another school';

  @override
  String get updates => 'Updates';

  @override
  String get finalGrades => 'Final grades';

  @override
  String get schedule => 'Schedule';

  @override
  String get sferum => 'Sferum';

  @override
  String get about => 'About';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get appIcon => 'App icon';

  @override
  String get defaultIcon => 'Default';

  @override
  String get classicIcon => 'Classic';

  @override
  String get autumnIcon => 'Autumn';

  @override
  String get darkIcon => 'Dark';

  @override
  String get winterIcon => 'Winter';

  @override
  String get additional => 'Additional';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheDescription => 'Free up space';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get enterLogin => 'Enter login';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get invalidCredentials => 'Invalid login or password';

  @override
  String get registrationError => 'Registration error';

  @override
  String get userExists => 'User with this login already exists';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get lastNameFirstName => 'Last Name First Name';

  @override
  String get middleName => 'Middle Name';

  @override
  String get languageChanged =>
      'Language changed. Restart the app to apply changes.';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get noAccount => 'No account? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get passwordMinLength => 'Password must be at least 3 characters';

  @override
  String get enterAccount => 'Sign in to your account';

  @override
  String get createAccount => 'Create a new account';

  @override
  String get search => 'Search school...';

  @override
  String get noResults => 'No schools found';

  @override
  String schoolSelected(String name) {
    return 'School \"$name\" selected';
  }
}
