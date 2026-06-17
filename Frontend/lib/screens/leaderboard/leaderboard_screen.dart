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

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final allAsync = ref.watch(_leaderboardStream);

    // Verrou : 20 scans requis pour accéder au classement
    final statsAsync = ref.watch(userStatsStreamProvider);
    final currentScans = statsAsync.when(
      data: (u) => u.scans,
      loading: () => user.scans,
      error: (_, _) => user.scans,
    );
    if (currentScans < 20) {
      return Scaffold(
        body: SafeArea(child: _LeaderboardLocked(currentScans: currentScans, isDark: isDark)),
      );
    }

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
                  final players = all.take(10).toList();

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

// ── Écran de verrou Classement (requis : 20 scans / badge Champion Vert) ─────
class _LeaderboardLocked extends StatelessWidget {
  final int currentScans;
  final bool isDark;
  const _LeaderboardLocked({required this.currentScans, required this.isDark});

  static const _required = 20;

  @override
  Widget build(BuildContext context) {
    final progress = (currentScans / _required).clamp(0.0, 1.0);
    final remaining = _required - currentScans;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
              border: Border.all(
                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.leaderboard_rounded,
                color: Color(0xFF7B1FA2), size: 46),
          ),
          const SizedBox(height: 24),
          const Text(
            'Classement verrouillé',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Badge requis : Champion Vert',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B1FA2),
                        ),
                      ),
                      Text(
                        'Réalisez $_required scans pour rejoindre le classement national',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression : $currentScans/$_required scans',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$remaining restant${remaining > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B1FA2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor: isDark ? AppColors.darkInput : AppColors.inputBg,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Continuez à scanner des déchets pour grimper dans le classement !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
