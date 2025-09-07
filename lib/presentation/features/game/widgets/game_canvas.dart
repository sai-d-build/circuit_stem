import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import '../../../../application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart' as core_providers;
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';

import 'canvas_interaction_widget.dart';
import 'canvas_rendering_layer.dart';
import 'canvas_wire_layer.dart';
import 'package:sparkcircuit/presentation/features/game/services/viewport_service.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart';

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
    print('🎮 GameCanvas: Starting level load process for ${widget.levelId}');
    StructuredLogger.info('GameCanvas: Starting level load process', context: {
      'levelId': widget.levelId,
    });

    try {
      final levelService = ref.read(providers_v3.levelServiceProvider);
      print('🎮 GameCanvas: Got level service: $levelService');
      final level = await levelService.loadLevel(widget.levelId);
      print('🎮 GameCanvas: Level loaded: ${level?.levelId ?? "NULL"}');

      if (level != null) {
        print('🎮 GameCanvas: Loading level into game state');
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
        print('🎮 GameCanvas: Level load completed successfully');
      } else {
        print('🎮 GameCanvas: Level is NULL - this is the problem!');
      }
    } catch (e) {
      print('🎮 GameCanvas: Error loading level: $e');
      StructuredLogger.error('GameCanvas: Error loading level', context: {
        'levelId': widget.levelId,
        'errorType': e.runtimeType.toString(),
        'errorMessage': e.toString(),
      }, error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎮 GameCanvas: BUILD METHOD CALLED for level ${widget.levelId}');
    print('🎮 GameCanvas: Building level ${widget.levelId}');
    StructuredLogger.trace('GameCanvas: Building - checking orchestrator state', context: {
      'context_available': context != null,
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
          print('🎮 GameCanvas: Container constraints: ${constraints.toString()}');
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
                      'contextAvailable': context != null,
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
              Consumer(
                builder: (context, ref, child) {
                  final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CanvasRenderingLayer(levelId: widget.levelId),
                    ),
                  );
                },
              ),
  
              // Component widgets - must allow touch pass-through
              // These need to be draggable themselves but shouldn't block the canvas
              Consumer(
                builder: (context, ref, child) {
                  final componentState = ref.watch(providers_v3.enhancedGameStateNotifierProvider.select((state) => state.grid.components));
                  return Positioned.fill(
                    child: IgnorePointer(
                      // 🔧 CRITICAL: Allow components to be interactive but pass through canvas drags
                      ignoring: false, // Allow component interaction
                      child: Stack(
                        children: componentState.values.map((component) =>
                          // Components handle their own interaction - don't block canvas
                          Positioned(
                            left: component.col * 60.0, // Use a constant for cell size
                            top: component.row * 60.0,  // Use a constant for cell size
                            child: AbsorbPointer(
                              absorbing: false, // Allow component interaction
                              child: CircuitComponentWidget(
                                key: ValueKey(component.id),
                                component: component,
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
                final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);
                final interactionState = ref.watch(interactionStateProvider(widget.levelId));
                final paletteState = ref.watch(paletteStateProvider(widget.levelId));

                // Group components by type for better display
                final componentsByType = <String, int>{};
                for (final component in gameState.grid.components.values) {
                  final typeKey = component.type.toString().split('.').last;
                  componentsByType[typeKey] = (componentsByType[typeKey] ?? 0) + 1;
                }

                // Calculate inventory summary
                final totalAvailable = paletteState.inventory.values.fold<int>(
                  0, (sum, inv) => sum + inv.available);
                final totalUsed = paletteState.inventory.values.fold<int>(
                  0, (sum, inv) => sum + (inv.total - inv.available));

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
                            'Utilization: ${totalUsed > 0 ? (((totalUsed / (totalAvailable + totalUsed)) * 100).round()) : 0}%',
                          ]),

                          const SizedBox(height: 8),

                          // Individual Component Inventory
                          _buildDebugSection('📋 COMPONENT INVENTORY',
                            paletteState.inventory.entries.map((e) {
                              final type = e.key.toString().split('.').last;
                              final inv = e.value;
                              return '$type: ${inv.available}/${inv.total} (${inv.total - inv.available} used)';
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