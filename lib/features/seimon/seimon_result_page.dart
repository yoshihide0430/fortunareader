import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 姓名判断の結果画面（星紋姓名術）
class SeimonResultPage extends StatelessWidget {
  const SeimonResultPage({
    super.key,
    required this.typeCode,
    this.name,
    this.birthDate,
    this.gender,
  });

  /// 星紋タイプコード（cat / dog / rabbit / ...）
  final String typeCode;

  /// 入力された名前
  final String? name;

  /// 生年月日
  final DateTime? birthDate;

  /// 性別 'male' / 'female' / 'other'
  final String? gender;

  // 1タイプあたり 0〜499 の 500バリアント
  static const int _kVariantCount = 500;

  /// 名前＋生年月日＋性別＋タイプから 0〜499 のバリアント番号を決める
  int _computeVariantIndex() {
    final base =
        '${name ?? ''}|${birthDate?.toIso8601String() ?? ''}|${gender ?? ''}|$typeCode';
    var hash = 0;
    for (final codeUnit in base.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    // マイナスにならないように absolute 化してから 0〜499 に収める
    final positive = hash & 0x7fffffff;
    return positive % _kVariantCount;
  }

  Future<_SeimonTypeData> _loadTypeData() async {
    // ───── 1. マスター（12タイプ）の読み込み
    final typesText = await rootBundle.loadString(
      'assets/seimon/seimon_types.json',
    );
    final dynamic typesDecoded = json.decode(typesText);

    List<dynamic> rawTypes;
    if (typesDecoded is List) {
      rawTypes = typesDecoded;
    } else if (typesDecoded is Map<String, dynamic>) {
      final inner =
          typesDecoded['types'] ??
          typesDecoded['data'] ??
          typesDecoded['items'];
      if (inner is List) {
        rawTypes = inner;
      } else {
        throw Exception('seimon_types.json の構造が想定外です');
      }
    } else {
      throw Exception('seimon_types.json の構造が想定外です');
    }

    // code → name（日本語ラベル）マップを作る（相性表示用）
    final Map<String, String> codeToName = {};
    for (final item in rawTypes) {
      if (item is! Map<String, dynamic>) continue;
      final c = item['code']?.toString();
      if (c == null) continue;
      final label = (item['name'] ?? item['title'] ?? c).toString();
      codeToName[c] = label;
    }

    // 対象タイプのマスターデータ
    final Map<String, dynamic> master = rawTypes
        .whereType<Map<String, dynamic>>()
        .firstWhere((m) => m['code']?.toString() == typeCode, orElse: () => {});

    if (master.isEmpty) {
      throw Exception('typeCode=$typeCode のマスターデータが見つかりませんでした');
    }

    // ───── 2. バリアント（12×500 = 6000件）の読み込み
    final variantIndex = _computeVariantIndex();

    final variantsText = await rootBundle.loadString(
      'assets/seimon/seimon_variants.json',
    );
    final dynamic variantsDecoded = json.decode(variantsText);

    List<dynamic> rawVariants;

    if (variantsDecoded is Map<String, dynamic>) {
      final inner = variantsDecoded['variants'];
      if (inner is List) {
        rawVariants = inner;
      } else {
        throw Exception('seimon_variants.json の構造が想定外です');
      }
    } else if (variantsDecoded is List) {
      rawVariants = variantsDecoded;
    } else {
      throw Exception('seimon_variants.json の構造が想定外です');
    }

    Map<String, dynamic>? variant;

    // typeCode & variantIndex で探す
    for (final v in rawVariants.whereType<Map<String, dynamic>>()) {
      if (v['typeCode']?.toString() == typeCode &&
          (v['variantIndex'] is int
              ? v['variantIndex'] == variantIndex
              : int.tryParse(v['variantIndex']?.toString() ?? '') ==
                    variantIndex)) {
        variant = v;
        break;
      }
    }

    // 万が一見つからなかったら、その typeCode の最初の1件を使う
    variant ??= rawVariants.whereType<Map<String, dynamic>>().firstWhere(
      (v) => v['typeCode']?.toString() == typeCode,
      orElse: () => <String, dynamic>{},
    );

    return _SeimonTypeData.fromMasterAndVariant(master, codeToName, variant);
  }

  String _formatBirthDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatGender(String? g) {
    switch (g) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      case 'other':
        return 'その他';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('姓名判断 結果')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF140F25), Color(0xFF1C1433)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_SeimonTypeData>(
            future: _loadTypeData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '結果の読み込み中にエラーが発生しました。\n${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final data = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ───────────── ヘッダー
                    Card(
                      color: Colors.black.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (data.title.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                data.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor.withOpacity(0.9),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (name != null ||
                                birthDate != null ||
                                gender != null)
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  if (name != null && name!.isNotEmpty)
                                    Text(
                                      '名前：$name',
                                      style: const TextStyle(color: textColor),
                                    ),
                                  if (birthDate != null)
                                    Text(
                                      '生年月日：${_formatBirthDate(birthDate)}',
                                      style: const TextStyle(color: textColor),
                                    ),
                                  if (gender != null)
                                    Text(
                                      '性別：${_formatGender(gender)}',
                                      style: const TextStyle(color: textColor),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ───────────── 全体の傾向
                    _SectionTitle(title: '全体の傾向', color: textColor),
                    const SizedBox(height: 8),
                    _SectionBox(
                      child: Text(
                        data.summary,
                        style: const TextStyle(color: textColor, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ───────────── 性格・スタイル
                    _SectionTitle(title: '性格・スタイル', color: textColor),
                    const SizedBox(height: 8),
                    _SectionBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.personality.isNotEmpty) ...[
                            const Text(
                              '◆ 性格の傾向',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.personality,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.loveStyle.isNotEmpty) ...[
                            const Text(
                              '◆ 恋愛のスタイル',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.loveStyle,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.workStyle.isNotEmpty) ...[
                            const Text(
                              '◆ 仕事のスタイル',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.workStyle,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ───────────── ストレスと癒し
                    if (data.stressSigns.isNotEmpty ||
                        data.healingTips.isNotEmpty) ...[
                      _SectionTitle(title: 'ストレスサインと癒し方', color: textColor),
                      const SizedBox(height: 8),
                      _SectionBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.stressSigns.isNotEmpty) ...[
                              const Text(
                                '◆ ストレスサイン',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.stressSigns,
                                style: const TextStyle(
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (data.healingTips.isNotEmpty) ...[
                              const Text(
                                '◆ 回復のヒント',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.healingTips,
                                style: const TextStyle(
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ───────────── 一生の流れ（バリアント）
                    _SectionTitle(title: '一生の流れ', color: textColor),
                    const SizedBox(height: 8),
                    _SectionBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.lifeStory.childhood.isNotEmpty) ...[
                            const Text(
                              '◆ 子ども時代',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.lifeStory.childhood,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.lifeStory.teen.isNotEmpty) ...[
                            const Text(
                              '◆ 10代',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.lifeStory.teen,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.lifeStory.twenties.isNotEmpty) ...[
                            const Text(
                              '◆ 20代',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.lifeStory.twenties,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.lifeStory.thirties.isNotEmpty) ...[
                            const Text(
                              '◆ 30代',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.lifeStory.thirties,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.lifeStory.fortiesPlus.isNotEmpty) ...[
                            const Text(
                              '◆ 40代以降',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.lifeStory.fortiesPlus,
                              style: const TextStyle(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ───────────── ターニングポイント（バリアント）
                    if (data.turningPoints.isNotEmpty) ...[
                      _SectionTitle(title: 'ターニングポイント', color: textColor),
                      const SizedBox(height: 8),
                      _SectionBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: data.turningPoints
                              .map(
                                (tp) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tp.ageHint,
                                        style: const TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tp.text,
                                        style: const TextStyle(
                                          color: textColor,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ───────────── 結婚・出会いタイミング（バリアント）
                    if (data.marriageChances.isNotEmpty) ...[
                      _SectionTitle(title: '結婚・出会いのタイミング', color: textColor),
                      const SizedBox(height: 8),
                      _SectionBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: data.marriageChances
                              .map(
                                (mc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mc.label,
                                        style: const TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mc.text,
                                        style: const TextStyle(
                                          color: textColor,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ───────────── 相性（マスター12件側）
                    _SectionTitle(title: '相性の良いタイプ・注意したいタイプ', color: textColor),
                    const SizedBox(height: 8),
                    _SectionBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.compatibility.bestMarriage.isNotEmpty) ...[
                            const Text(
                              '◆ 結婚相手として最適',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.compatibility.bestMarriage.join(' / '),
                              style: const TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.compatibility.goodMatchLove.isNotEmpty) ...[
                            const Text(
                              '◆ 恋愛の相性が良いタイプ',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.compatibility.goodMatchLove.join(' / '),
                              style: const TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data
                              .compatibility
                              .excitingButTiring
                              .isNotEmpty) ...[
                            const Text(
                              '◆ ドキドキするけど疲れやすい相手',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.compatibility.excitingButTiring.join(' / '),
                              style: const TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (data.compatibility.difficultMatch.isNotEmpty) ...[
                            const Text(
                              '◆ 価値観がぶつかりやすい相手',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.compatibility.difficultMatch.join(' / '),
                              style: const TextStyle(color: textColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 星紋タイプ + バリアントをまとめたデータ
class _SeimonTypeData {
  _SeimonTypeData({
    required this.id,
    required this.code,
    required this.name,
    required this.title,
    required this.summary,
    required this.personality,
    required this.loveStyle,
    required this.workStyle,
    required this.stressSigns,
    required this.healingTips,
    required this.lifeStory,
    required this.marriageChances,
    required this.turningPoints,
    required this.compatibility,
  });

  final int id;
  final String code;
  final String name;
  final String title;
  final String summary;
  final String personality;
  final String loveStyle;
  final String workStyle;
  final String stressSigns;
  final String healingTips;
  final _LifeStory lifeStory;
  final List<_MarriageChance> marriageChances;
  final List<_TurningPoint> turningPoints;
  final _Compatibility compatibility;

  factory _SeimonTypeData.fromMasterAndVariant(
    Map<String, dynamic> master,
    Map<String, String> codeToName,
    Map<String, dynamic>? variant,
  ) {
    int _i(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String _s(dynamic v) => v?.toString() ?? '';

    List<dynamic> _list(dynamic v) => v is List ? v : const [];

    List<String> _labelsFromCodes(List<dynamic> codes) {
      return codes
          .map((e) => e.toString())
          .map((code) => codeToName[code] ?? code)
          .toList();
    }

    final lifeMaster = master['lifeStory'] as Map<String, dynamic>? ?? {};
    final lifeVariant = variant?['lifeStory'] as Map<String, dynamic>? ?? {};

    Map<String, dynamic> _mergeLife() {
      // variant があればそっちを優先（なければ master）
      return {
        'childhood': lifeVariant['childhood'] ?? lifeMaster['childhood'],
        'teen': lifeVariant['teen'] ?? lifeMaster['teen'],
        'twenties': lifeVariant['twenties'] ?? lifeMaster['twenties'],
        'thirties': lifeVariant['thirties'] ?? lifeMaster['thirties'],
        'fortiesPlus': lifeVariant['fortiesPlus'] ?? lifeMaster['fortiesPlus'],
      };
    }

    final life = _mergeLife();

    final marriageListVariant = _list(variant?['marriageChances']); // バリアント優先
    final marriageListMaster = _list(master['marriageChances']);
    final marriageList = marriageListVariant.isNotEmpty
        ? marriageListVariant
        : marriageListMaster;

    final turningListVariant = _list(variant?['turningPoints']); // バリアント優先
    final turningListMaster = _list(master['turningPoints']);
    final turningList = turningListVariant.isNotEmpty
        ? turningListVariant
        : turningListMaster;

    final comp = master['compatibility'] as Map<String, dynamic>? ?? {};

    return _SeimonTypeData(
      id: _i(master['id']),
      code: _s(master['code']),
      name: _s(master['name']),
      title: _s(master['title']),
      summary: _s(master['summary']),
      personality: _s(master['personality']),
      loveStyle: _s(master['loveStyle']),
      workStyle: _s(master['workStyle']),
      stressSigns: _s(master['stressSigns']),
      healingTips: _s(master['healingTips']),
      lifeStory: _LifeStory(
        childhood: _s(life['childhood']),
        teen: _s(life['teen']),
        twenties: _s(life['twenties']),
        thirties: _s(life['thirties']),
        fortiesPlus: _s(life['fortiesPlus']),
      ),
      marriageChances: marriageList
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => _MarriageChance(label: _s(m['label']), text: _s(m['text'])),
          )
          .toList(),
      turningPoints: turningList
          .whereType<Map<String, dynamic>>()
          .map(
            (m) =>
                _TurningPoint(ageHint: _s(m['ageHint']), text: _s(m['text'])),
          )
          .toList(),
      compatibility: _Compatibility(
        goodMatchLove: _labelsFromCodes(_list(comp['goodMatchLove'])),
        bestMarriage: _labelsFromCodes(_list(comp['bestMarriage'])),
        excitingButTiring: _labelsFromCodes(_list(comp['excitingButTiring'])),
        difficultMatch: _labelsFromCodes(_list(comp['difficultMatch'])),
      ),
    );
  }
}

class _LifeStory {
  _LifeStory({
    required this.childhood,
    required this.teen,
    required this.twenties,
    required this.thirties,
    required this.fortiesPlus,
  });

  final String childhood;
  final String teen;
  final String twenties;
  final String thirties;
  final String fortiesPlus;
}

class _MarriageChance {
  _MarriageChance({required this.label, required this.text});

  final String label;
  final String text;
}

class _TurningPoint {
  _TurningPoint({required this.ageHint, required this.text});

  final String ageHint;
  final String text;
}

class _Compatibility {
  _Compatibility({
    required this.goodMatchLove,
    required this.bestMarriage,
    required this.excitingButTiring,
    required this.difficultMatch,
  });

  final List<String> goodMatchLove;
  final List<String> bestMarriage;
  final List<String> excitingButTiring;
  final List<String> difficultMatch;
}

/// セクションタイトル共通
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// 枠付きコンテンツボックス
class _SectionBox extends StatelessWidget {
  const _SectionBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: child,
    );
  }
}
