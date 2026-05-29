import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ScanApiService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.scanBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: Duration(seconds: ApiConstants.scanTimeoutSeconds),
    ),
  );

  /// Envoie l'image au backend YOLOv8 et retourne la détection principale.
  /// Retourne null si le serveur n'est pas disponible.
  static Future<ScanApiResult?> classify(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'scan.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConstants.scanEndpoint,
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;

      if (data['count'] == 0 || data['top_label'] == null) {
        return null;
      }

      return ScanApiResult(
        topLabel: _translateLabel(data['top_label'] as String),
        topConfidence: (data['top_confidence'] as num).toDouble(),
        detections: (data['detections'] as List)
            .map((d) => Detection(
                  label: _translateLabel(d['label'] as String),
                  confidence: (d['confidence'] as num).toDouble(),
                ))
            .toList(),
      );
    } catch (_) {
      return null; // Serveur injoignable → fallback TFLite
    }
  }

  static Future<bool> isAvailable() async {
    try {
      final response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Traduction labels TACO → labels marocains EcoScan
  static String _translateLabel(String label) {
    const map = {
      'Bottle': 'Plastique',
      'Plastic bottle': 'Plastique',
      'Can': 'Métal',
      'Aluminium can': 'Métal',
      'Carton': 'Papier',
      'Paper': 'Papier',
      'Glass bottle': 'Verre',
      'Cigarette': 'Dangereux',
      'Battery': 'Électronique',
      'Plastic bag': 'Plastique',
      'Styrofoam piece': 'Plastique',
      'Cup': 'Plastique',
      'Lid': 'Métal',
      'Broken glass': 'Verre',
      'Food waste': 'Organique',
      'Scrap metal': 'Métal',
      'Rope': 'Textile',
      'Shoe': 'Textile',
      'Tissue': 'Papier',
      'Pop tab': 'Métal',
    };
    return map[label] ?? label;
  }
}

class ScanApiResult {
  final String topLabel;
  final double topConfidence;
  final List<Detection> detections;

  const ScanApiResult({
    required this.topLabel,
    required this.topConfidence,
    required this.detections,
  });
}

class Detection {
  final String label;
  final double confidence;
  const Detection({required this.label, required this.confidence});
}
