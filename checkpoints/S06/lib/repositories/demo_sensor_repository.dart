import '../models/sensor_reading.dart';
import 'sensor_repository.dart';

class DemoSensorRepository implements SensorRepository {
  DemoSensorRepository({this.failEveryOtherRequest = false});

    final bool failEveryOtherRequest;
    int _requestCount = 0;

    @override
    Future<SensorReading> fetchLatest() async {
      final requestNumber = ++_requestCount;
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (failEveryOtherRequest && requestNumber.isEven) {
        throw StateError('모의 네트워크 장애: ${requestNumber}번째 요청');
      }

        return SensorReading(
           temperatureC: 21.0 + requestNumber * 0.3,
           humidityPercent: 58.0 + (requestNumber % 12),
           windKmh: 4.0 + requestNumber * 0.4,
           sourceTime: DateTime.now().toIso8601String().substring(0, 16),
        );
    }
}
