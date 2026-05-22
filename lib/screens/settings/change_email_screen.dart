import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
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

  Future<void> _submit() async {
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
        'wrong-password' || 'invalid-credential' => 'Mot de passe incorrect.',
        'email-already-in-use' => 'Cet email est déjà utilisé.',
        'invalid-email' => 'Adresse email invalide.',
        _ => 'Erreur : ${e.message}',
      };
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          'Changer l\'email',
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
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            isDark: isDark,
            currentEmail: currentEmail,
            passCtrl: _passCtrl,
            emailCtrl: _emailCtrl,
            formKey: _formKey,
            obscurePass: _obscurePass,
            loading: _loading,
            onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppColors.primary, size: 44),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text(
          'Email de vérification envoyé',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          'Vérifiez $email pour confirmer le changement.\nVotre email ne changera qu\'après confirmation.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Retour aux paramètres',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
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
                    'Email actuel : $currentEmail',
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
            label: 'Mot de passe actuel',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: obscurePass,
            isDark: isDark,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
          const SizedBox(height: 16),
          CustomTextField(
            controller: emailCtrl,
            label: 'Nouvel email',
            hint: 'exemple@email.com',
            prefixIcon: Icons.email_rounded,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Requis';
              if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
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
                  : const Text(
                      'Envoyer le lien de vérification',
                      style: TextStyle(
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
