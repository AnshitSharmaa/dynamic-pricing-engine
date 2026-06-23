import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<Map<String, double>?> getCoordinates(String location) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'DynamicPricingEngine'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data.isEmpty) {
      return null;
    }

    return {
      "lat": double.parse(data[0]["lat"]),
      "lon": double.parse(data[0]["lon"]),
    };
  }
}
