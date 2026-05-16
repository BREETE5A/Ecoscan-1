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
      duration: const Duration(milliseconds: 1500),
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
    final s = AppStrings.of(lang);
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
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
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
                                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                                Text(
                                  s.readySubtitle,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
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
                                            color: Colors.white,
                                            size: 22),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 9,
                                          height: 9,
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
                                    width: 44,
                                    height: 44,
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
            title: Text(
              'EcoScan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _WeeklyCard(counterAnim: _counterAnim, s: s)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 24),

                _SectionTitle(
                  title: s.quickActions,
                  onSeeAll: null,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
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
                        .animate(delay: (100 + i * 60).ms)
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.85, 0.85)),
                  ),
                ),
                const SizedBox(height: 24),

                _EcoTipBanner(s: s)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideX(begin: 0.1),
                const SizedBox(height: 24),

                _SectionTitle(
                  title: s.recentActivity,
                  onSeeAll: () => context.go('/history'),
                ).animate().fadeIn(duration: 400.ms, delay: 550.ms),
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
      (Icons.recycling_rounded,         AppColors.primary,          lang == 'en' ? 'PET Bottle Scan' : lang == 'ar' ? 'مسح زجاجة PET' : 'Scan Bouteille PET',     lang == 'en' ? 'Yesterday, 18:42' : lang == 'ar' ? 'أمس، 18:42' : 'Hier, 18:42',    '+15 pts'),
      (Icons.compost_rounded,           const Color(0xFF795548),    lang == 'en' ? 'Compost deposit' : lang == 'ar' ? 'إيداع سماد' : 'Dépôt Compost',              lang == 'en' ? '24 Oct, 10:15' : lang == 'ar' ? '24 أكت، 10:15' : '24 Oct, 10:15',  '+50 pts'),
      (Icons.delete_outline_rounded,    const Color(0xFF3498DB),    lang == 'en' ? 'Plastic sort' : lang == 'ar' ? 'فرز البلاستيك' : 'Tri Plastique',               lang == 'en' ? '22 Oct, 09:00' : lang == 'ar' ? '22 أكت، 09:00' : '22 Oct, 09:00',  '+30 pts'),
      (Icons.emoji_events_rounded,      const Color(0xFFF39C12),    lang == 'en' ? 'Badge unlocked!' : lang == 'ar' ? 'تم فتح شارة!' : 'Badge débloqué !',          lang == 'en' ? 'Oct 20' : lang == 'ar' ? '20 أكت' : '20 Oct',                     s.completed),
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
        )
            .animate(delay: (600 + i * 80).ms)
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.1),
      ),
    );
  }

  String get lang => ref.read(localeProvider).languageCode;
}

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
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
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
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white,
                  ),
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
                fontFamily: 'Poppins',
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            s.recycled,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
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
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

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
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.ecoTipText,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.4,
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
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
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
                fontFamily: 'Poppins',
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
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
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _tap.forward(),
      onTapUp: (_) {
        _tap.reverse();
        context.go(widget.route);
      },
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
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String date;
  final String points;
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.date,
    required this.points,
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
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
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
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
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
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
