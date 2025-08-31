
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/core/commands/game_command.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';

// Mock GameCommand for testing purposes
class MockGameCommand extends Mock implements GameCommand {}

void main() {
  group('InMemoryCommandStack', () {
    late InMemoryCommandStack commandStack;
    late MockGameCommand command1;
    late MockGameCommand command2;

    setUp(() {
      commandStack = InMemoryCommandStack();
      command1 = MockGameCommand();
      command2 = MockGameCommand();
    });

    test('initial state is correct', () {
      expect(commandStack.canUndo, isFalse);
      expect(commandStack.canRedo, isFalse);
    });

    test('push adds a command and updates canUndo', () {
      commandStack.push(command1);
      expect(commandStack.canUndo, isTrue);
      expect(commandStack.canRedo, isFalse);
    });

    test('pushing a command clears the redo history', () {
      commandStack.push(command1);
      commandStack.undo();
      expect(commandStack.canRedo, isTrue);

      commandStack.push(command2);
      expect(commandStack.canRedo, isFalse);
    });

    test('undo returns the last command and updates canUndo/canRedo', () {
      commandStack.push(command1);
      commandStack.push(command2);

      final undoneCommand = commandStack.undo();

      expect(undoneCommand, same(command2));
      expect(commandStack.canUndo, isTrue);
      expect(commandStack.canRedo, isTrue);
    });

    test('redo returns the undone command and updates canUndo/canRedo', () {
      commandStack.push(command1);
      commandStack.undo();

      final redoneCommand = commandStack.redo();

      expect(redoneCommand, same(command1));
      expect(commandStack.canUndo, isTrue);
      expect(commandStack.canRedo, isFalse);
    });

    test('undo returns null when history is empty', () {
      final undoneCommand = commandStack.undo();
      expect(undoneCommand, isNull);
    });

    test('redo returns null when no commands have been undone', () {
      commandStack.push(command1);
      final redoneCommand = commandStack.redo();
      expect(redoneCommand, isNull);
    });

    test('clear resets the command stack', () {
      commandStack.push(command1);
      commandStack.push(command2);
      commandStack.undo();

      commandStack.clear();

      expect(commandStack.canUndo, isFalse);
      expect(commandStack.canRedo, isFalse);
    });
  });
}
