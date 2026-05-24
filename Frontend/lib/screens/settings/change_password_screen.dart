import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _loading        = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  double _passwordStrength(String p) {
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 8) s += 0.25;
    if (p.length >= 12) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[0-9!@#\$&*~]').hasMatch(p)) s += 0.25;
    return s;
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return AppColors.danger;
    if (s <= 0.50) return Colors.orange;
    if (s <= 0.75) return Colors.yellow.shade700;
    return AppColors.primary;
  }

  String _strengthLabel(double s, AppStrings str) {
    if (s <= 0.25) return str.strengthWeak;
    if (s <= 0.50) return str.strengthFair;
    if (s <= 0.75) return str.strengthGood;
    return str.strengthStrong;
  }

  Future<void> _submit(AppStrings s) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.passwordUpdated,
              style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.pop();
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? s.wrongPassword
          : s.errorMsg(e.message ?? '');
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
    final strength = _passwordStrength(_newCtrl.text);

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
          s.changePassword,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.changePassHint,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 28),
                CustomTextField(
                  controller: _currentCtrl,
                  label: s.currentPassword,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureCurrent,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? s.fieldRequired : null,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _newCtrl,
                  label: s.newPassword,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_rounded,
                  obscureText: _obscureNew,
                  isDark: isDark,
                  onChanged: (_) => setState(() {}),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return s.minPassword;
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                if (_newCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: strength,
                            backgroundColor: Colors.grey.shade200,
                            color: _strengthColor(strength),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _strengthLabel(strength, s),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: _strengthColor(strength),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmCtrl,
                  label: s.confirmNewPassword,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_reset_rounded,
                  obscureText: _obscureConfirm,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _newCtrl.text) return s.passwordsMismatch;
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _submit(s),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : Text(
                            s.update,
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
          ),
        ),
      ),
    );
  }
}
