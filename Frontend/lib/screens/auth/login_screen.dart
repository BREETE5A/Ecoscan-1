// Page de connexion — vague SVG, logo animé, loading button, shake sur erreur
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  bool _obscure   = true;
  bool _shakeForm = false;

  // Rotation des feuilles autour du bouton pendant le loading
  late AnimationController _leafCtrl;

  // Contrôle l'état précédent pour détecter transitions
  AuthStatus _prevStatus = AuthStatus.idle;

  @override
  void initState() {
    super.initState();
    _leafCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _leafCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _shakeForm = true);
      Future.delayed(const Duration(milliseconds: 600),
          () { if (mounted) setState(() => _shakeForm = false); });
      return;
    }
    await ref.read(loginProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState    = ref.watch(loginProvider);
    final googleState  = ref.watch(googleSignInProvider);
    final s            = AppStrings.of(ref.watch(localeProvider).languageCode);
    final l10n         = AppLocalizations.of(context)!;
    final isLoading    = authState.status == AuthStatus.loading ||
                         googleState.status == AuthStatus.loading;
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final size         = MediaQuery.of(context).size;

    // Réagir au login email
    ref.listen(loginProvider, (_, next) {
      if (next.status == AuthStatus.loading) {
        _leafCtrl.repeat();
      } else {
        _leafCtrl.stop();
        _leafCtrl.reset();
      }
      if (next.status == AuthStatus.success) {
        context.go('/home');
      }
      if (next.status == AuthStatus.error && _prevStatus != AuthStatus.error) {
        setState(() { _shakeForm = true; });
        Future.delayed(const Duration(milliseconds: 600),
            () { if (mounted) setState(() => _shakeForm = false); });
      }
      _prevStatus = next.status;
    });

    // Réagir au login Google
    ref.listen(googleSignInProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        context.go('/home');
      }
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage ?? s.googleSignInError),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
          body: Stack(
            children: [
              // ── Vague verte en bas ──────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(size.width, 180),
                  painter: _WavePainter(isDark: isDark),
                ),
              ),

              // ── Contenu principal ───────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),

                        // Logo animé (Hero tag → home)
                        _AnimatedLogo()
                            .animate()
                            .scale(
                              begin: const Offset(0.4, 0.4),
                              duration: 450.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 250.ms),

                        const SizedBox(height: 14),

                        // Slogan
                        Text(
                          s.taglineLogin,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 320.ms, delay: 100.ms)
                            .slideY(begin: 0.15),

                        const SizedBox(height: 36),

                        // ── Carte formulaire ─────────────────────────────
                        _FormCard(
                          isDark: isDark,
                          shake: _shakeForm,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                l10n.welcomeBack,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.textPrimary,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 200.ms)
                                  .slideY(begin: 0.1),

                              const SizedBox(height: 20),

                              // Email
                              CustomTextField(
                                controller: _emailCtrl,
                                label: l10n.email,
                                hint: s.hintEmail,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                errorText: authState.status == AuthStatus.error
                                    ? authState.errorMessage
                                    : null,
                                shake: _shakeForm,
                                isDark: isDark,
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? s.invalidEmail
                                        : null,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 300.ms)
                                  .slideX(begin: -0.08),

                              const SizedBox(height: 16),

                              // Mot de passe
                              CustomTextField(
                                controller: _passCtrl,
                                label: l10n.password,
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscure,
                                shake: _shakeForm,
                                isDark: isDark,
                                suffixIcon: GestureDetector(
                                  onTap: () =>
                                      setState(() => _obscure = !_obscure),
                                  child: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.length < 6)
                                        ? s.minPassword
                                        : null,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 400.ms)
                                  .slideX(begin: -0.08),

                              // Lien mot de passe oublié
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    final email = _emailCtrl.text.trim();
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(s.forgotPassHint),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(s.resetSent),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(e.message ?? s.sendError),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 300.ms, delay: 450.ms),

                              const SizedBox(height: 6),

                              // Bouton Se connecter (avec feuilles orbitales)
                              _LoadingButton(
                                isLoading: isLoading,
                                leafCtrl: _leafCtrl,
                                onPressed: isLoading ? null : _submit,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 500.ms)
                                  .slideY(begin: 0.15),

                              // Message d'erreur global
                              if (authState.status == AuthStatus.error &&
                                  authState.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.error_outline_rounded,
                                            color: AppColors.danger,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            authState.errorMessage!,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: AppColors.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 300.ms),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 320.ms, delay: 130.ms)
                            .slideY(begin: 0.1),

                        const SizedBox(height: 22),

                        // ── Séparateur animé ─────────────────────────────
                        _AnimatedDivider(text: s.orContinueWith)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 600.ms),

                        const SizedBox(height: 18),

                        // ── Bouton Google Sign-In ────────────────────────
                        _GoogleButton(
                          isLoading: googleState.status == AuthStatus.loading,
                          onTap: isLoading
                              ? null
                              : () => ref
                                  .read(googleSignInProvider.notifier)
                                  .signIn(),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 650.ms)
                            .slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // ── Lien inscription ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccount,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                l10n.register,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                        const SizedBox(height: 24),

                        // ── Liens légaux ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyScreen())),
                              child: Text(
                                l10n.privacyPolicy,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF2D6A4F),
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              ' • ',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const TermsScreen())),
                              child: Text(
                                l10n.termsOfUse,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF2D6A4F),
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 900.ms),

                        const SizedBox(height: 16),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Overlay de chargement par-dessus tout ───────────────────────
        LoadingOverlay(visible: isLoading),
      ],
    );
  }
}

// ── Logo EcoScan animé ────────────────────────────────────────────────────────
class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    // Rotation lente et douce
    _rotation = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Hero(
        tag: 'ecoscan_logo',
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Feuille principale
              const Icon(Icons.eco_rounded, color: Colors.white, size: 44),
              // Anneau rotatif
              RotationTransition(
                turns: _rotation,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Carte formulaire avec shake ───────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final bool isDark;
  final bool shake;
  final Widget child;
  const _FormCard({
    required this.isDark,
    required this.shake,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: shake ? 1 : 0),
      duration: const Duration(milliseconds: 500),
      builder: (_, t, ch) {
        // sin(t·π·5) → 5 demi-oscillations qui s'amortissent
        final offset = shake ? math.sin(t * math.pi * 5) * 10.0 * (1 - t) : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: ch);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ── Bouton Se connecter avec feuilles orbitales ───────────────────────────────
class _LoadingButton extends StatelessWidget {
  final bool isLoading;
  final AnimationController leafCtrl;
  final VoidCallback? onPressed;
  const _LoadingButton({
    required this.isLoading,
    required this.leafCtrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: isLoading
                ? _OrbitingLeaves(ctrl: leafCtrl)
                : Text(
                    AppLocalizations.of(context)!.login,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// 2 feuilles qui tournent autour du centre du bouton
class _OrbitingLeaves extends StatelessWidget {
  final AnimationController ctrl;
  const _OrbitingLeaves({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(2, (i) {
              final angle = ctrl.value * 2 * math.pi + i * math.pi;
              final x = 14.0 * math.cos(angle);
              final y = 14.0 * math.sin(angle);
              return Transform.translate(
                offset: Offset(x, y),
                child: Icon(
                  Icons.eco_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
              );
            }),
          );
        },
      ),
    );
  }

}

// ── Séparateur animé ──────────────────────────────────────────────────────────
class _AnimatedDivider extends StatelessWidget {
  final String text;
  const _AnimatedDivider({required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.textLight.withValues(alpha: 0.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.textLight.withValues(alpha: 0.4),
            ),
          ),
        ],
      );
}

// ── Bouton Google ─────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _GoogleButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: isDark ? 0.3 : 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.primary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.continueWithGoogle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _GoogleLogoPainter()),
      );
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  // Convertit des degrés en radians
  static double _d(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    // Rayon médian de l'anneau et épaisseur du trait
    final r  = s.width * 0.36;
    final sw = s.width * 0.19;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Le "G" s'ouvre à 0° (3 h) — l'arc démarre à 0° et fait 340° au total
    // Bleu  :   0° → 160°
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, _d(0),   _d(160), false, paint);
    // Rouge : 160° → 220°
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, _d(160), _d(60),  false, paint);
    // Jaune : 220° → 275°
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, _d(220), _d(55),  false, paint);
    // Vert  : 275° → 340°
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, _d(275), _d(65),  false, paint);

    // Barre horizontale bleue (le jambage du "G"), de cx vers la droite
    paint
      ..color = const Color(0xFF4285F4)
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r + sw / 2, cy),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Vague verte en bas de l'écran ────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  final bool isDark;
  const _WavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFF1A3320).withValues(alpha: 0.9)
          : const Color(0xFF27AE60).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.3,
          size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.7,
          size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Deuxième couche plus foncée
    final paint2 = Paint()
      ..color = isDark
          ? const Color(0xFF27AE60).withValues(alpha: 0.15)
          : const Color(0xFF27AE60).withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.55,
          size.width * 0.6, size.height * 0.7)
      ..quadraticBezierTo(
          size.width * 0.8, size.height * 0.8,
          size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.isDark != isDark;
}
