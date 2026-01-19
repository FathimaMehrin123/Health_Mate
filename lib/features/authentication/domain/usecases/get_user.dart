/*This file defines a Use Case called GetUser.

A Use Case = one business action
Here: “Get the current user”
*/

import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/authentication/domain/entities/user.dart';
import 'package:health_mate/features/authentication/domain/repositories/user_repository.dart';

class GetUser implements UseCase<User, NoParams> {
  UserRepository repository;
  GetUser(this.repository);
  @override
  Future<Either<Failure, User>> call(NoParams params) {
    // TODO: implement call
    return repository.getUser();
  }
}
