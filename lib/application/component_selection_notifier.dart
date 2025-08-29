import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComponentSelectionNotifier extends StateNotifier<String?> {
  ComponentSelectionNotifier() : super(null);

  // Public snapshot getter for safe read access
  String? get current => state;

  // Public setter for controlled writes
  void setState(String? newState) => state = newState;

  // Select a component
  void selectComponent(String componentId) {
    state = componentId;
  }

  // Clear selection
  void clearSelection() {
    state = null;
  }

  // Check if a component is selected
  bool isSelected(String componentId) {
    return state == componentId;
  }

  // Method to execute actions in transaction
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Store current state for rollback
    final previousState = state;
    
    // Register rollback handler
    transaction.onRollback(() {
      state = previousState;
    });
    
    // Register commit handler - execute selection updates
    transaction.onCommit(() async {
      // Handle selection-related actions
      if (action.toString().contains('SelectPalette') || action.toString().contains('Select')) {
        // TODO: Extract componentId from action and select it
        // For now this is a placeholder until we have proper action types
      } else if (action.toString().contains('ClearSelection')) {
        clearSelection();
      }
    });
  }
}