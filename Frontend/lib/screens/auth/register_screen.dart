// Page d'inscription — stepper 3 étapes, avatar initiales, force mdp, confetti
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';

// ── Villes marocaines pour l'autocomplétion ───────────────────────────────────
const _moroccanCities = [
  'Agadir', 'Al Hoceima', 'Beni Mellal', 'Berkane', 'Casablanca',
  'Dakhla', 'El Jadida', 'Errachidia', 'Essaouira', 'Fès',
  'Guelmim', 'Ifrane', 'Kénitra', 'Khouribga', 'Laâyoune',
  'Larache', 'Marrakech', 'Meknès', 'Mohammedia', 'Nador',
  'Ouarzazate', 'Oujda', 'Rabat', 'Safi', 'Salé',
  'Settat', 'Tanger', 'Taroudant', 'Tétouan', 'Zagora',
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  // Contrôleurs de texte — étape 1
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  // Étape 2
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  // Étape 3
  final _cityCtrl = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms  = false;

  // Autocomplétion ville
  List<String> _citySuggestions = [];
  bool _showCityDropdown = false;

  // Clés de formulaire par étape
  final _form1 = GlobalKey<FormState>();
  final _form2 = GlobalKey<FormState>();
  final _form3 = GlobalKey<FormState>();

  // PageController pour les transitions slide
  late PageController _pageCtrl;

  // Confetti au succès
  late ConfettiController _confettiCtrl;

  // Animation entrée des étapes
  late AnimationController _stepEnterCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _confettiCtrl = ConfettiController(
        duration: const Duration(milliseconds: 2500));
    _stepEnterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _firstCtrl.addListener(_onNameChanged);
    _lastCtrl.addListener(_onNameChanged);
    _cityCtrl.addListener(_onCityChanged);
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _cityCtrl.dispose();
    _pageCtrl.dispose();
    _confettiCtrl.dispose();
    _stepEnterCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  void _onCityChanged() {
    final q = _cityCtrl.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _citySuggestions = [];
        _showCityDropdown = false;
      } else {
        _citySuggestions = _moroccanCities
            .where((c) => c.toLowerCase().startsWith(q))
            .take(5)
            .toList();
        _showCityDropdown = _citySuggestions.isNotEmpty;
      }
    });
  }

  // Passer à l'étape suivante avec validation
  void _next(int currentStep) {
    final form = [_form1, _form2, _form3][currentStep];
    if (form.currentState?.validate() != true) {
      _triggerShake();
      return;
    }
    if (currentStep < 2) {
      _stepEnterCtrl.reset();
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
      ref.read(registerProvider.notifier).nextStep();
      _stepEnterCtrl.forward();
    } else {
      _submit();
    }
  }

  void _prev() {
    _stepEnterCtrl.reset();
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
    ref.read(registerProvider.notifier).prevStep();
    _stepEnterCtrl.forward();
  }

  void _triggerShake() {
    // Vibration visuelle — setState force un rebuild des champs avec errorText
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_agreedToTerms) {
      _triggerShake();
      final s = AppStrings.of(ref.read(localeProvider).languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.mustAcceptTerms)),
      );
      return;
    }
    await ref.read(registerProvider.notifier).register(
      firstName: _firstCtrl.text.trim(),
      lastName:  _lastCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
      password:  _passCtrl.text,
      city:      _cityCtrl.text.trim(),
    );
  }

  // Force du mot de passe : 0‒4
  int _passStrength(String p) {
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  String get _initials {
    final f = _firstCtrl.text.trim();
    final l = _lastCtrl.text.trim();
    if (f.isEmpty && l.isEmpty) return '?';
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final regState  = ref.watch(registerProvider);
    final l10n      = AppLocalizations.of(context)!;
    final s         = AppStrings.of(ref.watch(localeProvider).languageCode);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final step      = regState.step;
    final isLoading = regState.status == AuthStatus.loading;

    // Écouter les transitions d'état
    ref.listen(registerProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        _confettiCtrl.play();
        final router = GoRouter.of(context);
        Future.delayed(const Duration(milliseconds: 2600), () {
          if (mounted) router.go('/verify-email');
        });
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
          body: Stack(
            children: [
              // Vague en bas (réutilisée du login)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 160),
                  painter: _WavePainter(isDark: isDark),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // ── Header avec back + stepper ──────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          if (step > 0)
                            GestureDetector(
                              onTap: _prev,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.darkCard
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.07),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 16,
                                    color: AppColors.primary),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/login'); } },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.darkCard
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.07),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          const Spacer(),
                          _StepIndicator(currentStep: step),
                          const Spacer(),
                          SizedBox(
                            width: 38,
                            child: Text(
                              '${step + 1}/3',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Pages des étapes ─────────────────────────────────
                    Expanded(
                      child: PageView(
                        controller: _pageCtrl,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1(isDark, step, s),
                          _buildStep2(isDark, step, s),
                          _buildStep3(isDark, step, s),
                        ],
                      ),
                    ),

                    // ── Lien connexion ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyAccount,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/login'); } },
                            child: Text(
                              l10n.login,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Confetti au succès ───────────────────────────────────────────
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary, AppColors.teal,
              Color(0xFF81C784), Colors.white,
            ],
            numberOfParticles: 40,
            maxBlastForce: 30,
            minBlastForce: 10,
          ),
        ),

        // ── Overlay de chargement ────────────────────────────────────────
        LoadingOverlay(visible: isLoading),

        // ── Message de bienvenue après succès ────────────────────────────
        if (regState.status == AuthStatus.success)
          _WelcomeBanner(
            title: s.welcomeMsg(_firstCtrl.text.trim()),
            subtitle: s.accountCreated,
          ),
      ],
    );
  }

  // ── Étape 1 : Identité ─────────────────────────────────────────────────────
  Widget _buildStep1(bool isDark, int step, AppStrings s) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _stepEnterCtrl, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: _stepEnterCtrl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Form(
            key: _form1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar avec initiales mis à jour en temps réel
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate(key: ValueKey(_initials))
                      .scale(begin: const Offset(0.85, 0.85), duration: 250.ms, curve: Curves.easeOut),
                ),
                const SizedBox(height: 20),

                _sectionTitle(s.yourIdentity, isDark),
                const SizedBox(height: 16),

                // Prénom + Nom côte à côte
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstCtrl,
                        label: AppLocalizations.of(context)!.firstName,
                        hint: s.hintFirstName,
                        prefixIcon: Icons.person_outline_rounded,
                        isDark: isDark,
                        validator: (v) =>
                            (v == null || v.trim().length < 2) ? s.fieldRequired : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastCtrl,
                        label: AppLocalizations.of(context)!.lastName,
                        hint: s.hintLastName,
                        prefixIcon: Icons.badge_outlined,
                        isDark: isDark,
                        validator: (v) =>
                            (v == null || v.trim().length < 2) ? s.fieldRequired : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                _NextButton(
                  label: s.continue_,
                  onPressed: () => _next(0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Étape 2 : Accès ────────────────────────────────────────────────────────
  Widget _buildStep2(bool isDark, int step, AppStrings s) {
    final strength = _passStrength(_passCtrl.text);
    final passMatch = _passCtrl.text.isNotEmpty &&
        _passCtrl.text == _confirmCtrl.text;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _stepEnterCtrl, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: _stepEnterCtrl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Form(
            key: _form2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(s.yourAccess, isDark),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailCtrl,
                  label: AppLocalizations.of(context)!.email,
                  hint: s.hintEmail,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? s.invalidEmail : null,
                ),
                const SizedBox(height: 16),

                // Mot de passe
                CustomTextField(
                  controller: _passCtrl,
                  label: AppLocalizations.of(context)!.password,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePass,
                  isDark: isDark,
                  onChanged: (_) => setState(() {}),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePass = !_obscurePass),
                    child: Icon(
                      _obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? s.minPassword : null,
                ),
                const SizedBox(height: 10),

                // Indicateur de force
                _PasswordStrength(strength: strength),
                const SizedBox(height: 16),

                // Confirmation mot de passe
                CustomTextField(
                  controller: _confirmCtrl,
                  label: AppLocalizations.of(context)!.confirmPassword,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  isDark: isDark,
                  onChanged: (_) => setState(() {}),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkmark animé quand les mots de passe correspondent
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: passMatch
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                                key: ValueKey('check'))
                            : const SizedBox.shrink(key: ValueKey('none')),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  validator: (v) => v != _passCtrl.text
                      ? s.passwordsMismatch
                      : null,
                ),
                const SizedBox(height: 28),

                _NextButton(
                  label: s.continue_,
                  onPressed: () => _next(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Étape 3 : Localisation + CGU ──────────────────────────────────────────
  Widget _buildStep3(bool isDark, int step, AppStrings s) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _stepEnterCtrl, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: _stepEnterCtrl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Form(
            key: _form3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(s.yourLocation, isDark),
                const SizedBox(height: 16),

                // Champ ville avec dropdown expand animé
                CustomTextField(
                  controller: _cityCtrl,
                  label: AppLocalizations.of(context)!.city,
                  hint: s.hintCity,
                  prefixIcon: Icons.location_city_rounded,
                  isDark: isDark,
                  onChanged: (_) {},
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? s.cityRequired : null,
                ),

                // Dropdown de suggestions avec animation expand
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: _showCityDropdown
                      ? Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            children: _citySuggestions.map((city) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  _cityCtrl.text = city;
                                  setState(() {
                                    _showCityDropdown = false;
                                    _citySuggestions = [];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.place_outlined,
                                          size: 16,
                                          color: AppColors.primary),
                                      const SizedBox(width: 10),
                                      Text(
                                        city,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: isDark
                                              ? AppColors.darkText
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // CGU avec ripple
                _TermsCheckbox(
                  agreed: _agreedToTerms,
                  isDark: isDark,
                  acceptText: s.acceptTerms,
                  termsText: s.termsOfUse,
                  andText: s.andThe,
                  privacyText: s.privacyPolicyLink,
                  onChanged: (v) => setState(() => _agreedToTerms = v),
                ),
                const SizedBox(height: 28),

                // Bouton créer compte
                _NextButton(
                  label: s.createAccount2,
                  onPressed: () => _next(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) => Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        ),
      );
}

// ── Stepper visuel (cercles animés) ──────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final done   = i < currentStep;
          final active = i == currentStep;
          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                width: active ? 32 : 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.primary
                      : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active || done
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              if (i < 2)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 24,
                  height: 2,
                  color: i < currentStep
                      ? AppColors.primary
                      : AppColors.inputBg,
                ),
            ],
          );
        }),
      );
}

// ── Indicateur force du mot de passe ─────────────────────────────────────────
class _PasswordStrength extends StatelessWidget {
  final int strength; // 0‒4

  const _PasswordStrength({required this.strength});

  Color get _color => switch (strength) {
        0 => AppColors.textLight,
        1 => AppColors.danger,
        2 => AppColors.warning,
        3 => AppColors.accent,
        _ => AppColors.primary,
      };

  String get _label => switch (strength) {
        0 => '',
        1 => 'Très faible',
        2 => 'Faible',
        3 => 'Moyen',
        _ => 'Fort',
      };

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final filled = i < strength;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 5,
                    decoration: BoxDecoration(
                      color: filled ? _color : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (strength > 0) ...[
            const SizedBox(height: 4),
            Text(
              _label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: _color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
}

// ── Case à cocher CGU avec ripple ────────────────────────────────────────────
class _TermsCheckbox extends StatelessWidget {
  final bool agreed;
  final bool isDark;
  final String acceptText;
  final String termsText;
  final String andText;
  final String privacyText;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({
    required this.agreed,
    required this.isDark,
    required this.acceptText,
    required this.termsText,
    required this.andText,
    required this.privacyText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onChanged(!agreed),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: agreed ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: agreed
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    width: 1.5,
                  ),
                ),
                child: agreed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                children: [
                  Text(
                    acceptText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsScreen()),
                    ),
                    child: Text(
                      termsText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    andText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    ),
                    child: Text(
                      privacyText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ── Bouton Suivant/Créer ──────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _NextButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 52),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}

// ── Message de bienvenue post-inscription ─────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _WelcomeBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Container(
          color: Colors.white.withValues(alpha: 0.9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_rounded,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
          ),
        ),
      );
}

// ── Vague décorative (partagée avec login) ────────────────────────────────────
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
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.3,
          size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.7,
          size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = isDark
          ? const Color(0xFF27AE60).withValues(alpha: 0.15)
          : const Color(0xFF27AE60).withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.55,
          size.width * 0.6, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.8,
          size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.isDark != isDark;
}
