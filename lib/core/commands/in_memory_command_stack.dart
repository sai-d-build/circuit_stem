
import 'package:sparkcircuit/core/commands/command_stack.dart';
import 'package:sparkcircuit/core/commands/game_command.dart';

class InMemoryCommandStack implements CommandStack {
  final List<GameCommand> _history = [];
  int _currentIndex = -1;

  @override
  void push(GameCommand command) {
    // Remove any commands after the current index (redo history)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    _history.add(command);
    _currentIndex = _history.length - 1;
  }

  @override
  GameCommand? undo() {
    if (canUndo) {
      final command = _history[_currentIndex];
      _currentIndex--;
      return command;
    }
    return null;
  }

  @override
  GameCommand? redo() {
    if (canRedo) {
      _currentIndex++;
      final command = _history[_currentIndex];
      return command;
    }
    return null;
  }

  @override
  bool get canUndo => _currentIndex >= 0;

  @override
  bool get canRedo => _currentIndex < _history.length - 1;

  @override
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}
