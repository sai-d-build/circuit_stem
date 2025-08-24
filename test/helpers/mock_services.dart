// test/helpers/mock_services.dart
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:mocktail/mocktail.dart';

/// A mock AudioService that records played sounds for verification in tests.
class MockAudioService extends AudioService {
  final List<String> playedSounds = [];

  @override
  void play(String asset) {
    playedSounds.add(asset);
  }

  void clearHistory() => playedSounds.clear();
}

/// A mock AnimationScheduler for controlling animations in tests.
class MockAnimationScheduler extends Mock implements AnimationScheduler {}
