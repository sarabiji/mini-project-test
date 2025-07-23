import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:snap_chef_5/services/user_preferences_service.dart';

class RecipeService {
  // List of API keys to rotate through
  static const List<String> _apiKeys = [
    "c65ebc1840c44a8a8491391a5dc726c7",
    "de07e7a93fc744bab82de88f23ebe571",
    // Add more API keys here if you have them
  ];

  // Current API key index
  static int _currentApiKeyIndex = 0;

  // Get current API key
  static String get apiKey => _apiKeys[_currentApiKeyIndex];

  // Rotate to next API key
  static void _rotateApiKey() {
    _currentApiKeyIndex = (_currentApiKeyIndex + 1) % _apiKeys.length;
  }

  static const String baseUrl =
      "https://api.spoonacular.com/recipes/complexSearch";
  static const String recipeDetailUrl = "https://api.spoonacular.com/recipes";

  // Handle API response and check for quota limits
  static Future<Map<String, dynamic>> _handleApiResponse(
    http.Response response,
  ) async {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 402) {
      // API quota exceeded - try rotating to next API key
      if (_apiKeys.length > 1) {
        _rotateApiKey();
        throw Exception("API quota exceeded, rotated to next API key");
      } else {
        throw Exception("API daily limit reached. Please try again tomorrow.");
      }
    } else {
      throw Exception("API request failed with status: ${response.statusCode}");
    }
  }

  // Fetch personalized recipe recommendations based on user preferences
  static Future<List<Map<String, dynamic>>> fetchRecommendedRecipes({
    int limit = 10,
  }) async {
    try {
      // Get user preferences
      final userPrefs = await UserPreferencesService.getAllPreferences();
      final diets = userPrefs['dietPreferences'] ?? [];
      final cuisines = userPrefs['cuisinePreferences'] ?? [];
      final allergies = userPrefs['allergies'] ?? [];

      // Create query parameters
      Map<String, String> queryParams = {
        "addRecipeInformation": "true",
        "apiKey": apiKey,
        "number": limit.toString(),
        "sort": "random", // Get random recommendations
        "fillIngredients": "true",
      };

      // Add user preferences
      if (diets.isNotEmpty) {
        queryParams["diet"] = diets.join(',');
      }

      if (cuisines.isNotEmpty) {
        queryParams["cuisine"] = cuisines.join(',');
      }

      if (allergies.isNotEmpty) {
        queryParams["intolerances"] = allergies.join(',');
      }

      // Make the API request
      Uri url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      // Try with current API key
      try {
        final response = await http.get(url);
        final data = await _handleApiResponse(response);
        return List<Map<String, dynamic>>.from(data['results']);
      } catch (e) {
        if (e.toString().contains("rotated to next API key")) {
          // Retry with new API key
          queryParams["apiKey"] = apiKey;
          url = Uri.parse(baseUrl).replace(queryParameters: queryParams);
          final response = await http.get(url);
          final data = await _handleApiResponse(response);
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      //print("Error in fetchRecommendedRecipes: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchRecipes(
    String query,
    List<String> filters, {
    bool applyUserPreferences = true,
  }) async {
    try {
      Map<String, String> queryParams = {
        "addRecipeInformation": "true",
        "apiKey": apiKey,
        "number": "25", // Limit to reasonable results
      };

      // Process query appropriately
      if (query.isNotEmpty) {
        // Check if query contains commas, which suggests a list of ingredients
        if (query.contains(',')) {
          // Split by commas and use as ingredients
          final ingredients = query.split(',').map((e) => e.trim()).join(',');
          queryParams["includeIngredients"] = ingredients;
        } else {
          // For single words or phrases, use as general search query
          queryParams["query"] = query.trim();
        }
      }

      // Add cuisine, diet, meal type filters
      if (filters.isNotEmpty) {
        // Loop through filters and categorize them
        List<String> mealTypes = [];
        List<String> cuisines = [];
        List<String> diets = [];
        List<String> intolerances = [];

        for (String filter in filters) {
          // Check if it's a meal type
          if ([
            'Breakfast',
            'Main Course',
            'Side Dish',
            'Dessert',
            'Appetizer',
            'Salad',
            'Bread',
            'Soup',
            'Beverage',
            'Sauce',
            'Marinade',
            'Fingerfood',
            'Snack',
            'Drink',
            'Lunch',
            'Dinner',
            'Quick',
          ].contains(filter)) {
            mealTypes.add(filter);
          }
          // Check if it's a cuisine type
          else if ([
            'African',
            'Asian',
            'American',
            'British',
            'Cajun',
            'Caribbean',
            'Chinese',
            'Eastern European',
            'European',
            'French',
            'German',
            'Greek',
            'Indian',
            'Irish',
            'Italian',
            'Japanese',
            'Jewish',
            'Korean',
            'Latin American',
            'Mediterranean',
            'Mexican',
            'Middle Eastern',
            'Nordic',
            'Southern',
            'Spanish',
            'Thai',
            'Vietnamese',
          ].contains(filter)) {
            cuisines.add(filter);
          }
          // Check if it's a diet
          else if ([
            'Gluten Free',
            'Ketogenic',
            'Vegetarian',
            'Lacto-Vegetarian',
            'Ovo-Vegetarian',
            'Vegan',
            'Pescetarian',
            'Paleo',
            'Primal',
            'Low FODMAP',
            'Whole30',
          ].contains(filter)) {
            diets.add(filter);
          }
          // Check if it's an intolerance/allergy
          else if ([
            'Dairy',
            'Egg',
            'Gluten',
            'Grain',
            'Peanut',
            'Seafood',
            'Sesame',
            'Shellfish',
            'Soy',
            'Sulfite',
            'Tree Nut',
            'Wheat',
          ].contains(filter)) {
            intolerances.add(filter);
          }
        }

        // Add appropriate parameters
        if (mealTypes.isNotEmpty) {
          queryParams["type"] = mealTypes.join(',');
        }
        if (cuisines.isNotEmpty) {
          queryParams["cuisine"] = cuisines.join(',');
        }
        if (diets.isNotEmpty) {
          queryParams["diet"] = diets.join(',');
        }
        if (intolerances.isNotEmpty) {
          queryParams["intolerances"] = intolerances.join(',');
        }
      }

      // Apply user preferences if requested
      if (applyUserPreferences) {
        // Get user preferences
        final userPrefs = await UserPreferencesService.getAllPreferences();
        final userDiets = userPrefs['dietPreferences'] ?? [];
        final userAllergies = userPrefs['allergies'] ?? [];

        // Apply allergies as intolerances (always respect allergies)
        if (userAllergies.isNotEmpty) {
          List<String> currentIntolerances = [];
          if (queryParams.containsKey("intolerances")) {
            currentIntolerances = queryParams["intolerances"]!.split(',');
          }

          // Add user allergies that are not already included
          for (String allergy in userAllergies) {
            if (!currentIntolerances.contains(allergy)) {
              currentIntolerances.add(allergy);
            }
          }

          queryParams["intolerances"] = currentIntolerances.join(',');
        }

        // Only apply diet preferences if not explicitly specified in search filters
        if (userDiets.isNotEmpty && !queryParams.containsKey("diet")) {
          queryParams["diet"] = userDiets.join(',');
        }
      }

      Uri url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      try {
        final response = await http.get(url);
        final data = await _handleApiResponse(response);
        final List<dynamic> results = data['results'] ?? [];

        return results.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        if (e.toString().contains("rotated to next API key")) {
          queryParams["apiKey"] = apiKey;
          url = Uri.parse(baseUrl).replace(queryParameters: queryParams);
          final response = await http.get(url);
          final data = await _handleApiResponse(response);
          final List<dynamic> results = data['results'] ?? [];
          return results.map((e) => e as Map<String, dynamic>).toList();
        } else {
          return [];
        }
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchRecipeDetails(int recipeId) async {
    try {
      Map<String, String> queryParams = {
        "apiKey": apiKey,
        "includeNutrition": "false",
      };

      Uri url = Uri.parse(
        "$recipeDetailUrl/$recipeId/information",
      ).replace(queryParameters: queryParams);

      //print("Fetching recipe details from: $url");

      // Try with current API key
      try {
        final response = await http.get(url);
        return await _handleApiResponse(response);
      } catch (e) {
        if (e.toString().contains("rotated to next API key")) {
          // Retry with new API key
          queryParams["apiKey"] = apiKey;
          url = Uri.parse(
            "$recipeDetailUrl/$recipeId/information",
          ).replace(queryParameters: queryParams);
          final response = await http.get(url);
          return await _handleApiResponse(response);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      //print("Error fetching recipe details: $e");
      return null;
    }
  }
}
