import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/presentation/widgets/component_palette.dart';
import 'package:circuit_stem/domain/entities/component.dart';

class ComponentPaletteAdapter extends ConsumerWidget {
  const ComponentPaletteAdapter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The adapter now reads from the new paletteManager.
    final paletteManager = ref.watch(gameEngineProvider.select((s) => s.paletteManager));
    final availableComponents = paletteManager.availableTemplates;
    final selectedComponentId = ref.watch(gameEngineProvider.select((s) => s.selectedComponentId));
    
    ComponentModel? selectedComponent;
    if (selectedComponentId != null) {
      try {
        selectedComponent = availableComponents.firstWhere((c) => c.id == selectedComponentId);
      } catch (e) {
        // It's possible for the selected component to disappear, so we handle the error.
        selectedComponent = null;
      }
    }

    // The adapter calls the OLD ComponentPalette, passing the data it expects.
    // No changes are needed in ComponentPalette itself yet.
    return ComponentPalette(
      availableComponents: availableComponents,
      selectedComponent: selectedComponent,
      onComponentSelected: (component) {
        ref.read(gameEngineProvider.notifier).selectPaletteComponent(component);
      },
    );
  }
}
