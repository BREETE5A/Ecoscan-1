import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = FirebaseAuth.instance;
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _sendVerification();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerification() async {
    final user = _auth.currentUser;
    if (user == null || _cooldownSeconds > 0) return;
    setState(() => _sending = true);
    try {
      await user.sendEmailVerification();
      _startCooldown();
    } catch (_) {}
    setState(() => _sending = false);
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) t.cancel();
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.reload();
      if (user.emailVerified && mounted) {
        _pollTimer?.cancel();
        context.go('/home');
      }
    });
  }

  Future<void> _skipForNow() async {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_rounded,
                    color: AppColors.primary, size: 48),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .fadeIn(),
              const SizedBox(height: 32),
              Text(
                'Vérifiez votre email',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
              Text(
                'Un lien de vérification a été envoyé à\n$email',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              const Text(
                'Ouvrez votre boîte mail et cliquez sur le lien.\nCette page se redirige automatiquement.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: (_cooldownSeconds > 0 || _sending) ? null : _sendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  label: Text(
                    _cooldownSeconds > 0
                        ? 'Renvoyer dans ${_cooldownSeconds}s'
                        : 'Renvoyer l\'email',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _skipForNow,
                child: const Text(
                  'Vérifier plus tard',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'En attente de vérification…',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1800.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
