import 'package:flutter/material.dart';
import 'package:snap_chef_5/components/bottom_nav_bar.dart';
import 'package:snap_chef_5/screens/bookmarks_screen.dart';
import 'package:snap_chef_5/screens/categories_screen.dart';
import 'package:snap_chef_5/screens/homescreen.dart';
import 'package:snap_chef_5/screens/profile_screen.dart';
import 'package:snap_chef_5/screens/searchscreen.dart';

class Home extends StatefulWidget {
  final int initialIndex;

  const Home({super.key, this.initialIndex = 0});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController pageController;
  final GlobalKey<State<SearchPage>> searchPageKey =
      GlobalKey<State<SearchPage>>();

  late int currentIndex;
  String searchQuery = "";
  List<String> searchFilters = [];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void _navigateToSearchPage(String query, List<String> filters) {
    // Always update the search query and filters
    setState(() {
      searchQuery = query;
      searchFilters = filters;
    });

    // Always navigate to the search page
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Only change currentIndex if an actual search is performed
    // (query is not empty or there are filters)
    if (query.isNotEmpty || filters.isNotEmpty) {
      setState(() {
        currentIndex = 2; // Index of SearchPage in PageView
      });

      // Make sure we're using the correct key and updating the search
      // Need to use a slight delay to ensure the page has time to build
      Future.delayed(Duration.zero, () {
        final searchPageState = searchPageKey.currentState as SearchPageState?;
        if (searchPageState != null) {
          searchPageState.updateSearch(query, filters);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedItem: currentIndex,
        onTap: (int index) {
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          setState(() {
            currentIndex = index;
          });
        },
      ),

      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          // Only update the bottom nav bar if we're not navigating to search page with empty query
          if (index == 2) {
            // If navigating to search tab, only update bottom nav when there's actual search content
            if (searchQuery.isNotEmpty || searchFilters.isNotEmpty) {
              setState(() {
                currentIndex = index;
              });
            }
          } else {
            // For other tabs, always update the bottom nav
            setState(() {
              currentIndex = index;
            });
          }
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomePage(onSearch: _navigateToSearchPage),
          CategoriesPage(onSearch: _navigateToSearchPage),
          SearchPage(
            key: searchPageKey,
            ingredients: "",
            filters: const [],
            onSearch: _navigateToSearchPage,
          ),
          const BookmarksScreen(),
          const ProfilePage(),
        ],
      ),
    );
  }
}
