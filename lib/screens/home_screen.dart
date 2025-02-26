import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  // 🔹 Obtenir la météo par localisation
  Future<void> _fetchWeatherByLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('La localisation est désactivée.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissions refusées.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weather = await WeatherApi.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      setState(() => _weatherData = weather);
    } catch (e) {
      _showErrorSnackBar('Erreur de localisation : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Obtenir la météo par nom de ville
  Future<void> _fetchWeatherByCity() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final weather = await WeatherApi.fetchWeatherByCity(
        _searchController.text,
      );
      setState(() => _weatherData = weather);
    } catch (e) {
      _showErrorSnackBar('Ville non trouvée. Veuillez réessayer.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // 🔹 Date et heure formatées
  String _formatDateTime() {
    return DateFormat('EEEE d MMMM, HH:mm', 'fr_FR').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        title: const Text('🌤️ WeatherApp', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWeatherByLocation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Champ de recherche avec design amélioré
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  hintText: '🔍 Rechercher une ville...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _fetchWeatherByCity,
                  ),
                ),
              ),
            ),

            // ✅ Affichage des données météo
            _isLoading
                ? const SpinKitFadingCircle(color: Colors.white, size: 50.0)
                : _weatherData != null
                    ? WeatherCard(weatherData: _weatherData!)
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune donnée météo disponible.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

// 🌦️ Widget personnalisé pour l'affichage des données météo
class WeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              weatherData.cityName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${weatherData.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              weatherData.description,
              style: const TextStyle(fontSize: 22, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Image.network(
              'https://openweathermap.org/img/wn/${weatherData.icon}@2x.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile(
                    Icons.wind_power,
                    '${weatherData.windSpeed} km/h',
                    'Vent',
                  ),
                  _buildInfoTile(
                    Icons.water_drop,
                    '${weatherData.humidity}%',
                    'Humidité',
                  ),
                  _buildInfoTile(
                    Icons.thermostat,
                    '${weatherData.pressure} hPa',
                    'Pression',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 34),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
