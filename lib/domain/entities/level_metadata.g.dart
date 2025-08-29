// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelMetadataImpl _$$LevelMetadataImplFromJson(Map<String, dynamic> json) =>
    _$LevelMetadataImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      levelNumber: (json['levelNumber'] as num).toInt(),
      unlocked: json['unlocked'] as bool? ?? false,
    );

Map<String, dynamic> _$$LevelMetadataImplToJson(_$LevelMetadataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'levelNumber': instance.levelNumber,
      'unlocked': instance.unlocked,
    };
