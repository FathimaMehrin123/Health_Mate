import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';
import 'package:health_mate/features/activity/domain/repositories/activity_repository.dart';

class GetActivities implements UseCase<List<Activity>, GetActivitiesParams> {
  final ActivityRepository repository;
  GetActivities(this.repository);

  @override
  Future<Either<Failure, List<Activity>>> call(GetActivitiesParams params) {
    return repository.getActivities(
      startDate: params.startDate,
      endDate: params.endDate,
    );
    // TODO: implement call
  }
}

class GetActivitiesParams {
  final DateTime startDate;
  final DateTime endDate;
  GetActivitiesParams({required this.startDate, required this.endDate});

  // Helper factory methods
  factory GetActivitiesParams.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return GetActivitiesParams(startDate: startOfDay, endDate: endOfDay);
  }

  factory GetActivitiesParams.lastWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return GetActivitiesParams(startDate: weekAgo, endDate: now);
  }
  factory GetActivitiesParams.lastMonth() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return GetActivitiesParams(startDate: monthAgo, endDate: now);
  }
}
