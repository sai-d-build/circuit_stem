import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';


part 'component.freezed.dart';
part 'component.g.dart';

@freezed
class CellOffset with _$CellOffset {
  const CellOffset._();
  const factory CellOffset(
    int dr,
    int dc,
  ) = _CellOffset;

  factory CellOffset.fromJson(Map<String, dynamic> json) {
    return CellOffset(
      (json['dr'] ?? json['r']) as int,
      (json['dc'] ?? json['c']) as int,
    );
  }

  Map<String, dynamic> toJson() => {'dr': dr, 'dc': dc};
}

@freezed
class TerminalSpec with _$TerminalSpec {
  const factory TerminalSpec({
    required int cellIndex,
    required Dir dir,
    String? label,
    String? role,
  }) = _TerminalSpec;

  factory TerminalSpec.fromJson(Map<String, dynamic> json) =>
      _$TerminalSpecFromJson(json);
}

Dir _dirFromString(String dir) {
  final lowerDir = dir.toLowerCase();
  if (lowerDir == 'up') return Dir.north;
  if (lowerDir == 'down') return Dir.south;
  if (lowerDir == 'left') return Dir.west;
  if (lowerDir == 'right') return Dir.east;
  return Dir.values.firstWhere(
    (e) => e.name.toLowerCase() == lowerDir,
    orElse: () {
      // For backward compatibility with older level files
      if (lowerDir == 'n') return Dir.north;
      if (lowerDir == 'e') return Dir.east;
      if (lowerDir == 's') return Dir.south;
      if (lowerDir == 'w') return Dir.west;
      throw Exception('Unknown direction string: $dir');
    },
  );
}

@freezed
class ComponentModel with _$ComponentModel {
  const ComponentModel._();

  const factory ComponentModel({
    required String id,
    required String type,
    required int r,
    required int c,
    @Default(0) int rotation,
    @Default(false) bool isPowered,
    @Default({}) Map<String, dynamic> state,
    @Default([CellOffset(0, 0)]) List<CellOffset> shapeOffsets,
    @Default([
      TerminalSpec(cellIndex: 0, dir: Dir.north),
      TerminalSpec(cellIndex: 0, dir: Dir.south)
    ]) List<TerminalSpec> terminals,
    @Default([]) List<List<int>> internalConnections,
    @Default([]) List<dynamic> behaviors,
    @Default(false) bool isDraggable,
  }) = _ComponentModel;

  T? getBehavior<T>() {
    for (final behavior in behaviors) {
      if (behavior is T) {
        return behavior;
      }
    }
    return null;
  }

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    final shapeOffsets = (json['shapeOffsets'] as List<dynamic>?)
            ?.map((e) => CellOffset.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [CellOffset(0, 0)];

    final terminalsJson = json['terminals'] as List<dynamic>?;
    final terminals = terminalsJson != null
        ? terminalsJson.map((e) {
            final termJson = e as Map<String, dynamic>;
            int cellIndex = -1;
            if (termJson.containsKey('offset')) {
              final offset = CellOffset.fromJson(termJson['offset'] as Map<String, dynamic>);
              cellIndex = shapeOffsets.indexWhere((e) => e.dr == offset.dr && e.dc == offset.dc);
            } else if (termJson.containsKey('cellIndex')) {
              cellIndex = termJson['cellIndex'] as int;
            }
            if (cellIndex == -1) {
              throw Exception('TerminalSpec.fromJson: could not determine cellIndex');
            }
            return TerminalSpec(
              cellIndex: cellIndex,
              dir: _dirFromString(termJson['dir'] as String),
              label: termJson['label'] as String?,
              role: termJson['role'] as String?,
            );
          }).toList()
        : const [
            TerminalSpec(cellIndex: 0, dir: Dir.north),
            TerminalSpec(cellIndex: 0, dir: Dir.south)
          ];

    return ComponentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      r: (json['position']?['r'] ?? json['r']) as int,
      c: (json['position']?['c'] ?? json['c']) as int,
      rotation: json['rotation'] as int? ?? 0,
      state: (json['state'] as Map<String, dynamic>?) ?? {},
      shapeOffsets: shapeOffsets,
      terminals: terminals,
      internalConnections: (json['internalConnections'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>).map((x) => x as int).toList())
              .toList() ??
          const [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'r': r,
      'c': c,
      'rotation': rotation,
      'state': state,
      'shapeOffsets': shapeOffsets.map((e) => e.toJson()).toList(),
      'terminals': terminals.map((e) => e.toJson()).toList(),
      'internalConnections': internalConnections,
    };
  }
}

// Type alias for backward compatibility with tests
typedef Component = ComponentModel;


enum Dir { north, east, south, west }

extension DirExtension on Dir {
  Dir get opposite {
    switch (this) {
      case Dir.north:
        return Dir.south;
      case Dir.east:
        return Dir.west;
      case Dir.south:
        return Dir.north;
      case Dir.west:
        return Dir.east;
    }
  }

  Dir rotate(int steps) {
    return Dir.values[(index + steps) % 4];
  }
}
