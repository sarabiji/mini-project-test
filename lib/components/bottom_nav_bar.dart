import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedItem;
  final Function(int index) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedItem,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedItem;
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the selected index when widget is updated from parent
    if (widget.selectedItem != oldWidget.selectedItem) {
      setState(() {
        _selectedIndex = widget.selectedItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.02,
            vertical: h * 0.01,
          ),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: w * 0.02,
            activeColor: Colors.white,
            iconSize: w * 0.06,
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.01,
            ),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFF637FE7),
            color: const Color(0xFF888888),
            textStyle: TextStyle(
              fontSize: w * 0.034,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                margin: EdgeInsets.only(left: w * 0.01),
              ),
              const GButton(icon: Icons.category, text: 'Categories'),
              const GButton(icon: Icons.search, text: 'Search'),
              const GButton(icon: Icons.bookmark, text: 'Saved'),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                margin: EdgeInsets.only(right: w * 0.01),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
              widget.onTap(index);
            },
          ),
        ),
      ),
    );
  }
}
