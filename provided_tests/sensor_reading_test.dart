import 'package:flutter_test/flutter_test.dart';
import 'package:lab07_sensor_provider/models/sensor_reading.dart';

Map<String, dynamic> validJson() => {
       'temperature_2m': 23.5,
       'relative_humidity_2m': 55,
       'wind_speed_10m': 4,
       'time': '2026-10-25T10:00',
    };

void main() {
  test('JSON int와 double을 double 필드로 변환한다', () {
    final reading = SensorReading.fromCurrentJson(validJson());
    expect(reading.temperatureC, 23.5);
    expect(reading.humidityPercent, 55.0);
    expect(reading.windKmh, 4.0);
    expect(reading.humidityPercent, isA<double>());
    expect(reading.sourceTime, '2026-10-25T10:00');
  });

    test('빠진 숫자 값은 null 반환이 아니라 TypeError다', () {
      final json = validJson()..remove('temperature_2m');
      expect(() => SensorReading.fromCurrentJson(json), throwsA(isA<TypeError>()));
    });

    test('숫자처럼 보이는 문자열도 자동 파싱하지 않는다', () {
      final json = validJson()..['temperature_2m'] = '23.5';
      expect(() => SensorReading.fromCurrentJson(json), throwsA(isA<TypeError>()));
    });

    test('time이 없으면 TypeError를 발생시킨다', () {
      final json = validJson()..remove('time');
      expect(() => SensorReading.fromCurrentJson(json), throwsA(isA<TypeError>()));
    });
}
