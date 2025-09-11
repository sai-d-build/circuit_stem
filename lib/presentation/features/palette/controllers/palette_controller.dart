import 'package:flutter/foundation.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Controller for managing palette interactions
class PaletteController extends ChangeNotifier {
  PaletteState _state;
  
  PaletteController(this._state);

  PaletteState get state => _state;

  void updateState(PaletteState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void selectComponent(String? componentType) {
    _state = _state.copyWith(selectedComponentType: componentType);
    notifyListeners();
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void toggleFilter(String filter) {
    final filters = List<String>.from(_state.activeFilters);
    if (filters.contains(filter)) {
      filters.remove(filter);
    } else {
      filters.add(filter);
    }
    _state = _state.copyWith(activeFilters: filters);
    notifyListeners();
  }

  void clearFilters() {
    _state = _state.copyWith(activeFilters: []);
    notifyListeners();
  }

  bool canUseComponent(String componentType) {
    final inventory = _state.inventory[componentType];
    return inventory?.canUse ?? false;
  }

  void useComponent(String componentType) {
    final inventory = _state.inventory[componentType];
    if (inventory != null && inventory.canUse) {
      final previousAvailable = inventory.available;
      final updatedInventory = inventory.copyWith(
        available: inventory.available - 1,
        used: inventory.used + 1,
      );

      final newInventoryMap = Map<String, ComponentInventory>.from(_state.inventory);
      newInventoryMap[componentType] = updatedInventory;

      // Log inventory reduction (controlled by debugInventory flag)
      if (StructuredLogger.debugInventory) {
        StructuredLogger.components('📦 INVENTORY reduction via PaletteController', context: {
          'componentType': componentType,
          'previousAvailable': previousAvailable,
          'newAvailable': updatedInventory.available,
          'used': updatedInventory.used,
          'totalRemainingInventory': newInventoryMap.values.fold<int>(
            0, (sum, inv) => sum + inv.available),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Validate: Warn if inventory is being reduced but very few components remain
      final totalRemainingComponents = newInventoryMap.values.fold<int>(
        0, (sum, inv) => sum + (inv.available + inv.used)
      );
      final totalAvailableComponents = newInventoryMap.values.fold<int>(
        0, (sum, inv) => sum + inv.available
      );

      if (totalAvailableComponents <= 1 && StructuredLogger.debugInventory) {
        StructuredLogger.warning('⚠️ CRITICAL: Very low inventory remaining during component usage', context: {
          'componentType': componentType,
          'remainingAvailable': totalAvailableComponents,
          'totalComponentsInSystem': totalRemainingComponents,
          'severity': 'high',
          'message': 'Inventory reduction detected with very low remaining count - check if components are being populated on grid',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      _state = _state.copyWith(inventory: newInventoryMap);
      notifyListeners();
    }
  }

  void returnComponent(String componentType) {
    final inventory = _state.inventory[componentType];
    if (inventory != null && inventory.used > 0) {
      final updatedInventory = inventory.copyWith(
        available: inventory.available + 1,
        used: inventory.used - 1,
      );
      
      final newInventoryMap = Map<String, ComponentInventory>.from(_state.inventory);
      newInventoryMap[componentType] = updatedInventory;
      
      _state = _state.copyWith(inventory: newInventoryMap);
      notifyListeners();
    }
  }
}