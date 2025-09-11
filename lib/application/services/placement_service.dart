import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../core/commands/create_component_command.dart';
import '../states/game_state.dart';
import '../../core/debug/structured_logger.dart';

/// Service for centralized component placement with transaction deduplication
class PlacementService {
  final Set<String> _recentTransactions = {};
  static const Duration _transactionTimeout = Duration(seconds: 5);

  PlacementService();

  /// Place a component with transaction deduplication
  /// Returns true if placement was successful, false if duplicate or invalid
  bool placeComponentWithTransaction({
    required String transactionId,
    required ComponentType componentType,
    required int row,
    required int col,
    required GameState currentState,
  }) {
    // Check for duplicate transaction
    if (_recentTransactions.contains(transactionId)) {
      StructuredLogger.warning('Duplicate transaction - ignoring', context: {
        'service': 'PlacementService',
        'transactionId': transactionId,
      });
      return false;
    }

    // Validate placement
    if (!currentState.grid.canPlaceComponent(row, col)) {
      StructuredLogger.warning('Invalid placement position', context: {
        'service': 'PlacementService',
        'row': row,
        'col': col,
      });
      return false;
    }

    // Check if position is already occupied
    final existingComponent = currentState.grid.getComponentAt(row, col);
    if (existingComponent != null) {
      StructuredLogger.warning('Position already occupied', context: {
        'service': 'PlacementService',
        'row': row,
        'col': col,
        'existingComponent': existingComponent.id,
      });
      return false;
    }

    // Create component
    final componentId = '${componentType.toString().split('.').last}_${DateTime.now().millisecondsSinceEpoch}';
    final component = ComponentModel(
      id: componentId,
      type: componentType,
      row: row,
      col: col,
    );

    // Create and execute command
    final command = CreateComponentCommand(component);
    command.execute(currentState);

    // Record transaction to prevent duplicates
    _recentTransactions.add(transactionId);

    // Clean up old transactions after timeout
    Future.delayed(_transactionTimeout, () {
      _recentTransactions.remove(transactionId);
    });

    StructuredLogger.info('Component placed successfully', context: {
      'service': 'PlacementService',
      'componentId': componentId,
      'row': row,
      'col': col,
    });
    return true;
  }

  /// Check if a transaction ID is currently active
  bool isTransactionActive(String transactionId) {
    return _recentTransactions.contains(transactionId);
  }

  /// Get current active transaction count
  int get activeTransactionCount => _recentTransactions.length;

  /// Clear all active transactions (for testing/debugging)
  void clearTransactions() {
    _recentTransactions.clear();
  }
}

// Provider for PlacementService
final placementServiceProvider = Provider<PlacementService>((ref) {
  return PlacementService();
});