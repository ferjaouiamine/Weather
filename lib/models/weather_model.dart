class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double windSpeed;
  final int humidity;
  final int pressure;
  final List<DailyForecast> forecasts;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.forecasts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dailyForecasts = json['forecasts'] ?? [];
    List<DailyForecast> forecasts = dailyForecasts.map((day) {
      return DailyForecast.fromJson(day);
    }).toList();

    return WeatherData(
      cityName: json['name'] ?? 'Ville inconnue',
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      windSpeed: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      forecasts: forecasts,
    );
  }
}

class DailyForecast {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String icon;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final date = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    return DailyForecast(
      date: '${date.day}/${date.month}/${date.year}',
      minTemp: json['temp']['min'].toDouble(),
      maxTemp: json['temp']['max'].toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}
