import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class N8nService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: '${ApiConstants.n8nBaseUrl}/webhook',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Authorization': ApiConstants.n8nAuthHeader},
    ),
  );

  /// Déclenche le workflow "alerte-danger" après détection d'un déchet dangereux.
  /// [nom] prénom+nom, [email] email user, [typeDechet] catégorie EcoScan,
  /// [fcmToken] token FCM stocké dans Firestore
  static Future<void> alerteDanger({
    required String nom,
    required String email,
    required String typeDechet,
    required String fcmToken,
  }) async {
    try {
      await _dio.post('/ecoscan/alerte-danger', data: {
        'nom': nom,
        'email': email,
        'type_dechet': typeDechet,
        'fcm_token': fcmToken,
      });
    } catch (_) {
      // Fire & forget — ne bloque pas l'UI si n8n est inaccessible
    }
  }

  /// Déclenche le workflow "bienvenue" après inscription réussie.
  static Future<void> bienvenue({
    required String userId,
    required String nom,
    required String email,
  }) async {
    try {
      await _dio.post('/ecoscan/bienvenue', data: {
        'user_id': userId,
        'nom': nom,
        'email': email,
      });
    } catch (_) {
      // Fire & forget
    }
  }
}
