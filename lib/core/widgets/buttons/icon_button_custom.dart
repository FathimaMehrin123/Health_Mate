import 'package:flutter/material.dart';

class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  const IconButtonCustom({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (color ?? const Color(0xFF6B73FF)).withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: size,
          color: color ?? const Color(0xFF6B73FF),
        ),
      ),
    );
  }
}
