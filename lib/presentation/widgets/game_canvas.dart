import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/providers.dart';
import '../../domain/entities/component.dart';
import '../../common/constants.dart';
import '../../domain/entities/level_definition.dart';
import '../widgets/grid_widget.dart';
import '../widgets/component_widget.dart';
import '../../domain/behaviors/drag_behavior.dart';

class GameCanvas extends ConsumerStatefulWidget {
  final LevelDefinition levelDefinition;
  const GameCanvas({super.key, required this.levelDefinition});

  @override
  GameCanvasState createState() => GameCanvasState();
}

class GameCanvasState extends ConsumerState<GameCanvas> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load the level into the notifier when the widget is first created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameEngineProvider.notifier).loadLevel(widget.levelDefinition);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(gridProvider);
    final notifier = ref.read(gameEngineProvider.notifier);
    final assetManager = ref.watch(assetManagerProvider.notifier);
    final dragBehavior = DragBehavior(ref: ref, gridKey: _gridKey);

    return DragTarget<ComponentModel>(
      onAcceptWithDetails: (details) {
        dragBehavior.onDragEnd(details);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          key: _gridKey,
          children: [
            GridWidget(
              rows: grid.rows,
              cols: grid.cols,
              cellSize: cellSize,
            ),
            ...grid.components.map((component) {
              int maxR = 0;
              int maxC = 0;
              for (final offset in component.shapeOffsets) {
                if (offset.r > maxR) maxR = offset.r;
                if (offset.c > maxC) maxC = offset.c;
              }
              final componentWidth = (maxC + 1) * cellSize;
              final componentHeight = (maxR + 1) * cellSize;

              return Positioned(
                left: component.c * cellSize,
                top: component.r * cellSize,
                width: componentWidth,
                height: componentHeight,
                child: ComponentWidget(
                  component: component,
                  assetManager: assetManager,
                  dragBehavior: dragBehavior,
                  onTap: () {
                    notifier.inputManager.handleTap(component);
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
