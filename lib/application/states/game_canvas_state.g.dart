// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_canvas_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InteractionStateImpl _$$InteractionStateImplFromJson(Map json) =>
    $checkedCreate(
      r'_$InteractionStateImpl',
      json,
      ($checkedConvert) {
        final val = _$InteractionStateImpl(
          mode: $checkedConvert(
              'mode', (v) => $enumDecode(_$GestureModeEnumMap, v)),
          selectedComponentId: $checkedConvert(
              'selectedComponentId', (v) => v as String? ?? null),
          draggedComponentId: $checkedConvert(
              'draggedComponentId', (v) => v as String? ?? null),
          placingComponentType: $checkedConvert('placingComponentType',
              (v) => $enumDecodeNullable(_$ComponentTypeEnumMap, v) ?? null),
          dragStartPosition: $checkedConvert(
              'dragStartPosition',
              (v) => v == null
                  ? null
                  : GridPosition.fromJson(Map<String, dynamic>.from(v as Map))),
          currentDragPosition: $checkedConvert(
              'currentDragPosition',
              (v) => v == null
                  ? null
                  : GridPosition.fromJson(Map<String, dynamic>.from(v as Map))),
          dragPosition: $checkedConvert(
              'dragPosition',
              (v) => _$JsonConverterFromJson<Map<String, dynamic>, Offset>(
                  v, const OffsetConverter().fromJson)),
          draggedComponentType: $checkedConvert('draggedComponentType',
              (v) => $enumDecodeNullable(_$ComponentTypeEnumMap, v) ?? null),
          mousePosition: $checkedConvert(
              'mousePosition',
              (v) => _$JsonConverterFromJson<Map<String, dynamic>, Offset>(
                  v, const OffsetConverter().fromJson)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$InteractionStateImplToJson(
        _$InteractionStateImpl instance) =>
    <String, dynamic>{
      'mode': _$GestureModeEnumMap[instance.mode]!,
      'selectedComponentId': instance.selectedComponentId,
      'draggedComponentId': instance.draggedComponentId,
      'placingComponentType':
          _$ComponentTypeEnumMap[instance.placingComponentType],
      'dragStartPosition': instance.dragStartPosition?.toJson(),
      'currentDragPosition': instance.currentDragPosition?.toJson(),
      'dragPosition': _$JsonConverterToJson<Map<String, dynamic>, Offset>(
          instance.dragPosition, const OffsetConverter().toJson),
      'draggedComponentType':
          _$ComponentTypeEnumMap[instance.draggedComponentType],
      'mousePosition': _$JsonConverterToJson<Map<String, dynamic>, Offset>(
          instance.mousePosition, const OffsetConverter().toJson),
    };

const _$GestureModeEnumMap = {
  GestureMode.idle: 'idle',
  GestureMode.panning: 'panning',
  GestureMode.draggingExistingComponent: 'draggingExistingComponent',
  GestureMode.placingNewComponent: 'placingNewComponent',
  GestureMode.drawingWire: 'drawingWire',
  GestureMode.multiTouchScaling: 'multiTouchScaling',
};

const _$ComponentTypeEnumMap = {
  ComponentType.battery: 'battery',
  ComponentType.resistor: 'resistor',
  ComponentType.capacitor: 'capacitor',
  ComponentType.inductor: 'inductor',
  ComponentType.diode: 'diode',
  ComponentType.transistor: 'transistor',
  ComponentType.switch_: 'switch_',
  ComponentType.bulb: 'bulb',
  ComponentType.buzzer: 'buzzer',
  ComponentType.timer: 'timer',
  ComponentType.wire: 'wire',
  ComponentType.ground: 'ground',
  ComponentType.voltageSource: 'voltageSource',
  ComponentType.currentSource: 'currentSource',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$CanvasRenderingDataImpl _$$CanvasRenderingDataImplFromJson(Map json) =>
    $checkedCreate(
      r'_$CanvasRenderingDataImpl',
      json,
      ($checkedConvert) {
        final val = _$CanvasRenderingDataImpl(
          components: $checkedConvert(
              'components',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => CircuitComponent.fromJson(
                          Map<String, dynamic>.from(e as Map)))
                      .toList() ??
                  const []),
          wires: $checkedConvert(
              'wires',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => CircuitWire.fromJson(
                          Map<String, dynamic>.from(e as Map)))
                      .toList() ??
                  const []),
          gridCells: $checkedConvert(
              'gridCells',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => GridCell.fromJson(
                          Map<String, dynamic>.from(e as Map)))
                      .toList() ??
                  const []),
          gridConfiguration: $checkedConvert(
              'gridConfiguration',
              (v) => GridConfiguration.fromJson(
                  Map<String, dynamic>.from(v as Map))),
          effectsData: $checkedConvert(
              'effectsData',
              (v) =>
                  (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  ) ??
                  const {}),
        );
        return val;
      },
    );

Map<String, dynamic> _$$CanvasRenderingDataImplToJson(
        _$CanvasRenderingDataImpl instance) =>
    <String, dynamic>{
      'components': instance.components.map((e) => e.toJson()).toList(),
      'wires': instance.wires.map((e) => e.toJson()).toList(),
      'gridCells': instance.gridCells.map((e) => e.toJson()).toList(),
      'gridConfiguration': instance.gridConfiguration.toJson(),
      'effectsData': instance.effectsData,
    };

_$GridPositionImpl _$$GridPositionImplFromJson(Map json) => $checkedCreate(
      r'_$GridPositionImpl',
      json,
      ($checkedConvert) {
        final val = _$GridPositionImpl(
          row: $checkedConvert('row', (v) => (v as num).toInt()),
          col: $checkedConvert('col', (v) => (v as num).toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$GridPositionImplToJson(_$GridPositionImpl instance) =>
    <String, dynamic>{
      'row': instance.row,
      'col': instance.col,
    };

_$GridConfigurationImpl _$$GridConfigurationImplFromJson(Map json) =>
    $checkedCreate(
      r'_$GridConfigurationImpl',
      json,
      ($checkedConvert) {
        final val = _$GridConfigurationImpl(
          rows: $checkedConvert('rows', (v) => (v as num?)?.toInt() ?? 20),
          cols: $checkedConvert('cols', (v) => (v as num?)?.toInt() ?? 20),
          cellSize: $checkedConvert(
              'cellSize', (v) => (v as num?)?.toDouble() ?? 60.0),
        );
        return val;
      },
    );

Map<String, dynamic> _$$GridConfigurationImplToJson(
        _$GridConfigurationImpl instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'cols': instance.cols,
      'cellSize': instance.cellSize,
    };

_$CircuitComponentImpl _$$CircuitComponentImplFromJson(Map json) =>
    $checkedCreate(
      r'_$CircuitComponentImpl',
      json,
      ($checkedConvert) {
        final val = _$CircuitComponentImpl(
          id: $checkedConvert('id', (v) => v as String),
          type: $checkedConvert(
              'type', (v) => $enumDecode(_$ComponentTypeEnumMap, v)),
          row: $checkedConvert('row', (v) => (v as num).toInt()),
          col: $checkedConvert('col', (v) => (v as num).toInt()),
          properties: $checkedConvert(
              'properties',
              (v) =>
                  (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  ) ??
                  const {}),
          isSelected: $checkedConvert('isSelected', (v) => v as bool? ?? false),
          isHighlighted:
              $checkedConvert('isHighlighted', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$$CircuitComponentImplToJson(
        _$CircuitComponentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ComponentTypeEnumMap[instance.type]!,
      'row': instance.row,
      'col': instance.col,
      'properties': instance.properties,
      'isSelected': instance.isSelected,
      'isHighlighted': instance.isHighlighted,
    };

_$CircuitWireImpl _$$CircuitWireImplFromJson(Map json) => $checkedCreate(
      r'_$CircuitWireImpl',
      json,
      ($checkedConvert) {
        final val = _$CircuitWireImpl(
          id: $checkedConvert('id', (v) => v as String),
          startRow: $checkedConvert('startRow', (v) => (v as num).toInt()),
          startCol: $checkedConvert('startCol', (v) => (v as num).toInt()),
          endRow: $checkedConvert('endRow', (v) => (v as num).toInt()),
          endCol: $checkedConvert('endCol', (v) => (v as num).toInt()),
          isActive: $checkedConvert('isActive', (v) => v as bool? ?? false),
          thickness: $checkedConvert(
              'thickness', (v) => (v as num?)?.toDouble() ?? 2.0),
        );
        return val;
      },
    );

Map<String, dynamic> _$$CircuitWireImplToJson(_$CircuitWireImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startRow': instance.startRow,
      'startCol': instance.startCol,
      'endRow': instance.endRow,
      'endCol': instance.endCol,
      'isActive': instance.isActive,
      'thickness': instance.thickness,
    };

_$GridCellImpl _$$GridCellImplFromJson(Map json) => $checkedCreate(
      r'_$GridCellImpl',
      json,
      ($checkedConvert) {
        final val = _$GridCellImpl(
          row: $checkedConvert('row', (v) => (v as num).toInt()),
          col: $checkedConvert('col', (v) => (v as num).toInt()),
          isOccupied: $checkedConvert('isOccupied', (v) => v as bool? ?? false),
          isHighlighted:
              $checkedConvert('isHighlighted', (v) => v as bool? ?? false),
          componentId:
              $checkedConvert('componentId', (v) => v as String? ?? null),
        );
        return val;
      },
    );

Map<String, dynamic> _$$GridCellImplToJson(_$GridCellImpl instance) =>
    <String, dynamic>{
      'row': instance.row,
      'col': instance.col,
      'isOccupied': instance.isOccupied,
      'isHighlighted': instance.isHighlighted,
      'componentId': instance.componentId,
    };
