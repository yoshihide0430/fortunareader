import 'package:flutter/foundation.dart';

/// 1枚の占いカード
class ZodiacCard {
  final int id; // 1〜180
  final int starRank; // 1〜10 （★0.5〜5.0）
  final String title;
  final String main;
  final String love;
  final String work;
  final String money;
  final String health;
  final String luckyColor;
  final String luckyItem;

  const ZodiacCard({
    required this.id,
    required this.starRank,
    required this.title,
    required this.main,
    required this.love,
    required this.work,
    required this.money,
    required this.health,
    required this.luckyColor,
    required this.luckyItem,
  });

  factory ZodiacCard.fromJson(Map<String, dynamic> json) {
    return ZodiacCard(
      id: json['id'] as int,
      starRank: json['starRank'] as int,
      title: json['title'] as String,
      main: json['main'] as String,
      love: json['love'] as String,
      work: json['work'] as String,
      money: json['money'] as String,
      health: json['health'] as String,
      luckyColor: json['luckyColor'] as String,
      luckyItem: json['luckyItem'] as String,
    );
  }
}

/// 1セット分（180枚）のカード束
class ZodiacSet {
  final int setId; // 0〜11
  final String name; // "Dawn of Stars" など
  final List<ZodiacCard> cards;

  const ZodiacSet({
    required this.setId,
    required this.name,
    required this.cards,
  });

  factory ZodiacSet.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>;
    return ZodiacSet(
      setId: json['setId'] as int,
      name: json['name'] as String,
      cards: rawCards
          .map((e) => ZodiacCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// JSON 全体（12セットぶん）
class ZodiacData {
  final int version;
  final List<ZodiacSet> sets;

  const ZodiacData({required this.version, required this.sets});

  factory ZodiacData.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as List<dynamic>;
    return ZodiacData(
      version: json['version'] as int,
      sets: rawSets
          .map((e) => ZodiacSet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
