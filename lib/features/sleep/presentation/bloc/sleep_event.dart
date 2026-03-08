import 'package:equatable/equatable.dart';
import '../../domain/entities/sleep_record.dart';

abstract class SleepEvent extends Equatable {
  const SleepEvent();

  @override
  List<Object?> get props => [];
}

// Get all sleep records for date range
class GetSleepRecordsEvent extends SleepEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetSleepRecordsEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

// Get last night's sleep
class GetLastNightSleepEvent extends SleepEvent {
  const GetLastNightSleepEvent();
}

// Start sleep tracking
class StartSleepTrackingEvent extends SleepEvent {
  const StartSleepTrackingEvent();
}

// Stop sleep tracking and analyze
class StopSleepTrackingEvent extends SleepEvent {
  const StopSleepTrackingEvent();
}

// Save sleep record
class SaveSleepRecordEvent extends SleepEvent {
  final SleepRecord record;

  const SaveSleepRecordEvent(this.record);

  @override
  List<Object?> get props => [record];
}

// Get weekly average
class GetWeeklyAverageEvent extends SleepEvent {
  const GetWeeklyAverageEvent();
}

// Delete sleep record
class DeleteSleepRecordEvent extends SleepEvent {
  final String recordId;

  const DeleteSleepRecordEvent(this.recordId);

  @override
  List<Object?> get props => [recordId];
}

// Get sleep by specific date
class GetSleepByDateEvent extends SleepEvent {
  final DateTime date;

  const GetSleepByDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

// Clear all sleep data
class ClearSleepDataEvent extends SleepEvent {
  const ClearSleepDataEvent();
}
