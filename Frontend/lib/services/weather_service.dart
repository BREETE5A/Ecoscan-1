import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final String city;
  final double temp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int uvIndex;
  final String condition; // clear, clouds, rain, etc.

  const WeatherData({
    required this.city,
    required this.temp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.condition,
  });
}

class WeatherService {
  static const _apiKey = '40bbb318e5d3379c017f100b4a79b9b9';
  static const _base = 'https://api.openweathermap.org/data/2.5';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<WeatherData?> fetchByLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return fetchByCity('Casablanca');

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return fetchByCity('Casablanca');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      return _fetch('lat=${pos.latitude}&lon=${pos.longitude}');
    } catch (_) {
      return fetchByCity('Casablanca');
    }
  }

  static Future<WeatherData?> fetchByCity(String city) =>
      _fetch('q=$city,MA');

  static Future<WeatherData?> _fetch(String query) async {
    try {
      final r = await _dio.get(
        '$_base/weather?$query&appid=$_apiKey&units=metric&lang=fr',
      );
      final d = r.data;
      return WeatherData(
        city: d['name'] as String? ?? 'Maroc',
        temp: (d['main']['temp'] as num).toDouble(),
        description: d['weather'][0]['description'] as String? ?? '',
        icon: d['weather'][0]['icon'] as String? ?? '01d',
        humidity: (d['main']['humidity'] as num).toInt(),
        windSpeed: (d['wind']['speed'] as num).toDouble(),
        uvIndex: 0,
        condition: d['weather'][0]['main'] as String? ?? 'Clear',
      );
    } catch (_) {
      return null;
    }
  }
}
