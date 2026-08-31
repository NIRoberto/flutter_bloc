import 'package:audioplayers/audioplayers.dart';

/// Available ambient sound presets for the focus timer.
enum AmbientSound {
  none('None'),
  rain('Rain'),
  forest('Forest'),
  whitenoise('White Noise');

  const AmbientSound(this.label);
  final String label;

  /// Asset path inside `assets/sounds/`.
  String? get assetPath => switch (this) {
        AmbientSound.none => null,
        AmbientSound.rain => 'sounds/rain.mp3',
        AmbientSound.forest => 'sounds/forest.mp3',
        AmbientSound.whitenoise => 'sounds/whitenoise.mp3',
      };
}

/// Plays a looping ambient sound via [Audioplayers].
class SoundService {
  SoundService._();
  static final SoundService _instance = SoundService._();
  static SoundService get instance => _instance;

  final _player = AudioPlayer();
  AmbientSound _current = AmbientSound.none;

  AmbientSound get current => _current;

  /// Switches the playing sound. If the same sound is requested, it is a no-op.
  Future<void> play(AmbientSound sound) async {
    if (sound == _current && _player.state == PlayerState.playing) return;
    _current = sound;
    await _player.stop();
    if (sound.assetPath != null) {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(sound.assetPath!), volume: 0.5);
    }
  }

  /// Stops playback entirely.
  Future<void> stop() async {
    await _player.stop();
    _current = AmbientSound.none;
  }

  /// Adjusts volume (0.0–1.0) while playing.
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}