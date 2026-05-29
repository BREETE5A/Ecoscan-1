import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> load() async {
    final doc = _doc;
    if (doc == null) return;
    try {
      final snap = await doc.get();
      final today = _dayKey();
      final thisWeek = _weekKey();

      if (!snap.exists) {
        final fresh = ChallengeProgress(dayKey: today, weekKey: thisWeek);
        state = fresh;
        await doc.set(fresh.toJson());
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      var p = ChallengeProgress.fromJson(data);

      // Reset daily if new day
      if (p.dayKey != today) {
        p = ChallengeProgress(
          dailyScans: 0,
          ecoBotUsed: false,
          guideViews: 0,
          mapOpened: false,
          shared: false,
          // Keep weekly unless new week
          weeklyScans: p.weekKey == thisWeek ? p.weeklyScans : 0,
          dayKey: today,
          weekKey: thisWeek,
        );
        await doc.set(p.toJson());
      } else if (p.weekKey != thisWeek) {
        p = p.copyWith(weeklyScans: 0, weekKey: thisWeek);
        await doc.set(p.toJson());
      }

      state = p;
    } catch (e) {
      debugPrint('ChallengesProvider load error: $e');
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
    try {
      await _doc?.set(p.toJson());
    } catch (e) {
      debugPrint('ChallengesProvider save error: $e');
    }
  }
}
