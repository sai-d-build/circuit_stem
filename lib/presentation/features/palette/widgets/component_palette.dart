import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/presentation/features/palette/widgets/component_widget.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

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
      begin: 0.0,
      end: 1.0,
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
                _buildSearchBar(theme, circuitColors),
                _buildFilters(theme, circuitColors, paletteState),
                Expanded(
                  child: _buildComponentList(theme, circuitColors, paletteState),
                ),
                _buildFooter(theme, circuitColors, paletteState),
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

  Widget _buildSearchBar(ThemeData theme, CircuitColorScheme circuitColors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(paletteStateProvider(widget.levelId).notifier).updateSearchQuery(value);
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
                    ref.read(paletteStateProvider(widget.levelId).notifier).clearSearch();
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    PaletteState paletteState,
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
          final isActive = paletteState.activeFilters.contains(filter.toLowerCase());
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  ref.read(paletteStateProvider(widget.levelId).notifier).addFilter(filter.toLowerCase());
                } else {
                  ref.read(paletteStateProvider(widget.levelId).notifier).removeFilter(filter.toLowerCase());
                }
              },
              backgroundColor: circuitColors.surface,
              selectedColor: circuitColors.primary.withValues(alpha: 0.2),
              checkmarkColor: circuitColors.primary,
              labelStyle: TextStyle(
                color: isActive ? circuitColors.primary : circuitColors.onSurface,
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
            onTap: () => _selectComponent(component.type),
            onDragStart: () => _startDrag(component.type),
          ),
        );
      },
    );
  }

  Widget _buildFooter(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    PaletteState paletteState,
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
                ref.read(paletteStateProvider(widget.levelId).notifier).clearSearch();
                ref.read(paletteStateProvider(widget.levelId).notifier).clearFilters();
              },
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  void _selectComponent(String componentType) {
    StructuredLogger.info('Component selection initiated', context: {
      'componentType': componentType,
      'levelId': widget.levelId,
    });

    final paletteNotifier = ref.read(paletteStateProvider(widget.levelId).notifier);

    if (paletteNotifier.canUseComponent(componentType)) {
      StructuredLogger.info('Component selection approved - starting placement mode', context: {
        'componentType': componentType,
        'action': 'selection_and_placement',
      });

      paletteNotifier.selectComponent(componentType);
      paletteNotifier.startPlacingComponent(componentType);

      StructuredLogger.debug('Component selection complete', context: {
        'componentType': componentType,
        'result': 'placement_mode_active',
      });
    } else {
      StructuredLogger.warning('Component selection denied - insufficient inventory', context: {
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

  void _startDrag(String componentType) {
    ref.read(paletteStateProvider(widget.levelId).notifier).selectComponent(componentType);
  }
}