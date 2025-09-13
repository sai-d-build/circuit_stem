import 'dart:ui';

import '../../../core/debug/structured_logger.dart';
import '../../../core/events/domain_events.dart';
import '../../../core/services/optimized_grid_manager.dart';
import '../../../domain/entities/core/component.dart';

/// Request DTOs for component use cases
class PlaceComponentRequest {
  final Offset position;
  final ComponentType componentType;
  final Map<String, dynamic>? properties;

  const PlaceComponentRequest({
    required this.position,
    required this.componentType,
    this.properties,
  });
}

class RemoveComponentRequest {
  final Offset position;

  const RemoveComponentRequest({
    required this.position,
  });
}

class MoveComponentRequest {
  final Offset fromPosition;
  final Offset toPosition;

  const MoveComponentRequest({
    required this.fromPosition,
    required this.toPosition,
  });
}

/// Response DTOs for component use cases
class ComponentPlacementResult {
  final bool success;
  final String? componentId;
  final String? errorMessage;
  final ComponentModel? component;

  const ComponentPlacementResult._({
    required this.success,
    this.componentId,
    this.errorMessage,
    this.component,
  });

  factory ComponentPlacementResult.success({
    required String componentId,
    required ComponentModel component,
  }) =>
      ComponentPlacementResult._(
        success: true,
        componentId: componentId,
        component: component,
      );

  factory ComponentPlacementResult.failure(String error) =>
      ComponentPlacementResult._(
        success: false,
        errorMessage: error,
      );
}

/// Component repository interface (Clean Architecture)
abstract class ComponentRepository {
  /// Get component at specific position
  Future<ComponentModel?> getComponentAt(Offset position);

  /// Save component to repository
  Future<void> saveComponent(ComponentModel component);

  /// Remove component from repository
  Future<void> removeComponent(String componentId);

  /// Update component in repository
  Future<void> updateComponent(ComponentModel component);

  /// Get all components
  Future<List<ComponentModel>> getAllComponents();

  /// Check if position is occupied
  Future<bool> isPositionOccupied(Offset position);
}

/// Component placement use case (Clean Architecture)
class PlaceComponentUseCase {
  final ComponentRepository repository;
  final OptimizedGridManager gridManager;

  const PlaceComponentUseCase({
    required this.repository,
    required this.gridManager,
  });

  Future<ComponentPlacementResult> execute(
      PlaceComponentRequest request) async {
    try {
      StructuredLogger.info('PlaceComponentUseCase: Executing place component',
          context: {
            'position': request.position.toString(),
            'componentType': request.componentType.toString(),
          });

      // Business rule: Check if position is available
      if (!gridManager.canPlaceComponent(request.position)) {
        return ComponentPlacementResult.failure('Position is not available');
      }

      // Business rule: Validate component type
      if (!await _isValidComponentType(request.componentType)) {
        return ComponentPlacementResult.failure('Invalid component type');
      }

      // Create component
      final component = ComponentModel(
        id: 'component_${DateTime.now().millisecondsSinceEpoch}',
        type: request.componentType,
        row: request.position.dy.round(),
        col: request.position.dx.round(),
        state: ComponentState.normal,
        properties: request.properties ?? {},
      );

      // Save to repository
      await repository.saveComponent(component);

      // Update grid manager
      gridManager.placeComponent(request.position);

      // Publish domain event
      domainEventBus.publish(ComponentPlacedEvent(
        componentId: component.id,
        position: request.position,
        componentType: request.componentType.toString(),
      ));

      StructuredLogger.info(
          'PlaceComponentUseCase: Component placed successfully',
          context: {
            'componentId': component.id,
            'position': request.position.toString(),
          });

      return ComponentPlacementResult.success(
        componentId: component.id,
        component: component,
      );
    } catch (e) {
      StructuredLogger.error('PlaceComponentUseCase: Failed to place component',
          context: {
            'error': e.toString(),
            'position': request.position.toString(),
            'componentType': request.componentType.toString(),
          });

      return ComponentPlacementResult.failure('Failed to place component: $e');
    }
  }

  Future<bool> _isValidComponentType(ComponentType type) async {
    // Business rule: Only allow certain component types
    const validTypes = [
      ComponentType.resistor,
      ComponentType.capacitor,
      ComponentType.inductor,
      ComponentType.bulb,
      ComponentType.battery,
      ComponentType.wire,
    ];

    return validTypes.contains(type);
  }
}

/// Remove component use case
class RemoveComponentUseCase {
  final ComponentRepository repository;
  final OptimizedGridManager gridManager;

  const RemoveComponentUseCase({
    required this.repository,
    required this.gridManager,
  });

  Future<ComponentPlacementResult> execute(
      RemoveComponentRequest request) async {
    try {
      StructuredLogger.info(
          'RemoveComponentUseCase: Executing remove component',
          context: {
            'position': request.position.toString(),
          });

      // Get component at position
      final component = await repository.getComponentAt(request.position);
      if (component == null) {
        return ComponentPlacementResult.failure('No component at position');
      }

      // Remove from repository
      await repository.removeComponent(component.id);

      // Update grid manager
      gridManager.removeComponent(request.position);

      // Publish domain event
      domainEventBus.publish(ComponentRemovedEvent(
        componentId: component.id,
        position: request.position,
        componentType: component.type.toString(),
      ));

      StructuredLogger.info(
          'RemoveComponentUseCase: Component removed successfully',
          context: {
            'componentId': component.id,
            'position': request.position.toString(),
          });

      return ComponentPlacementResult.success(
        componentId: component.id,
        component: component,
      );
    } catch (e) {
      StructuredLogger.error(
          'RemoveComponentUseCase: Failed to remove component',
          context: {
            'error': e.toString(),
            'position': request.position.toString(),
          });

      return ComponentPlacementResult.failure('Failed to remove component: $e');
    }
  }
}

/// Move component use case
class MoveComponentUseCase {
  final ComponentRepository repository;
  final OptimizedGridManager gridManager;

  const MoveComponentUseCase({
    required this.repository,
    required this.gridManager,
  });

  Future<ComponentPlacementResult> execute(MoveComponentRequest request) async {
    try {
      StructuredLogger.info('MoveComponentUseCase: Executing move component',
          context: {
            'fromPosition': request.fromPosition.toString(),
            'toPosition': request.toPosition.toString(),
          });

      // Get component at source position
      final component = await repository.getComponentAt(request.fromPosition);
      if (component == null) {
        return ComponentPlacementResult.failure(
            'No component at source position');
      }

      // Check if destination is available
      if (!gridManager.canPlaceComponent(request.toPosition)) {
        return ComponentPlacementResult.failure(
            'Destination position is not available');
      }

      // Update component position
      final updatedComponent = ComponentModel(
        id: component.id,
        type: component.type,
        row: request.toPosition.dy.round(),
        col: request.toPosition.dx.round(),
        state: component.state,
        properties: component.properties,
      );

      // Update in repository
      await repository.updateComponent(updatedComponent);

      // Update grid manager
      gridManager.removeComponent(request.fromPosition); // ignore: cascade_invocations
      gridManager.placeComponent(request.toPosition); // ignore: cascade_invocations

      // Publish domain event
      domainEventBus.publish(ComponentMovedEvent(
        componentId: component.id,
        fromPosition: request.fromPosition,
        toPosition: request.toPosition,
        componentType: component.type.toString(),
      ));

      StructuredLogger.info(
          'MoveComponentUseCase: Component moved successfully',
          context: {
            'componentId': component.id,
            'fromPosition': request.fromPosition.toString(),
            'toPosition': request.toPosition.toString(),
          });

      return ComponentPlacementResult.success(
        componentId: component.id,
        component: updatedComponent,
      );
    } catch (e) {
      StructuredLogger.error('MoveComponentUseCase: Failed to move component',
          context: {
            'error': e.toString(),
            'fromPosition': request.fromPosition.toString(),
            'toPosition': request.toPosition.toString(),
          });

      return ComponentPlacementResult.failure('Failed to move component: $e');
    }
  }
}

/// Circuit validation use case
class ValidateCircuitUseCase {
  final ComponentRepository repository;
  final OptimizedGridManager gridManager;

  const ValidateCircuitUseCase({
    required this.repository,
    required this.gridManager,
  });

  Future<CircuitValidationResult> execute() async {
    try {
      StructuredLogger.info(
          'ValidateCircuitUseCase: Executing circuit validation');

      final components = await repository.getAllComponents();
      final errors = <String>[];
      final warnings = <String>[];

      // Business rule: Check for isolated components
      final connectedComponents = await _findConnectedComponents(components);
      if (connectedComponents.length < components.length) {
        warnings.add(
            '${components.length - connectedComponents.length} components are isolated');
      }

      // Business rule: Check for voltage sources
      final hasBattery = components.any((c) => c.type == ComponentType.battery);
      if (!hasBattery) {
        warnings.add('Circuit has no voltage source (battery)');
      }

      // Business rule: Check for complete circuits
      final hasLoad = components.any((c) =>
          c.type == ComponentType.bulb || c.type == ComponentType.buzzer);
      if (!hasLoad) {
        warnings.add('Circuit has no load (bulb or buzzer)');
      }

      // Business rule: Check for proper connections
      final connectionErrors = await _validateConnections(components);
      errors.addAll(connectionErrors);

      final isValid = errors.isEmpty;

      StructuredLogger.info(
          'ValidateCircuitUseCase: Circuit validation completed',
          context: {
            'isValid': isValid,
            'errorCount': errors.length,
            'warningCount': warnings.length,
            'componentCount': components.length,
          });

      return CircuitValidationResult(
        isValid: isValid,
        errors: errors,
        warnings: warnings,
        componentCount: components.length,
      );
    } catch (e) {
      StructuredLogger.error(
          'ValidateCircuitUseCase: Circuit validation failed',
          context: {
            'error': e.toString(),
          });

      return CircuitValidationResult(
        isValid: false,
        errors: ['Validation failed: $e'],
        warnings: [],
        componentCount: 0,
      );
    }
  }

  Future<List<ComponentModel>> _findConnectedComponents(
      List<ComponentModel> components) async {
    // Simplified connectivity check - in real implementation, this would use
    // wire network analysis to determine actual connectivity
    return components
        .where((component) => component.type != ComponentType.wire)
        .toList();
  }

  Future<List<String>> _validateConnections(
      List<ComponentModel> components) async {
    final errors = <String>[];

    // Check for components with invalid positions
    for (final component in components) {
      final position =
          Offset(component.col.toDouble(), component.row.toDouble());
      if (!gridManager.isWithinBounds(position)) {
        errors.add('Component ${component.id} is outside grid bounds');
      }
    }

    return errors;
  }
}

/// Circuit validation result
class CircuitValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int componentCount;

  const CircuitValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.componentCount,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}
