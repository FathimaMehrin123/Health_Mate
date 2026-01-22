import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserEvent extends AuthEvent {}

class CreateUserEvent extends AuthEvent {
  String name;
  int age;
  double height;
  double weight;
  String activityGoal;

  CreateUserEvent({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityGoal,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [name,age,height,weight,activityGoal];
}

class UpdateUserEvent extends AuthEvent {
  String name;
  int age;
  double height;
  double weight;
  String activityGoal;
  UpdateUserEvent({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityGoal,
  });
@override
  
  List<Object?> get props => [name,age,height,weight,activityGoal];

}
