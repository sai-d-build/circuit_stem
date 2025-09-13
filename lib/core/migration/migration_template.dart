import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Migration template for game state notifier consolidation
/// This template shows the before/after pattern for migrating files
class MigrationTemplate {
  /// Template for migrating a file from old providers to unified provider
  static const String migrationTemplate = '''
// BEFORE MIGRATION
// =================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';

// Using old provider directly
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(gameEngineNotifierV3Provider.notifier); // ignore: cascade_invocations
    // OR
    final enhancedNotifier = ref.watch(enhancedGameStateNotifierProvider.notifier); // ignore: cascade_invocations

    return Container();
  }
}

// AFTER MIGRATION
// ================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';

// Using unified provider
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(unifiedGameStateProvider.notifier);

    // Mark file as migrated
    MigrationTracker.markFileMigrated(
      'lib/presentation/widgets/some_widget.dart',
      DateTime.now().toIso8601String()
    );

    return Container();
  }
}
''';

  /// Template for migrating use cases
  static const String useCaseMigrationTemplate = '''
// BEFORE MIGRATION
// =================

class CreateComponentUseCase extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  @override
  Future<Result<void>> executeWithNotifiers(
    CreateComponentFromTemplateAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    // Old pattern - checking both notifiers
    if (notifiers.grid is EnhancedGameStateNotifier) {
      await (notifiers.grid as EnhancedGameStateNotifier).placeComponent(type, row, col);
    } else if (notifiers.grid is GameEngineNotifierV3) {
      (notifiers.grid as GameEngineNotifierV3).placeComponent(type, row, col);
    }
  }
}

// AFTER MIGRATION
// ================

class CreateComponentUseCase extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  @override
  Future<Result<void>> executeWithNotifiers(
    CreateComponentFromTemplateAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    // New pattern - unified interface
    final notifier = notifiers.grid as IGameStateNotifier;

    await notifier.placeComponentAsync(
      ComponentType.values.firstWhere(
        (type) => type.name == action.templateId,
        orElse: () => ComponentType.resistor,
      ),
      action.row,
      action.col,
    );

    StructuredLogger.info('✅ CreateComponent: Used unified interface');

    // Mark file as migrated
    MigrationTracker.markFileMigrated(
      'lib/application/use_cases/create_component_use_case.dart',
      DateTime.now().toIso8601String()
    );

    return const Success(null);
  }
}
''';

  /// Template for migrating controllers
  static const String controllerMigrationTemplate = '''
// BEFORE MIGRATION
// =================

class ComponentPaletteController {
  void onComponentTap(ComponentType type) {
    final notifier = ref.read(gameEngineNotifierV3Provider.notifier);
    // ... existing logic
  }
}

// AFTER MIGRATION
// ================

class ComponentPaletteController {
  void onComponentTap(ComponentType type) {
    final notifier = ref.read(unifiedGameStateProvider.notifier);

    // Mark file as migrated
    MigrationTracker.markFileMigrated(
      'lib/presentation/controllers/component_palette_controller.dart',
      DateTime.now().toIso8601String()
    );

    // ... existing logic unchanged
  }
}
''';

  /// Get migration template for specific file type
  static String getTemplateForFileType(String filePath) {
    final lowerPath = filePath.toLowerCase();

    if (lowerPath.contains('use_case')) {
      return useCaseMigrationTemplate;
    } else if (lowerPath.contains('controller')) {
      return controllerMigrationTemplate;
    } else {
      return migrationTemplate;
    }
  }

  /// Validate migration for a file
  static bool validateMigration(String filePath, String content) {
    // Check if file uses old providers
    final usesOldProviders = content.contains('gameEngineNotifierV3Provider') ||
        content.contains('enhancedGameStateNotifierProvider');

    // Check if file uses new unified provider
    final usesUnifiedProvider = content.contains('unifiedGameStateProvider');

    // Check if migration tracking is added
    final hasMigrationTracking =
        content.contains('MigrationTracker.markFileMigrated');

    return !usesOldProviders && usesUnifiedProvider && hasMigrationTracking;
  }

  /// Generate migration checklist for a file
  static List<String> generateMigrationChecklist(String filePath) {
    return [
      '✅ Replace old provider imports with unified_providers.dart',
      '✅ Update provider references to use unifiedGameStateProvider',
      '✅ Add MigrationTracker.markFileMigrated() call',
      '✅ Update any type casts to use IGameStateNotifier',
      '✅ Test functionality with both Enhanced and V3 implementations',
      '✅ Verify no breaking changes in component behavior',
      '✅ Update related tests to use unified provider',
    ];
  }

  /// Log migration template usage
  static void logTemplateUsage(String filePath, String templateType) {
    StructuredLogger.info('Migration template applied', context: {
      'file': filePath,
      'template_type': templateType,
      'timestamp': DateTime.now().toIso8601String(),
      'checklist': generateMigrationChecklist(filePath),
    });
  }
}

/// Migration helper utilities
class MigrationHelper {
  /// Check if a file needs migration
  static bool needsMigration(String content) {
    return content.contains('gameEngineNotifierV3Provider') ||
        content.contains('enhancedGameStateNotifierProvider');
  }

  /// Get list of files that need migration
  static Future<List<String>> findFilesNeedingMigration() async {
    // This would scan the codebase for files using old providers
    // For now, return a placeholder list based on the consolidation plan
    return [
      'lib/application/use_cases/create_component_use_case.dart',
      'lib/presentation/features/game/widgets/circuit_grid.dart',
      'lib/presentation/features/game/controllers/canvas_interaction_controller.dart',
      'lib/core/services/component_action_service.dart',
      // ... more files from the consolidation plan
    ];
  }

  /// Generate migration report
  static Map<String, dynamic> generateMigrationReport(
      List<String> migratedFiles) {
    return {
      'total_files_migrated': migratedFiles.length,
      'migration_percentage': (migratedFiles.length / 50 * 100).round(),
      'remaining_files': 50 - migratedFiles.length,
      'migrated_files': migratedFiles,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
