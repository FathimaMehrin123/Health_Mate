import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/exceptions.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/features/sleep/models/sleep_record_model.dart';

import '../../domain/entities/sleep_record.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/microphone_datasource.dart';
import '../datasources/sleep_local_datasource.dart';


class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource localDataSource;
  final MicrophoneDataSource microphoneDataSource;

  SleepRepositoryImpl({
    required this.localDataSource,
    required this.microphoneDataSource,
  });

  // Track current sleep session
  DateTime? _sessionStartTime;
  bool _isTracking = false;

  @override
  Future<Either<Failure, List<SleepRecord>>> getSleepRecords({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final records = await localDataSource.getSleepRecords(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(records);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get sleep records: $e'));
    }
  }

  @override
  Future<Either<Failure, SleepRecord?>> getLastNightSleep() async {
    try {
      final record = await localDataSource.getLastNightSleep();
      return Right(record);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get last night sleep: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSleepRecord(SleepRecord record) async {
    try {
      final model = SleepRecordModel.fromEntity(record);
      await localDataSource.saveSleepRecord(model);
      return const Right(null);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to save sleep record: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> startSleepTracking() async {
    try {
      _sessionStartTime = DateTime.now();
      _isTracking = true;
      await microphoneDataSource.startRecording();
      return const Right(null);
    } on SensorException catch (e) {
      return Left(SensorFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to start sleep tracking: $e'));
    }
  }

  @override
  Future<Either<Failure, SleepRecord>> stopSleepTracking() async {
    try {
      if (!_isTracking || _sessionStartTime == null) {
        return Left(UnexpectedFailure('No active sleep tracking session'));
      }

      _isTracking = false;
      await microphoneDataSource.stopRecording();

      final endTime = DateTime.now();
      final totalDuration = endTime.difference(_sessionStartTime!).inMinutes;

      // Get sound levels
      final soundLevels = await microphoneDataSource.getSoundLevels();

      // Calculate sleep quality (mock algorithm)
      final qualityScore = _calculateSleepQuality(
        totalDuration,
        soundLevels,
      );

      // Estimate sleep phases (mock data)
      final phaseDurations = _estimateSleepPhases(totalDuration);

      // Create sleep record
      final record = SleepRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _sessionStartTime!,
        endTime: endTime,
        qualityScore: qualityScore,
        phaseDurations: phaseDurations,
        movementCount: _estimateMovementCount(soundLevels),
        soundLevels: soundLevels,
        totalDuration: totalDuration,
      );

      // Save to database
      await saveSleepRecord(record);

      _sessionStartTime = null;
      return Right(record);
    } on SensorException catch (e) {
      _isTracking = false;
      return Left(SensorFailure(e.message));
    } catch (e) {
      _isTracking = false;
      return Left(UnexpectedFailure('Failed to analyze sleep: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeeklyAverage() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final records = await localDataSource.getSleepRecords(
        startDate: weekAgo,
        endDate: now,
      );

      if (records.isEmpty) {
        return Right({
          'avgDuration': 0,
          'avgQuality': 0,
          'deepSleepAvg': 0,
          'records': [],
        });
      }

      final avgDuration = records
              .fold<int>(0, (sum, r) => sum + r.totalDuration) ~/
          records.length;
      final avgQuality =
          records.fold<int>(0, (sum, r) => sum + r.qualityScore) ~/
              records.length;
      final deepSleepAvg =
          records.fold<int>(0, (sum, r) => sum + r.deepSleepDuration) ~/
              records.length;

      return Right({
        'avgDuration': avgDuration,
        'avgQuality': avgQuality,
        'deepSleepAvg': deepSleepAvg,
        'records': records,
        'totalNights': records.length,
      });
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get weekly average: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSleepRecord(String id) async {
    try {
      await localDataSource.deleteSleepRecord(id);
      return const Right(null);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete sleep record: $e'));
    }
  }

  /// Helper: Calculate sleep quality score (0-100)
  int _calculateSleepQuality(int durationMinutes, List<double> soundLevels) {
    int score = 100;

    // Duration factor (7-8 hours is ideal)
    final hours = durationMinutes / 60;
    if (hours < 6 || hours > 9) {
      score -= 10;
    }

    // Sound disturbance factor
    final avgSound = soundLevels.isEmpty
        ? 0.0
        : soundLevels.reduce((a, b) => a + b) / soundLevels.length;
    if (avgSound > 50) {
      score -= 15;
    } else if (avgSound > 40) {
      score -= 10;
    }

    // Movement factor (estimated from sound pattern)
    final movementEstimate = soundLevels.where((s) => s > 60).length;
    if (movementEstimate > 5) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  /// Helper: Estimate sleep phases (mock distribution)
  Map<SleepPhase, int> _estimateSleepPhases(int totalDuration) {
    // Typical distribution:
    // Deep: 15-20% (2-2.5 hours in 8-hour sleep)
    // REM: 20-25% (1.5-2 hours)
    // Light: 50-65% (rest)
    // Awake: 5-10%

    final deepDuration = (totalDuration * 0.18).toInt();
    final remDuration = (totalDuration * 0.22).toInt();
    final awakeDuration = (totalDuration * 0.07).toInt();
    final lightDuration =
        totalDuration - deepDuration - remDuration - awakeDuration;

    return {
      SleepPhase.deep: deepDuration,
      SleepPhase.rem: remDuration,
      SleepPhase.light: lightDuration,
      SleepPhase.awake: awakeDuration,
    };
  }

  /// Helper: Estimate movement count from sound patterns
  int _estimateMovementCount(List<double> soundLevels) {
    // Count sudden spikes in sound (indicating movement)
    if (soundLevels.length < 2) return 0;

    int count = 0;
    for (int i = 1; i < soundLevels.length; i++) {
      if ((soundLevels[i] - soundLevels[i - 1]).abs() > 15) {
        count++;
      }
    }
    return count;
  }
}