import 'package:flutter/material.dart';
import 'package:snap_chef_5/screens/detailscreen.dart';
import 'package:snap_chef_5/services/httpservice.dart';
import 'package:snap_chef_5/services/user_preferences_service.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: h * 0.01),
        constraints: BoxConstraints(maxHeight: h * 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: w * 0.04),
              padding: EdgeInsets.symmetric(
                vertical: h * 0.005,
                horizontal: w * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.symmetric(
                  vertical: h * 0.005,
                  horizontal: w * 0.01,
                ),
                labelPadding: EdgeInsets.symmetric(horizontal: w * 0.035),
                unselectedLabelColor: const Color(0xFF888888),
                labelColor: Colors.white,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 99, 127, 231), // Deep Blue
                      Color.fromARGB(255, 89, 103, 157),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF3756D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(30),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  _buildTab('Breakfast', Icons.free_breakfast, w, h),
                  _buildTab('Lunch', Icons.lunch_dining, w, h),
                  _buildTab('Dinner', Icons.dinner_dining, w, h),
                ],
              ),
            ),
            SizedBox(height: h * 0.01),
            // Tab view with content
            const Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  HomeTabBarView(recipe: "Breakfast"),
                  HomeTabBarView(recipe: "Lunch"),
                  HomeTabBarView(recipe: "Dinner"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, double w, double h) {
    return Tab(
      height: h * 0.05,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: w * 0.045),
          SizedBox(width: w * 0.01),
          Text(title, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////
class HomeTabBarView extends StatelessWidget {
  final String recipe;
  const HomeTabBarView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: RecipeService.fetchRecipes(
        recipe,
        [],
        applyUserPreferences: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(w);
        } else if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return _buildEmptyState(context, w, h);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Personalized indicator
            FutureBuilder<Map<String, List<String>>>( 
              future: UserPreferencesService.getAllPreferences(),
              builder: (context, prefsSnapshot) {
                if (prefsSnapshot.hasData &&
                    (prefsSnapshot.data!['dietPreferences']!.isNotEmpty ||
                        prefsSnapshot.data!['allergies']!.isNotEmpty ||
                        prefsSnapshot
                            .data!['cuisinePreferences']!
                            .isNotEmpty)) {
                  return Padding(
                    padding: EdgeInsets.only(left: w * 0.04, bottom: h * 0.01),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.02,
                        vertical: h * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE7FD), // Lavender Blue
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: const Color(0xFF637FE7), // Deep Blue
                            size: w * 0.035,
                          ),
                          SizedBox(width: w * 0.01),
                          Text(
                            "Personalized for you",
                            style: TextStyle(
                              fontSize: w * 0.025,
                              color: const Color(0xFF637FE7), // Deep Blue
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Recipe list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> snap = snapshot.data![index];

                  return _buildRecipeCard(context, snap, w, h);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(double w) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: w * 0.15,
            height: w * 0.15,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF637FE7).withOpacity(0.8),
              ),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: w * 0.04),
          Text(
            'Finding delicious recipes...',
            style: TextStyle(
              color: const Color(0xFF637FE7), // Deep Blue
              fontSize: w * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double w, double h) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              size: w * 0.15,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: h * 0.02),
          Text(
            'No recipes available',
            style: TextStyle(
              color: const Color(0xFF637FE7), // Deep Blue
              fontSize: w * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: h * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
            child: Text(
              'Try searching with different ingredients',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF888888), // Grey
                fontSize: w * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    Map<String, dynamic> recipe,
    double w,
    double h,
  ) {
    int readyInMinutes = (recipe['readyInMinutes'] ?? 0).toInt();

    // Determine recipe difficulty based on preparation time
    String difficulty = "Easy";
    Color difficultyColor = Colors.green;
    if (readyInMinutes > 45) {
      difficulty = "Hard";
      difficultyColor = Colors.red;
    } else if (readyInMinutes > 25) {
      difficulty = "Medium";
      difficultyColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () => _navigateToRecipeDetails(context, recipe),
      child: Container(
        width: w * 0.42, // Reduced width to prevent overflow
        height: h * 0.4,
        margin: EdgeInsets.symmetric(horizontal: w * 0.015, vertical: h * 0.005), // Reduced margin
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with difficulty badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: recipe['image'] != null
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: w * 0.42,
                            maxHeight: h * 0.18,
                          ),
                          child: Image.network(
                            recipe['image'],
                            height: h * 0.18,
                            width: w * 0.42,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: h * 0.18,
                          width: w * 0.42,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[500],
                            size: w * 0.1,
                          ),
                        ),
                ),
                // Difficulty badge
                Positioned(
                  top: h * 0.005,
                  left: w * 0.02,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02,
                      vertical: h * 0.002,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: difficultyColor,
                          size: w * 0.03,
                        ),
                        SizedBox(width: w * 0.01),
                        Text(
                          difficulty,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(w * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe Title
                    Text(
                      recipe['title'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: h * 0.008),
                    // Recipe Info
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Colors.grey[600],
                          size: w * 0.035,
                        ),
                        SizedBox(width: w * 0.01),
                        Text(
                          '$readyInMinutes min',
                          style: TextStyle(
                            fontSize: w * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Category tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.02,
                        vertical: h * 0.002,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE7FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        this.recipe,
                        style: TextStyle(
                          fontSize: w * 0.025,
                          color: const Color(0xFF637FE7),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToRecipeDetails(
    BuildContext context,
    Map<String, dynamic> recipe,
  ) async {
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
