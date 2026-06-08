import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AirQualityError { gpsDisabled, permissionDenied, networkError }

class AirQualityResult {
  final AirQualityData? data;
  final AirQualityError? error;
  const AirQualityResult.success(this.data) : error = null;
  const AirQualityResult.failure(this.error) : data = null;
}

class AirQualityData {
  final int aqi;
  final String city;
  final String level, levelAr, levelEn, levelEs;
  final int color;
  final Map<String, double> pollutants;
  final String? detectedCity; // renseigné si les données viennent d'une ville de substitution

  const AirQualityData({
    required this.aqi, required this.city,
    required this.level, required this.levelAr,
    required this.levelEn, required this.levelEs,
    required this.color, required this.pollutants,
    this.detectedCity,
  });

  bool get isRedirected => detectedCity != null && detectedCity != city;
}

// ── Villes marocaines (coords pour l'API OWM + affichage sélecteur) ───────────
const moroccanCities = [
  (name: 'Casablanca',  key: 'casablanca',  slug: 'casablanca',  lat: 33.5731, lng: -7.5898),
  (name: 'Rabat',       key: 'rabat',       slug: 'rabat',       lat: 34.0209, lng: -6.8416),
  (name: 'Marrakech',   key: 'marrakech',   slug: 'marrakech',   lat: 31.6295, lng: -7.9811),
  (name: 'Fès',         key: 'fes',         slug: 'fez',         lat: 34.0181, lng: -5.0078),
  (name: 'Tanger',      key: 'tanger',      slug: 'tangier',     lat: 35.7595, lng: -5.8340),
  (name: 'Agadir',      key: 'agadir',      slug: 'agadir',      lat: 30.4278, lng: -9.5981),
  (name: 'Meknès',      key: 'meknes',      slug: 'meknes',      lat: 33.8935, lng: -5.5473),
  (name: 'Oujda',       key: 'oujda',       slug: 'oujda',       lat: 34.6814, lng: -1.9086),
  (name: 'Tétouan',     key: 'tetouan',     slug: 'tetouan',     lat: 35.5889, lng: -5.3626),
  (name: 'Kénitra',     key: 'kenitra',     slug: 'kenitra',     lat: 34.2610, lng: -6.5802),
  (name: 'Safi',        key: 'safi',        slug: 'safi',        lat: 32.2994, lng: -9.2372),
  (name: 'Mohammedia',  key: 'mohammedia',  slug: 'mohammedia',  lat: 33.6861, lng: -7.3829),
];

// SharedPreferences keys
const _kCityKey      = 'aq_city_key';
const _kCityTs       = 'aq_city_ts';
const _kLastLat      = 'last_gps_lat';   // clés partagées avec weather_service
const _kLastLng      = 'last_gps_lng';
const _kCityRefreshMs = 1800000; // 30 min

class AirQualityService {
  // ── OpenWeatherMap Air Pollution API ──────────────────────────────────────
  // Avantage sur WAQI : coverage mondiale garantie par coordonnées GPS
  // Pas de station physique nécessaire — données satellite + modèle numérique
  static const _owmKey  = '40bbb318e5d3379c017f100b4a79b9b9';
  static const _owmBase = 'https://api.openweathermap.org/data/2.5';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // ── Point d'entrée principal ──────────────────────────────────────────────
  static Future<AirQualityResult> fetchWithStatus() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      String? cityKey = prefs.getString(_kCityKey);
      final lastTs    = prefs.getInt(_kCityTs) ?? 0;
      final cityStale = DateTime.now().millisecondsSinceEpoch - lastTs > _kCityRefreshMs;

      double? userLat;
      double? userLng;

      // ── GPS : détection de la position ────────────────────────────────────
      try {
        LocationPermission perm = await Geolocator.checkPermission();

        // Demande permission si jamais accordée (y compris relances)
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }

        final gpsGranted = perm == LocationPermission.whileInUse ||
                           perm == LocationPermission.always;

        if (gpsGranted && (cityKey == null || cityStale)) {
          final serviceOn = await Geolocator.isLocationServiceEnabled();
          if (serviceOn) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 8),
              ),
            );
            userLat = pos.latitude;
            userLng = pos.longitude;
            // Sauvegarde les dernières coordonnées GPS connues
            await prefs.setDouble(_kLastLat, userLat);
            await prefs.setDouble(_kLastLng, userLng);
            // Enregistre la ville marocaine la plus proche
            cityKey = _nearestCityKey(userLat, userLng);
            await prefs.setString(_kCityKey, cityKey);
            await prefs.setInt(_kCityTs, DateTime.now().millisecondsSinceEpoch);
          }
        } else if (gpsGranted) {
          // Cache encore frais : on peut quand même tenter le GPS si service actif
          final serviceOn = await Geolocator.isLocationServiceEnabled();
          if (serviceOn) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 5),
              ),
            );
            userLat = pos.latitude;
            userLng = pos.longitude;
            // Sauvegarde les dernières coordonnées GPS connues
            await prefs.setDouble(_kLastLat, userLat);
            await prefs.setDouble(_kLastLng, userLng);
          }
        }
      } catch (_) {
        // GPS échoue → utilise les dernières coordonnées mémorisées
      }

      // ── Résolution des coordonnées ────────────────────────────────────────
      // Si GPS indisponible, utilise les dernières coords GPS mémorisées
      if (userLat == null || userLng == null) {
        final savedLat = prefs.getDouble(_kLastLat);
        final savedLng = prefs.getDouble(_kLastLng);
        if (savedLat != null && savedLng != null) {
          userLat = savedLat;
          userLng = savedLng;
          // Met à jour la cityKey depuis les dernières coords si pas encore définie
          cityKey ??= _nearestCityKey(userLat, userLng);
        }
      }

      cityKey ??= 'casablanca';
      final city = moroccanCities.where((c) => c.key == cityKey).firstOrNull
                   ?? moroccanCities.first;

      // Utilise les coords GPS réelles (ou dernières mémorisées), sinon coords de la ville
      final lat = userLat ?? city.lat;
      final lng = userLng ?? city.lng;

      // Nom de la ville affichée (GPS → ville marocaine la plus proche)
      final displayCity = _nearestCityName(lat, lng);

      // ── Fetch qualité de l'air via OWM Air Pollution API ─────────────────
      final data = await _fetchOWM(lat, lng, displayCity);

      if (data != null) return AirQualityResult.success(data);
      return AirQualityResult.failure(AirQualityError.networkError);

    } on LocationServiceDisabledException {
      return AirQualityResult.failure(AirQualityError.gpsDisabled);
    } catch (_) {
      return AirQualityResult.failure(AirQualityError.networkError);
    }
  }

  // Compatibilité avec environment_providers.dart
  static Future<AirQualityData?> fetchByLocation() async {
    final r = await fetchWithStatus();
    return r.data;
  }

  // Fetch par clé de ville (depuis le sélecteur manuel)
  static Future<AirQualityData?> fetchByCityKey(String key) async {
    final city = moroccanCities.where((c) => c.key == key).firstOrNull
                 ?? moroccanCities.first;
    return _fetchOWM(city.lat, city.lng, city.name);
  }

  // ── OpenWeatherMap Air Pollution ──────────────────────────────────────────
  static Future<AirQualityData?> _fetchOWM(
      double lat, double lng, String cityName) async {
    try {
      final r = await _dio.get(
        '$_owmBase/air_pollution',
        queryParameters: {'lat': lat, 'lon': lng, 'appid': _owmKey},
      );
      final list = (r.data['list'] as List?)?.firstOrNull;
      if (list == null) return null;

      // OWM AQI : 1=Good 2=Fair 3=Moderate 4=Poor 5=Very Poor
      // Conversion vers une valeur AQI standard 0-500 pour affichage
      final owmAqi = (list['main']?['aqi'] as num?)?.toInt() ?? 0;
      if (owmAqi <= 0) return null;
      final aqi = _owmToAqi(owmAqi);

      final comp = list['components'] as Map? ?? {};
      final pollutants = <String, double>{
        'PM2.5': (comp['pm2_5'] as num?)?.toDouble() ?? 0,
        'PM10':  (comp['pm10']  as num?)?.toDouble() ?? 0,
        'NO₂':   (comp['no2']   as num?)?.toDouble() ?? 0,
        'O₃':    (comp['o3']    as num?)?.toDouble() ?? 0,
        'CO':    (comp['co']    as num?)?.toDouble() ?? 0,
        'SO₂':   (comp['so2']   as num?)?.toDouble() ?? 0,
        'NH₃':   (comp['nh3']   as num?)?.toDouble() ?? 0,
      };

      return _buildData(aqi, cityName, pollutants);
    } catch (_) {
      return null;
    }
  }

  // Convertit OWM AQI (1-5) vers valeur numérique affichable
  static int _owmToAqi(int owm) {
    switch (owm) {
      case 1: return 25;   // Good
      case 2: return 75;   // Fair → Modéré
      case 3: return 125;  // Moderate → Mauvais (sensibles)
      case 4: return 175;  // Poor → Mauvais
      case 5: return 250;  // Very Poor → Très mauvais
      default: return 0;
    }
  }

  // Construit l'objet AirQualityData avec niveau et couleur
  static AirQualityData _buildData(int aqi, String city,
      Map<String, double> pollutants) {
    String level, levelAr, levelEn, levelEs; int color;
    if      (aqi <= 50)  { level='Bon';               levelEn='Good';                  levelAr='جيد';           levelEs='Bueno';            color=0xFF00C853; }
    else if (aqi <= 100) { level='Modéré';             levelEn='Moderate';              levelAr='معتدل';         levelEs='Moderado';         color=0xFFFFAB00; }
    else if (aqi <= 150) { level='Mauvais (sensibles)';levelEn='Unhealthy (sensitive)'; levelAr='سيء (حساسون)';  levelEs='Malo (sensibles)'; color=0xFFFF6D00; }
    else if (aqi <= 200) { level='Mauvais';            levelEn='Unhealthy';             levelAr='غير صحي';       levelEs='No saludable';     color=0xFFD50000; }
    else if (aqi <= 300) { level='Très mauvais';       levelEn='Very unhealthy';        levelAr='سيء جداً';      levelEs='Muy no saludable'; color=0xFF6200EA; }
    else                 { level='Dangereux';           levelEn='Hazardous';             levelAr='خطر';           levelEs='Peligroso';        color=0xFF880E4F; }

    return AirQualityData(
      aqi: aqi, city: city,
      level: level, levelAr: levelAr, levelEn: levelEn, levelEs: levelEs,
      color: color, pollutants: pollutants,
    );
  }

  // Ville marocaine la plus proche des coordonnées
  static String _nearestCityKey(double lat, double lng) {
    ({String name, String key, String slug, double lat, double lng})? nearest;
    double minDist = double.infinity;
    for (final c in moroccanCities) {
      final d = (lat - c.lat) * (lat - c.lat) + (lng - c.lng) * (lng - c.lng);
      if (d < minDist) { minDist = d; nearest = c; }
    }
    return nearest?.key ?? 'casablanca';
  }

  static String _nearestCityName(double lat, double lng) {
    ({String name, String key, String slug, double lat, double lng})? nearest;
    double minDist = double.infinity;
    for (final c in moroccanCities) {
      final d = (lat - c.lat) * (lat - c.lat) + (lng - c.lng) * (lng - c.lng);
      if (d < minDist) { minDist = d; nearest = c; }
    }
    return nearest?.name ?? 'Casablanca';
  }
}
