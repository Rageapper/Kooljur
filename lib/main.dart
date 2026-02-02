import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/theme_inherited_widget.dart';
import 'core/theme/app_themes.dart';
import 'core/services/fcm_service.dart';
import 'core/services/fcm_background_handler.dart';
import 'core/services/language_service.dart';
import 'core/services/data_service.dart';
import 'screens/login_screen.dart';
import 'screens/Frame1.dart';
import 'screens/Frame3.dart';
import 'screens/updates_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/final_grades_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/sferum_screen.dart';
import 'screens/about_screen.dart';
import 'screens/select_school_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/bounce_loader.dart';
import 'core/config/firebase_config.dart';

// Глобальный ключ для навигации
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: FirebaseConfig.apiKey,
        appId: FirebaseConfig.appId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
      ),
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
    
    // Инициализация FCM
    try {
      // Регистрируем обработчик фоновых сообщений
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      // Инициализируем FCM
      await FCMService.initialize();
      debugPrint('✅ FCM initialized successfully');
    } catch (e) {
      debugPrint('⚠️ FCM initialization error: $e');
    }
  } catch (e, stackTrace) {
    // Если Firebase не настроен, выводим предупреждение
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('❌ Error type: ${e.runtimeType}');
    debugPrint('❌ Stack trace: $stackTrace');
    debugPrint('⚠️ Пожалуйста, настройте Firebase согласно инструкции в FIREBASE_SETUP.md');
  }
  
  if (!firebaseInitialized) {
    debugPrint('⚠️ WARNING: Firebase is not initialized. Registration and data sync will not work!');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  Locale _locale = const Locale('ru', '');

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {});
    });
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LanguageService.getCurrentLocale();
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    LanguageService.setLocale(locale);
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeInheritedWidget(
      themeProvider: _themeProvider,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Дневник',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: _themeProvider.themeMode,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LanguageService.supportedLocales,
        initialRoute: '/',
        routes: {
          '/': (context) => const InitialRoute(),
          '/login': (context) => const LoginScreen(),
          '/Frame1': (context) => Frame1(onLocaleChanged: _setLocale),
          '/Frame3': (context) => Frame3(onLocaleChanged: _setLocale),
          '/updates': (context) => const UpdatesScreen(),
          '/grades': (context) => const GradesScreen(),
          '/finalGrades': (context) => const FinalGradesScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/announcements': (context) => const AnnouncementsScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/sferum': (context) => const SferumScreen(),
          '/about': (context) => const AboutScreen(),
          '/selectSchool': (context) => const SelectSchoolScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}

// Виджет для проверки сохраненной сессии при запуске
class InitialRoute extends StatefulWidget {
  const InitialRoute({super.key});

  @override
  State<InitialRoute> createState() => _InitialRouteState();
}

class _InitialRouteState extends State<InitialRoute> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Добавляем минимальную задержку для отображения анимации загрузки
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Проверяем, есть ли сохраненный пользователь
    final userId = await DataService.getCurrentUserId();
    
    if (mounted) {
      if (userId != null && userId.isNotEmpty) {
        // Пользователь залогинен, переходим на главный экран
        // Инициализируем FCM для получения уведомлений
        try {
          await FCMService.initialize();
        } catch (e) {
          debugPrint('InitialRoute: FCM initialization error: $e');
        }
        
        Navigator.of(context).pushReplacementNamed('/Frame1');
      } else {
        // Пользователь не залогинен, переходим на экран входа
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем анимацию загрузки во время проверки
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceLoader(
              size: 60,
            ),
          ],
        ),
      ),
    );
  }
}
