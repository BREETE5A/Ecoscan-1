import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../theme/app_theme.dart';

const _kAvatarPathKey = 'user_avatar_path';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  bool _saving = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _bioCtrl = TextEditingController();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    // Charger avatar
    final path = prefs.getString(_kAvatarPathKey);
    // Charger bio depuis Firestore
    String bio = '';
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        bio = (doc.data()?['bio'] as String?) ?? '';
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        if (path != null && File(path).existsSync()) _avatarPath = path;
        _bioCtrl.text = bio;
      });
      if (path != null && File(path).existsSync()) {
        ref.read(avatarPathProvider.notifier).state = path;
      }
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Caméra', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Galerie', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (picked == null || !mounted) return;

    final appDir = await getApplicationDocumentsDirectory();
    final dest = File('${appDir.path}/profile_avatar.jpg');
    await File(picked.path).copy(dest.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarPathKey, dest.path);

    // Vider le cache image pour forcer le rechargement depuis le disque
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (mounted) {
      setState(() => _avatarPath = dest.path);
      ref.read(avatarPathProvider.notifier).state = dest.path;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppStrings.of(ref.read(localeProvider).languageCode);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // 1. Mettre à jour Firebase Auth
      await user.updateDisplayName(name);
      // 2. Mettre à jour Firestore (nom + bio)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'displayName': name,
            'bio': _bioCtrl.text.trim(),
          }, SetOptions(merge: true));
      // 3. Recharger le provider depuis Firestore pour propager partout
      await ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: name,
        firebaseUid: user.uid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.profileUpdated,
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e',
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.go('/profile'),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(s.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'profile-avatar',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _avatarPath == null ? AppColors.primaryGradient : null,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                            ),
                          ],
                          image: _avatarPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_avatarPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _avatarPath == null
                            ? const Icon(Icons.person_rounded,
                                color: Colors.white, size: 50)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 500.ms,
                curve: Curves.elasticOut),
            const SizedBox(height: 28),

            // Form fields
            _FormSection(
              isDark: isDark,
              children: [
                _Field(
                  label: s.fullName,
                  ctrl: _nameCtrl,
                  icon: Icons.person_outline_rounded,
                  delay: 100,
                  isDark: isDark,
                ),
                // Email shown read-only — changes via change-email flow
                _ReadOnlyField(
                  label: 'Email',
                  value: user?.email ?? '',
                  icon: Icons.email_outlined,
                  delay: 180,
                  isDark: isDark,
                  onTap: () => context.push('/change-email'),
                ),
                _Field(
                  label: s.bio,
                  ctrl: _bioCtrl,
                  icon: Icons.info_outline_rounded,
                  maxLines: 3,
                  delay: 260,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(s.saveChanges),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _FormSection({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.1);
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final int maxLines;
  final int delay;
  final bool isDark;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.maxLines = 1,
    required this.delay,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: delay.ms).slideX(begin: -0.05);
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final int delay;
  final bool isDark;
  final VoidCallback onTap;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    required this.delay,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: delay.ms).slideX(begin: -0.05);
  }
}
