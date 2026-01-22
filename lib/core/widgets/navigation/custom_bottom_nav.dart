import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, -2),
            color: Colors.black12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Item(Icons.home, 'Home', 0),
            _Item(Icons.bar_chart, 'Activity', 1),
            _Item(Icons.bedtime, 'Sleep', 2),
            _Item(Icons.emoji_events, 'Awards', 3),
            _Item(Icons.settings, 'Settings', 4),
          ],
        ),
      ),
    );
  }

  Widget _Item(IconData icon, String label, int index) {
    final active = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF6B73FF) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFF6B73FF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
