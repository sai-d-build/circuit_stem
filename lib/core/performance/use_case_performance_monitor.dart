import 'dart:async';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
// import 'package:sparkcircuit/application/use_cases/interaction_use_case.dart'; // TODO: Uncomment when InteractionUseCase is implemented

/// Performance monitoring for use case operations
class UseCasePerformanceMonitor {
  static final UseCasePerformanceMonitor _instance = UseCasePerformanceMonitor._();
  factory UseCasePerformanceMonitor() => _instance;
  UseCasePerformanceMonitor._();

  final Map<String, _PerformanceMetrics> _metrics = {};
  final Map<String, Completer<void>> _activeOperations = {};

  /// Monitor a use case operation
  Future<T> monitor<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final startTime = DateTime.now().microsecondsSinceEpoch;
    final operationId = '$operationName-$startTime';

    // Mark operation as active
    _activeOperations[operationId] = Completer<void>();

    try {
      StructuredLogger.debug('UseCase Performance: Starting $operationName', context: {
        'operationId': operationId,
        'startTime': startTime,
        'metadata': metadata,
      });

      final result = await operation();

      final endTime = DateTime.now().microsecondsSinceEpoch;
      final duration = endTime - startTime;

      // Record metrics
      _recordMetrics(operationName, duration, true, metadata);

      StructuredLogger.debug('UseCase Performance: Completed $operationName', context: {
        'operationId': operationId,
        'duration': '$durationμs',
        'success': true,
        'metadata': metadata,
      });

      // Complete the operation
      _activeOperations[operationId]?.complete();
      _activeOperations.remove(operationId);

      return result;
    } catch (e) {
      final endTime = DateTime.now().microsecondsSinceEpoch;
      final duration = endTime - startTime;

      // Record failure metrics
      _recordMetrics(operationName, duration, false, metadata);

      StructuredLogger.error('UseCase Performance: Failed $operationName', context: {
        'operationId': operationId,
        'duration': '$durationμs',
        'success': false,
        'error': e.toString(),
        'metadata': metadata,
      });

      // Complete the operation with error
      _activeOperations[operationId]?.completeError(e);
      _activeOperations.remove(operationId);

      rethrow;
    }
  }

  /// Monitor synchronous use case operation
  T monitorSync<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    try {
      StructuredLogger.debug('UseCase Performance: Starting sync $operationName', context: {
        'startTime': startTime,
        'metadata': metadata,
      });

      final result = operation();

      final endTime = DateTime.now().microsecondsSinceEpoch;
      final duration = endTime - startTime;

      // Record metrics
      _recordMetrics(operationName, duration, true, metadata);

      StructuredLogger.debug('UseCase Performance: Completed sync $operationName', context: {
        'duration': '$durationμs',
        'success': true,
        'metadata': metadata,
      });

      return result;
    } catch (e) {
      final endTime = DateTime.now().microsecondsSinceEpoch;
      final duration = endTime - startTime;

      // Record failure metrics
      _recordMetrics(operationName, duration, false, metadata);

      StructuredLogger.error('UseCase Performance: Failed sync $operationName', context: {
        'duration': '$durationμs',
        'success': false,
        'error': e.toString(),
        'metadata': metadata,
      });

      rethrow;
    }
  }

  void _recordMetrics(String operationName, int duration, bool success, Map<String, dynamic>? metadata) {
    final metrics = _metrics.putIfAbsent(operationName, () => _PerformanceMetrics());

    metrics.totalCalls++;
    metrics.totalDuration += duration;

    if (success) {
      metrics.successCount++;
    } else {
      metrics.failureCount++;
    }

    if (duration > metrics.maxDuration) {
      metrics.maxDuration = duration;
    }

    if (duration < metrics.minDuration || metrics.minDuration == 0) {
      metrics.minDuration = duration;
    }

    // Log performance warnings for slow operations
    if (duration > 16000) { // 16ms for 60fps
      StructuredLogger.warning('UseCase Performance: Slow operation detected', context: {
        'operation': operationName,
        'duration': '$durationμs',
        'threshold': '16000μs (60fps)',
        'metadata': metadata,
      });
    }
  }

  /// Get performance metrics for an operation
  Map<String, dynamic> getMetrics(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null) {
      return {'error': 'No metrics found for operation: $operationName'};
    }

    final avgDuration = metrics.totalCalls > 0 ? metrics.totalDuration / metrics.totalCalls : 0;

    return {
      'operation': operationName,
      'totalCalls': metrics.totalCalls,
      'successCount': metrics.successCount,
      'failureCount': metrics.failureCount,
      'successRate': metrics.totalCalls > 0 ? (metrics.successCount / metrics.totalCalls * 100) : 0,
      'averageDuration': '${avgDuration.round()}μs',
      'minDuration': '$metrics.minDurationμs',
      'maxDuration': '$metrics.maxDurationμs',
      'totalDuration': '$metrics.totalDurationμs',
    };
  }

  /// Get all performance metrics
  Map<String, Map<String, dynamic>> getAllMetrics() {
    final result = <String, Map<String, dynamic>>{};
    for (final entry in _metrics.entries) {
      result[entry.key] = getMetrics(entry.key);
    }
    return result;
  }

  /// Reset metrics for an operation
  void resetMetrics(String operationName) {
    _metrics.remove(operationName);
  }

  /// Reset all metrics
  void resetAllMetrics() {
    _metrics.clear();
  }

  /// Get active operations count
  int get activeOperationsCount => _activeOperations.length;

  /// Get active operation IDs
  List<String> get activeOperationIds => _activeOperations.keys.toList();
}

class _PerformanceMetrics {
  int totalCalls = 0;
  int successCount = 0;
  int failureCount = 0;
  int totalDuration = 0;
  int minDuration = 0;
  int maxDuration = 0;
}

// TODO: Add use case monitoring extensions when InteractionUseCase is implemented
// /// Extension methods for easy use case monitoring
// extension UseCaseMonitoring on InteractionUseCase {
//   /// Monitor findPath operation
//   Future<Result<List<GridPosition>>> findPathMonitored(
//     GridPosition start,
//     GridPosition end, {
//     Set<GridPosition>? occupiedPositions,
//   }) {
//     return UseCasePerformanceMonitor().monitor(
//       'findPath',
//       () => findPath(start, end, occupiedPositions: occupiedPositions),
//       metadata: {
//         'start': {'row': start.row, 'col': start.col},
//         'end': {'row': end.row, 'col': end.col},
//         'occupiedCount': occupiedPositions?.length ?? 0,
//       },
//     );
//   }
//
//   /// Monitor createWireNetwork operation
//   Future<Result<dynamic>> createWireNetworkMonitored(
//     dynamic startPort,
//     dynamic endPort,
//     List<GridPosition> path,
//   ) {
//     return UseCasePerformanceMonitor().monitor(
//       'createWireNetwork',
//       () => createWireNetwork(startPort, endPort, path),
//       metadata: {
//         'pathLength': path.length,
//         'startPort': startPort.toString(),
//         'endPort': endPort.toString(),
//       },
//     );
//   }
// }

/// Global performance monitor instance
final useCasePerformanceMonitor = UseCasePerformanceMonitor();