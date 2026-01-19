import 'package:health_mate/features/authentication/domain/entities/user.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends User {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  double height;
  @HiveField(4)
  double weight;

  @HiveField(5)
  String activityGoal;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityGoal,
  }) : super(
         id: id,
         name: name,
         age: age,
         height: height,
         weight: weight,
         activityGoal: activityGoal,
       );
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      height: user.height,
      weight: user.weight,
      activityGoal: user.activityGoal,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'height': height,
    'weight': weight,
    'activityGoal': activityGoal,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      height: json['height'],
      weight: json['weight'],
      activityGoal: json['activityGoal'],
    );
  }
}
