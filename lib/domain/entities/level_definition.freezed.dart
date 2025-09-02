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

/// @nodoc
mixin _$GridConfig {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String? get background => throw _privateConstructorUsedError;

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
  $Res call({int width, int height, String? background});
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
    ) as $Val);
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
  $Res call({int width, int height, String? background});
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
    ));
  }
}

/// @nodoc

class _$GridConfigImpl implements _GridConfig {
  const _$GridConfigImpl(
      {required this.width, required this.height, this.background});

  @override
  final int width;
  @override
  final int height;
  @override
  final String? background;

  @override
  String toString() {
    return 'GridConfig(width: $width, height: $height, background: $background)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridConfigImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.background, background) ||
                other.background == background));
  }

  @override
  int get hashCode => Object.hash(runtimeType, width, height, background);

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridConfigImplCopyWith<_$GridConfigImpl> get copyWith =>
      __$$GridConfigImplCopyWithImpl<_$GridConfigImpl>(this, _$identity);
}

abstract class _GridConfig implements GridConfig {
  const factory _GridConfig(
      {required final int width,
      required final int height,
      final String? background}) = _$GridConfigImpl;

  @override
  int get width;
  @override
  int get height;
  @override
  String? get background;

  /// Create a copy of GridConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridConfigImplCopyWith<_$GridConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ComponentConfig {
  List<ComponentTemplate> get available => throw _privateConstructorUsedError;
  List<PreplacedComponent>? get preplaced => throw _privateConstructorUsedError;

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
      {List<ComponentTemplate> available, List<PreplacedComponent>? preplaced});
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
    Object? preplaced = freezed,
  }) {
    return _then(_value.copyWith(
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as List<ComponentTemplate>,
      preplaced: freezed == preplaced
          ? _value.preplaced
          : preplaced // ignore: cast_nullable_to_non_nullable
              as List<PreplacedComponent>?,
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
      {List<ComponentTemplate> available, List<PreplacedComponent>? preplaced});
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
    Object? preplaced = freezed,
  }) {
    return _then(_$ComponentConfigImpl(
      available: null == available
          ? _value._available
          : available // ignore: cast_nullable_to_non_nullable
              as List<ComponentTemplate>,
      preplaced: freezed == preplaced
          ? _value._preplaced
          : preplaced // ignore: cast_nullable_to_non_nullable
              as List<PreplacedComponent>?,
    ));
  }
}

/// @nodoc

class _$ComponentConfigImpl implements _ComponentConfig {
  const _$ComponentConfigImpl(
      {required final List<ComponentTemplate> available,
      final List<PreplacedComponent>? preplaced})
      : _available = available,
        _preplaced = preplaced;

  final List<ComponentTemplate> _available;
  @override
  List<ComponentTemplate> get available {
    if (_available is EqualUnmodifiableListView) return _available;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_available);
  }

  final List<PreplacedComponent>? _preplaced;
  @override
  List<PreplacedComponent>? get preplaced {
    final value = _preplaced;
    if (value == null) return null;
    if (_preplaced is EqualUnmodifiableListView) return _preplaced;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ComponentConfig(available: $available, preplaced: $preplaced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentConfigImpl &&
            const DeepCollectionEquality()
                .equals(other._available, _available) &&
            const DeepCollectionEquality()
                .equals(other._preplaced, _preplaced));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_available),
      const DeepCollectionEquality().hash(_preplaced));

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentConfigImplCopyWith<_$ComponentConfigImpl> get copyWith =>
      __$$ComponentConfigImplCopyWithImpl<_$ComponentConfigImpl>(
          this, _$identity);
}

abstract class _ComponentConfig implements ComponentConfig {
  const factory _ComponentConfig(
      {required final List<ComponentTemplate> available,
      final List<PreplacedComponent>? preplaced}) = _$ComponentConfigImpl;

  @override
  List<ComponentTemplate> get available;
  @override
  List<PreplacedComponent>? get preplaced;

  /// Create a copy of ComponentConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentConfigImplCopyWith<_$ComponentConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ComponentTemplate {
  String get type => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  Map<String, dynamic>? get properties => throw _privateConstructorUsedError;

  /// Create a copy of ComponentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComponentTemplateCopyWith<ComponentTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComponentTemplateCopyWith<$Res> {
  factory $ComponentTemplateCopyWith(
          ComponentTemplate value, $Res Function(ComponentTemplate) then) =
      _$ComponentTemplateCopyWithImpl<$Res, ComponentTemplate>;
  @useResult
  $Res call({String type, int quantity, Map<String, dynamic>? properties});
}

/// @nodoc
class _$ComponentTemplateCopyWithImpl<$Res, $Val extends ComponentTemplate>
    implements $ComponentTemplateCopyWith<$Res> {
  _$ComponentTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComponentTemplate
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
abstract class _$$ComponentTemplateImplCopyWith<$Res>
    implements $ComponentTemplateCopyWith<$Res> {
  factory _$$ComponentTemplateImplCopyWith(_$ComponentTemplateImpl value,
          $Res Function(_$ComponentTemplateImpl) then) =
      __$$ComponentTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, int quantity, Map<String, dynamic>? properties});
}

/// @nodoc
class __$$ComponentTemplateImplCopyWithImpl<$Res>
    extends _$ComponentTemplateCopyWithImpl<$Res, _$ComponentTemplateImpl>
    implements _$$ComponentTemplateImplCopyWith<$Res> {
  __$$ComponentTemplateImplCopyWithImpl(_$ComponentTemplateImpl _value,
      $Res Function(_$ComponentTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComponentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? quantity = null,
    Object? properties = freezed,
  }) {
    return _then(_$ComponentTemplateImpl(
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

class _$ComponentTemplateImpl implements _ComponentTemplate {
  const _$ComponentTemplateImpl(
      {required this.type,
      required this.quantity,
      final Map<String, dynamic>? properties})
      : _properties = properties;

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
    return 'ComponentTemplate(type: $type, quantity: $quantity, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentTemplateImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, quantity,
      const DeepCollectionEquality().hash(_properties));

  /// Create a copy of ComponentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentTemplateImplCopyWith<_$ComponentTemplateImpl> get copyWith =>
      __$$ComponentTemplateImplCopyWithImpl<_$ComponentTemplateImpl>(
          this, _$identity);
}

abstract class _ComponentTemplate implements ComponentTemplate {
  const factory _ComponentTemplate(
      {required final String type,
      required final int quantity,
      final Map<String, dynamic>? properties}) = _$ComponentTemplateImpl;

  @override
  String get type;
  @override
  int get quantity;
  @override
  Map<String, dynamic>? get properties;

  /// Create a copy of ComponentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentTemplateImplCopyWith<_$ComponentTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PreplacedComponent {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  Position get position => throw _privateConstructorUsedError;
  int? get rotation => throw _privateConstructorUsedError;
  Map<String, dynamic>? get properties => throw _privateConstructorUsedError;

  /// Create a copy of PreplacedComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreplacedComponentCopyWith<PreplacedComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreplacedComponentCopyWith<$Res> {
  factory $PreplacedComponentCopyWith(
          PreplacedComponent value, $Res Function(PreplacedComponent) then) =
      _$PreplacedComponentCopyWithImpl<$Res, PreplacedComponent>;
  @useResult
  $Res call(
      {String id,
      String type,
      Position position,
      int? rotation,
      Map<String, dynamic>? properties});

  $PositionCopyWith<$Res> get position;
}

/// @nodoc
class _$PreplacedComponentCopyWithImpl<$Res, $Val extends PreplacedComponent>
    implements $PreplacedComponentCopyWith<$Res> {
  _$PreplacedComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreplacedComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? position = null,
    Object? rotation = freezed,
    Object? properties = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Position,
      rotation: freezed == rotation
          ? _value.rotation
          : rotation // ignore: cast_nullable_to_non_nullable
              as int?,
      properties: freezed == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of PreplacedComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PositionCopyWith<$Res> get position {
    return $PositionCopyWith<$Res>(_value.position, (value) {
      return _then(_value.copyWith(position: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PreplacedComponentImplCopyWith<$Res>
    implements $PreplacedComponentCopyWith<$Res> {
  factory _$$PreplacedComponentImplCopyWith(_$PreplacedComponentImpl value,
          $Res Function(_$PreplacedComponentImpl) then) =
      __$$PreplacedComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      Position position,
      int? rotation,
      Map<String, dynamic>? properties});

  @override
  $PositionCopyWith<$Res> get position;
}

/// @nodoc
class __$$PreplacedComponentImplCopyWithImpl<$Res>
    extends _$PreplacedComponentCopyWithImpl<$Res, _$PreplacedComponentImpl>
    implements _$$PreplacedComponentImplCopyWith<$Res> {
  __$$PreplacedComponentImplCopyWithImpl(_$PreplacedComponentImpl _value,
      $Res Function(_$PreplacedComponentImpl) _then)
      : super(_value, _then);

  /// Create a copy of PreplacedComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? position = null,
    Object? rotation = freezed,
    Object? properties = freezed,
  }) {
    return _then(_$PreplacedComponentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Position,
      rotation: freezed == rotation
          ? _value.rotation
          : rotation // ignore: cast_nullable_to_non_nullable
              as int?,
      properties: freezed == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$PreplacedComponentImpl implements _PreplacedComponent {
  const _$PreplacedComponentImpl(
      {required this.id,
      required this.type,
      required this.position,
      this.rotation,
      final Map<String, dynamic>? properties})
      : _properties = properties;

  @override
  final String id;
  @override
  final String type;
  @override
  final Position position;
  @override
  final int? rotation;
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
    return 'PreplacedComponent(id: $id, type: $type, position: $position, rotation: $rotation, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreplacedComponentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, type, position, rotation,
      const DeepCollectionEquality().hash(_properties));

  /// Create a copy of PreplacedComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreplacedComponentImplCopyWith<_$PreplacedComponentImpl> get copyWith =>
      __$$PreplacedComponentImplCopyWithImpl<_$PreplacedComponentImpl>(
          this, _$identity);
}

abstract class _PreplacedComponent implements PreplacedComponent {
  const factory _PreplacedComponent(
      {required final String id,
      required final String type,
      required final Position position,
      final int? rotation,
      final Map<String, dynamic>? properties}) = _$PreplacedComponentImpl;

  @override
  String get id;
  @override
  String get type;
  @override
  Position get position;
  @override
  int? get rotation;
  @override
  Map<String, dynamic>? get properties;

  /// Create a copy of PreplacedComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreplacedComponentImplCopyWith<_$PreplacedComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Position {
  int get row => throw _privateConstructorUsedError;
  int get col => throw _privateConstructorUsedError;

  /// Create a copy of Position
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PositionCopyWith<Position> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PositionCopyWith<$Res> {
  factory $PositionCopyWith(Position value, $Res Function(Position) then) =
      _$PositionCopyWithImpl<$Res, Position>;
  @useResult
  $Res call({int row, int col});
}

/// @nodoc
class _$PositionCopyWithImpl<$Res, $Val extends Position>
    implements $PositionCopyWith<$Res> {
  _$PositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Position
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? col = null,
  }) {
    return _then(_value.copyWith(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PositionImplCopyWith<$Res>
    implements $PositionCopyWith<$Res> {
  factory _$$PositionImplCopyWith(
          _$PositionImpl value, $Res Function(_$PositionImpl) then) =
      __$$PositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int row, int col});
}

/// @nodoc
class __$$PositionImplCopyWithImpl<$Res>
    extends _$PositionCopyWithImpl<$Res, _$PositionImpl>
    implements _$$PositionImplCopyWith<$Res> {
  __$$PositionImplCopyWithImpl(
      _$PositionImpl _value, $Res Function(_$PositionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Position
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? col = null,
  }) {
    return _then(_$PositionImpl(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PositionImpl implements _Position {
  const _$PositionImpl({required this.row, required this.col});

  @override
  final int row;
  @override
  final int col;

  @override
  String toString() {
    return 'Position(row: $row, col: $col)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PositionImpl &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.col, col) || other.col == col));
  }

  @override
  int get hashCode => Object.hash(runtimeType, row, col);

  /// Create a copy of Position
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PositionImplCopyWith<_$PositionImpl> get copyWith =>
      __$$PositionImplCopyWithImpl<_$PositionImpl>(this, _$identity);
}

abstract class _Position implements Position {
  const factory _Position({required final int row, required final int col}) =
      _$PositionImpl;

  @override
  int get row;
  @override
  int get col;

  /// Create a copy of Position
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PositionImplCopyWith<_$PositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LevelGoalInfo {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conditions => throw _privateConstructorUsedError;
  List<Hint>? get hints => throw _privateConstructorUsedError;
  int? get timeLimit => throw _privateConstructorUsedError;

  /// Create a copy of LevelGoalInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelGoalInfoCopyWith<LevelGoalInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelGoalInfoCopyWith<$Res> {
  factory $LevelGoalInfoCopyWith(
          LevelGoalInfo value, $Res Function(LevelGoalInfo) then) =
      _$LevelGoalInfoCopyWithImpl<$Res, LevelGoalInfo>;
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      Map<String, dynamic>? conditions,
      List<Hint>? hints,
      int? timeLimit});
}

/// @nodoc
class _$LevelGoalInfoCopyWithImpl<$Res, $Val extends LevelGoalInfo>
    implements $LevelGoalInfoCopyWith<$Res> {
  _$LevelGoalInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelGoalInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? conditions = freezed,
    Object? hints = freezed,
    Object? timeLimit = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      conditions: freezed == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      hints: freezed == hints
          ? _value.hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<Hint>?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelGoalInfoImplCopyWith<$Res>
    implements $LevelGoalInfoCopyWith<$Res> {
  factory _$$LevelGoalInfoImplCopyWith(
          _$LevelGoalInfoImpl value, $Res Function(_$LevelGoalInfoImpl) then) =
      __$$LevelGoalInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      Map<String, dynamic>? conditions,
      List<Hint>? hints,
      int? timeLimit});
}

/// @nodoc
class __$$LevelGoalInfoImplCopyWithImpl<$Res>
    extends _$LevelGoalInfoCopyWithImpl<$Res, _$LevelGoalInfoImpl>
    implements _$$LevelGoalInfoImplCopyWith<$Res> {
  __$$LevelGoalInfoImplCopyWithImpl(
      _$LevelGoalInfoImpl _value, $Res Function(_$LevelGoalInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelGoalInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? conditions = freezed,
    Object? hints = freezed,
    Object? timeLimit = freezed,
  }) {
    return _then(_$LevelGoalInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      conditions: freezed == conditions
          ? _value._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      hints: freezed == hints
          ? _value._hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<Hint>?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$LevelGoalInfoImpl implements _LevelGoalInfo {
  const _$LevelGoalInfoImpl(
      {required this.id,
      required this.type,
      required this.description,
      final Map<String, dynamic>? conditions,
      final List<Hint>? hints,
      this.timeLimit})
      : _conditions = conditions,
        _hints = hints;

  @override
  final String id;
  @override
  final String type;
  @override
  final String description;
  final Map<String, dynamic>? _conditions;
  @override
  Map<String, dynamic>? get conditions {
    final value = _conditions;
    if (value == null) return null;
    if (_conditions is EqualUnmodifiableMapView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Hint>? _hints;
  @override
  List<Hint>? get hints {
    final value = _hints;
    if (value == null) return null;
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? timeLimit;

  @override
  String toString() {
    return 'LevelGoalInfo(id: $id, type: $type, description: $description, conditions: $conditions, hints: $hints, timeLimit: $timeLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelGoalInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions) &&
            const DeepCollectionEquality().equals(other._hints, _hints) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      description,
      const DeepCollectionEquality().hash(_conditions),
      const DeepCollectionEquality().hash(_hints),
      timeLimit);

  /// Create a copy of LevelGoalInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelGoalInfoImplCopyWith<_$LevelGoalInfoImpl> get copyWith =>
      __$$LevelGoalInfoImplCopyWithImpl<_$LevelGoalInfoImpl>(this, _$identity);
}

abstract class _LevelGoalInfo implements LevelGoalInfo {
  const factory _LevelGoalInfo(
      {required final String id,
      required final String type,
      required final String description,
      final Map<String, dynamic>? conditions,
      final List<Hint>? hints,
      final int? timeLimit}) = _$LevelGoalInfoImpl;

  @override
  String get id;
  @override
  String get type;
  @override
  String get description;
  @override
  Map<String, dynamic>? get conditions;
  @override
  List<Hint>? get hints;
  @override
  int? get timeLimit;

  /// Create a copy of LevelGoalInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelGoalInfoImplCopyWith<_$LevelGoalInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Hint {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get trigger => throw _privateConstructorUsedError;
  dynamic get triggerValue => throw _privateConstructorUsedError;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HintCopyWith<Hint> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HintCopyWith<$Res> {
  factory $HintCopyWith(Hint value, $Res Function(Hint) then) =
      _$HintCopyWithImpl<$Res, Hint>;
  @useResult
  $Res call({String id, String text, String? trigger, dynamic triggerValue});
}

/// @nodoc
class _$HintCopyWithImpl<$Res, $Val extends Hint>
    implements $HintCopyWith<$Res> {
  _$HintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? trigger = freezed,
    Object? triggerValue = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      trigger: freezed == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String?,
      triggerValue: freezed == triggerValue
          ? _value.triggerValue
          : triggerValue // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HintImplCopyWith<$Res> implements $HintCopyWith<$Res> {
  factory _$$HintImplCopyWith(
          _$HintImpl value, $Res Function(_$HintImpl) then) =
      __$$HintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text, String? trigger, dynamic triggerValue});
}

/// @nodoc
class __$$HintImplCopyWithImpl<$Res>
    extends _$HintCopyWithImpl<$Res, _$HintImpl>
    implements _$$HintImplCopyWith<$Res> {
  __$$HintImplCopyWithImpl(_$HintImpl _value, $Res Function(_$HintImpl) _then)
      : super(_value, _then);

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? trigger = freezed,
    Object? triggerValue = freezed,
  }) {
    return _then(_$HintImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      trigger: freezed == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String?,
      triggerValue: freezed == triggerValue
          ? _value.triggerValue
          : triggerValue // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class _$HintImpl implements _Hint {
  const _$HintImpl(
      {required this.id, required this.text, this.trigger, this.triggerValue});

  @override
  final String id;
  @override
  final String text;
  @override
  final String? trigger;
  @override
  final dynamic triggerValue;

  @override
  String toString() {
    return 'Hint(id: $id, text: $text, trigger: $trigger, triggerValue: $triggerValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HintImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.trigger, trigger) || other.trigger == trigger) &&
            const DeepCollectionEquality()
                .equals(other.triggerValue, triggerValue));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, text, trigger,
      const DeepCollectionEquality().hash(triggerValue));

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HintImplCopyWith<_$HintImpl> get copyWith =>
      __$$HintImplCopyWithImpl<_$HintImpl>(this, _$identity);
}

abstract class _Hint implements Hint {
  const factory _Hint(
      {required final String id,
      required final String text,
      final String? trigger,
      final dynamic triggerValue}) = _$HintImpl;

  @override
  String get id;
  @override
  String get text;
  @override
  String? get trigger;
  @override
  dynamic get triggerValue;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HintImplCopyWith<_$HintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ValidationRules {
  List<String> get circuitRules => throw _privateConstructorUsedError;
  List<String> get successConditions => throw _privateConstructorUsedError;

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

class _$ValidationRulesImpl implements _ValidationRules {
  const _$ValidationRulesImpl(
      {required final List<String> circuitRules,
      required final List<String> successConditions})
      : _circuitRules = circuitRules,
        _successConditions = successConditions;

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
}

abstract class _ValidationRules implements ValidationRules {
  const factory _ValidationRules(
      {required final List<String> circuitRules,
      required final List<String> successConditions}) = _$ValidationRulesImpl;

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

/// @nodoc
mixin _$TutorialConfig {
  bool get enabled => throw _privateConstructorUsedError;
  List<TutorialStep>? get steps => throw _privateConstructorUsedError;

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

class _$TutorialConfigImpl implements _TutorialConfig {
  const _$TutorialConfigImpl(
      {required this.enabled, final List<TutorialStep>? steps})
      : _steps = steps;

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
}

abstract class _TutorialConfig implements TutorialConfig {
  const factory _TutorialConfig(
      {required final bool enabled,
      final List<TutorialStep>? steps}) = _$TutorialConfigImpl;

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

/// @nodoc
mixin _$TutorialStep {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get highlight => throw _privateConstructorUsedError;
  String? get requiredAction => throw _privateConstructorUsedError;

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

class _$TutorialStepImpl implements _TutorialStep {
  const _$TutorialStepImpl(
      {required this.id,
      required this.title,
      required this.description,
      this.highlight,
      this.requiredAction});

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
}

abstract class _TutorialStep implements TutorialStep {
  const factory _TutorialStep(
      {required final String id,
      required final String title,
      required final String description,
      final String? highlight,
      final String? requiredAction}) = _$TutorialStepImpl;

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

/// @nodoc
mixin _$ScoringConfig {
  int get maxScore => throw _privateConstructorUsedError;
  TimeBonus? get timeBonus => throw _privateConstructorUsedError;
  EfficiencyBonus? get efficiencyBonus => throw _privateConstructorUsedError;
  StarThresholds? get starThresholds => throw _privateConstructorUsedError;

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
      {int maxScore,
      TimeBonus? timeBonus,
      EfficiencyBonus? efficiencyBonus,
      StarThresholds? starThresholds});

  $TimeBonusCopyWith<$Res>? get timeBonus;
  $EfficiencyBonusCopyWith<$Res>? get efficiencyBonus;
  $StarThresholdsCopyWith<$Res>? get starThresholds;
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
    Object? maxScore = null,
    Object? timeBonus = freezed,
    Object? efficiencyBonus = freezed,
    Object? starThresholds = freezed,
  }) {
    return _then(_value.copyWith(
      maxScore: null == maxScore
          ? _value.maxScore
          : maxScore // ignore: cast_nullable_to_non_nullable
              as int,
      timeBonus: freezed == timeBonus
          ? _value.timeBonus
          : timeBonus // ignore: cast_nullable_to_non_nullable
              as TimeBonus?,
      efficiencyBonus: freezed == efficiencyBonus
          ? _value.efficiencyBonus
          : efficiencyBonus // ignore: cast_nullable_to_non_nullable
              as EfficiencyBonus?,
      starThresholds: freezed == starThresholds
          ? _value.starThresholds
          : starThresholds // ignore: cast_nullable_to_non_nullable
              as StarThresholds?,
    ) as $Val);
  }

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeBonusCopyWith<$Res>? get timeBonus {
    if (_value.timeBonus == null) {
      return null;
    }

    return $TimeBonusCopyWith<$Res>(_value.timeBonus!, (value) {
      return _then(_value.copyWith(timeBonus: value) as $Val);
    });
  }

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EfficiencyBonusCopyWith<$Res>? get efficiencyBonus {
    if (_value.efficiencyBonus == null) {
      return null;
    }

    return $EfficiencyBonusCopyWith<$Res>(_value.efficiencyBonus!, (value) {
      return _then(_value.copyWith(efficiencyBonus: value) as $Val);
    });
  }

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StarThresholdsCopyWith<$Res>? get starThresholds {
    if (_value.starThresholds == null) {
      return null;
    }

    return $StarThresholdsCopyWith<$Res>(_value.starThresholds!, (value) {
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
      {int maxScore,
      TimeBonus? timeBonus,
      EfficiencyBonus? efficiencyBonus,
      StarThresholds? starThresholds});

  @override
  $TimeBonusCopyWith<$Res>? get timeBonus;
  @override
  $EfficiencyBonusCopyWith<$Res>? get efficiencyBonus;
  @override
  $StarThresholdsCopyWith<$Res>? get starThresholds;
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
    Object? maxScore = null,
    Object? timeBonus = freezed,
    Object? efficiencyBonus = freezed,
    Object? starThresholds = freezed,
  }) {
    return _then(_$ScoringConfigImpl(
      maxScore: null == maxScore
          ? _value.maxScore
          : maxScore // ignore: cast_nullable_to_non_nullable
              as int,
      timeBonus: freezed == timeBonus
          ? _value.timeBonus
          : timeBonus // ignore: cast_nullable_to_non_nullable
              as TimeBonus?,
      efficiencyBonus: freezed == efficiencyBonus
          ? _value.efficiencyBonus
          : efficiencyBonus // ignore: cast_nullable_to_non_nullable
              as EfficiencyBonus?,
      starThresholds: freezed == starThresholds
          ? _value.starThresholds
          : starThresholds // ignore: cast_nullable_to_non_nullable
              as StarThresholds?,
    ));
  }
}

/// @nodoc

class _$ScoringConfigImpl implements _ScoringConfig {
  const _$ScoringConfigImpl(
      {required this.maxScore,
      this.timeBonus,
      this.efficiencyBonus,
      this.starThresholds});

  @override
  final int maxScore;
  @override
  final TimeBonus? timeBonus;
  @override
  final EfficiencyBonus? efficiencyBonus;
  @override
  final StarThresholds? starThresholds;

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
}

abstract class _ScoringConfig implements ScoringConfig {
  const factory _ScoringConfig(
      {required final int maxScore,
      final TimeBonus? timeBonus,
      final EfficiencyBonus? efficiencyBonus,
      final StarThresholds? starThresholds}) = _$ScoringConfigImpl;

  @override
  int get maxScore;
  @override
  TimeBonus? get timeBonus;
  @override
  EfficiencyBonus? get efficiencyBonus;
  @override
  StarThresholds? get starThresholds;

  /// Create a copy of ScoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoringConfigImplCopyWith<_$ScoringConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TimeBonus {
  int get maxTime => throw _privateConstructorUsedError;
  int get bonusPerSecond => throw _privateConstructorUsedError;

  /// Create a copy of TimeBonus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeBonusCopyWith<TimeBonus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeBonusCopyWith<$Res> {
  factory $TimeBonusCopyWith(TimeBonus value, $Res Function(TimeBonus) then) =
      _$TimeBonusCopyWithImpl<$Res, TimeBonus>;
  @useResult
  $Res call({int maxTime, int bonusPerSecond});
}

/// @nodoc
class _$TimeBonusCopyWithImpl<$Res, $Val extends TimeBonus>
    implements $TimeBonusCopyWith<$Res> {
  _$TimeBonusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeBonus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTime = null,
    Object? bonusPerSecond = null,
  }) {
    return _then(_value.copyWith(
      maxTime: null == maxTime
          ? _value.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as int,
      bonusPerSecond: null == bonusPerSecond
          ? _value.bonusPerSecond
          : bonusPerSecond // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeBonusImplCopyWith<$Res>
    implements $TimeBonusCopyWith<$Res> {
  factory _$$TimeBonusImplCopyWith(
          _$TimeBonusImpl value, $Res Function(_$TimeBonusImpl) then) =
      __$$TimeBonusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int maxTime, int bonusPerSecond});
}

/// @nodoc
class __$$TimeBonusImplCopyWithImpl<$Res>
    extends _$TimeBonusCopyWithImpl<$Res, _$TimeBonusImpl>
    implements _$$TimeBonusImplCopyWith<$Res> {
  __$$TimeBonusImplCopyWithImpl(
      _$TimeBonusImpl _value, $Res Function(_$TimeBonusImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeBonus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTime = null,
    Object? bonusPerSecond = null,
  }) {
    return _then(_$TimeBonusImpl(
      maxTime: null == maxTime
          ? _value.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as int,
      bonusPerSecond: null == bonusPerSecond
          ? _value.bonusPerSecond
          : bonusPerSecond // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TimeBonusImpl implements _TimeBonus {
  const _$TimeBonusImpl({required this.maxTime, required this.bonusPerSecond});

  @override
  final int maxTime;
  @override
  final int bonusPerSecond;

  @override
  String toString() {
    return 'TimeBonus(maxTime: $maxTime, bonusPerSecond: $bonusPerSecond)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeBonusImpl &&
            (identical(other.maxTime, maxTime) || other.maxTime == maxTime) &&
            (identical(other.bonusPerSecond, bonusPerSecond) ||
                other.bonusPerSecond == bonusPerSecond));
  }

  @override
  int get hashCode => Object.hash(runtimeType, maxTime, bonusPerSecond);

  /// Create a copy of TimeBonus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeBonusImplCopyWith<_$TimeBonusImpl> get copyWith =>
      __$$TimeBonusImplCopyWithImpl<_$TimeBonusImpl>(this, _$identity);
}

abstract class _TimeBonus implements TimeBonus {
  const factory _TimeBonus(
      {required final int maxTime,
      required final int bonusPerSecond}) = _$TimeBonusImpl;

  @override
  int get maxTime;
  @override
  int get bonusPerSecond;

  /// Create a copy of TimeBonus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeBonusImplCopyWith<_$TimeBonusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EfficiencyBonus {
  int get maxComponents => throw _privateConstructorUsedError;
  int get bonusPerUnusedComponent => throw _privateConstructorUsedError;

  /// Create a copy of EfficiencyBonus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EfficiencyBonusCopyWith<EfficiencyBonus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EfficiencyBonusCopyWith<$Res> {
  factory $EfficiencyBonusCopyWith(
          EfficiencyBonus value, $Res Function(EfficiencyBonus) then) =
      _$EfficiencyBonusCopyWithImpl<$Res, EfficiencyBonus>;
  @useResult
  $Res call({int maxComponents, int bonusPerUnusedComponent});
}

/// @nodoc
class _$EfficiencyBonusCopyWithImpl<$Res, $Val extends EfficiencyBonus>
    implements $EfficiencyBonusCopyWith<$Res> {
  _$EfficiencyBonusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EfficiencyBonus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxComponents = null,
    Object? bonusPerUnusedComponent = null,
  }) {
    return _then(_value.copyWith(
      maxComponents: null == maxComponents
          ? _value.maxComponents
          : maxComponents // ignore: cast_nullable_to_non_nullable
              as int,
      bonusPerUnusedComponent: null == bonusPerUnusedComponent
          ? _value.bonusPerUnusedComponent
          : bonusPerUnusedComponent // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EfficiencyBonusImplCopyWith<$Res>
    implements $EfficiencyBonusCopyWith<$Res> {
  factory _$$EfficiencyBonusImplCopyWith(_$EfficiencyBonusImpl value,
          $Res Function(_$EfficiencyBonusImpl) then) =
      __$$EfficiencyBonusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int maxComponents, int bonusPerUnusedComponent});
}

/// @nodoc
class __$$EfficiencyBonusImplCopyWithImpl<$Res>
    extends _$EfficiencyBonusCopyWithImpl<$Res, _$EfficiencyBonusImpl>
    implements _$$EfficiencyBonusImplCopyWith<$Res> {
  __$$EfficiencyBonusImplCopyWithImpl(
      _$EfficiencyBonusImpl _value, $Res Function(_$EfficiencyBonusImpl) _then)
      : super(_value, _then);

  /// Create a copy of EfficiencyBonus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxComponents = null,
    Object? bonusPerUnusedComponent = null,
  }) {
    return _then(_$EfficiencyBonusImpl(
      maxComponents: null == maxComponents
          ? _value.maxComponents
          : maxComponents // ignore: cast_nullable_to_non_nullable
              as int,
      bonusPerUnusedComponent: null == bonusPerUnusedComponent
          ? _value.bonusPerUnusedComponent
          : bonusPerUnusedComponent // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$EfficiencyBonusImpl implements _EfficiencyBonus {
  const _$EfficiencyBonusImpl(
      {required this.maxComponents, required this.bonusPerUnusedComponent});

  @override
  final int maxComponents;
  @override
  final int bonusPerUnusedComponent;

  @override
  String toString() {
    return 'EfficiencyBonus(maxComponents: $maxComponents, bonusPerUnusedComponent: $bonusPerUnusedComponent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EfficiencyBonusImpl &&
            (identical(other.maxComponents, maxComponents) ||
                other.maxComponents == maxComponents) &&
            (identical(
                    other.bonusPerUnusedComponent, bonusPerUnusedComponent) ||
                other.bonusPerUnusedComponent == bonusPerUnusedComponent));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, maxComponents, bonusPerUnusedComponent);

  /// Create a copy of EfficiencyBonus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EfficiencyBonusImplCopyWith<_$EfficiencyBonusImpl> get copyWith =>
      __$$EfficiencyBonusImplCopyWithImpl<_$EfficiencyBonusImpl>(
          this, _$identity);
}

abstract class _EfficiencyBonus implements EfficiencyBonus {
  const factory _EfficiencyBonus(
      {required final int maxComponents,
      required final int bonusPerUnusedComponent}) = _$EfficiencyBonusImpl;

  @override
  int get maxComponents;
  @override
  int get bonusPerUnusedComponent;

  /// Create a copy of EfficiencyBonus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EfficiencyBonusImplCopyWith<_$EfficiencyBonusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StarThresholds {
  int get threeStars => throw _privateConstructorUsedError;
  int get twoStars => throw _privateConstructorUsedError;
  int get oneStar => throw _privateConstructorUsedError;

  /// Create a copy of StarThresholds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StarThresholdsCopyWith<StarThresholds> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StarThresholdsCopyWith<$Res> {
  factory $StarThresholdsCopyWith(
          StarThresholds value, $Res Function(StarThresholds) then) =
      _$StarThresholdsCopyWithImpl<$Res, StarThresholds>;
  @useResult
  $Res call({int threeStars, int twoStars, int oneStar});
}

/// @nodoc
class _$StarThresholdsCopyWithImpl<$Res, $Val extends StarThresholds>
    implements $StarThresholdsCopyWith<$Res> {
  _$StarThresholdsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StarThresholds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threeStars = null,
    Object? twoStars = null,
    Object? oneStar = null,
  }) {
    return _then(_value.copyWith(
      threeStars: null == threeStars
          ? _value.threeStars
          : threeStars // ignore: cast_nullable_to_non_nullable
              as int,
      twoStars: null == twoStars
          ? _value.twoStars
          : twoStars // ignore: cast_nullable_to_non_nullable
              as int,
      oneStar: null == oneStar
          ? _value.oneStar
          : oneStar // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StarThresholdsImplCopyWith<$Res>
    implements $StarThresholdsCopyWith<$Res> {
  factory _$$StarThresholdsImplCopyWith(_$StarThresholdsImpl value,
          $Res Function(_$StarThresholdsImpl) then) =
      __$$StarThresholdsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int threeStars, int twoStars, int oneStar});
}

/// @nodoc
class __$$StarThresholdsImplCopyWithImpl<$Res>
    extends _$StarThresholdsCopyWithImpl<$Res, _$StarThresholdsImpl>
    implements _$$StarThresholdsImplCopyWith<$Res> {
  __$$StarThresholdsImplCopyWithImpl(
      _$StarThresholdsImpl _value, $Res Function(_$StarThresholdsImpl) _then)
      : super(_value, _then);

  /// Create a copy of StarThresholds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threeStars = null,
    Object? twoStars = null,
    Object? oneStar = null,
  }) {
    return _then(_$StarThresholdsImpl(
      threeStars: null == threeStars
          ? _value.threeStars
          : threeStars // ignore: cast_nullable_to_non_nullable
              as int,
      twoStars: null == twoStars
          ? _value.twoStars
          : twoStars // ignore: cast_nullable_to_non_nullable
              as int,
      oneStar: null == oneStar
          ? _value.oneStar
          : oneStar // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$StarThresholdsImpl implements _StarThresholds {
  const _$StarThresholdsImpl(
      {required this.threeStars,
      required this.twoStars,
      required this.oneStar});

  @override
  final int threeStars;
  @override
  final int twoStars;
  @override
  final int oneStar;

  @override
  String toString() {
    return 'StarThresholds(threeStars: $threeStars, twoStars: $twoStars, oneStar: $oneStar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StarThresholdsImpl &&
            (identical(other.threeStars, threeStars) ||
                other.threeStars == threeStars) &&
            (identical(other.twoStars, twoStars) ||
                other.twoStars == twoStars) &&
            (identical(other.oneStar, oneStar) || other.oneStar == oneStar));
  }

  @override
  int get hashCode => Object.hash(runtimeType, threeStars, twoStars, oneStar);

  /// Create a copy of StarThresholds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StarThresholdsImplCopyWith<_$StarThresholdsImpl> get copyWith =>
      __$$StarThresholdsImplCopyWithImpl<_$StarThresholdsImpl>(
          this, _$identity);
}

abstract class _StarThresholds implements StarThresholds {
  const factory _StarThresholds(
      {required final int threeStars,
      required final int twoStars,
      required final int oneStar}) = _$StarThresholdsImpl;

  @override
  int get threeStars;
  @override
  int get twoStars;
  @override
  int get oneStar;

  /// Create a copy of StarThresholds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StarThresholdsImplCopyWith<_$StarThresholdsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
