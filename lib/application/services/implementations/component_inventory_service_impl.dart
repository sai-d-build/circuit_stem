// lib/application/services/implementations/component_inventory_service_impl.dart
// Implementation of ComponentInventoryService extracted from PaletteState

import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

import '../interfaces/component_inventory_service.dart';

/// Default implementation of ComponentInventoryService
class DefaultComponentInventoryService implements ComponentInventoryService {
  final PaletteStateNotifier _paletteStateNotifier;

  DefaultComponentInventoryService({
    required PaletteStateNotifier paletteStateNotifier,
    required String levelId,
  }) : _paletteStateNotifier = paletteStateNotifier;

  @override
  InventoryCheckResult checkAvailability(ComponentType type) {
    final componentTypeString = _componentTypeToString(type);
    final canUse = _paletteStateNotifier.canUseComponent(componentTypeString);

    if (!canUse) {
      // Get inventory through public methods instead of accessing state directly
      final inventory = _getInventoryForType(componentTypeString);
      return InventoryCheckResult.unavailable(inventory?.available ?? 0,
          inventory?.total ?? 0, 'Component not available in inventory');
    }

    final inventory = _getInventoryForType(componentTypeString);
    return InventoryCheckResult.available(
      inventory?.available ?? 0,
      inventory?.total ?? 0,
    );
  }

  // ✅ FIXED: Method to get actual inventory from PaletteStateNotifier
  ComponentInventory? _getInventoryForType(String componentTypeString) {
    try {
      // Get the actual inventory state from PaletteStateNotifier
      final inventoryState = _paletteStateNotifier.getInventoryState();

      // Look up the component in the actual inventory
      final inventoryItem = inventoryState[componentTypeString];

      if (inventoryItem != null) {
        StructuredLogger.debug('🎯 ACTUAL INVENTORY FOUND', context: {
          'componentType': componentTypeString,
          'available': inventoryItem.available,
          'total': inventoryItem.total,
          'used': inventoryItem.used,
          'canUse': inventoryItem.canUse,
        });
      } else {
        StructuredLogger.warning('🎯 INVENTORY NOT FOUND', context: {
          'componentType': componentTypeString,
          'availableInventoryKeys': inventoryState.keys.toList(),
        });
      }

      return inventoryItem;
    } catch (e) {
      StructuredLogger.error('❌ FAILED TO GET INVENTORY', context: {
        'componentType': componentTypeString,
        'error': e.toString(),
      });
      return null;
    }
  }

  @override
  Future<InventoryConsumptionResult> consumeComponent(
      ComponentType type) async {
    final componentTypeString = _componentTypeToString(type);

    try {
      final canUse = _paletteStateNotifier.canUseComponent(componentTypeString);
      if (!canUse) {
        return InventoryConsumptionResult.failed(
            'Component not available in inventory');
      }

      _paletteStateNotifier.useComponent(componentTypeString);

      // Get remaining count through public interface
      final remainingCount = _getRemainingCount(componentTypeString);
      return InventoryConsumptionResult.success(remainingCount);
    } catch (e) {
      return InventoryConsumptionResult.failed(
          'Failed to consume component: $e');
    }
  }

  // Helper method to get remaining count without accessing state
  int _getRemainingCount(String componentTypeString) {
    // This is a workaround - ideally PaletteStateNotifier should expose this
    try {
      final canUseAfterConsumption =
          _paletteStateNotifier.canUseComponent(componentTypeString);
      return canUseAfterConsumption ? 1 : 0; // Simplified assumption
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<InventoryConsumptionResult> returnComponent(ComponentType type) async {
    final componentTypeString = _componentTypeToString(type);

    try {
      _paletteStateNotifier.returnComponent(componentTypeString);

      final updatedCount = _getRemainingCount(componentTypeString);
      return InventoryConsumptionResult.success(updatedCount);
    } catch (e) {
      return InventoryConsumptionResult.failed(
          'Failed to return component: $e');
    }
  }

  @override
  Map<ComponentType, InventoryCheckResult> getAllInventoryLevels() {
    // This is a simplified implementation
    // In a real scenario, we'd need PaletteStateNotifier to expose this information
    final result = <ComponentType, InventoryCheckResult>{};

    // For now, return empty map - this needs to be properly implemented
    // when PaletteStateNotifier exposes inventory information through public methods
    return result;
  }

  @override
  Future<void> resetInventoryForLevel(String levelId) async {
    // Reset the palette state for the level - now async due to inventory clearing
    await _paletteStateNotifier.reset();
  }

  /// Converts ComponentType enum to inventory key representation
  /// FIXED: Switch enum name `switch_` to inventory key `switch`
  String _componentTypeToString(ComponentType type) {
    final enumName = type.toString().split('.').last;

    // Handle component type mapping inconsistencies
    switch (enumName) {
      case 'switch_':
        return 'switch'; // Remove underscore for inventory key
      // Add other special cases here if needed
      default:
        return enumName;
    }
  }
}
