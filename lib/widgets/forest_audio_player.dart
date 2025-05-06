import 'package:just_audio/just_audio.dart';

class ForestAudioPlayer {
  static final ForestAudioPlayer _instance = ForestAudioPlayer._internal();
  factory ForestAudioPlayer() => _instance;

  late final AudioPlayer _player;
  bool _isInitialized = false;

  ForestAudioPlayer._internal() {
    _player = AudioPlayer();
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _player.setAsset('assets/sounds/forest_sound.wav');
      _player.setLoopMode(LoopMode.one);
      _player.play();
      _isInitialized = true;
    }
  }

  void mute() {
    _player.setVolume(0.0);
  }

  void unmute() {
    _player.setVolume(1.0);
  }

  Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}
