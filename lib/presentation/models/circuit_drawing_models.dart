// Dummy CircuitWire for the painter, will be replaced by a proper model
class CircuitWire {
  final String id;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final bool isActive;

  CircuitWire({
    required this.id,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitWire &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startX == other.startX &&
          startY == other.startY &&
          endX == other.endX &&
          endY == other.endY &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      startX.hashCode ^
      startY.hashCode ^
      endX.hashCode ^
      endY.hashCode ^
      isActive.hashCode;
}

bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
}
