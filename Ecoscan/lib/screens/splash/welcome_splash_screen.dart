// Page de transition post-auth : 4 phases, checkmark trait par trait,
// feuilles volantes, variantes heure/scénario, skip sur tap, reduceMotion.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

// ── Constantes de timing ──────────────────────────────────────────────────────
const _kPhase1End  = 800;   // ms — cercle + icône
const _kPhase2End  = 1500;  // ms — checkmark
const _kPhase3End  = 2200;  // ms — texte
const _kPhase4End  = 3000;  // ms — feuilles + sortie

// ── Scénario de message ───────────────────────────────────────────────────────
enum _Scenario { firstTime, longAbsence, regular }

// ── Page principale ───────────────────────────────────────────────────────────
class WelcomeSplashScreen extends ConsumerStatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  ConsumerState<WelcomeSplashScreen> createState() =>
      _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends ConsumerState<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  // Phase 1 : cercle pulse
  late AnimationController _circleCtrl;
  late Animation<double> _circleScale;

  // Phase 1b : rotation icône ♻️
  late AnimationController _iconRotCtrl;
  late Animation<double> _iconRot;

  // Phase 2 : checkmark trait par trait
  late AnimationController _checkCtrl;

  // Phase 3 : texte slide-up
  late AnimationController _textCtrl;

  // Phase 4 : feuilles volantes
  late AnimationController _leavesCtrl;

  // Sortie globale (fade + scale down)
  late AnimationController _exitCtrl;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  bool _skipped  = false;
  bool _reduceMotion = false;
  _Scenario _scenario = _Scenario.regular;
  String _firstName = '';

  @override
  void initState() {
    super.initState();

    // Récupérer le prénom et calculer le scénario
    _initUserData();

    // Phase 1 : cercle 0 → 1.1 → 1.0 en 800 ms
    _circleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase1End),
    );
    _circleScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.15)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 70),
      TweenSequenceItem(
          tween: Tween(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
    ]).animate(_circleCtrl);

    // Phase 1b : rotation icône 0 → 2π en 800 ms elasticOut
    _iconRotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase1End),
    );
    _iconRot = Tween(begin: 0.0, end: 2 * math.pi)
        .animate(CurvedAnimation(parent: _iconRotCtrl, curve: Curves.elasticOut));

    // Phase 2 : checkmark 0 → 1 en (1500-800) ms
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase2End - _kPhase1End),
    );

    // Phase 3 : fade/slide du texte en (2200-1500) ms
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase3End - _kPhase2End),
    );

    // Phase 4 : feuilles en (3000-2200) ms
    _leavesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kPhase4End - _kPhase3End),
    );

    // Sortie : fade + scale 300 ms
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _exitFade = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitScale = Tween(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  Future<void> _initUserData() async {
    // Prénom depuis le provider
    final user = ref.read(currentUserProvider);
    _firstName = user?.displayName.split(' ').first ?? '';

    // Scénario : SharedPreferences
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
      // Pas d'animations si l'accessibilité le demande — skip direct
      await Future.delayed(const Duration(milliseconds: 500));
      _navigate();
      return;
    }

    // Phase 1
    _circleCtrl.forward();
    _iconRotCtrl.forward();
    await Future.delayed(const Duration(milliseconds: _kPhase1End + 50));
    if (!mounted || _skipped) return;

    // Phase 2
    _checkCtrl.forward();
    await Future.delayed(
        const Duration(milliseconds: _kPhase2End - _kPhase1End + 50));
    if (!mounted || _skipped) return;

    // Phase 3
    _textCtrl.forward();
    await Future.delayed(
        const Duration(milliseconds: _kPhase3End - _kPhase2End + 50));
    if (!mounted || _skipped) return;

    // Phase 4
    _leavesCtrl.forward();
    await Future.delayed(
        const Duration(milliseconds: _kPhase4End - _kPhase3End));
    if (!mounted || _skipped) return;

    // Sortie
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
    _circleCtrl.dispose();
    _iconRotCtrl.dispose();
    _checkCtrl.dispose();
    _textCtrl.dispose();
    _leavesCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ── Gradient selon l'heure ────────────────────────────────────────────────
  LinearGradient get _bgGradient {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 12) {
      // Matin : jaune → vert
      return const LinearGradient(
        colors: [Color(0xFFFFF176), Color(0xFF27AE60)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (h >= 12 && h < 18) {
      // Après-midi : vert clair
      return const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF27AE60)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (h >= 18 && h < 22) {
      // Soir : vert foncé
      return const LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF27AE60)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // Nuit : bleu nuit → vert
      return const LinearGradient(
        colors: [Color(0xFF0D1B2A), Color(0xFF1A3320)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // ── Texte selon l'heure et le scénario ───────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    final name = _firstName.isNotEmpty ? ' $_firstName' : '';
    if (_scenario == _Scenario.firstTime) {
      return 'Bienvenue$name ! 🌿';
    }
    if (_scenario == _Scenario.longAbsence) {
      return 'On avait hâte de te revoir ! 🌍';
    }
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
          child: Transform.scale(
            scale: _exitScale.value,
            child: child,
          ),
        ),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: _bgGradient),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Phase 1 + 2 : cercle + checkmark ───────────────────
                _CircleCheckmark(
                  circleCtrl:  _circleCtrl,
                  circleScale: _circleScale,
                  iconRotCtrl: _iconRotCtrl,
                  iconRot:     _iconRot,
                  checkCtrl:   _checkCtrl,
                ),

                // ── Phase 4 : feuilles volantes ─────────────────────────
                ...List.generate(6, (i) => _LeafParticle(
                  ctrl: _leavesCtrl,
                  angle: i * (2 * math.pi / 6),
                  distance: 80 + (i % 2) * 40.0,
                  delay: i * 0.06,
                  size: 18 + (i % 3) * 6.0,
                )),

                // ── Phase 3 : texte ─────────────────────────────────────
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.22,
                  left: 32,
                  right: 32,
                  child: AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _textCtrl.value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - _textCtrl.value)),
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
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Prêt à trier intelligemment ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
                ),

                // ── Indication "Appuyer pour passer" ────────────────────
                Positioned(
                  bottom: 32,
                  child: Text(
                    'Appuyer pour passer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
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

// ── Widget cercle + checkmark animé ──────────────────────────────────────────
class _CircleCheckmark extends StatelessWidget {
  final AnimationController circleCtrl;
  final Animation<double> circleScale;
  final AnimationController iconRotCtrl;
  final Animation<double> iconRot;
  final AnimationController checkCtrl;

  const _CircleCheckmark({
    required this.circleCtrl,
    required this.circleScale,
    required this.iconRotCtrl,
    required this.iconRot,
    required this.checkCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([circleCtrl, iconRotCtrl, checkCtrl]),
      builder: (_, _) {
        final showCheck = checkCtrl.value > 0;
        return Transform.scale(
          scale: circleScale.value.clamp(0.0, 2.0),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3 * circleScale.value.clamp(0, 1)),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icône ♻️ qui s'estompe quand le checkmark prend le relais
                Opacity(
                  opacity: (1.0 - checkCtrl.value * 2).clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: iconRot.value,
                    child: const Icon(
                      Icons.recycling_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
                // Checkmark dessiné trait par trait
                if (showCheck)
                  Opacity(
                    opacity: (checkCtrl.value * 2 - 1).clamp(0.0, 1.0),
                    child: CustomPaint(
                      size: const Size(56, 56),
                      painter: CheckmarkPainter(
                        progress: checkCtrl.value,
                        color: Colors.white,
                        strokeWidth: 5.0,
                      ),
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

// ── Painter checkmark trait par trait ────────────────────────────────────────
class CheckmarkPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double strokeWidth;

  const CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Chemin du checkmark : deux segments
    final path = Path();
    path.moveTo(size.width * 0.18, size.height * 0.52);
    path.lineTo(size.width * 0.42, size.height * 0.74);
    path.lineTo(size.width * 0.82, size.height * 0.28);

    final metrics = path.computeMetrics().first;
    final total   = metrics.length;
    final drawn   = total * progress.clamp(0.0, 1.0);

    if (drawn <= 0) return;

    final drawnPath = metrics.extractPath(0, drawn);
    canvas.drawPath(drawnPath, glowPaint);
    canvas.drawPath(drawnPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Feuille volante (phase 4) ─────────────────────────────────────────────────
class _LeafParticle extends StatelessWidget {
  final AnimationController ctrl;
  final double angle;    // direction en radians
  final double distance; // distance max depuis le centre
  final double delay;    // 0.0 → 0.5 (fraction du controller)
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
        final dx = math.cos(angle) * distance * curved;
        final dy = math.sin(angle) * distance * curved;
        final opacity = (1.0 - t * 1.2).clamp(0.0, 1.0);
        final rotation = angle + curved * math.pi;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: rotation,
              child: Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }
}
