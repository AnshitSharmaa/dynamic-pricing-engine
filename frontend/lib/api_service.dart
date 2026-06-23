import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>?> calculatePrice({
    required String vehicle,
    required double distance,
    required double load,
  }) async {
    final now = DateTime.now();

    String timeType = "normal";

    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      timeType = "weekend";
    } else if (now.hour >= 22 || now.hour < 6) {
      timeType = "night";
    } else if ((now.hour >= 7 && now.hour <= 10) ||
        (now.hour >= 17 && now.hour <= 21)) {
      timeType = "peak";
    }

    String routeType = "city";

    if (distance > 30) {
      routeType = "highway";
    } else if (distance > 10) {
      routeType = "industrial";
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "vehicle": vehicle,
        "distance": distance,
        "load": load,
        "route": routeType,
        "time_type": timeType,
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    return data["pricing"];
  }
}
