import 'package:flutter/material.dart';
import 'package:snap_chef_5/models/bookmark_model.dart';
import 'package:snap_chef_5/screens/detailscreen.dart';
import 'package:snap_chef_5/services/httpservice.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    final bookmarks = await BookmarkService.getAllBookmarks();

    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Bookmarks",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * .05,
            color: const Color(0xFF0E0A57), // Deep Blue from palette
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0E0A57)),
            onPressed: _loadBookmarks,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookmarks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: w * 0.2,
                      color: const Color(0xFF93B7FC), // Light Blue from palette
                    ),
                    SizedBox(height: h * 0.02),
                    Text(
                      "No bookmarked recipes yet",
                      style: TextStyle(
                        fontSize: w * 0.045,
                        color: const Color(0xFF0E0A57),
                      ),
                    ),
                    SizedBox(height: h * 0.01),
                    Text(
                      "Tap the bookmark icon on any recipe to save it",
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: const Color(0xFF93B7FC),
                      ),
                    ),
                  ],
                ),
              )
              : _buildBookmarksByDate(),
    );
  }

  Widget _buildBookmarksByDate() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    // Group bookmarks by date
    final Map<String, List<BookmarkModel>> bookmarksByDate = {};
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    for (var bookmark in _bookmarks) {
      final DateTime saveDate = DateTime.fromMillisecondsSinceEpoch(
        bookmark.timestamp,
      );
      final DateTime saveDay = DateTime(
        saveDate.year,
        saveDate.month,
        saveDate.day,
      );

      String dateKey;
      if (saveDay == today) {
        dateKey = "Today";
      } else if (saveDay == yesterday) {
        dateKey = "Yesterday";
      } else {
        dateKey = DateFormat('MMMM d, yyyy').format(saveDate);
      }

      if (!bookmarksByDate.containsKey(dateKey)) {
        bookmarksByDate[dateKey] = [];
      }

      bookmarksByDate[dateKey]!.add(bookmark);
    }

    // Sort date keys
    final sortedDates =
        bookmarksByDate.keys.toList()..sort((a, b) {
          if (a == "Today") return -1;
          if (b == "Today") return 1;
          if (a == "Yesterday") return -1;
          if (b == "Yesterday") return 1;
          return 0; // Others are already sorted by timestamp
        });

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final bookmarksForDate = bookmarksByDate[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                w * 0.04,
                h * 0.02,
                w * 0.04,
                h * 0.01,
              ),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E0A57),
                ),
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: w * 0.03),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: w * 0.04,
                mainAxisSpacing: h * 0.02,
              ),
              itemCount: bookmarksForDate.length,
              itemBuilder: (context, i) {
                return _buildRecipeCard(context, bookmarksForDate[i]);
              },
            ),
            SizedBox(height: h * 0.01),
          ],
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, BookmarkModel bookmark) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _navigateToRecipeDetails(context, bookmark),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Stack(
                children: [
                  // Recipe Image with shimmer loading effect
                  bookmark.imageUrl.isNotEmpty
                      ? Hero(
                        tag: 'recipe_${bookmark.id}',
                        child: Image.network(
                          bookmark.imageUrl,
                          height: h * 0.2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: h * 0.2,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: w * 0.1,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: h * 0.01),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: w * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                      : Container(
                        height: h * 0.2,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: w * 0.1,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: h * 0.01),
                            Text(
                              'No image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: w * 0.03,
                              ),
                            ),
                          ],
                        ),
                      ),

                  // Gradient overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: h * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Delete button with improved styling
                  Positioned(
                    top: h * 0.01,
                    right: w * 0.02,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _removeBookmark(bookmark),
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: EdgeInsets.all(w * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.bookmark,
                            color: const Color(
                              0xFFF8A490,
                            ), // Salmon from palette
                            size: w * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recipe Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(w * 0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.title,
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0E0A57),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: h * 0.008),
                    // Cooking time
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: w * 0.04,
                          color: const Color(
                            0xFF93B7FC,
                          ), // Light Blue from palette
                        ),
                        SizedBox(width: w * 0.01),
                        Text(
                          "${bookmark.readyInMinutes} min",
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: const Color(0xFF93B7FC),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
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
    BookmarkModel bookmark,
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
      final detailedRecipe = await RecipeService.fetchRecipeDetails(
        bookmark.id,
      );

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
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load recipe details'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading recipe details'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _removeBookmark(BookmarkModel bookmark) async {
    final bool success = await BookmarkService.removeBookmark(bookmark.id);

    if (success) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe removed from bookmarks'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reload bookmarks
      _loadBookmarks();
    }
  }
}
