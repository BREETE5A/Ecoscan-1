import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterCtrl;
  late Animation<double> _counterAnim;

  @override
  void initState() {
    super.initState();
    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _counterAnim = CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final s    = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${s.greetingPrefix}, Amine 🌿',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.1),
                                Text(
                                  s.readySubtitle,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ).animate().fadeIn(duration: 350.ms, delay: 80.ms),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.go('/notifications'),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.white, size: 22),
                                      ),
                                      Positioned(
                                        top: 8, right: 8,
                                        child: Container(
                                          width: 9, height: 9,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF6B6B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => context.go('/profile'),
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.3),
                                      border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          width: 2),
                                    ),
                                    child: const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _MiniStat(label: s.points,    value: 1240, anim: _counterAnim),
                            const SizedBox(width: 16),
                            _MiniStat(label: s.scans,     value: 47,   anim: _counterAnim),
                            const SizedBox(width: 16),
                            _MiniStat(label: s.co2Avoided, value: 870, anim: _counterAnim),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Objectif hebdomadaire ──────────────────────────────
                _WeeklyCard(counterAnim: _counterAnim, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 130.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 16),

                // ── Impact environnemental (3 cartes) ──────────────────
                _ImpactRow(anim: _counterAnim)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 180.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 20),

                // ── Bouton Scan CTA ────────────────────────────────────
                const _ScanCTACard()
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 220.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 20),

                // ── Défi du jour ───────────────────────────────────────
                _DailyChallengeCard(anim: _counterAnim)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 260.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 24),

                // ── Actions rapides ────────────────────────────────────
                _SectionTitle(title: s.quickActions, onSeeAll: null)
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
                _SectionTitle(title: 'Catégories de tri', onSeeAll: () => context.go('/guide'))
                    .animate().fadeIn(duration: 280.ms, delay: 360.ms),
                const SizedBox(height: 12),
                const _CategoriesRow()
                    .animate().fadeIn(duration: 350.ms, delay: 380.ms).slideX(begin: 0.08),
                const SizedBox(height: 24),

                // ── Conseil éco ────────────────────────────────────────
                _EcoTipBanner(s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 400.ms)
                    .slideX(begin: 0.08),
                const SizedBox(height: 20),

                // ── Impact communautaire ───────────────────────────────
                _CommunityCard(anim: _counterAnim)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 430.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 24),

                // ── Activité récente ───────────────────────────────────
                _SectionTitle(
                  title: s.recentActivity,
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
    final activities = [
      (Icons.recycling_rounded,      AppColors.primary,          lang == 'en' ? 'PET Bottle Scan' : lang == 'ar' ? 'مسح زجاجة PET' : 'Scan Bouteille PET',     lang == 'en' ? 'Yesterday, 18:42' : lang == 'ar' ? 'أمس، 18:42' : 'Hier, 18:42',    '+15 pts'),
      (Icons.compost_rounded,        const Color(0xFF795548),    lang == 'en' ? 'Compost deposit' : lang == 'ar' ? 'إيداع سماد' : 'Dépôt Compost',              lang == 'en' ? '24 Oct, 10:15' : lang == 'ar' ? '24 أكت، 10:15' : '24 Oct, 10:15',  '+50 pts'),
      (Icons.delete_outline_rounded, const Color(0xFF3498DB),    lang == 'en' ? 'Plastic sort' : lang == 'ar' ? 'فرز البلاستيك' : 'Tri Plastique',               lang == 'en' ? '22 Oct, 09:00' : lang == 'ar' ? '22 أكت، 09:00' : '22 Oct, 09:00',  '+30 pts'),
      (Icons.emoji_events_rounded,   const Color(0xFFF39C12),    lang == 'en' ? 'Badge unlocked!' : lang == 'ar' ? 'تم فتح شارة!' : 'Badge débloqué !',          lang == 'en' ? 'Oct 20' : lang == 'ar' ? '20 أكت' : '20 Oct',                     s.completed),
    ];
    return List.generate(
      activities.length,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ActivityItem(
          icon: activities[i].$1,
          color: activities[i].$2,
          title: activities[i].$3,
          date: activities[i].$4,
          points: activities[i].$5,
        ).animate(delay: (460 + i * 60).ms).fadeIn(duration: 280.ms).slideX(begin: 0.08),
      ),
    );
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
  const _WeeklyCard({required this.counterAnim, required this.s});

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
              '${(12.5 * counterAnim.value).toStringAsFixed(1)} kg',
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
                value: 0.75 * counterAnim.value,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '75% ${s.ofGoal}',
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
  const _ImpactRow({required this.anim});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (Icons.cloud_outlined,      '2.4 kg', 'CO₂ évité',   const Color(0xFF27AE60)),
      (Icons.park_outlined,       '0.3',    'Arbres éq.',   const Color(0xFF2E7D32)),
      (Icons.water_drop_outlined, '40 L',   'Eau éco.',     const Color(0xFF1ABC9C)),
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
  const _ScanCTACard();
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
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanner un produit',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                Text(
                  "Analysez l'impact écologique",
                  style: TextStyle(
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
  const _DailyChallengeCard({required this.anim});

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
              const Expanded(
                child: Text(
                  'Défi du jour',
                  style: TextStyle(
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
            'Scannez 3 articles en plastique',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '1 sur 3 complété  ·  Expire dans 8 h',
            style: TextStyle(
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
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      (Icons.local_drink_outlined,   'Plastique',    const Color(0xFFFDD835)),
      (Icons.wine_bar_outlined,       'Verre',         const Color(0xFF43A047)),
      (Icons.newspaper_rounded,       'Papier',        const Color(0xFF1565C0)),
      (Icons.hardware_rounded,        'Métal',         const Color(0xFF546E7A)),
      (Icons.compost_rounded,         'Organique',     const Color(0xFF795548)),
      (Icons.devices_other_rounded,   'Électronique',  const Color(0xFF7B1FA2)),
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
  const _EcoTipBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  s.ecoTipText,
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
  const _CommunityCard({required this.anim});

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
                'Impact communautaire',
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
              _CommStat(label: 'Scans totaux', value: 12847, anim: anim, color: AppColors.teal),
              _CommStat(label: 'kg recyclés',  value: 4521,  anim: anim, color: AppColors.primary),
              _CommStat(label: 'Utilisateurs', value: 384,   anim: anim, color: const Color(0xFF9B59B6)),
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
            '68% vers le prochain niveau communautaire',
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
  const _SectionTitle({required this.title, this.onSeeAll});

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
            child: const Text(
              'Voir tout',
              style: TextStyle(
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
