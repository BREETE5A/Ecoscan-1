import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Amine Benali');
  final _emailCtrl = TextEditingController(text: 'amine@ecoscan.ma');
  final _cityCtrl = TextEditingController(text: 'Oujda');
  final _bioCtrl = TextEditingController(
      text: 'Passionné par l\'environnement et le recyclage.');
  bool _saving = false;
  String _title = 'Éco-Warrior';

  final _titles = [
    'Débutant Vert',
    'Éco-Citoyen',
    'Éco-Warrior',
    'Gardien de la Planète',
    'Maître du Recyclage',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profil mis à jour avec succès !',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.go('/profile'),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Modifier le profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar picker
            Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile-avatar',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
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
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 50),
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
            ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 500.ms,
                curve: Curves.elasticOut),
            const SizedBox(height: 28),

            // Form fields
            _FormSection(
              title: 'Informations personnelles',
              isDark: isDark,
              children: [
                _Field(
                  label: 'Nom complet',
                  ctrl: _nameCtrl,
                  icon: Icons.person_outline_rounded,
                  delay: 100,
                  isDark: isDark,
                ),
                _Field(
                  label: 'Email',
                  ctrl: _emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  delay: 180,
                  isDark: isDark,
                ),
                _Field(
                  label: 'Ville',
                  ctrl: _cityCtrl,
                  icon: Icons.location_on_outlined,
                  delay: 260,
                  isDark: isDark,
                ),
                _Field(
                  label: 'Bio',
                  ctrl: _bioCtrl,
                  icon: Icons.info_outline_rounded,
                  maxLines: 3,
                  delay: 340,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title selector
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Titre affiché',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _titles
                        .map((t) => GestureDetector(
                              onTap: () => setState(() => _title = t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: t == _title
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkInput
                                          : AppColors.inputBg),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: t == _title
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1),
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
                    : const Text('Enregistrer les modifications'),
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
  final String title;
  final bool isDark;
  final List<Widget> children;
  const _FormSection(
      {required this.title, required this.isDark, required this.children});

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
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.1);
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final int delay;
  final bool isDark;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: delay.ms).slideX(begin: -0.05);
  }
}
