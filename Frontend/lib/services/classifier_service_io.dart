import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  // Ordre alphabétique des 10 dossiers d'entraînement (vérifié empiriquement sur TRASHNET)
  // indices 1,3,4,6,7,8,9 confirmés ; 5=organique par position alphabétique
  // 0=vetement confirmé (images textile→idx 0, 98%) ; 2=chaussures (c-h entre c-a et e)
  static const _labels = [
    'vetement',     // 0 — confirmé empiriquement (images textile → 98%)
    'cardboard',    // 1 — confirmé
    'chaussures',   // 2 — confirmé par l'utilisateur (c-h entre cardboard et electronique)
    'electronique', // 3 — confirmé
    'metal',        // 4 — confirmé
    'organique',    // 5 — inféré (position alphabétique entre metal et paper)
    'paper',        // 6 — confirmé
    'plastique',    // 7 — confirmé (nom du dossier d'entraînement)
    'trash',        // 8 — confirmé
    'verre',        // 9 — confirmé
  ];

  // Aucune conversion nécessaire : 'plastique' est déjà le nom canonique
  static const _canonicalMap = <String, String>{};
  static const _inputSize = 224;
  // Seuil de confiance minimum : en dessous → "Objet non reconnu"
  static const _confidenceThreshold = 0.45;

  Interpreter? _interpreter;
  bool _inputIsUint8 = false;

  bool get isLoaded => _interpreter != null;

  Future<void> load() async {
    final byteData = await rootBundle.load(
      'assets/models/EfficientNetV2B0_ecoscan.tflite',
    );
    _interpreter = Interpreter.fromBuffer(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);
    _inputIsUint8 = inputTensor.type.toString().contains('uint8') ||
                    inputTensor.type.toString().contains('UInt8');
    if (kDebugMode) debugPrint('TFLite | input: ${inputTensor.shape} ${inputTensor.type} | output: ${outputTensor.shape} ${outputTensor.type} | uint8=$_inputIsUint8');
  }

  Future<({String label, double confidence, List<({String label, double score})> allScores})> classify(File imageFile) async {
    final interpreter = _interpreter;
    if (interpreter == null) throw StateError('Model not loaded');

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Cannot decode image');

    final resized = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    List<double> scores;

    if (_inputIsUint8) {
      // Modèle quantifié uint8 : pixels bruts [0, 255]
      final inputBuffer = Uint8List(_inputSize * _inputSize * 3);
      int idx = 0;
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[idx++] = pixel.r.toInt().clamp(0, 255);
          inputBuffer[idx++] = pixel.g.toInt().clamp(0, 255);
          inputBuffer[idx++] = pixel.b.toInt().clamp(0, 255);
        }
      }
      final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
      final output = [List.filled(_labels.length, 0.0)];
      interpreter.run(input, output);
      scores = output[0];
    } else {
      // Les couches Rescaling internes du modèle attendent des pixels [0, 255]
      // — ne pas pré-normaliser ici, sinon les valeurs arrivent ~0 au modèle.
      final inputBuffer = Float32List(_inputSize * _inputSize * 3);
      int idx = 0;
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[idx++] = pixel.r.toDouble();
          inputBuffer[idx++] = pixel.g.toDouble();
          inputBuffer[idx++] = pixel.b.toDouble();
        }
      }
      final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
      final output = [List.filled(_labels.length, 0.0)];
      interpreter.run(input, output);
      scores = output[0];
    }

    // Applique softmax si les scores ne sont pas déjà des probabilités
    final rawSum = scores.reduce((a, b) => a + b);
    final probabilities = (rawSum > 0.95 && rawSum < 1.05)
        ? scores
        : _softmax(scores);
    if (kDebugMode) debugPrint('TFLite probs: $probabilities  sum=${scores.reduce((a,b)=>a+b)}');

    int maxIdx = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[maxIdx]) maxIdx = i;
    }

    final rawLabel = probabilities[maxIdx] >= _confidenceThreshold
        ? _labels[maxIdx]
        : 'unknown';
    final topLabel = _canonicalMap[rawLabel] ?? rawLabel;

    return (
      label: topLabel,
      confidence: probabilities[maxIdx],
      allScores: List<({String label, double score})>.generate(
        _labels.length,
        (i) => (label: _labels[i], score: probabilities[i]),
      ),
    );
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  static List<double> _softmax(List<double> logits) {
    final maxVal = logits.reduce(max);
    final exps = logits.map((v) => exp(v - maxVal)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((v) => v / sum).toList();
  }
}
