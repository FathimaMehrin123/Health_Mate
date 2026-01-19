abstract class Failure {
  String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class SensorFailure extends Failure {
  SensorFailure(super.message);
}
