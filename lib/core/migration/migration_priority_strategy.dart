import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Migration priority strategy for game state notifier consolidation
class MigrationPriorityStrategy {
  static const int totalFiles = 50;

  /// Priority levels for migration
  static const String priorityLow = 'LOW';
  static const String priorityMedium = 'MEDIUM';
  static const String priorityHigh = 'HIGH';

  /// File categories by priority
  static const Map<String, List<String>> priorityCategories = {
    priorityLow: [
      'widgets',
      'presentation_components',
      'test_files',
      'pure_ui_components',
    ],
    priorityMedium: [
      'event_handlers',
      'controllers',
      'service_layer',
      'business_logic_with_modifications',
    ],
    priorityHigh: [
      'core_business_logic',
      'create_component_use_case',
      'state_modifiers',
      'critical_path_components',
    ],
  };

  /// Get migration priority for a file path
  static String getPriority(String filePath) {
    final lowerPath = filePath.toLowerCase();

    // High priority files
    if (_isHighPriority(lowerPath)) {
      return priorityHigh;
    }

    // Medium priority files
    if (_isMediumPriority(lowerPath)) {
      return priorityMedium;
    }

    // Default to low priority
    return priorityLow;
  }

  /// Check if file is high priority
  static bool _isHighPriority(String filePath) {
    return filePath.contains('use_case') ||
        filePath.contains('create_component') ||
        filePath.contains('core') ||
        filePath.contains('business_logic');
  }

  /// Check if file is medium priority
  static bool _isMediumPriority(String filePath) {
    return filePath.contains('controller') ||
        filePath.contains('service') ||
        filePath.contains('handler') ||
        filePath.contains('manager');
  }

  /// Get recommended migration order
  static List<String> getMigrationOrder() {
    return [
      ...priorityCategories[priorityHigh]!,
      ...priorityCategories[priorityMedium]!,
      ...priorityCategories[priorityLow]!,
    ];
  }

  /// Get migration batch information
  static Map<String, dynamic> getMigrationBatchInfo() {
    return {
      'total_files': totalFiles,
      'high_priority_count': (totalFiles * 0.2).round(), // 20%
      'medium_priority_count': (totalFiles * 0.5).round(), // 50%
      'low_priority_count': (totalFiles * 0.3).round(), // 30%
      'recommended_batches': [
        {
          'name': 'High Priority',
          'percentage': 20,
          'files': (totalFiles * 0.2).round()
        },
        {
          'name': 'Medium Priority',
          'percentage': 50,
          'files': (totalFiles * 0.5).round()
        },
        {
          'name': 'Low Priority',
          'percentage': 30,
          'files': (totalFiles * 0.3).round()
        },
      ],
    };
  }

  /// Validate migration readiness for a file
  static bool isReadyForMigration(String filePath, String currentPhase) {
    final priority = getPriority(filePath);

    switch (currentPhase) {
      case 'PHASE_1':
        return priority == priorityLow; // Only low priority in phase 1
      case 'PHASE_2':
        return priority == priorityLow ||
            priority == priorityMedium; // Low + medium
      case 'PHASE_3':
        return true; // All priorities in phase 3
      default:
        return false;
    }
  }

  /// Log migration strategy information
  static void logStrategyInfo() {
    StructuredLogger.info('Migration Priority Strategy', context: {
      'strategy': 'risk_based_priority',
      'total_files': totalFiles,
      'priority_distribution': getMigrationBatchInfo(),
      'migration_order': getMigrationOrder(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

/// Migration phase definitions
class MigrationPhase {
  static const String phase1 = 'PHASE_1'; // Foundation & low-risk files
  static const String phase2 = 'PHASE_2'; // Medium-risk files
  static const String phase3 = 'PHASE_3'; // High-risk & critical files

  static String getCurrentPhase(int migratedFiles) {
    final percentage =
        (migratedFiles / MigrationPriorityStrategy.totalFiles) * 100;

    if (percentage < 30) return phase1;
    if (percentage < 80) return phase2;
    return phase3;
  }

  static String getPhaseDescription(String phase) {
    switch (phase) {
      case phase1:
        return 'Foundation & Low-Risk Migration (Widgets, Tests, UI Components)';
      case phase2:
        return 'Medium-Risk Migration (Services, Controllers, Event Handlers)';
      case phase3:
        return 'High-Risk Migration (Core Business Logic, Use Cases, Critical Path)';
      default:
        return 'Unknown Phase';
    }
  }
}
