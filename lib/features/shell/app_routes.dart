import 'package:flutter/material.dart';
import 'dummy_pages.dart';
import '../omikuji/omikuji_box_page.dart';
import '../zodiac/zodiac_select_page.dart';
import '../seimon/seimon_input_page.dart';
import '../palm/palm_capture_page.dart'; // ★ 追加

class AppRoutes {
  static const palm = '/palm';
  static const zodiac = '/zodiac';
  static const numerology = '/numerology';
  static const settings = '/settings';
  static const omikuji = '/omikuji';

  static Map<String, WidgetBuilder> routes = {
    palm: (_) => const PalmCapturePage(),
    zodiac: (_) => const ZodiacSelectPage(),
    numerology: (_) => const SeimonInputPage(),
    omikuji: (_) => const OmikujiBoxPage(),
  };
}
