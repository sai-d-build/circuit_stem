import 'package:circuit_stem/common/logger.dart';
import 'package:flutter/material.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/presentation/widgets/circuit_component_display.dart';
import 'package:circuit_stem/application/services/component_registry.dart';

class ComponentPalette extends StatelessWidget {
  final List<ComponentModel> availableComponents;
  final Function(ComponentModel component) onComponentSelected;
  final ComponentModel? selectedComponent;
  
  const ComponentPalette({
    super.key,
    required this.availableComponents,
    required this.onComponentSelected,
    this.selectedComponent,
  });

  @override
  Widget build(BuildContext context) {
    Logger.log('ComponentPalette: Building with ${availableComponents.length} available components: $availableComponents');
    final componentCounts = <String, int>{};
    for (final component in availableComponents) {
      componentCounts[component.type] = (componentCounts[component.type] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧩 Component Palette',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (availableComponents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'All components have been placed! 🎉',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: componentCounts.entries.map((entry) {
                final componentType = entry.key;
                final count = entry.value;
                final component = availableComponents.firstWhere(
                  (c) => c.type == componentType,
                );
                
                return ComponentPaletteItem(
                  component: component,
                  count: count,
                  isSelected: selectedComponent?.type == componentType,
                  onTap: () => onComponentSelected(component),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class ComponentPaletteItem extends StatelessWidget {
  final ComponentModel component;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  
  const ComponentPaletteItem({
    super.key,
    required this.component,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentModel>(
      data: component,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CircuitComponentDisplay(
            component: component,
            size: 40,
            isPreview: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildComponentItem(context),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _buildComponentItem(context),
      ),
    );
  }
  
  Widget _buildComponentItem(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withAlpha(77),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircuitComponentDisplay(
            component: component,
            size: 32,
            isPreview: true,
          ),
          const SizedBox(height: 4),
          Text(
            ComponentRegistry.getDisplayName(component.type),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (count > 1)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
