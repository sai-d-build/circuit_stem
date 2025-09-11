import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';

import 'canvas_interaction_widget.dart';
import 'canvas_rendering_layer.dart';
import 'canvas_wire_layer.dart';
import 'package:sparkcircuit/presentation/helpers/central_interaction_helper.dart';

class GameCanvas extends ConsumerStatefulWidget {
  final String levelId;

  const GameCanvas({super.key, required this.levelId});

  @override
  ConsumerState<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends ConsumerState<GameCanvas> {

  @override
  void initState() {
    super.initState();
    StructuredLogger.info('GameCanvas: Initializing GameCanvas', context: {
      'levelId': widget.levelId,
    });
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    StructuredLogger.debug('🎮 GameCanvas: Starting level load process for ${widget.levelId}', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    StructuredLogger.info('GameCanvas: Starting level load process', context: {
      'levelId': widget.levelId,
    });

    try {
      final levelService = CentralInteractionHelper.getLevelService(ref);
      StructuredLogger.debug('🎮 GameCanvas: Got level service: $levelService', context: {
        'levelId': widget.levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      final level = await levelService.loadLevel(widget.levelId);
      StructuredLogger.debug('🎮 GameCanvas: Level loaded: ${level?.levelId ?? "NULL"}', context: {
        'levelId': widget.levelId,
        'loadedLevelId': level?.levelId ?? "NULL",
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (level != null) {
        StructuredLogger.debug('🎮 GameCanvas: Loading level into game state', context: {
          'levelId': widget.levelId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        // Initialize game state with the loaded level using centralized helper
        await CentralInteractionHelper.loadLevel(ref, widget.levelId, level);

        // Also initialize the orchestrator with the level
        CentralInteractionHelper.initializeLevel(ref, widget.levelId);

        StructuredLogger.info('GameCanvas: Level load process completed successfully', context: {
          'levelId': level.levelId,
          'levelTitle': level.metadata.title,
        });
        StructuredLogger.debug('🎮 GameCanvas: Level load completed successfully', context: {
          'levelId': level.levelId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        StructuredLogger.error('🎮 GameCanvas: Level is NULL - this is the problem!', context: {
          'levelId': widget.levelId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      StructuredLogger.error('🎮 GameCanvas: Error loading level: $e', context: {
        'levelId': widget.levelId,
        'errorType': e.runtimeType.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }, error: e);
      StructuredLogger.error('GameCanvas: Error loading level', context: {
        'levelId': widget.levelId,
        'errorType': e.runtimeType.toString(),
        'errorMessage': e.toString(),
      }, error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    StructuredLogger.debug('🎮 GameCanvas: BUILD METHOD CALLED for level ${widget.levelId}', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    StructuredLogger.debug('🎮 GameCanvas: Building level ${widget.levelId}', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    StructuredLogger.trace('GameCanvas: Building - checking orchestrator state', context: {
      'levelId': widget.levelId,
    });
    StructuredLogger.debug('GameCanvas: Build started', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>() ?? _getDefaultCircuitColors();

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
          StructuredLogger.debug('🎮 GameCanvas: Container constraints: ${constraints.toString()}', context: {
            'levelId': widget.levelId,
            'constraints': constraints.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand, // Ensure stack fills the entire container
              children: [
              // 🔧 FIX: Unified interaction layer with proper hit testing elevation
              // This must be FIRST to receive drag events - other layers must allow pass-through
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    StructuredLogger.debug('GameCanvas building CanvasInteractionWidget', context: {
                      'levelId': widget.levelId,
                      'widgetOrder': 'first_in_stack',
                      'hitTestingEnabled': true,
                    });
                    return CanvasInteractionWidget(levelId: widget.levelId);
                  },
                ),
              ),
  
              // Grid background - MUST receive drag events for drop zones
              Positioned.fill(
                child: CircuitGrid(levelId: widget.levelId),
              ),
  
              // Wire layer - must allow touch pass-through
              Positioned.fill(
                child: IgnorePointer(
                  child: CanvasWireLayer(levelId: widget.levelId),
                ),
              ),
  
              // Rendering layer - must allow touch pass-through
              Positioned.fill(
                child: IgnorePointer(
                  child: CanvasRenderingLayer(levelId: widget.levelId),
                ),
              ),
  
              // Component widgets - must allow touch pass-through
              // These need to be draggable themselves but shouldn't block the canvas
              Consumer(
                builder: (context, ref, child) {
                  final componentState = ref.watch(unifiedGameStateProvider.select((state) => state.grid.components));
                  final canvasState = ref.watch(gameCanvasOrchestratorProvider(widget.levelId));
                  final cellSize = canvasState.viewportState.gridConfiguration.cellSize; // 🔧 FIX 5: Use dynamic cell size

                  StructuredLogger.debug('GameCanvas: Component positioning using dynamic cell size', context: {
                    'dynamicCellSize': cellSize,
                    'oldHardcodedSize': 60.0,
                    'totalComponents': componentState.length,
                    'scaleFactor': canvasState.viewportState.gridConfiguration.cellSize / 60.0,
                  });

                  return Positioned.fill(
                    child: IgnorePointer(
                      // 🔧 CRITICAL: Allow components to be interactive but pass through canvas drags
                      ignoring: false, // Allow component interaction
                      child: Stack(
                        children: componentState.values.map((component) =>
                          // Components handle their own interaction - don't block canvas
                          Positioned(
                            left: component.col * cellSize, // 🔧 FIX 5: Use dynamic cell size instead of 60.0
                            top: component.row * cellSize,   // 🔧 FIX 5: Use dynamic cell size instead of 60.0
                            child: AbsorbPointer(
                              absorbing: false, // Allow component interaction
                              child: CircuitComponentWidget(
                                key: ValueKey(component.id),
                                component: component,
                                levelId: widget.levelId,
                              )
                            ),
                          )
                        ).toList(),
                      ),
                    ),
                  );
                },
              ),

            // Enhanced Debug Dashboard - comprehensive debugging information
            Consumer(
              builder: (context, ref, child) {
                final gameState = ref.watch(unifiedGameStateProvider);
                final interactionState = ref.watch(interactionStateProvider(widget.levelId));
                final paletteState = ref.watch(paletteStateProvider(widget.levelId));

                // Group components by type for better display
                final componentsByType = <String, int>{};
                for (final component in gameState.grid.components.values) {
                  final typeKey = component.type.toString().split('.').last;
                  componentsByType[typeKey] = (componentsByType[typeKey] ?? 0) + 1;
                }

                // Log GRID STATE metrics (controlled by debugDashboard flag)
                if (StructuredLogger.debugDashboard) {
                  StructuredLogger.gameCanvas('📊 GRID STATE metrics calculated', context: {
                    'levelId': widget.levelId,
                    'componentsCount': gameState.grid.components.length,
                    'gridDimensions': '${gameState.grid.rows}x${gameState.grid.cols}',
                    'occupiedCells': gameState.grid.components.length,
                    'freeCells': (gameState.grid.rows * gameState.grid.cols) - gameState.grid.components.length,
                    'componentsByType': componentsByType,
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  });
                }

                // Calculate inventory summary
                final totalAvailable = paletteState.inventory.values.fold<int>(
                  0, (sum, inv) => sum + inv.available);
                final totalUsed = paletteState.inventory.values.fold<int>(
                  0, (sum, inv) => sum + (inv.total - inv.available));

                final totalCapacity = totalAvailable + totalUsed;
                final utilizationPercentage = totalUsed > 0 ? ((totalUsed / totalCapacity) * 100).round() : 0;

                // Log INVENTORY SUMMARY metrics (controlled by debugDashboard flag)
                if (StructuredLogger.debugDashboard) {
                  StructuredLogger.gameCanvas('📦 INVENTORY SUMMARY metrics calculated', context: {
                    'levelId': widget.levelId,
                    'totalAvailable': totalAvailable,
                    'totalUsed': totalUsed,
                    'totalCapacity': totalCapacity,
                    'utilizationPercentage': utilizationPercentage,
                    'inventoryDetail': paletteState.inventory.entries.map((e) {
                      final type = e.key.toString().split('.').last;
                      final inv = e.value;
                      return '${type}:${inv.available}/${inv.total}(${inv.total - inv.available}used)';
                    }).toList(),
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  });
                }

                // Additional logging for dashboard sections when populated
                if (componentsByType.isNotEmpty && StructuredLogger.debugDashboard) {
                  StructuredLogger.gameCanvas('🔧 COMPONENTS BY TYPE dashboard section updated', context: {
                    'levelId': widget.levelId,
                    'componentBreakdown': componentsByType,
                    'totalTypes': componentsByType.length,
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  });
                }

                if (paletteState.inventory.isNotEmpty && StructuredLogger.debugDashboard) {
                  StructuredLogger.gameCanvas('📋 COMPONENT INVENTORY dashboard section updated', context: {
                    'levelId': widget.levelId,
                    'inventoryCount': paletteState.inventory.length,
                    'detailedInventory': paletteState.inventory.entries.map((e) {
                      final type = e.key.toString().split('.').last;
                      final inv = e.value;
                      return '${type}: ${inv.available}/${inv.total}(${inv.used}used)';
                    }).toList(),
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  });
                }

                return Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Text(
                                '🔧 DEBUG DASHBOARD',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: interactionState.isValid ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Interaction State
                          _buildDebugSection('🎯 INTERACTION STATE', [
                            'Mode: ${interactionState.currentMode.toString().split('.').last}',
                            'Valid: ${interactionState.isValid}',
                            'Selected: ${interactionState.componentData?.componentName ?? "None"}',
                            'Target: ${interactionState.targetPosition?.toString() ?? "None"}',
                            'Path Length: ${interactionState.path.length}',
                          ]),

                          const SizedBox(height: 8),

                          // Grid State
                          _buildDebugSection('📊 GRID STATE', [
                            'Components: ${gameState.grid.components.length}',
                            'Grid Size: ${gameState.grid.rows}x${gameState.grid.cols}',
                            'Occupied Cells: ${gameState.grid.components.length}',
                            'Free Cells: ${(gameState.grid.rows * gameState.grid.cols) - gameState.grid.components.length}',
                          ]),

                          const SizedBox(height: 8),

                          // Components by Type
                          _buildDebugSection('🔧 COMPONENTS BY TYPE',
                            componentsByType.entries.map((e) => '${e.key}: ${e.value}').toList()
                          ),

                          const SizedBox(height: 8),

                          // Inventory Summary
                          _buildDebugSection('📦 INVENTORY SUMMARY', [
                            'Total Available: $totalAvailable',
                            'Total Used: $totalUsed',
                            'Total Capacity: ${totalAvailable + totalUsed}',
                            'Utilization: $utilizationPercentage%',
                          ]),

                          const SizedBox(height: 8),

                          // Individual Component Inventory
                          _buildDebugSection('📋 COMPONENT INVENTORY',
                            paletteState.inventory.entries.map((e) {
                              final type = e.key.toString().split('.').last;
                              final inv = e.value;
                              return '$type: ${inv.available}/${inv.total} (${inv.used} used)';
                            }).toList()
                          ),

                          const SizedBox(height: 8),

                          // Error Display
                          if (interactionState.errorMessage != null)
                            _buildDebugSection('❌ ERROR', [
                              interactionState.errorMessage!,
                            ], Colors.red[100]!),

                          // Performance metrics
                          _buildDebugSection('⚡ PERFORMANCE', [
                            'Grid Components: ${gameState.grid.components.length}',
                            'Palette Items: ${paletteState.filteredComponents.length}',
                            'Interaction Mode: ${interactionState.currentMode.toString().split('.').last}',
                          ]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  ),
);
  }

  Widget _buildDebugSection(String title, List<String> items, [Color? backgroundColor]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          )),
        ],
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