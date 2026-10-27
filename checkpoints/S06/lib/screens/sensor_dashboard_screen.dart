import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sensor_dashboard_view_model.dart';
import '../widgets/reading_card.dart';

class SensorDashboardScreen extends StatelessWidget {
  const SensorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Dashboard 고정 영역 build');
    return Scaffold(
      appBar: AppBar(title: const Text('환경 데이터 대시보드')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           Text('대전 현재 환경', style: Theme.of(context).textTheme.titleLarge),
           const Text('Open-Meteo 날씨 모델 기반 자료 (실물 센서 측정 아님)'),
           const SizedBox(height: 16),
           Consumer<SensorDashboardViewModel>(
             builder: (context, vm, child) {
               debugPrint('Consumer 데이터 영역 build');
               return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     if (vm.isLoading) const LinearProgressIndicator(),
                     if (vm.reading != null) ReadingCard(reading: vm.reading!),
                     Text(
                        '마지막 성공: '
                        '${vm.lastUpdated == null ? "없음" : TimeOfDay.fromDateTime(vm.lastUpdated!).format(context)}'
                        ' / 성공 횟수: ${vm.successCount}',
                     ),
                     if (vm.errorMessage != null)
                        Text(
                           '조회 실패: ${vm.errorMessage}',
                           style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                     const SizedBox(height: 16),
                     FilledButton.icon(
                        onPressed: vm.isLoading
                             ? null
                             : () => context.read<SensorDashboardViewModel>().refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('새로고침'),
                     ),
                  ],
               );
             },
           ),
        ],
          ),
        );
    }
}
