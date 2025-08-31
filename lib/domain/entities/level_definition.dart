
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/domain/entities/component.dart';

part 'level_definition.freezed.dart';
part 'level_definition.g.dart';

@freezed
class LevelDefinition with _$LevelDefinition {
  const factory LevelDefinition({
    required String id,
    required int levelNumber,
    required String title,
    required String description,
    required int rows,
    required int cols,
    required List<ComponentModel> initialComponentsList,
    required List<ComponentType> paletteComponents,
    required List<Map<String, dynamic>> validationRules,
  }) = _LevelDefinition;

  factory LevelDefinition.fromJson(Map<String, dynamic> json) =>
      _$LevelDefinitionFromJson(json);
}
