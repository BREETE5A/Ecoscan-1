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

  static const _samples = [
    (
      name: 'Bouteille PET',
      category: 'Plastique',
      recyclable: true,
      dangerous: false,
      points: 15,
      co2Saved: 45.0,
      recyclability: 0.92,
      binColor: 'Jaune',
      mode: 'cloud',
    ),
    (
      name: 'Boîte de conserve',
      category: 'Métal',
      recyclable: true,
      dangerous: false,
      points: 20,
      co2Saved: 80.0,
      recyclability: 0.97,
      binColor: 'Jaune',
      mode: 'cloud',
    ),
    (
      name: 'Journal',
      category: 'Papier',
      recyclable: true,
      dangerous: false,
      points: 10,
      co2Saved: 30.0,
      recyclability: 0.85,
      binColor: 'Bleu',
      mode: 'local',
    ),
    (
      name: 'Bouteille en verre',
      category: 'Verre',
      recyclable: true,
      dangerous: false,
      points: 25,
      co2Saved: 55.0,
      recyclability: 1.0,
      binColor: 'Vert',
      mode: 'cloud',
    ),
    (
      name: 'Pile alcaline',
      category: 'DEEE',
      recyclable: true,
      dangerous: true,
      points: 40,
      co2Saved: 0.0,
      recyclability: 0.6,
      binColor: 'Point de collecte',
      mode: 'cloud',
    ),
    (
      name: 'Emballage alimentaire',
      category: 'Plastique',
      recyclable: false,
      dangerous: false,
      points: 5,
      co2Saved: 0.0,
      recyclability: 0.15,
      binColor: 'Noir',
      mode: 'local',
    ),
  ];

  static List<ScanEntry> get seedData {
    final now = DateTime.now();
    return List.generate(_samples.length, (i) {
      final s = _samples[i];
      return ScanEntry(
        id: 'seed_$i',
        name: s.name,
        category: s.category,
        recyclable: s.recyclable,
        dangerous: s.dangerous,
        points: s.points,
        co2Saved: s.co2Saved,
        recyclability: s.recyclability,
        binColor: s.binColor,
        scannedAt: now.subtract(Duration(hours: i * 5 + 2)),
        mode: s.mode,
      );
    });
  }

  static ScanEntry random() {
    final s = _samples[DateTime.now().millisecond % _samples.length];
    return ScanEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: s.name,
      category: s.category,
      recyclable: s.recyclable,
      dangerous: s.dangerous,
      points: s.points,
      co2Saved: s.co2Saved,
      recyclability: s.recyclability,
      binColor: s.binColor,
      scannedAt: DateTime.now(),
      mode: s.mode,
    );
  }
}
