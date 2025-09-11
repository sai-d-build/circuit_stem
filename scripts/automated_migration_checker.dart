#!/usr/bin/env dart
import 'dart:io';

/// Automated Migration Status Checker
/// Provides real-time metrics for Game State Notifier Consolidation
class AutomatedMigrationChecker {
  static const String libPath = 'lib';

  /// Main analysis function
  static Future<MigrationReport> analyze() async {
    print('🔍 Starting Automated Migration Analysis...\n');

    final report = MigrationReport();

    // File counts
    report.totalDartFiles = await _countDartFiles();
    report.migratedFiles = await _countMigratedFiles();
    report.filesUsingUnifiedProvider = await _countUnifiedProviderUsage();
    report.filesUsingOldProviders = await _countOldProviderUsage();

    // Code quality metrics
    report.totalRefReadCalls = await _countRefReadCalls();
    report.businessLogicViolations = await _countBusinessLogicViolations();
    report.presentationLayerRefReads = await _countPresentationRefReads();
    report.providerFactoryRefReads = await _countProviderFactoryRefReads();

    // Flutter analyze
    report.flutterAnalyzeIssues = await _runFlutterAnalyze();

    // Calculate percentages
    report.migrationPercentage = report.totalDartFiles > 0
        ? (report.migratedFiles / report.totalDartFiles * 100).round()
        : 0;

    report.violationPercentage = report.businessLogicViolations > 0
        ? (report.businessLogicViolations / report.totalRefReadCalls * 100).round()
        : 0;

    return report;
  }

  /// Count total Dart files in lib/
  static Future<int> _countDartFiles() async {
    final result = await Process.run('find', [libPath, '-name', '*.dart', '-type', 'f']);
    if (result.exitCode == 0) {
      final files = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      return files.length;
    }
    return 0;
  }

  /// Count files with migration tracking
  static Future<int> _countMigratedFiles() async {
    final result = await Process.run('grep', ['-r', 'MigrationTracker.markFileMigrated', libPath, '--include=*.dart']);
    if (result.exitCode == 0) {
      final matches = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      return matches.length;
    }
    return 0;
  }

  /// Count files using unified provider
  static Future<int> _countUnifiedProviderUsage() async {
    final result = await Process.run('grep', ['-r', 'unifiedGameStateProvider', libPath, '--include=*.dart']);
    if (result.exitCode == 0) {
      final matches = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      // Filter out test files and provider definitions
      final filtered = matches.where((match) =>
          !match.contains('/test/') &&
          !match.contains('/providers/') &&
          !match.contains('test_providers.dart'));
      return filtered.length;
    }
    return 0;
  }

  /// Count files using old providers
  static Future<int> _countOldProviderUsage() async {
    final result = await Process.run('grep', ['-r', 'gameEngineV1Provider\\|gameEngineV3Provider\\|enhancedGameStateNotifierProvider', libPath, '--include=*.dart']);
    if (result.exitCode == 0) {
      final matches = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      // Filter out provider definitions themselves
      final filtered = matches.where((match) => !match.contains('/providers/'));
      return filtered.length;
    }
    return 0;
  }

  /// Count total ref.read() calls
  static Future<int> _countRefReadCalls() async {
    final result = await Process.run('grep', ['-r', 'ref\\.read(', libPath, '--include=*.dart']);
    if (result.exitCode == 0) {
      final matches = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      // Filter out test files
      final filtered = matches.where((match) => !match.contains('/test/'));
      return filtered.length;
    }
    return 0;
  }

  /// Count ref.read() violations in business logic (only actual violations, not acceptable usage)
  static Future<int> _countBusinessLogicViolations() async {
    final violations = await analyzeRefReadViolations();
    // Count only critical violations
    return violations.where((v) => v.severity == ViolationSeverity.critical).length;
  }

  /// Count acceptable ref.read() in presentation layer
  static Future<int> _countPresentationRefReads() async {
    final result = await Process.run('grep', ['-r', 'ref\\.read(', '$libPath/presentation/', '--include=*.dart']);
    if (result.exitCode == 0) {
      final matches = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      // Filter out test files
      final filtered = matches.where((match) => !match.contains('/test/'));
      return filtered.length;
    }
    return 0;
  }

  /// Count ref.read() in provider factories (acceptable)
  static Future<int> _countProviderFactoryRefReads() async {
    final result = await Process.run('grep', ['-r', 'ref\\.read(', '$libPath/application/providers/', '--include=*.dart']);
    if (result.exitCode == 0) {
      final matches = result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty);
      return matches.length;
    }
    return 0;
  }

  /// Run Flutter analyze and count issues
  static Future<int> _runFlutterAnalyze() async {
    final result = await Process.run('flutter', ['analyze', '--no-pub']);
    if (result.exitCode == 0) {
      final output = result.stdout.toString() + result.stderr.toString();
      final issues = output.split('\n').where((line) =>
          line.contains('error •') ||
          line.contains('warning •') ||
          line.contains('info •'));
      return issues.length;
    }
    return 0;
  }

  /// Generate detailed violation report
  static Future<List<RefReadViolation>> analyzeRefReadViolations() async {
    final violations = <RefReadViolation>[];

    // Check business logic violations
    final businessLogicResult = await Process.run('grep', ['-rn', 'ref\\.read(', '$libPath/application/', '$libPath/core/', '$libPath/domain/', '--include=*.dart']);

    if (businessLogicResult.exitCode == 0) {
      final lines = businessLogicResult.stdout.toString().trim().split('\n');
      for (final line in lines) {
        if (line.isNotEmpty && !line.contains('/test/')) {
          final parts = line.split(':');
          if (parts.length >= 3) {
            final filePath = parts[0];
            final lineNumber = int.tryParse(parts[1]) ?? 0;
            final code = parts.sublist(2).join(':').trim();

            violations.add(RefReadViolation(
              filePath: filePath,
              lineNumber: lineNumber,
              code: code,
              severity: _determineSeverity(filePath, code),
              recommendation: _generateRecommendation(filePath, code),
            ));
          }
        }
      }
    }

    return violations;
  }

  /// Determine severity of violation
  static ViolationSeverity _determineSeverity(String filePath, String code) {
    // Provider factories are acceptable (check for various provider patterns)
    if (filePath.contains('/providers/') ||
        code.contains('Provider.family') ||
        code.contains('StateNotifierProvider') ||
        code.contains('FutureProvider') ||
        code.contains('final ') && code.contains('Provider') ||
        code.contains('Provider(') ||
        (code.contains('ref.read(') && code.contains('return ')) ||
        (code.contains('ref.read(') && code.contains(':')) || // Constructor parameter assignment
        (code.contains('ref.read(') && filePath.contains('use_cases') && code.contains('InteractionUseCaseInjected'))) {
      return ViolationSeverity.acceptable;
    }

    // Comments mentioning ref.read() are acceptable
    if (code.trim().startsWith('//') && code.contains('ref.read(')) {
      return ViolationSeverity.acceptable;
    }

    // Business logic violations are critical
    if ((filePath.contains('/application/') || filePath.contains('/core/') || filePath.contains('/domain/'))
        && !code.contains('Provider.family') && !code.contains('StateNotifierProvider')) {
      return ViolationSeverity.critical;
    }

    // Presentation layer is generally acceptable
    if (filePath.contains('/presentation/')) {
      return ViolationSeverity.acceptable;
    }

    return ViolationSeverity.warning;
  }

  /// Generate recommendation for violation
  static String _generateRecommendation(String filePath, String code) {
    if (filePath.contains('/providers/')) {
      return 'ACCEPTABLE: Provider factory - ref.read() is correct pattern here';
    }

    if (filePath.contains('/presentation/')) {
      return 'ACCEPTABLE: Presentation layer - one-time service access';
    }

    if (filePath.contains('/application/') || filePath.contains('/core/') || filePath.contains('/domain/')) {
      return 'VIOLATION: Use constructor injection instead of ref.read()';
    }

    return 'REVIEW: Check if this usage follows clean architecture';
  }
}

/// Migration report data class
class MigrationReport {
  int totalDartFiles = 0;
  int migratedFiles = 0;
  int filesUsingUnifiedProvider = 0;
  int filesUsingOldProviders = 0;
  int totalRefReadCalls = 0;
  int businessLogicViolations = 0;
  int presentationLayerRefReads = 0;
  int providerFactoryRefReads = 0;
  int flutterAnalyzeIssues = 0;
  int migrationPercentage = 0;
  int violationPercentage = 0;

  void printReport() {
    print('📊 AUTOMATED MIGRATION REPORT');
    print('=' * 50);
    print('📁 File Statistics:');
    print('  Total Dart files: $totalDartFiles');
    print('  Migrated files: $migratedFiles');
    print('  Migration completion: $migrationPercentage%');
    print('');
    print('🏗️ Provider Usage:');
    print('  Files using unified provider: $filesUsingUnifiedProvider');
    print('  Files using old providers: $filesUsingOldProviders');
    print('');
    print('🔍 ref.read() Analysis:');
    print('  Total ref.read() calls: $totalRefReadCalls');
    print('  Business logic violations: $businessLogicViolations ⚠️');
    print('  Presentation layer (acceptable): $presentationLayerRefReads ✅');
    print('  Provider factories (acceptable): $providerFactoryRefReads ✅');
    print('  Violation rate: $violationPercentage%');
    print('');
    print('⚡ Code Quality:');
    print('  Flutter analyze issues: $flutterAnalyzeIssues');
    print('');
    print('🎯 Summary:');
    final remainingFiles = totalDartFiles - migratedFiles;
    print('  Files remaining to migrate: $remainingFiles');
    print('  Critical violations to fix: $businessLogicViolations');
  }
}

/// ref.read() violation data class
class RefReadViolation {
  final String filePath;
  final int lineNumber;
  final String code;
  final ViolationSeverity severity;
  final String recommendation;

  RefReadViolation({
    required this.filePath,
    required this.lineNumber,
    required this.code,
    required this.severity,
    required this.recommendation,
  });

  @override
  String toString() {
    final severityIcon = severity == ViolationSeverity.critical ? '🚨' :
                        severity == ViolationSeverity.warning ? '⚠️' : '✅';
    return '$severityIcon $filePath:$lineNumber\n    $code\n    $recommendation\n';
  }
}

/// Violation severity levels
enum ViolationSeverity {
  acceptable,
  warning,
  critical,
}

/// Main execution
void main() async {
  try {
    print('🚀 Automated Migration Checker Starting...\n');

    // Generate main report
    final report = await AutomatedMigrationChecker.analyze();
    report.printReport();

    print('\n' + '=' * 50);
    print('🔍 DETAILED VIOLATION ANALYSIS');
    print('=' * 50);

    // Generate detailed violation report
    final violations = await AutomatedMigrationChecker.analyzeRefReadViolations();

    if (violations.isEmpty) {
      print('✅ No ref.read() violations found!');
    } else {
      print('Found ${violations.length} ref.read() instances to analyze:\n');

      // Group by severity
      final critical = violations.where((v) => v.severity == ViolationSeverity.critical);
      final warnings = violations.where((v) => v.severity == ViolationSeverity.warning);
      final acceptable = violations.where((v) => v.severity == ViolationSeverity.acceptable);

      if (critical.isNotEmpty) {
        print('🚨 CRITICAL VIOLATIONS (${critical.length}):');
        for (final violation in critical) {
          print(violation);
        }
      }

      if (warnings.isNotEmpty) {
        print('⚠️ WARNINGS (${warnings.length}):');
        for (final violation in warnings) {
          print(violation);
        }
      }

      if (acceptable.isNotEmpty) {
        print('✅ ACCEPTABLE USAGE (${acceptable.length}):');
        for (final violation in acceptable.take(5)) { // Show first 5
          print(violation);
        }
        if (acceptable.length > 5) {
          print('    ... and ${acceptable.length - 5} more acceptable instances');
        }
      }
    }

    print('\n🎯 RECOMMENDATIONS:');
    print('1. Fix ${report.businessLogicViolations} critical violations in business logic');
    print('2. Migrate ${report.totalDartFiles - report.migratedFiles} remaining files');
    print('3. Update migration tracker with accurate counts');
    print('4. Implement automated validation in CI/CD');

  } catch (e) {
    print('❌ Error running automated checker: $e');
    exit(1);
  }
}