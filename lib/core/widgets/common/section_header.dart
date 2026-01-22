import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          if (actionText != null || actionIcon != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                children: [
                  if (actionText != null)
                    Text(
                      actionText!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B73FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (actionIcon != null) ...[
                    if (actionText != null) SizedBox(width: 4),
                    Icon(
                      actionIcon,
                      size: 16,
                      color: Color(0xFF6B73FF),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}