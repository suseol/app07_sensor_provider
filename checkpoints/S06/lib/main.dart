import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/demo_sensor_repository.dart';
import 'repositories/sensor_repository.dart';
import 'screens/sensor_dashboard_screen.dart';
import 'services/open_meteo_service.dart';
import 'viewmodels/sensor_dashboard_view_model.dart';

void main() {
  const useDemo = false;
  const failAlternate = false;

    final SensorRepository repository = useDemo
        ? DemoSensorRepository(failEveryOtherRequest: failAlternate)
        : const OpenMeteoSensorRepository(service: OpenMeteoService());

    runApp(
       ChangeNotifierProvider(
          create: (_) => SensorDashboardViewModel(
            repository: repository,
          )..refresh(),
          child: const SensorApp(),
       ),
    );
}

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
