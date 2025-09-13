import '../../components/battery.dart';
import '../../components/bulb.dart';
import '../../components/buzzer.dart';
import '../../components/switch.dart';
import '../../components/timer.dart';
import '../../components/wire.dart';
import '../../domain/goals/power_bulb_goal.dart';
import './component_factory.dart';

class ComponentRegistry {
  static void registerAll(ComponentFactory factory) {
    // This is still not ideal, but it's a step towards a better system.
    // A true self-registration system might use annotations or other mechanisms
    // to avoid having to list all components here.
    registerBulb(factory);
    registerWireStraight(factory);
    registerWireCorner(factory);
    registerWireT(factory);
    registerSwitch(factory);
    registerBattery(factory);
    registerTimer(factory);
    registerCrossWire(factory);
    registerBuzzer(factory);
    registerPowerBulbGoal(factory);
  }
}
