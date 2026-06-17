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

  return db
      .collection('community_totals')
      .doc('stats')
      .snapshots()
      .asyncMap((snap) async {
    final data = snap.exists ? snap.data() : null;

    final hasTotalScans = data?.containsKey('totalScans') ?? false;
    final hasCo2        = data?.containsKey('totalCo2Grams') ?? false;
    final hasUserCount  = data?.containsKey('userCount') ?? false;
    final rawUsers      = (data?['userCount'] as num?)?.toInt() ?? 0;

    // Initialiser si un champ obligatoire est absent ou userCount négatif
    if (!hasTotalScans || !hasCo2 || !hasUserCount || rawUsers < 0) {
      final stats = await _initializeTotals(db, existingData: data);
      return stats;
    }

    final totalScans    = (data!['totalScans']    as num?)?.toInt()    ?? 0;
    final totalCo2Grams = (data['totalCo2Grams'] as num?)?.toDouble() ?? 0.0;
    final users         = rawUsers.clamp(0, 999999999);

    // Si userCount vaut 0 mais qu'il y a des scans, le compteur est désynchronisé
    if (users == 0 && totalScans > 0) {
      _resyncUserCount(db);
    }

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

/// Compte les utilisateurs réels et remet à jour userCount sans bloquer le stream.
Future<void> _resyncUserCount(FirebaseFirestore db) async {
  try {
    final countSnap = await db.collection('users').count().get();
    final realCount = countSnap.count ?? 0;
    if (realCount > 0) {
      await db.collection('community_totals').doc('stats').update({
        'userCount': realCount,
      });
    }
  } catch (_) {}
}

/// Initialise le document community_totals/stats depuis les données réelles.
/// Retourne les stats calculées immédiatement (sans attendre le prochain snapshot).
Future<CommunityStats> _initializeTotals(
  FirebaseFirestore db, {
  Map<String, dynamic>? existingData,
}) async {
  // Valeurs déjà présentes dans le document (pour ne pas écraser)
  final existingScans = (existingData?['totalScans'] as num?)?.toInt() ?? 0;
  final existingCo2   = (existingData?['totalCo2Grams'] as num?)?.toDouble() ?? 0.0;

  // count() fonctionne sur tous les plans Firestore (Spark inclus)
  int userCount = 0;
  try {
    final countSnap = await db.collection('users').count().get();
    userCount = countSnap.count ?? 0;
  } catch (_) {}

  // sum() nécessite le plan Blaze — on tente, mais on ne bloque pas si ça échoue
  int totalScans    = existingScans;
  double totalCo2   = existingCo2;
  try {
    final agg = await db.collection('users').aggregate(
      sum('scansCount'),
      sum('co2Saved'),
    ).get();
    final aggScans = (agg.getSum('scansCount') as num?)?.toInt() ?? 0;
    final aggCo2   = (agg.getSum('co2Saved')  as num?)?.toDouble() ?? 0.0;
    // On prend le max entre la valeur existante et l'agrégat (évite de rétrograder)
    if (aggScans > totalScans) totalScans = aggScans;
    if (aggCo2   > totalCo2)   totalCo2   = aggCo2;
  } catch (_) {
    // Plan Spark : sum() non disponible, on conserve les valeurs existantes
  }

  // Écriture du document complet (merge pour ne pas supprimer d'autres champs)
  try {
    await db.collection('community_totals').doc('stats').set({
      'totalScans':    totalScans,
      'totalCo2Grams': totalCo2,
      'userCount':     userCount,
    }, SetOptions(merge: true));
  } catch (_) {}

  final kg       = (totalCo2 / 1000).round();
  final progress = (totalScans / 10000.0).clamp(0.0, 1.0);

  return CommunityStats(
    users:      userCount,
    scans:      totalScans,
    kgRecycled: kg,
    progress:   progress,
  );
}
