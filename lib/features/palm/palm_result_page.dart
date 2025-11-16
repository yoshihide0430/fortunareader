import 'dart:io';

import 'package:flutter/material.dart';

class PalmResultPage extends StatelessWidget {
  const PalmResultPage({super.key, required this.imageFile});

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('手相占い結果（仮）')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF140F25), Color(0xFF1C1433)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ───── 撮影画像 + ラインオーバーレイ
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(imageFile, fit: BoxFit.cover),
                        // うっすら暗くしてラインを見やすく
                        Container(color: Colors.black.withOpacity(0.18)),
                        // 手相ラインを描画
                        IgnorePointer(
                          child: CustomPaint(painter: _PalmLinesPainter()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Colors.black.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'ここに本格的な手相解析の結果が表示されます（仮実装）。\n\n'
                      '今はデモとして、撮影した画像の上に生命線・感情線・知能線を\n'
                      'イメージしたラインを重ねています。\n\n'
                      '今後は、このラインの太さや色を「実際の診断結果」に応じて\n'
                      '変えていくこともできます。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 撮影画像の上に「手相の3本ライン」を描くペインター
/// ここでは固定位置だけど、将来パラメータで位置や太さを変える想定にもできる
class _PalmLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = Colors.yellowAccent.withOpacity(0.9);

    final lifePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final heartPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    final headPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;

    final w = size.width;
    final h = size.height;

    // 生命線（手のひらの親指側のカーブをイメージ）
    final life = Path()
      ..moveTo(w * 0.25, h * 0.20)
      ..quadraticBezierTo(w * 0.15, h * 0.40, w * 0.28, h * 0.70)
      ..quadraticBezierTo(w * 0.35, h * 0.82, w * 0.42, h * 0.90);
    canvas.drawPath(life, lifePaint);

    // 感情線（上のほうを横切るライン）
    final heart = Path()
      ..moveTo(w * 0.20, h * 0.30)
      ..quadraticBezierTo(w * 0.45, h * 0.25, w * 0.75, h * 0.28);
    canvas.drawPath(heart, heartPaint);

    // 知能線（真ん中あたりを横切るライン）
    final head = Path()
      ..moveTo(w * 0.18, h * 0.42)
      ..quadraticBezierTo(w * 0.45, h * 0.45, w * 0.78, h * 0.40);
    canvas.drawPath(head, headPaint);

    // ラベル（生命線 / 感情線 / 知能線）
    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    void drawLabel(String label, Offset pos) {
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 3, offset: Offset(1, 1)),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }

    drawLabel('生命線', Offset(w * 0.43, h * 0.78));
    drawLabel('感情線', Offset(w * 0.68, h * 0.24));
    drawLabel('知能線', Offset(w * 0.70, h * 0.37));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
