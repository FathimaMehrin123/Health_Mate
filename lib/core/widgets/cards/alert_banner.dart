import 'package:flutter/material.dart';

enum AlertType { warning, success, info, error }

class AlertBanner extends StatelessWidget {
  final String message;
  final String? subtitle;
  final AlertType type;
  final VoidCallback? onActionTap;
  final String? actionText;

  const AlertBanner({
    super.key,
    required this.message,
    this.subtitle,
    this.type = AlertType.warning,
    this.onActionTap,
    this.actionText,
  });

  Color _bg() {
    switch (type) {
      case AlertType.success:
        return const Color(0xFFD4EDDA);
      case AlertType.error:
        return const Color(0xFFF8D7DA);
      case AlertType.info:
        return const Color(0xFFD1ECF1);
      default:
        return const Color(0xFFFFF3CD);
    }
  }

  Color _accent() {
    switch (type) {
      case AlertType.success:
        return const Color(0xFF4ECDC4);
      case AlertType.error:
        return const Color(0xFFFF6B6B);
      case AlertType.info:
        return const Color(0xFF6B73FF);
      default:
        return const Color(0xFFFFC107);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent()),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: _accent()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText!,
                style: TextStyle(color: _accent()),
              ),
            ),
        ],
      ),
    );
  }
}
