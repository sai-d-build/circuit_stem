import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComponentSelectionNotifier extends StateNotifier<String?> {
  ComponentSelectionNotifier() : super(null);

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
    // Implementation for transaction-based selection updates
    // This will be expanded based on the specific action types
  }
}