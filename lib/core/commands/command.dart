import '../../../core/debug/structured_logger.dart';

/// Base command interface for undo/redo functionality
abstract class Command {
  /// Unique identifier for the command
  String get id =>
      '${runtimeType.toString()}_${DateTime.now().millisecondsSinceEpoch}';

  /// Human-readable description of the command
  String get description;

  /// Timestamp when command was created
  DateTime get timestamp => DateTime.now();

  /// Whether this command can be undone
  bool get canUndo => true;

  /// Whether this command can be redone
  bool get canRedo => true;

  /// Execute the command
  Future<CommandResult> execute();

  /// Undo the command
  Future<CommandResult> undo();

  /// Get command metadata for serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': runtimeType.toString(),
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'canUndo': canUndo,
        'canRedo': canRedo,
      };

  /// Create command from JSON (for persistence)
  static Command? fromJson(Map<String, dynamic> json) {
    // This would be implemented by subclasses
    return null;
  }
}

/// Result of command execution
class CommandResult {
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? data;
  final CommandResultType type;

  const CommandResult._({
    required this.success,
    this.errorMessage,
    this.data,
    required this.type,
  });

  factory CommandResult.success({
    Map<String, dynamic>? data,
    CommandResultType type = CommandResultType.success,
  }) =>
      CommandResult._(
        success: true,
        data: data,
        type: type,
      );

  factory CommandResult.failure({
    required String errorMessage,
    Map<String, dynamic>? data,
    CommandResultType type = CommandResultType.error,
  }) =>
      CommandResult._(
        success: false,
        errorMessage: errorMessage,
        data: data,
        type: type,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'errorMessage': errorMessage,
        'data': data,
        'type': type.toString(),
      };
}

/// Types of command results
enum CommandResultType {
  success,
  error,
  warning,
  info,
}

/// Command manager for handling undo/redo operations
class CommandManager {
  static const int _maxHistorySize = 100;
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  /// Execute a command and add it to the undo stack
  Future<CommandResult> executeCommand(Command command) async {
    try {
      StructuredLogger.info('Executing command', context: {
        'commandId': command.id,
        'commandType': command.runtimeType.toString(),
        'description': command.description,
        'timestamp': command.timestamp.toIso8601String(),
      });

      final result = await command.execute();

      if (result.success && command.canUndo) {
        _undoStack.add(command);
        _redoStack.clear(); // Clear redo stack when new command is executed

        // Maintain history size limit
        if (_undoStack.length > _maxHistorySize) {
          _undoStack.removeAt(0);
        }

        StructuredLogger.info('Command executed successfully', context: {
          'commandId': command.id,
          'undoStackSize': _undoStack.length,
          'redoStackSize': _redoStack.length,
        });
      } else if (!result.success) {
        StructuredLogger.error('Command execution failed', context: {
          'commandId': command.id,
          'error': result.errorMessage,
        });
      }

      return result;
    } catch (e) {
      StructuredLogger.error('Command execution threw exception', context: {
        'commandId': command.id,
        'error': e.toString(),
      });

      return CommandResult.failure(
        errorMessage: 'Command execution failed: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  /// Undo the last command
  Future<CommandResult> undo() async {
    if (!canUndo) {
      return CommandResult.failure(errorMessage: 'Nothing to undo');
    }

    final command = _undoStack.removeLast();

    try {
      StructuredLogger.info('Undoing command', context: {
        'commandId': command.id,
        'commandType': command.runtimeType.toString(),
        'description': command.description,
      });

      final result = await command.undo();

      if (result.success) {
        _redoStack.add(command);

        StructuredLogger.info('Command undone successfully', context: {
          'commandId': command.id,
          'undoStackSize': _undoStack.length,
          'redoStackSize': _redoStack.length,
        });
      }

      return result;
    } catch (e) {
      // Put the command back on the undo stack if undo failed
      _undoStack.add(command);

      StructuredLogger.error('Command undo failed', context: {
        'commandId': command.id,
        'error': e.toString(),
      });

      return CommandResult.failure(
        errorMessage: 'Undo failed: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  /// Redo the last undone command
  Future<CommandResult> redo() async {
    if (!canRedo) {
      return CommandResult.failure(errorMessage: 'Nothing to redo');
    }

    final command = _redoStack.removeLast();

    try {
      StructuredLogger.info('Redoing command', context: {
        'commandId': command.id,
        'commandType': command.runtimeType.toString(),
        'description': command.description,
      });

      final result = await command.execute();

      if (result.success) {
        _undoStack.add(command);

        StructuredLogger.info('Command redone successfully', context: {
          'commandId': command.id,
          'undoStackSize': _undoStack.length,
          'redoStackSize': _redoStack.length,
        });
      }

      return result;
    } catch (e) {
      // Put the command back on the redo stack if redo failed
      _redoStack.add(command);

      StructuredLogger.error('Command redo failed', context: {
        'commandId': command.id,
        'error': e.toString(),
      });

      return CommandResult.failure(
        errorMessage: 'Redo failed: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  /// Check if undo is available
  bool get canUndo => _undoStack.isNotEmpty;

  /// Check if redo is available
  bool get canRedo => _redoStack.isNotEmpty;

  /// Clear command history
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();

    StructuredLogger.info('Command history cleared', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get command history for debugging
  List<Map<String, dynamic>> getHistory() {
    final history = <Map<String, dynamic>>[];

    for (final command in _undoStack) {
      history.add({
        'id': command.id,
        'type': command.runtimeType.toString(),
        'description': command.description,
        'timestamp': command.timestamp.toIso8601String(),
        'stack': 'undo',
      });
    }

    for (final command in _redoStack.reversed) {
      history.add({
        'id': command.id,
        'type': command.runtimeType.toString(),
        'description': command.description,
        'timestamp': command.timestamp.toIso8601String(),
        'stack': 'redo',
      });
    }

    return history;
  }

  /// Get statistics about command usage
  Map<String, dynamic> getStatistics() {
    final commandTypes = <String, int>{};

    for (final command in _undoStack) {
      final type = command.runtimeType.toString();
      commandTypes[type] = (commandTypes[type] ?? 0) + 1;
    }

    return {
      'undoStackSize': _undoStack.length,
      'redoStackSize': _redoStack.length,
      'maxHistorySize': _maxHistorySize,
      'commandTypes': commandTypes,
      'oldestCommand': _undoStack.isNotEmpty
          ? _undoStack.first.timestamp.toIso8601String()
          : null,
      'newestCommand': _undoStack.isNotEmpty
          ? _undoStack.last.timestamp.toIso8601String()
          : null,
    };
  }
}

/// Singleton instance of command manager
final commandManager = CommandManager();
