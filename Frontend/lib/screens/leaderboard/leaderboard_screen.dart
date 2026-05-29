import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

// ── Firestore stream ──────────────────────────────────────────────────────────

class _LeaderEntry {
  final String uid;
  final String name;
  final int points;
  final int rank;
  final String city;
  const _LeaderEntry({
    required this.uid,
    required this.name,
    required this.points,
    required this.rank,
    required this.city,
  });
}

final _leaderboardStream = StreamProvider<List<_LeaderEntry>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('ecoPoints', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.asMap().entries.map((e) {
            final d = e.value.data();
            return _LeaderEntry(
              uid: e.value.id,
              name: ((d['displayName'] as String?) ?? 'Utilisateur').trim(),
              points: (d['ecoPoints'] as num?)?.toInt() ?? 0,
              rank: e.key + 1,
              city: ((d['city'] as String?) ?? '').trim(),
            );
          }).toList());
});

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _tabIdx = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() => _tabIdx = _tab.index));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final allAsync = ref.watch(_leaderboardStream);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.leaderboard,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  Text(
                    s.bestEcoCitizens,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 14),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tab,
                      tabs: [Tab(text: s.myCity), Tab(text: s.national)],
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      dividerColor: Colors.transparent,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: allAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ),
                ),
                data: (all) {
                  final national = all.take(10).toList();
                  final cityEntries = all
                      .where((e) =>
                          user.city.isNotEmpty &&
                          e.city.toLowerCase() == user.city.toLowerCase())
                      .take(10)
                      .toList();
                  // Re-rank city entries
                  final city = cityEntries.asMap().entries.map((e) =>
                    _LeaderEntry(
                      uid: e.value.uid,
                      name: e.value.name,
                      points: e.value.points,
                      rank: e.key + 1,
                      city: e.value.city,
                    )).toList();

                  final players = _tabIdx == 0
                      ? (city.isEmpty ? national : city)
                      : national;

                  if (players.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun utilisateur pour l\'instant',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  final top3 = players.take(3).toList();
                  final rest = players.skip(3).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _Podium(top3: top3, isDark: isDark, myUid: myUid),
                        const SizedBox(height: 20),
                        ...List.generate(
                          rest.length,
                          (i) => _RankRow(
                            entry: rest[i],
                            isDark: isDark,
                            isMe: rest[i].uid == myUid,
                          )
                              .animate(delay: (200 + i * 70).ms)
                              .fadeIn(duration: 350.ms)
                              .slideX(begin: 0.08),
                        ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<_LeaderEntry> top3;
  final bool isDark;
  final String myUid;
  const _Podium({required this.top3, required this.isDark, required this.myUid});

  static const _colors = [
    Color(0xFFB0BEC5),
    Color(0xFFF9CA24),
    Color(0xFFFF8A65),
  ];

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox.shrink();

    // order: 2nd, 1st, 3rd
    final order = [top3[1], top3[0], top3[2]];
    final heights = [110.0, 150.0, 80.0];
    final avatarSizes = [52.0, 62.0, 46.0];
    final delays = [200, 100, 300];

    return SizedBox(
      height: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final entry = order[i];
          final color = entry.uid == myUid
              ? AppColors.primary
              : _colors[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _PodiumSlot(
              entry: entry,
              height: heights[i],
              avatarSize: avatarSizes[i],
              delay: delays[i],
              isDark: isDark,
              color: color,
              showCrown: i == 1,
              isMe: entry.uid == myUid,
            ),
          );
        }),
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final _LeaderEntry entry;
  final double height;
  final double avatarSize;
  final int delay;
  final bool isDark;
  final Color color;
  final bool showCrown;
  final bool isMe;

  const _PodiumSlot({
    required this.entry,
    required this.height,
    required this.avatarSize,
    required this.delay,
    required this.isDark,
    required this.color,
    this.showCrown = false,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + delay),
      curve: Curves.elasticOut,
      builder: (_, v, child) =>
          Transform.scale(scaleY: v, alignment: Alignment.bottomCenter, child: child),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showCrown)
            const Text('👑', style: TextStyle(fontSize: 22))
                .animate(delay: 600.ms)
                .scale(
                  begin: const Offset(0, 0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, color: color, size: avatarSize * 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            entry.name.split(' ').first,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          Text(
            '${entry.points} pts',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 72,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.7), color],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rank row ──────────────────────────────────────────────────────────────────

class _RankRow extends ConsumerWidget {
  final _LeaderEntry entry;
  final bool isDark;
  final bool isMe;
  const _RankRow({required this.entry, required this.isDark, required this.isMe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final color = isMe ? AppColors.primary : AppColors.teal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isMe
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isMe ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Icon(Icons.person_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ),
            if (isMe)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  s.youLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              '${entry.points} pts',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
