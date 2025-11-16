// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/shell/app_routes.dart';
import 'features/shell/home_page.dart';
import 'features/seimon/seimon_debug_page.dart';

// ★ 追加：BGMサービス（just_audioベースのシングルトン想定）
import 'core/audio/bgm_service.dart';

const _sand = Color(0xFFEADCC2); // 生成り（縁・文字）
const _ink = Color(0xFF0B0813); // 墨色（最も暗い）
const _night1 = Color(0xFF140F25); // 夜空1
const _night2 = Color(0xFF1C1433); // 夜空2

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ★ 追加：BGMの初期化（assets/audio/n59.mp3 をループ再生できるよう準備）
  final bgm = BgmService();
  await bgm.init(
    assetPath: 'assets/audio/n59.mp3',
    initialVolume: 0.2,
    loop: true,
  );

  runApp(FortunaReaderApp(bgm: bgm));
}

class FortunaReaderApp extends StatefulWidget {
  const FortunaReaderApp({super.key, required this.bgm});
  final BgmService bgm;

  @override
  State<FortunaReaderApp> createState() => _FortunaReaderAppState();
}

class _FortunaReaderAppState extends State<FortunaReaderApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 🔽 これを追加：画面が描画された直後に再生開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.bgm.play();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // バージョン差異に強い実装
    final name = state.toString();
    if (name.contains('resumed')) {
      widget.bgm.play();
    } else if (name.contains('paused') ||
        name.contains('hidden') ||
        name.contains('detached')) {
      widget.bgm.pause();
    } else {
      // inactive等は無視
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.bgm.dispose();
    super.dispose();
  }

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
        scaffoldBackgroundColor: _night1,
        fontFamily: 'NotoSansJP', // 既定でOK。好みで変更可
      ),
      routes: AppRoutes.routes,
      home: const HomePage(),
    );
  }
}
