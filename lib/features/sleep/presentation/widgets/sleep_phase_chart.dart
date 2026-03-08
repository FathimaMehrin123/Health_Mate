import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/sleep_record.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SleepPhaseChart extends StatelessWidget {
  final SleepRecord record;

  const SleepPhaseChart({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
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
          Text('Sleep Phases', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          // Line chart showing sleep phases
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 30,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppColors.border, strokeWidth: 0.5);
                  },
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const hours = [
                          '10pm',
                          '11pm',
                          '12am',
                          '1am',
                          '2am',
                          '3am',
                          '4am',
                          '5am',
                          '6am',
                          '7am',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < hours.length) {
                          return Text(
                            hours[value.toInt()],
                            style: AppTextStyles.label.copyWith(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: AppTextStyles.label.copyWith(fontSize: 9),
                        );
                      },
                      interval: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  // Deep sleep line
                  LineChartBarData(
                    spots: _generatePhaseSpots(SleepPhase.deep),
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // Light sleep line
                  LineChartBarData(
                    spots: _generatePhaseSpots(SleepPhase.light),
                    isCurved: true,
                    color: AppColors.warning,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // REM sleep line
                  LineChartBarData(
                    spots: _generatePhaseSpots(SleepPhase.rem),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Phase legend and details
          Column(
            children: [
              _buildPhaseInfo(
                '💤 Deep Sleep',
                record.deepSleepDuration,
                record.deepSleepPercentage,
                AppColors.success,
              ),
              const SizedBox(height: 12),
              _buildPhaseInfo(
                '😴 Light Sleep',
                record.lightSleepDuration,
                record.lightSleepPercentage,
                AppColors.warning,
              ),
              const SizedBox(height: 12),
              _buildPhaseInfo(
                '💭 REM Sleep',
                record.remSleepDuration,
                record.remSleepPercentage,
                AppColors.primary,
              ),
              const SizedBox(height: 12),
              _buildPhaseInfo(
                '👁️ Awake',
                record.awakeDuration,
                (record.awakeDuration / record.totalDuration) * 100,
                AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generatePhaseSpots(SleepPhase phase) {
    final duration = record.phaseDurations[phase] ?? 0;
    final spots = <FlSpot>[];

    // Generate spots for the duration
    for (int i = 0; i < 10; i++) {
      final value = (duration / 10) * (i + 1);
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    return spots;
  }

  Widget _buildPhaseInfo(
    String label,
    int duration,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body),
              Text(
                '${duration}m (${percentage.toStringAsFixed(1)}%)',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
