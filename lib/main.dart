// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'presentation/state/game_state.dart';
import 'common/logger.dart';
import 'common/assets.dart';
import 'dart:async';
import 'infrastructure/rendering/svg_processor.dart';
import 'infrastructure/rendering/svg_processor_base.dart';
import 'common/debug_utils.dart'; // Import the new debug utility
import 'application/services/component_registry.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate the SvgProcessor
  final SvgProcessorBase svgProcessor = SvgProcessor();

  // Register all component and goal behaviors.
  ComponentRegistry.registerAllGameEntities();
  Logger.log('main.dart: All game entities registered.');

  // Run the MoveBehavior attachment check
  checkMoveBehaviorAttachment(); // Call the new utility

  runApp(
    ProviderScope(
      child: Initializer(
          svgProcessor: svgProcessor), // Pass processor to Initializer
    ),
  );
  Logger.log('runApp() called');
}

class Initializer extends ConsumerStatefulWidget {
  final SvgProcessorBase svgProcessor;
  const Initializer({super.key, required this.svgProcessor});

  @override
  InitializerState createState() => InitializerState();
}

class InitializerState extends ConsumerState<Initializer> {
  bool _ready = false;
  String _status = 'Preparing assets...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAssets();
    });
  }

  Future<void> _initializeAssets() async {
    // Initialize LevelManager
    setState(() => _status = 'Loading levels...');
    // Reading the provider will initialize it, thanks to Riverpod.
    await ref.read(levelManagerProvider.notifier).init();

    final assetManager = ref.read(assetManagerProvider.notifier);
    await assetManager.loadAllAssets(); // Load non-svg assets

    final svgPaths = AppAssets.all.where((p) => p.endsWith('.svg')).toList();

    try {
      setState(() => _status = 'Processing SVGs...');
      final images = await widget.svgProcessor.processSvgs(svgPaths);

      assetManager.setSvgImages(images);
      Logger.log(
          'SVG processing complete. ${images.length} images set in AssetManager.');

      setState(() => _ready = true);
    } catch (e) {
      Logger.log('Error during SVG processing: $e');
      setState(
          () => _ready = true); // allow app to continue even if svg step failed
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(_status),
              ],
            ),
          ),
        ),
      );
    }

    // Ready -> run real App
    return const App();
  }
}
