import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/palette/widgets/component_widget.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

// ✅ CLEAN ARCHITECTURE: Palette Service
class PaletteService {
  final dynamic paletteNotifier;

  PaletteService(this.paletteNotifier);

  void updateSearchQuery(String query) =>
      paletteNotifier.updateSearchQuery(query);
  void clearSearch() => paletteNotifier.clearSearch();
  void addFilter(String filter) => paletteNotifier.addFilter(filter);
  void removeFilter(String filter) => paletteNotifier.removeFilter(filter);
  void clearFilters() => paletteNotifier.clearFilters();
  bool canUseComponent(String componentType) =>
      paletteNotifier.canUseComponent(componentType);
  void selectComponent(String componentType) =>
      paletteNotifier.selectComponent(componentType);
  void startPlacingComponent(String componentType) =>
      paletteNotifier.startPlacingComponent(componentType);
}

final paletteServiceProvider =
    Provider.family<PaletteService, String>((ref, levelId) {
  final paletteNotifier = ref.watch(paletteStateProvider(levelId).notifier);
  return PaletteService(paletteNotifier);
});

class ComponentPalette extends ConsumerStatefulWidget {
  final String levelId;

  const ComponentPalette({super.key, required this.levelId});

  @override
  ConsumerState<ComponentPalette> createState() => _ComponentPaletteState();
}

class _ComponentPaletteState extends ConsumerState<ComponentPalette>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final paletteState = ref.watch(paletteStateProvider(widget.levelId));
    final paletteService = ref.watch(paletteServiceProvider(widget.levelId));

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((-1 + _slideAnimation.value) * 280, 0),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: circuitColors.surfaceContainer.withValues(alpha: 0.95),
              border: Border(
                right: BorderSide(
                  color: circuitColors.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: circuitColors.shadow.withValues(alpha: 0.1),
                  offset: const Offset(2, 0),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(theme, circuitColors),
                _buildSearchBar(theme, circuitColors, paletteService),
                _buildFilters(
                    theme, circuitColors, paletteState, paletteService),
                Expanded(
                  child: _buildComponentList(
                      theme, circuitColors, paletteState, paletteService),
                ),
                _buildFooter(
                    theme, circuitColors, paletteState, paletteService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, CircuitColorScheme circuitColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: circuitColors.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: circuitColors.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: circuitColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Components',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: circuitColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Drag to canvas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: circuitColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, CircuitColorScheme circuitColors,
      PaletteService paletteService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          paletteService.updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search components...',
          prefixIcon: Icon(
            Icons.search,
            color: circuitColors.onSurfaceVariant,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    paletteService.clearSearch();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: circuitColors.onSurfaceVariant,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: circuitColors.surface.withValues(alpha: 0.8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    PaletteState paletteState,
    PaletteService paletteService,
  ) {
    final filters = ['Basic', 'Active', 'Passive', 'Power', 'Measurement'];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive =
              paletteState.activeFilters.contains(filter.toLowerCase());

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  paletteService.addFilter(filter.toLowerCase());
                } else {
                  paletteService.removeFilter(filter.toLowerCase());
                }
              },
              backgroundColor: circuitColors.surface,
              selectedColor: circuitColors.primary.withValues(alpha: 0.2),
              checkmarkColor: circuitColors.primary,
              labelStyle: TextStyle(
                color:
                    isActive ? circuitColors.primary : circuitColors.onSurface,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComponentList(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    PaletteState paletteState,
    PaletteService paletteService,
  ) {
    final filteredComponents = paletteState.filteredComponents;

    if (filteredComponents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: circuitColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No components found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: circuitColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: circuitColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: filteredComponents.length,
      itemBuilder: (context, index) {
        final component = filteredComponents[index];
        final inventory = paletteState.getInventory(component.type);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ComponentWidget(
            component: component,
            inventory: inventory,
            isSelected: paletteState.selectedComponentType == component.type,
            onTap: () => _selectComponent(component.type, paletteService),
            onDragStart: () => _startDrag(component.type, paletteService),
          ),
        );
      },
    );
  }

  Widget _buildFooter(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    PaletteState paletteState,
    PaletteService paletteService,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: circuitColors.surface.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: circuitColors.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${paletteState.filteredComponents.length} components available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: circuitColors.onSurfaceVariant,
              ),
            ),
          ),
          if (paletteState.hasFilters || paletteState.hasSearch)
            TextButton(
              onPressed: () {
                _searchController.clear();
                paletteService.clearSearch();
                paletteService.clearFilters();
              },
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  void _selectComponent(String componentType, PaletteService paletteService) {
    StructuredLogger.info('Component selection initiated', context: {
      'componentType': componentType,
      'levelId': widget.levelId,
    });

    final canUse = paletteService.canUseComponent(componentType);

    if (canUse) {
      StructuredLogger.info(
          'Component selection approved - starting placement mode',
          context: {
            'componentType': componentType,
            'action': 'selection_and_placement',
          });

      paletteService.selectComponent(componentType);
      paletteService.startPlacingComponent(componentType);

      StructuredLogger.debug('Component selection complete', context: {
        'componentType': componentType,
        'result': 'placement_mode_active',
      });
    } else {
      StructuredLogger.warning(
          'Component selection denied - insufficient inventory',
          context: {
            'componentType': componentType,
            'reason': 'not_available_in_inventory',
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more $componentType components available'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startDrag(String componentType, PaletteService paletteService) {
    paletteService.selectComponent(componentType);
  }
}
