// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HintImpl _$$HintImplFromJson(Map json) => $checkedCreate(
      r'_$HintImpl',
      json,
      ($checkedConvert) {
        final val = _$HintImpl(
          id: $checkedConvert('id', (v) => v as String),
          text: $checkedConvert('text', (v) => v as String),
          trigger: $checkedConvert('trigger', (v) => v as String),
          triggerValue: $checkedConvert('triggerValue', (v) => v),
        );
        return val;
      },
    );

Map<String, dynamic> _$$HintImplToJson(_$HintImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'trigger': instance.trigger,
      'triggerValue': instance.triggerValue,
    };
