// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LevelDefinition _$LevelDefinitionFromJson(Map<String, dynamic> json) {
  return _LevelDefinition.fromJson(json);
}

/// @nodoc
mixin _$LevelDefinition {
  String get levelId => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  LevelMetadata get metadata => throw _privateConstructorUsedError;
  GridConfig get grid => throw _privateConstructorUsedError;
  ComponentConfig get components => throw _privateConstructorUsedError;
  List<LevelGoal> get goals => throw _privateConstructorUsedError;
  ValidationRules get validation => throw _privateConstructorUsedError;
  TutorialConfig? get tutorial => throw _privateConstructorUsedError;
  ScoringConfig? get scoring => throw _privateConstructorUsedError;

  /// Serializes this LevelDefinition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelDefinitionCopyWith<LevelDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelDefinitionCopyWith<$Res> {
  factory $LevelDefinitionCopyWith(
          LevelDefinition value, $Res Function(LevelDefinition) then) =
      _$LevelDefinitionCopyWithImpl<$Res, LevelDefinition>;
  @useResult
  $Res call(
      {String levelId,
      String version,
      LevelMetadata metadata,
      GridConfig grid,
      ComponentConfig components,
      List<LevelGoal> goals,
      ValidationRules validation,
      TutorialConfig? tutorial,
      ScoringConfig? scoring});

  $LevelMetadataCopyWith<$Res> get metadata;
  $GridConfigCopyWith<$Res> get grid;
  $ComponentConfigCopyWith<$Res> get components;
  $ValidationRulesCopyWith<$Res> get validation;
  $TutorialConfigCopyWith<$Res>? get tutorial;
  $ScoringConfigCopyWith<$Res>? get scoring;
}

/// @nodoc
class _$LevelDefinitionCopyWithImpl<$Res, $Val extends LevelDefinition>
    implements $LevelDefinitionCopyWith<$Res> {
  _$LevelDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? levelId = null,
    Object? version = null,
    Object? metadata = null,
    Object? grid = null,
    Object? components = null,
    Object? goals = null,
    Object? validation = null,
    Object? tutorial = freezed,
    Object? scoring = freezed,
  }) {
    return _then(_value.copyWith(
      levelId: null == levelId
          ? _value.levelId
          : levelId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as LevelMetadata,
      grid: null == grid
          ? _value.grid
          : grid // ignore: cast_nullable_to_non_nullable
              as GridConfig,
      components: null == components
          ? _value.components
          : components // ignore: cast_nullable_to_non_nullable
              as ComponentConfig,
      goals: null == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<LevelGoal>,
      validation: null == validation
          ? _value.validation
          : validation // ignore: cast_nullable_to_non_nullable
              as ValidationRules,
      tutorial: freezed == tutorial
          ? _value.tutorial
          : tutorial // ignore: cast_nullable_to_non_nullable
              as TutorialConfig?,
      scoring: freezed == scoring
          ? _value.scoring
          : scoring // ignore: cast_nullable_to_non_nullable
              as ScoringConfig?,
    ) as $Val);
  }

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LevelMetadataCopyWith<$Res> get metadata {
    return $LevelMetadataCopyWith<$Res>(_value.metadata, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridConfigCopyWith<$Res> get grid {
    return $GridConfigCopyWith<$Res>(_value.grid, (value) {
      return _then(_value.copyWith(grid: value) as $Val);
    });
  }

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ComponentConfigCopyWith<$Res> get components {
    return $ComponentConfigCopyWith<$Res>(_value.components, (value) {
      return _then(_value.copyWith(components: value) as $Val);
    });
  }

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ValidationRulesCopyWith<$Res> get validation {
    return $ValidationRulesCopyWith<$Res>(_value.validation, (value) {
      return _then(_value.copyWith(validation: value) as $Val);
    });
  }

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TutorialConfigCopyWith<$Res>? get tutorial {
    if (_value.tutorial == null) {
      return null;
    }

    return $TutorialConfigCopyWith<$Res>(_value.tutorial!, (value) {
      return _then(_value.copyWith(tutorial: value) as $Val);
    });
  }

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoringConfigCopyWith<$Res>? get scoring {
    if (_value.scoring == null) {
      return null;
    }

    return $ScoringConfigCopyWith<$Res>(_value.scoring!, (value) {
      return _then(_value.copyWith(scoring: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LevelDefinitionImplCopyWith<$Res>
    implements $LevelDefinitionCopyWith<$Res> {
  factory _$$LevelDefinitionImplCopyWith(_$LevelDefinitionImpl value,
          $Res Function(_$LevelDefinitionImpl) then) =
      __$$LevelDefinitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String levelId,
      String version,
      LevelMetadata metadata,
      GridConfig grid,
      ComponentConfig components,
      List<LevelGoal> goals,
      ValidationRules validation,
      TutorialConfig? tutorial,
      ScoringConfig? scoring});

  @override
  $LevelMetadataCopyWith<$Res> get metadata;
  @override
  $GridConfigCopyWith<$Res> get grid;
  @override
  $ComponentConfigCopyWith<$Res> get components;
  @override
  $ValidationRulesCopyWith<$Res> get validation;
  @override
  $TutorialConfigCopyWith<$Res>? get tutorial;
  @override
  $ScoringConfigCopyWith<$Res>? get scoring;
}

/// @nodoc
class __$$LevelDefinitionImplCopyWithImpl<$Res>
    extends _$LevelDefinitionCopyWithImpl<$Res, _$LevelDefinitionImpl>
    implements _$$LevelDefinitionImplCopyWith<$Res> {
  __$$LevelDefinitionImplCopyWithImpl(
      _$LevelDefinitionImpl _value, $Res Function(_$LevelDefinitionImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? levelId = null,
    Object? version = null,
    Object? metadata = null,
    Object? grid = null,
    Object? components = null,
    Object? goals = null,
    Object? validation = null,
    Object? tutorial = freezed,
    Object? scoring = freezed,
  }) {
    return _then(_$LevelDefinitionImpl(
      levelId: null == levelId
          ? _value.levelId
          : levelId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as LevelMetadata,
      grid: null == grid
          ? _value.grid
          : grid // ignore: cast_nullable_to_non_nullable
              as GridConfig,
      components: null == components
          ? _value.components
          : components // ignore: cast_nullable_to_non_nullable
              as ComponentConfig,
      goals: null == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<LevelGoal>,
      validation: null == validation
          ? _value.validation
          : validation // ignore: cast_nullable_to_non_nullable
              as ValidationRules,
      tutorial: freezed == tutorial
          ? _value.tutorial
          : tutorial // ignore: cast_nullable_to_non_nullable
              as TutorialConfig?,
      scoring: freezed == scoring
          ? _value.scoring
          : scoring // ignore: cast_nullable_to_non_nullable
              as ScoringConfig?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelDefinitionImpl implements _LevelDefinition {
  const _$LevelDefinitionImpl(
      {required this.levelId,
      required this.version,
      required this.metadata,
      required this.grid,
      required this.components,
      required final List<LevelGoal> goals,
      required this.validation,
      this.tutorial,
      this.scoring})
      : _goals = goals;

  factory _$LevelDefinitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelDefinitionImplFromJson(json);

  @override
  final String levelId;
  @override
  final String version;
  @override
  final LevelMetadata metadata;
  @override
  final GridConfig grid;
  @override
  final ComponentConfig components;
  final List<LevelGoal> _goals;
  @override
  List<LevelGoal> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  @override
  final ValidationRules validation;
  @override
  final TutorialConfig? tutorial;
  @override
  final ScoringConfig? scoring;

  @override
  String toString() {
    return 'LevelDefinition(levelId: $levelId, version: $version, metadata: $metadata, grid: $grid, components: $components, goals: $goals, validation: $validation, tutorial: $tutorial, scoring: $scoring)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelDefinitionImpl &&
            (identical(other.levelId, levelId) || other.levelId == levelId) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.grid, grid) || other.grid == grid) &&
            (identical(other.components, components) ||
                other.components == components) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            (identical(other.validation, validation) ||
                other.validation == validation) &&
            (identical(other.tutorial, tutorial) ||
                other.tutorial == tutorial) &&
            (identical(other.scoring, scoring) || other.scoring == scoring));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      levelId,
      version,
      metadata,
      grid,
      components,
      const DeepCollectionEquality().hash(_goals),
      validation,
      tutorial,
      scoring);

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelDefinitionImplCopyWith<_$LevelDefinitionImpl> get copyWith =>
      __$$LevelDefinitionImplCopyWithImpl<_$LevelDefinitionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelDefinitionImplToJson(
      this,
    );
  }
}

abstract class _LevelDefinition implements LevelDefinition {
  const factory _LevelDefinition(
      {required final String levelId,
      required final String version,
      required final LevelMetadata metadata,
      required final GridConfig grid,
      required final ComponentConfig components,
      required final List<LevelGoal> goals,
      required final ValidationRules validation,
      final TutorialConfig? tutorial,
      final ScoringConfig? scoring}) = _$LevelDefinitionImpl;

  factory _LevelDefinition.fromJson(Map<String, dynamic> json) =
      _$LevelDefinitionImpl.fromJson;

  @override
  String get levelId;
  @override
  String get version;
  @override
  LevelMetadata get metadata;
  @override
  GridConfig get grid;
  @override
  ComponentConfig get components;
  @override
  List<LevelGoal> get goals;
  @override
  ValidationRules get validation;
  @override
  TutorialConfig? get tutorial;
  @override
  ScoringConfig? get scoring;

  /// Create a copy of LevelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelDefinitionImplCopyWith<_$LevelDefinitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LevelMetadata _$LevelMetadataFromJson(Map<String, dynamic> json) {
  return _LevelMetadata.fromJson(json);
}

/// @nodoc
mixin _$LevelMetadata {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  bool? get unlocked => throw _privateConstructorUsedError;
  int? get estimatedTime => throw _privateConstructorUsedError;
  List<String>? get learningObjectives => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<String>? get unlocksComponents => throw _privateConstructorUsedError;
  List<String>? get prerequisites => throw _privateConstructorUsedError;

  /// Serializes this LevelMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelMetadataCopyWith<LevelMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelMetadataCopyWith<$Res> {
  factory $LevelMetadataCopyWith(
          LevelMetadata value, $Res Function(LevelMetadata) then) =
      _$LevelMetadataCopyWithImpl<$Res, LevelMetadata>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String difficulty,
      bool? unlocked,
      int? estimatedTime,
      List<String>? learningObjectives,
      List<String>? tags,
      List<String>? unlocksComponents,
      List<String>? prerequisites});
}

/// @nodoc
class _$LevelMetadataCopyWithImpl<$Res, $Val extends LevelMetadata>
    implements $LevelMetadataCopyWith<$Res> {
  _$LevelMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? difficulty = null,
    Object? unlocked = freezed,
    Object? estimatedTime = freezed,
    Object? learningObjectives = freezed,
    Object? tags = freezed,
    Object? unlocksComponents = freezed,
    Object? prerequisites = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      unlocked: freezed == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool?,
      estimatedTime: freezed == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as int?,
      learningObjectives: freezed == learningObjectives
          ? _value.learningObjectives
          : learningObjectives // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      unlocksComponents: freezed == unlocksComponents
          ? _value.unlocksComponents
          : unlocksComponents // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      prerequisites: freezed == prerequisites
          ? _value.prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelMetadataImplCopyWith<$Res>
    implements $LevelMetadataCopyWith<$Res> {
  factory _$$LevelMetadataImplCopyWith(
          _$LevelMetadataImpl value, $Res Function(_$LevelMetadataImpl) then) =
      __$$LevelMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String difficulty,
      bool? unlocked,
      int? estimatedTime,
      List<String>? learningObjectives,
      List<String>? tags,
      List<String>? unlocksComponents,
      List<String>? prerequisites});
}

/// @nodoc
class __$$LevelMetadataImplCopyWithImpl<$Res>
    extends _$LevelMetadataCopyWithImpl<$Res, _$LevelMetadataImpl>
    implements _$$LevelMetadataImplCopyWith<$Res> {
  __$$LevelMetadataImplCopyWithImpl(
      _$LevelMetadataImpl _value, $Res Function(_$LevelMetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? difficulty = null,
    Object? unlocked = freezed,
    Object? estimatedTime = freezed,
    Object? learningObjectives = freezed,
    Object? tags = freezed,
    Object? unlocksComponents = freezed,
    Object? prerequisites = freezed,
  }) {
    return _then(_$LevelMetadataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      unlocked: freezed == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool?,
      estimatedTime: freezed == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as int?,
      learningObjectives: freezed == learningObjectives
          ? _value._learningObjectives
          : learningObjectives // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      unlocksComponents: freezed == unlocksComponents
          ? _value._unlocksComponents
          : unlocksComponents // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      prerequisites: freezed == prerequisites
          ? _value._prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelMetadataImpl implements _LevelMetadata {
  const _$LevelMetadataImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.difficulty,
      this.unlocked,
      this.estimatedTime,
      final List<String>? learningObjectives,
      final List<String>? tags,
      final List<String>? unlocksComponents,
      final List<String>? prerequisites})
      : _learningObjectives = learningObjectives,
        _tags = tags,
        _unlocksComponents = unlocksComponents,
        _prerequisites = prerequisites;

  factory _$LevelMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelMetadataImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String difficulty;
  @override
  final bool? unlocked;
  @override
  final int? estimatedTime;
  final List<String>? _learningObjectives;
  @override
  List<String>? get learningObjectives {
    final value = _learningObjectives;
    if (value == null) return null;
    if (_learningObjectives is EqualUnmodifiableListView)
      return _learningObjectives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _unlocksComponents;
  @override
  List<String>? get unlocksComponents {
    final value = _unlocksComponents;
    if (value == null) return null;
    if (_unlocksComponents is EqualUnmodifiableListView)
      return _unlocksComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _prerequisites;
  @override
  List<String>? get prerequisites {
    final value = _prerequisites;
    if (value == null) return null;
    if (_prerequisites is EqualUnmodifiableListView) return _prerequisites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LevelMetadata(id: $id, title: $title, description: $description, difficulty: $difficulty, unlocked: $unlocked, estimatedTime: $estimatedTime, learningObjectives: $learningObjectives, tags: $tags, unlocksComponents: $unlocksComponents, prerequisites: $prerequisites)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelMetadataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.unlocked, unlocked) ||
                other.unlocked == unlocked) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            const DeepCollectionEquality()
                .equals(other._learningObjectives, _learningObjectives) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._unlocksComponents, _unlocksComponents) &&
            const DeepCollectionEquality()
                .equals(other._prerequisites, _prerequisites));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      difficulty,
      unlocked,
      estimatedTime,
      const DeepCollectionEquality().hash(_learningObjectives),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_unlocksComponents),
      const DeepCollectionEquality().hash(_prerequisites));

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelMetadataImplCopyWith<_$LevelMetadataImpl> get copyWith =>
      __$$LevelMetadataImplCopyWithImpl<_$LevelMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelMetadataImplToJson(
      this,
    );
  }
}

abstract class _LevelMetadata implements LevelMetadata {
  const factory _LevelMetadata(
      {required final String id,
      required final String title,
      required final String description,
      required final String difficulty,
      final bool? unlocked,
      final int? estimatedTime,
      final List<String>? learningObjectives,
      final List<String>? tags,
      final List<String>? unlocksComponents,
      final List<String>? prerequisites}) = _$LevelMetadataImpl;

  factory _LevelMetadata.fromJson(Map<String, dynamic> json) =
      _$LevelMetadataImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get difficulty;
  @override
  bool? get unlocked;
  @override
  int? get estimatedTime;
  @override
  List<String>? get learningObjectives;
  @override
  List<String>? get tags;
  @override
  List<String>? get unlocksComponents;
  @override
  List<String>? get prerequisites;

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelMetadataImplCopyWith<_$LevelMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GridConfig _$GridConfigFromJson(Map<String, dynamic> json) {
  return _GridConfig.fromJson(json);
}

/// @nodoc
mixin _$GridConfig {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String? get background => throw _privateConstructorUsedError;
  BoundaryConfig? get boundaries => throw _privateConstructorUsedError;

  /// Serializes this GridConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GridConfigCopyWith<GridConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GridConfigCopyWith<$Res> {
  factory $GridConfigCopyWith(
          GridConfig value, $Res Function(GridConfig) then) =
      _$GridConfigCopyWithImpl<$Res, GridConfig>;
  @useResult
  $Res call(
      {int width, int height, String? background, BoundaryConfig? boundaries});

  $BoundaryConfigCopyWith<$Res>? get boundaries;
}

/// @nodoc
class _$GridConfigCopyWithImpl<$Res, $Val extends GridConfig>
    implements $GridConfigCopyWith<$Res> {
  _$GridConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? background = freezed,
    Object? boundaries = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      background: freezed == background
          ? _value.background
          : background // ignore: cast_nullable_to_non_nullable
              as String?,
      boundaries: freezed == boundaries
          ? _value.boundaries
          : boundaries // ignore: cast_nullable_to_non_nullable
              as BoundaryConfig?,
    ) as $Val);
  }

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BoundaryConfigCopyWith<$Res>? get boundaries {
    if (_value.boundaries == null) {
      return null;
    }

    return $BoundaryConfigCopyWith<$Res>(_value.boundaries!, (value) {
      return _then(_value.copyWith(boundaries: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GridConfigImplCopyWith<$Res>
    implements $GridConfigCopyWith<$Res> {
  factory _$$GridConfigImplCopyWith(
          _$GridConfigImpl value, $Res Function(_$GridConfigImpl) then) =
      __$$GridConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int width, int height, String? background, BoundaryConfig? boundaries});

  @override
  $BoundaryConfigCopyWith<$Res>? get boundaries;
}

/// @nodoc
class __$$GridConfigImplCopyWithImpl<$Res>
    extends _$GridConfigCopyWithImpl<$Res, _$GridConfigImpl>
    implements _$$GridConfigImplCopyWith<$Res> {
  __$$GridConfigImplCopyWithImpl(
      _$GridConfigImpl _value, $Res Function(_$GridConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? background = freezed,
    Object? boundaries = freezed,
  }) {
    return _then(_$GridConfigImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      background: freezed == background
          ? _value.background
          : background // ignore: cast_nullable_to_non_nullable
              as String?,
      boundaries: freezed == boundaries
          ? _value.boundaries
          : boundaries // ignore: cast_nullable_to_non_nullable
              as BoundaryConfig?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GridConfigImpl implements _GridConfig {
  const _$GridConfigImpl(
      {required this.width,
      required this.height,
      this.background,
      this.boundaries});

  factory _$GridConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GridConfigImplFromJson(json);

  @override
  final int width;
  @override
  final int height;
  @override
  final String? background;
  @override
  final BoundaryConfig? boundaries;

  @override
  String toString() {
    return 'GridConfig(width: $width, height: $height, background: $background, boundaries: $boundaries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridConfigImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.background, background) ||
                other.background == background) &&
            (identical(other.boundaries, boundaries) ||
                other.boundaries == boundaries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, width, height, background, boundaries);

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridConfigImplCopyWith<_$GridConfigImpl> get copyWith =>
      __$$GridConfigImplCopyWithImpl<_$GridConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GridConfigImplToJson(
      this,
    );
  }
}

abstract class _GridConfig implements GridConfig {
  const factory _GridConfig(
      {required final int width,
      required final int height,
      final String? background,
      final BoundaryConfig? boundaries}) = _$GridConfigImpl;

  factory _GridConfig.fromJson(Map<String, dynamic> json) =
      _$GridConfigImpl.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  String? get background;
  @override
  BoundaryConfig? get boundaries;

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridConfigImplCopyWith<_$GridConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BoundaryConfig _$BoundaryConfigFromJson(Map<String, dynamic> json) {
  return _BoundaryConfig.fromJson(json);
}

/// @nodoc
mixin _$BoundaryConfig {
  PlayableArea get playableArea => throw _privateConstructorUsedError;
  VisualArea get visualArea => throw _privateConstructorUsedError;
  String? get style => throw _privateConstructorUsedError;
  String? get behavior => throw _privateConstructorUsedError;
  Map<String, dynamic>? get settings => throw _privateConstructorUsedError;

  /// Serializes this BoundaryConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoundaryConfigCopyWith<BoundaryConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoundaryConfigCopyWith<$Res> {
  factory $BoundaryConfigCopyWith(
          BoundaryConfig value, $Res Function(BoundaryConfig) then) =
      _$BoundaryConfigCopyWithImpl<$Res, BoundaryConfig>;
  @useResult
  $Res call(
      {PlayableArea playableArea,
      VisualArea visualArea,
      String? style,
      String? behavior,
      Map<String, dynamic>? settings});

  $PlayableAreaCopyWith<$Res> get playableArea;
  $VisualAreaCopyWith<$Res> get visualArea;
}

/// @nodoc
class _$BoundaryConfigCopyWithImpl<$Res, $Val extends BoundaryConfig>
    implements $BoundaryConfigCopyWith<$Res> {
  _$BoundaryConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playableArea = null,
    Object? visualArea = null,
    Object? style = freezed,
    Object? behavior = freezed,
    Object? settings = freezed,
  }) {
    return _then(_value.copyWith(
      playableArea: null == playableArea
          ? _value.playableArea
          : playableArea // ignore: cast_nullable_to_non_nullable
              as PlayableArea,
      visualArea: null == visualArea
          ? _value.visualArea
          : visualArea // ignore: cast_nullable_to_non_nullable
              as VisualArea,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as String?,
      behavior: freezed == behavior
          ? _value.behavior
          : behavior // ignore: cast_nullable_to_non_nullable
              as String?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayableAreaCopyWith<$Res> get playableArea {
    return $PlayableAreaCopyWith<$Res>(_value.playableArea, (value) {
      return _then(_value.copyWith(playableArea: value) as $Val);
    });
  }

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VisualAreaCopyWith<$Res> get visualArea {
    return $VisualAreaCopyWith<$Res>(_value.visualArea, (value) {
      return _then(_value.copyWith(visualArea: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BoundaryConfigImplCopyWith<$Res>
    implements $BoundaryConfigCopyWith<$Res> {
  factory _$$BoundaryConfigImplCopyWith(_$BoundaryConfigImpl value,
          $Res Function(_$BoundaryConfigImpl) then) =
      __$$BoundaryConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PlayableArea playableArea,
      VisualArea visualArea,
      String? style,
      String? behavior,
      Map<String, dynamic>? settings});

  @override
  $PlayableAreaCopyWith<$Res> get playableArea;
  @override
  $VisualAreaCopyWith<$Res> get visualArea;
}

/// @nodoc
class __$$BoundaryConfigImplCopyWithImpl<$Res>
    extends _$BoundaryConfigCopyWithImpl<$Res, _$BoundaryConfigImpl>
    implements _$$BoundaryConfigImplCopyWith<$Res> {
  __$$BoundaryConfigImplCopyWithImpl(
      _$BoundaryConfigImpl _value, $Res Function(_$BoundaryConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playableArea = null,
    Object? visualArea = null,
    Object? style = freezed,
    Object? behavior = freezed,
    Object? settings = freezed,
  }) {
    return _then(_$BoundaryConfigImpl(
      playableArea: null == playableArea
          ? _value.playableArea
          : playableArea // ignore: cast_nullable_to_non_nullable
              as PlayableArea,
      visualArea: null == visualArea
          ? _value.visualArea
          : visualArea // ignore: cast_nullable_to_non_nullable
              as VisualArea,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as String?,
      behavior: freezed == behavior
          ? _value.behavior
          : behavior // ignore: cast_nullable_to_non_nullable
              as String?,
      settings: freezed == settings
          ? _value._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoundaryConfigImpl implements _BoundaryConfig {
  const _$BoundaryConfigImpl(
      {required this.playableArea,
      required this.visualArea,
      this.style,
      this.behavior,
      final Map<String, dynamic>? settings})
      : _settings = settings;

  factory _$BoundaryConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoundaryConfigImplFromJson(json);

  @override
  final PlayableArea playableArea;
  @override
  final VisualArea visualArea;
  @override
  final String? style;
  @override
  final String? behavior;
  final Map<String, dynamic>? _settings;
  @override
  Map<String, dynamic>? get settings {
    final value = _settings;
    if (value == null) return null;
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BoundaryConfig(playableArea: $playableArea, visualArea: $visualArea, style: $style, behavior: $behavior, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoundaryConfigImpl &&
            (identical(other.playableArea, playableArea) ||
                other.playableArea == playableArea) &&
            (identical(other.visualArea, visualArea) ||
                other.visualArea == visualArea) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.behavior, behavior) ||
                other.behavior == behavior) &&
            const DeepCollectionEquality().equals(other._settings, _settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, playableArea, visualArea, style,
      behavior, const DeepCollectionEquality().hash(_settings));

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoundaryConfigImplCopyWith<_$BoundaryConfigImpl> get copyWith =>
      __$$BoundaryConfigImplCopyWithImpl<_$BoundaryConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoundaryConfigImplToJson(
      this,
    );
  }
}

abstract class _BoundaryConfig implements BoundaryConfig {
  const factory _BoundaryConfig(
      {required final PlayableArea playableArea,
      required final VisualArea visualArea,
      final String? style,
      final String? behavior,
      final Map<String, dynamic>? settings}) = _$BoundaryConfigImpl;

  factory _BoundaryConfig.fromJson(Map<String, dynamic> json) =
      _$BoundaryConfigImpl.fromJson;

  @override
  PlayableArea get playableArea;
  @override
  VisualArea get visualArea;
  @override
  String? get style;
  @override
  String? get behavior;
  @override
  Map<String, dynamic>? get settings;

  /// Create a copy of BoundaryConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoundaryConfigImplCopyWith<_$BoundaryConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayableArea _$PlayableAreaFromJson(Map<String, dynamic> json) {
  return _PlayableArea.fromJson(json);
}

/// @nodoc
mixin _$PlayableArea {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this PlayableArea to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayableArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayableAreaCopyWith<PlayableArea> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayableAreaCopyWith<$Res> {
  factory $PlayableAreaCopyWith(
          PlayableArea value, $Res Function(PlayableArea) then) =
      _$PlayableAreaCopyWithImpl<$Res, PlayableArea>;
  @useResult
  $Res call({int width, int height, String? description});
}

/// @nodoc
class _$PlayableAreaCopyWithImpl<$Res, $Val extends PlayableArea>
    implements $PlayableAreaCopyWith<$Res> {
  _$PlayableAreaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayableArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayableAreaImplCopyWith<$Res>
    implements $PlayableAreaCopyWith<$Res> {
  factory _$$PlayableAreaImplCopyWith(
          _$PlayableAreaImpl value, $Res Function(_$PlayableAreaImpl) then) =
      __$$PlayableAreaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int width, int height, String? description});
}

/// @nodoc
class __$$PlayableAreaImplCopyWithImpl<$Res>
    extends _$PlayableAreaCopyWithImpl<$Res, _$PlayableAreaImpl>
    implements _$$PlayableAreaImplCopyWith<$Res> {
  __$$PlayableAreaImplCopyWithImpl(
      _$PlayableAreaImpl _value, $Res Function(_$PlayableAreaImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayableArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? description = freezed,
  }) {
    return _then(_$PlayableAreaImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayableAreaImpl implements _PlayableArea {
  const _$PlayableAreaImpl(
      {required this.width, required this.height, this.description});

  factory _$PlayableAreaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayableAreaImplFromJson(json);

  @override
  final int width;
  @override
  final int height;
  @override
  final String? description;

  @override
  String toString() {
    return 'PlayableArea(width: $width, height: $height, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayableAreaImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, width, height, description);

  /// Create a copy of PlayableArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayableAreaImplCopyWith<_$PlayableAreaImpl> get copyWith =>
      __$$PlayableAreaImplCopyWithImpl<_$PlayableAreaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayableAreaImplToJson(
      this,
    );
  }
}

abstract class _PlayableArea implements PlayableArea {
  const factory _PlayableArea(
      {required final int width,
      required final int height,
      final String? description}) = _$PlayableAreaImpl;

  factory _PlayableArea.fromJson(Map<String, dynamic> json) =
      _$PlayableAreaImpl.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  String? get description;

  /// Create a copy of PlayableArea
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayableAreaImplCopyWith<_$PlayableAreaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisualArea _$VisualAreaFromJson(Map<String, dynamic> json) {
  return _VisualArea.fromJson(json);
}

/// @nodoc
mixin _$VisualArea {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this VisualArea to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisualArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisualAreaCopyWith<VisualArea> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisualAreaCopyWith<$Res> {
  factory $VisualAreaCopyWith(
          VisualArea value, $Res Function(VisualArea) then) =
      _$VisualAreaCopyWithImpl<$Res, VisualArea>;
  @useResult
  $Res call({int width, int height, String? description});
}

/// @nodoc
class _$VisualAreaCopyWithImpl<$Res, $Val extends VisualArea>
    implements $VisualAreaCopyWith<$Res> {
  _$VisualAreaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisualArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VisualAreaImplCopyWith<$Res>
    implements $VisualAreaCopyWith<$Res> {
  factory _$$VisualAreaImplCopyWith(
          _$VisualAreaImpl value, $Res Function(_$VisualAreaImpl) then) =
      __$$VisualAreaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int width, int height, String? description});
}

/// @nodoc
class __$$VisualAreaImplCopyWithImpl<$Res>
    extends _$VisualAreaCopyWithImpl<$Res, _$VisualAreaImpl>
    implements _$$VisualAreaImplCopyWith<$Res> {
  __$$VisualAreaImplCopyWithImpl(
      _$VisualAreaImpl _value, $Res Function(_$VisualAreaImpl) _then)
      : super(_value, _then);

  /// Create a copy of VisualArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? description = freezed,
  }) {
    return _then(_$VisualAreaImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VisualAreaImpl implements _VisualArea {
  const _$VisualAreaImpl(
      {required this.width, required this.height, this.description});

  factory _$VisualAreaImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisualAreaImplFromJson(json);

  @override
  final int width;
  @override
  final int height;
  @override
  final String? description;

  @override
  String toString() {
    return 'VisualArea(width: $width, height: $height, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisualAreaImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, width, height, description);

  /// Create a copy of VisualArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisualAreaImplCopyWith<_$VisualAreaImpl> get copyWith =>
      __$$VisualAreaImplCopyWithImpl<_$VisualAreaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisualAreaImplToJson(
      this,
    );
  }
}

abstract class _VisualArea implements VisualArea {
  const factory _VisualArea(
      {required final int width,
      required final int height,
      final String? description}) = _$VisualAreaImpl;

  factory _VisualArea.fromJson(Map<String, dynamic> json) =
      _$VisualAreaImpl.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  String? get description;

  /// Create a copy of VisualArea
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisualAreaImplCopyWith<_$VisualAreaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ComponentAvailability _$ComponentAvailabilityFromJson(
    Map<String, dynamic> json) {
  return _ComponentAvailability.fromJson(json);
}

/// @nodoc
mixin _$ComponentAvailability {
  String get type => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  Map<String, dynamic>? get properties => throw _privateConstructorUsedError;

  /// Serializes this ComponentAvailability to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComponentAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComponentAvailabilityCopyWith<ComponentAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComponentAvailabilityCopyWith<$Res> {
  factory $ComponentAvailabilityCopyWith(ComponentAvailability value,
          $Res Function(ComponentAvailability) then) =
      _$ComponentAvailabilityCopyWithImpl<$Res, ComponentAvailability>;
  @useResult
  $Res call({String type, int quantity, Map<String, dynamic>? properties});
}

/// @nodoc
class _$ComponentAvailabilityCopyWithImpl<$Res,
        $Val extends ComponentAvailability>
    implements $ComponentAvailabilityCopyWith<$Res> {
  _$ComponentAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComponentAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? quantity = null,
    Object? properties = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      properties: freezed == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComponentAvailabilityImplCopyWith<$Res>
    implements $ComponentAvailabilityCopyWith<$Res> {
  factory _$$ComponentAvailabilityImplCopyWith(
          _$ComponentAvailabilityImpl value,
          $Res Function(_$ComponentAvailabilityImpl) then) =
      __$$ComponentAvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, int quantity, Map<String, dynamic>? properties});
}

/// @nodoc
class __$$ComponentAvailabilityImplCopyWithImpl<$Res>
    extends _$ComponentAvailabilityCopyWithImpl<$Res,
        _$ComponentAvailabilityImpl>
    implements _$$ComponentAvailabilityImplCopyWith<$Res> {
  __$$ComponentAvailabilityImplCopyWithImpl(_$ComponentAvailabilityImpl _value,
      $Res Function(_$ComponentAvailabilityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComponentAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? quantity = null,
    Object? properties = freezed,
  }) {
    return _then(_$ComponentAvailabilityImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      properties: freezed == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComponentAvailabilityImpl implements _ComponentAvailability {
  const _$ComponentAvailabilityImpl(
      {required this.type,
      required this.quantity,
      final Map<String, dynamic>? properties})
      : _properties = properties;

  factory _$ComponentAvailabilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComponentAvailabilityImplFromJson(json);

  @override
  final String type;
  @override
  final int quantity;
  final Map<String, dynamic>? _properties;
  @override
  Map<String, dynamic>? get properties {
    final value = _properties;
    if (value == null) return null;
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ComponentAvailability(type: $type, quantity: $quantity, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentAvailabilityImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, quantity,
      const DeepCollectionEquality().hash(_properties));

  /// Create a copy of ComponentAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentAvailabilityImplCopyWith<_$ComponentAvailabilityImpl>
      get copyWith => __$$ComponentAvailabilityImplCopyWithImpl<
          _$ComponentAvailabilityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComponentAvailabilityImplToJson(
      this,
    );
  }
}

abstract class _ComponentAvailability implements ComponentAvailability {
  const factory _ComponentAvailability(
      {required final String type,
      required final int quantity,
      final Map<String, dynamic>? properties}) = _$ComponentAvailabilityImpl;

  factory _ComponentAvailability.fromJson(Map<String, dynamic> json) =
      _$ComponentAvailabilityImpl.fromJson;

  @override
  String get type;
  @override
  int get quantity;
  @override
  Map<String, dynamic>? get properties;

  /// Create a copy of ComponentAvailability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentAvailabilityImplCopyWith<_$ComponentAvailabilityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ComponentConfig _$ComponentConfigFromJson(Map<String, dynamic> json) {
  return _ComponentConfig.fromJson(json);
}

/// @nodoc
mixin _$ComponentConfig {
  List<ComponentAvailability> get available =>
      throw _privateConstructorUsedError;
  List<Position> get preplaced => throw _privateConstructorUsedError;
  Map<String, dynamic>? get properties => throw _privateConstructorUsedError;

  /// Serializes this ComponentConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComponentConfigCopyWith<ComponentConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComponentConfigCopyWith<$Res> {
  factory $ComponentConfigCopyWith(
          ComponentConfig value, $Res Function(ComponentConfig) then) =
      _$ComponentConfigCopyWithImpl<$Res, ComponentConfig>;
  @useResult
  $Res call(
      {List<ComponentAvailability> available,
      List<Position> preplaced,
      Map<String, dynamic>? properties});
}

/// @nodoc
class _$ComponentConfigCopyWithImpl<$Res, $Val extends ComponentConfig>
    implements $ComponentConfigCopyWith<$Res> {
  _$ComponentConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? available = null,
    Object? preplaced = null,
    Object? properties = freezed,
  }) {
    return _then(_value.copyWith(
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as List<ComponentAvailability>,
      preplaced: null == preplaced
          ? _value.preplaced
          : preplaced // ignore: cast_nullable_to_non_nullable
              as List<Position>,
      properties: freezed == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComponentConfigImplCopyWith<$Res>
    implements $ComponentConfigCopyWith<$Res> {
  factory _$$ComponentConfigImplCopyWith(_$ComponentConfigImpl value,
          $Res Function(_$ComponentConfigImpl) then) =
      __$$ComponentConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ComponentAvailability> available,
      List<Position> preplaced,
      Map<String, dynamic>? properties});
}

/// @nodoc
class __$$ComponentConfigImplCopyWithImpl<$Res>
    extends _$ComponentConfigCopyWithImpl<$Res, _$ComponentConfigImpl>
    implements _$$ComponentConfigImplCopyWith<$Res> {
  __$$ComponentConfigImplCopyWithImpl(
      _$ComponentConfigImpl _value, $Res Function(_$ComponentConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? available = null,
    Object? preplaced = null,
    Object? properties = freezed,
  }) {
    return _then(_$ComponentConfigImpl(
      available: null == available
          ? _value._available
          : available // ignore: cast_nullable_to_non_nullable
              as List<ComponentAvailability>,
      preplaced: null == preplaced
          ? _value._preplaced
          : preplaced // ignore: cast_nullable_to_non_nullable
              as List<Position>,
      properties: freezed == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComponentConfigImpl implements _ComponentConfig {
  const _$ComponentConfigImpl(
      {required final List<ComponentAvailability> available,
      required final List<Position> preplaced,
      final Map<String, dynamic>? properties})
      : _available = available,
        _preplaced = preplaced,
        _properties = properties;

  factory _$ComponentConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComponentConfigImplFromJson(json);

  final List<ComponentAvailability> _available;
  @override
  List<ComponentAvailability> get available {
    if (_available is EqualUnmodifiableListView) return _available;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_available);
  }

  final List<Position> _preplaced;
  @override
  List<Position> get preplaced {
    if (_preplaced is EqualUnmodifiableListView) return _preplaced;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preplaced);
  }

  final Map<String, dynamic>? _properties;
  @override
  Map<String, dynamic>? get properties {
    final value = _properties;
    if (value == null) return null;
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ComponentConfig(available: $available, preplaced: $preplaced, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentConfigImpl &&
            const DeepCollectionEquality()
                .equals(other._available, _available) &&
            const DeepCollectionEquality()
                .equals(other._preplaced, _preplaced) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_available),
      const DeepCollectionEquality().hash(_preplaced),
      const DeepCollectionEquality().hash(_properties));

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentConfigImplCopyWith<_$ComponentConfigImpl> get copyWith =>
      __$$ComponentConfigImplCopyWithImpl<_$ComponentConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComponentConfigImplToJson(
      this,
    );
  }
}

abstract class _ComponentConfig implements ComponentConfig {
  const factory _ComponentConfig(
      {required final List<ComponentAvailability> available,
      required final List<Position> preplaced,
      final Map<String, dynamic>? properties}) = _$ComponentConfigImpl;

  factory _ComponentConfig.fromJson(Map<String, dynamic> json) =
      _$ComponentConfigImpl.fromJson;

  @override
  List<ComponentAvailability> get available;
  @override
  List<Position> get preplaced;
  @override
  Map<String, dynamic>? get properties;

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentConfigImplCopyWith<_$ComponentConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ValidationRules _$ValidationRulesFromJson(Map<String, dynamic> json) {
  return _ValidationRules.fromJson(json);
}

/// @nodoc
mixin _$ValidationRules {
  List<String> get circuitRules => throw _privateConstructorUsedError;
  List<String> get successConditions => throw _privateConstructorUsedError;

  /// Serializes this ValidationRules to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidationRules
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationRulesCopyWith<ValidationRules> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationRulesCopyWith<$Res> {
  factory $ValidationRulesCopyWith(
          ValidationRules value, $Res Function(ValidationRules) then) =
      _$ValidationRulesCopyWithImpl<$Res, ValidationRules>;
  @useResult
  $Res call({List<String> circuitRules, List<String> successConditions});
}

/// @nodoc
class _$ValidationRulesCopyWithImpl<$Res, $Val extends ValidationRules>
    implements $ValidationRulesCopyWith<$Res> {
  _$ValidationRulesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationRules
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? circuitRules = null,
    Object? successConditions = null,
  }) {
    return _then(_value.copyWith(
      circuitRules: null == circuitRules
          ? _value.circuitRules
          : circuitRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      successConditions: null == successConditions
          ? _value.successConditions
          : successConditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidationRulesImplCopyWith<$Res>
    implements $ValidationRulesCopyWith<$Res> {
  factory _$$ValidationRulesImplCopyWith(_$ValidationRulesImpl value,
          $Res Function(_$ValidationRulesImpl) then) =
      __$$ValidationRulesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> circuitRules, List<String> successConditions});
}

/// @nodoc
class __$$ValidationRulesImplCopyWithImpl<$Res>
    extends _$ValidationRulesCopyWithImpl<$Res, _$ValidationRulesImpl>
    implements _$$ValidationRulesImplCopyWith<$Res> {
  __$$ValidationRulesImplCopyWithImpl(
      _$ValidationRulesImpl _value, $Res Function(_$ValidationRulesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ValidationRules
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? circuitRules = null,
    Object? successConditions = null,
  }) {
    return _then(_$ValidationRulesImpl(
      circuitRules: null == circuitRules
          ? _value._circuitRules
          : circuitRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      successConditions: null == successConditions
          ? _value._successConditions
          : successConditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidationRulesImpl implements _ValidationRules {
  const _$ValidationRulesImpl(
      {required final List<String> circuitRules,
      required final List<String> successConditions})
      : _circuitRules = circuitRules,
        _successConditions = successConditions;

  factory _$ValidationRulesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidationRulesImplFromJson(json);

  final List<String> _circuitRules;
  @override
  List<String> get circuitRules {
    if (_circuitRules is EqualUnmodifiableListView) return _circuitRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_circuitRules);
  }

  final List<String> _successConditions;
  @override
  List<String> get successConditions {
    if (_successConditions is EqualUnmodifiableListView)
      return _successConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_successConditions);
  }

  @override
  String toString() {
    return 'ValidationRules(circuitRules: $circuitRules, successConditions: $successConditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationRulesImpl &&
            const DeepCollectionEquality()
                .equals(other._circuitRules, _circuitRules) &&
            const DeepCollectionEquality()
                .equals(other._successConditions, _successConditions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_circuitRules),
      const DeepCollectionEquality().hash(_successConditions));

  /// Create a copy of ValidationRules
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationRulesImplCopyWith<_$ValidationRulesImpl> get copyWith =>
      __$$ValidationRulesImplCopyWithImpl<_$ValidationRulesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidationRulesImplToJson(
      this,
    );
  }
}

abstract class _ValidationRules implements ValidationRules {
  const factory _ValidationRules(
      {required final List<String> circuitRules,
      required final List<String> successConditions}) = _$ValidationRulesImpl;

  factory _ValidationRules.fromJson(Map<String, dynamic> json) =
      _$ValidationRulesImpl.fromJson;

  @override
  List<String> get circuitRules;
  @override
  List<String> get successConditions;

  /// Create a copy of ValidationRules
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationRulesImplCopyWith<_$ValidationRulesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorialStep _$TutorialStepFromJson(Map<String, dynamic> json) {
  return _TutorialStep.fromJson(json);
}

/// @nodoc
mixin _$TutorialStep {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get highlight => throw _privateConstructorUsedError;
  String? get requiredAction => throw _privateConstructorUsedError;

  /// Serializes this TutorialStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorialStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorialStepCopyWith<TutorialStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorialStepCopyWith<$Res> {
  factory $TutorialStepCopyWith(
          TutorialStep value, $Res Function(TutorialStep) then) =
      _$TutorialStepCopyWithImpl<$Res, TutorialStep>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? highlight,
      String? requiredAction});
}

/// @nodoc
class _$TutorialStepCopyWithImpl<$Res, $Val extends TutorialStep>
    implements $TutorialStepCopyWith<$Res> {
  _$TutorialStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorialStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? highlight = freezed,
    Object? requiredAction = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      highlight: freezed == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredAction: freezed == requiredAction
          ? _value.requiredAction
          : requiredAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorialStepImplCopyWith<$Res>
    implements $TutorialStepCopyWith<$Res> {
  factory _$$TutorialStepImplCopyWith(
          _$TutorialStepImpl value, $Res Function(_$TutorialStepImpl) then) =
      __$$TutorialStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? highlight,
      String? requiredAction});
}

/// @nodoc
class __$$TutorialStepImplCopyWithImpl<$Res>
    extends _$TutorialStepCopyWithImpl<$Res, _$TutorialStepImpl>
    implements _$$TutorialStepImplCopyWith<$Res> {
  __$$TutorialStepImplCopyWithImpl(
      _$TutorialStepImpl _value, $Res Function(_$TutorialStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorialStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? highlight = freezed,
    Object? requiredAction = freezed,
  }) {
    return _then(_$TutorialStepImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      highlight: freezed == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredAction: freezed == requiredAction
          ? _value.requiredAction
          : requiredAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorialStepImpl implements _TutorialStep {
  const _$TutorialStepImpl(
      {required this.id,
      required this.title,
      required this.description,
      this.highlight,
      this.requiredAction});

  factory _$TutorialStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorialStepImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? highlight;
  @override
  final String? requiredAction;

  @override
  String toString() {
    return 'TutorialStep(id: $id, title: $title, description: $description, highlight: $highlight, requiredAction: $requiredAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorialStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.highlight, highlight) ||
                other.highlight == highlight) &&
            (identical(other.requiredAction, requiredAction) ||
                other.requiredAction == requiredAction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, description, highlight, requiredAction);

  /// Create a copy of TutorialStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorialStepImplCopyWith<_$TutorialStepImpl> get copyWith =>
      __$$TutorialStepImplCopyWithImpl<_$TutorialStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorialStepImplToJson(
      this,
    );
  }
}

abstract class _TutorialStep implements TutorialStep {
  const factory _TutorialStep(
      {required final String id,
      required final String title,
      required final String description,
      final String? highlight,
      final String? requiredAction}) = _$TutorialStepImpl;

  factory _TutorialStep.fromJson(Map<String, dynamic> json) =
      _$TutorialStepImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get highlight;
  @override
  String? get requiredAction;

  /// Create a copy of TutorialStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorialStepImplCopyWith<_$TutorialStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorialConfig _$TutorialConfigFromJson(Map<String, dynamic> json) {
  return _TutorialConfig.fromJson(json);
}

/// @nodoc
mixin _$TutorialConfig {
  bool get enabled => throw _privateConstructorUsedError;
  List<TutorialStep>? get steps => throw _privateConstructorUsedError;

  /// Serializes this TutorialConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorialConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorialConfigCopyWith<TutorialConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorialConfigCopyWith<$Res> {
  factory $TutorialConfigCopyWith(
          TutorialConfig value, $Res Function(TutorialConfig) then) =
      _$TutorialConfigCopyWithImpl<$Res, TutorialConfig>;
  @useResult
  $Res call({bool enabled, List<TutorialStep>? steps});
}

/// @nodoc
class _$TutorialConfigCopyWithImpl<$Res, $Val extends TutorialConfig>
    implements $TutorialConfigCopyWith<$Res> {
  _$TutorialConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorialConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? steps = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      steps: freezed == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<TutorialStep>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorialConfigImplCopyWith<$Res>
    implements $TutorialConfigCopyWith<$Res> {
  factory _$$TutorialConfigImplCopyWith(_$TutorialConfigImpl value,
          $Res Function(_$TutorialConfigImpl) then) =
      __$$TutorialConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enabled, List<TutorialStep>? steps});
}

/// @nodoc
class __$$TutorialConfigImplCopyWithImpl<$Res>
    extends _$TutorialConfigCopyWithImpl<$Res, _$TutorialConfigImpl>
    implements _$$TutorialConfigImplCopyWith<$Res> {
  __$$TutorialConfigImplCopyWithImpl(
      _$TutorialConfigImpl _value, $Res Function(_$TutorialConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorialConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? steps = freezed,
  }) {
    return _then(_$TutorialConfigImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      steps: freezed == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<TutorialStep>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorialConfigImpl implements _TutorialConfig {
  const _$TutorialConfigImpl(
      {required this.enabled, final List<TutorialStep>? steps})
      : _steps = steps;

  factory _$TutorialConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorialConfigImplFromJson(json);

  @override
  final bool enabled;
  final List<TutorialStep>? _steps;
  @override
  List<TutorialStep>? get steps {
    final value = _steps;
    if (value == null) return null;
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TutorialConfig(enabled: $enabled, steps: $steps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorialConfigImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            const DeepCollectionEquality().equals(other._steps, _steps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, enabled, const DeepCollectionEquality().hash(_steps));

  /// Create a copy of TutorialConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorialConfigImplCopyWith<_$TutorialConfigImpl> get copyWith =>
      __$$TutorialConfigImplCopyWithImpl<_$TutorialConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorialConfigImplToJson(
      this,
    );
  }
}

abstract class _TutorialConfig implements TutorialConfig {
  const factory _TutorialConfig(
      {required final bool enabled,
      final List<TutorialStep>? steps}) = _$TutorialConfigImpl;

  factory _TutorialConfig.fromJson(Map<String, dynamic> json) =
      _$TutorialConfigImpl.fromJson;

  @override
  bool get enabled;
  @override
  List<TutorialStep>? get steps;

  /// Create a copy of TutorialConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorialConfigImplCopyWith<_$TutorialConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeBonusConfig _$TimeBonusConfigFromJson(Map<String, dynamic> json) {
  return _TimeBonusConfig.fromJson(json);
}

/// @nodoc
mixin _$TimeBonusConfig {
  int? get maxTime => throw _privateConstructorUsedError;
  int? get bonusPerSecond => throw _privateConstructorUsedError;

  /// Serializes this TimeBonusConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeBonusConfigCopyWith<TimeBonusConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeBonusConfigCopyWith<$Res> {
  factory $TimeBonusConfigCopyWith(
          TimeBonusConfig value, $Res Function(TimeBonusConfig) then) =
      _$TimeBonusConfigCopyWithImpl<$Res, TimeBonusConfig>;
  @useResult
  $Res call({int? maxTime, int? bonusPerSecond});
}

/// @nodoc
class _$TimeBonusConfigCopyWithImpl<$Res, $Val extends TimeBonusConfig>
    implements $TimeBonusConfigCopyWith<$Res> {
  _$TimeBonusConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTime = freezed,
    Object? bonusPerSecond = freezed,
  }) {
    return _then(_value.copyWith(
      maxTime: freezed == maxTime
          ? _value.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as int?,
      bonusPerSecond: freezed == bonusPerSecond
          ? _value.bonusPerSecond
          : bonusPerSecond // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeBonusConfigImplCopyWith<$Res>
    implements $TimeBonusConfigCopyWith<$Res> {
  factory _$$TimeBonusConfigImplCopyWith(_$TimeBonusConfigImpl value,
          $Res Function(_$TimeBonusConfigImpl) then) =
      __$$TimeBonusConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? maxTime, int? bonusPerSecond});
}

/// @nodoc
class __$$TimeBonusConfigImplCopyWithImpl<$Res>
    extends _$TimeBonusConfigCopyWithImpl<$Res, _$TimeBonusConfigImpl>
    implements _$$TimeBonusConfigImplCopyWith<$Res> {
  __$$TimeBonusConfigImplCopyWithImpl(
      _$TimeBonusConfigImpl _value, $Res Function(_$TimeBonusConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTime = freezed,
    Object? bonusPerSecond = freezed,
  }) {
    return _then(_$TimeBonusConfigImpl(
      maxTime: freezed == maxTime
          ? _value.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as int?,
      bonusPerSecond: freezed == bonusPerSecond
          ? _value.bonusPerSecond
          : bonusPerSecond // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeBonusConfigImpl implements _TimeBonusConfig {
  const _$TimeBonusConfigImpl({this.maxTime, this.bonusPerSecond});

  factory _$TimeBonusConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeBonusConfigImplFromJson(json);

  @override
  final int? maxTime;
  @override
  final int? bonusPerSecond;

  @override
  String toString() {
    return 'TimeBonusConfig(maxTime: $maxTime, bonusPerSecond: $bonusPerSecond)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeBonusConfigImpl &&
            (identical(other.maxTime, maxTime) || other.maxTime == maxTime) &&
            (identical(other.bonusPerSecond, bonusPerSecond) ||
                other.bonusPerSecond == bonusPerSecond));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, maxTime, bonusPerSecond);

  /// Create a copy of TimeBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeBonusConfigImplCopyWith<_$TimeBonusConfigImpl> get copyWith =>
      __$$TimeBonusConfigImplCopyWithImpl<_$TimeBonusConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeBonusConfigImplToJson(
      this,
    );
  }
}

abstract class _TimeBonusConfig implements TimeBonusConfig {
  const factory _TimeBonusConfig(
      {final int? maxTime, final int? bonusPerSecond}) = _$TimeBonusConfigImpl;

  factory _TimeBonusConfig.fromJson(Map<String, dynamic> json) =
      _$TimeBonusConfigImpl.fromJson;

  @override
  int? get maxTime;
  @override
  int? get bonusPerSecond;

  /// Create a copy of TimeBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeBonusConfigImplCopyWith<_$TimeBonusConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EfficiencyBonusConfig _$EfficiencyBonusConfigFromJson(
    Map<String, dynamic> json) {
  return _EfficiencyBonusConfig.fromJson(json);
}

/// @nodoc
mixin _$EfficiencyBonusConfig {
  int? get maxComponents => throw _privateConstructorUsedError;
  int? get bonusPerUnusedComponent => throw _privateConstructorUsedError;

  /// Serializes this EfficiencyBonusConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EfficiencyBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EfficiencyBonusConfigCopyWith<EfficiencyBonusConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EfficiencyBonusConfigCopyWith<$Res> {
  factory $EfficiencyBonusConfigCopyWith(EfficiencyBonusConfig value,
          $Res Function(EfficiencyBonusConfig) then) =
      _$EfficiencyBonusConfigCopyWithImpl<$Res, EfficiencyBonusConfig>;
  @useResult
  $Res call({int? maxComponents, int? bonusPerUnusedComponent});
}

/// @nodoc
class _$EfficiencyBonusConfigCopyWithImpl<$Res,
        $Val extends EfficiencyBonusConfig>
    implements $EfficiencyBonusConfigCopyWith<$Res> {
  _$EfficiencyBonusConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EfficiencyBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxComponents = freezed,
    Object? bonusPerUnusedComponent = freezed,
  }) {
    return _then(_value.copyWith(
      maxComponents: freezed == maxComponents
          ? _value.maxComponents
          : maxComponents // ignore: cast_nullable_to_non_nullable
              as int?,
      bonusPerUnusedComponent: freezed == bonusPerUnusedComponent
          ? _value.bonusPerUnusedComponent
          : bonusPerUnusedComponent // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EfficiencyBonusConfigImplCopyWith<$Res>
    implements $EfficiencyBonusConfigCopyWith<$Res> {
  factory _$$EfficiencyBonusConfigImplCopyWith(
          _$EfficiencyBonusConfigImpl value,
          $Res Function(_$EfficiencyBonusConfigImpl) then) =
      __$$EfficiencyBonusConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? maxComponents, int? bonusPerUnusedComponent});
}

/// @nodoc
class __$$EfficiencyBonusConfigImplCopyWithImpl<$Res>
    extends _$EfficiencyBonusConfigCopyWithImpl<$Res,
        _$EfficiencyBonusConfigImpl>
    implements _$$EfficiencyBonusConfigImplCopyWith<$Res> {
  __$$EfficiencyBonusConfigImplCopyWithImpl(_$EfficiencyBonusConfigImpl _value,
      $Res Function(_$EfficiencyBonusConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of EfficiencyBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxComponents = freezed,
    Object? bonusPerUnusedComponent = freezed,
  }) {
    return _then(_$EfficiencyBonusConfigImpl(
      maxComponents: freezed == maxComponents
          ? _value.maxComponents
          : maxComponents // ignore: cast_nullable_to_non_nullable
              as int?,
      bonusPerUnusedComponent: freezed == bonusPerUnusedComponent
          ? _value.bonusPerUnusedComponent
          : bonusPerUnusedComponent // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EfficiencyBonusConfigImpl implements _EfficiencyBonusConfig {
  const _$EfficiencyBonusConfigImpl(
      {this.maxComponents, this.bonusPerUnusedComponent});

  factory _$EfficiencyBonusConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$EfficiencyBonusConfigImplFromJson(json);

  @override
  final int? maxComponents;
  @override
  final int? bonusPerUnusedComponent;

  @override
  String toString() {
    return 'EfficiencyBonusConfig(maxComponents: $maxComponents, bonusPerUnusedComponent: $bonusPerUnusedComponent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EfficiencyBonusConfigImpl &&
            (identical(other.maxComponents, maxComponents) ||
                other.maxComponents == maxComponents) &&
            (identical(
                    other.bonusPerUnusedComponent, bonusPerUnusedComponent) ||
                other.bonusPerUnusedComponent == bonusPerUnusedComponent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, maxComponents, bonusPerUnusedComponent);

  /// Create a copy of EfficiencyBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EfficiencyBonusConfigImplCopyWith<_$EfficiencyBonusConfigImpl>
      get copyWith => __$$EfficiencyBonusConfigImplCopyWithImpl<
          _$EfficiencyBonusConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EfficiencyBonusConfigImplToJson(
      this,
    );
  }
}

abstract class _EfficiencyBonusConfig implements EfficiencyBonusConfig {
  const factory _EfficiencyBonusConfig(
      {final int? maxComponents,
      final int? bonusPerUnusedComponent}) = _$EfficiencyBonusConfigImpl;

  factory _EfficiencyBonusConfig.fromJson(Map<String, dynamic> json) =
      _$EfficiencyBonusConfigImpl.fromJson;

  @override
  int? get maxComponents;
  @override
  int? get bonusPerUnusedComponent;

  /// Create a copy of EfficiencyBonusConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EfficiencyBonusConfigImplCopyWith<_$EfficiencyBonusConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}

StarThresholdsConfig _$StarThresholdsConfigFromJson(Map<String, dynamic> json) {
  return _StarThresholdsConfig.fromJson(json);
}

/// @nodoc
mixin _$StarThresholdsConfig {
  int? get threeStars => throw _privateConstructorUsedError;
  int? get twoStars => throw _privateConstructorUsedError;
  int? get oneStar => throw _privateConstructorUsedError;

  /// Serializes this StarThresholdsConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StarThresholdsConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StarThresholdsConfigCopyWith<StarThresholdsConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StarThresholdsConfigCopyWith<$Res> {
  factory $StarThresholdsConfigCopyWith(StarThresholdsConfig value,
          $Res Function(StarThresholdsConfig) then) =
      _$StarThresholdsConfigCopyWithImpl<$Res, StarThresholdsConfig>;
  @useResult
  $Res call({int? threeStars, int? twoStars, int? oneStar});
}

/// @nodoc
class _$StarThresholdsConfigCopyWithImpl<$Res,
        $Val extends StarThresholdsConfig>
    implements $StarThresholdsConfigCopyWith<$Res> {
  _$StarThresholdsConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StarThresholdsConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threeStars = freezed,
    Object? twoStars = freezed,
    Object? oneStar = freezed,
  }) {
    return _then(_value.copyWith(
      threeStars: freezed == threeStars
          ? _value.threeStars
          : threeStars // ignore: cast_nullable_to_non_nullable
              as int?,
      twoStars: freezed == twoStars
          ? _value.twoStars
          : twoStars // ignore: cast_nullable_to_non_nullable
              as int?,
      oneStar: freezed == oneStar
          ? _value.oneStar
          : oneStar // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StarThresholdsConfigImplCopyWith<$Res>
    implements $StarThresholdsConfigCopyWith<$Res> {
  factory _$$StarThresholdsConfigImplCopyWith(_$StarThresholdsConfigImpl value,
          $Res Function(_$StarThresholdsConfigImpl) then) =
      __$$StarThresholdsConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? threeStars, int? twoStars, int? oneStar});
}

/// @nodoc
class __$$StarThresholdsConfigImplCopyWithImpl<$Res>
    extends _$StarThresholdsConfigCopyWithImpl<$Res, _$StarThresholdsConfigImpl>
    implements _$$StarThresholdsConfigImplCopyWith<$Res> {
  __$$StarThresholdsConfigImplCopyWithImpl(_$StarThresholdsConfigImpl _value,
      $Res Function(_$StarThresholdsConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of StarThresholdsConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threeStars = freezed,
    Object? twoStars = freezed,
    Object? oneStar = freezed,
  }) {
    return _then(_$StarThresholdsConfigImpl(
      threeStars: freezed == threeStars
          ? _value.threeStars
          : threeStars // ignore: cast_nullable_to_non_nullable
              as int?,
      twoStars: freezed == twoStars
          ? _value.twoStars
          : twoStars // ignore: cast_nullable_to_non_nullable
              as int?,
      oneStar: freezed == oneStar
          ? _value.oneStar
          : oneStar // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StarThresholdsConfigImpl implements _StarThresholdsConfig {
  const _$StarThresholdsConfigImpl(
      {this.threeStars, this.twoStars, this.oneStar});

  factory _$StarThresholdsConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$StarThresholdsConfigImplFromJson(json);

  @override
  final int? threeStars;
  @override
  final int? twoStars;
  @override
  final int? oneStar;

  @override
  String toString() {
    return 'StarThresholdsConfig(threeStars: $threeStars, twoStars: $twoStars, oneStar: $oneStar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StarThresholdsConfigImpl &&
            (identical(other.threeStars, threeStars) ||
                other.threeStars == threeStars) &&
            (identical(other.twoStars, twoStars) ||
                other.twoStars == twoStars) &&
            (identical(other.oneStar, oneStar) || other.oneStar == oneStar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, threeStars, twoStars, oneStar);

  /// Create a copy of StarThresholdsConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StarThresholdsConfigImplCopyWith<_$StarThresholdsConfigImpl>
      get copyWith =>
          __$$StarThresholdsConfigImplCopyWithImpl<_$StarThresholdsConfigImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StarThresholdsConfigImplToJson(
      this,
    );
  }
}

abstract class _StarThresholdsConfig implements StarThresholdsConfig {
  const factory _StarThresholdsConfig(
      {final int? threeStars,
      final int? twoStars,
      final int? oneStar}) = _$StarThresholdsConfigImpl;

  factory _StarThresholdsConfig.fromJson(Map<String, dynamic> json) =
      _$StarThresholdsConfigImpl.fromJson;

  @override
  int? get threeStars;
  @override
  int? get twoStars;
  @override
  int? get oneStar;

  /// Create a copy of StarThresholdsConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StarThresholdsConfigImplCopyWith<_$StarThresholdsConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ScoringConfig _$ScoringConfigFromJson(Map<String, dynamic> json) {
  return _ScoringConfig.fromJson(json);
}

/// @nodoc
mixin _$ScoringConfig {
  int? get maxScore => throw _privateConstructorUsedError;
  TimeBonusConfig? get timeBonus => throw _privateConstructorUsedError;
  EfficiencyBonusConfig? get efficiencyBonus =>
      throw _privateConstructorUsedError;
  StarThresholdsConfig? get starThresholds =>
      throw _privateConstructorUsedError;

  /// Serializes this ScoringConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoringConfigCopyWith<ScoringConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoringConfigCopyWith<$Res> {
  factory $ScoringConfigCopyWith(
          ScoringConfig value, $Res Function(ScoringConfig) then) =
      _$ScoringConfigCopyWithImpl<$Res, ScoringConfig>;
  @useResult
  $Res call(
      {int? maxScore,
      TimeBonusConfig? timeBonus,
      EfficiencyBonusConfig? efficiencyBonus,
      StarThresholdsConfig? starThresholds});

  $TimeBonusConfigCopyWith<$Res>? get timeBonus;
  $EfficiencyBonusConfigCopyWith<$Res>? get efficiencyBonus;
  $StarThresholdsConfigCopyWith<$Res>? get starThresholds;
}

/// @nodoc
class _$ScoringConfigCopyWithImpl<$Res, $Val extends ScoringConfig>
    implements $ScoringConfigCopyWith<$Res> {
  _$ScoringConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxScore = freezed,
    Object? timeBonus = freezed,
    Object? efficiencyBonus = freezed,
    Object? starThresholds = freezed,
  }) {
    return _then(_value.copyWith(
      maxScore: freezed == maxScore
          ? _value.maxScore
          : maxScore // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBonus: freezed == timeBonus
          ? _value.timeBonus
          : timeBonus // ignore: cast_nullable_to_non_nullable
              as TimeBonusConfig?,
      efficiencyBonus: freezed == efficiencyBonus
          ? _value.efficiencyBonus
          : efficiencyBonus // ignore: cast_nullable_to_non_nullable
              as EfficiencyBonusConfig?,
      starThresholds: freezed == starThresholds
          ? _value.starThresholds
          : starThresholds // ignore: cast_nullable_to_non_nullable
              as StarThresholdsConfig?,
    ) as $Val);
  }

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeBonusConfigCopyWith<$Res>? get timeBonus {
    if (_value.timeBonus == null) {
      return null;
    }

    return $TimeBonusConfigCopyWith<$Res>(_value.timeBonus!, (value) {
      return _then(_value.copyWith(timeBonus: value) as $Val);
    });
  }

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EfficiencyBonusConfigCopyWith<$Res>? get efficiencyBonus {
    if (_value.efficiencyBonus == null) {
      return null;
    }

    return $EfficiencyBonusConfigCopyWith<$Res>(_value.efficiencyBonus!,
        (value) {
      return _then(_value.copyWith(efficiencyBonus: value) as $Val);
    });
  }

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StarThresholdsConfigCopyWith<$Res>? get starThresholds {
    if (_value.starThresholds == null) {
      return null;
    }

    return $StarThresholdsConfigCopyWith<$Res>(_value.starThresholds!, (value) {
      return _then(_value.copyWith(starThresholds: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScoringConfigImplCopyWith<$Res>
    implements $ScoringConfigCopyWith<$Res> {
  factory _$$ScoringConfigImplCopyWith(
          _$ScoringConfigImpl value, $Res Function(_$ScoringConfigImpl) then) =
      __$$ScoringConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? maxScore,
      TimeBonusConfig? timeBonus,
      EfficiencyBonusConfig? efficiencyBonus,
      StarThresholdsConfig? starThresholds});

  @override
  $TimeBonusConfigCopyWith<$Res>? get timeBonus;
  @override
  $EfficiencyBonusConfigCopyWith<$Res>? get efficiencyBonus;
  @override
  $StarThresholdsConfigCopyWith<$Res>? get starThresholds;
}

/// @nodoc
class __$$ScoringConfigImplCopyWithImpl<$Res>
    extends _$ScoringConfigCopyWithImpl<$Res, _$ScoringConfigImpl>
    implements _$$ScoringConfigImplCopyWith<$Res> {
  __$$ScoringConfigImplCopyWithImpl(
      _$ScoringConfigImpl _value, $Res Function(_$ScoringConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxScore = freezed,
    Object? timeBonus = freezed,
    Object? efficiencyBonus = freezed,
    Object? starThresholds = freezed,
  }) {
    return _then(_$ScoringConfigImpl(
      maxScore: freezed == maxScore
          ? _value.maxScore
          : maxScore // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBonus: freezed == timeBonus
          ? _value.timeBonus
          : timeBonus // ignore: cast_nullable_to_non_nullable
              as TimeBonusConfig?,
      efficiencyBonus: freezed == efficiencyBonus
          ? _value.efficiencyBonus
          : efficiencyBonus // ignore: cast_nullable_to_non_nullable
              as EfficiencyBonusConfig?,
      starThresholds: freezed == starThresholds
          ? _value.starThresholds
          : starThresholds // ignore: cast_nullable_to_non_nullable
              as StarThresholdsConfig?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoringConfigImpl implements _ScoringConfig {
  const _$ScoringConfigImpl(
      {this.maxScore,
      this.timeBonus,
      this.efficiencyBonus,
      this.starThresholds});

  factory _$ScoringConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoringConfigImplFromJson(json);

  @override
  final int? maxScore;
  @override
  final TimeBonusConfig? timeBonus;
  @override
  final EfficiencyBonusConfig? efficiencyBonus;
  @override
  final StarThresholdsConfig? starThresholds;

  @override
  String toString() {
    return 'ScoringConfig(maxScore: $maxScore, timeBonus: $timeBonus, efficiencyBonus: $efficiencyBonus, starThresholds: $starThresholds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoringConfigImpl &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.timeBonus, timeBonus) ||
                other.timeBonus == timeBonus) &&
            (identical(other.efficiencyBonus, efficiencyBonus) ||
                other.efficiencyBonus == efficiencyBonus) &&
            (identical(other.starThresholds, starThresholds) ||
                other.starThresholds == starThresholds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, maxScore, timeBonus, efficiencyBonus, starThresholds);

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoringConfigImplCopyWith<_$ScoringConfigImpl> get copyWith =>
      __$$ScoringConfigImplCopyWithImpl<_$ScoringConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoringConfigImplToJson(
      this,
    );
  }
}

abstract class _ScoringConfig implements ScoringConfig {
  const factory _ScoringConfig(
      {final int? maxScore,
      final TimeBonusConfig? timeBonus,
      final EfficiencyBonusConfig? efficiencyBonus,
      final StarThresholdsConfig? starThresholds}) = _$ScoringConfigImpl;

  factory _ScoringConfig.fromJson(Map<String, dynamic> json) =
      _$ScoringConfigImpl.fromJson;

  @override
  int? get maxScore;
  @override
  TimeBonusConfig? get timeBonus;
  @override
  EfficiencyBonusConfig? get efficiencyBonus;
  @override
  StarThresholdsConfig? get starThresholds;

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoringConfigImplCopyWith<_$ScoringConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
