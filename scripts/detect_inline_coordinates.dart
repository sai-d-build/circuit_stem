#!/usr/bin/env dart

/// Script to detect inline coordinate conversions that should use UnifiedCoordinateService
/// This helps enforce the single source of truth principle during refactoring

import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('Error: lib directory not found. Run from project root.');
    exit(1);
  }

  print('🔍 Scanning for inline coordinate conversions...');

  final violations = <String>[];

  // Patterns to detect inline coordinate math
  final patterns = [
    RegExp(r'\.dx\s*[\+\-\*\/]\s*[\d\.]+'), // x coordinate math
    RegExp(r'\.dy\s*[\+\-\*\/]\s*[\d\.]+'), // y coordinate math
    RegExp(
        r'Offset\(\s*[\w\.]+\s*[\+\-\*\/]\s*[\d\.]+\s*,'), // Offset construction with math
    RegExp(r'cellSize\s*[\*\/]\s*[\w\.]+'), // Cell size calculations
    RegExp(r'panOffset\s*[\+\-]\s*[\w\.]+'), // Pan offset calculations
    RegExp(r'scale\s*[\*\/]\s*[\w\.]+'), // Scale calculations
  ];

  // Files to exclude (known legitimate uses)
  final excludePatterns = [
    'unified_coordinate_service.dart',
    'grid_service.dart',
    'coordinate_service.dart',
    'coordinate_system_service.dart',
    'coordinate_translator.dart',
    'test/',
  ];

  void scanDirectory(Directory dir, String relativePath) {
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final filePath = path.relative(entity.path);

        // Skip excluded files
        if (excludePatterns.any(filePath.contains)) {
          continue;
        }

        final content = entity.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final lineNumber = i + 1;

          for (final pattern in patterns) {
            if (pattern.hasMatch(line)) {
              // Skip if line contains legitimate uses
              if (line.contains('UnifiedCoordinateService') ||
                  line.contains('GridService.screenToGrid') ||
                  line.contains('GridService.gridToScreen') ||
                  line.contains('CoordinateService') ||
                  line.contains('// ignore') ||
                  line.contains('test') ||
                  line.contains('mock')) {
                continue;
              }

              violations.add('$filePath:$lineNumber: $line.trim()');
              break; // Only report once per line
            }
          }
        }
      } else if (entity is Directory) {
        scanDirectory(
            entity, path.join(relativePath, path.basename(entity.path)));
      }
    }
  }

  scanDirectory(libDir, '');

  if (violations.isEmpty) {
    print('✅ No inline coordinate conversions detected!');
    print('All coordinate operations properly use UnifiedCoordinateService.');
  } else {
    print(
        '❌ Found ${violations.length} potential inline coordinate conversions:');
    print('');
    for (final violation in violations.take(20)) {
      // Limit output
      print('  $violation');
    }
    if (violations.length > 20) {
      print('  ... and ${violations.length - 20} more');
    }
    print('');
    print(
        '💡 Recommendation: Replace inline math with UnifiedCoordinateService calls');
    print(
        '   Example: Instead of `offset.dx * cellSize`, use `unifiedService.screenToGrid(offset, config)`');
    exit(1);
  }
}
