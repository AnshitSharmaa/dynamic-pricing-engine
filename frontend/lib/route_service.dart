import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteService {
  static const String apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjA1MmZjNjQ4NmQ0ODQ5Mjg4YWQwZmFlODIyYzNlNzI1IiwiaCI6Im11cm11cjY0In0=';

  static Future<Map<String, dynamic>?> getRoute({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car'),
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "coordinates": [
          [startLon, startLat],
          [endLon, endLat],
        ],
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    final summary = data["routes"][0]["summary"];

    return {
      "distance": summary["distance"] / 1000,
      "duration": summary["duration"] / 60,
    };
  }
}
