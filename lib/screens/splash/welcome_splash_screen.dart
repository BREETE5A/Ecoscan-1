// Page de transition post-auth : animation scanner 2 s
// thème scan → éco : viewfinder + faisceau vert + texte + feuilles
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

const _kPhase1End = 400;   // viewfinder + icône scale in
const _kPhase2End = 900;   // faisceau de scan
const _kPhase3End = 1300;  // texte slide up
const _kPhase4End = 1700;  // feuilles + navigation

enum _Scenario { firstTime, longAbsence, regular }

class WelcomeSplashScreen extends ConsumerStatefulWidget {
  const WelcomeSplashScreen({super.key});
  @override
  ConsumerState<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends ConsumerState<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late AnimationController _beamCtrl;
  late AnimationController _textCtrl;
  late AnimationController _leavesCtrl;
  late AnimationController _exitCtrl;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  bool _skipped = false;
  bool _reduceMotion = false;
  _Scenario _scenario = _Scenario.regular;
  String _firstName = '';

  @override
  void initState() {
    super.initState();
    _initUserData();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase1End),
    );
    _beamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase2End - _kPhase1End),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase3End - _kPhase2End),
    );
    _leavesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase4End - _kPhase3End),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _exitFade = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitScale = Tween(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  Future<void> _initUserData() async {
    final user = ref.read(currentUserProvider);
    _firstName = user?.displayName.split(' ').first ?? '';

    final prefs = await SharedPreferences.getInstance();
    final firstDone   = prefs.getBool('welcome_shown') ?? false;
    final lastLoginMs = prefs.getInt('last_login_ms') ?? 0;
    final daysSince   = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastLoginMs))
        .inDays;

    if (!firstDone) {
      _scenario = _Scenario.firstTime;
    } else if (daysSince >= 7) {
      _scenario = _Scenario.longAbsence;
    } else {
      _scenario = _Scenario.regular;
    }

    await prefs.setBool('welcome_shown', true);
    await prefs.setInt('last_login_ms', DateTime.now().millisecondsSinceEpoch);
    if (mounted) setState(() {});
    _startSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
  }

  Future<void> _startSequence() async {
    if (_reduceMotion) {
      await Future.delayed(const Duration(milliseconds: 400));
      _navigate();
      return;
    }
    _scanCtrl.forward();
    await Future.delayed(const Duration(milliseconds: _kPhase1End + 50));
    if (!mounted || _skipped) return;

    _beamCtrl.forward();
    await Future.delayed(const Duration(milliseconds: _kPhase2End - _kPhase1End + 50));
    if (!mounted || _skipped) return;

    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: _kPhase3End - _kPhase2End + 50));
    if (!mounted || _skipped) return;

    _leavesCtrl.forward();
    await Future.delayed(const Duration(milliseconds: _kPhase4End - _kPhase3End));
    if (!mounted || _skipped) return;

    await _exitCtrl.forward();
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    context.go('/home');
  }

  void _skip() {
    if (_skipped) return;
    _skipped = true;
    _exitCtrl.forward(from: 0).then((_) => _navigate());
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _beamCtrl.dispose();
    _textCtrl.dispose();
    _leavesCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  LinearGradient get _bgGradient {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 12) {
      return const LinearGradient(
        colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      );
    } else if (h >= 12 && h < 18) {
      return const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      );
    } else if (h >= 18 && h < 22) {
      return const LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF0A2E0F)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF0D1B2A), Color(0xFF1A3320)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      );
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    final name = _firstName.isNotEmpty ? ' $_firstName' : '';
    if (_scenario == _Scenario.firstTime)   return 'Bienvenue$name ! 🌿';
    if (_scenario == _Scenario.longAbsence) return 'Content de te revoir ! 🌍';
    if (h >= 6 && h < 12)  return 'Bonjour$name ! 🌅';
    if (h >= 12 && h < 18) return 'Bon après-midi ! ☀️';
    if (h >= 18 && h < 22) return 'Bonsoir$name ! 🌙';
    return 'Bonne nuit$name 🌟';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skip,
      child: AnimatedBuilder(
        animation: _exitCtrl,
        builder: (_, child) => Opacity(
          opacity: _exitFade.value,
          child: Transform.scale(scale: _exitScale.value, child: child),
        ),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: _bgGradient),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grille de points subtile
                Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

                // Scanner central (viewfinder + faisceau)
                _ScannerWidget(scanCtrl: _scanCtrl, beamCtrl: _beamCtrl),

                // Feuilles volantes (phase 4)
                ...List.generate(8, (i) => _LeafParticle(
                  ctrl: _leavesCtrl,
                  angle: i * (2 * math.pi / 8),
                  distance: 90 + (i % 2) * 50.0,
                  delay: i * 0.05,
                  size: 16 + (i % 3) * 6.0,
                )),

                // Texte (phase 3)
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.18,
                  left: 32,
                  right: 32,
                  child: AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _textCtrl.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textCtrl.value)),
                        child: child,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _greeting,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prêt à trier intelligemment ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 28,
                  child: Text(
                    'Appuyer pour passer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Grille de points en fond ──────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

// ── Widget scanner ────────────────────────────────────────────────────────────
class _ScannerWidget extends StatelessWidget {
  final AnimationController scanCtrl;
  final AnimationController beamCtrl;
  const _ScannerWidget({required this.scanCtrl, required this.beamCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scanCtrl, beamCtrl]),
      builder: (_, _) {
        final scaleVal = CurvedAnimation(parent: scanCtrl, curve: Curves.elasticOut)
            .value
            .clamp(0.0, 1.15);
        final beamDone = beamCtrl.status == AnimationStatus.completed;

        final viewColor = Color.lerp(
          Colors.white,
          const Color(0xFF69F0AE),
          beamCtrl.value,
        )!;

        return Transform.scale(
          scale: scaleVal,
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fond semi-transparent
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),

                // Icône centrale
                if (scanCtrl.value > 0)
                  Opacity(
                    opacity: (scanCtrl.value * 1.5).clamp(0.0, 1.0),
                    child: AnimatedScale(
                      scale: beamDone ? 1.18 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.elasticOut,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          beamDone
                              ? Icons.check_circle_outline_rounded
                              : Icons.qr_code_scanner_rounded,
                          color: beamDone ? const Color(0xFF69F0AE) : Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),

                // Faisceau de scan
                if (beamCtrl.value > 0 && !beamDone)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: _ScanLinePainter(progress: beamCtrl.value),
                    ),
                  ),

                // Coins du viewfinder
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _ViewfinderPainter(
                    color: viewColor,
                    progress: scanCtrl.value.clamp(0.0, 1.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Faisceau laser de scan ────────────────────────────────────────────────────
class _ScanLinePainter extends CustomPainter {
  final double progress;
  const _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final y = size.height * progress;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF69F0AE).withValues(alpha: 0.0),
          const Color(0xFF69F0AE).withValues(alpha: 0.28),
          const Color(0xFF69F0AE).withValues(alpha: 0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 28, size.width, 56));
    canvas.drawRect(Rect.fromLTWH(0, y - 28, size.width, 56), glowPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF69F0AE)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), linePaint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.progress != progress;
}

// ── Coins du viewfinder ───────────────────────────────────────────────────────
class _ViewfinderPainter extends CustomPainter {
  final Color color;
  final double progress;
  const _ViewfinderPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final len = size.width * 0.22 * progress;
    const m = 6.0; // marge
    final w = size.width - m;
    final h = size.height - m;

    // Coin haut-gauche
    canvas.drawLine(Offset(m, m), Offset(m + len, m), paint);
    canvas.drawLine(Offset(m, m), Offset(m, m + len), paint);
    // Coin haut-droit
    canvas.drawLine(Offset(w, m), Offset(w - len, m), paint);
    canvas.drawLine(Offset(w, m), Offset(w, m + len), paint);
    // Coin bas-gauche
    canvas.drawLine(Offset(m, h), Offset(m + len, h), paint);
    canvas.drawLine(Offset(m, h), Offset(m, h - len), paint);
    // Coin bas-droit
    canvas.drawLine(Offset(w, h), Offset(w - len, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) =>
      old.color != color || old.progress != progress;
}

// ── Feuille volante ───────────────────────────────────────────────────────────
class _LeafParticle extends StatelessWidget {
  final AnimationController ctrl;
  final double angle;
  final double distance;
  final double delay;
  final double size;

  const _LeafParticle({
    required this.ctrl,
    required this.angle,
    required this.distance,
    required this.delay,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, _) {
        final t = ((ctrl.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final curved = Curves.easeOut.transform(t);
        return Transform.translate(
          offset: Offset(
            math.cos(angle) * distance * curved,
            math.sin(angle) * distance * curved,
          ),
          child: Opacity(
            opacity: (1.0 - t * 1.2).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: angle + curved * math.pi,
              child: Icon(Icons.eco_rounded, color: Colors.white, size: size),
            ),
          ),
        );
      },
    );
  }
}
