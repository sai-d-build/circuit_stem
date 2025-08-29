import 'dart:async';

/// Lightweight transaction abstraction used by the GameEngineOrchestrator.
///
/// Notifiers can register commit/rollback handlers against a transaction.
/// Handlers registered before commit will be executed when `commit()` is called.
/// If `rollback()` is called, registered rollback handlers will be executed instead.
/// This keeps the orchestrator's high-level atomicity while allowing notifiers
/// to defer state application until commit time.
class GameTransaction {
  final Map<String, dynamic> _changes = {};
  final List<FutureOr<void> Function()> _commitHandlers = [];
  final List<FutureOr<void> Function()> _rollbackHandlers = [];
  final List<void Function()> _postCommitHandlers = [];
  bool _committed = false;
  bool _rolledBack = false;

  void addChange(String key, dynamic value) {
    if (_committed || _rolledBack) {
      throw StateError('Cannot add change after transaction completed');
    }
    _changes[key] = value;
  }

  /// Register a handler that will run when commit() is called.
  /// Handlers run in registration order. They may be synchronous or return a Future.
  void onCommit(FutureOr<void> Function() handler) {
    if (_committed) {
      throw StateError('Transaction already committed');
    }
    _commitHandlers.add(handler);
  }

  /// Register a handler that will run when rollback() is called.
  void onRollback(FutureOr<void> Function() handler) {
    if (_rolledBack) {
      throw StateError('Transaction already rolled back');
    }
    _rollbackHandlers.add(handler);
  }

  /// Register a handler to be executed after successful commit.
  /// Use this for orchestrator-level updates that should happen after notifier state changes.
  void onPostCommit(void Function() handler) {
    if (_committed || _rolledBack) {
      throw StateError('Transaction already completed');
    }
    _postCommitHandlers.add(handler);
  }

  /// Commit the transaction: run all commit handlers and mark as committed.
  Future<void> commit() async {
    if (_committed) return;
    if (_rolledBack) {
      throw StateError('Transaction already rolled back');
    }
    _committed = true;
    for (final handler in _commitHandlers) {
      await handler();
    }
  }

  /// Execute all post-commit handlers. Call this after commit() succeeds.
  void executePostCommitHandlers() {
    for (final handler in _postCommitHandlers) {
      handler();
    }
  }

  /// Rollback the transaction: run all rollback handlers and clear recorded changes.
  Future<void> rollback() async {
    if (_rolledBack) return;
    if (_committed) {
      throw StateError('Transaction already committed');
    }
    _rolledBack = true;
    for (final handler in _rollbackHandlers) {
      await handler();
    }
    _changes.clear();
  }

  Map<String, dynamic> get changes => Map.unmodifiable(_changes);
  bool get isCommitted => _committed;
  bool get isRolledBack => _rolledBack;
}