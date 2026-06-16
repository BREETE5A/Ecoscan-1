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
    // Première fois : initialiser les champs depuis une agrégation serveur
    if (!snap.exists || !(snap.data()?.containsKey('totalScans') ?? false)) {
      await _initializeTotals(db);
      return const CommunityStats();
    }

    final data = snap.data()!;

    final totalScans    = (data['totalScans']    as num?)?.toInt()    ?? 0;
    final totalCo2Grams = (data['totalCo2Grams'] as num?)?.toDouble() ?? 0.0;
    final users         = (data['userCount']     as num?)?.toInt()    ?? 0;

    // Ajouter les données préservées des comptes supprimés
    final deletedScans = (data['deletedScans'] as num?)?.toInt()    ?? 0;
    final deletedCo2   = (data['deletedCo2']   as num?)?.toDouble() ?? 0.0;

    final allScans    = totalScans + deletedScans;
    final allCo2Grams = totalCo2Grams + deletedCo2;

    final kg       = (allCo2Grams / 1000).round();
    final progress = (allScans / 10000.0).clamp(0.0, 1.0);

    return CommunityStats(
      users:      users,
      scans:      allScans,
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
