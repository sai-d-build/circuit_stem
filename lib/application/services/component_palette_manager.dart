import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';

@immutable
class ComponentPaletteManager {
  const ComponentPaletteManager({required this.availableTemplates});

  final List<ComponentModel> availableTemplates;

  ComponentModel? getTemplateById(String id) {
    try {
      return availableTemplates.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
