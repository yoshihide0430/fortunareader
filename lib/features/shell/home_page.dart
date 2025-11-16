import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../core/audio/bgm_service.dart'; // ★ これを追加

const _sand = Color(0xFFEADCC2);
const _night1 = Color(0xFF140F25);
const _night2 = Color(0xFF1C1433);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // 夜空グラデーション背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_night1, _night2],
              ),
            ),
          ),
          // うっすら星屑
          IgnorePointer(
            child: CustomPaint(
              painter: _StarsPainter(color: _sand.withOpacity(0.08)),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  const _TitlePlate(text: '占い館'),
                  const SizedBox(height: 24),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.86,
                      children: const [
                        _FeatureCard(
                          imagePath: 'assets/images/palm.png',
                          title: '手相',
                          subtitle: '手のしるしを読む',
                          route: AppRoutes.palm,
                        ),
                        _FeatureCard(
                          imagePath: 'assets/images/zodiac.png',
                          title: '星座占い',
                          subtitle: '12星座の導き',
                          route: AppRoutes.zodiac,
                        ),
                        _FeatureCard(
                          imagePath: 'assets/images/daily.png',
                          title: '姓名判断',
                          subtitle: '名前と生年月日から',
                          route: AppRoutes.numerology, // 仮
                        ),
                        _FeatureCard(
                          imagePath: 'assets/images/omikuji.png',
                          title: 'おみくじ',
                          subtitle: '今日のひと言',
                          route: AppRoutes.omikuji,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 額縁タイトル
class _TitlePlate extends StatelessWidget {
  const _TitlePlate({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _sand, width: 2),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: _sand,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

/// 画像ボタン（生成りボーダー＋浮き感）
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.58),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _sand, width: 2),
      ),
      clipBehavior: Clip.antiAlias, // 角丸内に収める
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 画像エリア：高さは余りに応じて可変
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain, // 全体を表示
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _sand,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _sand.withOpacity(0.78)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 星屑ペインタ
class _StarsPainter extends CustomPainter {
  _StarsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width, h = size.height;
    final points = <Offset>[
      Offset(w * .15, h * .12),
      Offset(w * .30, h * .20),
      Offset(w * .75, h * .18),
      Offset(w * .60, h * .35),
      Offset(w * .20, h * .55),
      Offset(w * .85, h * .62),
      Offset(w * .40, h * .78),
      Offset(w * .10, h * .85),
    ];
    for (final p in points) {
      canvas.drawCircle(p, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
