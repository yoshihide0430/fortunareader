import 'package:flutter/foundation.dart';

@immutable
class SeimonType {
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
  final SeimonLifeStory lifeStory;
  final List<SeimonMarriageChance> marriageChances;
  final List<SeimonTurningPoint> turningPoints;
  final SeimonCompatibility compatibility;

  const SeimonType({
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

  factory SeimonType.fromJson(Map<String, dynamic> json) {
    return SeimonType(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      personality: json['personality'] as String,
      loveStyle: json['loveStyle'] as String,
      workStyle: json['workStyle'] as String,
      stressSigns: json['stressSigns'] as String,
      healingTips: json['healingTips'] as String,
      lifeStory: SeimonLifeStory.fromJson(
        json['lifeStory'] as Map<String, dynamic>,
      ),
      marriageChances: (json['marriageChances'] as List<dynamic>)
          .map((e) => SeimonMarriageChance.fromJson(e as Map<String, dynamic>))
          .toList(),
      turningPoints: (json['turningPoints'] as List<dynamic>)
          .map((e) => SeimonTurningPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      compatibility: SeimonCompatibility.fromJson(
        json['compatibility'] as Map<String, dynamic>,
      ),
    );
  }
}

@immutable
class SeimonLifeStory {
  final String childhood;
  final String teen;
  final String twenties;
  final String thirties;
  final String fortiesPlus;

  const SeimonLifeStory({
    required this.childhood,
    required this.teen,
    required this.twenties,
    required this.thirties,
    required this.fortiesPlus,
  });

  factory SeimonLifeStory.fromJson(Map<String, dynamic> json) {
    return SeimonLifeStory(
      childhood: json['childhood'] as String,
      teen: json['teen'] as String,
      twenties: json['twenties'] as String,
      thirties: json['thirties'] as String,
      fortiesPlus: json['fortiesPlus'] as String,
    );
  }
}

@immutable
class SeimonMarriageChance {
  final String label; // 例: "23〜25歳ごろ"
  final String text;

  const SeimonMarriageChance({required this.label, required this.text});

  factory SeimonMarriageChance.fromJson(Map<String, dynamic> json) {
    return SeimonMarriageChance(
      label: json['label'] as String,
      text: json['text'] as String,
    );
  }
}

@immutable
class SeimonTurningPoint {
  final String ageHint; // 例: "30代前半"
  final String text;

  const SeimonTurningPoint({required this.ageHint, required this.text});

  factory SeimonTurningPoint.fromJson(Map<String, dynamic> json) {
    return SeimonTurningPoint(
      ageHint: json['ageHint'] as String,
      text: json['text'] as String,
    );
  }
}

@immutable
class SeimonCompatibility {
  final List<String> goodMatchLove;
  final List<String> bestMarriage;
  final List<String> excitingButTiring;
  final List<String> difficultMatch;

  const SeimonCompatibility({
    required this.goodMatchLove,
    required this.bestMarriage,
    required this.excitingButTiring,
    required this.difficultMatch,
  });

  factory SeimonCompatibility.fromJson(Map<String, dynamic> json) {
    List<String> _toStringList(String key) {
      final list = json[key] as List<dynamic>;
      return list.map((e) => e as String).toList();
    }

    return SeimonCompatibility(
      goodMatchLove: _toStringList('goodMatchLove'),
      bestMarriage: _toStringList('bestMarriage'),
      excitingButTiring: _toStringList('excitingButTiring'),
      difficultMatch: _toStringList('difficultMatch'),
    );
  }
}
