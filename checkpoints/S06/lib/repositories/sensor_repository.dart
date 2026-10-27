import '../models/sensor_reading.dart';
import '../services/open_meteo_service.dart';

abstract class SensorRepository {
  Future<SensorReading> fetchLatest();
}

class OpenMeteoSensorRepository implements SensorRepository {
  const OpenMeteoSensorRepository({required this.service});

    final OpenMeteoService service;

    @override
    Future<SensorReading> fetchLatest() async {
      final json = await service.fetchCurrentJson();
      return SensorReading.fromCurrentJson(json);
    }
}
