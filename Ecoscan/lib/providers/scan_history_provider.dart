import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_entry.dart';

final scanHistoryProvider =
    StateNotifierProvider<ScanHistoryNotifier, List<ScanEntry>>(
  (ref) => ScanHistoryNotifier(),
);

// The most recent scan result, used by result screen
final currentScanProvider = StateProvider<ScanEntry?>((ref) => null);

class ScanHistoryNotifier extends StateNotifier<List<ScanEntry>> {
  ScanHistoryNotifier() : super(ScanEntry.seedData);

  void addScan(ScanEntry entry) {
    state = [entry, ...state];
  }

  double get totalCo2Saved => state.fold(0.0, (s, e) => s + e.co2Saved);
  int get totalPoints => state.fold(0, (s, e) => s + e.points);
  int get recyclableCount => state.where((e) => e.recyclable).length;
}
