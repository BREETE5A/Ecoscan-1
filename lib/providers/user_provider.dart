import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/scan_result_model.dart';
import '../services/storage_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel>(
  (ref) => UserNotifier()..loadFromStorage(),
);

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
          final fsName   = (data['displayName'] as String?)         ?? firebaseName ?? 'Utilisateur';
          final fsCity   = (data['city']        as String?)         ?? firebaseCity ?? 'Maroc';

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
            rank:           (data['rank'] as num?)?.toInt() ?? 0,
            level:          (fsPoints ~/ 200) + 1,
            xp:             fsPoints % 200,
            xpMax:          200,
            co2Saved:       fsCo2,
            weeklyGoalKg:   10.0,
            weeklyProgress: (fsCo2 / 10000).clamp(0.0, 1.0),
            recentScans:    history.take(4).toList(),
          );
          return;
        }
      } catch (e) {
        debugPrint('Firestore read error: $e');
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
      name:           firebaseName ?? 'Utilisateur',
      city:           firebaseCity ?? 'Maroc',
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
    await StorageService.addScan(result, 10, uid: uid);
    await loadFromStorage(
      firebaseName: state.name,
      firebaseUid:  uid,
      firebaseCity: state.city,
    );
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
