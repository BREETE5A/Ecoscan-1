// Overlay hors-ligne : antenne WiFi animée, SlideTransition depuis le bas,
// disparaît automatiquement quand la connexion revient.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class NoConnectionOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const NoConnectionOverlay({super.key, required this.child});

  @override
  ConsumerState<NoConnectionOverlay> createState() =>
      _NoConnectionOverlayState();
}

class _NoConnectionOverlayState extends ConsumerState<NoConnectionOverlay>
    with TickerProviderStateMixin {
  // Animation slide depuis le bas
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // Pulse du bouton "Réessayer"
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // Ondes WiFi (3 cercles qui s'estompent en boucle)
  late AnimationController _wifiCtrl;

  bool _wasOffline = false;
  bool _showReconnected = false;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _wifiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    _wifiCtrl.dispose();
    super.dispose();
  }

  // Appelé à chaque changement du provider de connexion
  void _handleConnectivity(bool isOffline) {
    if (isOffline && !_wasOffline) {
      _slideCtrl.forward();
    } else if (!isOffline && _wasOffline) {
      _slideCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _showReconnected = true);
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) setState(() => _showReconnected = false);
        });
      });
    }
    _wasOffline = isOffline;
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineProvider);
    _handleConnectivity(isOffline);

    return Stack(
      children: [
        widget.child,

        // Overlay hors-ligne
        SlideTransition(
          position: _slideAnim,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _OfflinePanel(
              wifiCtrl: _wifiCtrl,
              pulse: _pulse,
              onRetry: () {
                // Force un re-watch du provider de connectivité
                ref.invalidate(connectivityProvider);
              },
            ),
          ),
        ),

        // Toast "Connexion rétablie"
        if (_showReconnected)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _ReconnectedToast(),
          ),
      ],
    );
  }
}

// ── Panneau offline ───────────────────────────────────────────────────────────
class _OfflinePanel extends StatelessWidget {
  final AnimationController wifiCtrl;
  final Animation<double> pulse;
  final VoidCallback onRetry;

  const _OfflinePanel({
    required this.wifiCtrl,
    required this.pulse,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Antenne WiFi avec ondes animées
          SizedBox(
            width: 80,
            height: 80,
            child: AnimatedBuilder(
              animation: wifiCtrl,
              builder: (_, _) => CustomPaint(
                painter: _WifiPainter(progress: wifiCtrl.value),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Connexion introuvable',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Certaines fonctions restent disponibles hors-ligne 🌿',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: pulse,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toast succès ──────────────────────────────────────────────────────────────
class _ReconnectedToast extends StatefulWidget {
  @override
  State<_ReconnectedToast> createState() => _ReconnectedToastState();
}

class _ReconnectedToastState extends State<_ReconnectedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Connexion rétablie ✅',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Painter antenne WiFi avec ondes cycliques ─────────────────────────────────
class _WifiPainter extends CustomPainter {
  final double progress; // 0..1 en boucle

  const _WifiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;

    // Antenne (ligne verticale + base)
    final antPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 22), antPaint);
    canvas.drawLine(
        Offset(cx - 10, cy + 2), Offset(cx + 10, cy + 2), antPaint);

    // 3 ondes semi-circulaires qui s'estompent selon la progression
    for (int i = 0; i < 3; i++) {
      final delay = i / 3.0;
      final t = ((progress - delay) % 1.0 + 1.0) % 1.0;
      final alpha = (1.0 - t).clamp(0.0, 1.0);
      final radius = 12.0 + i * 10.0;

      final wavePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: alpha * 0.8)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: radius * 2,
          height: radius * 2,
        ),
        3.14159 * 1.25,
        3.14159 * 0.5,
        false,
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WifiPainter old) => old.progress != progress;
}
