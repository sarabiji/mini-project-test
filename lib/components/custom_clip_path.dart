import 'package:flutter/material.dart';

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Get screen dimensions for responsive calculations
    final double w = size.width;
    final double h = size.height;

    Path path = Path();

    // Start at origin
    path.moveTo(0, 0);
    // Draw line to top right
    path.lineTo(w, 0);
    // Draw line to right side at calculated height
    path.lineTo(w, h * 0.85);

    // Create curved bottom edge - make control points responsive
    path.quadraticBezierTo(
      w * 0.75,
      h * 0.95, // First control point
      w * 0.5,
      h * 0.85, // First destination point
    );

    path.quadraticBezierTo(
      w * 0.25,
      h * 0.75, // Second control point
      0,
      h * 0.8, // Second destination point
    );

    // Close the path by connecting back to origin
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
