import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenMeteoService {
  const OpenMeteoService();

    Future<Map<String, dynamic>> fetchCurrentJson() async {
      // final uri = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=36.35&longitude=127.38&current=temperature_2m,relative_humidity_2m,wind_speed_10m&timezone=Asia/Seoul');
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
