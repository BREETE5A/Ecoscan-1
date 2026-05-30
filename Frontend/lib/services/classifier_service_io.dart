import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  // Ordre alphabétique Python (Keras flow_from_directory) — 8 classes exactes
  static const _labels = [
    'cardboard', 'electronique', 'metal', 'organique', 'paper', 'plastique', 'trash', 'verre'
  ];
  static const _inputSize = 224;
  // Seuil de confiance minimum : en dessous → "Objet non reconnu"
  static const _confidenceThreshold = 0.45;

  Interpreter? _interpreter;
  bool _inputIsUint8 = false;

  bool get isLoaded => _interpreter != null;

  Future<void> load() async {
    final byteData = await rootBundle.load(
      'assets/models/ecoscan_model_efficientNet.tflite',
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
    debugPrint('TFLite | input: ${inputTensor.shape} ${inputTensor.type} | output: ${outputTensor.shape} ${outputTensor.type} | uint8=$_inputIsUint8');
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
      // EfficientNetB0 a une couche Rescaling(1/255) interne
      // → passer les pixels bruts [0, 255], le modèle normalise lui-même
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

    // Modèle avec softmax → output déjà des probabilités
    final probabilities = scores;
    debugPrint('TFLite probs: $probabilities  sum=${scores.reduce((a,b)=>a+b)}');

    int maxIdx = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[maxIdx]) maxIdx = i;
    }

    final topLabel = probabilities[maxIdx] >= _confidenceThreshold
        ? _labels[maxIdx]
        : 'unknown';

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
}
