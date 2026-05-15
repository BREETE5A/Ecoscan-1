import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  static const _badges = [
    _Badge(Icons.recycling_rounded, 'Premier Tri', 100, true, AppColors.primary, 'Effectuez votre premier tri'),
    _Badge(Icons.emoji_events_rounded, 'Champion', 500, true, Color(0xFFF39C12), 'Atteignez 500 points'),
    _Badge(Icons.forest_rounded, 'Ami des Arbres', 200, true, Color(0xFF388E3C), 'Sauvez 5 arbres virtuels'),
    _Badge(Icons.water_drop_rounded, 'Gardien de l\'Eau', 300, true, AppColors.info, 'Économisez 100L d\'eau'),
    _Badge(Icons.flash_on_rounded, 'Éco-Électrique', 400, false, AppColors.accent, 'Recyclez 5 appareils électro.'),
    _Badge(Icons.compost_rounded, 'Maître Compost', 350, false, Color(0xFF795548), 'Déposez 10 fois au compost'),
    _Badge(Icons.share_rounded, 'Ambassadeur', 600, false, AppColors.purple, 'Partagez 5 scans avec amis'),
    _Badge(Icons.star_rounded, 'Étoile Verte', 1000, false, AppColors.primaryLight, 'Atteignez 1000 points'),
    _Badge(Icons.military_tech_rounded, 'Expert Tri', 800, false, Color(0xFF9B59B6), '100 scans réalisés'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = _badges.where((b) => b.unlocked).length;

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
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: unlocked / _badges.length),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        backgroundColor: isDark
                            ? AppColors.darkInput
                            : AppColors.inputBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                )
                    .animate(delay: (i * 60).ms)
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
  const _BadgeCard({required this.badge, required this.isDark});

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
    if (widget.badge.unlocked) _shimmer.repeat();
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
      builder: (_) => _BadgeSheet(badge: widget.badge, isDark: widget.isDark),
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
          border: b.unlocked
              ? Border.all(
                  color: b.color.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: b.unlocked
                  ? b.color.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: b.unlocked ? 12 : 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shimmer,
              builder: (_, child) {
                if (!b.unlocked) return child!;
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      b.color.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.9),
                      b.color.withValues(alpha: 0.8),
                    ],
                    stops: [
                      0.0,
                      _shimmer.value,
                      1.0,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: child!,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: b.unlocked
                      ? b.color.withValues(alpha: 0.15)
                      : (widget.isDark
                          ? AppColors.darkInput
                          : AppColors.inputBg),
                ),
                child: Icon(
                  b.unlocked ? b.icon : Icons.lock_outline_rounded,
                  color: b.unlocked ? b.color : AppColors.textLight,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                b.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: b.unlocked
                      ? (widget.isDark
                          ? AppColors.darkText
                          : AppColors.textPrimary)
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (b.unlocked)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
  const _BadgeSheet({required this.badge, required this.isDark});

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
              border: Border.all(
                  color: badge.color.withValues(alpha: 0.4), width: 2),
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
              badge.unlocked ? '+${badge.points} points gagnés ✓' : 'Verrouillé',
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
