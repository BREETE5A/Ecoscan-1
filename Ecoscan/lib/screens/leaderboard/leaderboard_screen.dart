import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _tabIdx = 0;

  static const _cityPlayers = [
    _Player('Amine Benali', 1240, 1, Color(0xFFF9CA24), Icons.emoji_events_rounded),
    _Player('Sara Idrissi', 1180, 2, Color(0xFFB0BEC5), Icons.emoji_events_rounded),
    _Player('Karim Zoubir', 1050, 3, Color(0xFFFF8A65), Icons.emoji_events_rounded),
    _Player('Nadia Tahir', 980, 4, AppColors.primary, Icons.person_rounded),
    _Player('Omar Cherkaoui', 920, 5, AppColors.teal, Icons.person_rounded),
    _Player('Fatima Alami', 870, 6, AppColors.purple, Icons.person_rounded),
    _Player('Youssef Mansouri', 810, 7, AppColors.info, Icons.person_rounded),
    _Player('Leila Bennis', 760, 8, AppColors.accent, Icons.person_rounded),
  ];

  static const _nationPlayers = [
    _Player('Mehdi Bensalem', 4200, 1, Color(0xFFF9CA24), Icons.emoji_events_rounded),
    _Player('Rachid Ouali', 3950, 2, Color(0xFFB0BEC5), Icons.emoji_events_rounded),
    _Player('Zineb Hassani', 3700, 3, Color(0xFFFF8A65), Icons.emoji_events_rounded),
    _Player('Amine Benali', 1240, 4, AppColors.primary, Icons.person_rounded),
    _Player('Imane Berrada', 1190, 5, AppColors.teal, Icons.person_rounded),
    _Player('Hassan Moukhliss', 1100, 6, AppColors.purple, Icons.person_rounded),
  ];

  List<_Player> get _players => _tabIdx == 0 ? _cityPlayers : _nationPlayers;

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
    final top3 = _players.take(3).toList();
    final rest = _players.skip(3).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classement',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  Text(
                    'Les meilleurs éco-citoyens',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 14),
                  // Tab bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tab,
                      tabs: const [Tab(text: 'Ma Ville'), Tab(text: 'National')],
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Podium
                    _Podium(top3: top3, isDark: isDark),
                    const SizedBox(height: 20),
                    // Rest of the list
                    ...List.generate(
                      rest.length,
                      (i) => _RankRow(
                        player: rest[i],
                        isDark: isDark,
                        isMe: rest[i].name == 'Amine Benali',
                      )
                          .animate(delay: (200 + i * 70).ms)
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.08),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<_Player> top3;
  final bool isDark;
  const _Podium({required this.top3, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd
          _PodiumSlot(
            player: top3[1],
            height: 120,
            avatarSize: 56,
            delay: 200,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          // 1st
          _PodiumSlot(
            player: top3[0],
            height: 160,
            avatarSize: 68,
            delay: 100,
            isDark: isDark,
            showCrown: true,
          ),
          const SizedBox(width: 8),
          // 3rd
          _PodiumSlot(
            player: top3[2],
            height: 90,
            avatarSize: 50,
            delay: 300,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final _Player player;
  final double height;
  final double avatarSize;
  final int delay;
  final bool isDark;
  final bool showCrown;
  const _PodiumSlot({
    required this.player,
    required this.height,
    required this.avatarSize,
    required this.delay,
    required this.isDark,
    this.showCrown = false,
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
              color: player.color.withValues(alpha: 0.2),
              border: Border.all(color: player.color, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: player.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(Icons.person_rounded,
                color: player.color, size: avatarSize * 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            player.name.split(' ')[0],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          Text(
            '${player.points} pts',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: player.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 72,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  player.color.withValues(alpha: 0.7),
                  player.color,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                '#${player.rank}',
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

class _RankRow extends StatelessWidget {
  final _Player player;
  final bool isDark;
  final bool isMe;
  const _RankRow(
      {required this.player, required this.isDark, required this.isMe});

  @override
  Widget build(BuildContext context) {
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
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35), width: 1.5)
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
                '#${player.rank}',
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
                color: player.color.withValues(alpha: 0.15),
                border: Border.all(
                    color: player.color.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Icon(Icons.person_rounded,
                  color: player.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                player.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight:
                      isMe ? FontWeight.w700 : FontWeight.w500,
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
                child: const Text(
                  'Vous',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              '${player.points} pts',
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

class _Player {
  final String name;
  final int points;
  final int rank;
  final Color color;
  final IconData icon;
  const _Player(this.name, this.points, this.rank, this.color, this.icon);
}
