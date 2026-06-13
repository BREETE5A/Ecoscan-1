import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  // Badges ordonnés : rôle-clés en premier, cosmétiques ensuite
  static const _badges = [
    // ── Badge 0 : envoyé par n8n dès l'inscription ───────────────────────────
    _Badge(
      Icons.eco_rounded, 'Nouveau Trieur', 0, true, AppColors.primary,
      'Bienvenue dans la communauté EcoScan ! Badge envoyé automatiquement à l\'inscription.',
      unlock: 'Accès complet à EcoScan débloqué',
      unlockEn: 'Full EcoScan access unlocked',
      unlockAr: 'تم فتح الوصول الكامل لـ EcoScan',
      unlockEs: 'Acceso completo a EcoScan desbloqueado',
    ),
    // ── Badge 1 : 1 scan ────────────────────────────────────────────────────
    _Badge(
      Icons.qr_code_scanner_rounded, 'Explorateur Vert', 50, false, Color(0xFF00BCD4),
      'Réalisez votre premier scan de déchet.',
      unlock: 'Historique et statistiques débloqués',
      unlockEn: 'History & stats unlocked',
      unlockAr: 'تم فتح السجل والإحصائيات',
      unlockEs: 'Historial y estadísticas desbloqueados',
    ),
    // ── Badge 2 : 5 scans → débloque Défis ─────────────────────────────────
    _Badge(
      Icons.flash_on_rounded, 'Éco-Actif', 150, false, AppColors.accent,
      'Réalisez 5 scans pour prouver votre engagement.',
      unlock: 'Défis quotidiens & hebdomadaires débloqués',
      unlockEn: 'Daily & weekly challenges unlocked',
      unlockAr: 'تم فتح التحديات اليومية والأسبوعية',
      unlockEs: 'Retos diarios y semanales desbloqueados',
    ),
    // ── Badge 3 : 10 scans → débloque Marketplace ──────────────────────────
    _Badge(
      Icons.recycling_rounded, 'Protecteur Vert', 300, false, AppColors.primary,
      'Recyclez 10 déchets et rejoignez les protecteurs de l\'environnement.',
      unlock: 'Marketplace éco-responsable débloqué',
      unlockEn: 'Eco-marketplace unlocked',
      unlockAr: 'تم فتح السوق البيئي',
      unlockEs: 'Mercado eco-responsable desbloqueado',
    ),
    // ── Badge 4 : 20 scans → débloque Classement ───────────────────────────
    _Badge(
      Icons.leaderboard_rounded, 'Champion Vert', 500, false, Color(0xFF7B1FA2),
      'Atteignez 20 scans et entrez dans la compétition nationale.',
      unlock: 'Classement national débloqué',
      unlockEn: 'National leaderboard unlocked',
      unlockAr: 'تم فتح التصنيف الوطني',
      unlockEs: 'Clasificación nacional desbloqueada',
    ),
    // ── Badge 5 : 50 scans ──────────────────────────────────────────────────
    _Badge(
      Icons.military_tech_rounded, 'Légende Recycleur', 800, false, Color(0xFF9B59B6),
      '50 scans — vous êtes une référence du recyclage !',
      unlock: 'Contenu exclusif avancé débloqué',
      unlockEn: 'Advanced exclusive content unlocked',
      unlockAr: 'تم فتح المحتوى الحصري المتقدم',
      unlockEs: 'Contenido exclusivo avanzado desbloqueado',
    ),
    // ── Badge 6 : 100 pts → débloque Récompenses ───────────────────────────
    _Badge(
      Icons.card_giftcard_rounded, 'Contributeur Éco', 200, false, Color(0xFFFF6B35),
      'Accumulez 100 points éco pour accéder aux récompenses.',
      unlock: 'Boutique de récompenses débloquée',
      unlockEn: 'Rewards store unlocked',
      unlockAr: 'تم فتح متجر المكافآت',
      unlockEs: 'Tienda de recompensas desbloqueada',
    ),
    // ── Badge 7 : 500 pts ────────────────────────────────────────────────────
    _Badge(
      Icons.workspace_premium_rounded, 'Éco-Expert', 1000, false, Color(0xFFFFD700),
      'Atteignez 500 points — niveau expert du recyclage.',
      unlock: 'Récompenses premium débloquées',
      unlockEn: 'Premium rewards unlocked',
      unlockAr: 'تم فتح المكافآت المميزة',
      unlockEs: 'Recompensas premium desbloqueadas',
    ),

    // ── Badges cosmétiques — Streaks ─────────────────────────────────────────
    _Badge(Icons.local_fire_department_rounded, 'Streak 3 jours', 80, true, Color(0xFFFF7043),
        'Scannez des déchets 3 jours de suite.'),
    _Badge(Icons.local_florist_rounded, 'Semaine Verte', 200, false, Color(0xFF43A047),
        'Scannez des déchets 7 jours consécutifs.'),
    _Badge(Icons.calendar_month_rounded, 'Champion Mensuel', 600, false, Color(0xFF7E57C2),
        'Scannez des déchets 30 jours de suite.'),
    _Badge(Icons.whatshot_rounded, 'Habitué', 1500, false, Color(0xFFAB47BC),
        'Restez actif 100 jours — incroyable !'),

    // ── Badges cosmétiques — Catégories ──────────────────────────────────────
    _Badge(Icons.opacity_rounded, 'Spécialiste Plastique', 250, false, AppColors.plastic,
        'Recyclez 20 déchets plastique.'),
    _Badge(Icons.local_bar_outlined, 'Maître du Verre', 250, false, AppColors.glass,
        'Recyclez 20 objets en verre.'),
    _Badge(Icons.hardware_rounded, 'Titan du Métal', 250, false, AppColors.metal,
        'Recyclez 20 déchets métalliques.'),
    _Badge(Icons.article_outlined, 'Guerrier Papier', 250, false, AppColors.paper,
        'Recyclez 20 papiers et cartons.'),
    _Badge(Icons.compost_rounded, 'Guru Organique', 200, false, Color(0xFF66BB6A),
        'Compostez 20 déchets organiques.'),
    _Badge(Icons.electrical_services_rounded, 'Éco-Tech', 350, false, AppColors.electronics,
        'Déposez 10 appareils DEEE dans un éco-point ECOVAL.'),

    // ── Badges cosmétiques — Impact ───────────────────────────────────────────
    _Badge(Icons.air_rounded, 'Gardien de l\'Air', 400, false, Color(0xFF29B6F6),
        'Économisez 1 kg de CO₂ grâce au recyclage.'),
    _Badge(Icons.thermostat_rounded, 'Héros du Climat', 1000, false, Color(0xFFFF6F00),
        'Économisez 5 kg de CO₂ au total.'),
    _Badge(Icons.grass_rounded, 'Protecteur des Sols', 300, false, Color(0xFF8D6E63),
        'Détournez 2 kg de déchets des décharges.'),
    _Badge(Icons.forest_rounded, 'Ami des Arbres', 200, false, Color(0xFF388E3C),
        'Sauvez 5 arbres virtuels par le recyclage.'),
    _Badge(Icons.water_drop_rounded, 'Gardien de l\'Eau', 300, false, AppColors.info,
        'Économisez 100 litres d\'eau virtuelle.'),
    _Badge(Icons.wb_sunny_rounded, 'Sauveur de l\'Océan', 250, false, Color(0xFF0288D1),
        'Recyclez 3 plastiques qui auraient pollué l\'océan.'),

    // ── Badges cosmétiques — Communauté ──────────────────────────────────────
    _Badge(Icons.group_add_rounded, 'Recruteur', 300, false, Color(0xFF42A5F5),
        'Invitez 1 ami à rejoindre EcoScan.'),
    _Badge(Icons.share_rounded, 'Ambassadeur', 600, false, AppColors.purple,
        'Partagez 5 scans avec vos amis.'),
    _Badge(Icons.favorite_rounded, 'Cœur Vert', 150, false, Color(0xFFE91E63),
        'Faites votre premier don à une association écologique.'),
    _Badge(Icons.public_rounded, 'Légende Maroc', 2500, false, Color(0xFFFFD700),
        'Atteignez la 1ère place du classement national.'),

    // ── Badges cosmétiques — Niveaux élevés ──────────────────────────────────
    _Badge(Icons.bolt_rounded, 'Centurion', 700, false, Color(0xFFEF5350),
        '100 scans réalisés au total.'),
    _Badge(Icons.star_rounded, 'Étoile Verte', 1000, false, AppColors.primaryLight,
        'Atteignez 1000 points éco.'),
    _Badge(Icons.emoji_events_rounded, 'Maître Absolu', 2000, false, Color(0xFFF9A825),
        '500 scans — vous êtes une légende du tri !'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(userStatsStreamProvider);
    final userBadges = stats.when(
      data: (u) => u.badges,
      loading: () => ref.read(userProvider).badges,
      error: (_, _) => ref.read(userProvider).badges,
    );
    final unlocked = userBadges.clamp(0, _badges.length);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const SizedBox(height: 10),
                  // Banner "prochain déblocage"
                  if (unlocked < _badges.length)
                    _NextUnlockBanner(
                      nextBadge: _badges[unlocked],
                      isDark: isDark,
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.80,
                ),
                itemCount: _badges.length,
                itemBuilder: (context, i) => _BadgeCard(
                  badge: _badges[i],
                  isDark: isDark,
                  isUnlocked: i < unlocked,
                  isRole: _badges[i].unlock.isNotEmpty,
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

// Banner montrant le prochain badge à débloquer
class _NextUnlockBanner extends StatelessWidget {
  final _Badge nextBadge;
  final bool isDark;
  const _NextUnlockBanner({required this.nextBadge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (nextBadge.unlock.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: nextBadge.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: nextBadge.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_open_rounded, color: nextBadge.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prochain déblocage : ${nextBadge.unlock}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: nextBadge.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatefulWidget {
  final _Badge badge;
  final bool isDark;
  final bool isUnlocked;
  final bool isRole;
  const _BadgeCard({
    required this.badge,
    required this.isDark,
    required this.isUnlocked,
    this.isRole = false,
  });

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
      builder: (_) => _BadgeSheet(
        badge: widget.badge,
        isDark: widget.isDark,
        isUnlocked: widget.isUnlocked,
      ),
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
              : widget.isRole && !widget.isUnlocked
                  ? Border.all(color: b.color.withValues(alpha: 0.2), width: 1)
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
                  color: widget.isUnlocked
                      ? b.color
                      : (widget.isRole ? b.color.withValues(alpha: 0.4) : AppColors.textLight),
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
                  b.points > 0 ? '+${b.points} pts' : 'Obtenu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: b.color,
                  ),
                ),
              )
            else if (widget.isRole && b.unlock.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 9, color: b.color.withValues(alpha: 0.5)),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        'À débloquer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          color: b.color.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
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
  const _BadgeSheet({
    required this.badge,
    required this.isDark,
    required this.isUnlocked,
  });

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
            child: Icon(
              isUnlocked ? badge.icon : Icons.lock_outline_rounded,
              color: badge.color,
              size: 42,
            ),
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
          // Afficher le rôle du badge s'il en a un
          if (badge.unlock.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: badge.color.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                        color: badge.color,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isUnlocked ? 'Fonctionnalité débloquée' : 'Débloque',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badge.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.unlock,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: badge.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isUnlocked
                  ? (badge.points > 0 ? '+${badge.points} points gagnés ✓' : 'Badge obtenu ✓')
                  : '🔒 Continuez à recycler pour débloquer ce badge !',
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
  final String unlock;
  final String unlockEn;
  final String unlockAr;
  final String unlockEs;

  const _Badge(
    this.icon,
    this.name,
    this.points,
    this.unlocked,
    this.color,
    this.description, {
    this.unlock = '',
    this.unlockEn = '',
    this.unlockAr = '',
    this.unlockEs = '',
  });
}
