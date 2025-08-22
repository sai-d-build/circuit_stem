import 'package:flutter/material.dart';
import '../models/component.dart';
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

        // Listen to the new, non-family isWinProvider
        ref.listen<bool>(isWinProvider, (previous, isWin) {
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

        // Use the new providers
        final gameNotifier = ref.read(gameEngineProvider.notifier);
        final grid = ref.watch(gridProvider);
        final isPaused = ref.watch(gameEngineProvider.select((s) => s.isPaused));
        final selectedComponentId = ref.watch(gameEngineProvider.select((s) => s.selectedComponentId));
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final gridComponentIds =
            grid.components.map((c) => c.id).toSet();
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
                              onComponentSelected: gameNotifier.selectPaletteComponent,
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
