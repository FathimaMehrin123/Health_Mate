import 'dart:async';

import 'package:health_mate/core/error/exceptions.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Defines the contract for accessing and processing sensor data

abstract class SensorDataSource {
  /// Start collecting sensor data
  Future<void> startMonitoring();

  /// Stop collecting sensor data
  Future<void> stopMonitoring();

  /// Get current sensor readings
  Future<Map<String, dynamic>> getCurrentReadings();

  /// Generates a numerical feature vector for machine learning models

  Future<List<double>> getFeatureVector();
}

class SensorDataSourceImpl implements SensorDataSource {
  // Stream subscription for accelerometer sensor updates
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  // Stream subscription for gyroscope sensor updates
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  // Buffer to store recent accelerometer readings for analysis

  final List<AccelerometerEvent> _accelerometerBuffer = [];
  // Buffer to store recent gyroscope readings for analysis

  final List<GyroscopeEvent> _gyroscopeBuffer = [];
  // Maximum number of sensor readings retained in memory

  static const int bufferSize = 100;
  // Indicates whether sensor monitoring is currently active

  bool _isMonitoring = false;

  @override
  Future<void> startMonitoring() async {
    try {
      _isMonitoring = true;

      // Subscribe to accelerometer stream and collect readings

      _accelerometerSubscription = accelerometerEvents.listen((
        AccelerometerEvent event,
      ) {
        // Add new reading to buffer
        _accelerometerBuffer.add(event);
        // Maintain fixed buffer size by removing oldest entry

        if (_accelerometerBuffer.length > bufferSize) {
          _accelerometerBuffer.removeAt(0);
        }
      });

      // Subscribe to gyroscope stream and collect readings

      _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        // Add new reading to buffer

        _gyroscopeBuffer.add(event);
        // Maintain fixed buffer size by removing oldest entry

        if (_gyroscopeBuffer.length > bufferSize) {
          _gyroscopeBuffer.removeAt(0);
        }
      });
    } catch (e) {
      // Convert low-level errors into domain-specific sensor exception

      throw SensorException('Failed to start monitoring: $e');
    }
  }

  @override
  Future<void> stopMonitoring() async {
    // Disable monitoring flag
    _isMonitoring = false;
    // Cancel sensor subscriptions to prevent memory leaks

    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    // Clear buffered sensor history
    _accelerometerBuffer.clear();
    _gyroscopeBuffer.clear();
  }

  @override
  Future<Map<String, dynamic>> getCurrentReadings() async {
    // Ensure sensors are running and data exists

    if (!_isMonitoring || _accelerometerBuffer.isEmpty) {
      throw SensorException('Sensor monitoring not started');
    }
    // Retrieve most recent accelerometer reading

    final accel = _accelerometerBuffer.last;
    final gyro = _gyroscopeBuffer.isNotEmpty
        ? _gyroscopeBuffer.last
        : GyroscopeEvent(0, 0, 0, DateTime.now());
    // Return structured sensor snapshot
    return {
      'accelerometer': {'x': accel.x, 'y': accel.y, 'z': accel.z},
      'gyroscope': {'x': gyro.x, 'y': gyro.y, 'z': gyro.z},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<List<double>> getFeatureVector() async {
    // Ensure enough data exists for meaningful feature extraction

    if (_accelerometerBuffer.length < 10) {
      throw SensorException('Not enough sensor data collected');
    }

    // Calculate statistical features from sensor buffer
    final features = <double>[];

    // Extract accelerometer axes into separate numerical arrays
    final accelX = _accelerometerBuffer.map((e) => e.x).toList();
    final accelY = _accelerometerBuffer.map((e) => e.y).toList();
    final accelZ = _accelerometerBuffer.map((e) => e.z).toList();
    // Compute statistical features for accelerometer signals

    features.addAll([
      _mean(accelX),
      _mean(accelY),
      _mean(accelZ),
      _std(accelX),
      _std(accelY),
      _std(accelZ),
      _max(accelX),
      _max(accelY),
      _max(accelZ),
      _min(accelX),
      _min(accelY),
      _min(accelZ),
    ]);

    // Compute gyroscope features if sufficient data exists

    if (_gyroscopeBuffer.length >= 10) {
      final gyroX = _gyroscopeBuffer.map((e) => e.x).toList();
      final gyroY = _gyroscopeBuffer.map((e) => e.y).toList();
      final gyroZ = _gyroscopeBuffer.map((e) => e.z).toList();

      features.addAll([
        _mean(gyroX),
        _mean(gyroY),
        _mean(gyroZ),
        _std(gyroX),
        _std(gyroY),
        _std(gyroZ),
      ]);
    }
    // Return numerical feature vector ready for ML inference

    return features;
  }

  // Helper functions for feature extraction

  /// Computes the average value of a numeric list

  double _mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Computes the variance of a numeric list

  double _std(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _mean(values);
    final variance =
        values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
        values.length;
    return variance;
  }

  /// Returns the maximum value in a numeric list

  double _max(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Returns the minimum value in a numeric list

  double _min(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a < b ? a : b);
  }
}
