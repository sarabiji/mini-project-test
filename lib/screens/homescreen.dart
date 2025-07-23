import 'package:flutter/material.dart';
import 'package:snap_chef_5/components/home_app_bar.dart';
import 'package:snap_chef_5/components/tab_bar_widget.dart';
import 'package:snap_chef_5/components/text_field_widget.dart';
import 'package:snap_chef_5/constants/image_path.dart';
import 'package:snap_chef_5/services/httpservice.dart';
import 'package:snap_chef_5/screens/detailscreen.dart';

class HomePage extends StatefulWidget {
  final Function(String, List<String>) onSearch;
  const HomePage({super.key, required this.onSearch});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _recommendedRecipes = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoadingRecommendations = true;
      });

      final recommendations = await RecipeService.fetchRecommendedRecipes(
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _recommendedRecipes = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      //print('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeAppBar(
                  title: 'What are you',
                  subtitle: 'cooking today?',
                ),
                SizedBox(height: h * 0.03),

                
                TextFieldWidget(
                  onSearch: (query, filters) {
                    
                    widget.onSearch(query, filters);
                  }, filters: [],
                ),

                SizedBox(height: h * 0.022),

                // Explore Image Banner
                Container(
                  height: h * .25,
                  width: w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImagesPath.explore),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: h * .025),

                // Recommended Recipes Section
                if (_recommendedRecipes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: w * 0.06, // Larger for emphasis
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: const Color(0xFF0E0A57), // Federal Blue
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadRecommendations,
                        color: const Color(0xFF637FE7),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.015),
                  SizedBox(
                    height: h * 0.27,
                    child:
                        _isLoadingRecommendations
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recommendedRecipes.length,
                              itemBuilder: (context, index) {
                                final recipe = _recommendedRecipes[index];
                                return _buildRecommendedRecipeCard(
                                  recipe,
                                  w,
                                  h,
                                );
                              },
                            ),
                  ),
                  SizedBox(height: h * .025),
                ],

                // Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: w * 0.06, // Larger for emphasis
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: const Color(0xFF0E0A57), // Federal Blue
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Spacing before TabBar
                // Tab Bar Widget
                const TabBarWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedRecipeCard(
    Map<String, dynamic> recipe,
    double w,
    double h,
  ) {
    return GestureDetector(
      onTap: () => _navigateToRecipeDetail(recipe),
      child: Container(
        width: w * 0.6,
        margin: EdgeInsets.only(right: w * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child:
                  recipe['image'] != null
                      ? Image.network(
                        recipe['image'],
                        height: h * 0.15,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: h * 0.15,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[500],
                          size: w * 0.1,
                        ),
                      ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(w * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Title
                  Text(
                    recipe['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: h * 0.01),
                  // Recipe Info
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.grey[600],
                        size: w * 0.04,
                      ),
                      SizedBox(width: w * 0.01),
                      Text(
                        '${recipe['readyInMinutes'] ?? '?'} min',
                        style: TextStyle(
                          fontSize: w * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      // Based on user preferences tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.02,
                          vertical: h * 0.003,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF637FE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'For You',
                          style: TextStyle(
                            fontSize: w * 0.03,
                            color: const Color(0xFF637FE7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecipeDetail(Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(item: recipe)),
    );
  }
}
