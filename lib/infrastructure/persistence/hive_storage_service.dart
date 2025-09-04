// lib/infrastructure/persistence/hive_storage_service.dart
// Hive implementation of StorageService

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/persistence/storage_service.dart';

class HiveStorageService implements StorageService {
  late Box _box;
  final String boxName;

  HiveStorageService(this.boxName);

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  @override
  Future<void> saveData<T>(String key, T value) async {
    await _box.put(key, value);
  }

  @override
  T? readData<T>(String key) {
    return _box.get(key) as T?;
  }

  @override
  Future<void> deleteData(String key) async {
    await _box.delete(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _box.containsKey(key);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  Future<void> saveState(String key, dynamic state) => saveData(key, state);

  // Additional Hive-specific methods
  Future<void> close() async {
    await _box.close();
  }

  Future<void> compact() async {
    await _box.compact();
  }
}