import 'package:flutter_riverpod/flutter_riverpod.dart';


class TestSetup {
  final ProviderContainer container;
  final List<ProviderSubscription> _listeners = [];

  TestSetup(this.container);

  /// Prevents an autoDispose provider from being disposed prematurely
  /// when the widget tree temporarily stops listening.
  void keepAlive<T>(ProviderListenable<T> provider) {
    final sub = container.listen<T>(provider, (_, __) {});
    _listeners.add(sub);
  }

  void dispose() {
    for (final l in _listeners) {
      l.close();
    }
    container.dispose();
  }
}
