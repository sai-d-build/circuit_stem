// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PositionImpl _$$PositionImplFromJson(Map json) => $checkedCreate(
      r'_$PositionImpl',
      json,
      ($checkedConvert) {
        final val = _$PositionImpl(
          row: $checkedConvert('row', (v) => (v as num).toInt()),
          col: $checkedConvert('col', (v) => (v as num).toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$PositionImplToJson(_$PositionImpl instance) =>
    <String, dynamic>{
      'row': instance.row,
      'col': instance.col,
    };
