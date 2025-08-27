import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'component.freezed.dart';

@freezed
class CellOffset with _$CellOffset {
  const CellOffset._();
  const factory CellOffset(
    int r,
    int c,
  ) = _CellOffset;

  factory CellOffset.fromJson(Map<String, dynamic> json) {
    return CellOffset(
      json['r'] as int,
      json['c'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'r': r, 'c': c};
}

enum TerminalType { power, signal }

extension TerminalTypeExtension on String {
  TerminalType toTerminalType() {
    switch (toLowerCase()) {
      case 'power':
        return TerminalType.power;
      case 'signal':
        return TerminalType.signal;
      default:
        throw ArgumentError('Unknown terminal type: $this');
    }
  }
}

@freezed
class TerminalSpec with _$TerminalSpec {
  const factory TerminalSpec({
    required CellOffset offset,
    required Dir direction,
    required TerminalType type,
  }) = _TerminalSpec;

  // Custom fromJson to handle offset -> cellIndex conversion
  factory TerminalSpec.fromJson() {
    // This method should not be called directly - use ComponentRegistry.createFromJson instead
    throw UnsupportedError(
        'TerminalSpec.fromJson should not be called directly. Use ComponentRegistry.createFromJson for components.');
  }
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
      TerminalSpec(
          offset: CellOffset(0, 0),
          direction: Dir.north,
          type: TerminalType.power),
      TerminalSpec(
          offset: CellOffset(0, 0),
          direction: Dir.south,
          type: TerminalType.power)
    ])
    List<TerminalSpec> terminals,
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

  // Custom fromJson to handle complex parsing - but this should not be called directly
  factory ComponentModel.fromJson() {
    // This method should not be called directly - use ComponentRegistry.createFromJson instead
    throw UnsupportedError(
        'ComponentModel.fromJson should not be called directly. Use ComponentRegistry.createFromJson for components.');
  }

  ComponentBounds getBounds() {
    int maxR = 0;
    int maxC = 0;
    for (final offset in shapeOffsets) {
      if (offset.r > maxR) maxR = offset.r;
      if (offset.c > maxC) maxC = offset.c;
    }
    return ComponentBounds(maxC + 1, maxR + 1);
  }

  Size get displaySize {
    final bounds = getBounds();
    return Size(bounds.width * 100.0, bounds.height * 100.0);
  }
}

class ComponentBounds {
  final int width;
  final int height;
  const ComponentBounds(this.width, this.height);
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
