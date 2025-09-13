import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

part 'game_canvas_state.freezed.dart';
part 'game_canvas_state.g.dart';

// JsonConverter for Offset type
class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(json['dx'] as double, json['dy'] as double);
  }

  @override
  Map<String, dynamic> toJson(Offset offset) {
    return {'dx': offset.dx, 'dy': offset.dy};
  }
}

@freezed
class GameCanvasState with _$GameCanvasState {
  const factory GameCanvasState({
    required LevelDefinition? currentLevel,
    required CanvasRenderingData renderingData,
    required InteractionState interactionState,
    required ViewportState viewportState,
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default({}) Map<String, dynamic> debugInfo,
  }) = _GameCanvasState;

  factory GameCanvasState.initial() => GameCanvasState(
        currentLevel: null,
        renderingData: CanvasRenderingData.empty(),
        interactionState: InteractionState.idle(),
        viewportState: ViewportState.defaultViewport(),
      );
}

@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    required GestureMode mode,
    @Default(null) String? selectedComponentId,
    @Default(null) String? draggedComponentId,
    @Default(null) ComponentType? placingComponentType,
    @Default(null) GridPosition? dragStartPosition,
    @Default(null) GridPosition? currentDragPosition,
    @OffsetConverter() Offset? dragPosition,
    @Default(null) ComponentType? draggedComponentType,
    @OffsetConverter() Offset? mousePosition,
  }) = _InteractionState;

  factory InteractionState.idle() => const InteractionState(
        mode: GestureMode.idle,
        dragPosition: null,
        draggedComponentType: null,
        mousePosition: null,
      );

  factory InteractionState.fromJson(Map<String, dynamic> json) =>
      _$InteractionStateFromJson(json);
}

@freezed
class ViewportState with _$ViewportState {
  const factory ViewportState({
    required double scale,
    @OffsetConverter() required Offset panOffset,
    required Size canvasSize,
    required GridConfiguration gridConfiguration,
  }) = _ViewportState;

  factory ViewportState.defaultViewport() => ViewportState(
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: const Size(800, 600),
        gridConfiguration: GridConfiguration.standard(),
      );
}

@freezed
class CanvasRenderingData with _$CanvasRenderingData {
  const factory CanvasRenderingData({
    @Default([]) List<CircuitComponent> components,
    @Default([]) List<CircuitWire> wires,
    @Default([]) List<GridCell> gridCells,
    required GridConfiguration gridConfiguration,
    @Default({}) Map<String, dynamic> effectsData,
  }) = _CanvasRenderingData;

  factory CanvasRenderingData.empty() => CanvasRenderingData(
        gridConfiguration: GridConfiguration.standard(),
      );

  factory CanvasRenderingData.fromJson(Map<String, dynamic> json) =>
      _$CanvasRenderingDataFromJson(json);
}

@freezed
class GridPosition with _$GridPosition {
  const factory GridPosition({
    required int row,
    required int col,
  }) = _GridPosition;

  factory GridPosition.fromJson(Map<String, dynamic> json) =>
      _$GridPositionFromJson(json);
}

@freezed
class GridConfiguration with _$GridConfiguration {
  const factory GridConfiguration({
    @Default(20) int rows,
    @Default(20) int cols,
    @Default(60.0) double cellSize,
  }) = _GridConfiguration;

  factory GridConfiguration.standard() => const GridConfiguration();

  factory GridConfiguration.fromJson(Map<String, dynamic> json) =>
      _$GridConfigurationFromJson(json);
}

@freezed
class CircuitComponent with _$CircuitComponent {
  const factory CircuitComponent({
    required String id,
    required ComponentType type,
    required int row,
    required int col,
    @Default({}) Map<String, dynamic> properties,
    @Default(false) bool isSelected,
    @Default(false) bool isHighlighted,
  }) = _CircuitComponent;

  factory CircuitComponent.fromJson(Map<String, dynamic> json) =>
      _$CircuitComponentFromJson(json);
}

@freezed
class CircuitWire with _$CircuitWire {
  const factory CircuitWire({
    required String id,
    required int startRow,
    required int startCol,
    required int endRow,
    required int endCol,
    @Default(false) bool isActive,
    @Default(2.0) double thickness,
  }) = _CircuitWire;

  factory CircuitWire.fromJson(Map<String, dynamic> json) =>
      _$CircuitWireFromJson(json);
}

@freezed
class GridCell with _$GridCell {
  const factory GridCell({
    required int row,
    required int col,
    @Default(false) bool isOccupied,
    @Default(false) bool isHighlighted,
    @Default(null) String? componentId,
  }) = _GridCell;

  factory GridCell.fromJson(Map<String, dynamic> json) =>
      _$GridCellFromJson(json);
}

enum GestureMode {
  idle,
  panning,
  draggingExistingComponent,
  placingNewComponent,
  drawingWire,
  multiTouchScaling
}
