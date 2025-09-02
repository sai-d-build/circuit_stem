import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import './level_goal.dart';

part 'level_definition.freezed.dart';
part 'level_definition.g.dart';

// V2 API Extensions for backward compatibility
extension LevelDefinitionV2Extensions on LevelDefinition {
  /// Get level number (V2 API compatibility)
  int get levelNumber {
    // Extract number from levelId (e.g., "level_01" -> 1)
    final match = RegExp(r'(\d+)$').firstMatch(levelId);
    return match != null ? int.parse(match.group(1)!) : 1;
  }

  /// Get grid rows (V2 API compatibility)
  int get rows => grid.height;

  /// Get grid columns (V2 API compatibility)
  int get cols => grid.width;

  /// Get initial components list (V2 API compatibility)
  List<ComponentModel> get initialComponentsList {
    return components.preplaced?.map((preplaced) {
      // Convert string type to ComponentType enum
      ComponentType componentType;
      try {
        componentType = ComponentType.values.firstWhere(
          (type) => type.toString().split('.').last == preplaced.type,
        );
      } catch (e) {
        // Default to wire if type not found
        componentType = ComponentType.wire;
      }

      // Convert PreplacedComponent to ComponentModel
      return ComponentModel(
        id: preplaced.id,
        type: componentType,
        row: preplaced.position.row,
        col: preplaced.position.col,
        rotation: preplaced.rotation ?? 0,
        properties: preplaced.properties ?? {},
      );
    }).toList() ?? [];
  }

  /// Get level title (V2 API compatibility)
  String get title => metadata.title;

  /// Get level ID (V2 API compatibility)
  String get id => levelId;
}

// Main Level Definition
@JsonSerializable()
@freezed
class LevelDefinition with _$LevelDefinition {
  const factory LevelDefinition({
    required String levelId,
    required String version,
    required LevelMetadata metadata,
    required GridConfig grid,
    required ComponentConfig components,
    required List<LevelGoal> goals,
    required ValidationRules validation,
    TutorialConfig? tutorial,
    ScoringConfig? scoring,
  }) = _LevelDefinition;

  factory LevelDefinition.fromJson(Map<String, dynamic> json) => _$LevelDefinitionFromJson(json);
}

// Level Metadata
@freezed
@JsonSerializable()
class LevelMetadata with _$LevelMetadata {
  const factory LevelMetadata({
    required String id,
    required String title,
    required String description,
    required String difficulty,
    bool? unlocked,
    int? estimatedTime,
    List<String>? learningObjectives,
    List<String>? tags,
    List<String>? unlocksComponents,
    List<String>? prerequisites,
  }) = _LevelMetadata;

  factory LevelMetadata.fromJson(Map<String, dynamic> json) => _$LevelMetadataFromJson(json);
}

// Grid Configuration
@freezed
class GridConfig with _$GridConfig {
  const factory GridConfig({
    required int width,
    required int height,
    String? background,
  }) = _GridConfig;

  factory GridConfig.fromJson(Map<String, dynamic> json) => _$GridConfigFromJson(json);
}

// Component Configuration
@freezed
class ComponentConfig with _$ComponentConfig {
  const factory ComponentConfig({
    required List<ComponentTemplate> available,
    List<PreplacedComponent>? preplaced,
  }) = _ComponentConfig;

  factory ComponentConfig.fromJson(Map<String, dynamic> json) => _$ComponentConfigFromJson(json);
}

// Component Template
@freezed
class ComponentTemplate with _$ComponentTemplate {
  const factory ComponentTemplate({
    required String type,
    required int quantity,
    Map<String, dynamic>? properties,
  }) = _ComponentTemplate;

  factory ComponentTemplate.fromJson(Map<String, dynamic> json) => _$ComponentTemplateFromJson(json);
}

// Pre-placed Component
@freezed
class PreplacedComponent with _$PreplacedComponent {
  const factory PreplacedComponent({
    required String id,
    required String type,
    required Position position,
    int? rotation,
    Map<String, dynamic>? properties,
  }) = _PreplacedComponent;

  factory PreplacedComponent.fromJson(Map<String, dynamic> json) => _$PreplacedComponentFromJson(json);
}

// Position
@freezed
class Position with _$Position {
  const factory Position({
    required int row,
    required int col,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) => _$PositionFromJson(json);
}

// Goal Definition
@freezed
class LevelGoalInfo with _$LevelGoalInfo {
  const factory LevelGoalInfo({
    required String id,
    required String type,
    required String description,
    Map<String, dynamic>? conditions,
    List<Hint>? hints,
    int? timeLimit,
  }) = _LevelGoalInfo;

  
}

// Hint
@freezed
class Hint with _$Hint {
  const factory Hint({
    required String id,
    required String text,
    String? trigger,
    dynamic triggerValue,
  }) = _Hint;

  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);
}

// Validation Rules
@freezed
class ValidationRules with _$ValidationRules {
  const factory ValidationRules({
    required List<String> circuitRules,
    required List<String> successConditions,
  }) = _ValidationRules;

  factory ValidationRules.fromJson(Map<String, dynamic> json) => _$ValidationRulesFromJson(json);
}

// Tutorial Configuration
@freezed
class TutorialConfig with _$TutorialConfig {
  const factory TutorialConfig({
    required bool enabled,
    List<TutorialStep>? steps,
  }) = _TutorialConfig;

  factory TutorialConfig.fromJson(Map<String, dynamic> json) => _$TutorialConfigFromJson(json);
}

// Tutorial Step
@freezed
class TutorialStep with _$TutorialStep {
  const factory TutorialStep({
    required String id,
    required String title,
    required String description,
    String? highlight,
    String? requiredAction,
  }) = _TutorialStep;

  factory TutorialStep.fromJson(Map<String, dynamic> json) => _$TutorialStepFromJson(json);
}

// Scoring Configuration
@freezed
class ScoringConfig with _$ScoringConfig {
  const factory ScoringConfig({
    required int maxScore,
    TimeBonus? timeBonus,
    EfficiencyBonus? efficiencyBonus,
    StarThresholds? starThresholds,
  }) = _ScoringConfig;

  factory ScoringConfig.fromJson(Map<String, dynamic> json) => _$ScoringConfigFromJson(json);
}

// Time Bonus
@freezed
class TimeBonus with _$TimeBonus {
  const factory TimeBonus({
    required int maxTime,
    required int bonusPerSecond,
  }) = _TimeBonus;

  factory TimeBonus.fromJson(Map<String, dynamic> json) => _$TimeBonusFromJson(json);
}

// Efficiency Bonus
@freezed
class EfficiencyBonus with _$EfficiencyBonus {
  const factory EfficiencyBonus({
    required int maxComponents,
    required int bonusPerUnusedComponent,
  }) = _EfficiencyBonus;

  factory EfficiencyBonus.fromJson(Map<String, dynamic> json) => _$EfficiencyBonusFromJson(json);
}

// Star Thresholds
@freezed
class StarThresholds with _$StarThresholds {
  const factory StarThresholds({
    required int threeStars,
    required int twoStars,
    required int oneStar,
  }) = _StarThresholds;

  factory StarThresholds.fromJson(Map<String, dynamic> json) => _$StarThresholdsFromJson(json);
}