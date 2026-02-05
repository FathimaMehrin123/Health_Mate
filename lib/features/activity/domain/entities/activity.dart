import 'package:equatable/equatable.dart';

enum ActivityType {
  walking,
  sitting,
  standing,
  running,
  slouching,
  unknown,
}

class Activity extends Equatable {
  final String id;
  final DateTime timestamp;
  final ActivityType type;
  final double confidence; // 0.0 to 1.0
  final int duration; // in seconds
  final int? steps;
  final double? calories;

  const Activity({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.confidence,
    required this.duration,
    this.steps,
    this.calories,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        type,
        confidence,
        duration,
        steps,
        calories,
      ];
}

// Helper extension
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.sitting:
        return 'Sitting';
      case ActivityType.standing:
        return 'Standing';
      case ActivityType.running:
        return 'Running';
      case ActivityType.slouching:
        return 'Slouching';
      case ActivityType.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityType.walking:
        return '🚶';
      case ActivityType.sitting:
        return '🪑';
      case ActivityType.standing:
        return '🧍';
      case ActivityType.running:
        return '🏃';
      case ActivityType.slouching:
        return '⚠️';
      case ActivityType.unknown:
        return '❓';
    }
  }
}