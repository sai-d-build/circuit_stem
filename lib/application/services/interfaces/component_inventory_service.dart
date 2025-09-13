// lib/application/services/interfaces/component_inventory_service.dart
// Interface for component inventory management

import 'package:sparkcircuit/domain/entities/entities.dart';

/// Result of inventory availability check
class InventoryCheckResult {
  final bool isAvailable;
  final int availableCount;
  final int totalCount;
  final String? reason;

  const InventoryCheckResult._(
      this.isAvailable, this.availableCount, this.totalCount, this.reason);

  factory InventoryCheckResult.available(int available, int total) =>
      InventoryCheckResult._(true, available, total, null);

  factory InventoryCheckResult.unavailable(
          int available, int total, String reason) =>
      InventoryCheckResult._(false, available, total, reason);
}

/// Result of inventory consumption
class InventoryConsumptionResult {
  final bool isSuccess;
  final int remainingCount;
  final String? errorMessage;

  const InventoryConsumptionResult._(
      this.isSuccess, this.remainingCount, this.errorMessage);

  factory InventoryConsumptionResult.success(int remaining) =>
      InventoryConsumptionResult._(true, remaining, null);

  factory InventoryConsumptionResult.failed(String errorMessage) =>
      InventoryConsumptionResult._(false, 0, errorMessage);
}

/// Abstract interface for component inventory service
abstract class ComponentInventoryService {
  /// Checks if a component type is available in inventory
  InventoryCheckResult checkAvailability(ComponentType type);

  /// Consumes one instance of a component type from inventory
  Future<InventoryConsumptionResult> consumeComponent(ComponentType type);

  /// Returns one instance of a component type to inventory
  Future<InventoryConsumptionResult> returnComponent(ComponentType type);

  /// Gets current inventory levels for all component types
  Map<ComponentType, InventoryCheckResult> getAllInventoryLevels();

  /// Resets inventory to initial state for a level
  Future<void> resetInventoryForLevel(String levelId);
}
