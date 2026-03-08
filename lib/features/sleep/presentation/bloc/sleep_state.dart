import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/sleep_record.dart';

abstract class SleepState extends Equatable {
  const SleepState();

  @override
  List<Object?> get props => [];
}

// Initial state
class SleepInitial extends SleepState {
  const SleepInitial();
}

// Loading state
class SleepLoading extends SleepState {
  const SleepLoading();
}

// Records loaded successfully
class SleepRecordsLoaded extends SleepState {
  final List<SleepRecord> records;

  const SleepRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

// Last night sleep loaded
class LastNightSleepLoaded extends SleepState {
  final SleepRecord? record;

  const LastNightSleepLoaded(this.record);

  @override
  List<Object?> get props => [record];
}

// Sleep tracking started
class SleepTrackingStarted extends SleepState {
  final DateTime startTime;

  const SleepTrackingStarted(this.startTime);

  @override
  List<Object?> get props => [startTime];
}

// Sleep tracking stopped and analyzed
class SleepTrackingStopped extends SleepState {
  final SleepRecord record;

  const SleepTrackingStopped(this.record);

  @override
  List<Object?> get props => [record];
}

// Sleep record saved
class SleepRecordSaved extends SleepState {
  const SleepRecordSaved();
}

// Weekly average loaded
class WeeklyAverageLoaded extends SleepState {
  final Map<String, dynamic> data;

  const WeeklyAverageLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// Sleep record deleted
class SleepRecordDeleted extends SleepState {
  const SleepRecordDeleted();
}

// Error state
class SleepError extends SleepState {
  final Failure failure;
  final String message;

  const SleepError({required this.failure, required this.message});

  @override
  List<Object?> get props => [failure, message];
}

// Empty state
class SleepEmpty extends SleepState {
  const SleepEmpty();
}

// Tracking in progress state
class SleepTrackingInProgress extends SleepState {
  final DateTime startTime;
  final Duration elapsed;

  const SleepTrackingInProgress({
    required this.startTime,
    required this.elapsed,
  });

  @override
  List<Object?> get props => [startTime, elapsed];
}
