import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_entry.dart';

final scanHistoryProvider =
    StateNotifierProvider<ScanHistoryNotifier, List<ScanEntry>>(
  (ref) {
    final notifier = ScanHistoryNotifier();
    notifier.loadHistory();
    return notifier;
  },
);

// Stream Firestore en temps réel des scans de l'utilisateur (pour les stats)
final scanHistoryStreamProvider = StreamProvider<List<ScanEntry>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value(ref.watch(scanHistoryProvider));
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('scans')
      .limit(200)
      .snapshots()
      .map((snap) {
        final entries = snap.docs.map((doc) {
          final data = doc.data();
          final category = data['category'] as String? ?? 'unknown';
          final confidence = (data['confidence'] as num?)?.toDouble() ?? 1.0;
          // Timestamp peut être null brièvement (serverTimestamp en attente)
          final ts = data['scannedAt'];
          final scannedAt = ts is Timestamp
              ? ts.toDate()
              : (ts == null ? DateTime.now() : DateTime.now());
          final base = ScanEntry.fromClassification(category, confidence);
          return ScanEntry(
            id: doc.id,
            name: base.name,
            category: base.category,
            recyclable: base.recyclable,
            dangerous: base.dangerous,
            points: base.points,
            co2Saved: (data['co2Saved'] as num?)?.toDouble() ?? base.co2Saved,
            recyclability: base.recyclability,
            binColor: base.binColor,
            scannedAt: scannedAt,
            mode: 'cloud',
          );
        }).toList();
        // Tri côté client — pas besoin d'index Firestore composite
        entries.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
        return entries;
      });
});

// The most recent scan result, used by result screen
final currentScanProvider = StateProvider<ScanEntry?>((ref) => null);

class ScanHistoryNotifier extends StateNotifier<List<ScanEntry>> {
  static const _key = 'scan_entries_v2';

  ScanHistoryNotifier() : super([]);

  Future<void> loadHistory() async {
    // 1. Try SharedPreferences first (fast, offline)
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        state = list
            .map((e) => ScanEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return;
      } catch (_) {}
    }

    // 2. No local data — load from Firestore if logged in
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _loadFromFirestore(uid);
    }
  }

  Future<void> _loadFromFirestore(String uid) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scans')
          .orderBy('scannedAt', descending: true)
          .limit(50)
          .get();

      final entries = snap.docs.map((doc) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'unknown';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 1.0;
        final scannedAt =
            (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final base = ScanEntry.fromClassification(category, confidence);
        return ScanEntry(
          id: doc.id,
          name: base.name,
          category: base.category,
          recyclable: base.recyclable,
          dangerous: base.dangerous,
          points: base.points,
          co2Saved: (data['co2Saved'] as num?)?.toDouble() ?? base.co2Saved,
          recyclability: base.recyclability,
          binColor: base.binColor,
          scannedAt: scannedAt,
          mode: 'cloud',
        );
      }).toList();

      if (entries.isNotEmpty) {
        state = entries;
        await _saveToPrefs();
      }
    } catch (e) {
      debugPrint('scanHistory Firestore load error: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(state.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void addScan(ScanEntry entry) {
    state = [entry, ...state];
    _saveToPrefs();
  }

  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, '[]');
  }

  double get totalCo2Saved => state.fold(0.0, (s, e) => s + e.co2Saved);
  int get totalPoints => state.fold(0, (s, e) => s + e.points);
  int get recyclableCount => state.where((e) => e.recyclable).length;
}
