// Simplified Provider Test Helper
// A minimal version to avoid code generation issues

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderTestHelper {
  static ProviderContainer createTestContainer() {
    return ProviderContainer();
  }

  static void dispose(ProviderContainer container) {
    container.dispose();
  }

  static bool validateContainer(ProviderContainer container) {
    try {
      container.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }
}