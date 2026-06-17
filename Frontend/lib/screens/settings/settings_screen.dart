import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_strings.dart';
import 'theme_screen.dart';
import 'language_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _langCodes = ['fr', 'en', 'ar', 'es'];
  static const _langLabels = ['Français', 'English', 'العربية', 'Español'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final currentLang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(currentLang);
    final langIdx = _langCodes.indexOf(currentLang);
    final currentLangLabel = langIdx >= 0 ? _langLabels[langIdx] : 'Français';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.settingsTitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  Text(
                    s.customize,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Account section
                    _Section(
                      title: s.account,
                      isDark: isDark,
                      delay: 100,
                      children: [
                        _ActionRow(
                          icon: Icons.edit_rounded,
                          label: s.menuEditProfile,
                          color: AppColors.primary,
                          isDark: isDark,
                          onTap: () => context.push('/profile/edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Appearance section
                    _Section(
                      title: s.appearance,
                      isDark: isDark,
                      delay: 150,
                      children: [
                        _ActionRow(
                          icon: themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : themeMode == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.brightness_auto_rounded,
                          label: s.darkMode,
                          color: isDark ? AppColors.purple : AppColors.accent,
                          isDark: isDark,
                          trailing: Text(
                            ref.read(themeProvider.notifier).modeLabel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ThemeScreen())),
                        ),
                        _ActionRow(
                          icon: Icons.language_rounded,
                          label: s.language,
                          color: AppColors.info,
                          isDark: isDark,
                          trailing: Text(
                            currentLangLabel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LanguageScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Security section
                    _Section(
                      title: s.security,
                      isDark: isDark,
                      delay: 350,
                      children: [
                        _ActionRow(
                          icon: Icons.lock_reset_rounded,
                          label: s.changePassword,
                          color: AppColors.primary,
                          isDark: isDark,
                          onTap: () => context.push('/change-password'),
                        ),
                        _ActionRow(
                          icon: Icons.email_rounded,
                          label: s.changeEmail,
                          color: AppColors.info,
                          isDark: isDark,
                          onTap: () => context.push('/change-email'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tools section
                    _Section(
                      title: s.tools,
                      isDark: isDark,
                      delay: 420,
                      children: [
                        _ActionRow(
                          icon: Icons.share_rounded,
                          label: s.shareApp,
                          color: AppColors.info,
                          isDark: isDark,
                          onTap: _shareApp,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Privacy section
                    _Section(
                      title: s.privacy,
                      isDark: isDark,
                      delay: 450,
                      children: [
                        _ActionRow(
                          icon: Icons.delete_forever_rounded,
                          label: s.deleteAccount,
                          color: AppColors.danger,
                          isDark: isDark,
                          isDestructive: true,
                          onTap: () => _confirmDelete(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await signOutUser(ref);
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.danger, size: 18),
                      label: Text(
                        s.logout,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.danger.withValues(alpha: 0.4)),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ).animate(delay: 650.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share('Découvrez EcoScan — l\'app de tri des déchets 🌿');
  }

  bool get _isGoogleUser => FirebaseAuth.instance.currentUser?.providerData
      .any((p) => p.providerId == 'google.com') ?? false;

  void _confirmDelete(BuildContext context) {
    final s = AppStrings.of(ref.read(localeProvider).languageCode);

    if (_isGoogleUser) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(s.deleteAccount,
              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: Text(
            s.deleteAccountGoogleConfirm,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.no, style: const TextStyle(fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deleteAccountGoogle(s);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: Text(s.yes,
                  style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // Utilisateur email/mot de passe
      final passCtrl = TextEditingController();
      bool obscure = true;
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDlgState) {
            bool deleting = false;
            String? errorMsg;
            return StatefulBuilder(
              builder: (ctx, setInner) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(s.deleteAccount,
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.deleteAccountConfirm,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passCtrl,
                      obscureText: obscure,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(fontFamily: 'Poppins'),
                        errorText: errorMsg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded, size: 18),
                          onPressed: () => setDlgState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: deleting ? null : () => Navigator.pop(ctx),
                    child: Text(s.cancel, style: const TextStyle(fontFamily: 'Poppins')),
                  ),
                  ElevatedButton(
                    onPressed: deleting ? null : () async {
                      setInner(() { deleting = true; errorMsg = null; });
                      final err = await _deleteAccountPassword(ctx, passCtrl.text, s);
                      if (err != null && ctx.mounted) {
                        setInner(() { deleting = false; errorMsg = err; });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    child: deleting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(s.delete,
                            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> _preserveCommunityPoints(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('community_totals')
          .doc('stats')
          .set({'userCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Supprime TOUTES les données Firestore liées à [uid].
  Future<void> _deleteAllUserData(String uid) async {
    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(uid);

    // 1. Sous-collections de users/{uid}
    await _deleteSubcollection(userRef.collection('scans'));
    await _deleteSubcollection(userRef.collection('progress'));
    await _deleteSubcollection(userRef.collection('notifications'));
    await _deleteSubcollection(userRef.collection('chatFeedback'));

    // 2. Annonces marketplace publiées par cet utilisateur
    //    (+ leur sous-collection reviews/)
    try {
      QuerySnapshot listings;
      do {
        listings = await db.collection('marketplace')
            .where('userId', isEqualTo: uid)
            .limit(50)
            .get();
        if (listings.docs.isEmpty) break;
        for (final listing in listings.docs) {
          await _deleteSubcollection(listing.reference.collection('reviews'));
          await listing.reference.delete();
        }
      } while (listings.docs.length == 50);
    } catch (_) {}
  }

  Future<void> _deleteSubcollection(CollectionReference col) async {
    try {
      QuerySnapshot snap;
      do {
        snap = await col.limit(100).get();
        if (snap.docs.isEmpty) break;
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snap.docs) { batch.delete(doc.reference); }
        await batch.commit();
      } while (snap.docs.length == 100);
    } catch (_) {}
  }

  Future<void> _deleteAccountGoogle(AppStrings s) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;
      final userEmail = (user.email ?? '').toLowerCase();

      final gsi = GoogleSignIn();
      await gsi.signOut();
      final googleUser = await gsi.signIn();
      if (googleUser == null) return;

      // Reject immediately if the wrong Google account was picked
      if (googleUser.email.toLowerCase() != userEmail) {
        await gsi.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.wrongGoogleAccount,
              style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        return;
      }

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(cred);
      await _preserveCommunityPoints(uid);
      await _deleteAllUserData(uid);
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user.delete();
      if (!mounted) return;
      await signOutUser(ref);
      if (mounted) context.go('/login');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.errorMsg(e.message ?? ''),
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<String?> _deleteAccountPassword(BuildContext dlgCtx, String password, AppStrings s) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
      // Mot de passe correct — fermer le dialog et supprimer
      if (dlgCtx.mounted) Navigator.pop(dlgCtx);
      await _preserveCommunityPoints(uid);
      await _deleteAllUserData(uid);
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user.delete();
      if (!mounted) return null;
      await signOutUser(ref);
      if (mounted) context.go('/login');
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? s.wrongPassword
          : s.errorMsg(e.message ?? '');
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final bool isDark;
  final int delay;
  final List<Widget> children;
  const _Section({
    required this.title,
    required this.isDark,
    required this.delay,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          Divider(
                            height: 1,
                            indent: 54,
                            color: isDark
                                ? AppColors.darkInput
                                : AppColors.divider,
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(begin: 0.05);
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? AppColors.danger
                      : (isDark
                          ? AppColors.darkText
                          : AppColors.textPrimary),
                ),
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
