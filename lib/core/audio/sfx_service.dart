import 'package:just_audio/just_audio.dart';

class SfxService {
  static final SfxService _i = SfxService._internal();
  factory SfxService() => _i;
  SfxService._internal();

  final _shake = AudioPlayer();
  final _stick = AudioPlayer();
  final _paper = AudioPlayer();

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    await _shake.setAsset('assets/audio/shake.mp3');
    await _stick.setAsset('assets/audio/stick.mp3');
    await _paper.setAsset('assets/audio/paper.mp3');
    _inited = true;
  }

  Future<void> playShake() async {
    await init();
    await _shake.seek(Duration.zero);
    await _shake.play();
  }

  Future<void> playStick() async {
    await init();
    await _stick.seek(Duration.zero);
    await _stick.play();
  }

  Future<void> playPaper() async {
    await init();
    await _paper.seek(Duration.zero);
    await _paper.play();
  }

  Future<void> dispose() async {
    await _shake.dispose();
    await _stick.dispose();
    await _paper.dispose();
  }
}
