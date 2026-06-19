import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_entry.dart';
import '../../providers/scan_history_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/chat_provider.dart';
import '../../l10n/app_strings.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late ConfettiController _confetti;
  bool _chatContextSent = false; // empêche de re-poser la question si l'utilisateur revient

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entry = ref.read(currentScanProvider);
      if (entry != null && !entry.dangerous) _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final entry = ref.watch(currentScanProvider);

    // Redirige vers le scan si aucun résultat disponible
    if (entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/scan');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final scan = entry;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'map_fab',
            onPressed: () => context.push('/map'),
            backgroundColor: AppColors.primary,
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 24),
          )
              .animate()
              .scale(delay: 1000.ms, duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'ecobot_fab',
            onPressed: () {
              // N'envoie le contexte qu'une seule fois par résultat de scan
              if (!_chatContextSent) {
                _chatContextSent = true;
                final lang = ref.read(localeProvider).languageCode;
                final cat = scan.category;
                final question = switch (lang) {
                  'en' => 'I just scanned a "$cat" waste item. '
                      'It is ${scan.recyclable ? "recyclable" : "not recyclable"}. '
                      'How should I dispose of it correctly?',
                  'ar' => 'لقد قمت للتو بمسح نفاية من نوع "$cat". '
                      'هي ${scan.recyclable ? "قابلة للتدوير" : "غير قابلة للتدوير"}. '
                      'كيف يمكنني التخلص منها بشكل صحيح؟',
                  'es' => 'Acabo de escanear un residuo de tipo "$cat". '
                      'Es ${scan.recyclable ? "reciclable" : "no reciclable"}. '
                      '¿Cómo debo desecharlo correctamente?',
                  _ => 'Je viens de scanner un déchet de type "$cat". '
                      'Il est ${scan.recyclable ? "recyclable" : "non recyclable"}. '
                      'Comment le recycler ou l\'éliminer correctement ?',
                };
                ref.read(pendingChatContextProvider.notifier).state = question;
              }
              context.push('/chat');
            },
            backgroundColor: const Color(0xFFF5A623),
            elevation: 8,
            shape: const CircleBorder(),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
          )
              .animate()
              .scale(delay: 900.ms, duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms),
        ],
      ),
      body: Stack(
        children: [
          // Confetti (only for recyclable)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.15,
              colors: const [
                AppColors.primary,
                AppColors.teal,
                AppColors.accentLight,
                Colors.white,
                AppColors.primaryLight,
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/scan');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                        ),
                      ),
                      Text(
                        s.scanResultTitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: scan.mode == 'local'
                        ? _SimpleOfflineResult(scan: scan, isDark: isDark)
                        : Column(
                            children: [
                              // Composantes détectées (cloud only)
                              if (scan.components.isNotEmpty)
                                _ComponentsCard(scan: scan, isDark: isDark)
                                    .animate(delay: 80.ms)
                                    .fadeIn(duration: 400.ms)
                                    .slideY(begin: 0.15),
                              if (scan.components.isNotEmpty)
                                const SizedBox(height: 16),

                              // Points + CO₂
                              Row(
                                children: [
                                  Expanded(
                                    child: _PointsCard(scan: scan, isDark: isDark)
                                        .animate(delay: 300.ms)
                                        .fadeIn(duration: 400.ms)
                                        .slideY(begin: 0.2),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _Co2Card(scan: scan, isDark: isDark)
                                        .animate(delay: 380.ms)
                                        .fadeIn(duration: 400.ms)
                                        .slideY(begin: 0.2),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
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

// ── Widgets ──────────────────────────────────────────────────────────────────


class _PointsCard extends ConsumerStatefulWidget {
  final ScanEntry scan;
  final bool isDark;
  const _PointsCard({required this.scan, required this.isDark});

  @override
  ConsumerState<_PointsCard> createState() => _PointsCardState();
}

class _PointsCardState extends ConsumerState<_PointsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _pts;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pts = IntTween(begin: 0, end: widget.scan.points)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(400.ms, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: widget.isDark ? 0.2 : 0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentLight.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded,
                color: AppColors.accent, size: 26),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _pts,
            builder: (_, _) => Text(
              '+${_pts.value}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ),
          Text(
            AppStrings.of(ref.watch(localeProvider).languageCode).pointsEarnedScan,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Co2Card extends ConsumerWidget {
  final ScanEntry scan;
  final bool isDark;
  const _Co2Card({required this.scan, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.co2_rounded,
                color: AppColors.teal, size: 26),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: scan.co2Saved),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (_, v, _) => Text(
              '${(v / 1000).toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
            ),
          ),
          Text(
            s.co2SavedLabel,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentsCard extends ConsumerWidget {
  final ScanEntry scan;
  final bool isDark;
  const _ComponentsCard({required this.scan, required this.isDark});

  Color _colorForBin(String bin) {
    switch (bin) {
      case 'yellow':   return const Color(0xFFF39C12);
      case 'blue':     return const Color(0xFF3498DB);
      case 'green':    return AppColors.primary;
      case 'brown':    return const Color(0xFF8B5E3C);
      case 'black':    return const Color(0xFF757575);
      case 'textile':  return const Color(0xFF9B59B6);
      case 'special':
      case 'ecopoint': return const Color(0xFFE74C3C);
      default:         return AppColors.textSecondary;
    }
  }

  // Electronique et dangereux → rouge (collecte spéciale), textile → violet
  Color _colorForComponent(String label, String bin) {
    return _colorForBin(bin);
  }

  bool _isRecyclable(String label) => const {
    'plastique', 'verre', 'metal', 'cardboard', 'paper', 'organique',
    'textile', 'vetement', 'chaussures', 'bois',
  }.contains(label);

  IconData _iconForLabel(String label) {
    switch (label) {
      case 'plastique':    return Icons.water_drop_outlined;
      case 'verre':        return Icons.wine_bar_outlined;
      case 'metal':        return Icons.hardware_outlined;
      case 'cardboard':    return Icons.inventory_2_outlined;
      case 'paper':        return Icons.description_outlined;
      case 'organique':    return Icons.eco_outlined;
      case 'electronique': return Icons.devices_outlined;
      case 'textile':      return Icons.checkroom_outlined;
      case 'dangereux':    return Icons.warning_amber_outlined;
      case 'bois':         return Icons.forest_outlined;
      default:             return Icons.delete_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                s.componentsDetected,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...scan.components.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final binC = _colorForComponent(c.label, c.binColor);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: binC.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: binC.withValues(alpha: 0.30)),
                boxShadow: [
                  BoxShadow(
                    color: binC.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header : icône matière + partie + label badge + recyclable badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: Row(
                      children: [
                        // Icône matière colorée
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: binC.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_iconForLabel(c.label), color: binC, size: 18),
                        ),
                        const SizedBox(width: 10),
                        // Nom + badge label (gauche)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.partie,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: binC,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s.materialName(c.label),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge Recyclable / Dangereux (droite)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isRecyclable(c.label)
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : const Color(0xFFE74C3C).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isRecyclable(c.label)
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : const Color(0xFFE74C3C).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _isRecyclable(c.label) ? s.recyclableTag : s.dangerousTag,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isRecyclable(c.label)
                                  ? AppColors.primary
                                  : const Color(0xFFE74C3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(height: 1, thickness: 1, color: binC.withValues(alpha: 0.15), indent: 14, endIndent: 14),
                  // Bac row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: binC.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.delete_rounded, size: 13, color: binC),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${s.putIn} : ${s.binColorName(c.binColor)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: binC,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conseil
                  if (c.conseil.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_rounded, size: 14, color: const Color(0xFFF5A623)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                c.conseil,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkText.withValues(alpha: 0.8)
                                      : AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            )
                .animate(delay: (120 * index).ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.25, end: 0, curve: Curves.easeOut);
          }),
        ],
      ),
    );
  }
}

// ── Vue simplifiée pour le mode offline TFLite ───────────────────────────────

class _SimpleOfflineResult extends ConsumerWidget {
  final ScanEntry scan;
  final bool isDark;
  const _SimpleOfflineResult({required this.scan, required this.isDark});

  static IconData _iconForCategory(String label) {
    switch (label) {
      case 'plastique':    return Icons.water_drop_outlined;
      case 'verre':        return Icons.wine_bar_outlined;
      case 'metal':        return Icons.hardware_outlined;
      case 'cardboard':    return Icons.inventory_2_outlined;
      case 'paper':        return Icons.description_outlined;
      case 'organique':    return Icons.eco_outlined;
      case 'electronique': return Icons.devices_outlined;
      case 'textile':
      case 'vetement':     return Icons.checkroom_outlined;
      case 'chaussures':   return Icons.hiking_outlined;
      case 'dangereux':    return Icons.warning_amber_outlined;
      case 'bois':         return Icons.forest_outlined;
      default:             return Icons.delete_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final pct = scan.recyclability;
    final barColor = scan.dangerous ? const Color(0xFFE74C3C) : AppColors.primary;
    final heroGradient = scan.dangerous
        ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
        : scan.recyclable
            ? [AppColors.primary, AppColors.teal]
            : [AppColors.textSecondary, const Color(0xFF555555)];

    String qualityLabel;
    if (pct >= 0.8) {
      qualityLabel = '🌿 ${_t(s, 'Excellent', 'Excellent', 'ممتاز', 'Excelente')}';
    } else if (pct >= 0.6) {
      qualityLabel = '👍 ${_t(s, 'Bon', 'Good', 'جيد', 'Bueno')}';
    } else if (pct >= 0.4) {
      qualityLabel = '⚠️ ${_t(s, 'Moyen', 'Fair', 'متوسط', 'Regular')}';
    } else {
      qualityLabel = '🗑️ ${_t(s, 'Faible', 'Low', 'منخفض', 'Bajo')}';
    }

    return Column(
      children: [
        // ── Hero banner (horizontal, gradient plein) ──────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: heroGradient.first.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconForCategory(scan.category),
                    color: Colors.white, size: 30),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.93, 0.93),
                    end: const Offset(1.07, 1.07),
                    duration: 1400.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.dangerous
                          ? '⚠️ ${s.dangerousResult}'
                          : scan.recyclable
                              ? '✅ ${s.recyclableResult}'
                              : '🗑️ ${s.nonRecyclableResult}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${scan.name} — ${s.materialName(scan.category)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(delay: 60.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.15),
        const SizedBox(height: 12),

        // ── Badge TFLite ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.offline_bolt_rounded,
                  color: Colors.orange, size: 15),
              const SizedBox(width: 6),
              Text(
                s.modeLocal,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        )
            .animate(delay: 120.ms)
            .fadeIn(duration: 350.ms),
        const SizedBox(height: 14),

        // ── Recyclabilité ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.recyclabilityLevel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (_, v, _) => Text(
                      '${(v * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: barColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (_, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: barColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0%',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  Text(qualityLabel,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: barColor)),
                  Text('100%',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.15),
        const SizedBox(height: 14),

        // ── Points + CO₂ ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _PointsCard(scan: scan, isDark: isDark)
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Co2Card(scan: scan, isDark: isDark)
                  .animate(delay: 380.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Détails de l'objet ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.detailsTitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(label: s.materialType,
                  value: s.materialName(scan.category), isDark: isDark),
              _DetailRow(
                label: s.recyclabilityLevel,
                value: scan.recyclable
                    ? '${s.yes} ✓'
                    : '${s.no} ✗',
                valueColor: scan.recyclable
                    ? AppColors.primary
                    : const Color(0xFFE74C3C),
                isDark: isDark,
              ),
              _DetailRow(label: s.sortingInstruction,
                  value: s.binColorName(scan.binColor), isDark: isDark),
              _DetailRow(
                label: s.aiConfidence,
                value: '${(scan.recyclability * 100).round()}%',
                valueColor: barColor,
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
        )
            .animate(delay: 460.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.15),
        const SizedBox(height: 16),
      ],
    );
  }

  static String _t(AppStrings s, String fr, String en, String ar, String es) {
    switch (s.languageCode) {
      case 'en': return en;
      case 'ar': return ar;
      case 'es': return es;
      default:   return fr;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ??
                      (isDark ? AppColors.darkText : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
      ],
    );
  }
}

