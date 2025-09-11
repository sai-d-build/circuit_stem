import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Tracks migration progress for game state notifier consolidation
class MigrationTracker {
  static final Set<String> _migratedFiles = {};
  static final Map<String, String> _migrationLog = {};

  static void markFileMigrated(String filePath, String timestamp) {
    _migratedFiles.add(filePath);
    _migrationLog[filePath] = timestamp;

    StructuredLogger.info('File migrated to unified provider', context: {
      'file': filePath,
      'timestamp': timestamp,
      'totalMigrated': _migratedFiles.length,
      'migrationPercentage': (_migratedFiles.length / 50 * 100).toInt(),
    });
  }

  static MigrationStatus get status {
    final totalFiles = _getTotalDartFiles();
    return MigrationStatus(
      totalFiles: totalFiles,
      migratedFiles: _migratedFiles.length,
      remainingFiles: totalFiles - _migratedFiles.length,
      percentage: totalFiles > 0 ? (_migratedFiles.length / totalFiles * 100).toInt() : 0,
    );
  }

  /// Get the actual completion percentage based on current migration state
  static int get actualCompletionPercentage {
    final totalFiles = _getTotalDartFiles();
    return totalFiles > 0 ? (_migratedFiles.length / totalFiles * 100).toInt() : 0;
  }

  /// Get the number of files that are actually migrated
  static int get actualMigratedFiles {
    return _migratedFiles.length;
  }

  /// Dynamically count total Dart files in lib/
  static int _getTotalDartFiles() {
    // This would ideally use file system access, but for now we'll use a reasonable estimate
    // In a real implementation, this would scan the lib/ directory
    return 354; // Keeping the known count for now
  }

  static bool isFileMigrated(String filePath) => _migratedFiles.contains(filePath);

  static List<String> getMigratedFiles() => _migratedFiles.toList();

  static Map<String, String> getMigrationLog() => Map.from(_migrationLog);
}

/// Migration status data class
class MigrationStatus {
  final int totalFiles;
  final int migratedFiles;
  final int remainingFiles;
  final int percentage;

  const MigrationStatus({
    required this.totalFiles,
    required this.migratedFiles,
    required this.remainingFiles,
    required this.percentage,
  });

  Map<String, dynamic> toJson() => {
    'totalFiles': totalFiles,
    'migratedFiles': migratedFiles,
    'remainingFiles': remainingFiles,
    'percentage': percentage,
  };

  @override
  String toString() =>
    'MigrationStatus(total: $totalFiles, migrated: $migratedFiles, remaining: $remainingFiles, percentage: $percentage%)';
}