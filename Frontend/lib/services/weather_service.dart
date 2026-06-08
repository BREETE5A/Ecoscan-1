import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
const _kWeatherCity  = 'weather_city';
const _kWeatherTs    = 'weather_city_ts';
const _kLastLat      = 'last_gps_lat';
const _kLastLng      = 'last_gps_lng';
// Refresh GPS-based city at most once per hour
const _kCityRefreshMs = 3600000;

class WeatherService {
  static const _apiKey = '40bbb318e5d3379c017f100b4a79b9b9';
  static const _base   = 'https://api.openweathermap.org/data/2.5';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<WeatherData?> fetchByLocation() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      String? city = prefs.getString(_kWeatherCity);
      // lastTs et cityStale conservés pour usage futur (sync conditionnel)
    // ignore: unused_local_variable
    final cityStale = DateTime.now().millisecondsSinceEpoch - (prefs.getInt(_kWeatherTs) ?? 0) > _kCityRefreshMs;

      // ── GPS : mise à jour de la ville ─────────────────────────────────────
      // Demande la permission uniquement au premier lancement (pas de cache).
      // Ensuite, utilise la permission existante silencieusement.
      try {
        LocationPermission perm = await Geolocator.checkPermission();

        if (perm == LocationPermission.denied && city == null) {
          // Demande permission uniquement au tout premier lancement
          perm = await Geolocator.requestPermission();
        }

        final canUseGps = perm == LocationPermission.whileInUse ||
                          perm == LocationPermission.always;

        if (canUseGps) {
          // Si GPS dispo : toujours essayer (pas de gate 1h) pour avoir la position réelle
          final serviceOn = await Geolocator.isLocationServiceEnabled();
          if (serviceOn) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 8),
              ),
            );
            // Sauvegarde les dernières coordonnées GPS connues
            await prefs.setDouble(_kLastLat, pos.latitude);
            await prefs.setDouble(_kLastLng, pos.longitude);
            final data = await _fetchCoords(pos.latitude, pos.longitude);
            if (data != null) {
              await prefs.setString(_kWeatherCity, data.city);
              return data;
            }
          }
        }
      } catch (_) {
        // GPS échoue → utilise les dernières coordonnées connues
      }

      // Utilise les dernières coordonnées GPS mémorisées si disponibles
      final lastLat = prefs.getDouble(_kLastLat);
      final lastLng = prefs.getDouble(_kLastLng);
      if (lastLat != null && lastLng != null) {
        final data = await _fetchCoords(lastLat, lastLng);
        if (data != null) {
          await prefs.setString(_kWeatherCity, data.city);
          return data;
        }
      }

      // Fallback final : ville en cache ou Casablanca
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
