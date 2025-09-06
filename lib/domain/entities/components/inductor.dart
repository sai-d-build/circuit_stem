import 'dart:math' show pi, sqrt, cos;
import '../core/component.dart';
import '../../../core/debug/structured_logger.dart';
import 'circuit_component.dart';

/// Inductor component with magnetic field energy storage
class Inductor extends CircuitComponent {
  Inductor({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    Map<String, dynamic>? properties,
    super.rotation,
  }) : super(
    type: ComponentType.inductor,
    properties: {
      ...?properties,
      'inductance': properties?.containsKey('inductance') == true ? properties!['inductance'] : 0.001,     // Default 1mH
      'currentRating': properties?.containsKey('currentRating') == true ? properties!['currentRating'] : 1.0, // Default 1A
      'current': properties?.containsKey('current') == true ? properties!['current'] : 0.0,               // Default 0A
      'dcResistance': properties?.containsKey('dcResistance') == true ? properties!['dcResistance'] : 0.01, // Default 10mΩ
    },
  ) {
    // Validate component properties on creation
    _validateInductance(inductance);
    _validateCurrentRating(currentRating);
    _validatePosition(row, col);
  }

  /// Inductance value in henries (mH)
  double get inductance => getProperty<double>('inductance', 0.001);

  /// Current rating in amperes
  double get currentRating => getProperty<double>('currentRating', 1.0);

  /// Current flowing through inductor in amperes
  double get current => getProperty<double>('current', 0.0);

  /// DC resistance of the wire in ohms
  double get dcResistance => getProperty<double>('dcResistance', 0.01);

  /// Energy stored in joules (0.5 * L * I²)
  double get storedEnergy => 0.5 * inductance * current * current;

  /// Calculate voltage across inductor (V = L * dI/dt)
  double calculateVoltage(double dCurrentDt) => inductance * dCurrentDt;

  /// Calculate flux linkage in weber-turns
  double get fluxLinkage => inductance * current;

  /// Calculate reactance at given frequency (2πfL)
  double calculateReactance(double frequency) => 2 * pi * frequency * inductance;

  /// Calculate magnetic field strength (ampere-turns)
  double get ampereTurns => current * calculateTurns();

  /// Approximate number of turns (from inductance and geometry)
  double calculateTurns() {
    // Simplification: assume basic geometry
    final wireLength = 0.1; // 10cm
    final coreArea = 0.0001; // 1cm²
    final mu = 4 * pi * 1e-7; // μ₀

    return sqrt((inductance * wireLength) / (mu * coreArea));
  }

  /// Simulate inductor in LC circuit
  double simulateLC(double initialCurrent, double capacitance, double time, double dTime) {
    final omega = 1 / sqrt(inductance * capacitance);
    final newCurrent = initialCurrent * cos(omega * time);
    setProperty('current', newCurrent);
    return newCurrent;
  }

  /// Calculate power dissipated as heat (I²R)
  double get powerLoss => current * current * dcResistance;

  /// Set current flowing through inductor
  void setCurrent(double value) {
    if (value.abs() > currentRating) {
      final warning = 'Current ${value.toStringAsFixed(3)}A exceeds rating ${currentRating.toStringAsFixed(1)}A';
      StructuredLogger.warning('⚠️ INDUCTOR WARNING: $warning');
      setProperty('overCurrent', true);
      setProperty('error', 'Current overload');
    } else {
      setProperty('overCurrent', false);
      setProperty('error', null);
    }
    setProperty('current', value);
  }

  /// Calculate peak current for sinusoidal voltage
  double calculatePeakCurrent(double peakVoltage, double frequency) {
    final reactance = calculateReactance(frequency);
    return peakVoltage / sqrt(dcResistance * dcResistance + reactance * reactance);
  }

  /// Calculate quality factor (Q = ωL / R)
  double calculateQFactor(double frequency) {
    return calculateReactance(frequency) / dcResistance;
  }

  /// Check if current is within safe operating range
  bool isCurrentWithinRating() => current.abs() <= currentRating;

  @override
  String get behaviorType => 'passive_storage';

  @override
  List<String> get requiredConnections => ['terminal1', 'terminal2'];

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'row': row,
    'col': col,
    'state': state.toString(),
    'properties': properties,
    'rotation': rotation,
    'inductance': inductance,
    'currentRating': currentRating,
    'current': current,
    'dcResistance': dcResistance,
    'storedEnergy': storedEnergy,
    'fluxLinkage': fluxLinkage,
    'isWithinRating': isCurrentWithinRating(),
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

    return Inductor(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      state: state ?? this.state,
      properties: newProperties,
      rotation: rotation ?? this.rotation,
    );
  }

  factory Inductor.fromComponentModel(ComponentModel model) {
    try {
      return Inductor(
        id: model.id,
        row: model.row,
        col: model.col,
        state: model.state,
        properties: Map<String, dynamic>.from(model.properties),
        rotation: model.rotation,
      );
    } catch (e) {
      StructuredLogger.error('❌ Inductor.fromComponentModel failed for component ${model.id}: $e');
      StructuredLogger.error('   Stack trace: ${StackTrace.current}');

      // EMERGENCY FALLBACK - Create component with safe defaults
      StructuredLogger.warning('🛡️ Creating fallback inductor for ${model.id}');
      return Inductor(
        id: model.id,
        row: model.row,
        col: model.col,
        state: ComponentState.error,
        properties: {
          'inductance': 0.001,             // 1mH default
          'currentRating': 1.0,            // 1A default
          'current': 0.0,                  // No current initially
          'dcResistance': 0.01,            // 10mΩ default
          'error': e.toString(),
          'fallback_created': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  // PRIVATE VALIDATION METHODS
  void _validateInductance(double value) {
    if (value <= 0) {
      throw ArgumentError('Inductance must be positive: $value H');
    }
    if (value > 10) { // 10H reasonable upper limit
      throw ArgumentError('Inductance too high (max 10H): $value H');
    }
  }

  void _validateCurrentRating(double value) {
    if (value <= 0) {
      throw ArgumentError('Current rating must be positive: $value A');
    }
    if (value > 100) { // 100A reasonable upper limit
      throw ArgumentError('Current rating too high (max 100A): $value A');
    }
  }

  void _validatePosition(int row, int col) {
    if (row < 0 || col < 0) {
      throw ArgumentError('Component position must be non-negative: ($row, $col)');
    }
  }

  @override
  String toString() {
    return 'Inductor(id: $id, L: ${inductance.toStringAsFixed(6)}H, '
           'I: ${current.toStringAsFixed(3)}A/${currentRating.toStringAsFixed(1)}A MAX, '
           'Φ: ${fluxLinkage.toStringAsFixed(6)}Wb, E: ${storedEnergy.toStringAsFixed(6)}J, '
           'state: $state)';
  }
}