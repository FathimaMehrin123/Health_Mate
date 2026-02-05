import 'package:dartz/dartz.dart';
import 'package:health_mate/core/error/failures.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/activity/domain/repositories/activity_repository.dart';

class GetTodayStats implements UseCase<Map<String, dynamic>, NoParams> {
  final ActivityRepository repository;
  GetTodayStats(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return repository.getTodayStats();
  }
}
