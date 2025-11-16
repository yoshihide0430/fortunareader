// lib/features/seimon/seimon_calculator.dart
import 'package:flutter/foundation.dart';

class SeimonCalculator {
  // 星紋12タイプの並び順（この順番で 0〜11 を割り当て）
  static const List<String> _typeOrder = [
    'cat',
    'dog',
    'rabbit',
    'fox',
    'owl',
    'bear',
    'squirrel',
    'dolphin',
    'penguin',
    'wolf',
    'koala',
    'hedgehog',
  ];

  /// 星紋姓名術：名前＋生年月日＋性別からタイプコードを決定
  static String calcTypeCode({
    required String name,
    required DateTime birthDate,
    required String gender, // 'male' / 'female' / 'other'
  }) {
    // 1) 名前スコア：スペース等を除去して計算
    final normalizedName = name.replaceAll(RegExp(r'\s+'), '');
    int nameScore = 0;
    for (var i = 0; i < normalizedName.length; i++) {
      final code = normalizedName.codeUnitAt(i);
      // 画数の代わりにコード値を圧縮して使用
      final base = (code % 50) + 1; // 1〜50
      nameScore += base * (i + 1); // 文字位置に重み
    }
    nameScore = nameScore % 120; // スコアを 0〜119 に収める

    // 2) 生年月日スコア：YYYYMMDD の各桁を重み付きで合計
    final year = birthDate.year;
    final month = birthDate.month;
    final day = birthDate.day;

    final digits = <int>[
      year ~/ 1000,
      (year ~/ 100) % 10,
      (year ~/ 10) % 10,
      year % 10,
      month ~/ 10,
      month % 10,
      day ~/ 10,
      day % 10,
    ];

    int dateScore = 0;
    for (var i = 0; i < digits.length; i++) {
      dateScore += digits[i] * (i + 3); // 位置に応じて 3,4,5,... の重み
    }
    dateScore = dateScore % 120;

    // 3) 性別オフセット
    int genderOffset;
    switch (gender) {
      case 'male':
        genderOffset = 7;
        break;
      case 'female':
        genderOffset = 19;
        break;
      default:
        genderOffset = 31;
        break;
    }

    // 4) 合計 → 12タイプにマッピング
    final total = nameScore + dateScore + genderOffset;
    final index = total % _typeOrder.length;

    if (kDebugMode) {
      // デバッグ時だけ内部スコアを簡単に確認できるようにしておく
      // ignore: avoid_print
      print(
        '[SeimonCalculator] nameScore=$nameScore, '
        'dateScore=$dateScore, genderOffset=$genderOffset, '
        'total=$total, index=$index, type=${_typeOrder[index]}',
      );
    }

    return _typeOrder[index];
  }
}
