import 'package:flutter/material.dart';
import '../../domain/entities/sleep_record.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SleepScoreCard extends StatelessWidget {
  final SleepRecord? record;
  final VoidCallback? onTap;
  final bool isLoading;

  const SleepScoreCard({
    super.key,
    this.record,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? _buildLoadingState()
            : record != null
            ? _buildContent()
            : _buildEmptyState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '😴 Sleep Score',
          style: AppTextStyles.body.copyWith(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Text(
          'No data',
          style: AppTextStyles.heading.copyWith(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Start tracking to see your sleep score',
          style: AppTextStyles.body.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Text(
          '😴 Sleep Score',
          style: AppTextStyles.body.copyWith(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 16),
        // Circular progress ring
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CircularProgressIndicator(
                value: 1.0,
               // minRadius: 60,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(
                  Colors.white.withOpacity(0.3),
                ),
              ),
              // Foreground circle
              CircularProgressIndicator(
                value: (record!.qualityScore / 100),
               // minRadius: 60,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 6,
              ),
              // Score text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record!.qualityScore.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          record!.qualityLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTimeInfo('🌙', 'Bedtime', _formatTime(record!.startTime)),
            _buildTimeInfo('☀️', 'Wake time', _formatTime(record!.endTime)),
            _buildTimeInfo('⏱️', 'Duration', record!.durationFormatted),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeInfo(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
