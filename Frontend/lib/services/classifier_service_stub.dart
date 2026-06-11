import 'dart:io';
import 'package:flutter/foundation.dart';

class ClassifierService {
  bool get isLoaded => false;

  Future<void> load() async {
    if (kDebugMode) debugPrint('ClassifierService: TFLite not available on this platform');
  }

  Future<({String label, double confidence, List<({String label, double score})> allScores})>
      classify(File imageFile) async {
    throw UnsupportedError('TFLite classification is not available on web');
  }

  void close() {}
}
