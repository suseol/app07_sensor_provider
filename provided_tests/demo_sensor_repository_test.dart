import 'package:flutter_test/flutter_test.dart';
import 'package:lab07_sensor_provider/repositories/demo_sensor_repository.dart';

void main() {
  test('기본 Demo는 연속 요청에 성공한다', () async {
    final repo = DemoSensorRepository();
    expect((await repo.fetchLatest()).temperatureC, closeTo(21.3, 0.001));
    expect((await repo.fetchLatest()).temperatureC, closeTo(21.6, 0.001));
  });

    test('번갈아 실패 옵션은 2번째 실패 후 3번째 성공한다', () async {
      final repo = DemoSensorRepository(failEveryOtherRequest: true);
      expect((await repo.fetchLatest()).temperatureC, closeTo(21.3, 0.001));
      await expectLater(repo.fetchLatest(), throwsStateError);
      expect((await repo.fetchLatest()).temperatureC, closeTo(21.9, 0.001));
    });
}
