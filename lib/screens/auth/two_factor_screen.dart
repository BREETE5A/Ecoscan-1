import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

enum _Step { phone, otp, done }

class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  _Step _step     = _Step.phone;
  bool  _loading  = false;
  String _verificationId = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneCtrl.text.trim(),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          await _linkPhoneCredential(cred);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              e.code == 'invalid-phone-number'
                  ? 'Numéro de téléphone invalide.'
                  : 'Erreur : ${e.message}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.danger,
          ));
        },
        codeSent: (String vId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = vId;
            _step = _Step.otp;
            _loading = false;
          });
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Entrez le code à 6 chiffres.',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpCtrl.text.trim(),
      );
      await _linkPhoneCredential(cred);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.code == 'invalid-verification-code'
              ? 'Code incorrect. Réessayez.'
              : 'Erreur : ${e.message}',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential cred) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.linkWithCredential(cred);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'phoneNumber': _phoneCtrl.text.trim(),
        'twoFactorEnabled': true,
      });
      if (!mounted) return;
      setState(() {
        _step = _Step.done;
        _loading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e.code == 'credential-already-in-use'
          ? 'Ce numéro est lié à un autre compte.'
          : e.code == 'provider-already-linked'
              ? 'Un numéro est déjà lié à ce compte.'
              : 'Erreur : ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
          onPressed: _step == _Step.otp
              ? () => setState(() => _step = _Step.phone)
              : () => context.pop(),
        ),
        title: Text(
          'Double authentification',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: switch (_step) {
            _Step.phone => _PhoneStep(
                formKey: _formKey,
                ctrl: _phoneCtrl,
                isDark: isDark,
                loading: _loading,
                onSend: _sendOtp,
              ),
            _Step.otp => _OtpStep(
                ctrl: _otpCtrl,
                phone: _phoneCtrl.text.trim(),
                isDark: isDark,
                loading: _loading,
                onVerify: _verifyOtp,
                onResend: () {
                  setState(() => _step = _Step.phone);
                  _sendOtp();
                },
              ),
            _Step.done => _DoneStep(onBack: () => context.pop()),
          },
        ),
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrl;
  final bool isDark;
  final bool loading;
  final VoidCallback onSend;

  const _PhoneStep({
    required this.formKey,
    required this.ctrl,
    required this.isDark,
    required this.loading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_android_rounded,
                color: AppColors.teal, size: 38),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            'Liez votre numéro de téléphone',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 8),
          const Text(
            'Un SMS de vérification sera envoyé à ce numéro.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          CustomTextField(
            controller: ctrl,
            label: 'Numéro de téléphone',
            hint: '+212 6XX XXX XXX',
            prefixIcon: Icons.phone_rounded,
            isDark: isDark,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Requis';
              if (!v.trim().startsWith('+')) return 'Inclure l\'indicatif (+212...)';
              return null;
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
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
                      'Envoyer le code SMS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final TextEditingController ctrl;
  final String phone;
  final bool isDark;
  final bool loading;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpStep({
    required this.ctrl,
    required this.phone,
    required this.isDark,
    required this.loading,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.sms_rounded, color: AppColors.primary, size: 38),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text(
          'Entrez le code SMS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 8),
        Text(
          'Code envoyé au $phone',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        CustomTextField(
          controller: ctrl,
          label: 'Code de vérification',
          hint: '123456',
          prefixIcon: Icons.pin_rounded,
          isDark: isDark,
          keyboardType: TextInputType.number,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : onVerify,
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
                    'Vérifier',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        TextButton(
          onPressed: loading ? null : onResend,
          child: const Text(
            'Renvoyer le code',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  final VoidCallback onBack;
  const _DoneStep({required this.onBack});

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
          child: const Icon(Icons.verified_user_rounded,
              color: AppColors.primary, size: 44),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text(
          'Double authentification activée !',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        const Text(
          'Votre compte est maintenant protégé par une vérification en deux étapes.',
          style: TextStyle(
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
            onPressed: onBack,
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
