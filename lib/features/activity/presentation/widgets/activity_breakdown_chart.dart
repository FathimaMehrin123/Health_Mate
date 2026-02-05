import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/activity.dart';

class ActivityBreakdownChart extends StatelessWidget {
  final Map<ActivityType, double> breakdown;

  const ActivityBreakdownChart({
    super.key,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            'No activity data available',
            style: AppTextStyles.secondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _getSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _getSections() {
    final colors = _getColors();
    return breakdown.entries.map((entry) {
      final color = colors[entry.key] ?? AppColors.primary;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.value.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = _getColors();
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: breakdown.entries.map((entry) {
        final color = colors[entry.key] ?? AppColors.primary;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key.displayName} ${entry.value.toStringAsFixed(0)}%',
              style: AppTextStyles.body,
            ),
          ],
        );
      }).toList(),
    );
  }

  Map<ActivityType, Color> _getColors() {
    return {
      ActivityType.walking: AppColors.primary,
      ActivityType.sitting: AppColors.warning,
      ActivityType.standing: AppColors.success,
      ActivityType.running: const Color(0xFFFF6B6B),
      ActivityType.slouching: AppColors.error,
      ActivityType.unknown: AppColors.textSecondary,
    };
  }
}