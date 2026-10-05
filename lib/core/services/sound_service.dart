import 'package:audioplayers/audioplayers.dart';

/// ENOUGH — quiet, opt-in audio cues.
class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;

  /// Initialize the audio player
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await _player.setVolume(0.5); // Baseline internal volume
      await _player.setReleaseMode(ReleaseMode.stop);
      _initialized = true;
    } catch (e) {
      // Silent fail
    }
  }

  /// Play the closure chime - soft, final
  static Future<void> playClosureChime() async {
    if (!_initialized) await init();

    try {
      final source = AssetSource('audio/closure_chime.mp3');
      await _player.stop();
      await _player.play(source, volume: 0.12); // Subtle ritual volume
    } catch (e) {
      // Silent fail
    }
  }

  /// Plays only after the user chooses to release the glass.
  static Future<void> playGlassRelease() async {
    if (!_initialized) await init();

    try {
      await _player.stop();
      await _player.play(
        AssetSource('audio/Small glass shatter impact.mp3'),
        volume: 0.22,
      );
    } catch (e) {
      // The visual release still completes if audio is unavailable.
    }
  }

  /// Dispose the player
  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      // Silent fail
    }
  }
}
