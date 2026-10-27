import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lab07_sensor_provider/models/sensor_reading.dart';
import 'package:lab07_sensor_provider/repositories/sensor_repository.dart';
import 'package:lab07_sensor_provider/screens/sensor_dashboard_screen.dart';
import 'package:lab07_sensor_provider/viewmodels/sensor_dashboard_view_model.dart';

const sample = SensorReading(
   temperatureC: 23,
   humidityPercent: 55,
   windKmh: 5,
   sourceTime: '2026-10-25T10:00',
);

class StepRepository implements SensorRepository {
  int attempts = 0;

    @override
    Future<SensorReading> fetchLatest() async {
      attempts++;
      if (attempts == 2) throw StateError('테스트 장애');
      return sample;
    }
}

class PendingRepository implements SensorRepository {
  final completer = Completer<SensorReading>();

    @override
    Future<SensorReading> fetchLatest() => completer.future;
}

void main() {
  testWidgets('성공 후 실패해도 카드를 유지하고 재시도하면 복구한다', (tester) async {
    final repository = StepRepository();
    await tester.pumpWidget(
       ChangeNotifierProvider(
          create: (_) => SensorDashboardViewModel(repository: repository)..refresh(),
          child: const MaterialApp(home: SensorDashboardScreen()),
       ),
    );
    await tester.pumpAndSettle();
    expect(find.text('상태: 정상'), findsOneWidget);
    expect(find.text('23.0 °C'), findsOneWidget);

     await tester.tap(find.text('새로고침'));
     await tester.pumpAndSettle();
     expect(find.text('상태: 오류'), findsOneWidget);
     expect(find.text('23.0 °C'), findsOneWidget);
     expect(find.textContaining('테스트 장애'), findsOneWidget);

      await tester.tap(find.text('새로고침'));
      await tester.pumpAndSettle();
      expect(find.text('상태: 정상'), findsOneWidget);
      expect(find.textContaining('테스트 장애'), findsNothing);
      expect(repository.attempts, 3);
    });

    testWidgets('대기 중에는 버튼이 비활성화되고 완료 후 활성화된다', (tester) async {
      final repository = PendingRepository();
      await tester.pumpWidget(
         ChangeNotifierProvider(
            create: (_) => SensorDashboardViewModel(repository: repository)..refresh(),
            child: const MaterialApp(home: SensorDashboardScreen()),
         ),
      );
      // 진행 막대가 반복 애니메이션이므로 대기 중 pumpAndSettle은 사용하지 않는다.
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final loadingButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(loadingButton.onPressed, isNull);

      repository.completer.complete(sample);
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      final readyButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(readyButton.onPressed, isNotNull);
    });
}
