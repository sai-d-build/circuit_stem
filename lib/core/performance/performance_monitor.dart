import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Performance metric types
enum PerformanceMetric {
  frameTime('Frame Time', 'ms'),
  buildTime('Build Time', 'ms'),
  layoutTime('Layout Time', 'ms'),
  paintTime('Paint Time', 'ms'),
  memoryUsage('Memory Usage', 'MB'),
  cpuUsage('CPU Usage', '%'),
  networkLatency('Network Latency', 'ms'),
  custom('Custom', 'units');

  const PerformanceMetric(this.displayName, this.unit);
  final String displayName;
  final String unit;
}

/// Performance measurement result
class PerformanceMeasurement {
  final PerformanceMetric metric;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PerformanceMeasurement({
    required this.metric,
    required this.value,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'metric': metric.name,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Performance threshold configuration
class PerformanceThreshold {
  final PerformanceMetric metric;
  final double warningThreshold;
  final double errorThreshold;
  final String description;

  const PerformanceThreshold({
    required this.metric,
    required this.warningThreshold,
    required this.errorThreshold,
    required this.description,
  });
}

/// Performance alert
class PerformanceAlert {
  final PerformanceMetric metric;
  final double value;
  final double threshold;
  final AlertLevel level;
  final DateTime timestamp;
  final String message;

  const PerformanceAlert({
    required this.metric,
    required this.value,
    required this.threshold,
    required this.level,
    required this.timestamp,
    required this.message,
  });
}

/// Alert severity levels
enum AlertLevel {
  info('Info'),
  warning('Warning'),
  error('Error'),
  critical('Critical');

  const AlertLevel(this.displayName);
  final String displayName;
}

/// Main performance monitoring service
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._internal();

  final List<PerformanceMeasurement> _measurements = [];
  final List<PerformanceThreshold> _thresholds = [];
  final List<PerformanceAlert> _alerts = [];
  final Map<String, Stopwatch> _activeTimers = {};

  Timer? _collectionTimer;
  bool _isMonitoring = false;

  // Default thresholds
  static const List<PerformanceThreshold> _defaultThresholds = [
    PerformanceThreshold(
      metric: PerformanceMetric.frameTime,
      warningThreshold: 16.67, // ~60 FPS
      errorThreshold: 33.33, // ~30 FPS
      description: 'Frame time should be under 16.67ms for 60 FPS',
    ),
    PerformanceThreshold(
      metric: PerformanceMetric.memoryUsage,
      warningThreshold: 100, // 100 MB
      errorThreshold: 200, // 200 MB
      description: 'Memory usage should be under 100MB',
    ),
    PerformanceThreshold(
      metric: PerformanceMetric.buildTime,
      warningThreshold: 8,
      errorThreshold: 16,
      description: 'Widget build time should be under 8ms',
    ),
  ];

  /// Initialize performance monitoring
  void initialize() {
    _thresholds.addAll(_defaultThresholds);
    StructuredLogger.info('Performance monitor initialized', context: {
      'thresholds': _thresholds.length,
    });
  }

  /// Start performance monitoring
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _collectionTimer = Timer.periodic(interval, _collectMetrics);

    StructuredLogger.info('Performance monitoring started', context: {
      'interval': interval.inSeconds,
    });
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _collectionTimer?.cancel();
    _collectionTimer = null;

    StructuredLogger.info('Performance monitoring stopped');
  }

  /// Record a performance measurement
  void recordMeasurement(
    PerformanceMetric metric,
    double value, {
    Map<String, dynamic> metadata = const {},
  }) {
    final measurement = PerformanceMeasurement(
      metric: metric,
      value: value,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _measurements.add(measurement);

    // Keep only last 1000 measurements
    if (_measurements.length > 1000) {
      _measurements.removeAt(0);
    }

    // Check thresholds
    _checkThresholds(measurement);

    StructuredLogger.debug('Performance measurement recorded', context: {
      'metric': metric.displayName,
      'value': value,
      'unit': metric.unit,
    });
  }

  /// Start timing an operation
  void startTimer(String operationId) {
    _activeTimers[operationId] = Stopwatch()..start();
  }

  /// Stop timing an operation and record the measurement
  void stopTimer(String operationId, PerformanceMetric metric) {
    final stopwatch = _activeTimers.remove(operationId);
    if (stopwatch != null) {
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds.toDouble();
      recordMeasurement(metric, elapsedMs,
          metadata: {'operation': operationId});
    }
  }

  /// Measure frame time using FrameCallback
  void measureFrameTime(VoidCallback frameCallback) {
    startTimer('frame_render');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stopTimer('frame_render', PerformanceMetric.frameTime);
      frameCallback();
    });
  }

  /// Measure build time for a widget
  void measureBuildTime(String widgetName, VoidCallback buildCallback) {
    startTimer('widget_build_$widgetName');
    buildCallback();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stopTimer('widget_build_$widgetName', PerformanceMetric.buildTime);
    });
  }

  /// Get performance statistics
  Map<String, dynamic> getStatistics({
    Duration? timeWindow,
    List<PerformanceMetric>? metrics,
  }) {
    final cutoff =
        timeWindow != null ? DateTime.now().subtract(timeWindow) : null;

    final relevantMeasurements = _measurements.where((m) {
      if (cutoff != null && m.timestamp.isBefore(cutoff)) return false;
      if (metrics != null && !metrics.contains(m.metric)) return false;
      return true;
    }).toList();

    final stats = <String, dynamic>{};

    for (final metric in PerformanceMetric.values) {
      final metricMeasurements =
          relevantMeasurements.where((m) => m.metric == metric).toList();

      if (metricMeasurements.isEmpty) continue;

      final values = metricMeasurements.map((m) => m.value).toList();
      values.sort();

      stats[metric.name] = {
        'count': values.length,
        'min': values.first,
        'max': values.last,
        'avg': values.reduce((a, b) => a + b) / values.length,
        'median': values[values.length ~/ 2],
        'p95': values[(values.length * 0.95).toInt()],
        'unit': metric.unit,
      };
    }

    return stats;
  }

  /// Get recent alerts
  List<PerformanceAlert> getRecentAlerts({int limit = 10}) {
    return _alerts.reversed.take(limit).toList();
  }

  /// Add custom threshold
  void addThreshold(PerformanceThreshold threshold) {
    _thresholds.add(threshold);
    StructuredLogger.info('Performance threshold added', context: {
      'metric': threshold.metric.displayName,
      'warning': threshold.warningThreshold,
      'error': threshold.errorThreshold,
    });
  }

  /// Clear all measurements and alerts
  void clearData() {
    _measurements.clear();
    _alerts.clear();
    StructuredLogger.info('Performance data cleared');
  }

  /// Start static monitoring (for adaptive quality assessment)
  static void startStaticMonitoring() {
    // Initialize static monitoring
    // This would typically start collecting device performance metrics
    StructuredLogger.info('Static performance monitoring started');
  }

  /// Check if device is high performance
  static bool get isHighPerformanceDevice {
    // Simple heuristic: assume high performance in release mode
    // In production, this would check actual device capabilities
    return !kDebugMode;
  }

  /// Get average frame time
  static double get averageFrameTime {
    // Return estimated frame time based on device performance
    // In production, this would be calculated from actual measurements
    return isHighPerformanceDevice ? 16.67 : 33.33; // 60 FPS vs 30 FPS
  }

  /// Get device performance score
  static double get devicePerformanceScore {
    // Return a performance score between 0.0 and 1.0
    // In production, this would be calculated from various device metrics
    return isHighPerformanceDevice ? 0.8 : 0.4;
  }

  /// Check if static monitoring is active
  static bool get isMonitoringStatic {
    // Return monitoring status
    return _instance._isMonitoring;
  }

  /// Get all metrics
  List<PerformanceMeasurement> getAllMetrics() {
    return List.unmodifiable(_measurements);
  }

  /// Get metric statistics
  Map<String, dynamic> getMetricStats(String metricName) {
    final metricMeasurements =
        _measurements.where((m) => m.metric.name == metricName).toList();

    if (metricMeasurements.isEmpty) {
      return {'count': 0, 'avg': 0.0, 'min': 0.0, 'max': 0.0};
    }

    final values = metricMeasurements.map((m) => m.value).toList();
    values.sort();

    return {
      'count': values.length,
      'avg': values.reduce((a, b) => a + b) / values.length,
      'min': values.first,
      'max': values.last,
      'median': values[values.length ~/ 2],
    };
  }

  /// Dispose static resources
  static void disposeStatic() {
    _instance.stopMonitoring();
    StructuredLogger.info('Static performance monitoring disposed');
  }

  /// Export performance data
  Map<String, dynamic> exportData() {
    return {
      'measurements': _measurements.map((m) => m.toJson()).toList(),
      'alerts': _alerts
          .map((a) => {
                'metric': a.metric.name,
                'value': a.value,
                'threshold': a.threshold,
                'level': a.level.name,
                'timestamp': a.timestamp.toIso8601String(),
                'message': a.message,
              })
          .toList(),
      'thresholds': _thresholds
          .map((t) => {
                'metric': t.metric.name,
                'warningThreshold': t.warningThreshold,
                'errorThreshold': t.errorThreshold,
                'description': t.description,
              })
          .toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Collect automatic metrics
  void _collectMetrics(Timer timer) {
    if (!_isMonitoring) return;

    // Collect memory usage (if available)
    if (kDebugMode) {
      // In debug mode, we can collect some basic metrics
      // In production, you might use platform-specific APIs
      recordMeasurement(
        PerformanceMetric.memoryUsage,
        50, // Placeholder memory usage in MB
        metadata: {'source': 'debug_mode'},
      );
    }

    // Collect frame time if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This is a simplified frame time collection
      // In production, you might use more sophisticated frame timing
      recordMeasurement(
        PerformanceMetric.frameTime,
        16.67, // Assume 60 FPS for now
        metadata: {'source': 'estimated'},
      );
    });
  }

  /// Check measurements against thresholds
  void _checkThresholds(PerformanceMeasurement measurement) {
    for (final threshold in _thresholds) {
      if (threshold.metric != measurement.metric) continue;

      AlertLevel? level;
      if (measurement.value >= threshold.errorThreshold) {
        level = AlertLevel.error;
      } else if (measurement.value >= threshold.warningThreshold) {
        level = AlertLevel.warning;
      }

      if (level != null) {
        final alert = PerformanceAlert(
          metric: measurement.metric,
          value: measurement.value,
          threshold: level == AlertLevel.error
              ? threshold.errorThreshold
              : threshold.warningThreshold,
          level: level,
          timestamp: DateTime.now(),
          message:
              '${measurement.metric.displayName} exceeded ${level.displayName.toLowerCase()} threshold '
              '(${measurement.value.toStringAsFixed(2)}${measurement.metric.unit} >= '
              '${level == AlertLevel.error ? threshold.errorThreshold : threshold.warningThreshold}${measurement.metric.unit})',
        );

        _alerts.add(alert);

        // Keep only last 100 alerts
        if (_alerts.length > 100) {
          _alerts.removeAt(0);
        }

        StructuredLogger.warning('Performance alert triggered', context: {
          'metric': measurement.metric.displayName,
          'value': measurement.value,
          'threshold': alert.threshold,
          'level': level.displayName,
          'message': alert.message,
        });
      }
    }
  }
}

/// Performance monitoring widget overlay
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  late Timer _updateTimer;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 2), _updateStats);
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _updateStats(Timer timer) {
    if (mounted) {
      setState(() {
        _stats = PerformanceMonitor().getStatistics(
          timeWindow: const Duration(seconds: 10),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Monitor',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ..._stats.entries.map((entry) {
                    final stat = entry.value as Map<String, dynamic>;
                    return Text(
                      '${entry.key}: ${stat['avg']?.toStringAsFixed(1) ?? 'N/A'}${stat['unit']}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
