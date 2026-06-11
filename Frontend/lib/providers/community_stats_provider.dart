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

  // Stream principal : top-100 users pour les points
  final usersStream = db
      .collection('users')
      .orderBy('ecoPoints', descending: true)
      .limit(100)
      .snapshots();

  return usersStream.asyncMap((snap) async {
    int totalPoints = 0;
    int totalScans  = 0;
    for (final doc in snap.docs) {
      totalPoints += (doc.data()['ecoPoints']   as num?)?.toInt() ?? 0;
      totalScans  += (doc.data()['scansCount']  as num?)?.toInt() ?? 0;
    }

    // Compter uniquement les docs avec lastSeen (écrit à chaque login).
    // Les docs orphelins (comptes supprimés depuis la Console Firebase)
    // n'ont jamais lastSeen → ils sont exclus automatiquement.
    // Fallback sur snap.docs.length avant le premier login post-déploiement.
    final activeDocs = snap.docs.where((d) => d.data()['lastSeen'] != null).toList();
    int users = activeDocs.isNotEmpty ? activeDocs.length : snap.docs.length;
    try {
      final totals = await db.collection('community_totals').doc('stats').get();
      if (totals.exists) {
        final data = totals.data()!;
        // On garde deletedPoints/deletedScans pour ne pas perdre l'impact
        // des comptes supprimés, mais on ignore storedCount (stale)
        totalPoints += (data['deletedPoints'] as num?)?.toInt() ?? 0;
        totalScans  += (data['deletedScans']  as num?)?.toInt() ?? 0;
      }
    } catch (_) {}

    final kg       = (totalScans * 0.35).round();
    final progress = (totalPoints / 50000).clamp(0.0, 1.0);
    return CommunityStats(
      users: users,
      scans: totalScans,
      kgRecycled: kg,
      progress: progress,
    );
  });
});
