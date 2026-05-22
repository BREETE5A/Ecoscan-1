import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  static const _badges = [
    // ── Débloqués ─────────────────────────────────────────────────────────
    _Badge(Icons.recycling_rounded, 'Premier Tri', 100, true, AppColors.primary,
        'Effectuez votre premier tri de déchet'),
    _Badge(Icons.emoji_events_rounded, 'Champion', 500, true, Color(0xFFF39C12),
        'Atteignez 500 points éco'),
    _Badge(Icons.forest_rounded, 'Ami des Arbres', 200, true, Color(0xFF388E3C),
        'Sauvez 5 arbres virtuels par le recyclage'),
    _Badge(Icons.water_drop_rounded, 'Gardien de l\'Eau', 300, true, AppColors.info,
        'Économisez 100 litres d\'eau virtuelle'),
    _Badge(Icons.explore_rounded, 'Explorateur', 50, true, Color(0xFF00BCD4),
        'Réalisez 5 scans de déchets'),
    _Badge(Icons.wb_sunny_rounded, 'Sauveur de l\'Océan', 250, true, Color(0xFF0288D1),
        'Recyclez 3 plastiques qui auraient pollué l\'océan'),
    _Badge(Icons.local_fire_department_rounded, 'Streak 3 jours', 80, true, Color(0xFFFF7043),
        'Scannez des déchets 3 jours de suite'),

    // ── Verrouillés — Scans ───────────────────────────────────────────────
    _Badge(Icons.flash_on_rounded, 'Éco-Électrique', 400, false, AppColors.accent,
        'Recyclez 5 appareils électroniques'),
    _Badge(Icons.compost_rounded, 'Maître Compost', 350, false, Color(0xFF795548),
        'Déposez 10 fois au composteur'),
    _Badge(Icons.share_rounded, 'Ambassadeur', 600, false, AppColors.purple,
        'Partagez 5 scans avec vos amis'),
    _Badge(Icons.star_rounded, 'Étoile Verte', 1000, false, AppColors.primaryLight,
        'Atteignez 1000 points éco'),
    _Badge(Icons.military_tech_rounded, 'Expert Tri', 800, false, Color(0xFF9B59B6),
        '100 scans réalisés au total'),
    _Badge(Icons.qr_code_scanner_rounded, 'Scanneur Pro', 300, false, Color(0xFF26A69A),
        'Réalisez 25 scans de déchets'),
    _Badge(Icons.inventory_rounded, 'Collecteur', 500, false, Color(0xFF5C6BC0),
        'Réalisez 50 scans au total'),
    _Badge(Icons.whatshot_rounded, 'Centurion', 700, false, Color(0xFFEF5350),
        '100 scans réalisés — une vraie machine !'),
    _Badge(Icons.bolt_rounded, 'Légende', 2000, false, Color(0xFFF9A825),
        '500 scans — vous êtes une légende du tri !'),

    // ── Verrouillés — Catégories ─────────────────────────────────────────
    _Badge(Icons.opacity_rounded, 'Spécialiste Plastique', 250, false, AppColors.plastic,
        'Recyclez 20 déchets plastique'),
    _Badge(Icons.local_bar_outlined, 'Maître du Verre', 250, false, AppColors.glass,
        'Recyclez 20 objets en verre'),
    _Badge(Icons.hardware_rounded, 'Titan du Métal', 250, false, AppColors.metal,
        'Recyclez 20 déchets métalliques'),
    _Badge(Icons.article_outlined, 'Guerrier Papier', 250, false, AppColors.paper,
        'Recyclez 20 papiers et cartons'),
    _Badge(Icons.eco_rounded, 'Guru Organique', 200, false, Color(0xFF66BB6A),
        'Compostez 20 déchets organiques'),
    _Badge(Icons.electrical_services_rounded, 'Éco-Tech', 350, false, AppColors.electronics,
        'Déposez 10 appareils DEEE dans un éco-point ECOVAL'),

    // ── Verrouillés — Streaks ─────────────────────────────────────────────
    _Badge(Icons.local_florist_rounded, 'Semaine Verte', 200, false, Color(0xFF43A047),
        'Scannez des déchets 7 jours consécutifs'),
    _Badge(Icons.calendar_month_rounded, 'Champion Mensuel', 600, false, Color(0xFF7E57C2),
        'Scannez des déchets 30 jours de suite'),
    _Badge(Icons.workspace_premium_rounded, 'Habitué', 1500, false, Color(0xFFAB47BC),
        'Restez actif 100 jours — incroyable !'),

    // ── Verrouillés — Impact ───────────────────────────────────────────────
    _Badge(Icons.air_rounded, 'Gardien de l\'Air', 400, false, Color(0xFF29B6F6),
        'Économisez 1 kg de CO₂ grâce au recyclage'),
    _Badge(Icons.thermostat_rounded, 'Héros du Climat', 1000, false, Color(0xFFFF6F00),
        'Économisez 5 kg de CO₂ au total'),
    _Badge(Icons.grass_rounded, 'Protecteur des Sols', 300, false, Color(0xFF8D6E63),
        'Détournez 2 kg de déchets des décharges'),

    // ── Verrouillés — Communauté ───────────────────────────────────────────
    _Badge(Icons.group_add_rounded, 'Recruteur', 300, false, Color(0xFF42A5F5),
        'Invitez 1 ami à rejoindre EcoScan'),
    _Badge(Icons.leaderboard_rounded, 'Éco-Leader', 800, false, Color(0xFF26C6DA),
        'Entrez dans le top 10 du classement'),
    _Badge(Icons.public_rounded, 'Légende Maroc', 2500, false, Color(0xFFFFD700),
        'Atteignez la 1ère place du classement national'),
    _Badge(Icons.favorite_rounded, 'Cœur Vert', 150, false, Color(0xFFE91E63),
        'Faites votre premier don à une association écologique'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userBadges = ref.watch(userProvider).badges;
    final unlocked = userBadges.clamp(0, _badges.length);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Badges',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  Text(
                    '$unlocked/${_badges.length} badges débloqués',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: unlocked / _badges.length),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        backgroundColor:
                            isDark ? AppColors.darkInput : AppColors.inputBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: _badges.length,
                itemBuilder: (context, i) => _BadgeCard(
                  badge: _badges[i],
                  isDark: isDark,
                  isUnlocked: i < unlocked,
                )
                    .animate(delay: (i * 40).ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatefulWidget {
  final _Badge badge;
  final bool isDark;
  final bool isUnlocked;
  const _BadgeCard({required this.badge, required this.isDark, required this.isUnlocked});

  @override
  State<_BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<_BadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    if (widget.isUnlocked) _shimmer.repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  void _showDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeSheet(badge: widget.badge, isDark: widget.isDark, isUnlocked: widget.isUnlocked),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.badge;
    return GestureDetector(
      onTap: _showDetail,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: widget.isUnlocked
              ? Border.all(color: b.color.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: widget.isUnlocked
                  ? b.color.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: widget.isUnlocked ? 12 : 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shimmer,
              builder: (_, child) {
                if (!widget.isUnlocked) return child!;
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      b.color.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.9),
                      b.color.withValues(alpha: 0.8),
                    ],
                    stops: [0.0, _shimmer.value, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: child!,
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isUnlocked
                      ? b.color.withValues(alpha: 0.15)
                      : (widget.isDark ? AppColors.darkInput : AppColors.inputBg),
                ),
                child: Icon(
                  widget.isUnlocked ? b.icon : Icons.lock_outline_rounded,
                  color: widget.isUnlocked ? b.color : AppColors.textLight,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                b.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: widget.isUnlocked
                      ? (widget.isDark ? AppColors.darkText : AppColors.textPrimary)
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (widget.isUnlocked)
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: b.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${b.points} pts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: b.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeSheet extends StatelessWidget {
  final _Badge badge;
  final bool isDark;
  final bool isUnlocked;
  const _BadgeSheet({required this.badge, required this.isDark, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.color.withValues(alpha: 0.15),
              border: Border.all(color: badge.color.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: badge.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(badge.icon, color: badge.color, size: 42),
          )
              .animate()
              .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 500.ms,
                  curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            badge.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: badge.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isUnlocked
                  ? '+${badge.points} points gagnés ✓'
                  : '🔒 Verrouillé — continuez à recycler !',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: badge.color,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Badge {
  final IconData icon;
  final String name;
  final int points;
  final bool unlocked;
  final Color color;
  final String description;
  const _Badge(this.icon, this.name, this.points, this.unlocked, this.color, this.description);
}
