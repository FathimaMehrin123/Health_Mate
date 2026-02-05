import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';

// Base UseCase class for all business logic actions in the app.
// It enforces a standard structure where each use case:
// - takes input parameters (Params)
// - returns either a Failure or successful result (Type)




abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}