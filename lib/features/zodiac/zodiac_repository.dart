import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import 'zodiac_models.dart';

/// 12星座のコード（0〜11）
enum ZodiacSign {
  aries, // おひつじ座
  taurus, // おうし座
  gemini, // ふたご座
  cancer, // かに座
  leo, // しし座
  virgo, // おとめ座
  libra, // てんびん座
  scorpio, // さそり座
  sagittarius, // いて座
  capricorn, // やぎ座
  aquarius, // みずがめ座
  pisces, // うお座
}

/// 星座占いデータを読み込んで、今日の1枚を返すクラス
class ZodiacRepository {
  ZodiacRepository._();
  static final ZodiacRepository instance = ZodiacRepository._();

  ZodiacData? _cache;

  /// JSONを読み込んでキャッシュする
  Future<ZodiacData> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString(
      'assets/zodiac/zodiac_sets.json',
    );
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    _cache = ZodiacData.fromJson(map);
    return _cache!;
  }

  /// 今日の占いカードを取得
  ///
  /// - sign      : どの星座か
  /// - today     : テスト用に日付を差し替えたいときだけ指定（通常はnull）
  Future<ZodiacCard> pickTodayCard({
    required ZodiacSign sign,
    DateTime? today,
  }) async {
    final data = await load();
    final date = today ?? DateTime.now();
    final year = date.year;
    final month = date.month;
    final seasonCode = _seasonCode(month); // 1〜4
    final zodiacNum = sign.index + 1; // 1〜12

    // どのセット（デッキ）を使うか決定
    final setId = (year + seasonCode + zodiacNum) % data.sets.length;
    final set = data.sets[setId];

    // 2000/1/1 からの日数
    final days = _daysSince2000(date);
    final zodiacIndex = sign.index; // 0〜11

    // 時間＋星座からの仮インデックス
    final timeIndex = (zodiacIndex + days) % set.cards.length;

    // (year, season, setId) から決定論的なシャッフル順を生成
    final perm = _buildPermutation(
      set.cards.length,
      year: year,
      season: seasonCode,
      setId: setId,
    );

    final recordIndex = perm[timeIndex]; // 0〜cards.length-1
    return set.cards[recordIndex];
  }

  /// 月から季節コード (1〜4) を決める
  int _seasonCode(int month) {
    if (month <= 3) return 1; // 1〜3月
    if (month <= 6) return 2; // 4〜6月
    if (month <= 9) return 3; // 7〜9月
    return 4; // 10〜12月
  }

  /// 2000-01-01 からの経過日数
  int _daysSince2000(DateTime date) {
    final base = DateTime(2000, 1, 1);
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.difference(base).inDays;
  }

  /// (年・季節・setId) から決定論的なシャッフル順を生成
  List<int> _buildPermutation(
    int length, {
    required int year,
    required int season,
    required int setId,
  }) {
    // 年ごと・季節ごと・セットごとに並び替えが変わるようにseedを作る
    final seed = year * 100 + season * 10 + setId;
    final rnd = Random(seed);
    final list = List<int>.generate(length, (i) => i);

    // Fisher–Yates シャッフル
    for (var i = list.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }
}
