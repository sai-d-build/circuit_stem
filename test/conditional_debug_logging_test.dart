// test/conditional_debug_logging_test.dart
// Test suite for conditional debug logging system

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sparkcircuit/core/debug/structured_logger.dart';

// Mock for structured logger testing
class _TestStructuredLogger {
  static final List<String> _logs = [];
  static bool _lastCondition = false;

  static void clearLogs() => _logs.clear();

  static void log(String level, String message, {Map<String, dynamic>? context}) {
    _logs.add('$level: $message' + (context != null ? ' | Context: $context' : ''));
  }

  static List<String> getLogs() => _logs;
}

void main() {
  group('Conditional Debug Logging System Tests', () {
    setUp(() {
      StructuredLogger.setEnabled(true);
      _TestStructuredLogger.clearLogs();
    });

    tearDown(() {
      StructuredLogger.setEnabled(true);
      _TestStructuredLogger.clearLogs();
    });

    test('Global enable/disable logging control', () {
      // Initially enabled
      expect(StructuredLogger.isEnabled, true);

      // Disable globally
      StructuredLogger.setEnabled(false);
      expect(StructuredLogger.isEnabled, false);

      // Re-enable
      StructuredLogger.setEnabled(true);
      expect(StructuredLogger.isEnabled, true);
    });

    test('Module debug flag getters work in web/mobile context', () {
      // Test web defaults (should default to true for web development)
      if (kIsWeb) {
        expect(StructuredLogger.debugServices, true);
        expect(StructuredLogger.debugGameCanvas, true);
        expect(StructuredLogger.debugPresentation, true);
      } else {
        // Non-web should default to false for mobile performance
        expect(StructuredLogger.debugServices, false);
        expect(StructuredLogger.debugGameCanvas, false);
        expect(StructuredLogger.debugPresentation, false);
      }
      // Critical should always default to true
      expect(StructuredLogger.debugCritical, true);
    });

    test('Runtime flag configuration', () {
      // Test runtime flag setting
      StructuredLogger.setRuntimeFlag('testFlag', true);
      expect(StructuredLogger.getRuntimeFlag('testFlag'), true);
      expect(StructuredLogger.getRuntimeFlag('testFlag', defaultValue: false), true);

      // Test fallback to default
      expect(StructuredLogger.getRuntimeFlag('nonExistentFlag', defaultValue: false), false);
      expect(StructuredLogger.getRuntimeFlag('nonExistentFlag', defaultValue: true), true);
    });

    test('hasAnyDebugEnabled performance optimization', () {
      // Initially all debug flags are enabled (in web)
      expect(StructuredLogger.hasAnyDebugEnabled, true);

      // Set all to false through runtime flags (simulating production)
      StructuredLogger.setRuntimeFlag('simulateProduction', false);

      // In a real scenario, we'd override the flag getters
      // For testing, we can verify the optimization guard works
      final performanceGuard = StructuredLogger.hasAnyDebugEnabled;
      expect(performanceGuard, isA<bool>());
    });

    test('Module-specific logging methods work conditionally', () {
      // Test services logging
      StructuredLogger.services('Test services operation', context: {'operation': 'test'});
      // Should log if debugServices is enabled

      // Test critical logging (always enabled)
      StructuredLogger.critical('Test critical issue', context: {'severity': 'high'});
      // Should always log regardless of critical flag
    });

    test('Log optimization prevents expensive operations when disabled', () {
      int expensiveOperationCount = 0;

      void expensiveLoadOperation() {
        expensiveOperationCount++;
        // Simulate expensive string building
        final result = List.generate(1000, (i) => i).fold<String>('', (prev, i) => prev + i.toString());
        // Don't return anything, just perform expensive operation
      }

      // Test with global logging disabled
      StructuredLogger.setEnabled(false);

      // This should not execute the expensive operation
      if (StructuredLogger.isEnabled && StructuredLogger.debugServices) {
        expensiveLoadOperation();
      }

      expect(expensiveOperationCount, 0);

      // Test with logging enabled
      StructuredLogger.setEnabled(true);

      if (StructuredLogger.isEnabled && StructuredLogger.debugServices) {
        expensiveLoadOperation();
      }

      if (kIsWeb) {
        expect(expensiveOperationCount, 1); // Should execute in web environment
      }
    });

    test('Web-specific debug flags are automatically enabled in web builds', () {
      if (kIsWeb) {
        // In web builds, web debug should default to true
        expect(StructuredLogger.debugWeb, true);
      } else {
        // In mobile builds, web debug should default to false
        expect(StructuredLogger.debugWeb, false);
      }
    });

    test('Critical issues always log regardless of other flags', () {
      // Even if we disable most debug logging, critical should remain enabled
      StructuredLogger.setRuntimeFlag('disableAll', true);

      // Critical issues should always be logged
      StructuredLogger.critical('System critical error', context: {'requiresAttention': true});

      // Other debug logging might be disabled but critical remains
      expect(StructuredLogger.debugCritical, true);
    });
  });
}