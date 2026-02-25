import 'package:dartz/dartz.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';

import '../entities/sleep_record.dart';
import '../repositories/sleep_repository.dart';

class GetSleepRecords
    implements UseCase<List<SleepRecord>, GetSleepRecordsParams> {
  final SleepRepository repository;

  GetSleepRecords(this.repository);

  @override
  Future<Either<Failure, List<SleepRecord>>> call(
    GetSleepRecordsParams params,
  ) async {
    return await repository.getSleepRecords(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetSleepRecordsParams {
  final DateTime startDate;
  final DateTime endDate;

  GetSleepRecordsParams({required this.startDate, required this.endDate});

  // Helper factory - last 7 days
  factory GetSleepRecordsParams.lastWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return GetSleepRecordsParams(startDate: weekAgo, endDate: now);
  }

  // Helper factory - last 30 days
  factory GetSleepRecordsParams.lastMonth() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return GetSleepRecordsParams(startDate: monthAgo, endDate: now);
  }
}
