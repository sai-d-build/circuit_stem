import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'widgets/pause_menu.dart';
import 'game_canvas.dart';
import '../ui/widgets/component_palette.dart';
import '../common/theme.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameEngineState = ref.watch(gameEngineProvider);
    final gameNotifier = ref.read(gameEngineProvider.notifier);
    final isPaused = gameEngineState.isPaused;
    final currentLevel = gameEngineState.currentLevel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for win state to trigger celebration or navigation
    ref.listen<bool>(isWinProvider, (prev, isWin) {
      if (isWin) {
        // You can trigger animations or dialogs here, e.g., show a WinScreen overlay
      }
    });

    if (currentLevel == null) {
      // This should ideally not happen if navigation is handled correctly
      return const Scaffold(
        body: Center(
          child: Text('No level loaded!'),
        ),
      );
    }

    final gridComponentIds = gameEngineState.grid.components.map((c) => c.id).toSet();
    final paletteComponents =
        currentLevel.paletteComponents.where((c) => !gridComponentIds.contains(c.id)).toList();
    final selectedComponent = gameEngineState.selectedComponentId == null
        ? null
        : currentLevel.paletteComponents.firstWhere((c) => c.id == gameEngineState.selectedComponentId);

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
                    key: ValueKey(currentLevel.id), // Use the level ID as a key to force canvas recreation on level change
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
  }
}
