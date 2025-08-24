// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HintImpl _$$HintImplFromJson(Map<String, dynamic> json) => _$HintImpl(
      type: json['type'] as String,
      path: (json['path'] as List<dynamic>?)
          ?.map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HintImplToJson(_$HintImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'path': instance.path,
    };
