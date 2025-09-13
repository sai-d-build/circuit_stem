// lib/infrastructure/persistence/shared_preferences_storage_service.dart
// SharedPreferences implementation of StorageService

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/persistence/storage_service.dart';

class SharedPreferencesStorageService implements StorageService {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveData<T>(String key, T value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      // For complex objects, convert to JSON string
      await _prefs.setString(key, value.toString());
    }
  }

  @override
  T? readData<T>(String key) {
    if (T == bool) {
      return _prefs.getBool(key) as T?;
    } else if (T == int) {
      return _prefs.getInt(key) as T?;
    } else if (T == double) {
      return _prefs.getDouble(key) as T?;
    } else if (T == String) {
      return _prefs.getString(key) as T?;
    } else if (T == List<String>) {
      return _prefs.getStringList(key) as T?;
    }
    return null;
  }

  @override
  Future<void> deleteData(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  @override
  Future<void> saveState(String key, dynamic state) => saveData(key, state);
}
