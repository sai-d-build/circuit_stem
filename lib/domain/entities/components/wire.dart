import '../core/component.dart';
import 'circuit_component.dart';

/// Wire component that connects other components in a circuit
class Wire extends CircuitComponent {
  /// Wire resistance in ohms (usually very low)
  @override
  double get resistance => getProperty<double>('resistance', 0);
  set resistance(double value) => setProperty('resistance', value);

  /// Wire length (for calculating resistance based on material properties)
  double get length => getProperty<double>('length', 1);
  set length(double value) => setProperty('length', value);

  /// Wire material (affects resistance calculation)
  String get material => getProperty<String>('material', 'copper');
  set material(String value) => setProperty('material', value);

  Wire({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    super.properties,
    super.rotation,
    double? resistance,
    double? length,
    String? material,
  }) : super(type: ComponentType.wire) {
    if (resistance != null) {
      this.resistance = resistance;
    }
    if (length != null) {
      this.length = length;
    }
    if (material != null) {
      this.material = material;
    }
  }

  /// Factory constructor from ComponentModel
  factory Wire.fromComponentModel(ComponentModel model) {
    return Wire(
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
  Wire copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
    double? resistance,
    double? length,
    String? material,
  }) {
    final newProperties = properties ?? Map.from(this.properties);
    if (resistance != null) {
      newProperties['resistance'] = resistance;
    }
    if (length != null) {
      newProperties['length'] = length;
    }
    if (material != null) {
      newProperties['material'] = material;
    }

    return Wire(
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
      'length': length,
      'material': material,
    };
  }

  @override
  String get behaviorType => 'wire';

  @override
  List<String> get requiredConnections => ['start', 'end'];

  /// Calculate resistance based on material properties and length
  double calculateResistanceFromMaterial() {
    // Resistivity values in ohm-meters
    const resistivity = {
      'copper': 1.68e-8,
      'aluminum': 2.82e-8,
      'gold': 2.44e-8,
      'silver': 1.59e-8,
    };

    final materialResistivity =
        resistivity[material.toLowerCase()] ?? resistivity['copper']!;
    const crossSectionalArea = 1e-6; // Assume 1mm² cross-section
    return (materialResistivity * length) / crossSectionalArea;
  }

  /// Update resistance based on material and length
  void updateResistance() {
    resistance = calculateResistanceFromMaterial();
  }

  /// Check if wire is conducting (always true for wires unless broken)
  bool isConducting() {
    return true;
  }
}
