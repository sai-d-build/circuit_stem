import 'package:sparkcircuit/application/services/interfaces/component_inventory_service.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Default implementation of ComponentInventoryService
class DefaultComponentInventoryService implements ComponentInventoryService {
  final Map<ComponentType, int> _inventory = {};
  final Map<ComponentType, int> _used = {};

  @override
  InventoryCheckResult checkAvailability(ComponentType type) {
    final available = _inventory[type] ?? 0;
    final used = _used[type] ?? 0;
    final total = available + used;

    final isAvailable = available > 0;

    StructuredLogger.debug('Inventory availability check', context: {
      'componentType': type.toString(),
      'available': available,
      'used': used,
      'total': total,
      'isAvailable': isAvailable,
    });

    if (isAvailable) {
      return InventoryCheckResult.available(available, total);
    } else {
      return InventoryCheckResult.unavailable(
          available, total, 'No components available in inventory');
    }
  }

  @override
  Future<InventoryConsumptionResult> consumeComponent(
      ComponentType type) async {
    final currentAvailable = _inventory[type] ?? 0;
    final currentUsed = _used[type] ?? 0;

    StructuredLogger.info('Consuming component from inventory', context: {
      'componentType': type.toString(),
      'availableBefore': currentAvailable,
      'usedBefore': currentUsed,
    });

    if (currentAvailable <= 0) {
      StructuredLogger.warning('Cannot consume component - none available',
          context: {
            'componentType': type.toString(),
            'available': currentAvailable,
          });

      return InventoryConsumptionResult.failed(
          'No components available to consume');
    }

    // Update inventory
    _inventory[type] = currentAvailable - 1;
    _used[type] = currentUsed + 1;

    final remaining = _inventory[type]!;

    StructuredLogger.debug('Component consumed successfully', context: {
      'componentType': type.toString(),
      'availableAfter': _inventory[type],
      'usedAfter': _used[type],
      'remaining': remaining,
    });

    return InventoryConsumptionResult.success(remaining);
  }

  @override
  Future<InventoryConsumptionResult> returnComponent(ComponentType type) async {
    final currentAvailable = _inventory[type] ?? 0;
    final currentUsed = _used[type] ?? 0;

    StructuredLogger.info('Returning component to inventory', context: {
      'componentType': type.toString(),
      'availableBefore': currentAvailable,
      'usedBefore': currentUsed,
    });

    if (currentUsed <= 0) {
      StructuredLogger.warning('Cannot return component - none used', context: {
        'componentType': type.toString(),
        'used': currentUsed,
      });

      return InventoryConsumptionResult.failed('No components to return');
    }

    // Update inventory
    _inventory[type] = currentAvailable + 1;
    _used[type] = currentUsed - 1;

    final newAvailable = _inventory[type]!;

    StructuredLogger.debug('Component returned successfully', context: {
      'componentType': type.toString(),
      'availableAfter': _inventory[type],
      'usedAfter': _used[type],
      'newAvailable': newAvailable,
    });

    return InventoryConsumptionResult.success(newAvailable);
  }

  @override
  Map<ComponentType, InventoryCheckResult> getAllInventoryLevels() {
    final result = <ComponentType, InventoryCheckResult>{};

    // Get all component types that have inventory
    final allTypes = {..._inventory.keys, ..._used.keys};

    for (final type in allTypes) {
      result[type] = checkAvailability(type);
    }

    StructuredLogger.debug('Retrieved all inventory levels', context: {
      'totalTypes': result.length,
      'inventory': result.map((key, value) => MapEntry(key.toString(),
          {'available': value.availableCount, 'total': value.totalCount})),
    });

    return result;
  }

  @override
  Future<void> resetInventoryForLevel(String levelId) async {
    StructuredLogger.info('Resetting inventory for level', context: {
      'levelId': levelId,
      'inventoryBeforeReset':
          _inventory.map((key, value) => MapEntry(key.toString(), value)),
      'usedBeforeReset':
          _used.map((key, value) => MapEntry(key.toString(), value)),
    });

    // Reset used counts to 0, keep available counts
    _used.clear();

    StructuredLogger.debug('Inventory reset complete', context: {
      'levelId': levelId,
      'inventoryAfterReset':
          _inventory.map((key, value) => MapEntry(key.toString(), value)),
      'usedAfterReset': _used.length, // Should be 0
    });
  }

  /// Initialize inventory for a level with specific component quantities
  void initializeInventoryForLevel(
      String levelId, Map<ComponentType, int> initialInventory) {
    StructuredLogger.info('Initializing inventory for level', context: {
      'levelId': levelId,
      'initialInventory':
          initialInventory.map((key, value) => MapEntry(key.toString(), value)),
    });

    _inventory.clear();
    _used.clear();

    initialInventory.forEach((type, quantity) {
      _inventory[type] = quantity;
      _used[type] = 0;
    });

    StructuredLogger.debug('Inventory initialization complete', context: {
      'levelId': levelId,
      'totalComponents': _inventory.values.fold(0, (sum, count) => sum + count),
    });
  }

  /// Get current available count for a component type
  int getAvailableCount(ComponentType type) {
    return _inventory[type] ?? 0;
  }

  /// Get current used count for a component type
  int getUsedCount(ComponentType type) {
    return _used[type] ?? 0;
  }

  /// Get total count (available + used) for a component type
  int getTotalCount(ComponentType type) {
    return getAvailableCount(type) + getUsedCount(type);
  }
}
