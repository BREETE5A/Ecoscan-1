import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class WeatherData {
  final String city;
  final double temp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int uvIndex;
  final String condition;

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

// SharedPreferences keys
const _kWeatherCity = 'weather_city';
const _kLastLat     = 'last_gps_lat';
const _kLastLng     = 'last_gps_lng';

class WeatherService {
  static const _apiKey = ApiConstants.owmKey;
  static const _base   = 'https://api.openweathermap.org/data/2.5';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Même logique que AirQualityService : toujours essayer le GPS,
  /// utiliser les coordonnées mémorisées en fallback, jamais bloquer l'UI.
  static Future<WeatherData?> fetchByLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      double? userLat;
      double? userLng;

      try {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }

        final gpsGranted = perm == LocationPermission.whileInUse ||
            perm == LocationPermission.always;

        if (gpsGranted) {
          final serviceOn = await Geolocator.isLocationServiceEnabled();
          if (serviceOn) {
            // 1. Dernière position connue (instantané — cache Android)
            try {
              final last = await Geolocator.getLastKnownPosition();
              if (last != null) {
                userLat = last.latitude;
                userLng = last.longitude;
              }
            } catch (_) {}

            // 2. Position fraîche en parallèle (même timeout que AirQuality : 8s)
            try {
              final fresh = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.medium,
                  timeLimit: Duration(seconds: 8),
                ),
              );
              // La position fraîche prend toujours le dessus
              userLat = fresh.latitude;
              userLng = fresh.longitude;
            } catch (_) {}

            if (userLat != null && userLng != null) {
              await prefs.setDouble(_kLastLat, userLat);
              await prefs.setDouble(_kLastLng, userLng);
            }
          }
        }
      } catch (_) {}

      // Fallback : coordonnées mémorisées (partagées avec AirQualityService)
      userLat ??= prefs.getDouble(_kLastLat);
      userLng ??= prefs.getDouble(_kLastLng);

      if (userLat != null && userLng != null) {
        final data = await _fetchCoords(userLat, userLng);
        if (data != null) {
          await prefs.setString(_kWeatherCity, data.city);
          return data;
        }
      }

      // Dernier recours : ville en cache ou Casablanca
      final city = prefs.getString(_kWeatherCity);
      return fetchByCity(city ?? 'Casablanca');
    } catch (_) {
      return fetchByCity('Casablanca');
    }
  }

  static Future<WeatherData?> fetchByCity(String city) =>
      _fetch('q=$city,MA');

  static Future<WeatherData?> _fetchCoords(double lat, double lng) =>
      _fetch('lat=$lat&lon=$lng');

  static Future<WeatherData?> _fetch(String query) async {
    try {
      final r = await _dio.get(
        '$_base/weather?$query&appid=$_apiKey&units=metric&lang=fr',
      );
      final d = r.data;
      return WeatherData(
        city:        d['name'] as String? ?? 'Maroc',
        temp:        (d['main']['temp'] as num).toDouble(),
        description: d['weather'][0]['description'] as String? ?? '',
        icon:        d['weather'][0]['icon'] as String? ?? '01d',
        humidity:    (d['main']['humidity'] as num).toInt(),
        windSpeed:   (d['wind']['speed'] as num).toDouble(),
        uvIndex:     0,
        condition:   d['weather'][0]['main'] as String? ?? 'Clear',
      );
    } catch (_) {
      return null;
    }
  }
}
