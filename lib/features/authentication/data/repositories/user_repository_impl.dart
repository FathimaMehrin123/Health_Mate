import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/exceptions.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/features/authentication/data/datasources/user_local_datasource.dart';
import 'package:health_mate/features/authentication/data/models/user_model.dart';
import 'package:health_mate/features/authentication/domain/entities/user.dart';
import 'package:health_mate/features/authentication/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  UserLocalDataSource localDataSource;

  UserRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, User>> getUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } on DatabaseExceptions catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);

      await localDataSource.saveUser(userModel);
      return Right(null);
    } on DatabaseExceptions catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);

      await localDataSource.updateUser(userModel);
      return right(null);
    } on DatabaseExceptions catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
