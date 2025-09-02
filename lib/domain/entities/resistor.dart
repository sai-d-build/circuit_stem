import 'circuit_component.dart';
import 'component.dart';

/// Resistor component that limits current flow in a circuit
class Resistor extends CircuitComponent {
  /// Resistance value in ohms
  double get resistance => getProperty<double>('resistance', 1000.0);
  set resistance(double value) => setProperty('resistance', value);

  Resistor({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    super.properties,
    super.rotation,
    double? resistance,
  }) : super(type: ComponentType.resistor) {
    if (resistance != null) {
      this.resistance = resistance;
    }
  }

  /// Factory constructor from ComponentModel
  factory Resistor.fromComponentModel(ComponentModel model) {
    return Resistor(
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
  Resistor copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
    double? resistance,
  }) {
    final newProperties = properties ?? Map.from(this.properties);
    if (resistance != null) {
      newProperties['resistance'] = resistance;
    }

    return Resistor(
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
    };
  }

  @override
  String get behaviorType => 'resistor';

  @override
  List<String> get requiredConnections => ['a', 'b'];

  /// Calculate current through resistor given voltage
  double calculateCurrent(double voltage) {
    return voltage / resistance;
  }

  /// Calculate power dissipation
  double calculatePower(double voltage) {
    final current = calculateCurrent(voltage);
    return voltage * current;
  }
}