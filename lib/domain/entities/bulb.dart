import 'circuit_component.dart';
import 'component.dart';

/// Light bulb component that illuminates when current flows through it
class Bulb extends CircuitComponent {
  /// Resistance value in ohms
  double get resistance => getProperty<double>('resistance', 100.0);
  set resistance(double value) => setProperty('resistance', value);

  /// Power consumption in watts
  double get powerRating => getProperty<double>('powerRating', 1.0);
  set powerRating(double value) => setProperty('powerRating', value);

  /// Whether the bulb is currently lit
  bool get isLit => state == ComponentState.powered;

  Bulb({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    super.properties,
    super.rotation,
    double? resistance,
    double? powerRating,
  }) : super(type: ComponentType.bulb) {
    if (resistance != null) {
      this.resistance = resistance;
    }
    if (powerRating != null) {
      this.powerRating = powerRating;
    }
  }

  /// Factory constructor from ComponentModel
  factory Bulb.fromComponentModel(ComponentModel model) {
    return Bulb(
      id: model.id,
      row: model.row,
      col: model.col,
      state: model.state,
      properties: Map.from(model.properties),
      rotation: model.rotation,
      resistance: model.resistance,
    );
  }

  @override
  Bulb copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
    double? resistance,
    double? powerRating,
  }) {
    final newProperties = properties ?? Map.from(this.properties);
    if (resistance != null) {
      newProperties['resistance'] = resistance;
    }
    if (powerRating != null) {
      newProperties['powerRating'] = powerRating;
    }

    return Bulb(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      state: state ?? this.state,
      properties: newProperties,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'row': row,
      'col': col,
      'state': state.toString(),
      'properties': properties,
      'rotation': rotation,
      'resistance': resistance,
      'powerRating': powerRating,
      'isLit': isLit,
    };
  }

  @override
  String get behaviorType => 'bulb';

  @override
  List<String> get requiredConnections => ['positive', 'negative'];

  /// Calculate current through bulb given voltage
  double calculateCurrent(double voltage) {
    return voltage / resistance;
  }

  /// Calculate power consumption
  double calculatePower(double voltage) {
    final current = calculateCurrent(voltage);
    return voltage * current;
  }

  /// Check if bulb should be lit based on current
  bool shouldBeLit(double voltage) {
    final current = calculateCurrent(voltage);
    return current > 0.01; // Minimum current threshold
  }

  /// Get brightness level (0.0 to 1.0)
  double getBrightness(double voltage) {
    final current = calculateCurrent(voltage);
    final maxCurrent = powerRating / voltage; // Assuming rated voltage
    return (current / maxCurrent).clamp(0.0, 1.0);
  }
}