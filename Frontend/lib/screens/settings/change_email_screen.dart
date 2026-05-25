import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _passCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  bool _obscurePass = true;
  bool _loading     = false;
  bool _sent        = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppStrings s) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _passCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'wrong-password' || 'invalid-credential' => s.wrongPassword,
        'email-already-in-use' => s.emailAlreadyUsed,
        'invalid-email' => s.invalidEmail,
        _ => s.errorMsg(e.message ?? ''),
      };
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          s.changeEmail,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _sent
              ? _SuccessView(
                  email: _emailCtrl.text.trim(),
                  currentEmail: currentEmail,
                  password: _passCtrl.text,
                  s: s,
                )
              : _FormView(
                  isDark: isDark,
                  currentEmail: currentEmail,
                  passCtrl: _passCtrl,
                  emailCtrl: _emailCtrl,
                  formKey: _formKey,
                  obscurePass: _obscurePass,
                  loading: _loading,
                  s: s,
                  onToggleObscure: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  onSubmit: () => _submit(s),
                ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatefulWidget {
  final String email;
  final String currentEmail;
  final String password;
  final AppStrings s;
  const _SuccessView({
    required this.email,
    required this.currentEmail,
    required this.password,
    required this.s,
  });

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> with WidgetsBindingObserver {
  bool _verified = false;
  bool _resending = false;
  Timer? _pollTimer;
  Timer? _resendCooldown;
  int _resendSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Poll every 4 s as a fallback
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_verified) _autoCheck();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _resendCooldown?.cancel();
    super.dispose();
  }

  // Trigger check immediately when user returns from email app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_verified) {
      _autoCheck();
    }
  }

  bool _emailsMatch(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  Future<void> _handleEmailVerified() async {
    _pollTimer?.cancel();
    if (!mounted) return;
    setState(() => _verified = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/login');
  }

  Future<void> _autoCheck() async {
    if (_verified) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      // Already signed out = Firebase revoked the session after email change
      if (user == null) { await _handleEmailVerified(); return; }

      await user.reload();

      // After reload, check if currentUser was nulled (signed out by Firebase)
      final fresh = FirebaseAuth.instance.currentUser;
      if (fresh == null) { await _handleEmailVerified(); return; }

      if (_emailsMatch(fresh.email ?? '', widget.email)) {
        await _handleEmailVerified();
        return;
      }

      // Force token refresh — if the session was revoked, this throws
      try {
        await fresh.getIdToken(true);
        // Re-read email after token refresh (SDK may now have the new value)
        final afterRefresh = FirebaseAuth.instance.currentUser?.email ?? '';
        if (_emailsMatch(afterRefresh, widget.email) && mounted) {
          await _handleEmailVerified();
        }
      } on FirebaseAuthException {
        // Any auth exception after email change means session was revoked = verified
        await _handleEmailVerified();
      }
    } catch (_) {}
  }

  Future<void> _resendEmail() async {
    setState(() => _resending = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Re-authenticate first so the session is fresh
      final cred = EmailAuthProvider.credential(
        email: widget.currentEmail,
        password: widget.password,
      );
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(widget.email);
      if (mounted) {
        _startResendCooldown(60);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.s.resendEmail,
              style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? widget.s.wrongPassword
          : widget.s.errorMsg(e.message ?? '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _startResendCooldown(int seconds) {
    setState(() => _resendSecondsLeft = seconds);
    _resendCooldown?.cancel();
    _resendCooldown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _resendSecondsLeft--);
      if (_resendSecondsLeft <= 0) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_verified) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded,
                  color: AppColors.primary, size: 54),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text('✅', style: TextStyle(fontSize: 44))
                .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text(
              'Email vérifié !',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 10),
            const Text(
              'Redirection vers la connexion...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 50),
        // Spinner around the email icon
        SizedBox(
          width: 100, height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 100, height: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    color: AppColors.primary, size: 38),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 28),
        Text(
          widget.s.waitingVerif,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 10),
        Text(
          widget.s.emailVerifConfirm(widget.email),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 220.ms),
        const SizedBox(height: 16),
        // Spam hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Si vous ne trouvez pas l\'email, vérifiez votre dossier Spams / Indésirables.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.amber),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
        // Resend button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: (_resending || _resendSecondsLeft > 0) ? null : _resendEmail,
            icon: _resending
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              _resendSecondsLeft > 0
                  ? '${widget.s.resendIn} ${_resendSecondsLeft}s'
                  : widget.s.resendEmail,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            widget.s.backToSettings,
            style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textSecondary,
                fontSize: 13),
          ),
        ).animate().fadeIn(delay: 420.ms),
      ],
    );
  }
}

class _FormView extends StatelessWidget {
  final bool isDark;
  final String currentEmail;
  final TextEditingController passCtrl;
  final TextEditingController emailCtrl;
  final GlobalKey<FormState> formKey;
  final bool obscurePass;
  final bool loading;
  final AppStrings s;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _FormView({
    required this.isDark,
    required this.currentEmail,
    required this.passCtrl,
    required this.emailCtrl,
    required this.formKey,
    required this.obscurePass,
    required this.loading,
    required this.s,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${s.currentEmail} : $currentEmail',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 28),
          CustomTextField(
            controller: passCtrl,
            label: s.currentPassword,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: obscurePass,
            isDark: isDark,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? s.fieldRequired : null,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
          const SizedBox(height: 16),
          CustomTextField(
            controller: emailCtrl,
            label: s.newEmail,
            hint: 'exemple@email.com',
            prefixIcon: Icons.email_rounded,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return s.fieldRequired;
              if (!v.contains('@') || !v.contains('.')) return s.invalidEmail;
              return null;
            },
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(
                      s.sendVerifLink,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
