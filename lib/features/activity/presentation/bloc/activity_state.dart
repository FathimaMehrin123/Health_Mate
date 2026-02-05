import 'package:equatable/equatable.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';
import 'package:health_mate/features/activity/presentation/bloc/activity_event.dart';

abstract class ActivityState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

/// Initial state
class ActivityInitial extends ActivityState {}

/// Loading activities
class ActivityLoading extends ActivityState {}

/// Activities loaded successfully
class ActivityLoaded extends ActivityState {
  final List<Activity> activities;
  final Map<ActivityType, double> breakdown;
  final TimePeriod currentPeriod;
  final Activity? currentActivity;
  final bool isMonitoring;
  final Map<String, dynamic>? todayStats;

  ActivityLoaded({
    required this.activities,
    required this.breakdown,
    required this.currentPeriod,
    this.currentActivity,
    this.isMonitoring = false,
    this.todayStats,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [
    activities,
    breakdown,
    currentPeriod,
    currentActivity,
    isMonitoring,
    todayStats,
  ];
  ActivityLoaded copyWith({
    List<Activity>? activities,
    Map<ActivityType, double>? breakdown,
    TimePeriod? currentPeriod,
    Activity? currentActivity,
    bool? isMonitoring,
    Map<String, dynamic>? todayStats,
  }) {
    return ActivityLoaded(
      activities: activities ?? this.activities,
      breakdown: breakdown ?? this.breakdown,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      currentActivity: currentActivity ?? this.currentActivity,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      todayStats: todayStats ?? this.todayStats,
    );
  }
}

/// Error state
class ActivityError extends ActivityState {
  final String message;
  ActivityError(this.message);
  @override
  // TODO: implement props
  List<Object?> get props => [message];
}

/// Monitoring started
class MonitoringStarted extends ActivityState {}

/// Monitoring stopped
class MonitoringStopped extends ActivityState {}

/// Current activity classified

class CurrentActivityClassified extends ActivityState {
  final Activity activity;
  CurrentActivityClassified(this.activity);
  @override
  // TODO: implement props
  List<Object?> get props => [activity];
}
