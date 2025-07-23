import 'package:flutter/material.dart';
import 'package:snap_chef_5/screens/searchscreen.dart';

class CategoriesPage extends StatefulWidget {
  final Function(String, List<String>) onSearch;

  const CategoriesPage({super.key, required this.onSearch});

  @override
  CategoriesPageState createState() => CategoriesPageState();
}

class CategoriesPageState extends State<CategoriesPage> {
  final Map<String, List<String>> categories = {
    "Dish Types": [
      "Main Course",
      "Side Dish",
      "Dessert",
      "Appetizer",
      "Salad",
      "Bread",
      "Breakfast",
      "Soup",
      "Beverage",
      "Sauce",
      "Marinade",
      "Fingerfood",
      "Snack",
      "Drink",
    ],
    "Cuisines": [
      "African",
      "Asian",
      "American",
      "British",
      "Cajun",
      "Caribbean",
      "Chinese",
      "Eastern European",
      "European",
      "French",
      "German",
      "Greek",
      "Indian",
      "Irish",
      "Italian",
      "Japanese",
      "Jewish",
      "Korean",
      "Latin American",
      "Mediterranean",
      "Mexican",
      "Middle Eastern",
      "Nordic",
      "Southern",
      "Spanish",
      "Thai",
      "Vietnamese",
    ],
    "Diets": [
      "Gluten Free",
      "Ketogenic",
      "Vegetarian",
      "Lacto-Vegetarian",
      "Ovo-Vegetarian",
      "Vegan",
      "Pescetarian",
      "Paleo",
      "Primal",
      "Low FODMAP",
      "Whole30",
    ],
    "Allergies": [
      "Dairy",
      "Egg",
      "Gluten",
      "Grain",
      "Peanut",
      "Seafood",
      "Sesame",
      "Shellfish",
      "Soy",
      "Sulfite",
      "Tree Nut",
      "Wheat",
    ],
  };

  // Handle category selection based on category type
  void _onCategorySelected(
    BuildContext context,
    String categoryName,
    String selectedItem,
  ) {
    //print("Selected category: $categoryName - Item: $selectedItem");

    // Prepare empty query and filter list
    String query = '';
    List<String> filters = [selectedItem];

    // Navigate to the search page with appropriate filters

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SearchPage(
              ingredients: query,
              filters: filters,

              onSearch: (query, filters) {},
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * .05,
            color: const Color(0xFF637FE7), // Deep Blue
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: h * 0.02,
          ),
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              String categoryName = categories.keys.elementAt(index);
              List<String> categoryItems = categories[categoryName]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.02, bottom: h * 0.015),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: w * 0.055,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF637FE7),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: h * 0.16,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryItems.length,
                      itemBuilder: (context, subIndex) {
                        return GestureDetector(
                          onTap:
                              () => _onCategorySelected(
                                context,
                                categoryName,
                                categoryItems[subIndex],
                              ),
                          child: Container(
                            width: w * 0.4,
                            margin: EdgeInsets.only(
                              right: w * 0.03,
                              bottom: h * 0.01,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor(categoryName, 0),
                                  _getCategoryColor(categoryName, 1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(w * 0.04),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCategoryColor(
                                    categoryName,
                                    0,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(w * 0.025),
                                child: Text(
                                  categoryItems[subIndex],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: w * 0.04,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

 
Color _getCategoryColor(String category, int position) {
  switch (category) {
    case "Dish Types":
      return position == 0
          ? const Color(0xFF6F81C1) // Glaucous
          : const Color(0xFF5C80DA); // Glaucous-2
    case "Cuisines":
      return position == 0
          ? const Color(0xFFE2EBFD) // Lavender Web (Soft Background)
          : const Color(0xFF6F81C1); // Glaucous for contrast
    case "Diets":
      return position == 0
          ? const Color(0xFFF3756D) // Salmon
          : const Color(0xFFD45562); // Deeper Coral Pink
    case "Allergies":
      return position == 0
          ? const Color(0xFFF48BA5) // Soft Pink
          : const Color(0xFFC05774); // Rich Pink // Darker Pink
    default:
      return position == 0
          ? const Color(0xFF6F81C1) // Default Glaucous
          : const Color(0xFF5C80DA); // Glaucous-2 for depth
  }
}

}
