import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onPressed;
  final bool isActive;
  final Color? shadowColor;

  const CircleButton({
    super.key,
    required this.icon,
    required this.gradient,
    this.onPressed,
    this.isActive = false,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final double w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: w * 0.12,
        height: w * 0.12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: w * 0.06),
      ),
    );
  }
}
