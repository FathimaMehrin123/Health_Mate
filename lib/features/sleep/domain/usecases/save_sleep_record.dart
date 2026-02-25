import 'package:dartz/dartz.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/sleep_record.dart';
import '../repositories/sleep_repository.dart';

class SaveSleepRecord implements UseCase<void, SaveSleepRecordParams> {
  final SleepRepository repository;

  SaveSleepRecord(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveSleepRecordParams params) async {
    return await repository.saveSleepRecord(params.record);
  }
}

class SaveSleepRecordParams {
  final SleepRecord record;

  SaveSleepRecordParams({required this.record});
}