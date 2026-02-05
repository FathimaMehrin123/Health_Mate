import 'package:health_mate/core/error/exceptions.dart';
import 'package:hive/hive.dart';

import '../models/activity_model.dart';

abstract class ActivityLocalDataSource {
  /// Get activities for a date range
  Future<List<ActivityModel>> getActivities({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save an activity
  Future<void> saveActivity(ActivityModel activity);

  /// Get all activities for today
  Future<List<ActivityModel>> getTodayActivities();

  /// Delete activity
  Future<void> deleteActivity(String id);

  /// Clear all activities
  Future<void> clearAll();
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  final Box<ActivityModel> activityBox;

  ActivityLocalDataSourceImpl(this.activityBox);

  @override
  Future<List<ActivityModel>> getActivities({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allActivities = activityBox.values.toList();

      // Filter by date range
      final filtered = allActivities.where((activity) {
        return activity.timestamp.isAfter(startDate) &&
            activity.timestamp.isBefore(endDate);
      }).toList();

      // Sort by timestamp (newest first)
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return filtered;
    } catch (e) {
      throw DatabaseExceptions('Failed to get activities: $e');
    }
  }

  @override
  Future<void> saveActivity(ActivityModel activity) async {
    try {
      await activityBox.put(activity.id, activity);
    } catch (e) {
      throw DatabaseExceptions('Failed to save activity: $e');
    }
  }

  @override
  Future<List<ActivityModel>> getTodayActivities() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getActivities(startDate: startOfDay, endDate: endOfDay);
  }

  @override
  Future<void> deleteActivity(String id) async {
    try {
      await activityBox.delete(id);
    } catch (e) {
      throw DatabaseExceptions('Failed to delete activity: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await activityBox.clear();
    } catch (e) {
      throw DatabaseExceptions('Failed to clear activities: $e');
    }
  }
}
