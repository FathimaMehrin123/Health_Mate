import 'package:health_mate/features/sleep/domain/entities/sleep_record.dart';
import 'package:hive/hive.dart';

part 'sleep_record_model.g.dart';

@HiveType(typeId: 2)
class SleepRecordModel extends SleepRecord {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final DateTime startTime;

  @override
  @HiveField(2)
  final DateTime endTime;

  @override
  @HiveField(3)
  final int qualityScore;

  @HiveField(4)
  final Map<String, int> phaseDurationsMap; // Store as Map<String, int>

  @override
  @HiveField(5)
  final int movementCount;

  @override
  @HiveField(6)
  final List<double> soundLevels;

  @override
  @HiveField(7)
  final int totalDuration;

  SleepRecordModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.qualityScore,
    required this.phaseDurationsMap,
    required this.movementCount,
    required this.soundLevels,
    required this.totalDuration,
  }) : super(
          id: id,
          startTime: startTime,
          endTime: endTime,
          qualityScore: qualityScore,
          phaseDurations: _mapToPhaseDurations(phaseDurationsMap),
          movementCount: movementCount,
          soundLevels: soundLevels,
          totalDuration: totalDuration,
        );

  // Convert String map to SleepPhase map
  static Map<SleepPhase, int> _mapToPhaseDurations(Map<String, int> map) {
    return {
      SleepPhase.awake: map['awake'] ?? 0,
      SleepPhase.light: map['light'] ?? 0,
      SleepPhase.deep: map['deep'] ?? 0,
      SleepPhase.rem: map['rem'] ?? 0,
    };
  }

  // Convert SleepPhase map to String map
  static Map<String, int> _phaseDurationsToMap(
      Map<SleepPhase, int> phaseDurations) {
    return {
      'awake': phaseDurations[SleepPhase.awake] ?? 0,
      'light': phaseDurations[SleepPhase.light] ?? 0,
      'deep': phaseDurations[SleepPhase.deep] ?? 0,
      'rem': phaseDurations[SleepPhase.rem] ?? 0,
    };
  }

  // From Entity
  factory SleepRecordModel.fromEntity(SleepRecord record) {
    return SleepRecordModel(
      id: record.id,
      startTime: record.startTime,
      endTime: record.endTime,
      qualityScore: record.qualityScore,
      phaseDurationsMap: _phaseDurationsToMap(record.phaseDurations),
      movementCount: record.movementCount,
      soundLevels: record.soundLevels,
      totalDuration: record.totalDuration,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'qualityScore': qualityScore,
      'phaseDurations': phaseDurationsMap,
      'movementCount': movementCount,
      'soundLevels': soundLevels,
      'totalDuration': totalDuration,
    };
  }

  // From JSON
  factory SleepRecordModel.fromJson(Map<String, dynamic> json) {
    return SleepRecordModel(
      id: json['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      qualityScore: json['qualityScore'] as int,
      phaseDurationsMap: Map<String, int>.from(json['phaseDurations'] as Map),
      movementCount: json['movementCount'] as int,
      soundLevels: (json['soundLevels'] as List).map((e) => e as double).toList(),
      totalDuration: json['totalDuration'] as int,
    );
  }

  // Copy with
  SleepRecordModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? qualityScore,
    Map<String, int>? phaseDurationsMap,
    int? movementCount,
    List<double>? soundLevels,
    int? totalDuration,
  }) {
    return SleepRecordModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      qualityScore: qualityScore ?? this.qualityScore,
      phaseDurationsMap: phaseDurationsMap ?? this.phaseDurationsMap,
      movementCount: movementCount ?? this.movementCount,
      soundLevels: soundLevels ?? this.soundLevels,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}