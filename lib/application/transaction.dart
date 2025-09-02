import 'dart:ui';
import '../common/logger.dart';

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
      throw StateError('Cannot add handlers to a completed transaction');
    }
    _commitHandlers.add(handler);
  }

  /// Register a handler to be called after the transaction commits (V2 API compatibility)
  void onPostCommit(VoidCallback callback) {
    onCommit(() async => callback());
  }

  /// Register a handler to be called when the transaction rolls back
  void onRollback(VoidCallback handler) {
    if (_isCommitted || _isRolledBack) {
      throw StateError('Cannot add handlers to a completed transaction');
    }
    _rollbackHandlers.add(handler);
  }

  /// Commit the transaction, executing all commit handlers
  Future<void> commit() async {
    if (_isCommitted) {
      Logger.log('Transaction already committed');
      return;
    }
    if (_isRolledBack) {
      throw StateError('Cannot commit a rolled back transaction');
    }

    _isCommitted = true;
    Logger.log('Committing transaction with ${_commitHandlers.length} handlers');

    for (final handler in _commitHandlers) {
      try {
        await handler();
      } catch (e, stack) {
        Logger.log('Error in commit handler: $e\n$stack');
        // Continue with other handlers even if one fails
      }
    }

    _commitHandlers.clear();
    _rollbackHandlers.clear();
  }

  /// Rollback the transaction, executing all rollback handlers
  void rollback() {
    if (_isRolledBack) {
      Logger.log('Transaction already rolled back');
      return;
    }
    if (_isCommitted) {
      throw StateError('Cannot rollback a committed transaction');
    }

    _isRolledBack = true;
    Logger.log('Rolling back transaction with ${_rollbackHandlers.length} handlers');

    for (final handler in _rollbackHandlers) {
      try {
        handler();
      } catch (e, stack) {
        Logger.log('Error in rollback handler: $e\n$stack');
        // Continue with other handlers even if one fails
      }
    }

    _commitHandlers.clear();
    _rollbackHandlers.clear();
  }

  /// Check if the transaction has been committed
  bool get isCommitted => _isCommitted;

  /// Check if the transaction has been rolled back
  bool get isRolledBack => _isRolledBack;

  /// Check if the transaction is still active
  bool get isActive => !_isCommitted && !_isRolledBack;
}