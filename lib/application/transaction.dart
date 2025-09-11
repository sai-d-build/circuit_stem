import 'dart:ui';
import '../core/debug/structured_logger.dart';

/// Represents a transaction that can be committed or rolled back
/// Used by NotifierIntegratedUseCase for atomic operations
class GameTransaction {
  final List<Function()> _commitHandlers = [];
  final List<Function()> _rollbackHandlers = [];
  bool _isCommitted = false;
  bool _isRolledBack = false;

  /// Register a handler to be called when the transaction commits
  void onCommit(Future<void> Function() handler) {
    if (_isCommitted || _isRolledBack) {
      StructuredLogger.error('💥 Transaction: Cannot add commit handler to completed transaction', context: {
        'isCommitted': _isCommitted,
        'isRolledBack': _isRolledBack,
        'timestamp': DateTime.now().toIso8601String(),
      });
      throw StateError('Cannot add handlers to a completed transaction');
    }
    _commitHandlers.add(handler);
    StructuredLogger.debug('🔧 Transaction: Added commit handler', context: {
      'handlerCount': _commitHandlers.length,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Register a handler to be called after the transaction commits (V2 API compatibility)
  void onPostCommit(VoidCallback callback) {
    onCommit(() async => callback());
  }

  /// Register a handler to be called when the transaction rolls back
  void onRollback(VoidCallback handler) {
    if (_isCommitted || _isRolledBack) {
      StructuredLogger.error('💥 Transaction: Cannot add rollback handler to completed transaction', context: {
        'isCommitted': _isCommitted,
        'isRolledBack': _isRolledBack,
        'timestamp': DateTime.now().toIso8601String(),
      });
      throw StateError('Cannot add handlers to a completed transaction');
    }
    _rollbackHandlers.add(handler);
    StructuredLogger.debug('🔧 Transaction: Added rollback handler', context: {
      'handlerCount': _rollbackHandlers.length,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Commit the transaction, executing all commit handlers
  Future<void> commit() async {
    if (_isCommitted) {
      StructuredLogger.info('🔄 Transaction: Already committed', context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }
    if (_isRolledBack) {
      StructuredLogger.error('💥 Transaction: Cannot commit rolled back transaction', context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
      throw StateError('Cannot commit a rolled back transaction');
    }

    _isCommitted = true;
    StructuredLogger.info('✅ Transaction: Starting commit execution', context: {
      'handlerCount': _commitHandlers.length,
      'rollbackHandlersCount': _rollbackHandlers.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    var successCount = 0;
    for (var i = 0; i < _commitHandlers.length; i++) {
      final handlerStart = DateTime.now();
      try {
        await _commitHandlers[i]();
        final handlerDuration = DateTime.now().difference(handlerStart);
        successCount++;
        StructuredLogger.debug('✅ Transaction: Commit handler ${i+1}/${_commitHandlers.length} completed', context: {
          'handlerIndex': i,
          'executionTimeMs': handlerDuration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e, stack) {
        final handlerDuration = DateTime.now().difference(handlerStart);
        StructuredLogger.error('💥 Transaction: Commit handler ${i+1} failed', context: {
          'handlerIndex': i,
          'error': e.toString(),
          'executionTimeMs': handlerDuration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
          'stackTrace': stack.toString(),
        });
        // Continue with other handlers even if one fails
      }
    }

    _commitHandlers.clear();
    _rollbackHandlers.clear();

    StructuredLogger.info('🎯 Transaction: Commit completed', context: {
      'totalHandlers': _commitHandlers.length + successCount,
      'successfulHandlers': successCount,
      'failedHandlers': (_commitHandlers.length + successCount) - successCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Rollback the transaction, executing all rollback handlers
  void rollback() {
    if (_isRolledBack) {
      StructuredLogger.info('🔄 Transaction: Already rolled back', context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }
    if (_isCommitted) {
      StructuredLogger.error('💥 Transaction: Cannot rollback committed transaction', context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
      throw StateError('Cannot rollback a committed transaction');
    }

    _isRolledBack = true;
    StructuredLogger.info('↩️ Transaction: Starting rollback execution', context: {
      'rollbackHandlerCount': _rollbackHandlers.length,
      'commitHandlersCount': _commitHandlers.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    var successCount = 0;
    for (var i = 0; i < _rollbackHandlers.length; i++) {
      final handlerStart = DateTime.now();
      try {
        _rollbackHandlers[i]();
        final handlerDuration = DateTime.now().difference(handlerStart);
        successCount++;
        StructuredLogger.debug('✅ Transaction: Rollback handler ${i+1}/${_rollbackHandlers.length} completed', context: {
          'handlerIndex': i,
          'executionTimeMs': handlerDuration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e, stack) {
        final handlerDuration = DateTime.now().difference(handlerStart);
        StructuredLogger.error('💥 Transaction: Rollback handler ${i+1} failed', context: {
          'handlerIndex': i,
          'error': e.toString(),
          'executionTimeMs': handlerDuration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
          'stackTrace': stack.toString(),
        });
        // Continue with other handlers even if one fails
      }
    }

    _commitHandlers.clear();
    _rollbackHandlers.clear();

    StructuredLogger.info('🎯 Transaction: Rollback completed', context: {
      'totalHandlers': _rollbackHandlers.length + successCount,
      'successfulHandlers': successCount,
      'failedHandlers': (_rollbackHandlers.length + successCount) - successCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Check if the transaction has been committed
  bool get isCommitted => _isCommitted;

  /// Check if the transaction has been rolled back
  bool get isRolledBack => _isRolledBack;

  /// Check if the transaction is still active
  bool get isActive => !_isCommitted && !_isRolledBack;
}