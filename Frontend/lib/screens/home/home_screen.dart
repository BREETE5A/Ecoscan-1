import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/did_you_know_data.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../models/user_model.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/did_you_know_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterCtrl;
  late Animation<double> _counterAnim;
  final _scrollCtrl = ScrollController();
  bool _headerCollapsed = false;

  @override
  void initState() {
    super.initState();
    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _counterAnim = CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOut);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    // expandedHeight(180) - kToolbarHeight(56) = 124
    final collapsed = _scrollCtrl.offset > 124;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final s    = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final avatarPath = ref.watch(avatarPathProvider);

    final quickActions = [
      (Icons.emoji_events_rounded,    s.qaBadges,       '/badges',      const Color(0xFFF39C12)),
      (Icons.menu_book_rounded,       s.qaGuide,        '/guide',       const Color(0xFF3498DB)),
      (Icons.leaderboard_rounded,     s.qaLeaderboard,  '/leaderboard', const Color(0xFF9B59B6)),
      (Icons.bar_chart_rounded,       s.qaStats,        '/stats',       const Color(0xFF1ABC9C)),
      (Icons.emoji_flags_rounded,     s.qaChallenges,   '/challenges',  const Color(0xFFFF6B35)),
      (Icons.history_rounded,         s.qaHistory,      '/history',     const Color(0xFF607D8B)),
      (Icons.card_giftcard_rounded,   s.qaRewards,      '/rewards',     const Color(0xFFE91E63)),
      (Icons.co2_rounded,             s.qaCalculator,   '/stats',       const Color(0xFF00BCD4)),
    ];

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            // Logo visible uniquement quand la barre est collapsée (scroll)
            title: _headerCollapsed
                ? ClipOval(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo + Bonjour + icônes sur la même ligne ──────
                        Row(
                          children: [
                            // Logo
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icons/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ).animate().fadeIn(duration: 400.ms).scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            ),
                            const SizedBox(width: 10),
                            // Bonjour + sous-titre
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${s.greetingPrefix}, ${user.name.split(' ').first} 🌿',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.1),
                                  Text(
                                    s.readySubtitle,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ).animate().fadeIn(duration: 350.ms, delay: 80.ms),
                                ],
                              ),
                            ),
                            // Icônes
                            GestureDetector(
                              onTap: () => context.go('/notifications'),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white, size: 20),
                                  ),
                                  Positioned(
                                    top: 7, right: 7,
                                    child: Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF6B6B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.go('/profile'),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      width: 2),
                                  image: avatarPath != null
                                      ? DecorationImage(
                                          image: FileImage(File(avatarPath)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: avatarPath == null
                                    ? const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 22)
                                    : null,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 350.ms),
                        const SizedBox(height: 16),
                        // ── Stats mini ─────────────────────────────────────
                        Row(
                          children: [
                            _MiniStat(label: s.points,     value: user.points,          anim: _counterAnim),
                            const SizedBox(width: 16),
                            _MiniStat(label: s.scans,      value: user.scans,           anim: _counterAnim),
                            const SizedBox(width: 16),
                            _MiniStat(label: s.co2Avoided, value: user.co2Saved.toInt(), anim: _counterAnim),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Objectif hebdomadaire ──────────────────────────────
                _WeeklyCard(counterAnim: _counterAnim, s: s, user: user)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 130.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 16),

                // ── Impact environnemental (3 cartes) ──────────────────
                _ImpactRow(anim: _counterAnim, user: user, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 180.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 16),

                // ── Le saviez-vous ? ───────────────────────────────────
                const DidYouKnowCard()
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 200.ms)
                    .slideY(begin: 0.06),
                const SizedBox(height: 20),

                // ── Bouton Scan CTA ────────────────────────────────────
                _ScanCTACard(scanLabel: s.scanProduct, analyzeLabel: s.analyzeEcoImpact)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 220.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 20),

                // ── Défi du jour ───────────────────────────────────────
                _DailyChallengeCard(anim: _counterAnim, dailyLabel: s.dailyChallenge, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 260.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 24),

                // ── Actions rapides ────────────────────────────────────
                _SectionTitle(title: s.quickActions, onSeeAll: null, seeAllLabel: null)
                    .animate().fadeIn(duration: 280.ms, delay: 300.ms),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    quickActions.length,
                    (i) => _QuickActionCard(
                      icon: quickActions[i].$1,
                      label: quickActions[i].$2,
                      route: quickActions[i].$3,
                      color: quickActions[i].$4,
                    )
                        .animate(delay: (80 + i * 40).ms)
                        .fadeIn(duration: 280.ms)
                        .scale(begin: const Offset(0.85, 0.85)),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Catégories de tri ──────────────────────────────────
                _SectionTitle(title: s.sortingCategories, seeAllLabel: s.seeAll, onSeeAll: () => context.go('/guide'))
                    .animate().fadeIn(duration: 280.ms, delay: 360.ms),
                const SizedBox(height: 12),
                _CategoriesRow(s: s)
                    .animate().fadeIn(duration: 350.ms, delay: 380.ms).slideX(begin: 0.08),
                const SizedBox(height: 24),

                // ── Conseil éco ────────────────────────────────────────
                _EcoTipBanner(s: s, lang: lang)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 400.ms)
                    .slideX(begin: 0.08),
                const SizedBox(height: 20),

                // ── Impact communautaire ───────────────────────────────
                _CommunityCard(anim: _counterAnim, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 430.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 24),

                // ── Activité récente ───────────────────────────────────
                _SectionTitle(
                  title: s.recentActivity,
                  seeAllLabel: s.seeAll,
                  onSeeAll: () => context.go('/history'),
                ).animate().fadeIn(duration: 280.ms, delay: 460.ms),
                const SizedBox(height: 12),

                ..._buildActivities(s, isDark),
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivities(AppStrings s, bool isDark) {
    final scans = ref.watch(userProvider).recentScans;
    if (scans.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              s.noActivity,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    const catIcons = <String, IconData>{
      'Plastique':    Icons.opacity_rounded,
      'Verre':        Icons.local_bar_outlined,
      'Métal':        Icons.hardware_rounded,
      'Papier':       Icons.article_outlined,
      'Organique':    Icons.compost_rounded,
      'Électronique': Icons.electrical_services_rounded,
      'Textile':      Icons.checkroom_rounded,
      'Dangereux':    Icons.warning_amber_rounded,
    };
    const catColors = <String, Color>{
      'Plastique':    AppColors.plastic,
      'Verre':        AppColors.glass,
      'Métal':        AppColors.metal,
      'Papier':       AppColors.paper,
      'Organique':    Color(0xFF795548),
      'Électronique': AppColors.electronics,
      'Textile':      Color(0xFF9B59B6),
      'Dangereux':    Color(0xFFE74C3C),
    };

    return List.generate(scans.length, (i) {
      final scan = scans[i];
      final cat = scan['category'] as String? ?? 'Inconnu';
      final date = scan['scanned_at'] != null
          ? DateTime.tryParse(scan['scanned_at'] as String)
          : null;
      final dateStr = date != null
          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
          : '';
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ActivityItem(
          icon: catIcons[cat] ?? Icons.recycling_rounded,
          color: catColors[cat] ?? AppColors.primary,
          title: 'Scan $cat',
          date: dateStr,
          points: '+10 pts',
        ).animate(delay: (460 + i * 60).ms).fadeIn(duration: 280.ms).slideX(begin: 0.08),
      );
    });
  }

  String get lang => ref.read(localeProvider).languageCode;
}

// ── Mini stat header ──────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Animation<double> anim;
  const _MiniStat({required this.label, required this.value, required this.anim});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: anim,
              builder: (_, _) => Text(
                '${(value * anim.value).round()}',
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 18,
                  fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte objectif hebdomadaire ───────────────────────────────────────────────
class _WeeklyCard extends StatelessWidget {
  final Animation<double> counterAnim;
  final AppStrings s;
  final UserModel user;
  const _WeeklyCard({required this.counterAnim, required this.s, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E8449), Color(0xFF27AE60)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.weeklyGoal,
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.thisWeek,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: counterAnim,
            builder: (_, _) => Text(
              '${(user.weeklyGoalKg * user.weeklyProgress * counterAnim.value).toStringAsFixed(1)} kg',
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 38,
                fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
          ),
          Text(
            s.recycled,
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedBuilder(
              animation: counterAnim,
              builder: (_, _) => LinearProgressIndicator(
                value: user.weeklyProgress * counterAnim.value,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(user.weeklyProgress * 100).toInt()}% ${s.ofGoal}',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Impact environnemental (3 mini-cartes) ────────────────────────────────────
class _ImpactRow extends StatelessWidget {
  final Animation<double> anim;
  final UserModel user;
  final AppStrings s;
  const _ImpactRow({required this.anim, required this.user, required this.s});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final co2 = user.co2Saved;
    final items = [
      (Icons.cloud_outlined,      '${(co2 / 1000).toStringAsFixed(1)} kg', s.co2Saved,    const Color(0xFF27AE60)),
      (Icons.park_outlined,       (co2 / 8000).toStringAsFixed(2),         s.treesEquiv,  const Color(0xFF2E7D32)),
      (Icons.water_drop_outlined, '${(co2 * 0.05).toStringAsFixed(0)} L',  s.waterSaved,  const Color(0xFF1ABC9C)),
    ];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: items[i].$4.withValues(alpha: 0.12),
                    blurRadius: 8, offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: items[i].$4.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(items[i].$1, color: items[i].$4, size: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    items[i].$3,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Bouton Scan CTA ───────────────────────────────────────────────────────────
class _ScanCTACard extends StatefulWidget {
  final String scanLabel;
  final String analyzeLabel;
  const _ScanCTACard({required this.scanLabel, required this.analyzeLabel});
  @override
  State<_ScanCTACard> createState() => _ScanCTACardState();
}

class _ScanCTACardState extends State<_ScanCTACard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/scan'),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + _pulseCtrl.value * 0.1,
                child: child,
              ),
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.scanLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                Text(
                  widget.analyzeLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 12, color: Colors.white70,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 18),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

// ── Défi du jour ─────────────────────────────────────────────────────────────
class _DailyChallengeCard extends StatelessWidget {
  final Animation<double> anim;
  final String dailyLabel;
  final AppStrings s;
  const _DailyChallengeCard({required this.anim, required this.dailyLabel, required this.s});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const progress = 1 / 3;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF39C12).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF39C12).withValues(alpha: 0.08),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_flags_rounded,
                    color: Color(0xFFF39C12), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dailyLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    fontWeight: FontWeight.bold, color: Color(0xFFF39C12),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+50 pts',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.bold, color: Color(0xFFF39C12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            s.dailyChallengeTask,
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.challengeProgress1of3,
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress * anim.value,
                backgroundColor: const Color(0xFFF39C12).withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF39C12)),
                minHeight: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Catégories de tri (scroll horizontal) ────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  final AppStrings s;
  const _CategoriesRow({required this.s});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      (Icons.local_drink_outlined,  s.catPlastic,    const Color(0xFFFDD835)),
      (Icons.wine_bar_outlined,     s.catGlass,      const Color(0xFF43A047)),
      (Icons.newspaper_rounded,     s.catPaper,      const Color(0xFF1565C0)),
      (Icons.hardware_rounded,      s.catMetal,      const Color(0xFF546E7A)),
      (Icons.compost_rounded,       s.catOrganic,    const Color(0xFF795548)),
      (Icons.devices_other_rounded, s.catElectronic, const Color(0xFF7B1FA2)),
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => context.go('/guide'),
            child: Container(
              width: 74,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: cat.$3.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: cat.$3.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.$1, color: cat.$3, size: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat.$2,
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Conseil éco ───────────────────────────────────────────────────────────────
class _EcoTipBanner extends StatelessWidget {
  final AppStrings s;
  final String lang;
  const _EcoTipBanner({required this.s, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayIndex = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final fact = allFacts[dayIndex % allFacts.length];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.teal.withValues(alpha: 0.15)
            : AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.didYouKnow,
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fact.factFor(lang),
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12, height: 1.4,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Impact communautaire ──────────────────────────────────────────────────────
class _CommunityCard extends StatelessWidget {
  final Animation<double> anim;
  final AppStrings s;
  const _CommunityCard({required this.anim, required this.s});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1ABC9C).withValues(alpha: 0.12),
            const Color(0xFF27AE60).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: AppColors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                s.communityImpact,
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _CommStat(label: s.totalScansComm, value: 12847, anim: anim, color: AppColors.teal),
              _CommStat(label: s.kgRecycled,     value: 4521,  anim: anim, color: AppColors.primary),
              _CommStat(label: s.users,           value: 384,   anim: anim, color: const Color(0xFF9B59B6)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, _) => LinearProgressIndicator(
                value: 0.68 * anim.value,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.communityLevelText,
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommStat extends StatelessWidget {
  final String label;
  final int value;
  final Animation<double> anim;
  final Color color;
  const _CommStat({
    required this.label,
    required this.value,
    required this.anim,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => Text(
              '${(value * anim.value).round()}',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 18,
                fontWeight: FontWeight.bold, color: color,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 10,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Titre de section ──────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;
  const _SectionTitle({required this.title, this.onSeeAll, this.seeAllLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              seeAllLabel ?? 'Voir tout',
              style: const TextStyle(
                fontFamily: 'Poppins', color: AppColors.primary,
                fontSize: 13, fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Carte action rapide ───────────────────────────────────────────────────────
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _QuickActionCard({
    required this.icon, required this.label,
    required this.route, required this.color,
  });
  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tap;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _tapScale = Tween(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _tap, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _tap.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _tap.forward(),
      onTapUp: (_) { _tap.reverse(); context.go(widget.route); },
      onTapCancel: () => _tap.reverse(),
      child: ScaleTransition(
        scale: _tapScale,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.1),
                blurRadius: 8, offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item activité récente ─────────────────────────────────────────────────────
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String date;
  final String points;
  const _ActivityItem({
    required this.icon, required this.color,
    required this.title, required this.date, required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              points,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                fontWeight: FontWeight.w700, color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
