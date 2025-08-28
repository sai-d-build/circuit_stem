/// A centralized class for managing application-wide feature flags.
class FeatureFlags {
  /// Determines whether to use the new Hybrid Facade game engine.
  ///
  /// **IMPORTANT**: Do NOT set this to `true` until Phase 3 of the
  /// refactoring is complete and all tests are passing.
  static const bool useHybridEngine = bool.fromEnvironment(
    'USE_HYBRID_ENGINE',
    defaultValue: false, // Default to OFF
  );
}
