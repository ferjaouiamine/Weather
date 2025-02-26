import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherApi {
  static const String apiKey =
      '74cabc9b96b25be54e2bcfa123cc4575'; // Remplace par ta clé API
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static Future<WeatherData> fetchWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  static Future<WeatherData> fetchWeatherByCity(String cityName) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ville non trouvée');
    }
  }
}
