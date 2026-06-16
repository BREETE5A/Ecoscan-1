import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_entry.dart';
import '../../providers/scan_history_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late ConfettiController _confetti;

  static const _n8nWebhookUrl = 'https://badora.app.n8n.cloud/webhook/ecoscan/alerte-danger';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entry = ref.read(currentScanProvider);
      if (entry == null) return;
      if (!entry.dangerous) _confetti.play();
      final hasEwaste = entry.components.any(
        (c) => c.label == 'electronique' || c.label == 'dangereux',
      );
      if (hasEwaste) _notifyN8n(entry);
    });
  }

  Future<void> _notifyN8n(ScanEntry scan) async {
    try {
      await Dio().post(_n8nWebhookUrl, data: {
        'email': 'badreddinehammoucha@gmail.com',
        'objet': scan.name,
        'date': DateTime.now().toIso8601String(),
        'composantes': scan.components
            .where((c) => c.label == 'electronique' || c.label == 'dangereux')
            .map((c) => {
                  'partie': c.partie,
                  'label': c.label,
                  'conseil': c.conseil,
                })
            .toList(),
      });
      if (mounted) {
        final s = AppStrings.of(ref.read(localeProvider).languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.email_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(s.alertEmailSent,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
            ]),
            backgroundColor: const Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {}
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
            onPressed: () => context.go('/map'),
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
            onPressed: () => context.go('/chat'),
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
                    child: Column(
                      children: [
                        // Composantes détectées
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
              '${v.round()} g',
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
      case 'ecopoint': return const Color(0xFF27AE60);
      default:         return AppColors.textSecondary;
    }
  }

  // Electronique et dangereux → rouge, autres → couleur du bac
  Color _colorForComponent(String label, String bin) {
    if (label == 'electronique' || label == 'dangereux') return const Color(0xFFE74C3C);
    return _colorForBin(bin);
  }

  bool _isRecyclable(String label) => const {
    'plastique', 'verre', 'metal', 'cardboard', 'paper', 'organique', 'textile', 'bois',
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.partie,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                                ),
                              ),
                              // Badge recyclable / danger
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: binC,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      c.label,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _isRecyclable(c.label)
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : const Color(0xFFE74C3C).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _isRecyclable(c.label) ? s.recyclableTag : s.dangerousTag,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: _isRecyclable(c.label)
                                            ? AppColors.primary
                                            : const Color(0xFFE74C3C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

