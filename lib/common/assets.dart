/// A class to hold all asset paths for the application.
class AppAssets {
  // Audio assets
  static const String audioPlacement = 'assets/audio/place.wav'; // Renamed from audioPlace
  static const String audioSuccess = 'assets/audio/success.wav';
  static const String audioSwitch = 'assets/audio/toggle.wav'; // Renamed from audioToggle
  static const String audioWarning = 'assets/audio/warning.wav';

  // Image assets
  static const String imageBattery = 'assets/images/battery.svg';
  static const String imageBulbOff = 'assets/images/bulb_off.svg';
  static const String imageBulbOn = 'assets/images/bulb_on.svg';
  static const String imageGridBgLevel1 = 'assets/images/grid_bg_level1.png';
  static const String imageSwitchClosed = 'assets/images/switch_closed.svg';
  static const String imageSwitchOpen = 'assets/images/switch_open.svg';
  static const String imageWireCorner = 'assets/images/wire_corner.svg';
  static const String imageWireStraight = 'assets/images/wire_straight.svg';
  static const String imageWireT = 'assets/images/wire_t.svg';

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
}