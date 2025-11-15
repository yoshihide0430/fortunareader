import 'package:flutter/material.dart';
import 'dummy_pages.dart';
import '../omikuji/omikuji_box_page.dart';
import '../zodiac/zodiac_select_page.dart';

class AppRoutes {
  static const palm = '/palm';
  static const zodiac = '/zodiac';
  static const numerology = '/numerology';
  static const settings = '/settings';
  static const omikuji = '/omikuji';

  static Map<String, WidgetBuilder> routes = {
    palm: (_) => const DummyPage(title: '手相（撮影へ）'),
    zodiac: (_) => const ZodiacSelectPage(),
    numerology: (_) => const DummyPage(title: '今日の運勢（準備中）'),
    omikuji: (_) => const OmikujiBoxPage(),
  };
}
