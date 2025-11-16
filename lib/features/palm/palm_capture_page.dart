import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'palm_result_page.dart';

class PalmCapturePage extends StatefulWidget {
  const PalmCapturePage({super.key});

  @override
  State<PalmCapturePage> createState() => _PalmCapturePageState();
}

class _PalmCapturePageState extends State<PalmCapturePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _captured;
  bool _isTaking = false;

  Future<void> _takePhoto() async {
    if (_isTaking) return;
    setState(() => _isTaking = true);

    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.camera,
        // preferredCameraDevice: CameraDevice.rear, // 必要なら戻してOK
        imageQuality: 90,
      );

      if (!mounted) return;

      setState(() {
        _captured = xfile;
      });
    } finally {
      if (mounted) {
        setState(() => _isTaking = false);
      }
    }
  }

  void _goToResult() {
    final file = _captured;
    if (file == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PalmResultPage(imageFile: File(file.path)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('手相占い（撮影）')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ───── プレビュー & ガイドエリア
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: _captured == null
                      ? _PalmGuideOverlay() // ← 撮影前ガイド
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_captured!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 撮影ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTaking ? null : _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_isTaking ? '撮影中…' : '手のひらを撮影する'),
                ),
              ),
              const SizedBox(height: 8),

              // 占いボタン（画像があるときだけ有効）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _captured == null ? null : _goToResult,
                  child: const Text('この画像で占う（仮）'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 撮影前の「手の枠ガイド」
/// ※ 実際のカメラ上ではなく、「こう撮ってね」のイメージとして表示
class _PalmGuideOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.4);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: CustomPaint(painter: _PalmFramePainter()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '「手のひら全体」がこの枠に収まるイメージで\n'
            '明るい場所で撮影してください。\n\n'
            '※ 実際のカメラではこの枠は表示されません。',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 手の輪郭っぽい枠（本当に精密な手ではなく、イメージ用のラフな形）
class _PalmFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = Colors.brown.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fingerPaint = Paint()
      ..color = Colors.brown.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final w = size.width;
    final h = size.height;

    // 手のひらの外枠（ラフな楕円＋四角の中間っぽい形）
    final path = Path()
      ..moveTo(w * 0.3, h * 0.85)
      ..lineTo(w * 0.25, h * 0.6)
      ..quadraticBezierTo(w * 0.20, h * 0.45, w * 0.30, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 0.25, w * 0.50, h * 0.25)
      ..quadraticBezierTo(w * 0.65, h * 0.25, w * 0.70, h * 0.35)
      ..quadraticBezierTo(w * 0.80, h * 0.45, w * 0.75, h * 0.6)
      ..lineTo(w * 0.70, h * 0.85)
      ..quadraticBezierTo(w * 0.50, h * 0.92, w * 0.30, h * 0.85);

    canvas.drawPath(path, framePaint);

    // 指っぽい短いラインを上部にちょっと描く（雰囲気）
    for (var i = 0; i < 4; i++) {
      final x = w * (0.32 + 0.12 * i);
      canvas.drawLine(Offset(x, h * 0.27), Offset(x, h * 0.16), fingerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
