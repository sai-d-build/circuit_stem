/// A class to hold all asset paths for the application.
class AppAssets {
  // Base asset directory
  static const String _assetsBase = 'assets';

  // Audio assets
  static const String audioPlacement =
      '$_assetsBase/audio/place.wav'; // Renamed from audioPlace
  static const String audioSuccess = '$_assetsBase/audio/success.wav';
  static const String audioSwitch =
      '$_assetsBase/audio/toggle.wav'; // Renamed from audioToggle
  static const String audioWarning = '$_assetsBase/audio/warning.wav';

  // Image assets
  static const String imageBattery = '$_assetsBase/images/battery.svg';
  static const String imageBulbOff = '$_assetsBase/images/bulb_off.svg';
  static const String imageBulbOn = '$_assetsBase/images/bulb_on.svg';
  static const String imageGridBgLevel1 =
      '$_assetsBase/images/grid_bg_level1.png';
  static const String imageSwitchClosed =
      '$_assetsBase/images/switch_closed.svg';
  static const String imageSwitchOpen = '$_assetsBase/images/switch_open.svg';
  static const String imageWireCorner = '$_assetsBase/images/wire_corner.svg';
  static const String imageWireStraight =
      '$_assetsBase/images/wire_straight.svg';
  static const String imageWireT = '$_assetsBase/images/wire_t.svg';

  // Level assets
  static const String levelsBase = '$_assetsBase/levels';
  static String levelManifest = '$levelsBase/level_manifest.json';
  static String levelPath(String levelId) => '$levelsBase/$levelId.json';

  // All assets
  static const List<String> all = [
    audioPlacement,
    audioSuccess,
    audioSwitch,
    audioWarning,
    imageBattery,
    imageBulbOff,
    imageBulbOn,
    imageGridBgLevel1,
    imageSwitchClosed,
    imageSwitchOpen,
    imageWireCorner,
    imageWireStraight,
    imageWireT,
  ];

  /// Utility method to ensure asset paths are properly formatted
  static String normalizePath(String path) {
    // Remove any leading slash and ensure it starts with assets/
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (!cleanPath.startsWith(_assetsBase)) {
      return '$_assetsBase/$cleanPath';
    }
    return cleanPath;
  }

  /// Validate that an asset path is properly formatted
  static bool isValidAssetPath(String path) {
    return path.startsWith(_assetsBase) &&
        !path.contains('$_assetsBase/$_assetsBase');
  }
}
