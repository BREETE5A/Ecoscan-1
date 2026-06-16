import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_entry.dart';
import '../../providers/scan_history_provider.dart';
import '../../providers/challenges_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late ConfettiController _confetti;

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

  void _share(ScanEntry entry) {
    final s = AppStrings.of(ref.read(localeProvider).languageCode);
    final text = s.shareText(
      entry.name,
      entry.recyclable,
      (entry.recyclability * 100).round(),
      entry.co2Saved.round(),
      entry.points,
    );
    Share.share(text, subject: 'EcoScan');
    ref.read(challengesProvider.notifier).shareContent();
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
    final accentColor = scan.dangerous
        ? const Color(0xFFE74C3C)
        : scan.recyclable
            ? AppColors.primary
            : AppColors.textSecondary;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/chat'),
        backgroundColor: const Color(0xFFF5A623),
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
      )
          .animate()
          .scale(delay: 900.ms, duration: 500.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 300.ms),
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
                      // Share button
                      GestureDetector(
                        onTap: () => _share(scan),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        // Success/danger banner
                        _HeroBanner(scan: scan, accentColor: accentColor)
                            .animate()
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),

                        // Components card
                        if (scan.components.isNotEmpty)
                          _ComponentsCard(scan: scan, isDark: isDark)
                              .animate(delay: 150.ms)
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.2),
                        if (scan.components.isNotEmpty)
                          const SizedBox(height: 16),

                        // Points + CO₂
                        Row(
                          children: [
                            Expanded(
                              child: _PointsCard(scan: scan, isDark: isDark)
                                  .animate(delay: 350.ms)
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: 0.2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Co2Card(scan: scan, isDark: isDark)
                                  .animate(delay: 420.ms)
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: 0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Waste details
                        _DetailCard(scan: scan, isDark: isDark)
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 16),

                        // Bin instruction
                        _BinCard(scan: scan, isDark: isDark)
                            .animate(delay: 580.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 16),

                        // Nearby collection points
                        _NearbyCard(isDark: isDark)
                            .animate(delay: 660.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 24),

                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/scan'),
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                            label: Text(s.rescan,
                                style: const TextStyle(fontFamily: 'Poppins')),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        )
                            .animate(delay: 750.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 12),

                        // Share social button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _share(scan),
                            icon: const Icon(Icons.ios_share_rounded, size: 18),
                            label: Text(
                              s.shareResults,
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        )
                            .animate(delay: 820.ms)
                            .fadeIn(duration: 400.ms),
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

class _HeroBanner extends ConsumerWidget {
  final ScanEntry scan;
  final Color accentColor;
  const _HeroBanner({required this.scan, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              scan.dangerous
                  ? Icons.warning_amber_rounded
                  : scan.recyclable
                      ? Icons.recycling_rounded
                      : Icons.delete_outline_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.dangerous
                      ? s.heroDangerous
                      : scan.recyclable
                          ? s.heroRecyclable
                          : s.heroNotRecyclable,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${scan.name} — ${scan.category}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
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

class _DetailCard extends ConsumerWidget {
  final ScanEntry scan;
  final bool isDark;
  const _DetailCard({required this.scan, required this.isDark});

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
          Text(
            s.itemDetails,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(s.labelType, scan.category, isDark),
          _DetailRow(s.labelRecyclable, scan.recyclable ? s.valueYes : s.valueNo, isDark,
              valueColor: scan.recyclable ? AppColors.primary : AppColors.danger),
          _DetailRow(s.sortingInstruction, '${s.binLabel} ${s.binColorName(scan.binColor)}', isDark),
          _DetailRow(s.aiConfidence, '${(scan.recyclability * 100).round()}%', isDark, valueColor: AppColors.teal),
          if (scan.dangerous)
            _DetailRow(s.attentionLabel, s.dangerousWaste, isDark,
                valueColor: AppColors.danger),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  const _DetailRow(this.label, this.value, this.isDark, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    (isDark ? AppColors.darkText : AppColors.textPrimary),
              )),
        ],
      ),
    );
  }
}

class _BinCard extends ConsumerWidget {
  final ScanEntry scan;
  final bool isDark;
  const _BinCard({required this.scan, required this.isDark});

  Color get _binColor {
    switch (scan.binColor) {
      case 'yellow':   return const Color(0xFFF39C12);
      case 'blue':     return const Color(0xFF3498DB);
      case 'green':    return AppColors.primary;
      case 'black':    return const Color(0xFF2C3E50);
      case 'brown':    return const Color(0xFF8B5E3C);
      case 'ecopoint': return const Color(0xFF27AE60);
      default:         return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final c = _binColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.binLabel} ${s.binColorName(scan.binColor)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scan.dangerous
                      ? s.bringToPoint
                      : s.binInstruction(scan.name, scan.binColor),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

  // Electronique et dangereux → rouge (danger), autres → couleur du bac
  Color _colorForComponent(String label, String bin) {
    if (label == 'electronique' || label == 'dangereux') {
      return const Color(0xFFE74C3C);
    }
    return _colorForBin(bin);
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
                  // Header : partie + label badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 6),
                    child: Row(
                      children: [
                        // Colored bin dot (pulsing)
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: binC,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: binC.withValues(alpha: 0.4), blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.partie,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkText : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Label badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: binC,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            c.label,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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

class _NearbyCard extends ConsumerWidget {
  final bool isDark;
  const _NearbyCard({required this.isDark});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.nearbyPoints,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/map'),
                child: Text(
                  s.viewMap,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.go('/map'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    s.viewMap,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
