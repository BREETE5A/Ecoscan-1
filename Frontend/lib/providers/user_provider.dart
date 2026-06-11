import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/scan_result_model.dart';
import '../services/storage_service.dart';
import '../services/n8n_service.dart';

// Stream Firestore en temps réel des stats utilisateur (co2, points, scans)
final userStatsStreamProvider = StreamProvider<UserModel>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value(ref.read(userProvider));
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return ref.read(userProvider);
    final data = doc.data()!;
    final fsPoints = (data['ecoPoints'] as num?)?.toInt() ?? 0;
    final fsScans = (data['scansCount'] as num?)?.toInt() ?? 0;
    final fsCo2 = (data['co2Saved'] as num?)?.toDouble() ?? 0.0;
    final fsStreak = (data['streak'] as num?)?.toInt() ?? 0;
    final rawName = ((data['displayName'] as String?) ?? '').trim();
    final emailFallback = FirebaseAuth.instance.currentUser?.email?.split('@').first ?? '';
    final fsName = rawName.isNotEmpty ? rawName : (emailFallback.isNotEmpty ? emailFallback : 'EcoUser');
    final rawCity = ((data['city'] as String?) ?? '').trim();
    final fsCity = rawCity.isNotEmpty ? rawCity : '';
    int badges = 0;
    if (fsScans >= 1) badges++;
    if (fsScans >= 5) badges++;
    if (fsScans >= 10) badges++;
    if (fsScans >= 50) badges++;
    if (fsPoints >= 100) badges++;
    if (fsPoints >= 500) badges++;
    return UserModel(
      id: uid,
      name: fsName,
      city: fsCity,
      points: fsPoints,
      scans: fsScans,
      badges: badges,
      rank: 0,
      level: (fsPoints ~/ 200) + 1,
      xp: fsPoints % 200,
      xpMax: 200,
      co2Saved: fsCo2,
      weeklyGoalKg: 10.0,
      weeklyProgress: (fsCo2 / 10000).clamp(0.0, 1.0),
      streak: fsStreak,
    );
  });
});

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  final notifier = UserNotifier();
  final fbUser = FirebaseAuth.instance.currentUser;
  if (fbUser != null) {
    notifier.loadFromStorage(
      firebaseName: fbUser.displayName?.trim().isNotEmpty == true
          ? fbUser.displayName
          : fbUser.email?.split('@').first,
      firebaseUid: fbUser.uid,
    );
  } else {
    notifier.loadFromStorage();
  }
  return notifier;
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(UserModel.empty());

  Future<void> loadFromStorage({
    String? firebaseName,
    String? firebaseUid,
    String? firebaseCity,
  }) async {
    // Firestore en priorité si connecté
    if (firebaseUid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final fsPoints = (data['ecoPoints']  as num?)?.toInt()    ?? 0;
          final fsScans  = (data['scansCount'] as num?)?.toInt()    ?? 0;
          final fsCo2    = (data['co2Saved']   as num?)?.toDouble() ?? 0.0;
          final fsStreak = (data['streak']     as num?)?.toInt()    ?? 0;
          final rawName  = ((data['displayName'] as String?) ?? '').trim();
          final fsName   = rawName.isNotEmpty ? rawName : (firebaseName?.trim().isNotEmpty == true ? firebaseName!.trim() : 'Utilisateur');
          final rawCity  = ((data['city'] as String?) ?? '').trim();
          final fsCity   = rawCity.isNotEmpty ? rawCity : (firebaseCity?.trim().isNotEmpty == true ? firebaseCity!.trim() : 'Maroc');

          // Calcul du rang réel (utilisateurs avec plus de points)
          int fsRank = 1;
          try {
            final countSnap = await FirebaseFirestore.instance
                .collection('users')
                .where('ecoPoints', isGreaterThan: fsPoints)
                .count()
                .get();
            fsRank = (countSnap.count ?? 0) + 1;
          } catch (_) {}

          // Synchroniser SharedPreferences avec Firestore
          await StorageService.setPoints(fsPoints);
          await StorageService.setScans(fsScans);
          await StorageService.setCo2(fsCo2);

          final history = await StorageService.getHistory();
          state = UserModel(
            id:             firebaseUid,
            name:           fsName,
            city:           fsCity,
            points:         fsPoints,
            scans:          fsScans,
            badges:         _computeBadges(fsScans, fsPoints),
            rank:           fsRank,
            level:          (fsPoints ~/ 200) + 1,
            xp:             fsPoints % 200,
            xpMax:          200,
            co2Saved:       fsCo2,
            weeklyGoalKg:   10.0,
            weeklyProgress: (fsCo2 / 10000).clamp(0.0, 1.0),
            recentScans:    history.take(4).toList(),
            streak:         fsStreak,
          );
          return;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Firestore read error: $e');
        // Fallback sur SharedPreferences si Firestore échoue
      }
    }

    // Fallback : SharedPreferences uniquement (offline ou non connecté)
    final scans   = await StorageService.getScans();
    final points  = await StorageService.getPoints();
    final co2     = await StorageService.getCo2();
    final history = await StorageService.getHistory();

    state = UserModel(
      id:             firebaseUid ?? 'local_user',
      name:           (firebaseName?.trim().isNotEmpty == true) ? firebaseName!.trim() : 'Utilisateur',
      city:           (firebaseCity?.trim().isNotEmpty == true) ? firebaseCity!.trim() : 'Maroc',
      points:         points,
      scans:          scans,
      badges:         _computeBadges(scans, points),
      rank:           0,
      level:          (points ~/ 200) + 1,
      xp:             points % 200,
      xpMax:          200,
      co2Saved:       co2,
      weeklyGoalKg:   10.0,
      weeklyProgress: (co2 / 10000).clamp(0.0, 1.0),
      recentScans:    history.take(4).toList(),
    );
  }

  Future<void> recordScan(ScanResultModel result) async {
    final uid = state.id != 'local_user' ? state.id : null;
    final fbUser = FirebaseAuth.instance.currentUser;
    String? fcmToken;
    if (uid != null) {
      try { fcmToken = await FirebaseMessaging.instance.getToken(); } catch (_) {}
    }
    await StorageService.addScan(result, 10,
      uid:      uid,
      nom:      state.name,
      email:    fbUser?.email,
      fcmToken: fcmToken,
    );
    if (uid != null && result.category == 'electronique') {
      N8nService.alerteDanger(
        nom:        state.name,
        email:      fbUser?.email ?? '',
        typeDechet: result.category,
        fcmToken:   fcmToken ?? '',
      ).catchError((_) {});
    }
    await loadFromStorage(
      firebaseName: state.name,
      firebaseUid:  uid,
      firebaseCity: state.city,
    );
  }

  void reset() {
    state = UserModel.empty();
  }

  void updateProfile({String? name, String? city}) {
    state = state.copyWith(name: name, city: city);
  }

  int _computeBadges(int scans, int points) {
    int count = 0;
    if (scans >= 1)    count++;
    if (scans >= 5)    count++;
    if (scans >= 10)   count++;
    if (scans >= 50)   count++;
    if (points >= 100) count++;
    if (points >= 500) count++;
    return count;
  }
}
