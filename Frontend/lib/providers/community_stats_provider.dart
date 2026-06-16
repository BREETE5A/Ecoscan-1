import 'dart:async';
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
  final controller = StreamController<CommunityStats>();

  Future<void> fetch() async {
    try {
      // Agrégation serveur — pas de limite, tous les utilisateurs
      final aggResult = await db.collection('users').aggregate(
        count(),
        sum('scansCount'),
        sum('co2Saved'),
      ).get();

      int totalScans      = (aggResult.getSum('scansCount') as num?)?.toInt()    ?? 0;
      double totalCo2Grams = (aggResult.getSum('co2Saved')  as num?)?.toDouble() ?? 0.0;
      int users           = aggResult.count ?? 0;

      // Ajouter les données des comptes supprimés préservées dans community_totals
      try {
        final totals = await db.collection('community_totals').doc('stats').get();
        if (totals.exists) {
          final data = totals.data()!;
          totalScans      += (data['deletedScans'] as num?)?.toInt()    ?? 0;
          totalCo2Grams   += (data['deletedCo2']  as num?)?.toDouble() ?? 0.0;
        }
      } catch (_) {}

      final kg       = (totalCo2Grams / 1000).round(); // grammes → kilogrammes
      final progress = (totalScans / 10000.0).clamp(0.0, 1.0);

      if (!controller.isClosed) {
        controller.add(CommunityStats(
          users:      users,
          scans:      totalScans,
          kgRecycled: kg,
          progress:   progress,
        ));
      }
    } catch (_) {
      if (!controller.isClosed) controller.add(const CommunityStats());
    }
  }

  fetch();
  // Rafraîchissement toutes les 5 minutes
  final timer = Timer.periodic(const Duration(minutes: 5), (_) => fetch());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
