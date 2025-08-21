import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';

import 'widgets/pause_menu.dart';
import 'game_canvas.dart';
import '../ui/widgets/component_palette.dart';
import '../common/theme.dart';

class GameScreen extends ConsumerWidget {
  final int levelIndex;

  const GameScreen({super.key, required this.levelIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelDefinitionAsync = ref.watch(levelDefinitionProvider(levelIndex));

    return levelDefinitionAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error loading level: $err')),
      ),
      data: (levelDefinition) {
        if (levelDefinition == null) {
          return const Scaffold(
            body: Center(child: Text('Level not found!')),
          );
        }

        ref.listen<bool>(isWinProvider(levelDefinition), (previous, isWin) {
          if (isWin) {
            final manager = ref.read(levelManagerProvider.notifier);

            // Mark current level as complete
            manager.markCurrentLevelComplete();

            // Navigate to next unlocked level if available
            final nextIndex = levelIndex + 1;
            final levels = ref.read(levelManagerProvider).levels;

            if (nextIndex < levels.length && levels[nextIndex].unlocked) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(levelIndex: nextIndex),
                ),
              );
            } else {
              // No next level: show completion screen or pop
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All levels completed!')),
              );
            }
          }
        });

        final gameEngineProviderWithLevel = gameEngineProvider(levelDefinition);
        final gameEngineState = ref.watch(gameEngineProviderWithLevel);
        final gameNotifier = ref.read(gameEngineProviderWithLevel.notifier);
        final isPaused = gameEngineState.isPaused;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final gridComponentIds =
            gameEngineState.grid.components.map((c) => c.id).toSet();
        final paletteComponents = levelDefinition.paletteComponents
            .where((c) => !gridComponentIds.contains(c.id))
            .toList();
        final selectedComponent = gameEngineState.selectedComponentId == null
            ? null
            : levelDefinition.paletteComponents.firstWhere(
                (c) => c.id == gameEngineState.selectedComponentId,
              );

        return Scaffold(
          body: Stack(
            children: [
              Container(
                color: isDark
                    ? DarkModeColors.darkSurface
                    : LightModeColors.lightSurface,
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
                          Expanded(
                            child: ComponentPalette(
                              availableComponents: paletteComponents,
                              onComponentSelected: gameNotifier.selectComponent,
                              selectedComponent: selectedComponent,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  key: const Key('restart_button'),
                                  icon: const Icon(Icons.refresh),
                                  onPressed: gameNotifier.restartLevel,
                                ),
                                IconButton(
                                  key: const Key('undo_button'),
                                  icon: const Icon(Icons.undo),
                                  onPressed: gameNotifier.undo,
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
      },
    );
  }
}
