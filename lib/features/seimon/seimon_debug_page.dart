// lib/features/seimon/seimon_debug_page.dart
import 'package:flutter/material.dart';

import 'seimon_repository.dart';
import 'seimon_models.dart';

class SeimonDebugPage extends StatelessWidget {
  const SeimonDebugPage({super.key});

  Future<SeimonType?> _loadCatType() {
    return SeimonRepository.instance.getTypeByCode('cat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('星紋タイプ（デバッグ）')),
      body: FutureBuilder<SeimonType?>(
        future: _loadCatType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }
          final type = snapshot.data;
          if (type == null) {
            return const Center(child: Text('データが見つかりませんでした'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style:
                  Theme.of(context).textTheme.bodyMedium ??
                  const TextStyle(fontSize: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(type.summary),
                  const SizedBox(height: 16),

                  _sectionTitle('性格'),
                  Text(type.personality),
                  const SizedBox(height: 12),

                  _sectionTitle('恋愛の傾向'),
                  Text(type.loveStyle),
                  const SizedBox(height: 12),

                  _sectionTitle('仕事・お金のスタイル'),
                  Text(type.workStyle),
                  const SizedBox(height: 12),

                  _sectionTitle('ストレスサイン'),
                  Text(type.stressSigns),
                  const SizedBox(height: 12),

                  _sectionTitle('整え方のヒント'),
                  Text(type.healingTips),
                  const SizedBox(height: 16),

                  _sectionTitle('一生の流れ'),
                  _bullet('子ども期〜', type.lifeStory.childhood),
                  _bullet('10代後半〜', type.lifeStory.teen),
                  _bullet('20代', type.lifeStory.twenties),
                  _bullet('30代', type.lifeStory.thirties),
                  _bullet('40代以降', type.lifeStory.fortiesPlus),
                  const SizedBox(height: 16),

                  _sectionTitle('結婚相手と出会いやすいタイミング'),
                  for (final mc in type.marriageChances) ...[
                    Text(
                      '・${mc.label}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(mc.text),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),

                  _sectionTitle('ターニングポイント'),
                  for (final tp in type.turningPoints) ...[
                    Text(
                      '・${tp.ageHint}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(tp.text),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _bullet(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
