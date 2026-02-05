import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/activity/domain/entities/activity.dart';
import 'package:health_mate/features/activity/domain/repositories/activity_repository.dart';

class SaveActivity implements UseCase<void, SaveActivityParams> {
  final ActivityRepository repository;
  SaveActivity(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveActivityParams params) {
    // TODO: implement call
    return repository.saveActivity(params.activity);
  }
}

class SaveActivityParams {
  final Activity activity;
  SaveActivityParams({required this.activity});
}
