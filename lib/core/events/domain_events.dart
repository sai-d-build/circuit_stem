import 'package:flutter/material.dart';
import '../../../core/debug/structured_logger.dart';

/// Base class for all domain events
abstract class DomainEvent {
  /// Unique identifier for the event
  final String eventId;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Event type identifier
  final String eventType;

  DomainEvent(this.eventType)
      : eventId = '${eventType}_${DateTime.now().millisecondsSinceEpoch}',
        timestamp = DateTime.now();

  /// Convert event to JSON for serialization
  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'eventType': eventType,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  String toString() => '$eventType(eventId: $eventId, timestamp: $timestamp)';
}

/// Component-related domain events
class ComponentPlacedEvent extends DomainEvent {
  final String componentId;
  final Offset position;
  final String componentType;

  ComponentPlacedEvent({
    required this.componentId,
    required this.position,
    required this.componentType,
  }) : super('ComponentPlaced');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'componentId': componentId,
      'positionDx': position.dx,
      'positionDy': position.dy,
      'componentType': componentType,
    });
    return json;
  }
}

class ComponentRemovedEvent extends DomainEvent {
  final String componentId;
  final Offset position;
  final String componentType;

  ComponentRemovedEvent({
    required this.componentId,
    required this.position,
    required this.componentType,
  }) : super('ComponentRemoved');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'componentId': componentId,
      'positionDx': position.dx,
      'positionDy': position.dy,
      'componentType': componentType,
    });
    return json;
  }
}

class ComponentMovedEvent extends DomainEvent {
  final String componentId;
  final Offset fromPosition;
  final Offset toPosition;
  final String componentType;

  ComponentMovedEvent({
    required this.componentId,
    required this.fromPosition,
    required this.toPosition,
    required this.componentType,
  }) : super('ComponentMoved');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'componentId': componentId,
      'fromPositionDx': fromPosition.dx,
      'fromPositionDy': fromPosition.dy,
      'toPositionDx': toPosition.dx,
      'toPositionDy': toPosition.dy,
      'componentType': componentType,
    });
    return json;
  }
}

/// Circuit simulation events
class CircuitSimulationStartedEvent extends DomainEvent {
  final String circuitId;
  final Map<String, dynamic> simulationParameters;

  CircuitSimulationStartedEvent({
    required this.circuitId,
    required this.simulationParameters,
  }) : super('CircuitSimulationStarted');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'circuitId': circuitId,
      'simulationParameters': simulationParameters,
    });
    return json;
  }
}

class CircuitSimulationCompletedEvent extends DomainEvent {
  final String circuitId;
  final Map<String, dynamic> results;
  final Duration executionTime;

  CircuitSimulationCompletedEvent({
    required this.circuitId,
    required this.results,
    required this.executionTime,
  }) : super('CircuitSimulationCompleted');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'circuitId': circuitId,
      'results': results,
      'executionTimeMs': executionTime.inMilliseconds,
    });
    return json;
  }
}

/// User interaction events
class UserInteractionEvent extends DomainEvent {
  final String userId;
  final String interactionType;
  final Map<String, dynamic> interactionData;

  UserInteractionEvent({
    required this.userId,
    required this.interactionType,
    required this.interactionData,
  }) : super('UserInteraction');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'userId': userId,
      'interactionType': interactionType,
      'interactionData': interactionData,
    });
    return json;
  }
}

/// Error events
class CircuitErrorEvent extends DomainEvent {
  final String errorType;
  final String errorMessage;
  final Map<String, dynamic>? errorContext;
  final StackTrace? stackTrace;

  CircuitErrorEvent({
    required this.errorType,
    required this.errorMessage,
    this.errorContext,
    this.stackTrace,
  }) : super('CircuitError');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'errorType': errorType,
      'errorMessage': errorMessage,
      'errorContext': errorContext,
      'hasStackTrace': stackTrace != null,
    });
    return json;
  }
}

/// Domain event bus for publishing and subscribing to events
class DomainEventBus {
  final Map<Type, List<Function(DomainEvent)>> _subscribers = {};
  final List<DomainEvent> _eventHistory = [];
  static const int _maxHistorySize = 1000;

  /// Subscribe to events of a specific type
  void subscribe<T extends DomainEvent>(void Function(T) handler) {
    final eventType = T;
    _subscribers.putIfAbsent(eventType, () => []);
    _subscribers[eventType]!.add(handler as Function(DomainEvent));

    StructuredLogger.info('DomainEventBus: Subscribed to $eventType', context: {
      'subscriberCount': _subscribers[eventType]!.length,
    });
  }

  /// Unsubscribe from events of a specific type
  void unsubscribe<T extends DomainEvent>(void Function(T) handler) {
    final eventType = T;
    if (_subscribers.containsKey(eventType)) {
      _subscribers[eventType]!.remove(handler);
      if (_subscribers[eventType]!.isEmpty) {
        _subscribers.remove(eventType);
      }
    }
  }

  /// Publish an event to all subscribers
  void publish(DomainEvent event) {
    // Add to history
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }

    // Log the event
    StructuredLogger.info('DomainEventBus: Publishing ${event.eventType}', context: {
      'eventId': event.eventId,
      'eventType': event.eventType,
      'timestamp': event.timestamp.toIso8601String(),
    });

    // Notify subscribers
    final eventType = event.runtimeType;
    if (_subscribers.containsKey(eventType)) {
      for (final handler in _subscribers[eventType]!) {
        try {
          handler(event);
        } catch (e) {
          StructuredLogger.error('DomainEventBus: Error in event handler', context: {
            'eventType': event.eventType,
            'error': e.toString(),
          });
        }
      }
    }
  }

  /// Get event history
  List<DomainEvent> getEventHistory({int? limit}) {
    if (limit != null && limit < _eventHistory.length) {
      return _eventHistory.sublist(_eventHistory.length - limit);
    }
    return List.unmodifiable(_eventHistory);
  }

  /// Get events of a specific type from history
  List<T> getEventsOfType<T extends DomainEvent>({int? limit}) {
    final events = _eventHistory.whereType<T>().toList();
    if (limit != null && limit < events.length) {
      return events.sublist(events.length - limit);
    }
    return events;
  }

  /// Clear event history
  void clearHistory() {
    _eventHistory.clear();
    StructuredLogger.info('DomainEventBus: Event history cleared');
  }

  /// Get statistics about event handling
  Map<String, dynamic> getStatistics() {
    final eventCounts = <String, int>{};
    for (final event in _eventHistory) {
      final type = event.eventType;
      eventCounts[type] = (eventCounts[type] ?? 0) + 1;
    }

    final subscriberCounts = <String, int>{};
    for (final entry in _subscribers.entries) {
      subscriberCounts[entry.key.toString()] = entry.value.length;
    }

    return {
      'totalEvents': _eventHistory.length,
      'eventCountsByType': eventCounts,
      'subscriberCountsByType': subscriberCounts,
      'oldestEvent': _eventHistory.isNotEmpty ? _eventHistory.first.timestamp.toIso8601String() : null,
      'newestEvent': _eventHistory.isNotEmpty ? _eventHistory.last.timestamp.toIso8601String() : null,
    };
  }
}

/// Singleton instance of the domain event bus
final domainEventBus = DomainEventBus();

/// Event handlers for common domain events
class DomainEventHandlers {
  static void setupDefaultHandlers() {
    // Component events
    domainEventBus.subscribe<ComponentPlacedEvent>((event) {
      StructuredLogger.info('Component placed', context: {
        'componentId': event.componentId,
        'position': event.position.toString(),
        'componentType': event.componentType,
      });
    });

    domainEventBus.subscribe<ComponentRemovedEvent>((event) {
      StructuredLogger.info('Component removed', context: {
        'componentId': event.componentId,
        'position': event.position.toString(),
        'componentType': event.componentType,
      });
    });

    domainEventBus.subscribe<ComponentMovedEvent>((event) {
      StructuredLogger.info('Component moved', context: {
        'componentId': event.componentId,
        'fromPosition': event.fromPosition.toString(),
        'toPosition': event.toPosition.toString(),
        'componentType': event.componentType,
      });
    });

    // Error events
    domainEventBus.subscribe<CircuitErrorEvent>((event) {
      StructuredLogger.error('Circuit error occurred', context: {
        'errorType': event.errorType,
        'errorMessage': event.errorMessage,
        'errorContext': event.errorContext,
      });
    });

    StructuredLogger.info('DomainEventHandlers: Default handlers configured');
  }
}