import 'package:flutter/material.dart';

import 'zodiac_repository.dart';
import 'zodiac_signs.dart';
import 'zodiac_models.dart';

const _sand = Color(0xFFEADCC2);
const _night1 = Color(0xFF140F25);
const _night2 = Color(0xFF1C1433);

class ZodiacResultPage extends StatefulWidget {
  const ZodiacResultPage({super.key, required this.sign});

  final ZodiacSign sign;

  @override
  State<ZodiacResultPage> createState() => _ZodiacResultPageState();
}

class _ZodiacResultPageState extends State<ZodiacResultPage> {
  late Future<ZodiacCard> _future;

  @override
  void initState() {
    super.initState();
    _future = ZodiacRepository.instance.pickTodayCard(sign: widget.sign);
  }

  @override
  Widget build(BuildContext context) {
    final meta = metaOf(widget.sign);

    return Scaffold(
      appBar: AppBar(
        title: Text('${meta.jpName} の運勢'),
        backgroundColor: _night1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_night1, _night2],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<ZodiacCard>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_sand),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '星のメッセージを読み取るのに失敗しました。\nしばらくしてからもう一度お試しください。',
                      style: const TextStyle(color: _sand),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final card = snapshot.data!;
              return _ResultBody(meta: meta, card: card);
            },
          ),
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.meta, required this.card});

  final ZodiacSignMeta meta;
  final ZodiacCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Card(
        color: Colors.black.withOpacity(0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _sand, width: 1.6),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー：星座名 + 日付 + 星ランク
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _HeaderText(meta: meta)),
                  const SizedBox(width: 8),
                  _StarRankBadge(starRank: card.starRank),
                ],
              ),
              const SizedBox(height: 16),

              // タイトル
              Text(
                card.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: _sand,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 総合運
              _SectionTitle(icon: '✨', label: '総合運'),
              const SizedBox(height: 4),
              Text(
                card.main,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _sand,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: _sand, height: 24, thickness: 0.3),

              // 恋愛運
              _SectionTitle(icon: '❤️', label: '恋愛運'),
              const SizedBox(height: 4),
              Text(
                card.love,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _sand,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: _sand, height: 24, thickness: 0.3),

              // 仕事運
              _SectionTitle(icon: '💼', label: '仕事運'),
              const SizedBox(height: 4),
              Text(
                card.work,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _sand,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: _sand, height: 24, thickness: 0.3),

              // 金運
              _SectionTitle(icon: '💰', label: '金運'),
              const SizedBox(height: 4),
              Text(
                card.money,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _sand,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: _sand, height: 24, thickness: 0.3),

              // 健康運
              _SectionTitle(icon: '💊', label: '健康運'),
              const SizedBox(height: 4),
              Text(
                card.health,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _sand,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: _sand, height: 24, thickness: 0.3),

              // ラッキー系
              Text(
                'ラッキーカラー：${card.luckyColor}',
                style: theme.textTheme.bodyMedium?.copyWith(color: _sand),
              ),
              const SizedBox(height: 4),
              Text(
                'ラッキーアイテム：${card.luckyItem}',
                style: theme.textTheme.bodyMedium?.copyWith(color: _sand),
              ),

              const SizedBox(height: 16),
              Text(
                '※ この占いは傾向やイメージをもとにしたメッセージです。気軽に楽しむヒントとして受け取ってください。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _sand.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.meta});
  final ZodiacSignMeta meta;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${now.year}年${now.month}月${now.day}日';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meta.jpName,
          style: const TextStyle(
            color: _sand,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(meta.period, style: const TextStyle(color: _sand, fontSize: 12)),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(color: _sand, fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _sand,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StarRankBadge extends StatelessWidget {
  const _StarRankBadge({required this.starRank});

  final int starRank; // 1〜10

  @override
  Widget build(BuildContext context) {
    final value = starRank / 2.0; // 0.5〜5.0

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final pos = index + 1; // 1〜5
            IconData icon;
            if (value >= pos) {
              icon = Icons.star;
            } else if (value >= pos - 0.5) {
              icon = Icons.star_half;
            } else {
              icon = Icons.star_border;
            }
            return Icon(icon, size: 18, color: _sand);
          }),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(1)} / 5.0',
          style: const TextStyle(color: _sand, fontSize: 11),
        ),
      ],
    );
  }
}
