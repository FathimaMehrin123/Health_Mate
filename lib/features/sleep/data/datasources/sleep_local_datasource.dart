import 'package:health_mate/core/error/exceptions.dart';
import 'package:health_mate/features/sleep/models/sleep_record_model.dart';
import 'package:hive/hive.dart';


abstract class SleepLocalDataSource {
  /// Get sleep records for a date range
  Future<List<SleepRecordModel>> getSleepRecords({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get last night's sleep
  Future<SleepRecordModel?> getLastNightSleep();

  /// Save sleep record
  Future<void> saveSleepRecord(SleepRecordModel record);

  /// Delete sleep record
  Future<void> deleteSleepRecord(String id);

  /// Clear all records
  Future<void> clearAll();
}

class SleepLocalDataSourceImpl implements SleepLocalDataSource {
  final Box<SleepRecordModel> sleepBox;

  SleepLocalDataSourceImpl(this.sleepBox);

  @override
  Future<List<SleepRecordModel>> getSleepRecords({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allRecords = sleepBox.values.toList();

      // Filter by date range
      final filtered = allRecords.where((record) {
        return record.startTime.isAfter(startDate) &&
            record.startTime.isBefore(endDate);
      }).toList();

      // Sort by date (newest first)
      filtered.sort((a, b) => b.startTime.compareTo(a.startTime));

      return filtered;
    } catch (e) {
      throw DatabaseExceptions('Failed to get sleep records: $e');
    }
  }

  @override
  Future<SleepRecordModel?> getLastNightSleep() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Get records from last 24 hours
      final recent = await getSleepRecords(
        startDate: yesterday,
        endDate: now,
      );

      return recent.isNotEmpty ? recent.first : null;
    } catch (e) {
      throw DatabaseExceptions('Failed to get last night sleep: $e');
    }
  }

  @override
  Future<void> saveSleepRecord(SleepRecordModel record) async {
    try {
      await sleepBox.put(record.id, record);
    } catch (e) {
      throw DatabaseExceptions('Failed to save sleep record: $e');
    }
  }

  @override
  Future<void> deleteSleepRecord(String id) async {
    try {
      await sleepBox.delete(id);
    } catch (e) {
      throw DatabaseExceptions('Failed to delete sleep record: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await sleepBox.clear();
    } catch (e) {
      throw DatabaseExceptions('Failed to clear sleep records: $e');
    }
  }
}