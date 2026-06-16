import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityStats {
  final int users;
  final int scans;
  final int kgRecycled;
  final double progress; // 0..1

  const CommunityStats({
    this.users = 0,
    this.scans = 0,
    this.kgRecycled = 0,
    this.progress = 0,
  });
}

final communityStatsProvider = StreamProvider<CommunityStats>((ref) {
  final db = FirebaseFirestore.instance;

  // Stream temps réel sur le document community_totals/stats.
  // Ce document est mis à jour à chaque scan (storage_service.dart),
  // à chaque inscription (auth_provider.dart) et à chaque suppression de compte.
  return db
      .collection('community_totals')
      .doc('stats')
      .snapshots()
      .asyncMap((snap) async {
    final data = snap.exists ? snap.data() : null;
    final hasTotalScans = data?.containsKey('totalScans') ?? false;
    final hasCo2        = data?.containsKey('totalCo2Grams') ?? false;
    final rawUsers      = (data?['userCount'] as num?)?.toInt() ?? 0;

    // Ré-initialiser si données manquantes ou userCount négatif
    if (!hasTotalScans || !hasCo2 || rawUsers < 0) {
      await _initializeTotals(db);
      return const CommunityStats();
    }

    final totalScans    = (data!['totalScans']    as num?)?.toInt()    ?? 0;
    final totalCo2Grams = (data['totalCo2Grams'] as num?)?.toDouble() ?? 0.0;
    final users         = rawUsers.clamp(0, 999999999);

    final kg       = (totalCo2Grams / 1000).round();
    final progress = (totalScans / 10000.0).clamp(0.0, 1.0);

    return CommunityStats(
      users:      users,
      scans:      totalScans,
      kgRecycled: kg,
      progress:   progress,
    );
  });
});

/// Initialise totalScans, totalCo2Grams et userCount depuis une agrégation
/// serveur — appelé une seule fois si les champs sont absents du document.
Future<void> _initializeTotals(FirebaseFirestore db) async {
  try {
    final agg = await db.collection('users').aggregate(
      count(),
      sum('scansCount'),
      sum('co2Saved'),
    ).get();

    await db.collection('community_totals').doc('stats').set({
      'totalScans':    (agg.getSum('scansCount') as num?)?.toInt()    ?? 0,
      'totalCo2Grams': (agg.getSum('co2Saved')  as num?)?.toDouble() ?? 0.0,
      'userCount':     agg.count ?? 0,
    }, SetOptions(merge: true));
  } catch (_) {}
}
