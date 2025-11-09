import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'omikuji_models.dart';
import 'omikuji_ticket_page.dart';
import '../../core/audio/sfx_service.dart';

class OmikujiBoxPage extends StatefulWidget {
  const OmikujiBoxPage({super.key});
  @override
  State<OmikujiBoxPage> createState() => _OmikujiBoxPageState();
}

class _OmikujiBoxPageState extends State<OmikujiBoxPage>
    with TickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  late final AnimationController _stickCtrl;
  late final Animation<double> _stickSlide;

  bool _isAnimating = false;
  bool _stickVisible = false;
  int? _currentNumber;

  // 箱（グループ全体）の見た目角度
  static const double _tiltDeg = 115;
  double get _tiltRad => _tiltDeg * pi / 180;

  @override
  void initState() {
    super.initState();

    // 箱を振る
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: -0.12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.00), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // 棒のスライド（右下にズレつつ伸びる）
    _stickCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _stickSlide = CurvedAnimation(
      parent: _stickCtrl,
      curve: Curves.easeOutBack,
    );

    _stickCtrl.addListener(() => setState(() {})); // 棒の再描画

    _shakeCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _stickVisible = true);
        SfxService().playStick();
        _stickCtrl.forward(from: 0);
      }
    });

    _stickCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 380), _showResult);
      }
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _stickCtrl.dispose();
    super.dispose();
  }

  Future<void> _drawOmikuji() async {
    if (_isAnimating) return;

    final number = Random().nextInt(500) + 1; // 1..500

    HapticFeedback.lightImpact();
    SfxService().playShake();
    setState(() {
      _isAnimating = true;
      _stickVisible = false;
      _currentNumber = number;
    });

    _shakeCtrl.forward(from: 0);
  }

  Future<void> _showResult() async {
    if (!mounted || _currentNumber == null) return;
    final repo = OmikujiRepository();
    final fortune = await repo.getByNumber(_currentNumber!);

    if (!mounted) return;
    SfxService().playPaper();
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) =>
            OmikujiTicketPage(result: fortune, stickNumber: _currentNumber!),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );

    if (!mounted) return;
    setState(() {
      _isAnimating = false;
      _stickVisible = false;
      _currentNumber = null;
    });
    _shakeCtrl.reset();
    _stickCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    // ===== キャンバスと画像サイズ =====
    const double groupW = 320;
    const double groupH = 360;
    const double boxW = 220;
    const double boxH = 260;

    // ===== 箱画像内の穴の相対位置（0〜1） =====
    const double holeRelX = 0.53; // 右寄り
    const double holeRelY = 0.24; // 下寄り

    // ===== 棒サイズ =====
    const double stickLen = 180;
    const double stickW = 60;

    // ===== 右下へのスライド量（“振った後に右下へ”） =====
    const double slideDx = 30; // →
    const double slideDy = -50; // ↓

    // さらに“気持ち下げる”微調整
    const double extraDown = 30; // ← ここで下方向にオフセット

    // ===== 穴中心の基準座標（グループ内px） =====
    final baseLeft = (groupW - boxW) / 2 + boxW * holeRelX;
    final baseTop = (groupH - boxH) / 2 + boxH * holeRelY;

    Widget group() {
      return SizedBox(
        width: groupW,
        height: groupH,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 箱（タップ/フリックで引く）
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, __) => Transform.rotate(
                angle: _shakeAnim.value,
                child: GestureDetector(
                  onTap: _drawOmikuji,
                  onVerticalDragEnd: (_) => _drawOmikuji(),
                  child: Image.asset(
                    'assets/images/omikuji_box.png',
                    width: boxW,
                    height: boxH,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 棒：右下にズレつつ、上→下に“伸びて見える”（マスク使用）
            if (_stickVisible)
              AnimatedBuilder(
                animation: _stickCtrl,
                builder: (_, __) {
                  final v = _stickSlide.value.clamp(0.0, 1.0);
                  // ❶ ゆっくり見せる（体感を遅く）：最後に向かって加速する代わりに全体を少し間延び
                  final slowV = Curves.easeOutCubic.transform(
                    v * 0.75,
                  ); // 0.75で全体を少しゆっくり

                  // ❷ “見えるのは半分だけ” に制限（0〜0.5）
                  const maxReveal = 0.5;
                  final revealV = (slowV * maxReveal).clamp(0.001, maxReveal);

                  // 座標：スライドは全体の進行 slowV に、棒の“伸び量/マスク”は revealV に
                  final left = baseLeft - (stickW / 2) + slideDx * slowV;
                  final top =
                      baseTop -
                      (stickLen * revealV) +
                      slideDy * slowV +
                      extraDown;

                  return Positioned(
                    left: left,
                    top: top,
                    child: Opacity(
                      opacity: slowV, // 透明度もゆっくり
                      child: Transform.rotate(
                        angle: 0.0, // 必要なら回転を入れる（例: 0.12）
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: revealV, // ← “上→下に半分だけ”見せる
                            child: SizedBox(
                              width: stickW,
                              height: stickLen,
                              child: const _StickImage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('おみくじ')),
      body: Center(
        child: Transform.rotate(
          angle: _tiltRad, // 箱＋棒を下向きに見せる
          child: group(),
        ),
      ),
    );
  }
}

/// 棒（番号表示なし）
class _StickImage extends StatelessWidget {
  const _StickImage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/omikuji_stick.png',
          fit: BoxFit.fill,
          errorBuilder: (_, __, ___) {
            // 画像がない場合のフォールバック描画
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE6B78E), Color(0xFFB27B53)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(1, 4),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
