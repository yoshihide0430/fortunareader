import 'zodiac_repository.dart';

/// 1つの星座のメタ情報
class ZodiacSignMeta {
  final ZodiacSign sign;
  final String jpName; // 日本語名（おひつじ座 etc）
  final String period; // 日付範囲（3/21 - 4/19 など）
  final String symbol; // 星座マーク（♈, ♉, ...）
  final String? assetPath; // 画像を使うならここにパス

  const ZodiacSignMeta({
    required this.sign,
    required this.jpName,
    required this.period,
    required this.symbol,
    this.assetPath,
  });
}

/// 12星座の一覧（enum ZodiacSign の順番と揃えてある）
const List<ZodiacSignMeta> kZodiacSignMetas = [
  ZodiacSignMeta(
    sign: ZodiacSign.aries,
    jpName: 'おひつじ座',
    period: '3/21 - 4/19',
    symbol: '♈',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.taurus,
    jpName: 'おうし座',
    period: '4/20 - 5/20',
    symbol: '♉',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.gemini,
    jpName: 'ふたご座',
    period: '5/21 - 6/21',
    symbol: '♊',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.cancer,
    jpName: 'かに座',
    period: '6/22 - 7/22',
    symbol: '♋',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.leo,
    jpName: 'しし座',
    period: '7/23 - 8/22',
    symbol: '♌',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.virgo,
    jpName: 'おとめ座',
    period: '8/23 - 9/22',
    symbol: '♍',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.libra,
    jpName: 'てんびん座',
    period: '9/23 - 10/23',
    symbol: '♎',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.scorpio,
    jpName: 'さそり座',
    period: '10/24 - 11/22',
    symbol: '♏',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.sagittarius,
    jpName: 'いて座',
    period: '11/23 - 12/21',
    symbol: '♐',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.capricorn,
    jpName: 'やぎ座',
    period: '12/22 - 1/19',
    symbol: '♑',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.aquarius,
    jpName: 'みずがめ座',
    period: '1/20 - 2/18',
    symbol: '♒',
    assetPath: null,
  ),
  ZodiacSignMeta(
    sign: ZodiacSign.pisces,
    jpName: 'うお座',
    period: '2/19 - 3/20',
    symbol: '♓',
    assetPath: null,
  ),
];

ZodiacSignMeta metaOf(ZodiacSign sign) {
  return kZodiacSignMetas.firstWhere((m) => m.sign == sign);
}
