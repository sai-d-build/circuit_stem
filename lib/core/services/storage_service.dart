
import 'package:sparkcircuit/application/enhanced_game_state.dart';

abstract class StorageService {
  Future<void> saveGameState(GameState state);
  Future<GameState?> loadGameState(String levelId);
}
