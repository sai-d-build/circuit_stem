import '../core/component.dart';
import 'circuit_component.dart';

/// Buzzer component that produces sound when current flows through it
class Buzzer extends CircuitComponent {
  /// Operating voltage in volts
  double get operatingVoltage => getProperty<double>('operatingVoltage', 3);
  set operatingVoltage(double value) => setProperty('operatingVoltage', value);

  /// Operating current in milliamperes
  double get operatingCurrent => getProperty<double>('operatingCurrent', 30);
  set operatingCurrent(double value) => setProperty('operatingCurrent', value);

  /// Sound frequency in Hz
  double get frequency => getProperty<double>('frequency', 2000);
  set frequency(double value) => setProperty('frequency', value);

  /// Whether the buzzer is currently active
  bool get isActive => state == ComponentState.powered;

  Buzzer({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    super.properties,
    super.rotation,
    double? operatingVoltage,
    double? operatingCurrent,
    double? frequency,
  }) : super(type: ComponentType.buzzer) {
    if (operatingVoltage != null) {
      this.operatingVoltage = operatingVoltage;
    }
    if (operatingCurrent != null) {
      this.operatingCurrent = operatingCurrent;
    }
    if (frequency != null) {
      this.frequency = frequency;
    }
  }

  /// Factory constructor from ComponentModel
  factory Buzzer.fromComponentModel(ComponentModel model) {
    return Buzzer(
      id: model.id,
      row: model.row,
      col: model.col,
      state: model.state,
      properties: Map.from(model.properties),
      rotation: model.rotation,
    );
  }

  @override
  Buzzer copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
    double? operatingVoltage,
    double? operatingCurrent,
    double? frequency,
  }) {
    final newProperties = properties ?? Map.from(this.properties);
    if (operatingVoltage != null) {
      newProperties['operatingVoltage'] = operatingVoltage;
    }
    if (operatingCurrent != null) {
      newProperties['operatingCurrent'] = operatingCurrent;
    }
    if (frequency != null) {
      newProperties['frequency'] = frequency;
    }

    return Buzzer(
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
      'operatingVoltage': operatingVoltage,
      'operatingCurrent': operatingCurrent,
      'frequency': frequency,
      'isActive': isActive,
    };
  }

  @override
  String get behaviorType => 'buzzer';

  @override
  List<String> get requiredConnections => ['positive', 'negative'];

  @override
  double get resistance => getEquivalentResistance();

  @override
  double calculateCurrent(double voltage) {
    return voltage / getEquivalentResistance();
  }

  /// Calculate equivalent resistance
  double getEquivalentResistance() {
    return operatingVoltage / (operatingCurrent / 1000); // Convert mA to A
  }

  /// Check if buzzer should be active based on applied voltage
  bool shouldBeActive(double voltage) {
    return voltage >= operatingVoltage * 0.8; // 80% of operating voltage
  }

  /// Get sound volume level (0.0 to 1.0)
  double getVolume(double voltage) {
    if (voltage < operatingVoltage * 0.5) {
      return 0;
    }
    return (voltage / operatingVoltage).clamp(0.0, 1.0);
  }

  /// Check if voltage is within safe operating range
  bool isVoltageSafe(double voltage) {
    return voltage <= operatingVoltage * 1.2; // Max 120% of operating voltage
  }
}
