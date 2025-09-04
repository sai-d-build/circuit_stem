import 'circuit_component.dart';
import '../core/component.dart';

/// Battery component that provides power to a circuit
class Battery extends CircuitComponent {
  /// Voltage output in volts
  double get voltage => getProperty<double>('voltage', 9.0);
  set voltage(double value) => setProperty('voltage', value);

  /// Internal resistance in ohms
  double get internalResistance => getProperty<double>('internalResistance', 0.1);
  set internalResistance(double value) => setProperty('internalResistance', value);

  /// Battery capacity in ampere-hours
  double get capacity => getProperty<double>('capacity', 100.0);
  set capacity(double value) => setProperty('capacity', value);

  /// Current charge level (0.0 to 1.0)
  double get chargeLevel => getProperty<double>('chargeLevel', 1.0);
  set chargeLevel(double value) => setProperty('chargeLevel', value);

  Battery({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    super.properties,
    super.rotation,
    double? voltage,
    double? internalResistance,
    double? capacity,
    double? chargeLevel,
  }) : super(type: ComponentType.battery) {
    if (voltage != null) {
      this.voltage = voltage;
    }
    if (internalResistance != null) {
      this.internalResistance = internalResistance;
    }
    if (capacity != null) {
      this.capacity = capacity;
    }
    if (chargeLevel != null) {
      this.chargeLevel = chargeLevel;
    }
  }

  /// Factory constructor from ComponentModel
  factory Battery.fromComponentModel(ComponentModel model) {
    return Battery(
      id: model.id,
      row: model.row,
      col: model.col,
      state: model.state,
      properties: Map.from(model.properties),
      rotation: model.rotation,
      voltage: model.voltage,
    );
  }

  @override
  Battery copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
    double? voltage,
    double? internalResistance,
    double? capacity,
    double? chargeLevel,
  }) {
    final newProperties = properties ?? Map.from(this.properties);
    if (voltage != null) {
      newProperties['voltage'] = voltage;
    }
    if (internalResistance != null) {
      newProperties['internalResistance'] = internalResistance;
    }
    if (capacity != null) {
      newProperties['capacity'] = capacity;
    }
    if (chargeLevel != null) {
      newProperties['chargeLevel'] = chargeLevel;
    }

    return Battery(
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
      'voltage': voltage,
      'internalResistance': internalResistance,
      'capacity': capacity,
      'chargeLevel': chargeLevel,
    };
  }

  @override
  String get behaviorType => 'battery';

  @override
  List<String> get requiredConnections => ['positive', 'negative'];

  /// Calculate available current at given load resistance
  double calculateAvailableCurrent(double loadResistance) {
    final totalResistance = internalResistance + loadResistance;
    return voltage / totalResistance;
  }

  /// Calculate terminal voltage under load
  double calculateTerminalVoltage(double current) {
    return voltage - (current * internalResistance);
  }

  /// Calculate power output
  double calculatePowerOutput(double current) {
    final terminalVoltage = calculateTerminalVoltage(current);
    return terminalVoltage * current;
  }

  /// Check if battery is depleted
  bool isDepleted() {
    return chargeLevel <= 0.01;
  }

  /// Get remaining capacity in ampere-hours
  double getRemainingCapacity() {
    return capacity * chargeLevel;
  }

  /// Simulate discharge over time
  void discharge(double current, double timeHours) {
    final ampereHoursUsed = current * timeHours;
    final newCapacity = getRemainingCapacity() - ampereHoursUsed;
    chargeLevel = (newCapacity / capacity).clamp(0.0, 1.0);
  }
}