import 'package:flutter/foundation.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

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
      final updatedInventory = inventory.copyWith(
        available: inventory.available - 1,
        used: inventory.used + 1,
      );
      
      final newInventoryMap = Map<String, ComponentInventory>.from(_state.inventory);
      newInventoryMap[componentType] = updatedInventory;
      
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