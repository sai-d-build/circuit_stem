import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';

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

  /// Build CoordinateContext for integration with CoordinateSystemService
  CoordinateContext buildCoordinateContext({
    Size? gridDimensions,
    double? devicePixelRatio,
  }) {
    return CoordinateContext(
      gridDimensions: gridDimensions ?? state.gridConfiguration,
      cellSize: state.cellSize,
      scale: state.scale,
      panOffset: state.panOffset,
      canvasSize: state.canvasSize,
      devicePixelRatio: devicePixelRatio ?? 1.0,
    );
  }

  /// Calculate visible grid bounds for optimization
  Rect getVisibleGridBounds() {
    final context = buildCoordinateContext();
    final topLeft = const Offset(0, 0);
    final bottomRight = state.canvasSize;

    final topLeftGrid = CoordinateSystemService().screenToGrid(
      topLeft,
      context,
      // This would need a RenderBox in real usage
      _createMockRenderBox(),
    );

    final bottomRightGrid = CoordinateSystemService().screenToGrid(
      Offset(bottomRight.width, bottomRight.height),
      context,
      _createMockRenderBox(),
    );

    if (topLeftGrid != null && bottomRightGrid != null) {
      return Rect.fromPoints(
        topLeftGrid.toOffset(),
        bottomRightGrid.toOffset(),
      );
    }

    return Rect.zero;
  }

  RenderBox _createMockRenderBox() {
    // Mock implementation for bounds calculation
    return _MockRenderBox(size: state.canvasSize);
  }
}

class _MockRenderBox extends RenderBox {
  _MockRenderBox({required Size size}) {
    this.size = size;
  }

  @override
  bool get attached => true;

  @override
  Offset globalToLocal(Offset globalPosition, {RenderObject? ancestor}) => globalPosition;
}