import 'dart:math' show exp;
import 'package:flutter/foundation.dart' show debugPrint;
import '../core/component.dart';
import 'circuit_component.dart';

/// Capacitor component with charge storing capability
class Capacitor extends CircuitComponent {
  Capacitor({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    Map<String, dynamic>? properties,
    super.rotation,
  }) : super(
    type: ComponentType.capacitor,
    properties: {
      ...?properties,
      'capacitance': properties?.containsKey('capacitance') == true ? properties!['capacitance'] : 0.001,
      'voltageRating': properties?.containsKey('voltageRating') == true ? properties!['voltageRating'] : 25.0,
      'currentCharge': properties?.containsKey('currentCharge') == true ? properties!['currentCharge'] : 0.0,
      'leakageResistance': properties?.containsKey('leakageResistance') == true ? properties!['leakageResistance'] : 1000000.0,
    },
  ) {
    // Validate component properties on creation
    _validateCapacitance(capacity);
    _validateVoltageRating(maxVoltage);
    _validatePosition(row, col);
  }

  /// Capacitance value in farads (μF)
  double get capacity => getProperty<double>('capacitance', 0.001);

  /// Operating voltage rating in volts
  double get maxVoltage => getProperty<double>('voltageRating', 25.0);

  /// Current charge stored in coulombs
  double get currentCharge => getProperty<double>('currentCharge', 0.0);

  /// Leakage resistance in ohms (simulates real-world capacitor behavior)
  double get leakageResistance => getProperty<double>('leakageResistance', 1000000.0);

  /// Current stored energy in joules (0.5 * C * V²)
  double get storedEnergy => 0.5 * capacity * voltage * voltage;

  /// Calculate voltage across capacitor given charge
  double get voltage => currentCharge / capacity;

  /// Calculate current through capacitor (I = C * dV/dt)
  double calculateCurrent(double dVoltageDt) => capacity * dVoltageDt;

  /// Calculate charge stored given voltage
  double calculateCharge(double voltage) => capacity * voltage;

  /// Calculate time constant (τ = R * C)
  double getTimeConstant(double resistance) => leakageResistance * capacity;

  /// Check if charge is within safe operating range
  bool isChargeWithinRating() => currentCharge.abs() <= maxChargeRating();

  /// Calculate maximum charge rating based on voltage rating
  double maxChargeRating() => capacity * maxVoltage;

  /// Calculate discharge current through leakage resistance
  double calculateLeakageCurrent() => voltage / leakageResistance;

  /// Simulate capacitor charging (returns new charge level)
  double charge(double voltageSource, double resistance, double timeStep) {
    final timeConstant = timeStep / (resistance * capacity);
    final newVoltage = voltage + (voltageSource - voltage) * (1 - exp(-timeConstant));
    final newCharge = calculateCharge(newVoltage);

    setProperty('currentCharge', newCharge);
    return newCharge;
  }

  /// Simulate capacitor discharging (returns new charge level)
  double discharge(double resistance, double timeStep) {
    final timeConstant = timeStep / (resistance * capacity);
    final newVoltage = voltage * exp(-timeConstant);
    final newCharge = calculateCharge(newVoltage);

    setProperty('currentCharge', newCharge);
    return newCharge;
  }

  /// Set current charge level
  void setCharge(double charge) {
    if (charge.abs() > maxChargeRating()) {
      final warning = 'Charge ${charge.toStringAsFixed(6)}C exceeds rating ${maxChargeRating().toStringAsFixed(6)}C';
      debugPrint('⚠️ CAPACITOR WARNING: $warning');
      setProperty('overCharged', true);
      setProperty('error', 'overload');
    } else {
      setProperty('overCharged', false);
      setProperty('error', null);
    }
    setProperty('currentCharge', charge);
  }

  /// Check if voltage exceeds safe operating range
  bool isVoltageWithinRating() => voltage.abs() <= maxVoltage;

  @override
  String get behaviorType => 'passive_storage';

  @override
  List<String> get requiredConnections => ['anode', 'cathode'];

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'row': row,
    'col': col,
    'state': state.toString(),
    'properties': properties,
    'rotation': rotation,
    'capacitance': capacity,
    'voltageRating': maxVoltage,
    'currentCharge': currentCharge,
    'leakageResistance': leakageResistance,
    'storedEnergy': storedEnergy,
    'isWithinRating': isChargeWithinRating(),
  };

  @override
  CircuitComponent copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
  }) {
    final newProperties = properties ?? Map<String, dynamic>.from(this.properties);

    if (row != null || col != null) {
      _validatePosition(row ?? this.row, col ?? this.col);
    }

    return Capacitor(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      state: state ?? this.state,
      properties: newProperties,
      rotation: rotation ?? this.rotation,
    );
  }

  factory Capacitor.fromComponentModel(ComponentModel model) {
    try {
      return Capacitor(
        id: model.id,
        row: model.row,
        col: model.col,
        state: model.state,
        properties: Map<String, dynamic>.from(model.properties),
        rotation: model.rotation,
      );
    } catch (e) {
      debugPrint('❌ Capacitor.fromComponentModel failed for component ${model.id}: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');

      // EMERGENCY FALLBACK - Create component with safe defaults
      debugPrint('🛡️ Creating fallback capacitor for ${model.id}');
      return Capacitor(
        id: model.id,
        row: model.row,
        col: model.col,
        state: ComponentState.error,
        properties: {
          'capacitance': 0.001,           // 1µF default
          'voltageRating': 25.0,          // 25V default
          'currentCharge': 0.0,           // No charge initially
          'error': e.toString(),
          'fallback_created': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  // PRIVATE VALIDATION METHODS
  void _validateCapacitance(double value) {
    if (value <= 0) {
      throw ArgumentError('Capacitance must be positive: $value F');
    }
    if (value > 1000) { // 1000µF reasonable upper limit
      throw ArgumentError('Capacitance too high (max 1000µF): $value F');
    }
  }

  void _validateVoltageRating(double value) {
    if (value <= 0) {
      throw ArgumentError('Voltage rating must be positive: $value V');
    }
    if (value > 1000) { // 1000V reasonable upper limit
      throw ArgumentError('Voltage rating too high (max 1000V): $value V');
    }
  }

  void _validatePosition(int row, int col) {
    if (row < 0 || col < 0) {
      throw ArgumentError('Component position must be non-negative: ($row, $col)');
    }
  }

  @override
  String toString() {
    return 'Capacitor(id: $id, C: ${capacity.toStringAsFixed(6)}F, '
           'V: ${voltage.toStringAsFixed(2)}V/${maxVoltage.toStringAsFixed(1)}V MAX, '
           'Q: ${currentCharge.toStringAsFixed(6)}C, E: ${storedEnergy.toStringAsFixed(6)}J, '
           'state: $state)';
  }
}