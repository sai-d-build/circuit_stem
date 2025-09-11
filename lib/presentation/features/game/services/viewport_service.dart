import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

part 'viewport_service.freezed.dart';

@freezed
class ViewportState with _$ViewportState {
  const factory ViewportState({
    @Default(1.0) double scale,
    @Default(Offset.zero) Offset panOffset,
    @Default(Size.zero) Size canvasSize,
    @Default(Size(20, 15)) Size gridConfiguration,
    @Default(60.0) double cellSize,
  }) = _ViewportState;
}

final viewportServiceProvider = StateNotifierProvider.family<ViewportService, ViewportState, String>(
  (ref, levelId) => ViewportService(
    initialState: const ViewportState(),
  ),
);

class ViewportService extends StateNotifier<ViewportState> {
  ViewportService({
    required ViewportState initialState,
  }) : super(initialState);

  void updateScale(double newScale) {
    state = state.copyWith(scale: newScale.clamp(0.1, 5.0));
  }

  void updatePan(Offset delta) {
    state = state.copyWith(panOffset: state.panOffset + delta);
  }

  void setCanvasSize(Size size) {
    state = state.copyWith(canvasSize: size);
  }

  void reset() {
    state = const ViewportState();
  }


  /// Calculate visible grid bounds for optimization
  /// Calculate visible grid bounds for optimization
  Rect getVisibleGridBounds() {
    final gridConfig = GridConfiguration(
      rows: state.gridConfiguration.height.toInt(),
      cols: state.gridConfiguration.width.toInt(),
      cellSize: state.cellSize,
      scale: state.scale,
      panOffset: state.panOffset,
    );

    final topLeft = const Offset(0, 0);
    final bottomRight = Offset(state.canvasSize.width, state.canvasSize.height);

    final topLeftGrid = UnifiedCoordinateService().screenToGrid(topLeft, gridConfig);
    final bottomRightGrid = UnifiedCoordinateService().screenToGrid(bottomRight, gridConfig);

    return Rect.fromPoints(topLeftGrid, bottomRightGrid);
  }
}