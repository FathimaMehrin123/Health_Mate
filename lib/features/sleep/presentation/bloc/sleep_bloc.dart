import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'dart:async';
import '../../domain/usecases/get_sleep_records.dart';
import '../../domain/usecases/get_last_night_sleep.dart';
import '../../domain/usecases/save_sleep_record.dart';
import '../../domain/usecases/analyze_sleep_quality.dart';
import '../../domain/repositories/sleep_repository.dart';
import 'sleep_event.dart';
import 'sleep_state.dart';

class SleepBloc extends Bloc<SleepEvent, SleepState> {
  final GetSleepRecords getSleepRecords;
  final GetLastNightSleep getLastNightSleep;
  final SaveSleepRecord saveSleepRecord;
  final AnalyzeSleepQuality analyzeSleepQuality;
  final SleepRepository repository;

  Timer? _trackingTimer;

  SleepBloc({
    required this.getSleepRecords,
    required this.getLastNightSleep,
    required this.saveSleepRecord,
    required this.analyzeSleepQuality,
    required this.repository,
  }) : super(const SleepInitial()) {
    // Event handlers
    on<GetSleepRecordsEvent>(_onGetSleepRecords);
    on<GetLastNightSleepEvent>(_onGetLastNightSleep);
    on<StartSleepTrackingEvent>(_onStartSleepTracking);
    on<StopSleepTrackingEvent>(_onStopSleepTracking);
    on<SaveSleepRecordEvent>(_onSaveSleepRecord);
    on<GetWeeklyAverageEvent>(_onGetWeeklyAverage);
    on<DeleteSleepRecordEvent>(_onDeleteSleepRecord);
    on<GetSleepByDateEvent>(_onGetSleepByDate);
    on<ClearSleepDataEvent>(_onClearSleepData);
  }

  // Get sleep records for date range
  Future<void> _onGetSleepRecords(
    GetSleepRecordsEvent event,
    Emitter<SleepState> emit,
  ) async {
    emit(const SleepLoading());

    final result = await getSleepRecords(
      GetSleepRecordsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (records) {
        if (records.isEmpty) {
          emit(const SleepEmpty());
        } else {
          emit(SleepRecordsLoaded(records));
        }
      },
    );
  }

  // Get last night's sleep
  Future<void> _onGetLastNightSleep(
    GetLastNightSleepEvent event,
    Emitter<SleepState> emit,
  ) async {
    emit(const SleepLoading());

    final result = await getLastNightSleep(NoParams());

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (record) => emit(LastNightSleepLoaded(record)),
    );
  }

  // Start sleep tracking
  Future<void> _onStartSleepTracking(
    StartSleepTrackingEvent event,
    Emitter<SleepState> emit,
  ) async {
    final result = await repository.startSleepTracking();

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) {
        final startTime = DateTime.now();
        emit(SleepTrackingStarted(startTime));

        // Start timer to update elapsed time
        _trackingTimer?.cancel();
        _trackingTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) {
            if (state is SleepTrackingStarted) {
              emit(SleepTrackingInProgress(
                startTime: startTime,
                elapsed: DateTime.now().difference(startTime),
              ));
            }
          },
        );
      },
    );
  }

  // Stop sleep tracking and analyze
  Future<void> _onStopSleepTracking(
    StopSleepTrackingEvent event,
    Emitter<SleepState> emit,
  ) async {
    _trackingTimer?.cancel();
    _trackingTimer = null;

    emit(const SleepLoading());

    final result = await analyzeSleepQuality(NoParams());

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (record) => emit(SleepTrackingStopped(record)),
    );
  }

  // Save sleep record
  Future<void> _onSaveSleepRecord(
    SaveSleepRecordEvent event,
    Emitter<SleepState> emit,
  ) async {
    final result = await saveSleepRecord(SaveSleepRecordParams(
      record: event.record,
    ));

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(const SleepRecordSaved()),
    );
  }

  // Get weekly average
  Future<void> _onGetWeeklyAverage(
    GetWeeklyAverageEvent event,
    Emitter<SleepState> emit,
  ) async {
    emit(const SleepLoading());

    final result = await repository.getWeeklyAverage();

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (data) => emit(WeeklyAverageLoaded(data)),
    );
  }

  // Delete sleep record
  Future<void> _onDeleteSleepRecord(
    DeleteSleepRecordEvent event,
    Emitter<SleepState> emit,
  ) async {
    final result = await repository.deleteSleepRecord(event.recordId);

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(const SleepRecordDeleted()),
    );
  }

  // Get sleep for specific date
  Future<void> _onGetSleepByDate(
    GetSleepByDateEvent event,
    Emitter<SleepState> emit,
  ) async {
    emit(const SleepLoading());

    final dayStart = DateTime(event.date.year, event.date.month, event.date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final result = await getSleepRecords(
      GetSleepRecordsParams(
        startDate: dayStart,
        endDate: dayEnd,
      ),
    );

    result.fold(
      (failure) => emit(SleepError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (records) {
        if (records.isEmpty) {
          emit(const SleepEmpty());
        } else {
          emit(SleepRecordsLoaded(records));
        }
      },
    );
  }

  // Clear all sleep data
  Future<void> _onClearSleepData(
    ClearSleepDataEvent event,
    Emitter<SleepState> emit,
  ) async {
    // Implementation depends on your repository
    // For now, just emit empty state
    emit(const SleepEmpty());
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(dynamic failure) {
    if (failure.toString().contains('DatabaseFailure')) {
      return 'Failed to access sleep data. Please try again.';
    } else if (failure.toString().contains('SensorFailure')) {
      return 'Failed to access sensors. Please check permissions.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _trackingTimer?.cancel();
    return super.close();
  }
}