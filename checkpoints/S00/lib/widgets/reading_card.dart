import 'package:flutter/material.dart';

import '../models/sensor_reading.dart';

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
