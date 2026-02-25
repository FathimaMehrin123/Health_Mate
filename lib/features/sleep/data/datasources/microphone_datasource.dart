import 'dart:async';
import '../../../../core/error/exceptions.dart';

abstract class MicrophoneDataSource {
  /// Start recording sound levels
  Future<void> startRecording();

  /// Stop recording
  Future<void> stopRecording();

  /// Get recorded sound levels
  Future<List<double>> getSoundLevels();

  /// Get average sound level
  Future<double> getAverageSoundLevel();
}

class MicrophoneDataSourceImpl implements MicrophoneDataSource {
  final List<double> _soundLevelBuffer = [];
  bool _isRecording = false;
  Timer? _recordingTimer;

  @override
  Future<void> startRecording() async {
    try {
      _isRecording = true;
      _soundLevelBuffer.clear();

      // Mock: Simulate sound level recording
      // In real implementation, use microphone plugin
      _recordingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (_isRecording) {
          // Mock sound level (0-100 dB)
          final mockLevel = 20.0 + (30.0 * (0.5 - 0.5)); // 20-50 dB range
          _soundLevelBuffer.add(mockLevel);
        }
      });
    } catch (e) {
      throw SensorException('Failed to start microphone: $e');
    }
  }

  @override
  Future<void> stopRecording() async {
    _isRecording = false;
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  @override
  Future<List<double>> getSoundLevels() async {
    return List.from(_soundLevelBuffer);
  }

  @override
  Future<double> getAverageSoundLevel() async {
    if (_soundLevelBuffer.isEmpty) return 0.0;
    final sum = _soundLevelBuffer.reduce((a, b) => a + b);
    return sum / _soundLevelBuffer.length;
  }
}
