import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';

abstract class ActivityRepository {
  /// Get activities for a specific date range

  Future<Either<Failure, List<Activity>>> getActivities({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get current activity classification
  Future<Either<Failure, Activity>> getCurrentActivity();

  /// Save activity to local storage
  Future<Either<Failure, void>> saveActivity(Activity activity);

  /// Get today's activity statistics
  Future<Either<Failure, Map<String, dynamic>>> getTodayStats();

  /// Get activity breakdown for a period
  Future<Either<Failure, Map<ActivityType, double>>> getActivityBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  
}
