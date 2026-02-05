import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../services/ml_service.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';
import '../datasources/sensor_datasource.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDataSource localDataSource;
  final SensorDataSource sensorDataSource;
  final MLService mlService;

  ActivityRepositoryImpl({
    required this.localDataSource,
    required this.sensorDataSource,
    required this.mlService,
  });

  @override
  Future<Either<Failure, List<Activity>>> getActivities({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final activities = await localDataSource.getActivities(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(activities);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Activity>> getCurrentActivity() async {
    try {
      // Get sensor features
      final features = await sensorDataSource.getFeatureVector();

      // Classify using ML model
      final activity = mlService.classifyActivity(features);

      return Right(activity);
    } on SensorException catch (e) {
      return Left(SensorFailure(e.message));
    } catch (e) {
      return Left(SensorFailure('Failed to classify activity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveActivity(Activity activity) async {
    try {
      final activityModel = ActivityModel.fromEntity(activity);
      await localDataSource.saveActivity(activityModel);
      return const Right(null);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTodayStats() async {
    try {
      final activities = await localDataSource.getTodayActivities();

      int totalSteps = 0;
      double totalCalories = 0.0;
      int totalDuration = 0;

      for (final activity in activities) {
        totalSteps += activity.steps ?? 0;
        totalCalories += activity.calories ?? 0.0;
        totalDuration += activity.duration;
      }

      return Right({
        'totalSteps': totalSteps,
        'totalCalories': totalCalories,
        'totalDuration': totalDuration,
        'activityCount': activities.length,
      });
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<ActivityType, double>>> getActivityBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final activities = await localDataSource.getActivities(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate total duration
      final totalDuration = activities.fold<int>(
        0,
        (sum, activity) => sum + activity.duration,
      );

      if (totalDuration == 0) {
        return const Right({});
      }

      // Calculate percentage for each activity type
      final breakdown = <ActivityType, double>{};

      for (final type in ActivityType.values) {
        final typeDuration = activities
            .where((a) => a.type == type)
            .fold<int>(0, (sum, a) => sum + a.duration);

        if (typeDuration > 0) {
          breakdown[type] = (typeDuration / totalDuration) * 100;
        }
      }

      return Right(breakdown);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}