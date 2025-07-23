import 'package:flutter/material.dart';
import 'package:snap_chef_5/components/text_field_widget.dart';
import 'package:snap_chef_5/screens/detailscreen.dart';
import 'package:snap_chef_5/services/httpservice.dart';
import 'package:snap_chef_5/services/user_preferences_service.dart';

class SearchPage extends StatefulWidget {
  final String ingredients;
  final List<String> filters;
  final void Function(String, List<String>) onSearch;

  const SearchPage({
    super.key,
    required this.ingredients,
    required this.filters,
    required this.onSearch,
  });

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  late TextEditingController _searchController;
  String _searchQuery = "";
  List<String> _filters = [];

  @override
  void initState() {
    super.initState();

    _searchQuery = widget.ingredients;
    _filters = widget.filters;

    _searchController = TextEditingController(text: _searchQuery);

    // Perform search if query is provided or filters are active
    if (_searchQuery.isNotEmpty || _filters.isNotEmpty) {
      // Use Future.delayed to ensure the widget is fully built before searching
      Future.delayed(Duration.zero, () {
        _fetchRecipes();
      });
    }
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ingredients != _searchQuery || widget.filters != _filters) {
      setState(() {
        _searchQuery = widget.ingredients;
        _filters = widget.filters;
        _searchController.text = widget.ingredients;
        _isLoading = true;
      });
      _fetchRecipes();
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of controller to free memory
    super.dispose();
  }

  /// Function to update search query dynamically from external sources (e.g., Home)
  void updateSearch(String query, List<String> filters) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        _filters = filters;
        _searchController.text = query;
        _isLoading = true;
      });

      // Only trigger a search when there's content to search for
      if (query.isNotEmpty || filters.isNotEmpty) {
        _fetchRecipes();

        // Only focus on the search field if there's actual content to search for
        if (query.isNotEmpty) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      } else {
        // If there's no search content, just clear the results
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
      }
    }
  }

  void _removeFilter(String filter) {
    setState(() {
      _filters.remove(filter);
      _isLoading = true;
    });
    _fetchRecipes();
  }

  /// Fetch recipes based on updated query and filters
  Future<void> _fetchRecipes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if we have a valid query or filters
      if (_searchQuery.trim().isEmpty && _filters.isEmpty) {
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
        return;
      }

      //print("Searching for: '$_searchQuery' with filters: $_filters");
      final recipes = await RecipeService.fetchRecipes(
        _searchQuery,
        _filters,
        applyUserPreferences: true,
      );

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      //print("Error in _fetchRecipes: $e");
      setState(() {
        _recipes = [];
        _isLoading = false;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch recipes. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getCategoryType(String filter) {
    // Return category type based on filter
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
      return "Dish Type";
    } else if ([
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
      return "Cuisine";
    } else if ([
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
      return "Diet";
    } else if ([
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
      return "Allergy";
    }
    return "Filter";
  }

  Color _getFilterColor(String filter) {
    String type = _getCategoryType(filter);
    switch (type) {
      case "Dish Type":
        return const Color(0xFF637FE7); // Blue
      case "Cuisine":
        return const Color(0xFF6B9157); // Green
      case "Diet":
        return const Color(0xFFe57367); // Red
      case "Allergy":
        return const Color(0xFFb76ce5); // Purple
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
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
      body: Column(
        children: [
          SizedBox(height: h * 0.02),

          // Search Input Field
          Padding(
            padding: EdgeInsets.all(h * 0.01),
            child: TextFieldWidget(
              autoFocus: _searchQuery.isNotEmpty,
              initialValue: _searchQuery,
              // filters: _filters, // Pass current filters
              onSearch: (String query, List<String> filters) {
                setState(() {
                  _searchQuery = query;
                  _filters = filters;
                  _isLoading = query.isNotEmpty || filters.isNotEmpty;
                });

                if (query.isNotEmpty || filters.isNotEmpty) {
                  _fetchRecipes();
                  widget.onSearch(query, _filters);
                } else {
                  widget.onSearch("", []);
                }
              }, 
              filters: [],
            ),
          ),

          // Active Filters
          if (_filters.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.03),
              child: Container(
                height: h * 0.05,
                margin: EdgeInsets.only(bottom: h * 0.01),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: w * 0.02),
                      child: Chip(
                        label: Text(
                          _filters[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.03,
                          ),
                        ),
                        backgroundColor: _getFilterColor(_filters[index]),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        onDeleted: () => _removeFilter(_filters[index]),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Results count
          if (!_isLoading && _recipes.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.01,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Found ${_recipes.length} recipes",
                    style: TextStyle(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  FutureBuilder<Map<String, List<String>>>(
                    future: UserPreferencesService.getAllPreferences(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          (snapshot.data!['dietPreferences']!.isNotEmpty ||
                              snapshot.data!['allergies']!.isNotEmpty ||
                              snapshot
                                  .data!['cuisinePreferences']!
                                  .isNotEmpty)) {
                        return Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.02,
                                vertical: h * 0.003,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF637FE7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: const Color(0xFF637FE7),
                                    size: w * 0.035,
                                  ),
                                  SizedBox(width: w * 0.01),
                                  Text(
                                    "Results personalized to your preferences",
                                    style: TextStyle(
                                      fontSize: w * 0.025,
                                      color: const Color(0xFF637FE7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

          // Search Results
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _recipes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: w * 0.15,
                            color: Colors.grey,
                          ),
                          SizedBox(height: h * 0.02),
                          Text(
                            'No recipes found',
                            style: TextStyle(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            'Try different ingredients or filters',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _buildRecipeList(w, h),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(double w, double h) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return Card(
          margin: EdgeInsets.symmetric(
            vertical: h * 0.01,
            horizontal: w * 0.01,
          ),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openRecipeDetails(recipe),
            child: Padding(
              padding: EdgeInsets.all(w * 0.02),
              child: Row(
                children: [
                  // Recipe image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:
                        recipe['image'] != null
                            ? Image.network(
                              recipe['image'],
                              width: w * 0.25,
                              height: h * 0.12,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: w * 0.25,
                                  height: h * 0.12,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[500],
                                    size: w * 0.08,
                                  ),
                                );
                              },
                            )
                            : Container(
                              width: w * 0.25,
                              height: h * 0.12,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[500],
                                size: w * 0.08,
                              ),
                            ),
                  ),
                  SizedBox(width: w * 0.03),
                  // Recipe details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recipe['title'] ?? "Untitled Recipe",
                          style: TextStyle(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: h * 0.005),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: w * 0.04,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: w * 0.01),
                            Text(
                              "Ready in ${recipe['readyInMinutes'] ?? 'unknown'} min",
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (recipe['dishTypes'] != null &&
                            recipe['dishTypes'] is List &&
                            recipe['dishTypes'].isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: h * 0.005),
                            child: Text(
                              recipe['dishTypes'].take(2).join(', '),
                              style: TextStyle(
                                fontSize: w * 0.03,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openRecipeDetails(Map<String, dynamic> recipe) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Fetch detailed recipe information
      final int recipeId = recipe['id'];
      final detailedRecipe = await RecipeService.fetchRecipeDetails(recipeId);

      // Close loading dialog
      Navigator.pop(context);

      if (detailedRecipe != null) {
        // Navigate to detail screen with detailed recipe data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(item: detailedRecipe),
          ),
        );
      } else {
        // If detailed fetch failed, use the summary data
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(item: recipe)),
        );
      }
    } catch (e) {
      // Close loading dialog and navigate with basic data on error
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(item: recipe)),
      );
    }
  }
}
