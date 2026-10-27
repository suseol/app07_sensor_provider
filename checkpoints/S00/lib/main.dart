import 'package:flutter/material.dart';

import 'screens/sensor_dashboard_screen.dart';

void main() => runApp(const SensorApp());

class SensorApp extends StatelessWidget {
  const SensorApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
         debugShowCheckedModeBanner: false,
         title: '환경 데이터 대시보드',
         theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
         home: const SensorDashboardScreen(),
      );
    }
}
