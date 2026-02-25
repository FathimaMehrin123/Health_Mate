import 'package:dartz/dartz.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/sleep_record.dart';
import '../repositories/sleep_repository.dart';

class AnalyzeSleepQuality implements UseCase<SleepRecord, NoParams> {
  final SleepRepository repository;

  AnalyzeSleepQuality(this.repository);

  @override
  Future<Either<Failure, SleepRecord>> call(NoParams params) async {
    return await repository.stopSleepTracking();
  }
}