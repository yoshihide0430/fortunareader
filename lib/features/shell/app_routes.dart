import 'package:flutter/material.dart';
import 'dummy_pages.dart';

class AppRoutes {
  static const palm = '/palm';
  static const zodiac = '/zodiac';
  static const numerology = '/numerology';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    palm: (_) => const DummyPage(title: '手相（撮影へ）'),
    zodiac: (_) => const DummyPage(title: '星座占い（準備中）'),
    numerology: (_) => const DummyPage(title: '今日の運勢（準備中）'),
    settings: (_) => const DummyPage(title: 'おみくじ / 設定（準備中）'),
  };
}
