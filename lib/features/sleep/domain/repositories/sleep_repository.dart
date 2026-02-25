import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sleep_record.dart';

abstract class SleepRepository {
  /// Get sleep records for a date range
  Future<Either<Failure, List<SleepRecord>>> getSleepRecords({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get last night's sleep record
  Future<Either<Failure, SleepRecord?>> getLastNightSleep();

  /// Save sleep record
  Future<Either<Failure, void>> saveSleepRecord(SleepRecord record);

  /// Start sleep tracking
  Future<Either<Failure, void>> startSleepTracking();

  /// Stop sleep tracking and analyze
  Future<Either<Failure, SleepRecord>> stopSleepTracking();

  /// Get weekly average
  Future<Either<Failure, Map<String, dynamic>>> getWeeklyAverage();

  /// Delete sleep record
  Future<Either<Failure, void>> deleteSleepRecord(String id);
}