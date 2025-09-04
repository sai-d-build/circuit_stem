import 'logger.dart';
import '../application/services/component_factory.dart';

void checkMoveBehaviorAttachment(ComponentFactory factory) {
  Logger.log('--- MoveBehavior Attachment Check ---');

  // Assuming ComponentRegistry has a way to get all registered component types
  // If not, you might need to add a static getter in ComponentRegistry
  // For now, let's iterate through known component types that should have MoveBehavior
  final componentTypesToCheck = [
    'Component.Bulb',
    'Component.Buzzer',
    'Component.WireStraight',
    'Component.WireCorner',
    'Component.WireT',
    'Component.CrossWire',
    'Component.Timer',
  ];

  for (var type in componentTypesToCheck) {
    // Create a dummy component to check its behaviors
    // This assumes create() or createFromJson() can be called with minimal data
    // and will attach behaviors based on registration.
    try {
      final dummyComponent = factory.create(
        type: type,
        id: 'dummy_${type.replaceAll('.', '_')}',
        r: 0,
        c: 0,
      );
      final componentModel = dummyComponent.toComponentModel();
      final hasMoveBehavior =
          componentModel.behaviors.contains('MoveBehavior');

      if (hasMoveBehavior) {
        Logger.log('✅ $type has MoveBehavior attached');
      } else {
        Logger.log('❌ $type is MISSING MoveBehavior');
      }

      // Optional: List all attached behaviors
      Logger.log(
          '   Attached behaviors for $type: ${componentModel.behaviors.map((b) => b.runtimeType).join(', ')}');
    } catch (e) {
      Logger.log('Error checking $type: $e');
    }
  }

  Logger.log('--- End of Check ---');
}
