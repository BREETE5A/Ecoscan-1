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
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('ecoPoints', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) {
    final users = snap.docs.length;
    int totalPoints = 0;
    for (final doc in snap.docs) {
      totalPoints += (doc.data()['ecoPoints'] as num?)?.toInt() ?? 0;
    }
    // 10 pts en moyenne par scan
    final scans = (totalPoints / 10).round();
    final kg = (scans * 0.35).round();
    // Objectif communautaire : 50 000 pts
    final progress = (totalPoints / 50000).clamp(0.0, 1.0);
    return CommunityStats(
      users: users,
      scans: scans,
      kgRecycled: kg,
      progress: progress,
    );
  });
});
