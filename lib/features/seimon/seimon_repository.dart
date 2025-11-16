import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'seimon_models.dart';

class SeimonRepository {
  SeimonRepository._();
  static final SeimonRepository instance = SeimonRepository._();

  List<SeimonType>? _cache;

  Future<List<SeimonType>> loadAllTypes() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString(
      'assets/seimon/seimon_types.json',
    );
    final Map<String, dynamic> data =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = (data['types'] as List<dynamic>)
        .map((e) => SeimonType.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }

  Future<SeimonType?> getTypeByCode(String code) async {
    final types = await loadAllTypes();
    try {
      return types.firstWhere((t) => t.code == code);
    } catch (_) {
      return null;
    }
  }
}
