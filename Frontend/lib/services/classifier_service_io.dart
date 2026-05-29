import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  // Ordre alphabétique Python (Keras flow_from_directory) — 8 classes
  static const _labels = [
    'Dangereux', 'Métal', 'Organique', 'Papier', 'Plastique', 'Textile', 'Verre', 'Électronique'
  ];
  static const _inputSize = 224;

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
    // Vérifie si le modèle attend uint8 (quantisé) ou float32
    _inputIsUint8 = inputTensor.type.toString().contains('uint8') ||
                    inputTensor.type.toString().contains('UInt8');
    debugPrint('TFLite loaded | input: ${inputTensor.shape} type:${inputTensor.type} | output: ${outputTensor.shape} type:${outputTensor.type} | uint8=$_inputIsUint8');
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
      // Modèle quantisé : uint8 [0, 255]
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
      // Modèle float32 entraîné avec rescale=1./255 → normaliser à [0, 1]
      final inputBuffer = Float32List(_inputSize * _inputSize * 3);
      int idx = 0;
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[idx++] = pixel.r.toDouble() / 255.0;
          inputBuffer[idx++] = pixel.g.toDouble() / 255.0;
          inputBuffer[idx++] = pixel.b.toDouble() / 255.0;
        }
      }
      final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
      final output = [List.filled(_labels.length, 0.0)];
      interpreter.run(input, output);
      scores = output[0];
    }

    // Applique softmax si le modèle sort des logits (pas de couche softmax finale)
    final probabilities = _softmax(scores);
    debugPrint('TFLite raw scores   : $scores');
    debugPrint('TFLite probabilities: $probabilities');

    int maxIdx = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[maxIdx]) maxIdx = i;
    }

    return (
      label: _labels[maxIdx],
      confidence: probabilities[maxIdx],
      allScores: List<({String label, double score})>.generate(
        _labels.length,
        (i) => (label: _labels[i], score: probabilities[i]),
      ),
    );
  }

  List<double> _softmax(List<double> logits) {
    final maxVal = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxVal)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
