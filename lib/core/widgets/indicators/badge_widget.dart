import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isLocked;
  final VoidCallback? onTap;
  final double size;

  const BadgeWidget({
    super.key,
    required this.emoji,
    required this.label,
    this.isLocked = false,
    this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isLocked
                  ? null
                  : LinearGradient(
                      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isLocked ? Colors.grey[200] : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: Color(0xFFF093FB).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                isLocked ? '🔒' : emoji,
                style: TextStyle(fontSize: size * 0.5),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey[400] : Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}