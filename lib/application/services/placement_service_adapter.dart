import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/features/game/services/viewport_service.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

class PlacementServiceAdapter {
  final WidgetRef ref;
  final String levelId;

  PlacementServiceAdapter({required this.ref, required this.levelId});

  Future<bool> placeComponent(ComponentType componentType, int row, int col) async {
    try {
      // Validate position using CoordinateService
      final viewportService = ref.read(viewportServiceProvider(levelId).notifier);
      final context = viewportService.buildCoordinateContext(
        gridDimensions: Size(20, 15), // Get from game state
        devicePixelRatio: 1.0,
      );

      final mockBox = MockRenderBox(Size.infinite);
      final validation = CoordinateSystemService().validateDropPosition(
        Offset.zero, // Not used in mock
        context,
        mockBox,
        occupiedPositions: _getOccupiedPositions(),
      );

      if (!validation.isValid) {
        return false;
      }

      // Place component using v3 notifier
      final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);
      gameNotifier.placeComponent(componentType, row, col);

      // Update palette state
      final paletteState = ref.read(paletteStateProvider(levelId));
      final componentName = componentType.toString().split('.').last;
      if (!paletteState.canUseComponent(componentName)) {
        return false;
      }

      ref.read(paletteStateProvider(levelId).notifier).stopPlacingComponent();
      return true;
    } catch (e) {
      debugPrint('PlacementServiceAdapter error: $e');
      return false;
    }
  }

  Future<bool> placeWire(List<GridPosition> path) async {
    try {
      // Validate wire path
      if (path.isEmpty) return false;

      // For now, place as special wire component
      // final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);

      // This would need extension in v3 to support wire paths
      // gameNotifier.placeWire(path);

      return true;
    } catch (e) {
      debugPrint('Wire placement error: $e');
      return false;
    }
  }

  Set<GridPosition> _getOccupiedPositions() {
    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    return gameState.grid.components.values
        .map((component) => GridPosition(row: component.row, col: component.col))
        .toSet();
  }
}

class MockRenderBox extends RenderBox {
  MockRenderBox([Size? size]) {
    if (size != null) {
      this.size = size;
    }
  }

  @override
  bool get attached => true;

  @override
  Offset globalToLocal(Offset globalPosition, {RenderObject? ancestor}) => globalPosition;
}