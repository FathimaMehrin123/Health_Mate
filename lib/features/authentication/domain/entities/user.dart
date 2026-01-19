import 'package:equatable/equatable.dart';

class User extends Equatable {
  String id;
  String name;
  int age;
  double height;
  double weight;
  String activityGoal;
  User({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityGoal,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, age, height, weight, activityGoal];
}
