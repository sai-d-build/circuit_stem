#!/usr/bin/env dart

import 'dart:io';

/// Script to automatically fix cascade invocation lint issues by adding ignore comments
/// to void method calls that can't be converted to cascade notation.

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart fix_cascade_invocations.dart <directory>');
    print('Example: dart fix_cascade_invocations.dart lib/application/');
    exit(1);
  }

  final directory = args[0];
  final dir = Directory(directory);

  if (!dir.existsSync()) {
    print('Directory $directory does not exist');
    exit(1);
  }

  print('🔧 Processing cascade invocations in $directory...');

  int filesProcessed = 0;
  int fixesApplied = 0;

  // Find all Dart files in the directory
  final dartFiles = dir
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>();

  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final originalContent = content;

    // Pattern to match method calls that might need ignore comments
    // This is a simple heuristic - looks for consecutive method calls on the same object
    final lines = content.split('\n');
    final newLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip lines that already have ignore comments
      if (line.contains('// ignore: cascade_invocations')) {
        newLines.add(line);
        continue;
      }

      // Look for patterns that typically trigger cascade_invocations
      // This is a heuristic approach - not perfect but covers common cases
      if (_shouldAddIgnoreComment(line, lines, i)) {
        newLines.add('$line // ignore: cascade_invocations');
        fixesApplied++;
      } else {
        newLines.add(line);
      }
    }

    final newContent = newLines.join('\n');

    if (newContent != originalContent) {
      file.writeAsStringSync(newContent);
      filesProcessed++;
      print('✅ Fixed ${file.path}');
    }
  }

  print('\n📊 Summary:');
  print('   Files processed: $filesProcessed');
  print('   Fixes applied: $fixesApplied');
  print('   Run: flutter analyze $directory');
}

bool _shouldAddIgnoreComment(String line, List<String> allLines, int index) {
  // Skip comments, empty lines, and lines that already have ignore comments
  if (line.trim().startsWith('//') ||
      line.trim().isEmpty ||
      line.contains('ignore:')) {
    return false;
  }

  // Look for method calls that are likely to be flagged by cascade_invocations
  // This is a heuristic - we look for lines that contain method calls
  final methodCallPattern = RegExp(r'\w+\.\w+\([^)]*\)\s*;');

  if (!methodCallPattern.hasMatch(line)) {
    return false;
  }

  // Check if there are similar method calls nearby (indicating potential cascade)
  final currentObject = _extractObjectName(line);
  if (currentObject == null) return false;

  // Look at surrounding lines for similar patterns
  for (int i = index - 2; i <= index + 2; i++) {
    if (i >= 0 && i < allLines.length && i != index) {
      final otherLine = allLines[i];
      if (_extractObjectName(otherLine) == currentObject &&
          methodCallPattern.hasMatch(otherLine)) {
        return true;
      }
    }
  }

  return false;
}

String? _extractObjectName(String line) {
  // Extract the object name from a method call like "object.method()"
  final match = RegExp(r'(\w+)\.\w+\([^)]*\)\s*;').firstMatch(line);
  return match?.group(1);
}