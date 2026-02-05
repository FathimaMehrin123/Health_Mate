import 'package:health_mate/features/activity/domain/entities/activity.dart';
import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 1)
class ActivityModel extends Activity {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime timestamp;
  @HiveField(2)
  final String typeString; // Store as string for Hive
  @override
  @HiveField(3)
  final double confidence;
  @override
  @HiveField(4)
  final int duration;

  @override
  @HiveField(5)
  final int? steps;

  @override
  @HiveField(6)
  final double? calories;

  ActivityModel({
    required this.id,
    required this.timestamp,
    required this.typeString,
    required this.confidence,
    required this.duration,
    this.steps,
    this.calories,
  }) : super(
         id: id,
         timestamp: timestamp,
         type: _stringToActivityType(typeString),
         confidence: confidence,
         duration: duration,
         steps: steps,
         calories: calories,
       );
  // Convert string to ActivityType
  static ActivityType _stringToActivityType(String type) {
    switch (type.toLowerCase()) {
      case "walking":
        return ActivityType.walking;
      case "sitting":
        return ActivityType.sitting;

      case "standing":
        return ActivityType.standing;

      case "running":
        return ActivityType.running;
      case "slouching":
        return ActivityType.slouching;
      default:
        return ActivityType.unknown;
    }
  }

  // Convert ActivityType to string
  static String _activityTypeToString(ActivityType type) {
    return type.toString().split(".").last;
  }

  //Entity → used in app logic
  //Model → used for Hive + API

  //Convert Domain Object → Hive Model
  //Entity → Model (storage friendly)
  /*When app creates activity:
  Activity activity = Activity(...);
  Before saving to Hive:
  ActivityModel model = ActivityModel.fromEntity(activity);
  box.put(id, model);

    */

  factory ActivityModel.fromEntity(Activity activity) {
    return ActivityModel(
      id: activity.id,
      timestamp: activity.timestamp,
      typeString: _activityTypeToString(activity.type),
      confidence: activity.confidence,
      duration: activity.duration,
      steps: activity.steps,
      calories: activity.calories,
    );
  }

  //Convert Model → JSON (for API, cloud, backup)

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "timestamp": timestamp.millisecondsSinceEpoch, //JSON can’t store DateTime directly — so milliseconds used
      "type": typeString,
      "confidence": confidence,
      'duration': duration,
      'steps': steps,
      'calories': calories,
    };
  }
  //fromJson() — Convert JSON → Model

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id:  json["id"] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json["timestamp"] as int),   //Gets the raw number from JSON(json["timestamp"]),Forces Dart to treat it as an integer(because epoch time is always an int) and DateTime.fromMicrosecondsSinceEpoch(...) line Transforms it into: DateTime(2026-01-23 10:30:00)


     typeString:  json['type'],
      confidence:  (json["confidence"] as num).toDouble(),
      duration: json["duration"] as int,
      steps: json["steps"] as int?,
 calories: json['calories'] != null
          ? (json['calories'] as num).toDouble()
          : null,

    );
  }




 ActivityModel copyWith({
    String? id,
    DateTime? timestamp,
    String? typeString,
    double? confidence,
    int? duration,
    int? steps,
    double? calories,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
    typeString: typeString ?? this.typeString,
      confidence: confidence ?? this.confidence,
      duration: duration ?? this.duration,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
    );
  }
}
