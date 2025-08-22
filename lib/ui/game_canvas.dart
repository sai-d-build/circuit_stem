import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../models/component.dart';
import '../common/constants.dart';
import '../common/logger.dart';
import '../models/level_definition.dart';
import '../widgets/grid_widget.dart';
import '../widgets/component_widget.dart';
import '../behaviors/drag_behavior.dart';
import '../behaviors/movable_behavior.dart';

class GameCanvas extends ConsumerStatefulWidget {
  final LevelDefinition levelDefinition;
  const GameCanvas({required this.levelDefinition, Key? key}) : super(key: key);

  @override
  _GameCanvasState createState() => _GameCanvasState();
}

class _GameCanvasState extends ConsumerState<GameCanvas> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Logger.log('GameCanvas: Building GameCanvas.');
    final gameNotifier = ref.read(gameEngineProvider(widget.levelDefinition).notifier);
    final gameEngineState = ref.watch(gameEngineProvider(widget.levelDefinition));
    final assetManager = ref.watch(assetManagerProvider.notifier);

    final movableBehavior = MovableBehavior(gameEngineNotifier: gameNotifier);
    final dragBehavior = DragBehavior(gameEngineNotifier: gameNotifier, gridKey: _gridKey);
    dragBehavior.attachBehavior(movableBehavior);

    return DragTarget<ComponentModel>(
        onAcceptWithDetails: (details) {
          final component = details.data;
          final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) return;

          final localOffset = renderBox.globalToLocal(details.offset);
          final col = (localOffset.dx / cellSize).floor();
          final row = (localOffset.dy / cellSize).floor();

          Logger.log('GameCanvas: Dropped component ${component.id} of type ${component.type} at ($row, $col)');
          gameNotifier.inputManager.handleMove(component.id, row, col);
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            key: _gridKey,
            children: [
              GridWidget(
                rows: gameEngineState.grid.rows,
                cols: gameEngineState.grid.cols,
                cellSize: cellSize,
              ),
              ...gameEngineState.grid.components.map((component) {
                return Positioned(
                  left: component.c * cellSize,
                  top: component.r * cellSize,
                  width: component.shape.first.c * cellSize,
                  height: component.shape.first.r * cellSize,
                  child: ComponentWidget(
                    component: component,
                    assetManager: assetManager,
                    dragBehavior: dragBehavior,
                    onTap: () {
                    gameNotifier.inputManager.handleTap(component);
                  },
                  ),
                );
              }).toList(),
            ],
          );
        });
  }
}
