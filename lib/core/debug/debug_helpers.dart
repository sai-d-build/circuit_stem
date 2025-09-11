// lib/core/debug/debug_helpers.dart
// Utility helpers for conditional debug logging

import 'package:flutter/foundation.dart';
import 'structured_logger.dart';

/// Performance optimization guard - use this before expensive debug operations
bool debugEnabled([String flagName = '']) {
  return StructuredLogger.isEnabled && (flagName.isEmpty || StructuredLogger.getRuntimeFlag(flagName, defaultValue: true));
}

/// 🔧 SERVICES DEBUG HELPERS
class ServicesDebugHelers {
  /// Service operation performance timing
  static void timeOperation(String operationName, Map<String, dynamic> context, Future<void> Function() operation) async {
    if (!StructuredLogger.debugServices) return;

    final start = DateTime.now();
    try {
      await operation();
      final duration = DateTime.now().difference(start);
      StructuredLogger.services('Service operation completed', context: {
        'operation': operationName,
        'durationMs': duration.inMilliseconds,
        'success': true,
      });
    } catch (e) {
      final duration = DateTime.now().difference(start);
      StructuredLogger.services('Service operation failed', context: {
        'operation': operationName,
        'durationMs': duration.inMilliseconds,
        'success': false,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Asset loading tracking
  static void logAssetLoad(String assetPath, {String? assetType, Map<String, dynamic>? metadata}) {
    if (!StructuredLogger.debugServices) return;
    StructuredLogger.services('Asset load initiated', context: {
      'path': assetPath,
      'type': assetType ?? 'generic',
      'timestamp': DateTime.now().toIso8601String(),
      if (metadata != null) ...metadata,
    });
  }
}

/// 🎮 GAME CANVAS DEBUG HELPERS
class GameCanvasDebugHelpers {
  /// Grid operation tracking
  static void gridOperation(String operation, Map<String, dynamic> position, {String? status}) {
    if (!StructuredLogger.debugGameCanvas) return;
    StructuredLogger.gameCanvas('Grid operation: $operation', context: {
      'position': position,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (status != null) 'status': status,
    });
  }

  /// Viewport change tracking
  static void viewportChange(String changeType, Map<String, dynamic> changes) {
    if (!StructuredLogger.debugGameCanvas) return;
    StructuredLogger.gameCanvas('Viewport change: $changeType', context: changes);
  }
}

/// 🖼️ PRESENTATION DEBUG HELPERS
class PresentationDebugHelpers {
  /// Widget performance tracking
  static void widgetBuild(String widgetName, {Map<String, dynamic>? context}) {
    if (!StructuredLogger.debugPresentation) return;
    StructuredLogger.presentation('Widget build: $widgetName', context: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?context,
    });
  }

  /// Navigation tracking
  static void navigation(String route, {String? fromRoute, Map<String, dynamic>? metadata}) {
    if (!StructuredLogger.debugPresentation) return;
    StructuredLogger.presentation('Navigation: $route', context: {
      if (fromRoute != null) 'from': fromRoute,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?metadata,
    });
  }
}

/// 🎯 COMPONENT DEBUG HELPERS
class ComponentDebugHelpers {
  /// Drag operation tracking
  static void dragOperation(String operation, String componentType, Map<String, dynamic> context) {
    if (!StructuredLogger.debugComponents) return;
    StructuredLogger.components('Drag operation: $operation for $componentType', context: context);
  }

  /// Placement validation tracking
  static void placementValidation(String componentType, Map<String, dynamic> position, bool valid, {String? reason}) {
    if (!StructuredLogger.debugComponents) return;
    final level = valid ? 'INFO' : 'WARNING';
    StructuredLogger.components('Placement validation: $componentType', context: {
      'position': position,
      'valid': valid,
      if (reason != null) 'reason': reason,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// 📊 PERFORMANCE DEBUG HELPERS
class PerformanceDebugHelpers {
  /// Frame rate monitoring
  static void frameRate(double fps, {String? context}) {
    if (!StructuredLogger.debugPerformance) return;
    StructuredLogger.performance('Frame rate: ${fps.toStringAsFixed(1)} FPS', context: {
      if (context != null) 'context': context,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Memory usage monitoring
  static void memoryUsage(int bytes, {String? operation}) {
    if (!StructuredLogger.debugPerformance) return;
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
    StructuredLogger.performance('Memory usage: ${mb}MB', context: {
      'bytes': bytes,
      if (operation != null) 'operation': operation,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Cache operation tracking
  static void cacheOperation(String operation, String key, bool hit, {Map<String, dynamic>? metadata}) {
    if (!StructuredLogger.debugPerformance) return;
    StructuredLogger.performance('Cache $operation: $key (${hit ? "HIT" : "MISS"})', context: {
      'operation': operation,
      'key': key,
      'hit': hit,
      ...?metadata,
    });
  }
}

/// 🌐 WEB SPECIFIC DEBUG HELPERS
class WebDebugHelpers {
  /// Asset loading in web environment
  static void webAssetLoad(String assetPath, {bool success = true, String? error}) {
    if (!StructuredLogger.debugWeb) return;
    StructuredLogger.web('Web asset load: $assetPath (${success ? "SUCCESS" : "FAILED"})', context: {
      'assetPath': assetPath,
      'success': success,
      if (error != null) 'error': error,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Browser compatibility issues
  static void browserCompatibility(String issue, {String? workaround, Map<String, dynamic>? details}) {
    if (!StructuredLogger.debugWeb) return;
    StructuredLogger.web('Browser compatibility issue: $issue', context: {
      if (workaround != null) 'workaround': workaround,
      if (details != null) ...details,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// 🔥 CRITICAL DEBUG HELPERS
class CriticalDebugHelpers {
  /// System health monitoring
  static void systemHealthCheck(String component, bool healthy, {String? error}) {
    if (!StructuredLogger.debugCritical) return;
    final status = healthy ? 'HEALTHY' : 'UNHEALTHY';
    StructuredLogger.critical('Health check: $component is $status', context: {
      'component': component,
      'healthy': healthy,
      if (error != null) 'error': error,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Error escalation
  static void escalateError(String error, String component, {String? context, StackTrace? stackTrace}) {
    StructuredLogger.critical('ERROR ESCALATION: $error in $component', error: error, context: {
      if (context != null) 'context': context,
      'component': component,
      'requiresImmediateAttention': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// ====================================================================
/// EXAMPLE USAGE PATTERNS
/// ====================================================================

/*
Example usage in service code:

```dart
class LevelService {
  Future<LevelDefinition?> loadLevel(String levelId) async {
    await ServicesDebugHelpers.timeOperation(
      'loadLevel_$levelId',
      {'levelId': levelId},
      () async {
        ServicesDebugHelpers.logAssetLoad('levels/$levelId.json', assetType: 'level');
        // actual loading logic
      }
    );
    return level;
  }
}
```

Example usage in component code:

```dart
class DragHandler {
  void startDrag(String componentType) {
    ComponentDebugHelpers.dragOperation('start', componentType, {
      'componentType': componentType,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  void validatePlacement(String componentType, Offset position, bool isValid) {
    ComponentDebugHelpers.placementValidation(componentType, {
      'x': position.dx,
      'y': position.dy
    }, isValid, reason: 'out of bounds');
  }
}
```

Example usage in presentation code:

```dart
class LevelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PresentationDebugHelpers.widgetBuild('LevelCard', context: {
      'isLocked': isLocked,
      'levelId': levelId
    });
    return Card(/* build card */);
  }
}
```

Example usage in performance monitoring:

```dart
class FrameRateMonitor {
  void logFrameRate(double fps) {
    PerformanceDebugHelpers.frameRate(fps, context: '40ms target frame rate');

    if (fps < 24) { // Below 24fps
      PerformanceDebugHelpers.performanceWarning(
        'Frame rate dropped below 24 FPS',
        {'currentFps': fps, 'targetFps': 60}
      );
    }
  }
}
*/