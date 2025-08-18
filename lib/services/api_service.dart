import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectconvert/modelflight/flight_model.dart';

class ApiService {
  static const String url = "http://103.214.233.90/result.json";

  static Future<FlightResponse?> fetchFlights() async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Print the entire JSON
        print("Full JSON: $data");

        // If it's a list of objects
        if (data is List) {
          print("First item keys: ${data.first.keys}");
        }

        // If it's a map
        if (data is Map) {
          print("Top-level keys: ${data.keys}");
        }
        return FlightResponse.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      print("API error: $e");
    }
    return null;
  }
}
