import 'package:circuit_stem/infrastructure/audio/audio_service.dart';

class MockAudioService implements AudioService {
  @override
  void play(String fileName) {
    // Do nothing in tests
  }
}
