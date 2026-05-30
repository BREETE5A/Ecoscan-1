import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/air_quality_service.dart';
import '../services/weather_service.dart';

// Providers non-autoDispose → données gardées en cache pendant toute la session
final weatherEnvProvider = FutureProvider<WeatherData?>(
  (ref) => WeatherService.fetchByLocation(),
);

final airQualityEnvProvider = FutureProvider<AirQualityData?>(
  (ref) => AirQualityService.fetchByLocation(),
);
