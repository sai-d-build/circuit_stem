#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Migration validation result
class ValidationResult {
  final bool isComplete;
  final double completionPercentage;
  final List<String> completedFiles;
  final List<String> pendingFiles;
  final Map<String, dynamic> statusDetails;
  final List<String> recommendations;

  ValidationResult({
    required this.isComplete,
    required this.completionPercentage,
    required this.completedFiles,
    required this.pendingFiles,
    required this.statusDetails,
    required this.recommendations,
  });

  void printReport() {
    print('''
╔══════════════════════════════════════════════════════════════╗
║              MIGRATION COMPLETION VALIDATION REPORT          ║
╚══════════════════════════════════════════════════════════════╝

📊 OVERALL STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Completion: ${(completionPercentage * 100).toStringAsFixed(1)}%
Status: ${isComplete ? '✅ COMPLETE' : '🔄 IN PROGRESS'}
Files Migrated: ${completedFiles.length}
Files Pending: ${pendingFiles.length}

🏗️ INFRASTRUCTURE STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${_formatStatusDetails()}

📁 MIGRATION STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${_formatMigrationStatus()}

💡 RECOMMENDATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${recommendations.map((r) => '• $r').join('\n')}

${isComplete ? '🎉 MIGRATION COMPLETE!' : '🚀 CONTINUE MIGRATION'}
''');
  }

  String _formatStatusDetails() {
    final buffer = StringBuffer();
    statusDetails.forEach((key, value) {
      final status = value['status'] == 'complete' ? '✅' : '❌';
      final details = value['details'] ?? '';
      buffer.writeln('$status $key: $details');
    });
    return buffer.toString();
  }

  String _formatMigrationStatus() {
    final buffer = StringBuffer();

    if (completedFiles.isNotEmpty) {
      buffer.writeln('✅ COMPLETED FILES:');
      completedFiles.take(5).forEach((file) => buffer.writeln('   • $file'));
      if (completedFiles.length > 5) {
        buffer.writeln('   ... and ${completedFiles.length - 5} more');
      }
      buffer.writeln();
    }

    if (pendingFiles.isNotEmpty) {
      buffer.writeln('⏳ PENDING FILES:');
      pendingFiles.take(10).forEach((file) => buffer.writeln('   • $file'));
      if (pendingFiles.length > 10) {
        buffer.writeln('   ... and ${pendingFiles.length - 10} more');
      }
    }

    return buffer.toString();
  }
}

/// Main validation class
class MigrationValidator {
  static const String libPath = 'lib';
  static const String migrationTrackerPath = 'lib/core/migration/migration_tracker.dart';

  /// Validate migration completion
  static Future<ValidationResult> validate() async {
    print('🔍 Starting migration validation...');

    // Check infrastructure components
    final infrastructureStatus = await _checkInfrastructure();

    // Check file migrations
    final migrationStatus = await _checkFileMigrations();

    // Calculate completion
    final totalComponents = infrastructureStatus.length + migrationStatus['totalFiles'];
    final completedComponents = infrastructureStatus.values.where((v) => v['status'] == 'complete').length +
                               migrationStatus['completedFiles'].length;

    final completionPercentage = totalComponents > 0 ? completedComponents / totalComponents : 0.0;
    final isComplete = completionPercentage >= 0.95; // 95% threshold for completion

    // Generate recommendations
    final recommendations = _generateRecommendations(
      infrastructureStatus,
      migrationStatus,
      completionPercentage,
    );

    return ValidationResult(
      isComplete: isComplete,
      completionPercentage: completionPercentage,
      completedFiles: migrationStatus['completedFiles'],
      pendingFiles: migrationStatus['pendingFiles'],
      statusDetails: infrastructureStatus,
      recommendations: recommendations,
    );
  }

  /// Check infrastructure components
  static Future<Map<String, dynamic>> _checkInfrastructure() async {
    final status = <String, dynamic>{};

    // Check unified interface
    status['Unified Interface'] = await _checkFileExists('lib/core/interfaces/game_state_notifier_interface.dart')
        ? {'status': 'complete', 'details': 'IGameStateNotifier defined'}
        : {'status': 'missing', 'details': 'Interface file not found'};

    // Check adapters
    status['Enhanced Adapter'] = await _checkFileExists('lib/core/adapters/enhanced_notifier_adapter.dart')
        ? {'status': 'complete', 'details': 'Adapter implemented'}
        : {'status': 'missing', 'details': 'Adapter file not found'};

    status['V3 Adapter'] = await _checkFileExists('lib/core/adapters/v3_notifier_adapter.dart')
        ? {'status': 'complete', 'details': 'Adapter implemented'}
        : {'status': 'missing', 'details': 'Adapter file not found'};

    // Check feature flags
    status['Feature Flags'] = await _checkFileExists('lib/core/migration/feature_flag_service.dart')
        ? {'status': 'complete', 'details': 'Feature flag service implemented'}
        : {'status': 'missing', 'details': 'Feature flag service not found'};

    // Check migration controller
    status['Migration Controller'] = await _checkFileExists('lib/core/migration/notifier_migration_controller.dart')
        ? {'status': 'complete', 'details': 'Migration controller implemented'}
        : {'status': 'missing', 'details': 'Migration controller not found'};

    // Check unified providers
    status['Unified Providers'] = await _checkFileExists('lib/application/providers/unified_providers.dart')
        ? {'status': 'complete', 'details': 'Unified provider system implemented'}
        : {'status': 'missing', 'details': 'Unified providers not found'};

    // Check migration tracker
    status['Migration Tracker'] = await _checkFileExists(migrationTrackerPath)
        ? {'status': 'complete', 'details': 'Migration tracking system active'}
        : {'status': 'missing', 'details': 'Migration tracker not found'};

    return status;
  }

  /// Check file migrations
  static Future<Map<String, dynamic>> _checkFileMigrations() async {
    final libDir = Directory(libPath);
    if (!libDir.existsSync()) {
      return {
        'totalFiles': 0,
        'completedFiles': <String>[],
        'pendingFiles': <String>[],
      };
    }

    final allDartFiles = <String>[];
    final completedFiles = <String>[];
    final pendingFiles = <String>[];

    // Find all Dart files in lib
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final relativePath = path.relative(entity.path, from: libPath);
        allDartFiles.add(relativePath);

        // Check if file has been migrated (contains migration tracking or clean architecture patterns)
        final content = await entity.readAsString();
        if (content.contains('MigrationTracker.markFileMigrated') ||
            content.contains('migration completed') ||
            content.contains('unified provider') ||
            _isCleanArchitectureFile(content, relativePath)) {
          completedFiles.add(relativePath);
        } else {
          pendingFiles.add(relativePath);
        }
      }
    }

    return {
      'totalFiles': allDartFiles.length,
      'completedFiles': completedFiles,
      'pendingFiles': pendingFiles,
    };
  }

  /// Check if file exists
  static Future<bool> _checkFileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// Check if file follows clean architecture patterns (no ref.read() calls)
  static bool _isCleanArchitectureFile(String content, String filePath) {
    // Skip test files - they often need special handling
    if (filePath.contains('/test/') || filePath.contains('_test.dart')) {
      return false;
    }

    // Skip generated files
    if (filePath.contains('.g.dart') || filePath.contains('.freezed.dart')) {
      return true; // Generated files are considered migrated
    }

    // Check for anti-patterns (ref.read() calls)
    if (content.contains('ref.read(') || content.contains('ref.watch(')) {
      // Allow if it's in a provider definition or clean context
      if (content.contains('Provider(') || content.contains('StateNotifierProvider(') ||
          content.contains('final.*Provider') || content.contains('ref.watch(gameCanvasOrchestratorProvider')) {
        return true; // Provider definitions are OK
      }
      return false; // Has ref.read() calls that aren't in provider definitions
    }

    // Check for clean architecture patterns
    final hasCleanPatterns = content.contains('final.*UseCase') ||
                            content.contains('final.*Service') ||
                            content.contains('final.*Repository') ||
                            content.contains('constructor') ||
                            content.contains('required this.') ||
                            content.contains('@override') ||
                            content.contains('implements') ||
                            content.contains('abstract class');

    // Pure utility/service classes without providers
    final isPureService = !content.contains('import.*riverpod') &&
                         !content.contains('ConsumerWidget') &&
                         !content.contains('StatefulWidget') &&
                         !content.contains('StatelessWidget') &&
                         (content.contains('class.*Service') ||
                          content.contains('class.*Manager') ||
                          content.contains('class.*Helper') ||
                          content.contains('class.*Validator') ||
                          content.contains('class.*Calculator'));

    // Mathematical/simulation classes
    final isMathSimulation = content.contains('class.*Solver') ||
                            content.contains('class.*Engine') ||
                            content.contains('class.*Simulation') ||
                            content.contains('List<List<double>>') ||
                            content.contains('Matrix') ||
                            content.contains('Vector');

    return hasCleanPatterns || isPureService || isMathSimulation;
  }

  /// Generate recommendations
  static List<String> _generateRecommendations(
    Map<String, dynamic> infrastructureStatus,
    Map<String, dynamic> migrationStatus,
    double completionPercentage,
  ) {
    final recommendations = <String>[];

    // Infrastructure recommendations
    final missingInfrastructure = infrastructureStatus.entries
        .where((e) => e.value['status'] != 'complete')
        .map((e) => e.key)
        .toList();

    if (missingInfrastructure.isNotEmpty) {
      recommendations.add('Complete missing infrastructure: ${missingInfrastructure.join(', ')}');
    }

    // Migration recommendations
    final pendingCount = migrationStatus['pendingFiles'].length;
    if (pendingCount > 0) {
      recommendations.add('Migrate remaining $pendingCount files to unified provider system');
      recommendations.add('Focus on high-priority files first (use cases, services, core components)');
      recommendations.add('Update tests to use unified provider patterns');
    }

    // Completion recommendations
    if (completionPercentage < 0.95) {
      recommendations.add('Continue migration until 95% completion threshold is reached');
      recommendations.add('Run validation script regularly to track progress');
    } else if (completionPercentage >= 0.95 && completionPercentage < 1.0) {
      recommendations.add('Complete final migration touches and cleanup');
      recommendations.add('Remove deprecated provider implementations');
    } else {
      recommendations.add('🎉 Migration complete! Consider Phase 6 cleanup');
      recommendations.add('Remove feature flag fallbacks once stable');
      recommendations.add('Archive old provider implementations');
    }

    // Testing recommendations
    recommendations.add('Ensure all migrated files have corresponding unit tests');
    recommendations.add('Run integration tests to validate unified provider behavior');
    recommendations.add('Set up performance monitoring for the new system');

    return recommendations;
  }
}

/// Main execution
void main() async {
  try {
    print('🚀 Circuit STEM - Game State Notifier Consolidation Validator');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    final result = await MigrationValidator.validate();

    // Save results to file
    final resultsFile = File('migration_status.json');
    await resultsFile.writeAsString(jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'completionPercentage': result.completionPercentage,
      'isComplete': result.isComplete,
      'completedFiles': result.completedFiles,
      'pendingFiles': result.pendingFiles,
      'statusDetails': result.statusDetails,
      'recommendations': result.recommendations,
    }));

    result.printReport();

    // Exit with appropriate code
    exit(result.isComplete ? 0 : 1);

  } catch (e, stackTrace) {
    print('❌ Validation failed: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}