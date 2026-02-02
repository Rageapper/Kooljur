import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB5AMYtgqzDITREM-Feo95s_pRxnJruXHo",
        appId: "1:614358163223:web:0ef7fbf83c58cbb5632152",
        messagingSenderId: "614358163223",
        projectId: "diary-app-d0542",
      ),
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
    debugPrint('⚠️ Пожалуйста, настройте Firebase согласно инструкции в FIREBASE_SETUP.md');
  }
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Админ панель',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
    );
  }
}
