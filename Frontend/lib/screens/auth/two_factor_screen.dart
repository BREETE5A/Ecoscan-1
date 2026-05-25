import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class _CountryEntry {
  final String flag;
  final String name;
  final String code;
  const _CountryEntry(this.flag, this.name, this.code);
  String get display => '$flag $code';
}

enum _Step { active, phone, otp, done }

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  _Step _step       = _Step.phone;
  bool  _loading    = false;
  String _verificationId = '';
  int _countryIndex = 0;
  String _savedPhone = '';

  static const _countries = [
    _CountryEntry('🇲🇦', 'Maroc',            '+212'),
    _CountryEntry('🇫🇷', 'France',           '+33'),
    _CountryEntry('🇩🇿', 'Algérie',          '+213'),
    _CountryEntry('🇹🇳', 'Tunisie',          '+216'),
    _CountryEntry('🇸🇦', 'Arabie Saoudite',  '+966'),
    _CountryEntry('🇦🇪', 'Émirats',          '+971'),
    _CountryEntry('🇬🇧', 'Royaume-Uni',      '+44'),
    _CountryEntry('🇺🇸', 'États-Unis',       '+1'),
    _CountryEntry('🇪🇸', 'Espagne',          '+34'),
    _CountryEntry('🇧🇪', 'Belgique',         '+32'),
    _CountryEntry('🇨🇦', 'Canada',           '+1'),
    _CountryEntry('🇸🇳', 'Sénégal',          '+221'),
  ];

  String get _prefix => _countries[_countryIndex].code;

  @override
  void initState() {
    super.initState();
    _loadSavedPhone();
  }

  Future<void> _loadSavedPhone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      final saved = (data['phoneNumber'] as String?)?.trim() ?? '';
      final enabled = (data['twoFactorEnabled'] as bool?) ?? false;

      if (saved.isNotEmpty && enabled && mounted) {
        // 2FA déjà activé — afficher l'écran "actif"
        setState(() {
          _savedPhone = saved;
          _step = _Step.active;
        });
        return;
      }
      // Pré-remplir le formulaire si numéro existant mais 2FA désactivé
      if (saved.isNotEmpty && mounted) {
        for (int i = 0; i < _countries.length; i++) {
          if (saved.startsWith(_countries[i].code)) {
            setState(() {
              _countryIndex = i;
              _phoneCtrl.text = saved.substring(_countries[i].code.length);
            });
            break;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _disable2FA() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'twoFactorEnabled': false,
        });
      }
      if (mounted) setState(() { _step = _Step.phone; _savedPhone = ''; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  String _formatPhone(String prefix, String number) {
    number = number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (number.startsWith('0')) number = number.substring(1);
    return '$prefix$number';
  }

  Future<void> _handleDone() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'phoneVerified': true, 'twoFactorEnabled': true});
    } catch (_) {}
    if (mounted) context.pop();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final formatted = _formatPhone(_prefix, _phoneCtrl.text.trim());
    debugPrint('Sending SMS to: $formatted');
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formatted,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          await _linkPhoneCredential(cred);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          final s = AppStrings.of(ref.read(localeProvider).languageCode);
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              e.code == 'invalid-phone-number'
                  ? s.invalidPhone
                  : s.errorMsg(e.message ?? ''),
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
      if (!mounted) return;
      final s = AppStrings.of(ref.read(localeProvider).languageCode);
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.errorMsg(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length < 6) {
      final s = AppStrings.of(ref.read(localeProvider).languageCode);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.enterSixDigits,
            style: const TextStyle(fontFamily: 'Poppins')),
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
      final s = AppStrings.of(ref.read(localeProvider).languageCode);
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.code == 'invalid-verification-code'
              ? s.wrongOtp
              : s.errorMsg(e.message ?? ''),
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
        'phoneNumber': _formatPhone(_prefix, _phoneCtrl.text.trim()),
        'twoFactorEnabled': true,
      });
      if (!mounted) return;
      setState(() {
        _step = _Step.done;
        _loading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final s = AppStrings.of(ref.read(localeProvider).languageCode);
      setState(() => _loading = false);
      final msg = e.code == 'credential-already-in-use'
          ? s.phoneLinkedOther
          : e.code == 'provider-already-linked'
              ? s.phoneAlreadyLinked
              : s.errorMsg(e.message ?? '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);

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
          s.twoFactorTitle,
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
            _Step.active => _ActiveStep(
                phone: _savedPhone,
                isDark: isDark,
                loading: _loading,
                onDisable: _disable2FA,
                onChange: () => setState(() => _step = _Step.phone),
                s: s,
              ),
            _Step.phone => _PhoneStep(
                formKey: _formKey,
                ctrl: _phoneCtrl,
                isDark: isDark,
                loading: _loading,
                onSend: _sendOtp,
                countryIndex: _countryIndex,
                countries: _countries,
                onCountryChanged: (i) => setState(() => _countryIndex = i),
                s: s,
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
                s: s,
              ),
            _Step.done => _DoneStep(onBack: () { _handleDone(); }, s: s),
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
  final int countryIndex;
  final List<_CountryEntry> countries;
  final ValueChanged<int> onCountryChanged;
  final AppStrings s;

  const _PhoneStep({
    required this.formKey,
    required this.ctrl,
    required this.isDark,
    required this.loading,
    required this.onSend,
    required this.countryIndex,
    required this.countries,
    required this.onCountryChanged,
    required this.s,
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
          Text(
            s.twoFactorSub,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 8),
          Text(
            s.twoFactorDesc,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: countryIndex,
                      items: List.generate(
                        countries.length,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(
                            countries[i].display,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (v) =>
                          v != null ? onCountryChanged(v) : null,
                      underline: const SizedBox.shrink(),
                      icon: Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: isDark
                            ? Colors.white54
                            : AppColors.textSecondary,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      dropdownColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.white,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '6XX XXX XXX',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: isDark
                                ? Colors.white38
                                : AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return s.fieldRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: ctrl,
                builder: (_, value, _) {
                  String n = value.text
                      .replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  if (n.startsWith('0')) n = n.substring(1);
                  if (n.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      s.finalNumber('${countries[countryIndex].code}$n'),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ],
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
                  : Text(
                      s.sendSmsCode,
                      style: const TextStyle(
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
  final AppStrings s;

  const _OtpStep({
    required this.ctrl,
    required this.phone,
    required this.isDark,
    required this.loading,
    required this.onVerify,
    required this.onResend,
    required this.s,
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
        Text(
          s.enterSmsCode,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 8),
        Text(
          s.codeSentTo(phone),
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
          label: s.verifyCodeTitle,
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
                : Text(
                    s.verifyCode,
                    style: const TextStyle(
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
          child: Text(
            s.resendCode,
            style: const TextStyle(
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
  final AppStrings s;
  const _DoneStep({required this.onBack, required this.s});

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
        Text(
          s.twoFactorDone,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          s.twoFactorDoneDesc,
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
            child: Text(
              s.continueHome,
              style: const TextStyle(
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

class _ActiveStep extends StatelessWidget {
  final String phone;
  final bool isDark;
  final bool loading;
  final VoidCallback onDisable;
  final VoidCallback onChange;
  final AppStrings s;

  const _ActiveStep({
    required this.phone,
    required this.isDark,
    required this.loading,
    required this.onDisable,
    required this.onChange,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_rounded,
              color: AppColors.primary, size: 38),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          s.twoFactorDone,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_android_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  phone,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onChange,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text(
              'Changer le numéro',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onDisable,
            icon: loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.shield_outlined, size: 18),
            label: const Text(
              'Désactiver la 2FA',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}
