import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/domain/entities/component.dart'; // Corrected import
import 'package:circuit_stem/common/constants.dart'; // Corrected import
import 'package:circuit_stem/domain/entities/level_definition.dart'; // Corrected import
import 'package:circuit_stem/presentation/state/game_state.dart' hide gameEngineProvider, gridProvider; // Hide to avoid conflicts
import 'package:circuit_stem/application/providers.dart'; // Use consolidated providers
import '../widgets/grid_widget.dart';
import '../widgets/component_widget.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/common/logger.dart'; // Corrected import
import 'package:circuit_stem/presentation/features/game/controllers/game_canvas_controller.dart';

class GameCanvas extends ConsumerStatefulWidget {
  final LevelDefinition levelDefinition;
  static const double _cellSize = cellSize;
  const GameCanvas({super.key, required this.levelDefinition});

  @override
  GameCanvasState createState() => GameCanvasState();
}

class GameCanvasState extends ConsumerState<GameCanvas> {
  @override
  void initState() {
    super.initState();
    // Load the level into the notifier when the widget is first created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameEngineNotifierProvider).loadLevel(widget.levelDefinition);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(gridProvider);
    final gameCanvasController = ref.read(gameCanvasControllerProvider.notifier); // Get the controller

    Logger.log("GameCanvas: Building with ${grid.components.length} components on the grid.");
    for (var component in grid.components) {
      Logger.log("GameCanvas: Component on grid: ${component.id} (type: ${component.type}) at r:${component.r}, c:${component.c}");
    }

    return DragTarget<ComponentModel>(
      onAcceptWithDetails: (details) {
        final Offset gridCoords = gameCanvasController.getGridCoordinates(details.offset); // Use controller
        final int col = gridCoords.dx.toInt();
        final int row = gridCoords.dy.toInt();

        if (details.data.id.endsWith('_palette')) {
          ref.read(gameEngineNotifierProvider).executeAction(
                CreateComponentFromTemplateAction(
                  templateId: details.data.id,
                  row: row,
                  col: col,
                ),
              );
        } else {
          ref.read(gameEngineNotifierProvider).executeAction(
                MoveComponentAction(
                  componentId: details.data.id,
                  newRow: row,
                  newCol: col,
                ),
              );
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          key: gameCanvasController.gridKey, // Use controller's key
          children: [
            GridWidget(
              rows: grid.rows,
              cols: grid.cols,
              cellSize: GameCanvas._cellSize,
            ),
            ...grid.components.map((component) {
              final bounds = component.getBounds();

              return Positioned(
                left: component.c * GameCanvas._cellSize,
                top: component.r * GameCanvas._cellSize,
                width: bounds.width * GameCanvas._cellSize,
                height: bounds.height * GameCanvas._cellSize,
                child: ComponentWidget(
                  component: component,
                  onTap: () => _handleComponentTap(component),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _handleComponentTap(ComponentModel component) {
    ref.read(gameEngineNotifierProvider).executeAction(
          TapComponentAction(componentId: component.id),
        );
  }
}
