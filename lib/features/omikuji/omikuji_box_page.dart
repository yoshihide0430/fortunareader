// lib/features/omikuji/omikuji_box_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'omikuji_models.dart';
import 'omikuji_ticket_page.dart';
import 'dart:ui' as ui;

class OmikujiBoxPage extends StatefulWidget {
  const OmikujiBoxPage({super.key});
  @override
  State<OmikujiBoxPage> createState() => _OmikujiBoxPageState();
}

class _OmikujiBoxPageState extends State<OmikujiBoxPage>
    with TickerProviderStateMixin {
  late final AnimationController _shakeCtrl; // 箱の揺れ（ばね）
  late final AnimationController _stickCtrl; // 棒の突出（下から）
  late final AnimationController _wobbleCtrl; // 棒先の減衰プルプル
  final _sfxShake = AudioPlayer();
  final _sfxStick = AudioPlayer();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _stickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // SFX（存在しなければ無音のまま）
    _sfxShake.setAsset('assets/audio/sfx_shake.mp3').catchError((_) {});
    _sfxStick.setAsset('assets/audio/sfx_stick.mp3').catchError((_) {});
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _stickCtrl.dispose();
    _wobbleCtrl.dispose();
    _sfxShake.dispose();
    _sfxStick.dispose();
    super.dispose();
  }

  Future<void> _draw() async {
    if (_running) return;
    _running = true;
    try {
      HapticFeedback.lightImpact();
      _sfxShake.seek(Duration.zero).catchError((_) {});
      _sfxShake.play().catchError((_) {});

      // ばね的に揺らす
      await _shakeCtrl.animateTo(1.0, curve: Curves.elasticOut);
      // 棒が下からニュッ
      await _stickCtrl.forward(from: 0.0);

      HapticFeedback.mediumImpact();
      _sfxStick.seek(Duration.zero).catchError((_) {});
      _sfxStick.play().catchError((_) {});
      _wobbleCtrl.forward(from: 0.0);

      // 番号を 1..500 で決定
      final number = Random().nextInt(500) + 1;

      // 結果を取得（番号→id対応）
      final repo = OmikujiRepository();
      final fortune = await repo.getByNumber(number);

      if (!mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, __, ___) =>
              OmikujiTicketPage(result: fortune, stickNumber: number),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );

      // 戻ってきたらリセット
      _stickCtrl.value = 0;
      _wobbleCtrl.value = 0;
      _shakeCtrl.value = 0;
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final shake = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 70,
      ),
    ]).animate(_shakeCtrl);

    final stickOut = CurvedAnimation(
      parent: _stickCtrl,
      curve: Curves.easeOutCubic,
    );
    final wobble = _wobbleCtrl.drive(Tween<double>(begin: 0, end: 1));
    double wobbleAngle() {
      final t = wobble.value;
      const amp = 0.06, lambda = 3.0, omega = 14.0;
      return amp * exp(-lambda * t) * sin(omega * t);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('おみくじ')),
      body: GestureDetector(
        onVerticalDragEnd: (_) => _draw(),
        onTap: _draw,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_shakeCtrl, _stickCtrl, _wobbleCtrl]),
            builder: (context, _) {
              final dx = sin(shake.value * pi * 6) * 10;
              final out = stickOut.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Transform.translate(
                    offset: Offset(dx, 0),
                    child: _BoxWidget(
                      width: 260,
                      height: 200,
                      body: scheme.surface.withOpacity(0.96),
                      edge: scheme.primary,
                    ),
                  ),
                  // 棒：下から出す（bottom を動かす）
                  Positioned(
                    bottom: -170 + 170 * (1 - out),
                    left: 130 - 12,
                    child: Transform.rotate(
                      angle: wobbleAngle(),
                      alignment: Alignment.topCenter,
                      child: _StickWidget(
                        width: 24,
                        height: 170,
                        numberLabel: '第000番', // 表示はダミー（棒自体の見た目用）
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    left: 0,
                    right: 0,
                    child: Text(
                      '箱をタップ/上下フリックで引く',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 正八角形風・木目陰影・下スリット
class _BoxWidget extends StatelessWidget {
  const _BoxWidget({
    required this.width,
    required this.height,
    required this.body,
    required this.edge,
  });
  final double width, height;
  final Color body, edge;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BoxPainter(body, edge),
    );
  }
}

class _BoxPainter extends CustomPainter {
  final Color c, edge;
  _BoxPainter(this.c, this.edge);

  Path _regularOctagon(Rect r) {
    // 正八角形（各辺45°カット）
    final s = r.shortestSide;
    final cut = s * 0.15;
    final p = Path();
    p.moveTo(r.left + cut, r.top);
    p.lineTo(r.right - cut, r.top);
    p.lineTo(r.right, r.top + cut);
    p.lineTo(r.right, r.bottom - cut);
    p.lineTo(r.right - cut, r.bottom);
    p.lineTo(r.left + cut, r.bottom);
    p.lineTo(r.left, r.bottom - cut);
    p.lineTo(r.left, r.top + cut);
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;

    // 天面（八角形）をやや奥にパース
    final topRect = Rect.fromLTWH(w * 0.10, h * 0.02, w * 0.80, h * 0.32);
    final top = _regularOctagon(topRect);
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c.withOpacity(0.98), c.withOpacity(0.78)],
      ).createShader(topRect);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = edge;

    // 側面ボディ（八角面の下に矩形＋丸Rで近似、影を強めに）
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.22, w * 0.72, h * 0.56),
      const Radius.circular(18),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [c.withOpacity(0.95), c.withOpacity(0.72)],
      ).createShader(bodyRRect.outerRect);

    // 描画順：側面 → 天面（境界が乗る）→ ハイライト
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, stroke);

    canvas.drawPath(top, topPaint);
    canvas.drawPath(top, stroke);

    // 天面のハイライト（木目の照り返しを疑似）
    final topHL = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.10), Colors.transparent],
      ).createShader(topRect);
    canvas.drawPath(top, topHL);

    // 下スリット（金縁）
    final slot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.74, w * 0.16, h * 0.06),
      const Radius.circular(6),
    );
    canvas.drawRRect(slot, Paint()..color = Colors.black.withOpacity(0.78));
    canvas.drawRRect(
      slot,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFD4AF37),
    );

    // 影（箱の落ち影）
    final shadow = Paint()
      ..shader = ui.Gradient.radial(Offset(w * 0.50, h * 0.92), w * 0.40, [
        Colors.black26,
        Colors.transparent,
      ]);
    canvas.drawCircle(Offset(w * 0.50, h * 0.92), w * 0.40, shadow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 木の棒（焼印っぽい見栄え）
class _StickWidget extends StatelessWidget {
  const _StickWidget({
    required this.width,
    required this.height,
    required this.numberLabel,
  });
  final double width, height;
  final String numberLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF82503C), Color(0xFFBF835A)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(1, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          numberLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF2A1A14),
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
