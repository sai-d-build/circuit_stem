import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/widgets/responsive_scaffold.dart';
import 'package:sparkcircuit/presentation/features/hud/widgets/level_card.dart';

class LevelSelect extends StatefulWidget {
  const LevelSelect({super.key});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Circuits',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: circuitColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn the fundamentals of circuit building',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: circuitColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  LevelCard(
                    levelId: '1',
                    title: 'First Light',
                    description: 'Light up an LED',
                    difficulty: 1,
                    isCompleted: false,
                    stars: 0,
                    onTap: () => context.go('/game/1'),
                  ),
                  LevelCard(
                    levelId: '2',
                    title: 'Series Circuit',
                    description: 'Connect in series',
                    difficulty: 2,
                    isCompleted: false,
                    stars: 0,
                    onTap: () => context.go('/game/2'),
                  ),
                  LevelCard(
                    levelId: '3',
                    title: 'Parallel Paths',
                    description: 'Create parallel branches',
                    difficulty: 2,
                    isCompleted: false,
                    stars: 0,
                    onTap: () => context.go('/game/3'),
                  ),
                ]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}