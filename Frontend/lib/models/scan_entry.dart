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
    'cardboard':    (name: 'Carton recyclable',    recyclable: true,  dangerous: false, points: 10, co2Saved: 30.0, recyclability: 0.88, binColor: 'Bleu'),
    'chaussures':   (name: 'Chaussures usagées',   recyclable: false, dangerous: false, points: 8,  co2Saved: 5.0,  recyclability: 0.15, binColor: 'Vert'),
    'vetement':     (name: 'Vêtement / Textile',   recyclable: true,  dangerous: false, points: 12, co2Saved: 10.0, recyclability: 0.65, binColor: 'Vert'),
    'electronique': (name: 'Appareil DEEE',        recyclable: true,  dangerous: true,  points: 40, co2Saved: 0.0,  recyclability: 0.60, binColor: 'Éco-point'),
    'metal':        (name: 'Métal recyclable',     recyclable: true,  dangerous: false, points: 20, co2Saved: 80.0, recyclability: 0.97, binColor: 'Jaune'),
    'organique':    (name: 'Déchet organique',     recyclable: true,  dangerous: false, points: 8,  co2Saved: 20.0, recyclability: 0.90, binColor: 'Marron'),
    'paper':        (name: 'Papier recyclable',    recyclable: true,  dangerous: false, points: 10, co2Saved: 30.0, recyclability: 0.85, binColor: 'Bleu'),
    'plastique':    (name: 'Plastique recyclable', recyclable: true,  dangerous: false, points: 15, co2Saved: 45.0, recyclability: 0.92, binColor: 'Jaune'),
    'trash':        (name: 'Déchet non recyclable',recyclable: false, dangerous: false, points: 5,  co2Saved: 0.0,  recyclability: 0.10, binColor: 'Noir'),
    'unknown':      (name: 'Objet non reconnu',    recyclable: false, dangerous: false, points: 0,  co2Saved: 0.0,  recyclability: 0.0,  binColor: 'Noir'),
    'verre':        (name: 'Verre recyclable',     recyclable: true,  dangerous: false, points: 25, co2Saved: 55.0, recyclability: 1.0,  binColor: 'Vert'),
  };

  static ScanEntry fromClassification(String label, double confidence) {
    final data = _categoryData[label] ?? _categoryData['unknown']!;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'recyclable': recyclable,
    'dangerous': dangerous,
    'points': points,
    'co2Saved': co2Saved,
    'recyclability': recyclability,
    'binColor': binColor,
    'scannedAt': scannedAt.toIso8601String(),
    'mode': mode,
  };

  factory ScanEntry.fromJson(Map<String, dynamic> json) => ScanEntry(
    id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] as String? ?? 'Inconnu',
    category: json['category'] as String? ?? 'unknown',
    recyclable: json['recyclable'] as bool? ?? false,
    dangerous: json['dangerous'] as bool? ?? false,
    points: (json['points'] as num?)?.toInt() ?? 0,
    co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
    recyclability: (json['recyclability'] as num?)?.toDouble() ?? 0.0,
    binColor: json['binColor'] as String? ?? 'Noir',
    scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? '') ?? DateTime.now(),
    mode: json['mode'] as String? ?? 'local',
  );

}
