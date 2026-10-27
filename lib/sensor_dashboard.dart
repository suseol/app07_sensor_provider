import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorReading {
  const SensorReading({
    required this.temperatureC,
    required this.humidityPercent,
    required this.windKmh,
    required this.sourceTime,
  });

    final double temperatureC;
    final double humidityPercent;
    final double windKmh;
    final String sourceTime;

    factory SensorReading.fromCurrentJson(Map<String, dynamic> json) {
      return SensorReading(
         temperatureC: (json['temperature_2m'] as num).toDouble(),
         humidityPercent: (json['relative_humidity_2m'] as num).toDouble(),
         windKmh: (json['wind_speed_10m'] as num).toDouble(),
         sourceTime: json['time'] as String,
      );
    }
}

class OpenMeteoService {
  const OpenMeteoService();

    Future<Map<String, dynamic>> fetchCurrentJson() async {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '36.35',
        'longitude': '127.38',
        'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m',
        'timezone': 'Asia/Seoul',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('잘못된 응답 형식');
      }
      final current = decoded['current'];
      if (current is! Map<String, dynamic>) {
        throw const FormatException('current 데이터가 없음');
      }
      return current;
    }
}

class ReadingCard extends StatelessWidget {
  const ReadingCard({super.key, required this.reading});

    final SensorReading reading;

    @override
    Widget build(BuildContext context) {
      return Card(
         child: Column(
            children: [
               ListTile(
                 leading: const Icon(Icons.thermostat),
                 title: const Text('기온'),
                 trailing: Text('${reading.temperatureC.toStringAsFixed(1)} °C'),
               ),
               ListTile(
                 leading: const Icon(Icons.water_drop_outlined),
                 title: const Text('습도'),
                 trailing: Text('${reading.humidityPercent.toStringAsFixed(0)} %'),
               ),
               ListTile(
                 leading: const Icon(Icons.air),
                 title: const Text('풍속'),
                 trailing: Text('${reading.windKmh.toStringAsFixed(1)} km/h'),
               ),
               Padding(
                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                 child: Text('자료 기준 시각: ${reading.sourceTime}'),
               ),
            ],
         ),
      );
    }
}

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
          final result = SensorReading.fromCurrentJson(json);
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
