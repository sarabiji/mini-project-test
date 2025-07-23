import 'package:flutter/material.dart';

class IngredientList extends StatelessWidget {
  final List<dynamic> ingredients; // Keep it dynamic to allow flexibility

  const IngredientList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling (parent handles it)
      shrinkWrap: true, // Allows it to fit inside parent scroll
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];

        // Check if ingredient is a Map (structured) or just a String
        if (ingredient is Map<String, dynamic>) {
          return _buildIngredientTile(
            context,
            ingredient['name'] ?? ingredient['original'] ?? 'Unknown',
            _formatAmount(ingredient['amount']),
            ingredient['unit'] ?? '',
          );
        } else if (ingredient is String) {
          return _buildIngredientTile(context, ingredient, '', '');
        }

        // Handle unexpected types by logging and showing a placeholder
        //print("Unexpected ingredient type: ${ingredient.runtimeType}");
        return _buildIngredientTile(
          context,
          "Ingredient format not recognized",
          '',
          '',
        );
      },
    );
  }

  // Helper method to format amounts properly
  String _formatAmount(dynamic amount) {
    if (amount == null) return '';

    // If it's already a string, return it
    if (amount is String) return amount;

    // If it's a number, format it to avoid trailing zeros
    if (amount is num) {
      // Convert to double first to handle both int and double
      double numAmount =
          amount.toDouble(); // This is the correct way to convert num to double

      // Format to remove trailing zeros
      if (numAmount == numAmount.round()) {
        return numAmount.round().toString();
      } else {
        return numAmount.toString();
      }
    }

    // Default fallback
    return amount.toString();
  }

  Widget _buildIngredientTile(
    BuildContext context,
    String name,
    String amount,
    String unit,
  ) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.008, horizontal: w * 0.025),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF637FE7),
              Color(0xFFF3756D),
            ], // Deep Blue to Salmon
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            name,
            style: TextStyle(
              fontSize: w * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for contrast
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          trailing: Text(
            amount.isNotEmpty ? "$amount $unit" : "",
            style: TextStyle(
              fontSize: w * 0.035,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
