import 'package:flutter_test/flutter_test.dart';
import 'package:lab07_sensor_provider/repositories/sensor_repository.dart';
import 'package:lab07_sensor_provider/services/open_meteo_service.dart';

class FakeOpenMeteoService extends OpenMeteoService {
  FakeOpenMeteoService(this.response, {this.shouldFail = false});

    final Map<String, dynamic> response;
    final bool shouldFail;

    @override
    Future<Map<String, dynamic>> fetchCurrentJson() async {
      if (shouldFail) throw StateError('서비스 실패');
      return response;
    }
}

void main() {
  test('Repository는 서비스 JSON을 SensorReading으로 제공한다', () async {
    final repo = OpenMeteoSensorRepository(
       service: FakeOpenMeteoService({
         'temperature_2m': 24,
         'relative_humidity_2m': 52,
         'wind_speed_10m': 6,
         'time': '2026-10-25T10:00',
       }),
    );
    final reading = await repo.fetchLatest();
    expect(reading.temperatureC, 24.0);
    expect(reading.humidityPercent, 52.0);
  });

    test('잘못된 JSON 변환 오류를 호출자에게 전달한다', () async {
      final repo = OpenMeteoSensorRepository(
         service: FakeOpenMeteoService({'time': '2026-10-25T10:00'}),
      );
      await expectLater(repo.fetchLatest(), throwsA(isA<TypeError>()));
    });

    test('서비스 오류도 호출자에게 전달한다', () async {
      final repo = OpenMeteoSensorRepository(
         service: FakeOpenMeteoService({}, shouldFail: true),
      );
      await expectLater(repo.fetchLatest(), throwsStateError);
    });
}
