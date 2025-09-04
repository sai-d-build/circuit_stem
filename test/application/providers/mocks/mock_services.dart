import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/application/services/component_palette_manager.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';

// ignore_for_file: must_be_immutable

// Mock Classes
class MockComponentFactory extends Mock implements ComponentFactory {}

class MockComponentPaletteManager extends Mock implements ComponentPaletteManager {}

class MockSharedPreferencesStorageService extends Mock implements SharedPreferencesStorageService {}

class MockLevelService extends Mock {
  Future<dynamic> loadLevel(String levelId) async => null;
  Future<List<dynamic>> loadAllLevels() async => [];
}