import 'package:flutter/material.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/presentation/state/game_state.dart' hide
    levelManagerProvider, gameEngineProvider, levelsProvider, gridProvider;
import 'package:circuit_stem/common/logger.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/presentation/core/ui_migration_wrapper.dart';

import 'package:circuit_stem/presentation/features/hud/screens/pause_menu.dart';
import 'package:circuit_stem/presentation/features/game/widgets/game_canvas.dart';
import 'package:circuit_stem/presentation/features/palette/widgets/component_palette.dart';


// =====================================
// RIVERPOD-IDIOMATIC IMPLEMENTATION
// =====================================

enum GameInitializationState {
  initializing,
  loadingLevel,
  initializingEngine,
  preloadingAdjacent,
  ready,
}

class GameScreenData {
  final GameInitializationState state;
  final LevelDefinition? levelDefinition;
  final double progress;
  final String? statusMessage;

  const GameScreenData({
    this.state = GameInitializationState.initializing,
    this.levelDefinition,
    this.progress = 0.0,
    this.statusMessage,
  });

  GameScreenData copyWith({
    GameInitializationState? state,
    LevelDefinition? levelDefinition,
    double? progress,
    String? statusMessage,
  }) {
    return GameScreenData(
      state: state ?? this.state,
      levelDefinition: levelDefinition ?? this.levelDefinition,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

// Cache for efficient level management
class GameScreenCache {
  static final Map<int, LevelDefinition> _levelCache = {};

  static LevelDefinition? getCachedLevel(int index) => _levelCache[index];

  static void cacheLevel(int index, LevelDefinition level) {
    _levelCache[index] = level;
  }

  static void clearCache() {
    _levelCache.clear();
    Logger.log('GameScreen: Level cache cleared');
  }

  static int getCacheSize() => _levelCache.length;
}

// AsyncNotifier for managing game initialization
class GameInitializationNotifier extends AsyncNotifier<GameScreenData> {
  late int levelIndex;

  @override
  Future<GameScreenData> build() async {
    // This will be called when the provider is first accessed
    return const GameScreenData();
  }

  Future<void> initializeGame(int index) async {
    levelIndex = index;

    try {
      // Phase 1: Start initialization
      state = const AsyncValue.loading();

      // Phase 2: Load level definition
      state = AsyncValue.data(const GameScreenData(
        state: GameInitializationState.loadingLevel,
        progress: 0.25,
        statusMessage: 'Loading level definition...',
      ));

      final levelDefinition = await _loadLevelWithProgress(index);
      if (levelDefinition == null) {
        throw Exception('Level $index not found or locked');
      }

      // Phase 3: Initialize game engine
      state = AsyncValue.data(GameScreenData(
        state: GameInitializationState.initializingEngine,
        levelDefinition: levelDefinition,
        progress: 0.5,
        statusMessage: 'Initializing game engine...',
      ));

      await _initializeGameEngine(levelDefinition);

      // Phase 4: Preload adjacent levels
      state = AsyncValue.data(GameScreenData(
        state: GameInitializationState.preloadingAdjacent,
        levelDefinition: levelDefinition,
        progress: 0.75,
        statusMessage: 'Preloading adjacent levels...',
      ));

      _preloadAdjacentLevels();

      // Phase 5: Ready
      state = AsyncValue.data(GameScreenData(
        state: GameInitializationState.ready,
        levelDefinition: levelDefinition,
        progress: 1.0,
        statusMessage: 'Game ready!',
      ));

      Logger.log(
          'GameScreen: Initialization complete for level ${levelDefinition.id}');
    } catch (error, stackTrace) {
      Logger.log('GameScreen: Initialization failed',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<LevelDefinition?> _loadLevelWithProgress(int index) async {
    // Check cache first
    final cached = GameScreenCache.getCachedLevel(index);
    if (cached != null) {
      Logger.log('GameScreen: Using cached level $index');
      return cached;
    }

    // Load from level manager
    final levelManager = ref.read(levelManagerProvider.notifier);
    final levelDefinition = await levelManager.loadLevelByIndex(index);

    if (levelDefinition != null) {
      GameScreenCache.cacheLevel(index, levelDefinition);
      levelManager.setCurrentLevel(levelDefinition);
    }

    return levelDefinition;
  }

  Future<void> _initializeGameEngine(LevelDefinition levelDefinition) async {
    final gameNotifier = ref.read(gameEngineNotifierProvider);

    Logger.log(
        'GameScreen: Loading level ${levelDefinition.id} into game engine');
    final result = await gameNotifier.loadLevel(levelDefinition);

    if (result.isFailure) {
      throw Exception('Failed to initialize game engine: ${result.error}');
    }

    // Allow some time for the engine to process
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _preloadAdjacentLevels() {
    final levels = ref.read(levelsProvider); // Corrected usage

    // Preload next level
    if (levelIndex + 1 < levels.length && levels[levelIndex + 1].unlocked) {
      _preloadLevel(levelIndex + 1);
    }

    // Preload previous level
    if (levelIndex > 0) {
      _preloadLevel(levelIndex - 1);
    }
  }

  void _preloadLevel(int index) async {
    if (GameScreenCache.getCachedLevel(index) != null) return;

    try {
      final levelManager = ref.read(levelManagerProvider.notifier);
      final levelDefinition = await levelManager.loadLevelByIndex(index);
      if (levelDefinition != null) {
        GameScreenCache.cacheLevel(index, levelDefinition);
        Logger.log('GameScreen: Preloaded level $index');
      }
    } catch (e) {
      Logger.log('GameScreen: Failed to preload level $index: $e');
    }
  }

  void retry() {
    initializeGame(levelIndex);
  }
}

// Provider for the game initialization
final gameInitializationProvider =
    AsyncNotifierProvider<GameInitializationNotifier, GameScreenData>(
  () => GameInitializationNotifier(),
);

// Riverpod-idiomatic GameScreen implementation
class GameScreen extends ConsumerStatefulWidget {
  final int levelIndex;

  const GameScreen({super.key, required this.levelIndex});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingAnimationController;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Initialize the game when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gameInitializationProvider.notifier)
          .initializeGame(widget.levelIndex);
    });
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initializationAsync = ref.watch(gameInitializationProvider);

    return initializationAsync.when(
      loading: () => _buildLoadingScreen(null),
      error: (error, stackTrace) => _buildErrorScreen(error.toString()),
      data: (gameData) {
        switch (gameData.state) {
          case GameInitializationState.ready:
            return _buildGameInterface(gameData.levelDefinition!);
          default:
            return _buildLoadingScreen(gameData);
        }
      },
    );
  }

  Widget _buildLoadingScreen(GameScreenData? gameData) {
    final progress = gameData?.progress ?? 0.0;
    final statusMessage = gameData?.statusMessage ?? 'Initializing...';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loading icon
              AnimatedBuilder(
                animation: _loadingAnimationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _loadingAnimationController.value * 2 * 3.14159,
                    child: Icon(
                      Icons.electrical_services,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Status message
              Text(
                statusMessage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),

              // Progress bar
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Progress percentage
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(gameInitializationProvider.notifier).retry();
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInterface(LevelDefinition levelDefinition) {
    Logger.log('GameScreen: Building UI for level: ${levelDefinition.id}');
    Logger.log('GameScreen: Initial components from level definition: ${levelDefinition.initialComponents.length}');
    for (var component in levelDefinition.initialComponents) {
      Logger.log('GameScreen: Initial component: ${component.id} (type: ${component.type}) at r:${component.r}, c:${component.c}');
    }

    // Listen to win condition - using granular provider for performance
    ref.listen<bool>(isWinProvider, (previous, isWin) {
      if (isWin) {
        _handleLevelWin();
      }
    });

    final gameNotifier = ref.read(gameEngineNotifierProvider);
    final grid = ref.watch(gridProvider);
    final isPaused = ref.watch(isPausedProvider); // Granular provider optimization
    final selectedComponentId = ref.watch(selectedComponentIdProvider); // Granular provider optimization
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gridComponentIds = grid.components.map((c) => c.id).toSet();
    final paletteComponents = levelDefinition.paletteComponents
        .where((c) => !gridComponentIds.contains(c.id))
        .toList();

    ComponentModel? selectedComponent;
    if (selectedComponentId != null) {
      for (final component in levelDefinition.paletteComponents) {
        if (component.id == selectedComponentId) {
          selectedComponent = component;
          break;
        }
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GameCanvas(
                    levelDefinition: levelDefinition,
                    key: ValueKey(levelDefinition.id),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      // Level info header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              levelDefinition.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${widget.levelIndex + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                            if (levelDefinition.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                levelDefinition.description,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Component palette
                      Expanded(
                        child: ComponentPalette(
                          availableComponents: paletteComponents,
                          onComponentSelected:
                              gameNotifier.selectPaletteComponent,
                          selectedComponent: selectedComponent,
                        ),
                      ),

                      // Control buttons
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Primary actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildControlButton(
                                  icon: Icons.refresh,
                                  onPressed: gameNotifier.restartLevel,
                                  tooltip: 'Restart Level',
                                  key: const Key('restart_button'),
                                ),
                                _buildControlButton(
                                  icon: Icons.undo,
                                  onPressed: gameNotifier.canUndo
                                      ? gameNotifier.undo
                                      : null,
                                  tooltip: 'Undo Last Action',
                                  key: const Key('undo_button'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Secondary actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildControlButton(
                                  icon:
                                      isPaused ? Icons.play_arrow : Icons.pause,
                                  onPressed: gameNotifier.togglePause,
                                  tooltip:
                                      isPaused ? 'Resume Game' : 'Pause Game',
                                ),
                                _buildControlButton(
                                  icon: Icons.arrow_back,
                                  onPressed: () => Navigator.of(context).pop(),
                                  tooltip: 'Back to Menu',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isPaused)
            PauseMenu(
              onResume: gameNotifier.togglePause,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Key? key,
  }) {
    return IconButton(
      key: key,
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: onPressed != null
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: onPressed != null
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  void _handleLevelWin() async {
    final manager = ref.read(levelManagerProvider.notifier);
    await manager.markCurrentLevelComplete();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.celebration,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Level Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉 Great job! You solved it!'),
              const SizedBox(height: 16),
              Text(
                'Ready for the next challenge?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Level Select'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToNextLevel();
              },
              child: const Text('Next Level'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToNextLevel() {
    final nextIndex = widget.levelIndex + 1;
    final levels = ref.read(levelsProvider); // Corrected usage

    if (nextIndex < levels.length && levels[nextIndex].unlocked) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameScreen(levelIndex: nextIndex),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 All levels completed! Amazing work!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
