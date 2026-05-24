import 'package:shared_preferences/shared_preferences.dart';
import '../data/challenges_data.dart';
import '../data/rewards_data.dart';
import '../data/did_you_know_data.dart';

/// Hourly rotation service — index advances every hour using SharedPreferences timestamps.
class RotationService {
  static const _kChallengeKey = 'rotation_challenge_index';
  static const _kChallengeTs = 'rotation_challenge_ts';
  static const _kRewardKey = 'rotation_reward_index';
  static const _kRewardTs = 'rotation_reward_ts';
  static const _kFactKey = 'rotation_fact_index';
  static const _kFactTs = 'rotation_fact_ts';

  /// Returns the current daily challenge (rotates every 24 h).
  static Future<ChallengeData> getCurrentChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final index = await _rotatedIndex(
      prefs,
      indexKey: _kChallengeKey,
      tsKey: _kChallengeTs,
      listLength: allChallenges.length,
      rotationHours: 24,
    );
    return allChallenges[index];
  }

  /// Returns the featured reward (rotates every 24 h).
  static Future<RewardData> getFeaturedReward() async {
    final prefs = await SharedPreferences.getInstance();
    final index = await _rotatedIndex(
      prefs,
      indexKey: _kRewardKey,
      tsKey: _kRewardTs,
      listLength: allRewards.length,
      rotationHours: 24,
    );
    return allRewards[index];
  }

  /// Returns the current "Did you know?" fact (rotates every hour).
  static Future<DidYouKnowFact> getCurrentFact() async {
    final prefs = await SharedPreferences.getInstance();
    final index = await _rotatedIndex(
      prefs,
      indexKey: _kFactKey,
      tsKey: _kFactTs,
      listLength: allFacts.length,
      rotationHours: 1,
    );
    return allFacts[index];
  }

  /// Returns how many minutes remain until the next fact rotation.
  static Future<Duration> timeUntilNextFactRotation() async {
    final prefs = await SharedPreferences.getInstance();
    final tsMillis = prefs.getInt(_kFactTs);
    if (tsMillis == null) return Duration.zero;
    final lastRotation = DateTime.fromMillisecondsSinceEpoch(tsMillis);
    final nextRotation = lastRotation.add(const Duration(hours: 1));
    final remaining = nextRotation.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns how many hours remain until the next daily challenge/reward rotation.
  static Future<Duration> timeUntilNextDailyRotation() async {
    final prefs = await SharedPreferences.getInstance();
    final tsMillis = prefs.getInt(_kChallengeTs);
    if (tsMillis == null) return Duration.zero;
    final lastRotation = DateTime.fromMillisecondsSinceEpoch(tsMillis);
    final nextRotation = lastRotation.add(const Duration(hours: 24));
    final remaining = nextRotation.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  static Future<int> _rotatedIndex(
    SharedPreferences prefs, {
    required String indexKey,
    required String tsKey,
    required int listLength,
    required int rotationHours,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final storedTs = prefs.getInt(tsKey);
    final storedIndex = prefs.getInt(indexKey) ?? 0;

    if (storedTs == null) {
      // First launch — seed with deterministic index based on current hour.
      final seed = DateTime.now().millisecondsSinceEpoch ~/ (rotationHours * 3600000);
      final index = seed % listLength;
      await prefs.setInt(indexKey, index);
      await prefs.setInt(tsKey, now);
      return index;
    }

    final elapsed = Duration(milliseconds: now - storedTs);
    if (elapsed.inHours >= rotationHours) {
      final newIndex = (storedIndex + 1) % listLength;
      await prefs.setInt(indexKey, newIndex);
      await prefs.setInt(tsKey, now);
      return newIndex;
    }

    return storedIndex;
  }
}
