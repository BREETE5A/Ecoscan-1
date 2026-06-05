import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ScanApiService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.scanBaseUrl,
      // Timeout étendu : Render free tier cold start peut prendre 30-60s
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// Envoie l'image au backend YOLOv8 et retourne la détection principale.
  /// Retourne null si le serveur n'est pas disponible (timeout ou erreur).
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

      // Seuil de confiance minimum côté client : rejette < 0.40
      final topConf = (data['top_confidence'] as num).toDouble();
      if (topConf < 0.40) return null;

      final translatedLabel = _translateLabel(data['top_label'] as String);

      return ScanApiResult(
        topLabel:      translatedLabel,
        topConfidence: topConf,
        detections: (data['detections'] as List)
            .map((d) => Detection(
                  label:      _translateLabel(d['label'] as String),
                  confidence: (d['confidence'] as num).toDouble(),
                ))
            .toList(),
      );
    } catch (_) {
      return null; // Serveur injoignable → fallback TFLite
    }
  }

  /// Ping /health pour réveiller le serveur Render en arrière-plan.
  /// À appeler au démarrage de l'app pour éviter le cold start lors du premier scan.
  static Future<bool> isAvailable() async {
    try {
      final response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout:    const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Table de traduction COMPLÈTE : labels TACO/YOLOv8 → catégories EcoScan ──
  // Couvre les 44 classes exactes de turhancan97/yolov8-segment-trash-detection
  // ET les classes du modèle Roboflow TACO (yolov8-trash-detections-kgnug)
  static String _translateLabel(String label) {
    // Normalise : supprime espaces superflus
    final l = label.trim();

    const map = <String, String>{
      // ── 44 classes EXACTES de turhancan97/yolov8-segment-trash-detection ──
      // Verre
      'Glass bottle':              'verre',
      'Glass jar':                 'verre',
      'Broken glass':              'verre',
      // Plastique
      'Clear plastic bottle':      'plastique',
      'Other plastic bottle':      'plastique',
      'Plastic bottle cap':        'plastique',
      'Plastic bag & wrapper':     'plastique',   // & et non -
      'Plastic straw':             'plastique',
      'Plastic utensils':          'plastique',
      'Other plastic':             'plastique',
      'Cup':                       'plastique',
      'Foam cup':                  'plastique',
      'Foam food container':       'plastique',
      'Polystyrene food container':'plastique',
      'Six pack rings':            'plastique',
      'Spread tub':                'plastique',
      'Squeezable tube':           'plastique',
      'Tupperware':                'plastique',
      'Lid':                       'plastique',
      'Styrofoam piece':           'plastique',
      'Carded blister pack':       'plastique',
      // Métal
      'Drink can':                 'metal',
      'Aluminium foil':            'metal',
      'Aluminium blister pack':    'metal',
      'Metal bottle cap':          'metal',
      'Metal lid':                 'metal',
      'Pop tab':                   'metal',
      'Scrap metal':               'metal',
      'Food Can':                  'metal',
      // Papier / Carton
      'Corrugated carton':         'cardboard',
      'Drink carton':              'cardboard',
      'Egg carton':                'cardboard',
      'Meal carton':               'cardboard',
      'Other carton':              'cardboard',
      'Paper bag':                 'paper',
      'Paper cup':                 'paper',
      'Magazine paper':            'paper',
      'Normal paper':              'paper',
      'Tissue':                    'paper',
      // Organique
      'Food waste':                'organique',
      // Électronique
      'Battery':                   'electronique',
      // Non recyclable
      'Cigarette':                 'trash',
      'Rope & strings':            'trash',
      'Unlabeled litter':          'trash',

      // ── Variantes Roboflow TACO (yolov8-trash-detections-kgnug) ──────────
      'plastic bottle':            'plastique',
      'glass bottle':              'verre',
      'drink can':                 'metal',
      'food can':                  'metal',
      'aluminium foil':            'metal',
      'paper bag':                 'paper',
      'cardboard':                 'cardboard',
      'corrugated carton':         'cardboard',
      'food waste':                'organique',
      'battery':                   'electronique',
      'cigarette':                 'trash',
      'unlabeled litter':          'trash',
      'broken glass':              'verre',
      'normal paper':              'paper',
      'other plastic':             'plastique',
      'styrofoam piece':           'plastique',
      'plastic bag & wrapper':     'plastique',
      'plastic straw':             'plastique',
      'plastic utensils':          'plastique',
      'metal lid':                 'metal',
      'metal bottle cap':          'metal',
      'scrap metal':               'metal',
      'pop tab':                   'metal',

      // ── Anciennes entrées / compatibilité descendante ─────────────────────
      'Glass':                     'verre',
      'Metal':                     'metal',
      'Paper':                     'paper',
      'Plastic':                   'plastique',
      'Waste':                     'trash',
      'Bottle':                    'verre',
      'Plastic bottle':            'plastique',
      'Plastic bag - Wrapper':     'plastique',
      'Plastic bag':               'plastique',
      'Plastic film':              'plastique',
      'Plastic gloves':            'plastique',
      'Disposable plastic cup':    'plastique',
      'Disposable food container': 'plastique',
      'Food Container':            'plastique',
      'Plastic lid':               'plastique',
      'Can':                       'metal',
      'Aluminium can':             'metal',
      'Aerosol':                   'electronique',
      'Cardboard':                 'cardboard',
      'Carton':                    'cardboard',
      'Cigarette end':             'trash',
      'Newspaper':                 'paper',
      'Magazine':                  'paper',
      'Tissues':                   'paper',
      'Organic waste':             'organique',
      'Electronic':                'electronique',
      'Shoe':                      'trash',
      'Rope':                      'trash',
      'Other':                     'trash',
      'Normal trash':              'trash',

      // ── Minuscules génériques ──────────────────────────────────────────────
      'bottle':      'plastique',
      'can':         'metal',
      'cup':         'plastique',
      'glass':       'verre',
      'metal':       'metal',
      'paper':       'paper',
      'plastic':     'plastique',
      'trash':       'trash',
      'food':        'organique',
    };

    // Cherche label exact d'abord, puis case-insensitive
    return map[l] ?? map[l.toLowerCase()] ?? 'unknown';
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
