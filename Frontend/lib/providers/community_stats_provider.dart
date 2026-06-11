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
    // Points des utilisateurs actifs (top 100)
    int totalPoints = 0;
    for (final doc in snap.docs) {
      totalPoints += (doc.data()['ecoPoints'] as num?)?.toInt() ?? 0;
    }

    // Lecture du document de totaux (userCount + deletedPoints)
    int users = snap.docs.length;
    try {
      final totals = await db.collection('community_totals').doc('stats').get();
      if (totals.exists) {
        final data = totals.data()!;
        // userCount maintenu par incréments/décréments à la création/suppression
        final storedCount = (data['userCount'] as num?)?.toInt();
        if (storedCount != null && storedCount > 0) users = storedCount;
        totalPoints += (data['deletedPoints'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}

    final scans = (totalPoints / 10).round();
    final kg = (scans * 0.35).round();
    final progress = (totalPoints / 50000).clamp(0.0, 1.0);
    return CommunityStats(
      users: users,
      scans: scans,
      kgRecycled: kg,
      progress: progress,
    );
  });
});
