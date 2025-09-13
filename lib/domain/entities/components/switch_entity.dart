import '../core/component.dart';
import 'circuit_component.dart';

/// Switch component that controls current flow in a circuit
class SwitchEntity extends CircuitComponent {
  /// Whether the switch is currently closed (allowing current flow)
  bool get isOn => getProperty<bool>('isOn', false);
  set isOn(bool value) => setProperty('isOn', value);

  /// Whether the switch is closed (same as isOn for clarity)
  bool get isClosed => isOn;
  set isClosed(bool value) => isOn = value;

  SwitchEntity({
    required super.id,
    required super.row,
    required super.col,
    super.state,
    super.properties,
    super.rotation,
    bool? isOn,
  }) : super(type: ComponentType.switch_) {
    if (isOn != null) {
      this.isOn = isOn;
    }
  }

  /// Factory constructor from ComponentModel
  factory SwitchEntity.fromComponentModel(ComponentModel model) {
    return SwitchEntity(
      id: model.id,
      row: model.row,
      col: model.col,
      state: model.state,
      properties: Map.from(model.properties),
      rotation: model.rotation,
      isOn: model.isOn,
    );
  }

  @override
  SwitchEntity copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
    bool? isOn,
  }) {
    final newProperties = properties ?? Map.from(this.properties);
    if (isOn != null) {
      newProperties['isOn'] = isOn;
    }

    return SwitchEntity(
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
      'isOn': isOn,
      'isClosed': isClosed,
    };
  }

  @override
  String get behaviorType => 'switch';

  @override
  List<String> get requiredConnections => ['input', 'output'];

  @override
  double get resistance => getEffectiveResistance();

  /// Toggle the switch state
  void toggle() {
    isOn = !isOn;
  }

  /// Turn the switch on
  void turnOn() {
    isOn = true;
  }

  /// Turn the switch off
  void turnOff() {
    isOn = false;
  }

  /// Get resistance based on switch state (0 when closed, infinite when open)
  double getEffectiveResistance() {
    return isOn ? 0.001 : double.infinity; // Small resistance when closed
  }

  /// Check if current can flow through the switch
  bool allowsCurrentFlow() {
    return isOn;
  }
}
