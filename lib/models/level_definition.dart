import 'package:freezed_annotation/freezed_annotation.dart';
import 'component.dart';
import 'goal.dart';
import 'hint.dart';
import 'position.dart';
import '../core/component_registry.dart';
import '../common/logger.dart'; // Import Logger

part 'level_definition.freezed.dart';
 

@freezed
class LevelDefinition with _$LevelDefinition {
  const factory LevelDefinition({
    required String id,
    required String title,
    required String description,
    required int levelNumber,
    required String author,
    required int version,
    required int rows,
    required int cols,
    required List<Position> blockedCells,
    required List<ComponentModel> initialComponents,
    required List<ComponentModel> paletteComponents,
    required List<Goal> goals,
    required List<Hint> hints,
  }) = _LevelDefinition;

  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    Logger.log('LevelDefinition.fromJson: Raw JSON: $json'); // Add logger
    // Use ComponentRegistry.createFromJson to ensure behaviors are attached
    final initialComponents = (json['initialComponents'] as List<dynamic>)
        .map((e) => ComponentRegistry.createFromJson(e as Map<String, dynamic>))
        .toList();
    Logger.log('LevelDefinition.fromJson: Parsed initialComponents: $initialComponents'); // Add logger
    
    final paletteComponents = (json['paletteComponents'] as List<dynamic>)
        .map((e) => ComponentRegistry.createFromJson(e as Map<String, dynamic>))
        .toList();
    Logger.log('LevelDefinition.fromJson: Parsed paletteComponents: $paletteComponents'); // Add logger

    return _$LevelDefinitionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      levelNumber: (json['levelNumber'] as num).toInt(),
      author: json['author'] as String,
      version: (json['version'] as num).toInt(),
      rows: (json['rows'] as num).toInt(),
      cols: (json['cols'] as num).toInt(),
      blockedCells: (json['blockedCells'] as List<dynamic>)
          .map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList(),
      initialComponents: initialComponents,
      paletteComponents: paletteComponents,
      goals: (json['goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>)
          .map((e) => Hint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}