import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';
import '../models/country.dart';

class RadioApi {
  static const String baseUrl = 'de2.api.radio-browser.info';

  Future<List<RadioStation>> fetchStations({
    String countryCode = 'IT',
    int limit = 100,
  }) async {
    final params = {
      'limit': limit.toString(),
      'countrycode': countryCode,
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true'
    };

    final uri = Uri.https(baseUrl, '/json/stations/search', params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RadioStation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }

  Future<List<Country>> fetchCountries() async {
    try {
      final response =
          await http.get(Uri.parse('https://flagcdn.com/it/codes.json'));

      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries
          .map((entry) =>
              Country(code: entry.key.toLowerCase(), name: entry.value))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Failed to load countries: $e');
    }
  }
}
