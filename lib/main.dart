// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'application/services/providers.dart';
import 'common/logger.dart';
import 'common/assets.dart';
import 'dart:async';
import 'infrastructure/rendering/svg_processor.dart';
import 'infrastructure/rendering/svg_processor_base.dart';
import 'components/bulb.dart';
import 'components/wire.dart';
import 'components/switch.dart';
import 'components/battery.dart';
import 'components/timer.dart';
import 'components/buzzer.dart';
import 'domain/goals/power_bulb_goal.dart';

void registerAllGameEntities() {
  registerBulb();
  registerWireStraight();
  registerWireCorner();
  registerWireT();
  registerSwitch();
  registerBattery();
  registerTimer();
  registerCrossWire();
  registerBuzzer();

  // Goals
  registerPowerBulbGoal();
}

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();

  // Basic synchronous service setup
  final prefs = await SharedPreferences.getInstance();

  // Instantiate the SvgProcessor
  final SvgProcessorBase svgProcessor = SvgProcessor();

  // Register all component and goal behaviors.
  registerAllGameEntities();
  Logger.log('main.dart: All game entities registered.');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: Initializer(svgProcessor: svgProcessor), // Pass processor to Initializer
    ),
  );
  Logger.log('runApp() called');
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAssets());
  }

  Future<void> _initializeAssets() async {
    final assetManager = ref.read(assetManagerProvider.notifier);
    await assetManager.loadAllAssets(); // Load non-svg assets

    final svgPaths = AppAssets.all.where((p) => p.endsWith('.svg')).toList();

    try {
      setState(() => _status = 'Processing SVGs...');
      final images = await widget.svgProcessor.processSvgs(svgPaths);
      
      assetManager.setSvgImages(images);
      Logger.log('SVG processing complete. ${images.length} images set in AssetManager.');

      setState(() => _ready = true);
    } catch (e) {
      Logger.log('Error during SVG processing: $e');
      setState(() => _ready = true); // allow app to continue even if svg step failed
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