import 'package:sparkcircuit/core/commands/game_command.dart';

abstract class CommandStack {
  void push(GameCommand command);
  GameCommand? undo();
  GameCommand? redo();
  bool get canUndo;
  bool get canRedo;
  void clear();
}
