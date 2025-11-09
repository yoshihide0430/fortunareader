import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class BgmService {
  static final BgmService _instance = BgmService._internal();
  factory BgmService() => _instance;
  BgmService._internal();

  final _player = AudioPlayer();
  bool _isMuted = false;
  bool _isReady = false;
  double _baseVolume = 0.2;

  Future<void> init({
    required String assetPath,
    double initialVolume = 0.2,
    bool loop = true,
  }) async {
    _baseVolume = initialVolume;

    // iOSのサイレントスイッチ越え＆安定化
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    await _player.setAsset(assetPath);
    if (loop) await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(_isMuted ? 0.0 : _baseVolume);
    _isReady = true;

    // デバッグ: 状態変化をログ（必要なければ削除）
    _player.playerStateStream.listen((s) {
      // print('player: ${s.processingState} playing=${s.playing}');
    });
  }

  Future<void> play() async {
    if (!_isReady) return;
    if (_isMuted) return;
    if (!_player.playing) {
      await _player.play();
    }
  }

  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _player.setVolume(_isMuted ? 0.0 : _baseVolume);
    // ミュート解除時に音が出ない場合は再生を明示
    if (!_isMuted) await play();
  }

  Future<void> setVolume(double v) async {
    _baseVolume = v.clamp(0.0, 1.0);
    if (!_isMuted) await _player.setVolume(_baseVolume);
  }

  bool get isMuted => _isMuted;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
