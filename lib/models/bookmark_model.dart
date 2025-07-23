import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkModel {
  final int id;
  final String title;
  final String imageUrl;
  final int readyInMinutes;
  final int timestamp;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.readyInMinutes,
    required this.timestamp,
  });

  // Convert recipe to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'readyInMinutes': readyInMinutes,
      'timestamp': timestamp,
    };
  }

  // Create model from JSON data
  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      readyInMinutes: json['readyInMinutes'],
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

// Service to manage bookmarks
class BookmarkService {
  static const String _storageKey = 'bookmarked_recipes';

  // Save a recipe to bookmarks
  static Future<bool> addBookmark(Map<String, dynamic> recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedRecipes = prefs.getStringList(_storageKey) ?? [];

      // Create bookmark model from recipe data with current timestamp
      final bookmark = BookmarkModel(
        id: recipe['id'],
        title: recipe['title'] ?? 'Untitled Recipe',
        imageUrl: recipe['image'] ?? '',
        readyInMinutes: recipe['readyInMinutes'] ?? 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Check if already bookmarked
      if (savedRecipes.any((item) => jsonDecode(item)['id'] == bookmark.id)) {
        return false; // Already exists
      }

      // Add to saved list
      savedRecipes.add(jsonEncode(bookmark.toJson()));
      await prefs.setStringList(_storageKey, savedRecipes);
      return true;
    } catch (e) {
      //print('Error saving bookmark: $e');
      return false;
    }
  }

  // Remove a recipe from bookmarks
  static Future<bool> removeBookmark(int recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedRecipes = prefs.getStringList(_storageKey) ?? [];

      // Filter out the recipe with matching ID
      final updatedList =
          savedRecipes.where((item) {
            final decodedItem = jsonDecode(item);
            return decodedItem['id'] != recipeId;
          }).toList();

      // Save updated list
      await prefs.setStringList(_storageKey, updatedList);
      return true;
    } catch (e) {
      //print('Error removing bookmark: $e');
      return false;
    }
  }

  // Check if a recipe is bookmarked
  static Future<bool> isBookmarked(int recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedRecipes = prefs.getStringList(_storageKey) ?? [];

      return savedRecipes.any((item) {
        final decodedItem = jsonDecode(item);
        return decodedItem['id'] == recipeId;
      });
    } catch (e) {
      //print('Error checking bookmark: $e');
      return false;
    }
  }

  // Get all bookmarked recipes
  static Future<List<BookmarkModel>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedRecipes = prefs.getStringList(_storageKey) ?? [];

      final bookmarks =
          savedRecipes.map((item) {
            return BookmarkModel.fromJson(jsonDecode(item));
          }).toList();

      // Sort by timestamp (newest first)
      bookmarks.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return bookmarks;
    } catch (e) {
      //print('Error getting bookmarks: $e');
      return [];
    }
  }
}
