import 'package:equatable/equatable.dart';

enum SleepPhase {
  awake,
  light,
  deep,
  rem,
}

class SleepRecord extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int qualityScore; // 0-100
  final Map<SleepPhase, int> phaseDurations; // Duration in minutes
  final int movementCount;
  final List<double> soundLevels; // Sound levels during sleep
  final int totalDuration; // Total sleep duration in minutes

  const SleepRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.qualityScore,
    required this.phaseDurations,
    required this.movementCount,
    required this.soundLevels,
    required this.totalDuration,
  });

  // Helper getters
  int get deepSleepDuration => phaseDurations[SleepPhase.deep] ?? 0;
  int get lightSleepDuration => phaseDurations[SleepPhase.light] ?? 0;
  int get remSleepDuration => phaseDurations[SleepPhase.rem] ?? 0;
  int get awakeDuration => phaseDurations[SleepPhase.awake] ?? 0;

  double get deepSleepPercentage =>
      totalDuration > 0 ? (deepSleepDuration / totalDuration) * 100 : 0;
  double get lightSleepPercentage =>
      totalDuration > 0 ? (lightSleepDuration / totalDuration) * 100 : 0;
  double get remSleepPercentage =>
      totalDuration > 0 ? (remSleepDuration / totalDuration) * 100 : 0;

  String get durationFormatted {
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;
    return '${hours}h ${minutes}m';
  }

  String get qualityLabel {
    if (qualityScore >= 80) return 'Excellent';
    if (qualityScore >= 70) return 'Good';
    if (qualityScore >= 60) return 'Fair';
    if (qualityScore >= 50) return 'Poor';
    return 'Very Poor';
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        qualityScore,
        phaseDurations,
        movementCount,
        soundLevels,
        totalDuration,
      ];
}

// Helper extension for SleepPhase
extension SleepPhaseExtension on SleepPhase {
  String get displayName {
    switch (this) {
      case SleepPhase.awake:
        return 'Awake';
      case SleepPhase.light:
        return 'Light Sleep';
      case SleepPhase.deep:
        return 'Deep Sleep';
      case SleepPhase.rem:
        return 'REM Sleep';
    }
  }

  String get emoji {
    switch (this) {
      case SleepPhase.awake:
        return '👁️';
      case SleepPhase.light:
        return '😴';
      case SleepPhase.deep:
        return '💤';
      case SleepPhase.rem:
        return '💭';
    }
  }
}