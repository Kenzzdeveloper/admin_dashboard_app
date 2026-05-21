import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:study_club_app/screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.initializeToken();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(
    DevicePreview(
      enabled: true, // ganti false untuk production
      builder: (context) => StudyClubApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class StudyClubApp extends StatelessWidget {
  final bool isLoggedIn;
  const StudyClubApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Club',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // ← tambahkan ini
      locale: DevicePreview.locale(context), // ← tambahkan ini
      builder: DevicePreview.appBuilder, // ← tambahkan ini
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          background: const Color(0xFFEFF3F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFEFF3F8),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
