import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/widgets/responsive_scaffold.dart';
import 'package:sparkcircuit/presentation/core/widgets/menu_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Circuit STEM',
      description: 'Learn electronics through interactive circuit building and simulation.',
      icon: Icons.developer_board,
      color: const Color(0xFF1E88E5),
    ),
    OnboardingPage(
      title: 'Drag & Drop Components',
      description: 'Select components from the palette and drag them onto the grid to build your circuit.',
      icon: Icons.touch_app,
      color: const Color(0xFF43A047),
    ),
    OnboardingPage(
      title: 'Connect with Wires',
      description: 'Connect components together to complete circuits and see electricity flow.',
      icon: Icons.cable,
      color: const Color(0xFFFF8F00),
    ),
    OnboardingPage(
      title: 'Simulate & Learn',
      description: 'Test your circuits, see current flow, and learn from interactive feedback.',
      icon: Icons.play_circle,
      color: const Color(0xFF8E24AA),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return ResponsiveScaffold(
      backgroundColor: circuitColors.surface,
      body: Column(
        children: [
          // Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Skip'),
                ),
              ),
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: page.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: page.color.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          page.icon,
                          size: 60,
                          color: page.color,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        page.title,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: circuitColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        page.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: circuitColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Page indicator and navigation
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _pages.asMap().entries.map((entry) {
                    return Container(
                      width: _currentPage == entry.key ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == entry.key
                            ? circuitColors.primary
                            : circuitColors.outline.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: MenuButton(
                          text: 'Previous',
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      child: MenuButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        isPrimary: true,
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            context.go('/');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}