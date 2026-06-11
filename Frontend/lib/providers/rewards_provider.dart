import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_provider.dart';

// state = set d'IDs de récompenses échangées
final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, Set<String>>((ref) {
  final notifier = RewardsNotifier(ref);
  notifier.load();
  return notifier;
});

class RewardsNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  RewardsNotifier(this._ref) : super({});

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<void> load() async {
    final doc = _doc;
    if (doc == null) return;
    try {
      final snap = await doc.get();
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final list = (data['redeemedRewards'] as List?)
              ?.map((e) => e.toString())
              .toSet() ??
          {};
      state = list;
    } catch (e) {
      if (kDebugMode) debugPrint('RewardsProvider load error: $e');
    }
  }

  // Retourne true si succès, false si points insuffisants
  Future<bool> redeem(String rewardId, int cost) async {
    if (state.contains(rewardId)) return false;

    final user = _ref.read(userProvider);
    if (user.points < cost) return false;

    final doc = _doc;
    if (doc == null) return false;

    try {
      await doc.update({
        'ecoPoints': FieldValue.increment(-cost),
        'redeemedRewards': FieldValue.arrayUnion([rewardId]),
      });
      state = {...state, rewardId};
      // Recharge le user pour mettre à jour les points affichés
      await _ref.read(userProvider.notifier).loadFromStorage(
            firebaseUid: _uid,
            firebaseName: user.name,
            firebaseCity: user.city,
          );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('RewardsProvider redeem error: $e');
      return false;
    }
  }

  bool isRedeemed(String rewardId) => state.contains(rewardId);
}
