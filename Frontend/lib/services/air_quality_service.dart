import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

// ── Résultat typé ─────────────────────────────────────────────────────────────
enum AirQualityError { gpsDisabled, permissionDenied, networkError }

class AirQualityResult {
  final AirQualityData? data;
  final AirQualityError? error;
  const AirQualityResult.success(this.data) : error = null;
  const AirQualityResult.failure(this.error) : data = null;
}

// ── Modèle de données ─────────────────────────────────────────────────────────
class AirQualityData {
  final int aqi;
  final String city;
  final String level, levelAr, levelEn, levelEs;
  final int color;
  final Map<String, double> pollutants;

  const AirQualityData({
    required this.aqi, required this.city,
    required this.level, required this.levelAr,
    required this.levelEn, required this.levelEs,
    required this.color, required this.pollutants,
  });
}

// ── Villes marocaines avec coords GPS ────────────────────────────────────────
// (on utilise les coords pour l'API geo, pas le nom — plus fiable)
const moroccanCities = [
  (name: 'Casablanca',  key: 'casablanca',  lat: 33.5731, lng: -7.5898),
  (name: 'Rabat',       key: 'rabat',       lat: 34.0209, lng: -6.8416),
  (name: 'Marrakech',   key: 'marrakech',   lat: 31.6295, lng: -7.9811),
  (name: 'Fès',         key: 'fes',         lat: 34.0181, lng: -5.0078),
  (name: 'Tanger',      key: 'tangier',     lat: 35.7595, lng: -5.8340),
  (name: 'Agadir',      key: 'agadir',      lat: 30.4278, lng: -9.5981),
  (name: 'Meknès',      key: 'meknes',      lat: 33.8935, lng: -5.5473),
  (name: 'Oujda',       key: 'oujda',       lat: 34.6814, lng: -1.9086),
  (name: 'Tétouan',     key: 'tetouan',     lat: 35.5889, lng: -5.3626),
  (name: 'Kénitra',     key: 'kenitra',     lat: 34.2610, lng: -6.5802),
  (name: 'Safi',        key: 'safi',        lat: 32.2994, lng: -9.2372),
  (name: 'Mohammedia',  key: 'mohammedia',  lat: 33.6861, lng: -7.3829),
  (name: 'Béni Mellal', key: 'beni-mellal', lat: 32.3372, lng: -6.3498),
  (name: 'Nador',       key: 'nador',       lat: 35.1681, lng: -2.9287),
  (name: 'Laâyoune',    key: 'laayoune',    lat: 27.1253, lng:-13.1625),
  (name: 'Dakhla',      key: 'dakhla',      lat: 23.7136, lng:-15.9355),
];

// ── Service ───────────────────────────────────────────────────────────────────
class AirQualityService {
  static const _token = '9fa2c3ace89df496e9a41e335d9aff90d7664ad0';
  static const _base  = 'https://api.waqi.info';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
  ));

  // Mots-clés indiquant un résultat non-marocain
  static bool _isNonMoroccan(String city) {
    const keywords = ['spain', 'españa', 'ceuta', 'melilla', 'gibraltar',
      'algeri', 'mauritani', 'sahara espag'];
    final lower = city.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }

  // Ville marocaine la plus proche des coordonnées GPS
  static String _nearestCityKey(double lat, double lng) {
    ({String name, String key, double lat, double lng})? nearest;
    double minDist = double.infinity;
    for (final c in moroccanCities) {
      final d = (lat - c.lat) * (lat - c.lat) + (lng - c.lng) * (lng - c.lng);
      if (d < minDist) { minDist = d; nearest = c; }
    }
    return nearest?.key ?? 'casablanca';
  }

  // ── Point d'entrée principal ──────────────────────────────────────────────
  static Future<AirQualityResult> fetchWithStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return AirQualityResult.failure(AirQualityError.gpsDisabled);
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return AirQualityResult.failure(AirQualityError.permissionDenied);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Essai 1 : coordonnées GPS exactes
      final direct = await _fetchByCoords(pos.latitude, pos.longitude);
      if (direct != null && !_isNonMoroccan(direct.city)) {
        return AirQualityResult.success(direct);
      }

      // Essai 2 : ville marocaine la plus proche (si résultat = Espagne)
      final key = _nearestCityKey(pos.latitude, pos.longitude);
      final fallback = await fetchByCityKey(key);
      if (fallback != null) return AirQualityResult.success(fallback);

      // Essai 3 : Casablanca
      final casa = await fetchByCityKey('casablanca');
      if (casa != null) return AirQualityResult.success(casa);

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

  // Fetch par clé de ville (ex: 'rabat') → utilise les coordonnées GPS de la ville
  static Future<AirQualityData?> fetchByCityKey(String key) async {
    final city = moroccanCities.firstWhere(
      (c) => c.key == key,
      orElse: () => moroccanCities.first,
    );
    // On utilise les coords de la ville → retourne la vraie station locale
    return _fetchByCoords(city.lat, city.lng);
  }

  // Fetch par coordonnées GPS (endpoint le plus fiable)
  static Future<AirQualityData?> _fetchByCoords(double lat, double lng) async {
    try {
      final r = await _dio.get('$_base/feed/geo:$lat;$lng/?token=$_token');
      return _parse(r.data);
    } catch (_) {
      return null;
    }
  }

  // ── Parsing ───────────────────────────────────────────────────────────────
  static AirQualityData? _parse(dynamic data) {
    if (data == null || data['status'] != 'ok') return null;
    final d   = data['data'];
    final aqi = d['aqi'] as int? ?? 0;
    final city = d['city']?['name'] as String? ?? 'Maroc';

    final iaqi = d['iaqi'] as Map? ?? {};
    final pollutants = <String, double>{
      'PM2.5': (iaqi['pm25']?['v'] as num?)?.toDouble() ?? 0,
      'PM10':  (iaqi['pm10']?['v'] as num?)?.toDouble() ?? 0,
      'NO₂':   (iaqi['no2']?['v']  as num?)?.toDouble() ?? 0,
      'O₃':    (iaqi['o3']?['v']   as num?)?.toDouble() ?? 0,
    };

    String level, levelAr, levelEn, levelEs; int color;
    if      (aqi <= 50)  { level='Bon';               levelEn='Good';                  levelAr='جيد';           levelEs='Bueno';            color=0xFF00E400; }
    else if (aqi <= 100) { level='Modéré';             levelEn='Moderate';              levelAr='معتدل';         levelEs='Moderado';         color=0xFFFFFF00; }
    else if (aqi <= 150) { level='Mauvais (sensibles)';levelEn='Unhealthy (sensitive)'; levelAr='سيء (حساسون)';  levelEs='Malo (sensibles)'; color=0xFFFF7E00; }
    else if (aqi <= 200) { level='Mauvais';            levelEn='Unhealthy';             levelAr='غير صحي';       levelEs='No saludable';     color=0xFFFF0000; }
    else if (aqi <= 300) { level='Très mauvais';       levelEn='Very unhealthy';        levelAr='سيء جداً';      levelEs='Muy no saludable'; color=0xFF8F3F97; }
    else                 { level='Dangereux';           levelEn='Hazardous';             levelAr='خطر';           levelEs='Peligroso';        color=0xFF7E0023; }

    return AirQualityData(
      aqi: aqi, city: city,
      level: level, levelAr: levelAr, levelEn: levelEn, levelEs: levelEs,
      color: color, pollutants: pollutants,
    );
  }
}
