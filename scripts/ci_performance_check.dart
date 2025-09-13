#!/usr/bin/env dart

/// CI script to enforce performance budgets and coordinate conversion accuracy
/// Run this in CI to prevent performance regressions

import 'dart:convert';
import 'dart:io';

// Enhanced logging for CI scripts
void logMessage(String message, [Object? data]) {
  final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
  var output = '[$timestamp] $message';
  if (data != null) {
    output += ' - $data';
  }
  print(output);
}

// Enhanced error logging
void logError(String message, [Object? error]) {
  final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
  var output = '[$timestamp] ❌ ERROR: $message';
  if (error != null) {
    output += '\n    Details: $error';
  }
  stderr.writeln(output);
}

// Enhanced success logging
void logSuccess(String message) {
  final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
  print('[$timestamp] ✅ $message');
}

void main(List<String> arguments) {
  logMessage('🚀 Starting CI Performance Check...');

  final results = <String, dynamic>{};
  var allPassed = true;

  // Performance budgets (in milliseconds)
  const performanceBudgets = {
    'coordinate_transformations_p50': 8.0,
    'coordinate_transformations_p99': 16.0,
    'drag_operations_p50': 8.0,
    'drag_operations_p99': 16.0,
    'placement_operations': 50.0,
  };

  // Coordinate accuracy thresholds
  const accuracyThresholds = {
    'max_roundtrip_error': 0.1, // pixels
    'max_boundary_error': 0.0, // pixels
  };

  try {
    // Run performance tests
    logMessage('📊 Running performance tests...');
    final perfResult = Process.runSync('flutter', [
      'test',
      'test/performance/game_canvas_performance_test.dart',
      '--reporter=json'
    ]);
    if (perfResult.exitCode != 0) {
      logError('Performance tests failed', perfResult.stderr);
      allPassed = false;
    } else {
      // Parse performance results (simplified - in real implementation, parse JSON output)
      results['performance_tests'] = 'passed';
      logSuccess('Performance tests passed');
    }

    // Run coordinate accuracy tests
    logMessage('🎯 Running coordinate accuracy tests...');
    final coordResult = Process.runSync('flutter', [
      'test',
      'test/coordinate_transformation_test.dart',
      '--reporter=json'
    ]);
    if (coordResult.exitCode != 0) {
      logError('Coordinate accuracy tests failed', coordResult.stderr);
      allPassed = false;
    } else {
      results['coordinate_tests'] = 'passed';
      logSuccess('Coordinate accuracy tests passed');
    }

    // Run legacy behavior tests
    logMessage('📜 Running legacy behavior tests...');
    final legacyResult = Process.runSync('flutter',
        ['test', 'test/coordinate_legacy_test.dart', '--reporter=json']);
    if (legacyResult.exitCode != 0) {
      logError('Legacy behavior tests failed', legacyResult.stderr);
      allPassed = false;
    } else {
      results['legacy_tests'] = 'passed';
      logSuccess('Legacy behavior tests passed');
    }

    // Check for inline coordinate violations
    logMessage('🔍 Checking for inline coordinate conversions...');
    final detectResult = Process.runSync(
        'dart', ['run', 'scripts/detect_inline_coordinates.dart']);
    if (detectResult.exitCode != 0) {
      logError('Inline coordinate violations detected', detectResult.stdout);
      allPassed = false;
    } else {
      results['inline_check'] = 'passed';
      logSuccess('No inline coordinate violations detected');
    }

    // Generate performance report
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'ci_run': true,
      'performance_budgets': performanceBudgets,
      'accuracy_thresholds': accuracyThresholds,
      'results': results,
      'overall_status': allPassed ? 'PASSED' : 'FAILED',
    };

    // Write report to file
    final reportFile = File('ci_performance_report.json');
    reportFile.writeAsStringSync(jsonEncode(report));

    logSuccess('Performance report saved to ci_performance_report.json');

    // Summary
    logMessage('\n📊 CI Performance Check Summary:');
    logMessage(
        'Performance Budgets: ${performanceBudgets.entries.map((e) => '${e.key}: ${e.value}ms').join(', ')}');
    logMessage(
        'Accuracy Thresholds: ${accuracyThresholds.entries.map((e) => '${e.key}: ${e.value}px').join(', ')}');
    final statusMessage = 'Overall Status: ${allPassed ? '✅ PASSED' : '❌ FAILED'}';
    if (allPassed) {
      logSuccess(statusMessage);
    } else {
      logError(statusMessage);
    }

    if (!allPassed) {
      logError('\n🔧 To fix failures:');
      logMessage(
          '1. Address performance regressions in test/performance/game_canvas_performance_test.dart');
      logMessage(
          '2. Fix coordinate accuracy issues in test/coordinate_transformation_test.dart');
      logMessage(
          '3. Remove inline coordinate conversions detected by scripts/detect_inline_coordinates.dart');
      logMessage(
          '4. Ensure legacy behavior is preserved in test/coordinate_legacy_test.dart');
      exit(1);
    }
  } catch (e) {
    logError('CI Performance Check failed with error', e);
    exit(1);
  }

  logSuccess('CI Performance Check completed successfully!');
}
