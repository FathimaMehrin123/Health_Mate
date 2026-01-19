import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/features/authentication/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser();
  Future<Either<Failure, void>> saveUser(User user);
  Future<Either<Failure, void>> updateUser(User user);
}
