// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelDefinitionImpl _$$LevelDefinitionImplFromJson(Map json) =>
    $checkedCreate(
      r'_$LevelDefinitionImpl',
      json,
      ($checkedConvert) {
        final val = _$LevelDefinitionImpl(
          levelId: $checkedConvert('levelId', (v) => v as String),
          version: $checkedConvert('version', (v) => v as String),
          metadata: $checkedConvert(
              'metadata',
              (v) =>
                  LevelMetadata.fromJson(Map<String, dynamic>.from(v as Map))),
          grid: $checkedConvert('grid',
              (v) => GridConfig.fromJson(Map<String, dynamic>.from(v as Map))),
          components: $checkedConvert(
              'components',
              (v) => ComponentConfig.fromJson(
                  Map<String, dynamic>.from(v as Map))),
          goals: $checkedConvert(
              'goals',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      LevelGoal.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          validation: $checkedConvert(
              'validation',
              (v) => ValidationRules.fromJson(
                  Map<String, dynamic>.from(v as Map))),
          tutorial: $checkedConvert(
              'tutorial',
              (v) => v == null
                  ? null
                  : TutorialConfig.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          scoring: $checkedConvert(
              'scoring',
              (v) => v == null
                  ? null
                  : ScoringConfig.fromJson(
                      Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$$LevelDefinitionImplToJson(
        _$LevelDefinitionImpl instance) =>
    <String, dynamic>{
      'levelId': instance.levelId,
      'version': instance.version,
      'metadata': instance.metadata.toJson(),
      'grid': instance.grid.toJson(),
      'components': instance.components.toJson(),
      'goals': instance.goals.map((e) => e.toJson()).toList(),
      'validation': instance.validation.toJson(),
      'tutorial': instance.tutorial?.toJson(),
      'scoring': instance.scoring?.toJson(),
    };

_$LevelMetadataImpl _$$LevelMetadataImplFromJson(Map json) => $checkedCreate(
      r'_$LevelMetadataImpl',
      json,
      ($checkedConvert) {
        final val = _$LevelMetadataImpl(
          id: $checkedConvert('id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String),
          difficulty: $checkedConvert('difficulty', (v) => v as String),
          unlocked: $checkedConvert('unlocked', (v) => v as bool?),
          estimatedTime:
              $checkedConvert('estimatedTime', (v) => (v as num?)?.toInt()),
          learningObjectives: $checkedConvert('learningObjectives',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          tags: $checkedConvert('tags',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          unlocksComponents: $checkedConvert('unlocksComponents',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          prerequisites: $checkedConvert('prerequisites',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$LevelMetadataImplToJson(_$LevelMetadataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'difficulty': instance.difficulty,
      'unlocked': instance.unlocked,
      'estimatedTime': instance.estimatedTime,
      'learningObjectives': instance.learningObjectives,
      'tags': instance.tags,
      'unlocksComponents': instance.unlocksComponents,
      'prerequisites': instance.prerequisites,
    };

_$GridConfigImpl _$$GridConfigImplFromJson(Map json) => $checkedCreate(
      r'_$GridConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$GridConfigImpl(
          width: $checkedConvert('width', (v) => (v as num).toInt()),
          height: $checkedConvert('height', (v) => (v as num).toInt()),
          background: $checkedConvert('background', (v) => v as String?),
          boundaries: $checkedConvert(
              'boundaries',
              (v) => v == null
                  ? null
                  : BoundaryConfig.fromJson(
                      Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$$GridConfigImplToJson(_$GridConfigImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'background': instance.background,
      'boundaries': instance.boundaries?.toJson(),
    };

_$BoundaryConfigImpl _$$BoundaryConfigImplFromJson(Map json) => $checkedCreate(
      r'_$BoundaryConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$BoundaryConfigImpl(
          playableArea: $checkedConvert(
              'playableArea',
              (v) =>
                  PlayableArea.fromJson(Map<String, dynamic>.from(v as Map))),
          visualArea: $checkedConvert('visualArea',
              (v) => VisualArea.fromJson(Map<String, dynamic>.from(v as Map))),
          style: $checkedConvert('style', (v) => v as String?),
          behavior: $checkedConvert('behavior', (v) => v as String?),
          settings: $checkedConvert(
              'settings',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$$BoundaryConfigImplToJson(
        _$BoundaryConfigImpl instance) =>
    <String, dynamic>{
      'playableArea': instance.playableArea.toJson(),
      'visualArea': instance.visualArea.toJson(),
      'style': instance.style,
      'behavior': instance.behavior,
      'settings': instance.settings,
    };

_$PlayableAreaImpl _$$PlayableAreaImplFromJson(Map json) => $checkedCreate(
      r'_$PlayableAreaImpl',
      json,
      ($checkedConvert) {
        final val = _$PlayableAreaImpl(
          width: $checkedConvert('width', (v) => (v as num).toInt()),
          height: $checkedConvert('height', (v) => (v as num).toInt()),
          description: $checkedConvert('description', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$PlayableAreaImplToJson(_$PlayableAreaImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'description': instance.description,
    };

_$VisualAreaImpl _$$VisualAreaImplFromJson(Map json) => $checkedCreate(
      r'_$VisualAreaImpl',
      json,
      ($checkedConvert) {
        final val = _$VisualAreaImpl(
          width: $checkedConvert('width', (v) => (v as num).toInt()),
          height: $checkedConvert('height', (v) => (v as num).toInt()),
          description: $checkedConvert('description', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$VisualAreaImplToJson(_$VisualAreaImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'description': instance.description,
    };

_$ComponentAvailabilityImpl _$$ComponentAvailabilityImplFromJson(Map json) =>
    $checkedCreate(
      r'_$ComponentAvailabilityImpl',
      json,
      ($checkedConvert) {
        final val = _$ComponentAvailabilityImpl(
          type: $checkedConvert('type', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toInt()),
          properties: $checkedConvert(
              'properties',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ComponentAvailabilityImplToJson(
        _$ComponentAvailabilityImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'quantity': instance.quantity,
      'properties': instance.properties,
    };

_$ComponentConfigImpl _$$ComponentConfigImplFromJson(Map json) =>
    $checkedCreate(
      r'_$ComponentConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$ComponentConfigImpl(
          available: $checkedConvert(
              'available',
              (v) => (v as List<dynamic>)
                  .map((e) => ComponentAvailability.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
          preplaced: $checkedConvert(
              'preplaced',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      Position.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          properties: $checkedConvert(
              'properties',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ComponentConfigImplToJson(
        _$ComponentConfigImpl instance) =>
    <String, dynamic>{
      'available': instance.available.map((e) => e.toJson()).toList(),
      'preplaced': instance.preplaced.map((e) => e.toJson()).toList(),
      'properties': instance.properties,
    };

_$ValidationRulesImpl _$$ValidationRulesImplFromJson(Map json) =>
    $checkedCreate(
      r'_$ValidationRulesImpl',
      json,
      ($checkedConvert) {
        final val = _$ValidationRulesImpl(
          circuitRules: $checkedConvert('circuitRules',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          successConditions: $checkedConvert('successConditions',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ValidationRulesImplToJson(
        _$ValidationRulesImpl instance) =>
    <String, dynamic>{
      'circuitRules': instance.circuitRules,
      'successConditions': instance.successConditions,
    };

_$TutorialStepImpl _$$TutorialStepImplFromJson(Map json) => $checkedCreate(
      r'_$TutorialStepImpl',
      json,
      ($checkedConvert) {
        final val = _$TutorialStepImpl(
          id: $checkedConvert('id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String),
          highlight: $checkedConvert('highlight', (v) => v as String?),
          requiredAction:
              $checkedConvert('requiredAction', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$TutorialStepImplToJson(_$TutorialStepImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'highlight': instance.highlight,
      'requiredAction': instance.requiredAction,
    };

_$TutorialConfigImpl _$$TutorialConfigImplFromJson(Map json) => $checkedCreate(
      r'_$TutorialConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$TutorialConfigImpl(
          enabled: $checkedConvert('enabled', (v) => v as bool),
          steps: $checkedConvert(
              'steps',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => TutorialStep.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$TutorialConfigImplToJson(
        _$TutorialConfigImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'steps': instance.steps?.map((e) => e.toJson()).toList(),
    };

_$TimeBonusConfigImpl _$$TimeBonusConfigImplFromJson(Map json) =>
    $checkedCreate(
      r'_$TimeBonusConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$TimeBonusConfigImpl(
          maxTime: $checkedConvert('maxTime', (v) => (v as num?)?.toInt()),
          bonusPerSecond:
              $checkedConvert('bonusPerSecond', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$TimeBonusConfigImplToJson(
        _$TimeBonusConfigImpl instance) =>
    <String, dynamic>{
      'maxTime': instance.maxTime,
      'bonusPerSecond': instance.bonusPerSecond,
    };

_$EfficiencyBonusConfigImpl _$$EfficiencyBonusConfigImplFromJson(Map json) =>
    $checkedCreate(
      r'_$EfficiencyBonusConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$EfficiencyBonusConfigImpl(
          maxComponents:
              $checkedConvert('maxComponents', (v) => (v as num?)?.toInt()),
          bonusPerUnusedComponent: $checkedConvert(
              'bonusPerUnusedComponent', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$EfficiencyBonusConfigImplToJson(
        _$EfficiencyBonusConfigImpl instance) =>
    <String, dynamic>{
      'maxComponents': instance.maxComponents,
      'bonusPerUnusedComponent': instance.bonusPerUnusedComponent,
    };

_$StarThresholdsConfigImpl _$$StarThresholdsConfigImplFromJson(Map json) =>
    $checkedCreate(
      r'_$StarThresholdsConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$StarThresholdsConfigImpl(
          threeStars:
              $checkedConvert('threeStars', (v) => (v as num?)?.toInt()),
          twoStars: $checkedConvert('twoStars', (v) => (v as num?)?.toInt()),
          oneStar: $checkedConvert('oneStar', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$StarThresholdsConfigImplToJson(
        _$StarThresholdsConfigImpl instance) =>
    <String, dynamic>{
      'threeStars': instance.threeStars,
      'twoStars': instance.twoStars,
      'oneStar': instance.oneStar,
    };

_$ScoringConfigImpl _$$ScoringConfigImplFromJson(Map json) => $checkedCreate(
      r'_$ScoringConfigImpl',
      json,
      ($checkedConvert) {
        final val = _$ScoringConfigImpl(
          maxScore: $checkedConvert('maxScore', (v) => (v as num?)?.toInt()),
          timeBonus: $checkedConvert(
              'timeBonus',
              (v) => v == null
                  ? null
                  : TimeBonusConfig.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          efficiencyBonus: $checkedConvert(
              'efficiencyBonus',
              (v) => v == null
                  ? null
                  : EfficiencyBonusConfig.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          starThresholds: $checkedConvert(
              'starThresholds',
              (v) => v == null
                  ? null
                  : StarThresholdsConfig.fromJson(
                      Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ScoringConfigImplToJson(_$ScoringConfigImpl instance) =>
    <String, dynamic>{
      'maxScore': instance.maxScore,
      'timeBonus': instance.timeBonus?.toJson(),
      'efficiencyBonus': instance.efficiencyBonus?.toJson(),
      'starThresholds': instance.starThresholds?.toJson(),
    };
