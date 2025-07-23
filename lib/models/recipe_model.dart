
class Recipe {
  final int id;
  final String title;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'] ?? '',
    );
  }
}

// Recipe details model
class RecipeDetails {
  final int id;
  final String title;
  final String imageUrl;
  final String summary;
  final List<String> dishTypes;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final int readyInMinutes;
  final int servings;

  RecipeDetails({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summary,
    required this.dishTypes,
    required this.ingredients,
    required this.instructions,
    required this.readyInMinutes,
    required this.servings,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    // Parse ingredients
    List<Ingredient> ingredients = (json['extendedIngredients'] as List?)
            ?.map((item) => Ingredient.fromJson(item))
            .toList() ??
        [];

    // Parse instructions
    List<String> instructions = [];
    if (json['analyzedInstructions'] != null &&
        json['analyzedInstructions'].isNotEmpty) {
      for (var instruction in json['analyzedInstructions']) {
        if (instruction['steps'] != null) {
          for (var step in instruction['steps']) {
            instructions.add(step['step']);
          }
        }
      }
    }

    // Fallback to plain text instructions if no structured steps exist
    if (instructions.isEmpty &&
        json['instructions'] != null &&
        json['instructions'].toString().isNotEmpty) {
      instructions = json['instructions']
          .toString()
          .split(RegExp(r'(?<=[.!?])\s+'))
          .where((step) => step.trim().isNotEmpty)
          .toList();
    }

    return RecipeDetails(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'] ?? '',
      summary: json['summary'] ?? '',
      dishTypes: (json['dishTypes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      ingredients: ingredients,
      instructions: instructions,
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
    );
  }
}

class Ingredient {
  final String name;
  final String original;
  final double amount;
  final String unit;

  Ingredient({
    required this.name,
    required this.original,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      original: json['original'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      unit: json['unit'] ?? '',
    );
  }
}
