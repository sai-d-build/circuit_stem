#!/usr/bin/env dart

/// Script to check for inline coordinate conversions outside authorized services
/// This enforces the single source of truth principle for coordinate transformations

import 'dart:io';
import 'package:path/path.dart' as path;

// Enhanced logging for development scripts
void logMessage(String message) {
  final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
  print('[$timestamp] $message');
}

void logError(String message) {
  final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
  stderr.writeln('[$timestamp] ❌ $message');
}

void logSuccess(String message) {
  final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
  print('[$timestamp] ✅ $message');
}

void main() {
  logMessage('🔍 Checking for inline coordinate conversions...');

  final libDir = Directory('lib');
  final violations = <String>[];

  // Authorized coordinate conversion services
  final authorizedFiles = [
    'lib/core/services/unified_coordinate_service.dart',
    'lib/core/services/coordinate_service.dart',
    'lib/core/services/grid_service.dart',
    'lib/core/services/coordinate_system_service.dart', // Delegates to unified
  ];

  // Patterns that indicate inline coordinate conversions
  final conversionPatterns = [
    RegExp(r'screenToGrid\s*\('),
    RegExp(r'gridToScreen\s*\('),
    RegExp(r'snapToGrid\s*\('),
    RegExp(r'getValidGridPosition\s*\('),
    RegExp(r'isWithinGridBounds\s*\('),
  ];

  // Files to exclude from checking
  final excludePatterns = [
    RegExp(r'test/.*'),
    RegExp(r'.*_test\.dart$'),
    RegExp(r'lib/core/services/unified_coordinate_service\.dart'),
    RegExp(r'lib/core/services/coordinate_service\.dart'),
    RegExp(r'lib/core/services/grid_service\.dart'),
    RegExp(r'lib/core/services/coordinate_system_service\.dart'),
  ];

  if (!libDir.existsSync()) {
    logError('lib directory not found');
    exit(1);
  }

  // Recursively scan all Dart files
  for (final file in libDir.listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.dart')) continue;

    final relativePath = path.relative(file.path);

    // Skip excluded files
    if (excludePatterns.any((pattern) => pattern.hasMatch(relativePath))) {
      continue;
    }

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      for (final pattern in conversionPatterns) {
        if (pattern.hasMatch(line)) {
          // Check if this is calling an authorized service
          final isAuthorizedCall = authorizedFiles.any((authFile) =>
              line.contains('UnifiedCoordinateService') ||
              line.contains('GridService') ||
              line.contains('CoordinateService') ||
              line.contains('CoordinateSystemService'));

          if (!isAuthorizedCall) {
            violations.add('$relativePath:${i + 1}: $line'.trim());
          }
        }
      }
    }
  }

  if (violations.isEmpty) {
    logSuccess('No inline coordinate conversions found outside authorized services');
    exit(0);
  } else {
    logError('Found ${violations.length} inline coordinate conversion violations:');
    logMessage('');
    for (final violation in violations) {
      logMessage('  $violation');
    }
    logMessage('');
    logMessage('💡 All coordinate conversions should use:');
    logMessage('  - UnifiedCoordinateService for direct conversions');
    logMessage('  - GridService for static utility methods');
    logMessage('  - CoordinateService for controller-scoped conversions');
    logMessage('');
    logMessage(
        '🔧 To fix violations, replace inline conversions with calls to authorized services');
    exit(1);
  }
}
