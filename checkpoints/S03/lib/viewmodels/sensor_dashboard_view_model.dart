import 'package:flutter/foundation.dart';

import '../models/sensor_reading.dart';
import '../services/open_meteo_service.dart';

class SensorDashboardViewModel extends ChangeNotifier {
  SensorDashboardViewModel({required this.service});

  final OpenMeteoService service;
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


  Future<void> refresh() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

      try {
        final json = await service.fetchCurrentJson();
        if (_disposed) return;
        _reading = SensorReading.fromCurrentJson(json);
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
