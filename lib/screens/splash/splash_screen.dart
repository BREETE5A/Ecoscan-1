// Premier écran au lancement — 4 phases, fond vert uni, logo seul, skip sur tap.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1 — apparition
  late AnimationController _appearCtrl;
  late Animation<double> _appearScale;
  late Animation<double> _appearFade;

  // Phase 2 — bounce + légère rotation
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceScale;
  late Animation<double> _bounceRot;

  // Phase 3 — respiration (pulse)
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;

  // Phase 4 — sortie
  late AnimationController _exitCtrl;
  late Animation<double> _exitScale;
  late Animation<double> _exitFade;
  late Animation<Color?> _exitBg;

  bool _skipped = false;

  @override
  void initState() {
    super.initState();

    // Cacher la status bar et la nav bar pendant le splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Phase 1 : 0 → 1.2 en 600 ms
    _appearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearScale = Tween(begin: 0.0, end: 1.2)
        .animate(CurvedAnimation(parent: _appearCtrl, curve: Curves.elasticOut));
    _appearFade = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: _appearCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    // Phase 2 : 1.2 → 1.0, rotation -5° → 0° en 600 ms
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceScale = Tween(begin: 1.2, end: 1.0)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
    _bounceRot = Tween(begin: -0.0873, end: 0.0) // -5° en radians
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));

    // Phase 3 : pulse 1.0 → 1.05 → 1.0 (une fois) en 600 ms
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Phase 4 : 1.0 → 1.3, fond vert → blanc cassé en 700 ms
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _exitScale = Tween(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitFade = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitBg = ColorTween(
      begin: const Color(0xFF2E7D32),
      end: const Color(0xFFF9FBF7),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Phase 1
    await _appearCtrl.forward();
    if (!mounted || _skipped) return;

    // Phase 2
    await _bounceCtrl.forward();
    if (!mounted || _skipped) return;

    // Phase 3
    await _pulseCtrl.forward();
    if (!mounted || _skipped) return;

    // Phase 4
    await _exitCtrl.forward();
    if (mounted) _navigateNext();
  }

  void _navigateNext() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      context.go('/welcome');
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    if (_skipped) return;
    _skipped = true;
    _appearCtrl.stop();
    _bounceCtrl.stop();
    _pulseCtrl.stop();
    _exitCtrl.forward(from: 0).then((_) {
      if (mounted) _navigateNext();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _appearCtrl.dispose();
    _bounceCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // Valeur de scale combinant toutes les phases actives
  double get _currentScale {
    if (_exitCtrl.isAnimating || _exitCtrl.isCompleted) return _exitScale.value;
    if (_pulseCtrl.isAnimating || _pulseCtrl.isCompleted) return _pulseScale.value;
    if (_bounceCtrl.isAnimating || _bounceCtrl.isCompleted) return _bounceScale.value;
    return _appearScale.value;
  }

  double get _currentRotation {
    if (_bounceCtrl.isAnimating || _bounceCtrl.isCompleted) return _bounceRot.value;
    return 0.0;
  }

  double get _currentFade {
    if (_exitCtrl.isAnimating || _exitCtrl.isCompleted) return _exitFade.value;
    return _appearFade.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skip,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_appearCtrl, _bounceCtrl, _pulseCtrl, _exitCtrl]),
        builder: (_, _) {
          final bg = _exitCtrl.isAnimating || _exitCtrl.isCompleted
              ? (_exitBg.value ?? const Color(0xFF2E7D32))
              : const Color(0xFF2E7D32);

          return Scaffold(
            backgroundColor: bg,
            body: Center(
              child: Opacity(
                opacity: _currentFade.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: _currentRotation,
                  child: Transform.scale(
                    scale: _currentScale.clamp(0.0, 2.0),
                    child: _LogoWidget(
                      glowOpacity: _appearFade.value.clamp(0.0, 1.0),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Logo statique — réutilise le style existant du projet ─────────────────────
class _LogoWidget extends StatelessWidget {
  final double glowOpacity;
  const _LogoWidget({required this.glowOpacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF81C784).withValues(alpha: glowOpacity * 0.6),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.eco_rounded,
        color: Colors.white,
        size: 56,
      ),
    );
  }
}
