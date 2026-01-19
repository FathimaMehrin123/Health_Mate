import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/authentication/domain/entities/user.dart';
import 'package:health_mate/features/authentication/domain/repositories/user_repository.dart';

class CreateUser implements UseCase<void, CreateUserParams> {
  UserRepository repository;
CreateUser(this.repository);
  @override
  Future<Either<Failure, void>> call(CreateUserParams  params)async {
    final user=User(id: DateTime.now().toString(), name: params.name, age: params.age, height: params.height, weight: params.weight, activityGoal: params.activityGoal);
    return await repository.saveUser(user);
  }


}

class CreateUserParams {

  String name;
  int age;
  double height;
  double weight;
  String activityGoal;

  CreateUserParams({required this.name,required this.age,required  this.height,required this.weight,required this.activityGoal});
  
}
