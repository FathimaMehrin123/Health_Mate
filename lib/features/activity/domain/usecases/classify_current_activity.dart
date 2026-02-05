import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';
import 'package:health_mate/features/activity/domain/repositories/activity_repository.dart';

class ClassifyCurrentActivity implements UseCase<Activity, NoParams> {
  final ActivityRepository repository;

  ClassifyCurrentActivity(this.repository);
  @override
  Future<Either<Failure, Activity>> call(NoParams params)async {
    return await repository.getCurrentActivity();
  }
}










