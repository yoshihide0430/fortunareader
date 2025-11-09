import 'package:flutter/material.dart';
import 'omikuji_models.dart';

class OmikujiTicketPage extends StatelessWidget {
  const OmikujiTicketPage({
    super.key,
    required this.result,
    required this.stickNumber,
  });

  final OmikujiFortune result;
  final int stickNumber;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('おみくじ')),
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;

          // 余白ルール：上20%、左右15%
          final leftPad = w * 0.15;
          final rightPad = w * 0.15;
          final topPad = h * 0.20;

          return Stack(
            children: [
              // ★ 背景を画面いっぱいに
              Positioned.fill(
                child: Image.asset(
                  'assets/images/omikuji_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              // ★ コンテンツ：上20%開始、左右15%余白、下は大きめ余白で最後まで見える
              Positioned(
                left: leftPad,
                right: rightPad,
                top: topPad,
                bottom: 0,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: safeBottom + 120, // ← 一番下が隠れないように余裕を確保
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Color(0xFF3A2A15),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '第${stickNumber.toString().padLeft(3, '0')}番',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A2A10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.fortune,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '「${result.kotoba}」',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),

                        // 各項目（枠内で折り返し）
                        ...result.items.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2A10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF4A2A10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '守り：${result.mamori}',
                            style: const TextStyle(
                              color: Color(0xFF4A2A10),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${result.kichiType.isNotEmpty ? result.kichiType : '吉方'}：${result.kichiValue}',
                            style: const TextStyle(
                              color: Color(0xFF4A2A10),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // ★ 下端ゆとり（さらに確実に）
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
