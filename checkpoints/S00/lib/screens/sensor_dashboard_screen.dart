import 'package:flutter/material.dart';

import '../models/sensor_reading.dart';
import '../services/open_meteo_service.dart';
import '../widgets/reading_card.dart';

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({super.key});

    @override
    State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  final _service = const OpenMeteoService();
  SensorReading? _reading;
  bool _isLoading = false;
  String? _errorMessage;

    @override
    void initState() {
      super.initState();
      _refresh();
    }

    Future<void> _refresh() async {
      setState(() {
        _isLoading = true;
          _errorMessage = null;
        });

        try {
          final json = await _service.fetchCurrentJson();
      debugPrint('JSON 데이터: $json');
          final result = SensorReading.fromCurrentJson(json);
      debugPrint('변환된 기온: ${result.temperatureC}');
          if (!mounted) return;
          setState(() {
            _reading = result;
            _isLoading = false;
          });
        } catch (error) {
          if (!mounted) return;
          setState(() {
            _errorMessage = error.toString();
            _isLoading = false;
          });
        }
    }

    @override
    Widget build(BuildContext context) {
      debugPrint('Dashboard 전체 build');
      return Scaffold(
         appBar: AppBar(title: const Text('환경 데이터 대시보드')),
         body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               Text('대전 현재 환경', style: Theme.of(context).textTheme.titleLarge),
               const Text('Open-Meteo 날씨 모델 기반 자료 (실물 센서 측정 아님)'),
               const SizedBox(height: 16),
               if (_isLoading) const LinearProgressIndicator(),
               if (_reading != null) ReadingCard(reading: _reading!),
               if (_errorMessage != null)
                 Text(
                   '조회 실패: $_errorMessage',
                   style: TextStyle(color: Theme.of(context).colorScheme.error),
                 ),
               const SizedBox(height: 16),
               FilledButton.icon(
                 onPressed: _isLoading ? null : _refresh,
                 icon: const Icon(Icons.refresh),
                 label: const Text('새로고침'),
               ),
            ],
         ),
      );
    }
}
