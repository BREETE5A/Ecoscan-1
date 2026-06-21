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

// Flag pour ne faire le resync qu'une seule fois par session
bool _sessionResynced = false;

final communityStatsProvider = StreamProvider<CommunityStats>((ref) {
  final db = FirebaseFirestore.instance;

  // Au premier accès de la session : recalcule les vrais totaux depuis les docs utilisateurs
  if (!_sessionResynced) {
    _sessionResynced = true;
    _resyncAllTotals(db);
  }

  return db
      .collection('community_totals')
      .doc('stats')
      .snapshots()
      .map((snap) {
    final data        = snap.exists ? snap.data() : null;
    final totalScans  = (data?['totalScans']    as num?)?.toInt()    ?? 0;
    final totalCo2    = (data?['totalCo2Grams'] as num?)?.toDouble() ?? 0.0;
    final users       = ((data?['userCount']    as num?)?.toInt()    ?? 0).clamp(0, 999999999);
    final kg          = (totalCo2 / 1000).round();
    final progress    = (totalScans / 10000.0).clamp(0.0, 1.0);

    return CommunityStats(
      users:      users,
      scans:      totalScans,
      kgRecycled: kg,
      progress:   progress,
    );
  });
});

/// Lit tous les docs utilisateurs et recalcule les vrais totaux communautaires.
/// Fonctionne sur tous les plans Firestore (Spark inclus).
Future<void> _resyncAllTotals(FirebaseFirestore db) async {
  try {
    final usersSnap = await db.collection('users').get();
    int totalScans  = 0;
    double totalCo2 = 0.0;

    for (final doc in usersSnap.docs) {
      totalScans += (doc.data()['scansCount'] as num?)?.toInt()    ?? 0;
      totalCo2   += (doc.data()['co2Saved']   as num?)?.toDouble() ?? 0.0;
    }

    await db.collection('community_totals').doc('stats').set({
      'totalScans':    totalScans,
      'totalCo2Grams': totalCo2,
      'userCount':     usersSnap.docs.length,
    }, SetOptions(merge: true));
  } catch (_) {}
}
