// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      grid: Grid.fromJson(json['grid'] as Map<String, dynamic>),
      isPaused: json['isPaused'] as bool,
      isWin: json['isWin'] as bool,
      currentLevel: json['currentLevel'] == null
          ? null
          : LevelDefinition.fromJson(
              json['currentLevel'] as Map<String, dynamic>),
      simulationResult: json['simulationResult'] == null
          ? null
          : SimulationResult.fromJson(
              json['simulationResult'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isDebugOverlayVisible: json['isDebugOverlayVisible'] as bool? ?? false,
      interactionState: InteractionState.fromJson(
          json['interactionState'] as Map<String, dynamic>),
      history: HistoryState.fromJson(json['history'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'grid': instance.grid,
      'isPaused': instance.isPaused,
      'isWin': instance.isWin,
      'currentLevel': instance.currentLevel,
      'simulationResult': instance.simulationResult,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isDebugOverlayVisible': instance.isDebugOverlayVisible,
      'interactionState': instance.interactionState,
      'history': instance.history,
    };

_$InteractionStateImpl _$$InteractionStateImplFromJson(
        Map<String, dynamic> json) =>
    _$InteractionStateImpl(
      selectedComponentId: json['selectedComponentId'] as String?,
      draggedComponentId: json['draggedComponentId'] as String?,
      dragStartLocalPosition: _offsetFromJson(
          json['dragStartLocalPosition'] as Map<String, dynamic>?),
      dragUpdateLocalPosition: _offsetFromJson(
          json['dragUpdateLocalPosition'] as Map<String, dynamic>?),
      isDragging: json['isDragging'] as bool? ?? false,
    );

Map<String, dynamic> _$$InteractionStateImplToJson(
        _$InteractionStateImpl instance) =>
    <String, dynamic>{
      'selectedComponentId': instance.selectedComponentId,
      'draggedComponentId': instance.draggedComponentId,
      'dragStartLocalPosition': _offsetToJson(instance.dragStartLocalPosition),
      'dragUpdateLocalPosition':
          _offsetToJson(instance.dragUpdateLocalPosition),
      'isDragging': instance.isDragging,
    };

_$HistoryStateImpl _$$HistoryStateImplFromJson(Map<String, dynamic> json) =>
    _$HistoryStateImpl(
      commands: (json['commands'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$HistoryStateImplToJson(_$HistoryStateImpl instance) =>
    <String, dynamic>{
      'commands': instance.commands,
    };
