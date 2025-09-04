import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/position.dart';
import 'goal.dart';

part 'level_definition.freezed.dart';
part 'level_definition.g.dart';

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

  factory LevelDefinition.fromJson(Map<String, dynamic> json) =>
      _$LevelDefinitionFromJson(json);
}

@freezed
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

  factory LevelMetadata.fromJson(Map<String, dynamic> json) =>
      _$LevelMetadataFromJson(json);
}

@freezed
class GridConfig with _$GridConfig {
  const factory GridConfig({
    required int width,
    required int height,
    String? background,
  }) = _GridConfig;

  factory GridConfig.fromJson(Map<String, dynamic> json) =>
      _$GridConfigFromJson(json);
}

@freezed
class ComponentAvailability with _$ComponentAvailability {
  const factory ComponentAvailability({
    required String type,
    required int quantity,
    Map<String, dynamic>? properties,
  }) = _ComponentAvailability;

  factory ComponentAvailability.fromJson(Map<String, dynamic> json) =>
      _$ComponentAvailabilityFromJson(json);
}

@freezed
class ComponentConfig with _$ComponentConfig {
  const factory ComponentConfig({
    required List<ComponentAvailability> available,
    required List<Position> preplaced,
    Map<String, dynamic>? properties,
  }) = _ComponentConfig;

  factory ComponentConfig.fromJson(Map<String, dynamic> json) =>
      _$ComponentConfigFromJson(json);
}

@freezed
class ValidationRules with _$ValidationRules {
  const factory ValidationRules({
    required List<String> circuitRules,
    required List<String> successConditions,
  }) = _ValidationRules;

  factory ValidationRules.fromJson(Map<String, dynamic> json) =>
      _$ValidationRulesFromJson(json);
}

@freezed
class TutorialStep with _$TutorialStep {
  const factory TutorialStep({
    required String id,
    required String title,
    required String description,
    String? highlight,
    String? requiredAction,
  }) = _TutorialStep;

  factory TutorialStep.fromJson(Map<String, dynamic> json) =>
      _$TutorialStepFromJson(json);
}

@freezed
class TutorialConfig with _$TutorialConfig {
  const factory TutorialConfig({
    required bool enabled,
    List<TutorialStep>? steps,
  }) = _TutorialConfig;

  factory TutorialConfig.fromJson(Map<String, dynamic> json) =>
      _$TutorialConfigFromJson(json);
}

@freezed
class TimeBonusConfig with _$TimeBonusConfig {
  const factory TimeBonusConfig({
    int? maxTime,
    int? bonusPerSecond,
  }) = _TimeBonusConfig;

  factory TimeBonusConfig.fromJson(Map<String, dynamic> json) =>
      _$TimeBonusConfigFromJson(json);
}

@freezed
class EfficiencyBonusConfig with _$EfficiencyBonusConfig {
  const factory EfficiencyBonusConfig({
    int? maxComponents,
    int? bonusPerUnusedComponent,
  }) = _EfficiencyBonusConfig;

  factory EfficiencyBonusConfig.fromJson(Map<String, dynamic> json) =>
      _$EfficiencyBonusConfigFromJson(json);
}

@freezed
class StarThresholdsConfig with _$StarThresholdsConfig {
  const factory StarThresholdsConfig({
    int? threeStars,
    int? twoStars,
    int? oneStar,
  }) = _StarThresholdsConfig;

  factory StarThresholdsConfig.fromJson(Map<String, dynamic> json) =>
      _$StarThresholdsConfigFromJson(json);
}

@freezed
class ScoringConfig with _$ScoringConfig {
  const factory ScoringConfig({
    int? maxScore,
    TimeBonusConfig? timeBonus,
    EfficiencyBonusConfig? efficiencyBonus,
    StarThresholdsConfig? starThresholds,
  }) = _ScoringConfig;

  factory ScoringConfig.fromJson(Map<String, dynamic> json) =>
      _$ScoringConfigFromJson(json);
}