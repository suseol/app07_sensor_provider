import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab07_sensor_provider/models/sensor_reading.dart';
import 'package:lab07_sensor_provider/repositories/sensor_repository.dart';
import 'package:lab07_sensor_provider/viewmodels/sensor_dashboard_view_model.dart';

const sample = SensorReading(
   temperatureC: 23,
   humidityPercent: 55,
   windKmh: 5,
   sourceTime: '2026-10-25T10:00',
);

class FunctionRepository implements SensorRepository {
  FunctionRepository(this.fetch);
  final Future<SensorReading> Function() fetch;

    @override
    Future<SensorReading> fetchLatest() => fetch();
}

void main() {
  test('초기 상태는 데이터 없음, 오류 없음, 횟수 0이다', () {
    final vm = SensorDashboardViewModel(
       repository: FunctionRepository(() async => sample),
    );
    addTearDown(vm.dispose);
    expect(vm.reading, isNull);
    expect(vm.isLoading, isFalse);
    expect(vm.errorMessage, isNull);
    expect(vm.lastUpdated, isNull);
    expect(vm.successCount, 0);
    expect(vm.statusLabel, '대기');
  });

    test('요청 시작과 성공 완료에 알리고 성공 정보를 기록한다', () async {
      final completer = Completer<SensorReading>();
      final vm = SensorDashboardViewModel(
         repository: FunctionRepository(() => completer.future),
      );
      addTearDown(vm.dispose);
      var notifications = 0;
      vm.addListener(() => notifications++);

     final request = vm.refresh();
     expect(vm.isLoading, isTrue);
     expect(vm.statusLabel, '조회 중');
     expect(notifications, 1);
     completer.complete(sample);
     await request;

     expect(vm.reading, same(sample));
    expect(vm.isLoading, isFalse);
    expect(vm.lastUpdated, isNotNull);
    expect(vm.successCount, 1);
    expect(vm.statusLabel, '정상');
    expect(notifications, 2);
  });

  test('실패 시 이전 성공값을 유지하고 재시도하면 복구한다', () async {
    var attempts = 0;
    final vm = SensorDashboardViewModel(
       repository: FunctionRepository(() async {
         attempts++;
         if (attempts == 2) throw StateError('테스트 장애');
         return sample;
       }),
    );
    addTearDown(vm.dispose);

    await vm.refresh();
    final previousTime = vm.lastUpdated;
    await vm.refresh();
    expect(vm.reading, same(sample));
    expect(vm.lastUpdated, previousTime);
    expect(vm.successCount, 1);
    expect(vm.isLoading, isFalse);
    expect(vm.errorMessage, contains('테스트 장애'));
    expect(vm.statusLabel, '오류');

    await vm.refresh();
    expect(vm.successCount, 2);
    expect(vm.errorMessage, isNull);
    expect(vm.statusLabel, '정상');
  });

  test('첫 조회 실패 시에도 로딩을 해제한다', () async {
    final vm = SensorDashboardViewModel(
       repository: FunctionRepository(() async => throw StateError('첫 실패')),
    );
    addTearDown(vm.dispose);
    await vm.refresh();
    expect(vm.reading, isNull);
    expect(vm.lastUpdated, isNull);
    expect(vm.successCount, 0);
    expect(vm.isLoading, isFalse);
    expect(vm.statusLabel, '오류');
  });

  test('진행 중 중복 호출은 Repository를 다시 부르지 않는다', () async {
    final completer = Completer<SensorReading>();
    var calls = 0;
    final vm = SensorDashboardViewModel(
       repository: FunctionRepository(() {
         calls++;
         return completer.future;
       }),
    );
    addTearDown(vm.dispose);
    final first = vm.refresh();
    await vm.refresh();
    expect(calls, 1);
      completer.complete(sample);
      await first;
      expect(vm.successCount, 1);
    });

    test('dispose 이후 완료된 성공 응답은 상태를 갱신하지 않는다', () async {
      final completer = Completer<SensorReading>();
      final vm = SensorDashboardViewModel(
         repository: FunctionRepository(() => completer.future),
      );
      final request = vm.refresh();
      vm.dispose();
      completer.complete(sample);
      await request;
      expect(vm.reading, isNull);
      expect(vm.successCount, 0);
    });

    test('dispose 이후 완료된 실패 응답도 알림을 보내지 않는다', () async {
      final completer = Completer<SensorReading>();
      final vm = SensorDashboardViewModel(
         repository: FunctionRepository(() => completer.future),
      );
      final request = vm.refresh();
      vm.dispose();
      completer.completeError(StateError('늦은 실패'));
      await request;
      expect(vm.errorMessage, isNull);
    });

    test('dispose 이후 새 요청을 시작하지 않는다', () async {
      var calls = 0;
      final vm = SensorDashboardViewModel(
         repository: FunctionRepository(() async {
           calls++;
           return sample;
         }),
      );
      vm.dispose();
      await vm.refresh();
      expect(calls, 0);
    });
}
