// Overlay de chargement : 3 feuilles en orbite + texte rotatif + barre verte
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingOverlay extends StatefulWidget {
  final bool visible;
  const LoadingOverlay({super.key, required this.visible});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  // Rotation globale des feuilles en orbite
  late AnimationController _orbitCtrl;
  // Barre de progression indéterminée
  late AnimationController _barCtrl;
  // Texte qui change toutes les 1.5 s
  late AnimationController _textCtrl;
  late Animation<double> _textFade;

  final _messages = const [
    'Connexion en cours...',
    'Vérification de vos données...',
    'Presque prêt...',
  ];
  int _msgIndex = 0;

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeInOut);
    _textCtrl.value = 1.0;

    // Cycle de texte toutes les 1.5 s
    _scheduleNextMessage();
  }

  void _scheduleNextMessage() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _textCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
        _textCtrl.forward().then((_) => _scheduleNextMessage());
      });
    });
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _barCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.visible
          ? _buildOverlay()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildOverlay() {
    return SizedBox.expand(
      child: Container(
        key: const ValueKey('loading'),
        color: Colors.white.withValues(alpha: 0.88),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinner organique : 3 feuilles en orbite
          SizedBox(
            width: 100,
            height: 100,
            child: AnimatedBuilder(
              animation: _orbitCtrl,
              builder: (_, _) => Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final angle = _orbitCtrl.value * 2 * math.pi
                      + (i * 2 * math.pi / 3);
                  final x = 32 * math.cos(angle);
                  final y = 32 * math.sin(angle);
                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Transform.rotate(
                      angle: angle + math.pi / 2,
                      child: Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary
                            .withValues(alpha: 0.5 + 0.5 * ((i + 1) / 3)),
                        size: 22 + i * 4.0,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Texte rotatif avec fade
          FadeTransition(
            opacity: _textFade,
            child: Text(
              _messages[_msgIndex],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Barre de progression verte en bas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: null,
                backgroundColor: AppColors.inputBg,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    ),   // SizedBox.expand
    );
  }
}
