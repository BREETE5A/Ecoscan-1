import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/did_you_know_data.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/environment_providers.dart';
import '../../providers/challenges_provider.dart';
import '../../providers/community_stats_provider.dart';
import '../../models/user_model.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/did_you_know_card.dart';
import '../../services/scan_api_service.dart';

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
  Timer? _envRefreshTimer;

  @override
  void initState() {
    super.initState();
    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _counterAnim = CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOut);
    _scrollCtrl.addListener(_onScroll);
    // Réveille le serveur Render en arrière-plan pour éviter le cold start au premier scan
    ScanApiService.isAvailable();
    // Rafraîchissement automatique météo + qualité air toutes les 10 min
    _envRefreshTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      if (mounted) {
        ref.invalidate(weatherEnvProvider);
        ref.invalidate(airQualityEnvProvider);
      }
    });
  }

  void _onScroll() {
    // expandedHeight(160) - kToolbarHeight(56) = 104
    final collapsed = _scrollCtrl.offset > 104;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _envRefreshTimer?.cancel();
    _counterCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang        = ref.watch(localeProvider).languageCode;
    final s           = AppStrings.of(lang);
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final UserModel user = ref.watch(userStatsStreamProvider).valueOrNull
                        ?? ref.watch(userProvider);
    final avatarPath  = ref.watch(avatarPathProvider);
    final weatherAsync = ref.watch(weatherEnvProvider);
    final aqiAsync     = ref.watch(airQualityEnvProvider);

    // ── Valeurs pré-calculées pour les badges verre dans le header ──────────
    final tempStr = weatherAsync.when(
      data:  (d) => d != null ? '${(d as dynamic).temp.round()}°C' : '--',
      loading: () => '·',
      error: (e, st) => '--',
    );
    final tempLabel = weatherAsync.when(
      data:  (d) => d != null ? s.tempStatus((d as dynamic).temp as double) : '',
      loading: () => '',
      error: (e, st) => '',
    );
    final aqiStr = aqiAsync.when(
      data:  (d) => d != null ? 'AQI ${(d as dynamic).aqi}' : '--',
      loading: () => '·',
      error: (e, st) => '--',
    );
    final aqiLabel = aqiAsync.when(
      data:  (d) => d != null ? s.aqiStatus((d as dynamic).aqi as int) : '',
      loading: () => '',
      error: (e, st) => '',
    );
    final aqiColor = aqiAsync.when(
      data:  (d) => d != null ? Color((d as dynamic).color as int) : const Color(0xFF26C6DA),
      loading: () => const Color(0xFF26C6DA),
      error: (e, st) => const Color(0xFF26C6DA),
    );
    final co2Str = user.co2Saved > 0 ? '${user.co2Saved.round()} g' : '0 g';

    final quickActions = [
      (Icons.emoji_events_rounded,    s.qaBadges,       '/badges',      const Color(0xFFF39C12)),
      (Icons.menu_book_rounded,       s.qaGuide,        '/guide',       const Color(0xFF3498DB)),
      (Icons.leaderboard_rounded,     s.qaLeaderboard,  '/leaderboard', const Color(0xFF9B59B6)),
      (Icons.bar_chart_rounded,       s.qaStats,        '/stats',       const Color(0xFF1ABC9C)),
      (Icons.emoji_flags_rounded,     s.qaChallenges,   '/challenges',  const Color(0xFFFF6B35)),
      (Icons.history_rounded,         s.qaHistory,      '/history',     const Color(0xFF607D8B)),
      (Icons.card_giftcard_rounded,   s.qaRewards,      '/rewards',     const Color(0xFFE91E63)),
      (Icons.air_rounded,             s.qaAirQuality,     '/air-quality',    const Color(0xFF26C6DA)),
      (Icons.water_drop_rounded,      s.qaWaterFootprint, '/water-footprint', const Color(0xFF0288D1)),
      (Icons.wb_sunny_rounded,        s.qaWeather,        '/weather',         const Color(0xFFFFA726)),
      (Icons.quiz_rounded,            s.qaQuiz,           '/quiz',            const Color(0xFF7E57C2)),
      (Icons.barcode_reader,          s.qaBarcode,        '/barcode',         const Color(0xFF26A69A)),
    ];

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            // Même vert que le gradient pour cohérence visuelle (pas de vert foncé)
            backgroundColor: const Color(0xFF27AE60),
            title: _headerCollapsed
                ? ClipOval(
                    child: Image.asset('assets/icons/app_icon.png',
                        width: 34, height: 34, fit: BoxFit.cover),
                  )
                : null,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: _BottomWaveClipper(),
                child: _AnimatedNatureHeader(
                  content: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Ligne 1 : Logo + Nom + Icônes ─────────────
                          Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset('assets/icons/app_icon.png',
                                      fit: BoxFit.cover),
                                ),
                              ).animate().fadeIn(duration: 400.ms).scale(
                                  begin: const Offset(0.7, 0.7),
                                  duration: 400.ms, curve: Curves.easeOut),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${s.greetingPrefix}, ${user.name.split(' ').first} \u{1F33F}',
                                      style: const TextStyle(fontFamily: 'Poppins',
                                        fontSize: 17, fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.1),
                                    Text(s.readySubtitle,
                                      style: TextStyle(fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.8)),
                                    ).animate().fadeIn(duration: 350.ms, delay: 80.ms),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/profile'),
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
                                            fit: BoxFit.cover)
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

                          const SizedBox(height: 10),

                          // ── Phrase environnementale (Brush Script) ─────
                          Text(
                            s.ecoHeaderQuote,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dancingScript(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.4,
                              shadows: const [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 700.ms, delay: 220.ms)
                          .slideY(begin: 0.10, duration: 700.ms, curve: Curves.easeOut)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                            duration: 2800.ms,
                            color: Colors.white.withValues(alpha: 0.45),
                            angle: 0.25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Badges (sous la vague, sur fond blanc) ─────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _ColoredBadge(
                    icon: Icons.wb_sunny_rounded,
                    value: tempStr,
                    label: tempLabel,
                    color: const Color(0xFFFF8C00),
                    route: '/weather',
                  ),
                  const SizedBox(width: 10),
                  _ColoredBadge(
                    icon: Icons.air_rounded,
                    value: aqiStr,
                    label: aqiLabel,
                    color: aqiColor,
                    route: '/air-quality',
                  ),
                  const SizedBox(width: 10),
                  _ColoredBadge(
                    icon: Icons.eco_rounded,
                    value: co2Str,
                    label: s.co2Saved,
                    color: const Color(0xFF00897B),
                    route: '/stats',
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Objectif hebdomadaire ───────────────────────────────────
                _WeeklyCard(counterAnim: _counterAnim, s: s, user: user)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 130.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 16),

                // ── Impact environnemental (3 cartes) ──────────────────────
                _ImpactRow(anim: _counterAnim, user: user, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 180.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 16),

                // ── Bouton Code-barres CTA ─────────────────────────────────
                _BarcodeCTACard(label: s.barcodeCtaLabel, sub: s.barcodeCtaSub)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 200.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 12),

                // ── Bouton Scan CTA ─────────────────────────────────────────
                _ScanCTACard(scanLabel: s.scanProduct, analyzeLabel: s.analyzeEcoImpact)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 210.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 20),

                // ── Le saviez-vous ? ────────────────────────────────────────
                const DidYouKnowCard()
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 220.ms)
                    .slideY(begin: 0.06),
                const SizedBox(height: 20),

                // ── Défi du jour ─────────────────────────────────────────────────────────
                _DailyChallengeCard(anim: _counterAnim, dailyLabel: s.dailyChallenge, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 260.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 24),

                // ── Actions rapides ──────────────────────────────────────────
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

                // ── Catégories de tri ────────────────────────────────────────────────────
                _SectionTitle(title: s.sortingCategories, seeAllLabel: s.seeAll, onSeeAll: () => context.push('/guide'))
                    .animate().fadeIn(duration: 280.ms, delay: 360.ms),
                const SizedBox(height: 12),
                _CategoriesRow(s: s)
                    .animate().fadeIn(duration: 350.ms, delay: 380.ms).slideX(begin: 0.08),
                const SizedBox(height: 24),

                // ── Conseil éco ──────────────────────────────────────────────────────────
                _EcoTipBanner(s: s, lang: lang)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 400.ms)
                    .slideX(begin: 0.08),
                const SizedBox(height: 20),

                // ── Impact communautaire ────────────────────────────────────
                _CommunityCard(anim: _counterAnim, s: s)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 430.ms)
                    .slideY(begin: 0.08),
                const SizedBox(height: 24),

                // ── Activité récente ─────────────────────────────────────────
                _SectionTitle(
                  title: s.recentActivity,
                  seeAllLabel: s.seeAll,
                  onSeeAll: () => context.push('/history'),
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

    final catIcons = <String, IconData>{
      'plastique':    Icons.opacity_rounded,
      'plastic':      Icons.opacity_rounded,
      'verre':        Icons.local_bar_outlined,
      'glass':        Icons.local_bar_outlined,
      'metal':        Icons.hardware_rounded,
      'paper':        Icons.article_outlined,
      'cardboard':    Icons.inventory_2_rounded,
      'organique':    Icons.compost_rounded,
      'organic':      Icons.compost_rounded,
      'electronique': Icons.electrical_services_rounded,
      'electronic':   Icons.electrical_services_rounded,
      'deee':         Icons.electrical_services_rounded,
      'vetement':     Icons.checkroom_rounded,
      'vêtement':     Icons.checkroom_rounded,
      'clothing':     Icons.checkroom_rounded,
      'textile':      Icons.checkroom_rounded,
      'chaussures':   Icons.hiking_rounded,
      'pile':         Icons.battery_charging_full_rounded,
      'battery':      Icons.battery_charging_full_rounded,
      'trash':        Icons.delete_outline_rounded,
      'unknown':      Icons.help_outline_rounded,
    };
    final catColors = <String, Color>{
      'plastique':    AppColors.plastic,
      'plastic':      AppColors.plastic,
      'verre':        AppColors.glass,
      'glass':        AppColors.glass,
      'metal':        AppColors.metal,
      'paper':        AppColors.paper,
      'cardboard':    AppColors.paper,
      'organique':    const Color(0xFF795548),
      'organic':      const Color(0xFF795548),
      'electronique': AppColors.electronics,
      'electronic':   AppColors.electronics,
      'deee':         AppColors.electronics,
      'vetement':     const Color(0xFF9C27B0),
      'vêtement':     const Color(0xFF9C27B0),
      'clothing':     const Color(0xFF9C27B0),
      'textile':      const Color(0xFF9C27B0),
      'chaussures':   const Color(0xFF795548),
      'pile':         const Color(0xFFFF5722),
      'battery':      const Color(0xFFFF5722),
      'trash':        const Color(0xFF607D8B),
      'unknown':      const Color(0xFF9E9E9E),
    };
    final catNames = <String, String>{
      'plastique':    s.catPlastic,
      'plastic':      s.catPlastic,
      'verre':        s.catGlass,
      'glass':        s.catGlass,
      'metal':        s.catMetal,
      'paper':        s.catPaper,
      'cardboard':    s.catCardboard,
      'organique':    s.catOrganic,
      'organic':      s.catOrganic,
      'electronique': s.catElectronic,
      'electronic':   s.catElectronic,
      'deee':         s.catElectronic,
      'vetement':     s.catClothing,
      'vêtement':     s.catClothing,
      'clothing':     s.catClothing,
      'textile':      s.catTextile,
      'chaussures':   s.catShoes,
      'pile':         s.catBatteries,
      'battery':      s.catBatteries,
      'trash':        s.catTrash,
      'unknown':      s.catUnknown,
    };

    return List.generate(scans.length, (i) {
      final scan = scans[i];
      final cat = (scan['category'] as String? ?? 'unknown').toLowerCase();
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
          title: '${s.scanCategory} ${catNames[cat] ?? cat}',
          date: dateStr,
          points: '+10 pts',
        ).animate(delay: (460 + i * 60).ms).fadeIn(duration: 280.ms).slideX(begin: 0.08),
      );
    });
  }

  String get lang => ref.read(localeProvider).languageCode;
}

// ── Badge environnement dans l'AppBar ───────────────────────────────────────
// ── Badges environnement (rangée sous le header) ─────────────────────────────
// ── Badge verre (frosted glass) dans la zone verte ───────────────────────────
// ── Badge coloré — hors zone verte, légèrement remonté sur la vague ──────────
class _ColoredBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String route;
  const _ColoredBadge({
    required this.icon, required this.value, required this.label,
    required this.color, required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.38),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              fontWeight: FontWeight.bold, color: Colors.white,
            )),
            if (label.isNotEmpty)
              Text(label,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.88)),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Vague prononcée au bas de la zone verte ───────────────────────────────────
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Départ coin haut gauche
    path.lineTo(0, size.height - 36);

    // Première bosse (creux vers le bas)
    path.cubicTo(
      size.width * 0.12, size.height - 36,
      size.width * 0.18, size.height + 10,
      size.width * 0.35, size.height + 10,
    );
    // Deuxième bosse (remonte)
    path.cubicTo(
      size.width * 0.52, size.height + 10,
      size.width * 0.58, size.height - 48,
      size.width * 0.72, size.height - 48,
    );
    // Troisième bosse (redescend légèrement)
    path.cubicTo(
      size.width * 0.85, size.height - 48,
      size.width * 0.92, size.height - 18,
      size.width,        size.height - 18,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomWaveClipper old) => false;
}

// ── Carte objectif hebdomadaire ──────────────────────────────────────────────
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

// ── Impact environnemental (3 mini-cartes) ───────────────────────────────────
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

// â”€â”€ Bouton Scan CTA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      onTap: () => context.push('/scan'),
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

// ── Défi du jour ──────────────────────────────────────────────────────────────
class _DailyChallengeCard extends ConsumerWidget {
  final Animation<double> anim;
  final String dailyLabel;
  final AppStrings s;
  const _DailyChallengeCard({required this.anim, required this.dailyLabel, required this.s});

  static const _dailyGoal = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cp       = ref.watch(challengesProvider);
    final done     = cp.dailyScans.clamp(0, _dailyGoal);
    final progress = done / _dailyGoal;

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
            s.challengeProgressOf(done, _dailyGoal),
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
            onTap: () => context.push('/guide'),
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

// â”€â”€ Impact communautaire â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _CommunityCard extends ConsumerWidget {
  final Animation<double> anim;
  final AppStrings s;
  const _CommunityCard({required this.anim, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats  = ref.watch(communityStatsProvider).valueOrNull
                ?? const CommunityStats();

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
              _CommStat(label: s.totalScansComm, value: stats.scans,      anim: anim, color: AppColors.teal),
              _CommStat(label: s.kgRecycled,     value: stats.kgRecycled, anim: anim, color: AppColors.primary),
              _CommStat(label: s.users,           value: stats.users,      anim: anim, color: const Color(0xFF9B59B6)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, _) => LinearProgressIndicator(
                value: stats.progress * anim.value,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.communityLevelPct((stats.progress * 100).round()),
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

// â”€â”€ Titre de section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€ Carte action rapide â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      onTapUp: (_) { _tap.reverse(); context.push(widget.route); },
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

// ── Item activité récente ──────────────────────────────────────────────────────
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


// â”€â”€ Bouton Barcode CTA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BarcodeCTACard extends StatefulWidget {
  final String label;
  final String sub;
  const _BarcodeCTACard({required this.label, required this.sub});
  @override
  State<_BarcodeCTACard> createState() => _BarcodeCTACardState();
}

class _BarcodeCTACardState extends State<_BarcodeCTACard>
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
      onTap: () => context.push('/barcode'),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00838F), Color(0xFF26A69A)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: const Color(0xFF26A69A).withValues(alpha: 0.3),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Row(children: [
          const SizedBox(width: 18),
          // Icône avec animation pulse identique au bouton scan
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _pulseCtrl.value * 0.1,
              child: child,
            ),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: const Icon(Icons.barcode_reader, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 15,
                fontWeight: FontWeight.bold, color: Colors.white,
              )),
              Text(widget.sub, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: Colors.white70,
              )),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 18),
        ]),
      ),
    );
  }
}

// ── Widget animé qui gère les controllers ────────────────────────────────────
class _AnimatedNatureHeader extends StatefulWidget {
  final Widget content;
  const _AnimatedNatureHeader({required this.content});

  @override
  State<_AnimatedNatureHeader> createState() => _AnimatedNatureHeaderState();
}

class _AnimatedNatureHeaderState extends State<_AnimatedNatureHeader>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _swayCtrl;
  late final AnimationController _leafCtrl;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _swayCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _leafCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _swayCtrl.dispose();
    _leafCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fond animé — remplit tout l'espace disponible
        AnimatedBuilder(
          animation: Listenable.merge([_waveCtrl, _swayCtrl, _leafCtrl, _particleCtrl]),
          builder: (context, _) => CustomPaint(
            painter: _NatureHeaderPainter(
              wavePhase:     _waveCtrl.value,
              swayPhase:     _swayCtrl.value,
              leafPhase:     _leafCtrl.value,
              particlePhase: _particleCtrl.value,
            ),
          ),
        ),
        // Contenu (texte + icônes) par-dessus
        widget.content,
      ],
    );
  }
}

// ── Painter animé ─────────────────────────────────────────────────────────────
class _NatureHeaderPainter extends CustomPainter {
  final double wavePhase;
  final double swayPhase;
  final double leafPhase;
  final double particlePhase;

  const _NatureHeaderPainter({
    required this.wavePhase,
    required this.swayPhase,
    required this.leafPhase,
    required this.particlePhase,
  });

  // ─── Fond dégradé ────────────────────────────────────────────────────────
  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF27AE60), Color(0xFF1A6B3A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Éclat lumineux (soleil)
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2ECC71).withValues(alpha: 0.38),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.18, size.height * 0.22),
        radius: size.width * 0.45,
      ));
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.22), size.width * 0.45, glow);
  }

  // ─── Vagues animées (3 couches, vitesses différentes) ────────────────────
  void _drawWaves(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final phase    = (wavePhase + i * 0.28) % 1.0;
      final alpha    = 0.10 - i * 0.025;
      final amp      = 9.0 + i * 5.0;
      final yBase    = size.height * (0.60 + i * 0.13);
      final paint    = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width + 2; x += 2) {
        final y = yBase +
            math.sin((x / size.width * 2 * math.pi) + phase * 2 * math.pi) * amp;
        x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  // ─── Particules d'air pur qui montent ────────────────────────────────────
  void _drawAirParticles(Canvas canvas, Size size) {
    const xRatios = [0.10, 0.22, 0.34, 0.44, 0.56];
    for (int i = 0; i < xRatios.length; i++) {
      final t      = (particlePhase + i * 0.20) % 1.0;
      final ease   = math.sin(t * math.pi);          // fade in/out
      if (ease < 0.05) continue;
      final x      = size.width * xRatios[i] + math.sin(t * 4 * math.pi + i) * 6;
      final y      = size.height * (1.0 - t * 1.1);
      final radius = 1.5 + ease * 2.0;
      final paint  = Paint()
        ..color = Colors.white.withValues(alpha: ease * 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  // ─── Arbre avec balancement ───────────────────────────────────────────────
  void _drawTree(Canvas canvas, Size size) {
    final cx = size.width * 0.80;
    final cy = size.height * 1.08;
    final swayAngle = (swayPhase - 0.5) * 0.06;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(swayAngle);
    canvas.translate(-cx, -cy);

    // Tronc
    final trunkP = Paint()
      ..color = const Color(0xFF0E4D26)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..cubicTo(cx - 3, cy - size.height * 0.28,
                  cx + 3, cy - size.height * 0.46,
                  cx, cy - size.height * 0.60),
      trunkP,
    );

    // Branches
    final branchP = Paint()
      ..color = const Color(0xFF0E4D26)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final b in [
      [cx,      cy - size.height * 0.40, cx - 30, cy - size.height * 0.31],
      [cx,      cy - size.height * 0.32, cx + 26, cy - size.height * 0.24],
      [cx,      cy - size.height * 0.50, cx - 20, cy - size.height * 0.43],
      [cx,      cy - size.height * 0.54, cx + 16, cy - size.height * 0.48],
    ]) {
      canvas.drawLine(Offset(b[0], b[1]), Offset(b[2], b[3]), branchP);
    }

    // Canopée (cercles superposés)
    for (final c in [
      [const Color(0xFF1ABC9C), 0.55, cx,      cy - size.height * 0.74, size.height * 0.22],
      [const Color(0xFF27AE60), 0.75, cx - 24, cy - size.height * 0.63, size.height * 0.16],
      [const Color(0xFF2ECC71), 0.60, cx + 22, cy - size.height * 0.61, size.height * 0.15],
      [const Color(0xFF1E8449), 0.85, cx,      cy - size.height * 0.62, size.height * 0.14],
      [const Color(0xFF52BE80), 0.50, cx - 12, cy - size.height * 0.80, size.height * 0.12],
      [const Color(0xFF27AE60), 0.65, cx + 12, cy - size.height * 0.77, size.height * 0.11],
    ]) {
      canvas.drawCircle(
        Offset(c[2] as double, c[3] as double),
        c[4] as double,
        Paint()
          ..color = (c[0] as Color).withValues(alpha: c[1] as double)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.restore();
  }

  // ─── Feuilles qui tombent de l'arbre ─────────────────────────────────────
  void _drawFallingLeaves(Canvas canvas, Size size) {
    final cx = size.width * 0.80;
    for (int i = 0; i < 5; i++) {
      final t = (leafPhase + i * 0.22) % 1.0;
      final ease = math.sin(t * math.pi);
      if (ease < 0.08) continue;

      final x = cx - 15 + math.sin(t * 5 * math.pi + i * 1.3) * 28;
      final y = size.height * (-0.05 + t * 1.1);
      if (y < 0 || y > size.height) continue;

      final angle    = t * math.pi * 4 + i * 1.5;
      final leafSize = 3.5 + ease * 3.5;
      final paint    = Paint()
        ..color = const Color(0xFF52BE80).withValues(alpha: ease * 0.75)
        ..style = PaintingStyle.fill;

      _drawLeaf(canvas, Offset(x, y), leafSize, angle, paint);
    }
  }

  // ─── Forme feuille ────────────────────────────────────────────────────────
  void _drawLeaf(Canvas canvas, Offset center, double sz, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawPath(
      Path()
        ..moveTo(0, -sz)
        ..cubicTo( sz * 1.2, -sz * 0.5,  sz * 1.2,  sz * 0.5, 0,  sz)
        ..cubicTo(-sz * 1.2,  sz * 0.5, -sz * 1.2, -sz * 0.5, 0, -sz),
      paint,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawWaves(canvas, size);
    _drawAirParticles(canvas, size);
    _drawTree(canvas, size);
    _drawFallingLeaves(canvas, size);
  }

  @override
  bool shouldRepaint(_NatureHeaderPainter old) =>
    old.wavePhase     != wavePhase     ||
    old.swayPhase     != swayPhase     ||
    old.leafPhase     != leafPhase     ||
    old.particlePhase != particlePhase;
}
