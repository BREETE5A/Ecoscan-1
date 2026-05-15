import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_entry.dart';
import '../../providers/scan_history_provider.dart';

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
    final text =
        '🌿 J\'ai scanné "${entry.name}" avec EcoScan !\n'
        '♻️ ${entry.recyclable ? "Recyclable" : "Non recyclable"} — ${(entry.recyclability * 100).round()}% recyclabilité\n'
        '💚 CO₂ économisé : ${entry.co2Saved.round()} g\n'
        '⭐ +${entry.points} pts gagnés\n\n'
        '#EcoScan #Recyclage #EcoResponsable';
    Share.share(text, subject: 'Mon scan EcoScan');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entry = ref.watch(currentScanProvider);

    // Fallback to a default entry if none
    final scan = entry ??
        ScanEntry(
          id: 'fallback',
          name: 'Bouteille PET',
          category: 'Plastique',
          recyclable: true,
          dangerous: false,
          points: 15,
          co2Saved: 45.0,
          recyclability: 0.92,
          binColor: 'Jaune',
          scannedAt: DateTime.now(),
          mode: 'cloud',
        );

    final accentColor = scan.dangerous
        ? const Color(0xFFE74C3C)
        : scan.recyclable
            ? AppColors.primary
            : AppColors.textSecondary;

    return Scaffold(
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
                        onTap: () => context.go('/scan'),
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
                      const Text(
                        'Résultat du scan',
                        style: TextStyle(
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

                        // Mode indicator
                        _ModeIndicator(mode: scan.mode)
                            .animate(delay: 150.ms)
                            .fadeIn(duration: 300.ms),
                        const SizedBox(height: 16),

                        // Recyclability bar
                        _RecyclabilityCard(
                            scan: scan, isDark: isDark, accentColor: accentColor)
                            .animate(delay: 250.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
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
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/scan'),
                                icon: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 18),
                                label: const Text('Re-scanner',
                                    style: TextStyle(fontFamily: 'Poppins')),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.go('/map'),
                                icon: const Icon(Icons.map_rounded, size: 18),
                                label: const Text('Voir carte',
                                    style: TextStyle(fontFamily: 'Poppins')),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
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
                            label: const Text(
                              'Partager mes résultats',
                              style: TextStyle(fontFamily: 'Poppins'),
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

class _HeroBanner extends StatelessWidget {
  final ScanEntry scan;
  final Color accentColor;
  const _HeroBanner({required this.scan, required this.accentColor});

  @override
  Widget build(BuildContext context) {
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
                      ? '⚠️ Déchet dangereux'
                      : scan.recyclable
                          ? '✅ Objet recyclable !'
                          : '❌ Non recyclable',
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

class _ModeIndicator extends StatelessWidget {
  final String mode;
  const _ModeIndicator({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isCloud = mode == 'cloud';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isCloud
                ? AppColors.info.withValues(alpha: 0.1)
                : AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCloud
                  ? AppColors.info.withValues(alpha: 0.4)
                  : AppColors.accent.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCloud
                    ? Icons.cloud_done_rounded
                    : Icons.offline_bolt_rounded,
                color: isCloud ? AppColors.info : AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isCloud
                    ? 'Identifié par YOLOv8 Cloud (97% confiance)'
                    : 'Identifié par TFLite Local (hors-ligne)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCloud ? AppColors.info : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecyclabilityCard extends StatelessWidget {
  final ScanEntry scan;
  final bool isDark;
  final Color accentColor;
  const _RecyclabilityCard(
      {required this.scan, required this.isDark, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final pct = (scan.recyclability * 100).round();
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
                'Niveau de recyclabilité',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: scan.recyclability),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor:
                    isDark ? AppColors.darkInput : AppColors.inputBg,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary)),
              Text(
                pct >= 80
                    ? '🌿 Excellent'
                    : pct >= 50
                        ? '♻️ Acceptable'
                        : '⚠️ Faible',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              Text('100%',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatefulWidget {
  final ScanEntry scan;
  final bool isDark;
  const _PointsCard({required this.scan, required this.isDark});

  @override
  State<_PointsCard> createState() => _PointsCardState();
}

class _PointsCardState extends State<_PointsCard>
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
          const Text(
            'Points gagnés',
            style: TextStyle(
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

class _Co2Card extends StatelessWidget {
  final ScanEntry scan;
  final bool isDark;
  const _Co2Card({required this.scan, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'CO₂ économisé',
            style: TextStyle(
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

class _DetailCard extends StatelessWidget {
  final ScanEntry scan;
  final bool isDark;
  const _DetailCard({required this.scan, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
            'Détails de l\'objet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow('Type', scan.category, isDark),
          _DetailRow('Recyclable', scan.recyclable ? 'Oui ✓' : 'Non ✗', isDark,
              valueColor:
                  scan.recyclable ? AppColors.primary : AppColors.danger),
          _DetailRow('Consigne de tri', 'Bac ${scan.binColor}', isDark),
          _DetailRow('Confiance IA', '97%', isDark, valueColor: AppColors.teal),
          if (scan.dangerous)
            _DetailRow('⚠️ Attention', 'Déchet dangereux', isDark,
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

class _BinCard extends StatelessWidget {
  final ScanEntry scan;
  final bool isDark;
  const _BinCard({required this.scan, required this.isDark});

  Color get _binColor {
    switch (scan.binColor) {
      case 'Jaune':
        return const Color(0xFFF39C12);
      case 'Bleu':
        return const Color(0xFF3498DB);
      case 'Vert':
        return AppColors.primary;
      case 'Noir':
        return const Color(0xFF2C3E50);
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Bac ${scan.binColor}',
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
                      ? 'Apportez ce déchet dans un point de collecte spécifique.'
                      : 'Déposez ${scan.name} dans le bac ${scan.binColor.toLowerCase()}. Pensez à le rincer avant.',
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

class _NearbyCard extends StatelessWidget {
  final bool isDark;
  const _NearbyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
                'Points de collecte proches',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/map'),
                child: const Text(
                  'Voir carte',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            ('Centre de tri Alger', '0.4 km', Icons.recycling_rounded, AppColors.primary),
            ('Bac jaune Rue Principale', '1.2 km', Icons.delete_outline_rounded, AppColors.accent),
            ('Point DEEE — Mairie', '2.1 km', Icons.electrical_services_rounded, AppColors.danger),
          ].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: e.$4.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(e.$3, color: e.$4, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.$1,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.textPrimary,
                          )),
                    ),
                    Text(e.$2,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
