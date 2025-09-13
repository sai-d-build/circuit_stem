import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../common/assets.dart';
import '../../common/logger.dart';
import '../rendering/asset_manager.dart';
import 'level_manager_state.dart';

/// Notifier for managing level state, including loading, progress, and persistence.
class LevelManagerNotifier extends StateNotifier<LevelManagerState> {
  final SharedPreferences _sharedPrefs;
  final AssetManagerNotifier _assetManager;

  static const String _prefsKeyCompletedLevels = 'completed_levels';

  LevelManagerNotifier(this._sharedPrefs, this._assetManager)
      : super(const LevelManagerState());

  /// Initializes the manager by loading the manifest and user progress.
  Future<void> init() async {
    Logger.log('LevelManagerNotifier: init');
    await _loadManifest();
  }

  /// Exposes the raw state for testing purposes.
  @visibleForTesting
  @override
  LevelManagerState get debugState => state;

  /// Loads the level manifest and user progress from storage.
  Future<void> _loadManifest() async {
    Logger.log('LevelManagerNotifier: _loadManifest START');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final manifestString =
          await _assetManager.loadString(AppAssets.levelManifest);
      Logger.log(
          'LevelManagerNotifier: Manifest string loaded: $manifestString');

      final manifestJson = json.decode(manifestString) as Map<String, dynamic>;
      Logger.log('LevelManagerNotifier: Manifest JSON decoded: $manifestJson');

      final levelList = manifestJson['levels'] as List<dynamic>;
      final allLevels = levelList
          .map((e) => LevelMetadata.fromJson(e as Map<String, dynamic>))
          .toList();
      Logger.log(
          'LevelManagerNotifier: ${allLevels.length} levels parsed from manifest.');

      final completedIds =
          _sharedPrefs.getStringList(_prefsKeyCompletedLevels)?.toSet() ?? {};

      // Unlock first level
      if (allLevels.isNotEmpty) {
        allLevels[0] = allLevels[0].copyWith(unlocked: true);
      }

      // Unlock levels based on progress
      for (var i = 1; i < allLevels.length; i++) {
        if (completedIds.contains(allLevels[i - 1].id)) {
          allLevels[i] = allLevels[i].copyWith(unlocked: true);
        }
      }

      Logger.log(
          'LevelManagerNotifier: Updating state with ${allLevels.length} levels.');
      state = state.copyWith(
        levels: allLevels,
        completedLevelIds: completedIds,
        isLoading: false,
      );
      Logger.log(
          'LevelManagerNotifier: State updated. isLoading: ${state.isLoading}, Levels count: ${state.levels.length}');
    } catch (e, stackTrace) {
      Logger.log('Failed to load level manifest: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load levels. Please restart the app.',
      );
    }
  }

  /// PURELY loads a level JSON by index. Does NOT modify state.
  Future<LevelDefinition?> loadLevelByIndex(int index) async {
    Logger.log('LevelManagerNotifier: loadLevelByIndex index $index');

    if (index < 0 || index >= state.levels.length) {
      Logger.log(
          'Invalid index $index for levels length ${state.levels.length}');
      return null;
    }

    final levelMeta = state.levels[index];
    if (!(levelMeta.unlocked ?? false)) {
      Logger.log('Attempted to load locked level ${levelMeta.id}');
      return null;
    }

    try {
      final jsonString =
          await _assetManager.loadString(AppAssets.levelPath(levelMeta.id));
      Logger.log(
          'LevelManagerNotifier: Loaded JSON string for ${levelMeta.id}: $jsonString'); // Add logger
      final decodedJson = json.decode(jsonString) as Map<String, dynamic>;
      final levelDefinition =
          LevelDefinition.fromJson(decodedJson); // Store in a variable
      Logger.log(
          'LevelManagerNotifier: Parsed LevelDefinition for ${levelMeta.id}: $levelDefinition'); // Add logger
      return levelDefinition; // Return the variable
    } catch (e, stackTrace) {
      Logger.log('Failed to load level ${levelMeta.id}: $e\n$stackTrace');
      return null;
    }
  }

  /// Sets the current level in state without fetching JSON.
  /// This method should be added to the LevelManagerNotifier class.
  void setCurrentLevel(LevelDefinition level) {
    state = state.copyWith(currentLevelDefinition: level);
    Logger.log('LevelManagerNotifier: Current level set to ${level.levelId}');
  }

  /// Marks the current level as complete and unlocks the next one.
  Future<void> markCurrentLevelComplete() async {
    final currentLevelId = state.currentLevelDefinition?.levelId;
    if (currentLevelId == null ||
        state.completedLevelIds.contains(currentLevelId)) {
      return;
    }

    // Update completed levels
    final newCompletedIds = {...state.completedLevelIds, currentLevelId};
    await _sharedPrefs.setStringList(
      _prefsKeyCompletedLevels,
      newCompletedIds.toList(),
    );

    // Unlock next level(s)
    final newLevels = state.levels.asMap().entries.map((entry) {
      final i = entry.key;
      final level = entry.value;
      final unlocked = (level.unlocked ?? false) ||
          (i > 0 && newCompletedIds.contains(state.levels[i - 1].id));
      return level.copyWith(unlocked: unlocked);
    }).toList();

    state = state.copyWith(
      completedLevelIds: newCompletedIds,
      levels: newLevels,
    );

    Logger.log('Marked level $currentLevelId as complete');
  }
}
