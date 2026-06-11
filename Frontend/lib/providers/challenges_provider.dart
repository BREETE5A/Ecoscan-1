import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class ChallengeProgress {
  // Daily
  final int dailyScans;
  final bool ecoBotUsed;
  final int guideViews;
  final bool mapOpened;
  final bool shared;
  // Weekly
  final int weeklyScans;
  final String dayKey;
  final String weekKey;

  const ChallengeProgress({
    this.dailyScans = 0,
    this.ecoBotUsed = false,
    this.guideViews = 0,
    this.mapOpened = false,
    this.shared = false,
    this.weeklyScans = 0,
    this.dayKey = '',
    this.weekKey = '',
  });

  ChallengeProgress copyWith({
    int? dailyScans,
    bool? ecoBotUsed,
    int? guideViews,
    bool? mapOpened,
    bool? shared,
    int? weeklyScans,
    String? dayKey,
    String? weekKey,
  }) => ChallengeProgress(
    dailyScans: dailyScans ?? this.dailyScans,
    ecoBotUsed: ecoBotUsed ?? this.ecoBotUsed,
    guideViews: guideViews ?? this.guideViews,
    mapOpened: mapOpened ?? this.mapOpened,
    shared: shared ?? this.shared,
    weeklyScans: weeklyScans ?? this.weeklyScans,
    dayKey: dayKey ?? this.dayKey,
    weekKey: weekKey ?? this.weekKey,
  );

  Map<String, dynamic> toJson() => {
    'dailyScans': dailyScans,
    'ecoBotUsed': ecoBotUsed,
    'guideViews': guideViews,
    'mapOpened': mapOpened,
    'shared': shared,
    'weeklyScans': weeklyScans,
    'dayKey': dayKey,
    'weekKey': weekKey,
  };

  factory ChallengeProgress.fromJson(Map<String, dynamic> d) => ChallengeProgress(
    dailyScans: (d['dailyScans'] as num?)?.toInt() ?? 0,
    ecoBotUsed: (d['ecoBotUsed'] as bool?) ?? false,
    guideViews: (d['guideViews'] as num?)?.toInt() ?? 0,
    mapOpened: (d['mapOpened'] as bool?) ?? false,
    shared: (d['shared'] as bool?) ?? false,
    weeklyScans: (d['weeklyScans'] as num?)?.toInt() ?? 0,
    dayKey: (d['dayKey'] as String?) ?? '',
    weekKey: (d['weekKey'] as String?) ?? '',
  );
}

// ── Keys ──────────────────────────────────────────────────────────────────────

String _dayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _weekKey() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final week = ((now.difference(startOfYear).inDays) / 7).ceil();
  return '${now.year}-W${week.toString().padLeft(2, '0')}';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, ChallengeProgress>((ref) {
  final notifier = ChallengesNotifier();
  notifier.load();
  return notifier;
});

class ChallengesNotifier extends StateNotifier<ChallengeProgress> {
  static const _prefsKey = 'challenges_progress_v1';

  ChallengesNotifier() : super(const ChallengeProgress());

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc('challenges');
  }

  // ── Persistance locale (fallback hors ligne) ──────────────────────────────

  Future<void> _saveLocal(ChallengeProgress p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(p.toJson()));
    } catch (_) {}
  }

  Future<ChallengeProgress?> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return null;
      return ChallengeProgress.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  // ── Applique les resets daily/weekly ─────────────────────────────────────

  ChallengeProgress _applyResets(ChallengeProgress p) {
    final today    = _dayKey();
    final thisWeek = _weekKey();
    if (p.dayKey != today) {
      return ChallengeProgress(
        dailyScans:  0,
        ecoBotUsed:  false,
        guideViews:  0,
        mapOpened:   false,
        shared:      false,
        weeklyScans: p.weekKey == thisWeek ? p.weeklyScans : 0,
        dayKey:      today,
        weekKey:     thisWeek,
      );
    } else if (p.weekKey != thisWeek) {
      return p.copyWith(weeklyScans: 0, weekKey: thisWeek);
    }
    return p;
  }

  Future<void> load() async {
    final today    = _dayKey();
    final thisWeek = _weekKey();
    final doc      = _doc;

    // Toujours charger le local d'abord (rapide, fonctionne offline)
    final local = await _loadLocal();
    if (local != null) {
      state = _applyResets(local);
    }

    if (doc == null) return; // utilisateur non connecté → local suffit

    try {
      final snap = await doc.get();

      if (!snap.exists) {
        final fresh = ChallengeProgress(dayKey: today, weekKey: thisWeek);
        state = fresh;
        await doc.set(fresh.toJson());
        await _saveLocal(fresh);
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      var p = _applyResets(ChallengeProgress.fromJson(data));

      if (p != ChallengeProgress.fromJson(data)) {
        await doc.set(p.toJson());
      }

      state = p;
      await _saveLocal(p);
    } catch (e) {
      if (kDebugMode) debugPrint('ChallengesProvider load error: $e');
      // On garde l'état local chargé au début
    }
  }

  Future<void> incrementScan() async {
    final p = state.copyWith(
      dailyScans: state.dailyScans + 1,
      weeklyScans: state.weeklyScans + 1,
    );
    state = p;
    await _save(p);
  }

  Future<void> useEcoBot() async {
    if (state.ecoBotUsed) return;
    final p = state.copyWith(ecoBotUsed: true);
    state = p;
    await _save(p);
  }

  Future<void> viewGuide() async {
    final p = state.copyWith(guideViews: state.guideViews + 1);
    state = p;
    await _save(p);
  }

  Future<void> openMap() async {
    if (state.mapOpened) return;
    final p = state.copyWith(mapOpened: true);
    state = p;
    await _save(p);
  }

  Future<void> shareContent() async {
    if (state.shared) return;
    final p = state.copyWith(shared: true);
    state = p;
    await _save(p);
  }

  Future<void> _save(ChallengeProgress p) async {
    await _saveLocal(p); // toujours persister localement en premier
    try {
      await _doc?.set(p.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('ChallengesProvider save error: $e');
    }
  }
}
