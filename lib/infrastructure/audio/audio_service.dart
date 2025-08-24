import 'package:flame_audio/flame_audio.dart';

class AudioService {
  void play(String fileName) {
    FlameAudio.play(fileName);
  }
}