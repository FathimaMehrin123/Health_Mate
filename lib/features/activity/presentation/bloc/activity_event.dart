import 'package:equatable/equatable.dart';

abstract class ActivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load activities for a specific time period
class LoadActivitiesEvent extends ActivityEvent {
  final TimePeriod period;

  LoadActivitiesEvent(this.period);

  @override
  // TODO: implement props
  List<Object?> get props => [period];
}

/// Start real-time activity monitoring
class StartMonitoringEvent extends ActivityEvent {}

/// Stop real-time activity monitoring
class StopMonitoringEvent extends ActivityEvent {}

/// Classify current activity (manual trigger)
class ClassifyCurrentActivityEvent extends ActivityEvent {}

/// Activity classified (from background service)

class ActivityClassifiedEvent extends ActivityEvent {
  final String activityType;
  final double confidence;
  final int duration;
  final int? steps;

  ActivityClassifiedEvent({
    required this.activityType,
    required this.confidence,
    required this.duration,
    this.steps,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [activityType, confidence, duration, steps];
}

/// Switch time period (Day/Week/Month)
class SwitchTimePeriodEvent extends ActivityEvent {
  final TimePeriod period;

  SwitchTimePeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

/// Refresh current data
class RefreshActivityDataEvent extends ActivityEvent {}

/// Load today's stats
class LoadTodayStatsEvent extends ActivityEvent {}

/// Enum for time periods
enum TimePeriod { day, week, month }

extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.day:
        return 'Day';
      case TimePeriod.week:
        return 'Week';
      case TimePeriod.month:
        return 'Month';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case TimePeriod.day:
        return DateTime(now.year, now.month, now.day);
      case TimePeriod.week:
        return now.subtract(const Duration(days: 7));
      case TimePeriod.month:
        return now.subtract(const Duration(days: 30));
    }
  }

  DateTime get endDate {
    return DateTime.now();
  }
}
