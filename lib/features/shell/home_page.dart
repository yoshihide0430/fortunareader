import 'package:flutter/material.dart';
import 'app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _HomeButton(label: '✋ 手相占い', route: AppRoutes.palm),
      _HomeButton(label: '🌟 星座占い', route: AppRoutes.zodiac),
      _HomeButton(label: '🔢 数秘占い', route: AppRoutes.numerology),
      _HomeButton(label: '⚙️ 設定', route: AppRoutes.settings),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fortuna Reader'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: buttons,
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String label;
  final String route;

  const _HomeButton({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
