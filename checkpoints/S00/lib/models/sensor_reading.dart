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
