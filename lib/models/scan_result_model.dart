class ScanResultModel {
  final String rawClass;
  final String category;
  final String binColor;
  final double confidence;
  final double co2SavedPerKg;
  final DateTime scannedAt;

  const ScanResultModel({
    required this.rawClass,
    required this.category,
    required this.binColor,
    required this.confidence,
    required this.co2SavedPerKg,
    required this.scannedAt,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      rawClass: json['raw_class'] as String? ?? '',
      category: json['category'] as String? ?? 'Inconnu',
      binColor: json['bin_color'] as String? ?? 'gris',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      co2SavedPerKg: (json['co2_saved_per_kg'] as num?)?.toDouble() ?? 0.0,
      scannedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'raw_class': rawClass,
        'category': category,
        'bin_color': binColor,
        'confidence': confidence,
        'co2_saved_per_kg': co2SavedPerKg,
        'scanned_at': scannedAt.toIso8601String(),
      };
}
