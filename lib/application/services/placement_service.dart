import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../core/commands/command_stack.dart';
import '../../core/commands/create_component_command.dart';
import '../enhanced_game_state.dart';
import '../use_cases/providers.dart' as use_case_providers;

/// Service for centralized component placement with transaction deduplication
class PlacementService {
  final CommandStack _commandStack;
  final Set<String> _recentTransactions = {};
  static const Duration _transactionTimeout = Duration(seconds: 5);

  PlacementService(this._commandStack);

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
      print('⚠️ PlacementService: Duplicate transaction $transactionId - ignoring');
      return false;
    }

    // Validate placement
    if (!currentState.grid.canPlaceComponent(row, col)) {
      print('❌ PlacementService: Invalid placement position ($row, $col)');
      return false;
    }

    // Check if position is already occupied
    final existingComponent = currentState.grid.getComponentAt(row, col);
    if (existingComponent != null) {
      print('❌ PlacementService: Position ($row, $col) already occupied');
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
    final newState = command.execute(currentState);

    // Record transaction to prevent duplicates
    _recentTransactions.add(transactionId);

    // Clean up old transactions after timeout
    Future.delayed(_transactionTimeout, () {
      _recentTransactions.remove(transactionId);
    });

    print('✅ PlacementService: Component placed successfully - $componentId at ($row, $col)');
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
  final commandStack = ref.watch(use_case_providers.commandStackProvider);
  return PlacementService(commandStack);
});