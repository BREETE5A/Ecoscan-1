class ScanEntry {
  final String id;
  final String name;
  final String category;
  final bool recyclable;
  final bool dangerous;
  final int points;
  final double co2Saved; // grams
  final double recyclability; // 0.0 to 1.0
  final String binColor;
  final DateTime scannedAt;
  final String mode; // 'cloud' or 'local'

  const ScanEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.recyclable,
    required this.dangerous,
    required this.points,
    required this.co2Saved,
    required this.recyclability,
    required this.binColor,
    required this.scannedAt,
    required this.mode,
  });

  static const _categoryData = {
    'Plastique':    (name: 'Plastique recyclable', recyclable: true,  dangerous: false, points: 15, co2Saved: 45.0, recyclability: 0.92, binColor: 'Jaune'),
    'Verre':        (name: 'Verre recyclable',     recyclable: true,  dangerous: false, points: 25, co2Saved: 55.0, recyclability: 1.0,  binColor: 'Vert'),
    'Métal':        (name: 'Métal recyclable',     recyclable: true,  dangerous: false, points: 20, co2Saved: 80.0, recyclability: 0.97, binColor: 'Jaune'),
    'Papier':       (name: 'Papier recyclable',    recyclable: true,  dangerous: false, points: 10, co2Saved: 30.0, recyclability: 0.85, binColor: 'Bleu'),
    'Organique':    (name: 'Déchet organique',     recyclable: true,  dangerous: false, points: 8,  co2Saved: 20.0, recyclability: 0.90, binColor: 'Marron'),
    'Électronique': (name: 'Appareil DEEE',        recyclable: true,  dangerous: true,  points: 40, co2Saved: 0.0,  recyclability: 0.60, binColor: 'Éco-point'),
    'Textile':      (name: 'Déchet textile',       recyclable: true,  dangerous: false, points: 12, co2Saved: 35.0, recyclability: 0.80, binColor: 'Borne textile'),
    'Dangereux':    (name: 'Déchet dangereux',     recyclable: false, dangerous: true,  points: 30, co2Saved: 0.0,  recyclability: 0.0,  binColor: 'Déchetterie spécialisée'),
  };

  static ScanEntry fromClassification(String label, double confidence) {
    final data = _categoryData[label] ?? _categoryData['Plastique']!;
    return ScanEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data.name,
      category: label,
      recyclable: data.recyclable,
      dangerous: data.dangerous,
      points: (data.points * confidence).round().clamp(data.points ~/ 2, data.points),
      co2Saved: data.co2Saved * confidence,
      recyclability: data.recyclability * confidence,
      binColor: data.binColor,
      scannedAt: DateTime.now(),
      mode: 'local',
    );
  }

}
