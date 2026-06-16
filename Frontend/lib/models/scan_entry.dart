import '../l10n/app_strings.dart';

class ScanComponent {
  final String partie;
  final String label;
  final String binColor;
  final String conseil;

  const ScanComponent({
    required this.partie,
    required this.label,
    required this.binColor,
    this.conseil = '',
  });
}

class ScanEntry {
  final String id;
  final String name;
  final String category;
  final bool recyclable;
  final bool dangerous;
  final int points;
  final double co2Saved;
  final double recyclability;
  final String binColor;
  final DateTime scannedAt;
  final String mode;
  final List<ScanComponent> components;

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
    this.components = const [],
  });

  static const _categoryData = {
    'bois':         (recyclable: true,  dangerous: false, points: 10, co2Saved: 15.0, recyclability: 0.70, binColor: 'black'),
    'cardboard':    (recyclable: true,  dangerous: false, points: 10, co2Saved: 30.0, recyclability: 0.88, binColor: 'blue'),
    'chaussures':   (recyclable: true,  dangerous: false, points: 8,  co2Saved: 5.0,  recyclability: 0.65, binColor: 'textile'),
    'dangereux':    (recyclable: false, dangerous: true,  points: 30, co2Saved: 0.0,  recyclability: 0.20, binColor: 'special'),
    'electronique': (recyclable: true,  dangerous: true,  points: 40, co2Saved: 0.0,  recyclability: 0.60, binColor: 'special'),
    'metal':        (recyclable: true,  dangerous: false, points: 20, co2Saved: 80.0, recyclability: 0.97, binColor: 'yellow'),
    'organique':    (recyclable: true,  dangerous: false, points: 8,  co2Saved: 20.0, recyclability: 0.90, binColor: 'brown'),
    'paper':        (recyclable: true,  dangerous: false, points: 10, co2Saved: 30.0, recyclability: 0.85, binColor: 'blue'),
    'plastique':    (recyclable: true,  dangerous: false, points: 15, co2Saved: 45.0, recyclability: 0.92, binColor: 'yellow'),
    'textile':      (recyclable: true,  dangerous: false, points: 12, co2Saved: 10.0, recyclability: 0.65, binColor: 'textile'),
    'trash':        (recyclable: false, dangerous: false, points: 5,  co2Saved: 0.0,  recyclability: 0.10, binColor: 'black'),
    'unknown':      (recyclable: false, dangerous: false, points: 0,  co2Saved: 0.0,  recyclability: 0.0,  binColor: 'black'),
    'vetement':     (recyclable: true,  dangerous: false, points: 12, co2Saved: 10.0, recyclability: 0.65, binColor: 'textile'),
    'verre':        (recyclable: true,  dangerous: false, points: 25, co2Saved: 55.0, recyclability: 1.0,  binColor: 'green'),
  };

  static String binColorForLabel(String label) =>
      _categoryData[label]?.binColor ?? 'black';

  static ScanEntry fromClassification(String label, double confidence,
      {String lang = 'fr', List<ScanComponent> components = const []}) {
    final data = _categoryData[label] ?? _categoryData['unknown']!;
    final localizedName = AppStrings.of(lang).categoryName(label);
    return ScanEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: localizedName,
      category: label,
      recyclable: data.recyclable,
      dangerous: data.dangerous,
      points: (data.points * confidence).round().clamp(data.points ~/ 2, data.points),
      co2Saved: data.co2Saved * confidence,
      recyclability: data.recyclability * confidence,
      binColor: data.binColor,
      scannedAt: DateTime.now(),
      mode: 'local',
      components: components,
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

  static const _binColorMigration = {
    'Vert': 'green', 'Bleu': 'blue', 'Jaune': 'yellow',
    'Noir': 'black', 'Marron': 'brown',
  };

  factory ScanEntry.fromJson(Map<String, dynamic> json) {
    final rawColor = json['binColor'] as String? ?? 'black';
    return ScanEntry(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Inconnu',
      category: json['category'] as String? ?? 'unknown',
      recyclable: json['recyclable'] as bool? ?? false,
      dangerous: json['dangerous'] as bool? ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
      co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
      recyclability: (json['recyclability'] as num?)?.toDouble() ?? 0.0,
      binColor: _binColorMigration[rawColor] ?? rawColor,
      scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? '') ?? DateTime.now(),
      mode: json['mode'] as String? ?? 'local',
    );
  }
}
