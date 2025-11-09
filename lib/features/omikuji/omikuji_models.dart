// lib/features/omikuji/omikuji_models.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class OmikujiFortune {
  final int id;
  final String fortune; // 大吉/吉/…
  final String kotoba;
  final Map<String, String> items;
  final String mamori;
  final String kichiType; // 例: 方位
  final String kichiValue; // 例: 南

  OmikujiFortune({
    required this.id,
    required this.fortune,
    required this.kotoba,
    required this.items,
    required this.mamori,
    required this.kichiType,
    required this.kichiValue,
  });

  factory OmikujiFortune.fromJson(Map<String, dynamic> j) {
    final map = <String, String>{};
    (j['items'] as Map<String, dynamic>).forEach(
      (k, v) => map[k] = v.toString(),
    );
    return OmikujiFortune(
      id: j['id'] as int,
      fortune: j['fortune'] as String,
      kotoba: j['kotoba'] as String,
      items: map,
      mamori: j['mamori'] as String,
      kichiType: (j['kichi']?['type'] ?? '').toString(),
      kichiValue: (j['kichi']?['value'] ?? '').toString(),
    );
  }
}

class OmikujiRepository {
  List<OmikujiFortune>? _cache;

  Future<List<OmikujiFortune>> load() async {
    if (_cache != null) return _cache!;
    final txt = await rootBundle.loadString('assets/omikuji/fortunes.json');
    final List<dynamic> arr = jsonDecode(txt);
    _cache = arr.map((e) => OmikujiFortune.fromJson(e)).toList(growable: false);
    return _cache!;
  }

  /// 1..N（通常は500）で探す。無ければインデックスで近似。
  Future<OmikujiFortune> getByNumber(int number) async {
    final list = await load();
    final hit = list.where((e) => e.id == number).toList();
    if (hit.isNotEmpty) return hit.first;
    return list[(number - 1) % list.length];
  }
}
