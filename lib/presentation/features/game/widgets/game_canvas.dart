import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import '../../../../application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart' as core_providers;
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';

import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';

import 'canvas_drag_drop_layer.dart';
import 'canvas_gesture_layer.dart';
import 'canvas_rendering_layer.dart';
import 'canvas_wire_layer.dart';
import 'canvas_drop_zone_layer.dart';
import 'canvas_drag_preview.dart';

class GameCanvas extends ConsumerStatefulWidget {
  final String levelId;

  const GameCanvas({super.key, required this.levelId});

  @override
  ConsumerState<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends ConsumerState<GameCanvas> {
  // Local drag state for layer integration
  ComponentDragData? _currentDragData;
  Offset? _dragPosition;

  @override
  void initState() {
    super.initState();
    StructuredLogger.info('GameCanvas: Initializing GameCanvas', context: {
      'levelId': widget.levelId,
    });
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    StructuredLogger.info('GameCanvas: Starting level load process', context: {
      'levelId': widget.levelId,
    });

    try {
      final levelService = ref.read(providers_v3.levelServiceProvider);
      final level = await levelService.loadLevel(widget.levelId);

      if (level != null) {
        // Initialize game state with the loaded level
        ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier).loadLevel(level);

        // Initialize orchestrator with level
        StructuredLogger.debug('GameCanvas: Initializing orchestrator with level', context: {
          'levelId': widget.levelId,
          'orchestrator_available': ref.read(gameCanvasOrchestratorProvider(widget.levelId).notifier) != null,
        });

        ref.read(gameCanvasOrchestratorProvider(widget.levelId).notifier).initializeLevel(widget.levelId);

        StructuredLogger.info('GameCanvas: Level load process completed successfully', context: {
          'levelId': level.levelId,
          'levelTitle': level.metadata.title,
        });
      }
    } catch (e) {
      StructuredLogger.error('GameCanvas: Error loading level', context: {
        'levelId': widget.levelId,
        'errorType': e.runtimeType.toString(),
        'errorMessage': e.toString(),
      }, error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎮 GameCanvas: Building level ${widget.levelId}');
    StructuredLogger.trace('GameCanvas: Building - checking orchestrator state', context: {
      'context_available': context != null,
      'levelId': widget.levelId,
    });

    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>() ?? _getDefaultCircuitColors();
    final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);

    final canvasState = ref.watch(gameCanvasOrchestratorProvider(widget.levelId));
    StructuredLogger.trace('GameCanvas: Orchestrator state received', context: {
      'orchestrator_available': true,
      'canvasState_error': canvasState.error,
      'canvasState_isLoading': canvasState.isLoading,
      'canvasState_hasLevel': canvasState.currentLevel != null,
      'viewport_scale': canvasState.viewportState.scale,
      'viewport_canvasSize': canvasState.viewportState.canvasSize.toString(),
      'viewport_panOffset': canvasState.viewportState.panOffset.toString(),
      'gridConfig_rows': canvasState.viewportState.gridConfiguration.rows,
      'gridConfig_cols': canvasState.viewportState.gridConfiguration.cols,
      'gridConfig_cellSize': canvasState.viewportState.gridConfiguration.cellSize,
    });

    return Container(
      decoration: BoxDecoration(
        color: circuitColors.surface,
        border: Border.all(
          color: circuitColors.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          print('🎮 GameCanvas: Container constraints: ${constraints.toString()}');
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
          children: [
            // Grid background
            Positioned.fill(
              child: CircuitGrid(levelId: widget.levelId),
            ),

            // Wire layer
            CanvasWireLayer(levelId: widget.levelId),

            // Rendering layer
            Positioned.fill(
              child: CanvasRenderingLayer(levelId: widget.levelId),
            ),

            // Interaction layer (gesture handling)
            Positioned.fill(
              child: CanvasGestureLayer(
                levelId: widget.levelId,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Debug Layer: Event blocking test
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) => debugPrint('🎯 DEBUG: Stack level pan start ${details.globalPosition}'),
                onPanUpdate: (details) => debugPrint('🎯 DEBUG: Stack level pan update ${details.globalPosition}'),
                onPanEnd: (details) => debugPrint('🎯 DEBUG: Stack level pan end ${details.velocity}'),
                child: Container(
                  color: Colors.transparent, // Fully transparent for visual debugging
                  child: const IgnorePointer(), // Don't block events, just observe them
                ),
              ),
            ),

            // Drag and drop layer
            Positioned.fill(
              child: CanvasDragDropLayer(
                levelId: widget.levelId,
                child: const SizedBox.shrink(),
              ),
            ),

            // Drop zone highlight (conditional)
            () {
              final isPaletteDragActive = ref.watch(core_providers.paletteDragActiveProvider);
              final hasCurrentDragData = _currentDragData != null;

              StructuredLogger.debug('GameCanvas: Drop zone condition check', context: {
                'paletteDragActive': isPaletteDragActive,
                'currentDragData_exists': hasCurrentDragData,
                'currentDragData_componentName': _currentDragData?.componentName ?? 'null',
                'currentDragData_componentType': _currentDragData?.componentType?.toString() ?? 'null',
                'dropZone_will_render': isPaletteDragActive && hasCurrentDragData,
              });

              if (isPaletteDragActive && hasCurrentDragData) {
                return Positioned.fill(
                  child: CanvasDropZoneLayer(
                    dragData: _currentDragData,
                    child: const SizedBox.shrink(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }(),

            // Drag preview
            if (_currentDragData != null && _dragPosition != null)
              CanvasDragPreview(
                componentType: _currentDragData!.componentType.toString().split('.').last,
                position: _dragPosition!,
              ),

            // Component widgets
            ...gameState.grid.components.values.map((component) =>
              CircuitComponentWidget(component: component)
            ),
          ],
        ),
      );
    },
    ),
  );
  }

  CircuitColorScheme _getDefaultCircuitColors() {
    return const CircuitColorScheme(
      primary: Color(0xFF1E88E5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF43A047),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFF8F00),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFFEFEFEF),
      onSurfaceVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      outline: Color(0xFFBDBDBD),
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
      neonPrimary: Color(0xFF00E5FF),
      neonAccent: Color(0xFF00BCD4),
      errorGlow: Color(0xFFFF5252),
      energyPulse: Color(0xFF00E676),
      highlightAccent: Color(0xFFFFC107),
    );
  }
}