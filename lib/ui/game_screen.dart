import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'widgets/pause_menu.dart';
import 'game_canvas.dart';
import '../ui/widgets/component_palette.dart';
import '../common/theme.dart';

class GameScreen extends ConsumerWidget {
  final int levelNumber;
  const GameScreen({required this.levelNumber, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelDefinitionAsync = ref.watch(levelDefinitionProvider(levelNumber));

    return levelDefinitionAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error loading level: $error'),
        ),
      ),
      data: (levelDefinition) {
        if (levelDefinition == null) {
          return const Scaffold(
            body: Center(
              child: Text('Level not found!'),
            ),
          );
        }

        final gameEngineProviderWithLevel = gameEngineProvider(levelDefinition);
        final gameEngineState = ref.watch(gameEngineProviderWithLevel);
        final gameNotifier = ref.read(gameEngineProviderWithLevel.notifier);
        final isPaused = gameEngineState.isPaused;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Listen for win state to trigger celebration or navigation
        // Note: isWinProvider will also need to be a family provider if it depends on the game engine
        // For now, this will throw an error. This will be addressed in the next step.
        ref.listen<bool>(isWinProvider(levelDefinition), (prev, isWin) {
          if (isWin) {
            // You can trigger animations or dialogs here, e.g., show a WinScreen overlay
          }
        });

        final gridComponentIds = gameEngineState.grid.components.map((c) => c.id).toSet();
        final paletteComponents =
            levelDefinition.paletteComponents.where((c) => !gridComponentIds.contains(c.id)).toList();
        final selectedComponent = gameEngineState.selectedComponentId == null
            ? null
            : levelDefinition.paletteComponents.firstWhere((c) => c.id == gameEngineState.selectedComponentId);

        return Scaffold(
          body: Stack(
            children: [
              Container(
                color: isDark ? DarkModeColors.darkSurface : LightModeColors.lightSurface,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GameCanvas(
                        levelDefinition: levelDefinition,
                        key: ValueKey(levelDefinition.id), // Use the level ID as a key to force canvas recreation on level change
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: ComponentPalette(
                        availableComponents: paletteComponents,
                        onComponentSelected: gameNotifier.selectComponent,
                        selectedComponent: selectedComponent,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPaused)
                PauseMenu(
                  onResume: gameNotifier.togglePause, // Simplified callback
                ),
            ],
          ),
        );
      },
    );
  }
}
