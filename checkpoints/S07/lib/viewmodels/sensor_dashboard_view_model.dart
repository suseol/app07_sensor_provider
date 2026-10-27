import 'package:flutter/foundation.dart';

import '../models/sensor_reading.dart';
import '../repositories/sensor_repository.dart';

class SensorDashboardViewModel extends ChangeNotifier {
  SensorDashboardViewModel({required this.repository});

  final SensorRepository repository;
  SensorReading? _reading;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  int _successCount = 0;
  bool _disposed = false;

  SensorReading? get reading => _reading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  int get successCount => _successCount;

  String get statusLabel {
    if (_isLoading) return '조회 중';
    if (_errorMessage != null) return '오류';
    if (_reading != null) return '정상';
    return '대기';
  }

  Future<void> refresh() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

      try {
        final result = await repository.fetchLatest();
        if (_disposed) return;
        _reading = result;
        _lastUpdated = DateTime.now();
        _successCount++;
      } catch (error) {
        if (!_disposed) _errorMessage = error.toString();
      } finally {
        _isLoading = false;
        if (!_disposed) notifyListeners();
      }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    }
}
