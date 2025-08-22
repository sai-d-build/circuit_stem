import '../services/audio_service.dart';

/// Thin wrapper to centralize audio logic, so core + input remain pure.
class AudioManager {
  final AudioService _audio;

  AudioManager(this._audio);

  void playSelection() => _audio.playSelection();

  void playPlacement() => _audio.playPlacement();

  void playWin() => _audio.playWin();

  void playLose() => _audio.playLose();

  void stopAll() => _audio.stopAll();
}
