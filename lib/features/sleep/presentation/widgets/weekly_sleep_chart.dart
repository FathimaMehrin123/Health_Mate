import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/sleep_record.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WeeklySleepChart extends StatelessWidget {
  final List<SleepRecord> records;
  final Function(DateTime)? onDayTap;

  const WeeklySleepChart({super.key, required this.records, this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final weekData = _generateWeekData();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Average', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      return BarTooltipItem(
                        '${days[group.x.toInt()]}: ${rod.toY.toStringAsFixed(1)}h',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt()],
                          style: AppTextStyles.label,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: AppTextStyles.label.copyWith(fontSize: 10),
                        );
                      },
                      interval: 2,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weekData,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppColors.border, strokeWidth: 0.5);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Stats summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Avg Sleep',
                '${_calculateAverageSleep().toStringAsFixed(1)}h',
              ),
              _buildStatItem(
                'Best Night',
                '${_getMaxSleep().toStringAsFixed(1)}h',
              ),
              _buildStatItem(
                'Worst Night',
                '${_getMinSleep().toStringAsFixed(1)}h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateWeekData() {
    final now = DateTime.now();
    final data = <BarChartGroupData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRecords = records.where((r) {
        return r.startTime.year == date.year &&
            r.startTime.month == date.month &&
            r.startTime.day == date.day;
      }).toList();

      final totalHours =
          dayRecords.fold<int>(0, (sum, r) => sum + r.totalDuration) / 60.0;

      data.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: totalHours > 0 ? totalHours : 0,
              color: _getBarColor(totalHours),
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return data;
  }

  Color _getBarColor(double hours) {
    if (hours >= 7 && hours <= 9) {
      return AppColors.success;
    } else if (hours >= 6 && hours < 7) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  double _calculateAverageSleep() {
    if (records.isEmpty) return 0;
    final total = records.fold<int>(0, (sum, r) => sum + r.totalDuration);
    return total / records.length / 60.0;
  }

  double _getMaxSleep() {
    if (records.isEmpty) return 0;
    return records
        .map((r) => r.totalDuration / 60.0)
        .reduce((a, b) => a > b ? a : b);
  }

  double _getMinSleep() {
    if (records.isEmpty) return 0;
    return records
        .map((r) => r.totalDuration / 60.0)
        .reduce((a, b) => a < b ? a : b);
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.heading.copyWith(fontSize: 18)),
      ],
    );
  }
}
