
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _keyDietPreferences = 'diet_preferences';
  static const String _keyCuisinePreferences = 'cuisine_preferences';
  static const String _keyAllergies = 'allergies';

  // Save diet preferences
  static Future<bool> saveDietPreferences(List<String> dietPreferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(_keyDietPreferences, dietPreferences);
    } catch (e) {
      //print('Error saving diet preferences: $e');
      return false;
    }
  }

  // Get diet preferences
  static Future<List<String>> getDietPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyDietPreferences) ?? [];
    } catch (e) {
      //print('Error getting diet preferences: $e');
      return [];
    }
  }

  // Save cuisine preferences
  static Future<bool> saveCuisinePreferences(
    List<String> cuisinePreferences,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(
        _keyCuisinePreferences,
        cuisinePreferences,
      );
    } catch (e) {
      //print('Error saving cuisine preferences: $e');
      return false;
    }
  }

  // Get cuisine preferences
  static Future<List<String>> getCuisinePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyCuisinePreferences) ?? [];
    } catch (e) {
      //print('Error getting cuisine preferences: $e');
      return [];
    }
  }

  // Save allergies
  static Future<bool> saveAllergies(List<String> allergies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(_keyAllergies, allergies);
    } catch (e) {
      //print('Error saving allergies: $e');
      return false;
    }
  }

  // Get allergies
  static Future<List<String>> getAllergies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyAllergies) ?? [];
    } catch (e) {
      //print('Error getting allergies: $e');
      return [];
    }
  }

  // Save all preferences at once
  static Future<bool> saveAllPreferences({
    required List<String> dietPreferences,
    required List<String> cuisinePreferences,
    required List<String> allergies,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dietSaved = await prefs.setStringList(
        _keyDietPreferences,
        dietPreferences,
      );
      final cuisineSaved = await prefs.setStringList(
        _keyCuisinePreferences,
        cuisinePreferences,
      );
      final allergiesSaved = await prefs.setStringList(
        _keyAllergies,
        allergies,
      );

      return dietSaved && cuisineSaved && allergiesSaved;
    } catch (e) {
      //print('Error saving all preferences: $e');
      return false;
    }
  }

  // Get all preferences at once
  static Future<Map<String, List<String>>> getAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'dietPreferences': prefs.getStringList(_keyDietPreferences) ?? [],
        'cuisinePreferences': prefs.getStringList(_keyCuisinePreferences) ?? [],
        'allergies': prefs.getStringList(_keyAllergies) ?? [],
      };
    } catch (e) {
      //print('Error getting all preferences: $e');
      return {'dietPreferences': [], 'cuisinePreferences': [], 'allergies': []};
    }
  }

  // Clear all preferences
  static Future<bool> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDietPreferences);
      await prefs.remove(_keyCuisinePreferences);
      await prefs.remove(_keyAllergies);
      return true;
    } catch (e) {
      //print('Error clearing preferences: $e');
      return false;
    }
  }
}
