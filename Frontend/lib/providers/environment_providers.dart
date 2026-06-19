import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/air_quality_service.dart';
import '../services/weather_service.dart';

// Synchronisation automatique toutes les 15 min pour la météo, 30 min pour la qualité de l'air
final weatherEnvProvider = StreamProvider<WeatherData?>((ref) async* {
  yield await WeatherService.fetchByLocation();
  await for (final _ in Stream.periodic(const Duration(minutes: 15))) {
    yield await WeatherService.fetchByLocation();
  }
});

final airQualityEnvProvider = StreamProvider<AirQualityData?>((ref) async* {
  yield await AirQualityService.fetchByLocation();
  await for (final _ in Stream.periodic(const Duration(minutes: 30))) {
    yield await AirQualityService.fetchByLocation();
  }
});
