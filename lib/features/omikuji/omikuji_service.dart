// lib/features/omikuji/omikuji_service.dart
import 'dart:math';

enum OmikujiRank { daikichi, kichi, chuukichi, shoukichi, suekichi, kyou }

class OmikujiResult {
  final OmikujiRank rank;
  final String overall;
  final String work;
  final String social;
  final String luckyColor;
  final int luckyNumber;
  const OmikujiResult({
    required this.rank,
    required this.overall,
    required this.work,
    required this.social,
    required this.luckyColor,
    required this.luckyNumber,
  });
}

class OmikujiService {
  // 日替わりの安定seedを作成（userIdが無ければ'guest'）
  int _seedFor(String userId, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final key = '${userId}_$d';
    // 簡易ハッシュ
    var h = 0;
    for (final c in key.codeUnits) {
      h = (h * 131 + c) & 0x7fffffff;
    }
    return h;
  }

  OmikujiResult draw({required String userId, DateTime? when}) {
    final now = when ?? DateTime.now();
    final rand = Random(_seedFor(userId.isEmpty ? 'guest' : userId, now));

    // ランクを加重抽選
    final table = [
      ...List.filled(8, OmikujiRank.daikichi),
      ...List.filled(18, OmikujiRank.kichi),
      ...List.filled(22, OmikujiRank.chuukichi),
      ...List.filled(22, OmikujiRank.shoukichi),
      ...List.filled(20, OmikujiRank.suekichi),
      ...List.filled(10, OmikujiRank.kyou),
    ];
    final rank = table[rand.nextInt(table.length)];

    const colors = [
      '赤',
      '青',
      '緑',
      '紫',
      '黄',
      '白',
      '黒',
      '金',
      '銀',
      '橙',
      '水色',
      '桃',
    ];
    final luckyColor = colors[rand.nextInt(colors.length)];
    final luckyNumber = rand.nextInt(9) + 1;

    String t(OmikujiRank r) {
      switch (r) {
        case OmikujiRank.daikichi:
          return '流れは追い風。まず小さく始めると大きく育つ日。';
        case OmikujiRank.kichi:
          return '堅実さが吉。丁寧な確認が成果を引き寄せる。';
        case OmikujiRank.chuukichi:
          return '等速前進。手元の改善がじわっと効いてくる。';
        case OmikujiRank.shoukichi:
          return '背伸びは不要。積み上げを信じよう。';
        case OmikujiRank.suekichi:
          return '焦らず整えると良い兆し。基礎を固めよう。';
        case OmikujiRank.kyou:
          return '無理に動かず、体勢を整える日。休む勇気も力。';
      }
    }

    // 短文を日替わりで変える
    String pick(List<String> list) => list[rand.nextInt(list.length)];

    final overall = t(rank);
    final work = pick([
      'ToDoを3つに絞ると進む。',
      '5分レビューで抜けを減らそう。',
      '早めの共有が手戻りを防ぐ。',
      '朝の10分で段取り確認。',
    ]);
    final social = pick([
      '先に挨拶、先に感謝。',
      '短い返信でもスピード重視。',
      '相手の都合を一言添えると吉。',
      '笑顔で目線を合わせると良し。',
    ]);

    return OmikujiResult(
      rank: rank,
      overall: overall,
      work: work,
      social: social,
      luckyColor: luckyColor,
      luckyNumber: luckyNumber,
    );
  }

  static String rankLabel(OmikujiRank r) {
    switch (r) {
      case OmikujiRank.daikichi:
        return '大吉';
      case OmikujiRank.kichi:
        return '吉';
      case OmikujiRank.chuukichi:
        return '中吉';
      case OmikujiRank.shoukichi:
        return '小吉';
      case OmikujiRank.suekichi:
        return '末吉';
      case OmikujiRank.kyou:
        return '凶';
    }
  }
}
