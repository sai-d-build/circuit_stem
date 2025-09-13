// lib/core/persistence/storage_service.dart
// Abstract interface for local data storage operations

abstract class StorageService {
  /// Initialize the storage service (e.g., open database connections)
  Future<void> init();

  /// Save data with the given key
  Future<void> saveData<T>(String key, T value);

  /// Read data for the given key, returns null if not found
  T? readData<T>(String key);

  /// Delete data for the given key
  Future<void> deleteData(String key);

  /// Check if a key exists in storage
  Future<bool> containsKey(String key);

  /// Clear all data (use with caution)
  Future<void> clearAll();

  /// Save state (for V2 compatibility - delegates to saveData)
  Future<void> saveState(String key, dynamic state) => saveData(key, state);
}
