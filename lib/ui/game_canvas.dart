import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'canvas_painter.dart';
import '../models/component.dart';
import '../common/constants.dart';
import '../common/logger.dart';

class GameCanvas extends ConsumerWidget {
  const GameCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger.log('GameCanvas: Building GameCanvas.');
    final gameNotifier = ref.read(gameEngineProvider.notifier);
    final renderState = ref.watch(gameEngineProvider.select((s) => s.renderState));
    final assetManager = ref.watch(assetManagerProvider.notifier);
    final theme = Theme.of(context);
    final selectedComponentId = ref.watch(gameEngineProvider.select((s) => s.selectedComponentId));
    final selectedComponent = selectedComponentId != null ? ref.watch(gameEngineProvider.select((s) => s.grid.componentsById[selectedComponentId])) : null;

    Logger.log('GameCanvas: renderState is ${renderState != null ? 'not null' : 'null'}');
    if (renderState != null) {
      Logger.log('GameCanvas: renderState grid has \${renderState.grid.components.length} components.');
    }

    return DragTarget<ComponentModel>(
      onAcceptWithDetails: (details) {
        final component = details.data;
        final offset = details.offset;
        final col = (offset.dx / cellSize).floor();
        final row = (offset.dy / cellSize).floor();
        Logger.log('GameCanvas: Dropped component \${component.id} of type \${component.type} at (\$row, \$col)');
        gameNotifier.addComponent(component, row, col);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTapDown: (details) {
            Logger.log('GameCanvas: TapDown at \${details.localPosition}');
            gameNotifier.handleTap(details.localPosition);
          },
          onPanStart: (details) {
            Logger.log('GameCanvas: PanStart at \${details.localPosition}');
            final cell = renderState?.grid.cellAt(details.localPosition.dx, details.localPosition.dy);
            if (cell != null) {
              final component = renderState?.grid.componentAt(cell.r, cell.c);
              if (component != null && component.isDraggable) {
                Logger.log('GameCanvas: Starting drag for component \${component.id}');
                gameNotifier.startDrag(component, details.localPosition);
              } else {
                Logger.log('GameCanvas: No draggable component at (\${cell.r}, \${cell.c})');
              }
            } else {
              Logger.log('GameCanvas: PanStart outside grid.');
            }
          },
          onPanUpdate: (details) {
            Logger.log('GameCanvas: PanUpdate to \${details.localPosition}');
            gameNotifier.updateDrag(details.localPosition);
          },
          onPanEnd: (details) {
            Logger.log('GameCanvas: PanEnd.');
            gameNotifier.endDrag();
          },
          child: Stack(
            children: [
              CustomPaint(
                painter: CanvasPainter(
                  renderState: renderState,
                  assetManager: assetManager,
                  isDark: theme.brightness == Brightness.dark,
                  gridColor: theme.dividerColor,
                  draggedComponentBackgroundColor: theme.scaffoldBackgroundColor.withAlpha(179),
                ),
                size: Size.infinite,
              ),
              if (selectedComponent != null) // Show rotate button if a component is selected
                Positioned(
                  left: selectedComponent.c * cellSize,
                  top: selectedComponent.r * cellSize,
                  child: IconButton(
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () {
                      Logger.log('GameCanvas: Rotate button pressed for component \${selectedComponent.id}');
                      gameNotifier.rotateComponent();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
