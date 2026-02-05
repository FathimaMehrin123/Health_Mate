import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/classify_current_activity.dart';
import '../../domain/usecases/get_activities.dart';
import '../../domain/usecases/get_today_stats.dart';
import '../../domain/usecases/save_activity.dart';
import '../../../activity/data/datasources/sensor_datasource.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivities getActivities;
  final ClassifyCurrentActivity classifyCurrentActivity;
  final SaveActivity saveActivity;
  final GetTodayStats getTodayStats;
  final SensorDataSource sensorDataSource;

  Timer? _monitoringTimer;
  TimePeriod _currentPeriod = TimePeriod.day;

  ActivityBloc({
    required this.getActivities,
    required this.classifyCurrentActivity,
    required this.saveActivity,
    required this.getTodayStats,
    required this.sensorDataSource,
  }) : super(ActivityInitial()) {
    on<LoadActivitiesEvent>(_onLoadActivities);
    on<StartMonitoringEvent>(_onStartMonitoring);
    on<StopMonitoringEvent>(_onStopMonitoring);
    on<ClassifyCurrentActivityEvent>(_onClassifyCurrentActivity);
    on<SwitchTimePeriodEvent>(_onSwitchTimePeriod);
    on<RefreshActivityDataEvent>(_onRefreshActivityData);
    on<LoadTodayStatsEvent>(_onLoadTodayStats);
    on<ActivityClassifiedEvent>(_onActivityClassified);
  }

  Future<void> _onLoadActivities(
    LoadActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());

    _currentPeriod = event.period;

    final params = GetActivitiesParams(
      startDate: event.period.startDate,
      endDate: event.period.endDate,
    );

    final result = await getActivities(params);

    await result.fold(
      (failure) async {
        emit(ActivityError(failure.message));
      },
      (activities) async {
        // Get activity breakdown
        final breakdown = _calculateBreakdown(activities);

        // Get today's stats
        final statsResult = await getTodayStats(NoParams());
        Map<String, dynamic>? todayStats;
        statsResult.fold(
          (failure) => null,
          (stats) => todayStats = stats,
        );

        emit(ActivityLoaded(
          activities: activities,
          breakdown: breakdown,
          currentPeriod: event.period,
          todayStats: todayStats,
        ));
      },
    );
  }

  Future<void> _onStartMonitoring(
    StartMonitoringEvent event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await sensorDataSource.startMonitoring();

      if (state is ActivityLoaded) {
        final currentState = state as ActivityLoaded;
        emit(currentState.copyWith(isMonitoring: true));
      }

      // Start periodic classification (every 30 seconds)
      _monitoringTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => add(ClassifyCurrentActivityEvent()),
      );

      // Classify immediately
      add(ClassifyCurrentActivityEvent());
    } catch (e) {
      emit(ActivityError('Failed to start monitoring: $e'));
    }
  }

  Future<void> _onStopMonitoring(
    StopMonitoringEvent event,
    Emitter<ActivityState> emit,
  ) async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    await sensorDataSource.stopMonitoring();

    if (state is ActivityLoaded) {
      final currentState = state as ActivityLoaded;
      emit(currentState.copyWith(
        isMonitoring: false,
        currentActivity: null,
      ));
    }
  }

  Future<void> _onClassifyCurrentActivity(
    ClassifyCurrentActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    final result = await classifyCurrentActivity(NoParams());

    result.fold(
      (failure) {
        // Don't emit error, just log it
        // Continue monitoring
      },
      (activity) async {
        // Save the classified activity
        await saveActivity(SaveActivityParams(activity: activity));

        if (state is ActivityLoaded) {
          final currentState = state as ActivityLoaded;
          emit(currentState.copyWith(currentActivity: activity));

          // Refresh activities list
          add(RefreshActivityDataEvent());
        }
      },
    );
  }

  Future<void> _onSwitchTimePeriod(
    SwitchTimePeriodEvent event,
    Emitter<ActivityState> emit,
  ) async {
    add(LoadActivitiesEvent(event.period));
  }

  Future<void> _onRefreshActivityData(
    RefreshActivityDataEvent event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is ActivityLoaded) {
      add(LoadActivitiesEvent(_currentPeriod));
    }
  }

  Future<void> _onLoadTodayStats(
    LoadTodayStatsEvent event,
    Emitter<ActivityState> emit,
  ) async {
    final result = await getTodayStats(NoParams());

    result.fold(
      (failure) => null,
      (stats) {
        if (state is ActivityLoaded) {
          final currentState = state as ActivityLoaded;
          emit(currentState.copyWith(todayStats: stats));
        }
      },
    );
  }

  Future<void> _onActivityClassified(
    ActivityClassifiedEvent event,
    Emitter<ActivityState> emit,
  ) async {
    // This event can be triggered from background service
    // For now, just refresh data
    add(RefreshActivityDataEvent());
  }

  Map<ActivityType, double> _calculateBreakdown(List<Activity> activities) {
    if (activities.isEmpty) return {};

    final totalDuration = activities.fold<int>(
      0,
      (sum, activity) => sum + activity.duration,
    );

    if (totalDuration == 0) return {};

    final breakdown = <ActivityType, double>{};

    for (final type in ActivityType.values) {
      final typeDuration = activities
          .where((a) => a.type == type)
          .fold<int>(0, (sum, a) => sum + a.duration);

      if (typeDuration > 0) {
        breakdown[type] = (typeDuration / totalDuration) * 100;
      }
    }

    return breakdown;
  }

  @override
  Future<void> close() {
    _monitoringTimer?.cancel();
    return super.close();
  }
}