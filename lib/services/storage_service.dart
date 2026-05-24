import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result_model.dart';

class StorageService {
  static const _keyScans   = 'user_scans_count';
  static const _keyPoints  = 'user_points';
  static const _keyCo2     = 'user_co2_grams';
  static const _keyHistory = 'scan_history';

  static Future<int> getScans() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyScans) ?? 0;
  }

  static Future<int> getPoints() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyPoints) ?? 0;
  }

  static Future<double> getCo2() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_keyCo2) ?? 0.0;
  }

  static Future<void> setPoints(int value) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyPoints, value);
  }

  static Future<void> setScans(int value) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyScans, value);
  }

  static Future<void> setCo2(double value) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_keyCo2, value);
  }

  static Future<void> addScan(
    ScanResultModel result,
    int pointsEarned, {
    String? uid,
  }) async {
    final p = await SharedPreferences.getInstance();

    final newScans  = (p.getInt(_keyScans)  ?? 0) + 1;
    final newPoints = (p.getInt(_keyPoints) ?? 0) + pointsEarned;
    final newCo2    = (p.getDouble(_keyCo2) ?? 0) + result.co2SavedPerKg * 100;

    await p.setInt(_keyScans,  newScans);
    await p.setInt(_keyPoints, newPoints);
    await p.setDouble(_keyCo2, newCo2);

    // Sync Firestore si connecté
    if (uid != null) {
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        await userRef.update({
          'ecoPoints':  FieldValue.increment(pointsEarned),
          'scansCount': FieldValue.increment(1),
          'co2Saved':   FieldValue.increment(result.co2SavedPerKg * 100),
          'lastScanAt': FieldValue.serverTimestamp(),
        });
        await userRef.collection('scans').add({
          'category':   result.category,
          'binColor':   result.binColor,
          'confidence': result.confidence,
          'co2Saved':   result.co2SavedPerKg * 100,
          'scannedAt':  FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore sync error: $e');
      }
    }

    // Historique local
    final raw = p.getString(_keyHistory);
    final history = raw != null
        ? List<Map<String, dynamic>>.from(
            (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)))
        : <Map<String, dynamic>>[];
    history.insert(0, result.toJson());
    if (history.length > 50) history.removeLast();
    await p.setString(_keyHistory, jsonEncode(history));
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyHistory);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
        (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)));
  }

  static Future<void> clearHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyHistory);
  }

  static Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyScans);
    await p.remove(_keyPoints);
    await p.remove(_keyCo2);
    await p.remove(_keyHistory);
  }
}
