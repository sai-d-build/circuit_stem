// lib/core/performance/performance_test_logger.dart
// Specialized logger for performance testing with structured output

import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Specialized logger for performance testing scenarios
/// Provides structured logging methods for test output, metrics, and enterprise reporting
class PerformanceTestLogger {
  static const String _testPrefix = '🏁 PERFORMANCE_TEST';
  static String get _separator => '=' * 60;

  /// Log test suite header with enterprise formatting
  static void testSuiteHeader(String suiteName, [String? description]) {
    StructuredLogger.info('$_testPrefix | SUITE_START | $suiteName',
      context: {
        'description': description ?? 'Enterprise-grade performance regression testing',
        'timestamp': DateTime.now().toIso8601String(),
        'separator': _separator
      });
  }

  /// Log test suite completion
  static void testSuiteComplete(String suiteName, {bool success = true}) {
    StructuredLogger.info('$_testPrefix | SUITE_COMPLETE | $suiteName | ${success ? 'SUCCESS' : 'FAILED'}',
      context: {
        'timestamp': DateTime.now().toIso8601String(),
        'separator': _separator
      });
  }

  /// Log individual test header
  static void testHeader(String testName, [String? description]) {
    StructuredLogger.info('$_testPrefix | TEST_START | $testName',
      context: description != null ? {'description': description} : null);
  }

  /// Log test result with metrics
  static void testResult(String testName, Map<String, dynamic> metrics,
      {bool passed = true, String? notes, String? target}) {
    StructuredLogger.info('$_testPrefix | TEST_RESULT | $testName | ${passed ? 'PASSED' : 'FAILED'}',
      context: {
        'metrics': metrics,
        'notes': notes,
        'target': target,
        'timestamp': DateTime.now().toIso8601String()
      });
  }

  /// Log performance metric with units
  static void performanceMetric(String operation, double value, String unit,
      {Map<String, dynamic>? context, String? target}) {
    final message = '$operation: ${value.toStringAsFixed(2)}$unit${target != null ? ' (Target: $target)' : ''}';

    StructuredLogger.info('$_testPrefix | METRIC | $message',
      context: context);
  }

  /// Log cache statistics
  static void cacheStats(Map<String, dynamic> stats) {
    StructuredLogger.info('$_testPrefix | CACHE_STATS',
      context: stats);
  }

  /// Log memory usage information
  static void memoryUsage(double currentMB, double growthMB,
      {String? notes, double? targetMB}) {
    StructuredLogger.info('$_testPrefix | MEMORY_USAGE | ${currentMB.toStringAsFixed(1)}MB (Growth: ${growthMB.toStringAsFixed(1)}MB)',
      context: {
        'current_mb': currentMB,
        'growth_mb': growthMB,
        'target_mb': targetMB,
        'notes': notes
      });
  }

  /// Log device compatibility results
  static void deviceCompatibility(String tier, List<String> features, double score,
      {Map<String, dynamic>? details}) {
    StructuredLogger.info('$_testPrefix | DEVICE_COMPATIBILITY | Tier: $tier | Score: ${(score * 100).toStringAsFixed(1)}%',
      context: {
        'tier': tier,
        'features': features,
        'compatibility_score': score,
        'details': details
      });
  }

  /// Log error recovery metrics
  static void errorRecovery(String type, double successRate, double stability,
      {Map<String, dynamic>? details}) {
    StructuredLogger.info('$_testPrefix | ERROR_RECOVERY | $type | Success: ${(successRate * 100).toStringAsFixed(1)}% | Stability: ${(stability * 100).toStringAsFixed(1)}%',
      context: {
        'recovery_type': type,
        'success_rate': successRate,
        'stability': stability,
        'details': details
      });
  }

  /// Log sustained performance results
  static void sustainedPerformance(double avgFrameTime, double fps, double deviance,
      {Duration? duration, String? notes}) {
    StructuredLogger.info('$_testPrefix | SUSTAINED_PERFORMANCE | ${avgFrameTime.toStringAsFixed(2)}ms/frame | ${fps.toStringAsFixed(1)} FPS',
      context: {
        'avg_frame_time_ms': avgFrameTime,
        'fps': fps,
        'deviance_percent': deviance * 100,
        'duration_seconds': duration?.inSeconds,
        'notes': notes
      });
  }

  /// Log enterprise-style report
  static void enterpriseReport(String title, Map<String, dynamic> metrics,
      {String? status, String? riskLevel}) {
    StructuredLogger.info('$_testPrefix | ENTERPRISE_REPORT | $title',
      context: {
        'metrics': metrics,
        'status': status ?? 'PRODUCTION_READY',
        'risk_level': riskLevel ?? 'LOW_RISK',
        'generated_at': DateTime.now().toIso8601String()
      });
  }

  /// Log warnings with context
  static void warning(String message, {Map<String, dynamic>? context}) {
    StructuredLogger.warning('$_testPrefix | WARNING | $message', context: context);
  }

  /// Log test failures
  static void testFailure(String testName, String reason, {Map<String, dynamic>? context}) {
    StructuredLogger.error('$_testPrefix | TEST_FAILURE | $testName | $reason', context: context);
  }

  /// Log general information
  static void info(String message, {Map<String, dynamic>? context}) {
    StructuredLogger.info('$_testPrefix | INFO | $message', context: context);
  }

  /// Enable/disable performance test logging
  static void setEnabled(bool enabled) {
    // This could be extended to control logging levels or output formats
    StructuredLogger.setEnabled(enabled);
  }
}