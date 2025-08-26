import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/providers.dart';
import '../../domain/entities/component.dart';
import '../../common/constants.dart';
import '../../domain/entities/level_definition.dart';
import '../widgets/grid_widget.dart';
import '../widgets/component_widget.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';

class GameCanvas extends ConsumerStatefulWidget {
  final LevelDefinition levelDefinition;
  static const double _cellSize = cellSize;
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
    final assetManager = ref.watch(assetManagerProvider.notifier);

    return DragTarget<ComponentModel>(
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = _gridKey.currentContext!.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        final int col = (localPosition.dx / cellSize).floor();
        final int row = (localPosition.dy / cellSize).floor();

        if (details.data.id.endsWith('_palette')) {
          ref.read(gameEngineProvider.notifier).executeAction(
                CreateComponentFromTemplateAction(
                  templateId: details.data.id,
                  row: row,
                  col: col,
                ),
              );
        } else {
          ref.read(gameEngineProvider.notifier).executeAction(
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
          key: _gridKey,
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
                  assetManager: assetManager,
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
    ref.read(gameEngineProvider.notifier).executeAction(
          TapComponentAction(componentId: component.id),
        );
  }
}
