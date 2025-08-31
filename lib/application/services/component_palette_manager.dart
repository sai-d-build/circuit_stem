import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:flutter/foundation.dart';

@immutable
class ComponentPaletteManager {
  const ComponentPaletteManager(this.availableTemplates);

  final List<ComponentModel> availableTemplates;

  ComponentModel? getTemplateById(String id) {
    try {
      return availableTemplates.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
