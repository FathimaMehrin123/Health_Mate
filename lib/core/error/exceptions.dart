class DatabaseExceptions implements Exception {
  String message;
  DatabaseExceptions(this.message);
}

class SensorException implements Exception {
  String message;
  SensorException(this.message);
}
