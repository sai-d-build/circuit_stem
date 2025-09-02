// lib/application/audio_manager.dart
// Comprehensive audio management for SparkCircuit

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioManager {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = [];
  final int _sfxPoolSize = 5;

  double _sfxVolume = 1.0;
  double _bgmVolume = 0.5;

  AudioManager() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    for (int i = 0; i < _sfxPoolSize; i++) {
      _sfxPlayers.add(AudioPlayer());
    }
  }

  Future<void> playSfx(String assetPath) async {
    final availablePlayer = _sfxPlayers.firstWhere(
      (player) => player.state == PlayerState.stopped || player.state == PlayerState.completed,
      orElse: () => _sfxPlayers.first,
    );
    await availablePlayer.setVolume(_sfxVolume);
    await availablePlayer.play(AssetSource(assetPath));
  }

  Future<void> playBgm(String assetPath) async {
    await _bgmPlayer.setVolume(_bgmVolume);
    await _bgmPlayer.play(AssetSource(assetPath));
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    for (var player in _sfxPlayers) {
      player.setVolume(_sfxVolume);
    }
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_bgmVolume);
  }

  double get sfxVolume => _sfxVolume;
  double get bgmVolume => _bgmVolume;

  void dispose() {
    _bgmPlayer.dispose();
    for (var player in _sfxPlayers) {
      player.dispose();
    }
  }
}

final audioManagerProvider = Provider<AudioManager>((ref) {
  final manager = AudioManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});