import '../../infrastructure/audio/audio_service.dart';

/// Thin wrapper to centralize audio logic, so core + input remain pure.
class AudioManager {
  final AudioService _audio;

  AudioManager(this._audio);

  void playSelection() => _audio.play('toggle.wav');
  void playPlacement() => _audio.play('place.wav');
  void playToggle() => _audio.play('toggle.wav');
  void playWin() => _audio.play('success.wav');
  void playLose() => _audio.play('warning.wav');
  void playSuccess() {
    _audioService.play('audio/success.wav');
  }
}
