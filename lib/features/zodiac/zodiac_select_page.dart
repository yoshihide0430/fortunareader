import 'package:flutter/material.dart';

import 'zodiac_repository.dart';
import 'zodiac_signs.dart';
import 'zodiac_result_page.dart';

const _sand = Color(0xFFEADCC2);
const _night1 = Color(0xFF140F25);
const _night2 = Color(0xFF1C1433);

class ZodiacSelectPage extends StatelessWidget {
  const ZodiacSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('星座占い'), backgroundColor: _night1),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_night1, _night2],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日付と説明
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(now),
                      style: const TextStyle(color: _sand, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '12星座から選んで、今日の運勢を見てみましょう。',
                      style: TextStyle(color: _sand, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: kZodiacSignMetas
                        .map((meta) => _ZodiacSelectTile(meta: meta))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final w = weekdays[d.weekday - 1];
    return '${d.year}年${d.month}月${d.day}日（$w）';
  }
}

class _ZodiacSelectTile extends StatelessWidget {
  const _ZodiacSelectTile({required this.meta});

  final ZodiacSignMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.black.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _sand, width: 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ZodiacResultPage(sign: meta.sign),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Expanded(child: _buildIcon()),
              const SizedBox(height: 4),
              Text(
                meta.jpName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _sand,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                meta.period,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _sand.withOpacity(0.8),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // 将来画像を使いたくなったとき用：assetPath があれば画像優先
    if (meta.assetPath != null) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          meta.assetPath!,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    // 画像がない場合は星座マーク（♈〜♓）を表示
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _sand, width: 1.5),
          color: Colors.black.withOpacity(0.2),
        ),
        alignment: Alignment.center,
        child: Text(
          meta.symbol,
          style: const TextStyle(
            color: _sand,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
