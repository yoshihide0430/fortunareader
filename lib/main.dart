import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/shell/app_routes.dart';
import 'features/shell/home_page.dart';

const _sand = Color(0xFFEADCC2); // 生成り（縁・文字）
const _ink = Color(0xFF0B0813); // 墨色（最も暗い）
const _night1 = Color(0xFF140F25); // 夜空1
const _night2 = Color(0xFF1C1433); // 夜空2

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FortunaReaderApp());
}

class FortunaReaderApp extends StatelessWidget {
  const FortunaReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6D4AFF),
      brightness: Brightness.dark,
      primary: _sand,
      onPrimary: _ink,
      surface: const Color(0xFF1A1429),
      onSurface: _sand,
    );

    return MaterialApp(
      title: '占い館',
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: _night2,
        fontFamily: 'NotoSansJP', // 既定でOK。好みで変更可
      ),
      routes: AppRoutes.routes,
      home: const HomePage(),
    );
  }
}
