import 'package:sparkcircuit/application/states/game_state.dart';

/// An abstract class representing a command in the game.
///
/// Each command must be able to be executed and undone, operating on a
/// [GameState] and returning the new state.
abstract class GameCommand {
  /// Executes the command on the given [state].
  GameState execute(GameState state);

  /// Undoes the command on the given [state].
  GameState undo(GameState state);
}