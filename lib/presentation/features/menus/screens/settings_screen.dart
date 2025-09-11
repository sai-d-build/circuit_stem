// Settings screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../application/game_engine/v3/providers_v3.dart';
import '../../../../application/audio_manager.dart';
import 'package:sparkcircuit/presentation/ui_components/glass_panel.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_switch.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_slider.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_dropdown.dart';

// ✅ CLEAN ARCHITECTURE: Settings Service
class SettingsService {
  final dynamic storageService;
  final dynamic audioManager;

  SettingsService(this.storageService, this.audioManager);

  // Storage operations
  T? readData<T>(String key) => storageService.readData<T>(key);
  Future<void> saveData<T>(String key, T value) => storageService.saveData<T>(key, value);

  // Audio operations
  void setSfxVolume(double volume) => audioManager.setSfxVolume(volume);
  void setBgmVolume(double volume) => audioManager.setBgmVolume(volume);
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final audioManager = ref.watch(audioManagerProvider);
  return SettingsService(storageService, audioManager);
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hintsEnabled = true;
  String _difficulty = 'Normal';
  double _soundVolume = 1.0;
  double _musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    // _loadAudioSettings will be called in build when service is available
  }

  Future<void> _loadAudioSettings(SettingsService settingsService) async {
    final soundEnabled = settingsService.readData<bool>('sound_enabled') ?? true;
    final musicEnabled = settingsService.readData<bool>('music_enabled') ?? true;
    final soundVolume = settingsService.readData<double>('sound_volume') ?? 1.0;
    final musicVolume = settingsService.readData<double>('music_volume') ?? 0.5;

    setState(() {
      _soundEnabled = soundEnabled;
      _musicEnabled = musicEnabled;
      _soundVolume = soundVolume;
      _musicVolume = musicVolume;
    });

    // Apply settings to AudioManager
    settingsService.setSfxVolume(soundEnabled ? soundVolume : 0.0);
    settingsService.setBgmVolume(musicEnabled ? musicVolume : 0.0);
  }

  Future<void> _saveAudioSettings(SettingsService settingsService) async {
    await settingsService.saveData<bool>('sound_enabled', _soundEnabled);
    await settingsService.saveData<bool>('music_enabled', _musicEnabled);
    await settingsService.saveData<double>('sound_volume', _soundVolume);
    await settingsService.saveData<double>('music_volume', _musicVolume);
  }

  Future<void> _resetProgress(SettingsService settingsService) async {
    // Clear all progress-related data
    await settingsService.saveData('completed_levels', <String>[]);
    await settingsService.saveData('player_progress', {});
    await settingsService.saveData('level_scores', {});
    await settingsService.saveData('hints_used', {});
    await settingsService.saveData('time_spent', {});

    // Reset settings to defaults
    await settingsService.saveData<bool>('sound_enabled', true);
    await settingsService.saveData<bool>('music_enabled', true);
    await settingsService.saveData<double>('sound_volume', 1.0);
    await settingsService.saveData<double>('music_volume', 0.5);

    // Update local state
    setState(() {
      _soundEnabled = true;
      _musicEnabled = true;
      _soundVolume = 1.0;
      _musicVolume = 0.5;
      _hintsEnabled = true;
      _difficulty = 'Normal';
    });

    // Apply default audio settings
    settingsService.setSfxVolume(1.0);
    settingsService.setBgmVolume(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = ref.watch(settingsServiceProvider);

    // Load audio settings on first build
    if (_soundEnabled == true && _musicEnabled == true && _soundVolume == 1.0 && _musicVolume == 0.5) {
      // This is likely the first build, load settings
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAudioSettings(settingsService);
      });
    }

    final colors = Theme.of(context).extension<CircuitColorScheme>() ?? const CircuitColorScheme(
      primary: Color(0xFF1E88E5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF43A047),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFF8F00),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFFEFEFEF),
      onSurfaceVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      outline: Color(0xFFBDBDBD),
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
      neonPrimary: Color(0xFF00FFFF),
      neonAccent: Color(0xFFFF00FF),
      errorGlow: Color(0xFFFF0040),
      energyPulse: Color(0xFF39FF14),
      highlightAccent: Color(0xFFFFFF00),
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: textTheme.headlineMedium?.copyWith(
            color: colors.onSurface,
            shadows: [
              BoxShadow(
                color: colors.neonPrimary.withValues(alpha: 0.5),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Audio', colors, textTheme),
          _buildSwitchTile(
            'Sound Effects',
            _soundEnabled,
            (value) {
              setState(() => _soundEnabled = value);
              settingsService.setSfxVolume(value ? 1.0 : 0.0);
              _saveAudioSettings(settingsService);
            },
            colors,
            textTheme,
          ),
          _buildSwitchTile(
            'Background Music',
            _musicEnabled,
            (value) {
              setState(() => _musicEnabled = value);
              settingsService.setBgmVolume(value ? _musicVolume : 0.0);
              _saveAudioSettings(settingsService);
            },
            colors,
            textTheme,
          ),
          if (_soundEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: NeonSlider(
                label: 'Sound Volume',
                value: _soundVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() => _soundVolume = value);
                  settingsService.setSfxVolume(_soundEnabled ? value : 0.0);
                  _saveAudioSettings(settingsService);
                },
              ),
            ),
          if (_musicEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: NeonSlider(
                label: 'Music Volume',
                value: _musicVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() => _musicVolume = value);
                  settingsService.setBgmVolume(_musicEnabled ? value : 0.0);
                  _saveAudioSettings(settingsService);
                },
              ),
            ),
          const SizedBox(height: 24),

          _buildSectionHeader('Gameplay', colors, textTheme),
          _buildSwitchTile(
            'Show Hints',
            _hintsEnabled,
            (value) => setState(() => _hintsEnabled = value),
            colors,
            textTheme,
          ),
          _buildDropdownTile(
            'Difficulty',
            _difficulty,
            ['Easy', 'Normal', 'Hard'],
            (value) => setState(() => _difficulty = value!),
            colors,
            textTheme,
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('About', colors, textTheme),
          _buildInfoTile('Version', '1.0.0', colors, textTheme),
          _buildInfoTile('Educational Platform', 'SparkCircuit', colors, textTheme),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              _showResetDialog(colors, textTheme, settingsService);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.errorGlow,
              foregroundColor: colors.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('Reset Progress', style: textTheme.titleMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, CircuitColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.neonPrimary,
          shadows: [
            BoxShadow(
              color: colors.neonPrimary.withValues(alpha: 0.5),
              blurRadius: 8.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, CircuitColorScheme colors, TextTheme textTheme) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textTheme.bodyLarge?.copyWith(color: colors.onSurface)),
            NeonSwitch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    Function(String?) onChanged,
    CircuitColorScheme colors,
    TextTheme textTheme,
  ) {
    return NeonDropdown<String>(
      label: title,
      value: value,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: textTheme.bodyMedium?.copyWith(color: colors.onSurface)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoTile(String title, String value, CircuitColorScheme colors, TextTheme textTheme) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textTheme.bodyLarge?.copyWith(color: colors.onSurface)),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(CircuitColorScheme colors, TextTheme textTheme, SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
        title: Text('Reset Progress', style: textTheme.titleLarge?.copyWith(color: colors.onSurface)),
        content: Text(
          'Are you sure you want to reset all progress? This action cannot be undone.',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: textTheme.labelLarge?.copyWith(color: colors.onSurface)),
          ),
          TextButton(
            onPressed: () async {
              await _resetProgress(settingsService);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress reset successfully', style: TextStyle(color: colors.onPrimary)),
                    backgroundColor: colors.neonPrimary,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: colors.errorGlow),
            child: Text('Reset', style: textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}