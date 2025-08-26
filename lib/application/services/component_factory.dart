import 'package:circuit_stem/domain/entities/component.dart';
import 'package:uuid/uuid.dart';

class ComponentFactory {
  const ComponentFactory();

  ComponentModel createInstanceFromTemplate(ComponentModel template, int r, int c) {
    return template.copyWith(
      id: const Uuid().v4(), // Centralized ID generation
      r: r,
      c: c,
    );
  }
}
