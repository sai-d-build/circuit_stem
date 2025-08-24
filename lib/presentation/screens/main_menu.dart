import 'package:circuit_stem/common/logger.dart';
import 'package:flutter/material.dart';

import 'package:circuit_stem/common/theme.dart'; // Import the theme file
import 'level_select.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  late Animation<Offset> _buttonSlide;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));
    
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 500), () {
      _logoController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _buttonController.forward();
    });
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
  
  void _navigateToLevelSelection() {
    Logger.log('MainMenuScreen: Navigating to LevelSelectScreen...');
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LevelSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.mainMenuBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo and title
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value * 2 * 3.14159,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withAlpha(77),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.electrical_services,
                            size: 60,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Circuit Kids',
                  style: Theme.of(context).textTheme.appTitle?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Circuit Simulation Game',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Build circuits, power bulbs, and learn electronics\nthrough interactive gameplay!',
                  style: Theme.of(context).textTheme.bodyTextSecondary?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Buttons
                SlideTransition(
                  position: _buttonSlide,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          key: const Key('start_playing_button'),
                          onPressed: _navigateToLevelSelection,
                          icon: Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          label: Text(
                            'Start Playing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showHowToPlay(context);
                          },
                          icon: Icon(
                            Icons.help_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            'How to Play',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton.icon(
                          onPressed: () {
                            _showAbout(context);
                          },
                          icon: Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          label: Text(
                            'About',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    '🎮 How to Play',
                    style: Theme.of(context).textTheme.appTitle,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInstructionItem(
                    context,
                    '🔋',
                    'Build Circuits',
                    'Drag components from the palette and place them on the grid to create electrical circuits.',
                  ),
                  
                  _buildInstructionItem(
                    context,
                    '💡',
                    'Power Components',
                    'Connect batteries to bulbs using wires to complete circuits and power up components.',
                  ),
                  
                  _buildInstructionItem(
                    context,
                    '🔄',
                    'Interact with Components',
                    'Tap switches to toggle them on/off. Tap other components to rotate their orientation.',
                  ),
                  
                  _buildInstructionItem(
                    context,
                    '⚠️',
                    'Avoid Short Circuits',
                    'Be careful not to create short circuits! The game will warn you if detected.',
                  ),
                  
                  _buildInstructionItem(
                    context,
                    '🎯',
                    'Complete Objectives',
                    'Each level has specific goals - usually powering certain bulbs or components.',
                  ),
                  
                  _buildInstructionItem(
                    context,
                    '🏆',
                    'Progress Through Levels',
                    'Complete levels to unlock new challenges with more complex circuits.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstructionItem(BuildContext context, String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.sectionTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyTextSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Circuit Kids'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Circuit Kids is an educational circuit simulation game designed to teach basic electronics and circuit building principles.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '⚡ Features:',
              style: Theme.of(context).textTheme.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              '• Interactive drag-and-drop interface\n'
              '• Realistic circuit simulation\n'
              '• Progressive difficulty levels\n'
              '• Visual and audio feedback\n'
              '• Educational and fun gameplay',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Built with Flutter for cross-platform compatibility.',
              style: Theme.of(context).textTheme.bodyTextSmallSecondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}