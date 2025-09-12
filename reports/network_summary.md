# Network, Caching & Offline Behavior

**Caching Mechanisms:** Hive (persistence for levels/user), shared_preferences (settings), firebase_auth/firestore (cloud sync). No cached_network_image (no network images).

**Insecure Endpoints:** None (1 http:// in SVG namespace, not API; Firebase uses https).

**Retry/Backoff/Error Handling:** Limited—maxRetryAttempts=3, retryDelay=2s in cloud_config; some try-catch in services, but no exponential backoff. Timeout in animation/placement (e.g., _transactionTimeout).

**Offline Behavior:** Graceful for local (Hive levels, audio); auth/game play offline, but Firebase sync fails with unhandled exceptions (no offline queue). Recommend Connectivity+ listener for degradation.

**Limitation:** Cannot run app to test offline; suggest user exercises login/level load offline.