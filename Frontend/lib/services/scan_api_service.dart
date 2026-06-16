import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/scan_entry.dart';

class ScanApiService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.scanBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static Future<ScanApiResult?> classify(File imageFile, {String lang = 'fr'}) async {
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
        queryParameters: {'lang': lang},
      );

      final data = response.data as Map<String, dynamic>;

      if (data['count'] == 0 || data['top_label'] == null) return null;

      final topConf = (data['top_confidence'] as num).toDouble();
      if (topConf < 0.40) return null;

      final components = (data['components'] as List? ?? [])
          .map((c) => ScanComponent(
                partie: c['partie'] as String? ?? 'Objet',
                label: c['label'] as String? ?? 'trash',
                binColor: ScanEntry.binColorForLabel(c['label'] as String? ?? 'trash'),
                conseil: c['conseil'] as String? ?? '',
              ))
          .toList();

      return ScanApiResult(
        topLabel: data['top_label'] as String,
        topConfidence: topConf,
        components: components,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isAvailable() async {
    try {
      final response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ScanApiResult {
  final String topLabel;
  final double topConfidence;
  final List<ScanComponent> components;

  const ScanApiResult({
    required this.topLabel,
    required this.topConfidence,
    required this.components,
  });
}
