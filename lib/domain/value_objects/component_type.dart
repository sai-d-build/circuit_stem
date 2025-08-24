enum ComponentType {
  battery,
  bulb,
  switchComponent,
  wire,
  buzzer,
  timer,
  unknown,
}

// Helper to convert string to ComponentType
ComponentType stringToComponentType(String type) {
  switch (type.toLowerCase()) {
    case 'battery':
      return ComponentType.battery;
    case 'bulb':
      return ComponentType.bulb;
    case 'switch':
      return ComponentType.switchComponent;
    case 'wire':
      return ComponentType.wire;
    case 'buzzer':
      return ComponentType.buzzer;
    case 'timer':
      return ComponentType.timer;
    default:
      return ComponentType.unknown;
  }
}
