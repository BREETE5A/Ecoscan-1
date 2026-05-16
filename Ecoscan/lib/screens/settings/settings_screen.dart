import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifEnabled = true;
  bool _locationEnabled = true;
  bool _soundEnabled = false;
  bool _weeklyReport = true;
  String _city = 'Alger';

  static const _langCodes = ['fr', 'en', 'ar'];
  static const _langLabels = ['Français', 'English', 'العربية'];
  static const _cities = ['Alger', 'Oran', 'Constantine', 'Annaba', 'Tlemcen'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final darkEnabled = themeMode == ThemeMode.dark;
    final currentLang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(currentLang);
    final currentLangLabel = _langLabels[_langCodes.indexOf(currentLang)];

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
                    // Appearance section
                    _Section(
                      title: s.appearance,
                      isDark: isDark,
                      delay: 150,
                      children: [
                        _ToggleRow(
                          icon: isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          label: s.darkMode,
                          subtitle: s.darkModeDesc,
                          value: darkEnabled,
                          color: isDark ? AppColors.purple : AppColors.accent,
                          isDark: isDark,
                          onChanged: (_) =>
                              ref.read(themeProvider.notifier).toggle(),
                        ),
                        _DropdownRow(
                          icon: Icons.language_rounded,
                          label: s.language,
                          value: currentLangLabel,
                          items: _langLabels,
                          color: AppColors.info,
                          isDark: isDark,
                          onChanged: (v) {
                            final idx = _langLabels.indexOf(v);
                            if (idx >= 0) {
                              ref.read(localeProvider.notifier)
                                  .setLocale(Locale(_langCodes[idx]));
                            }
                          },
                        ),
                        _DropdownRow(
                          icon: Icons.location_city_rounded,
                          label: s.city,
                          value: _city,
                          items: _cities,
                          color: AppColors.teal,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _city = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notifications section
                    _Section(
                      title: s.notifications,
                      isDark: isDark,
                      delay: 250,
                      children: [
                        _ToggleRow(
                          icon: Icons.notifications_rounded,
                          label: s.notifPush,
                          subtitle: s.notifDesc,
                          value: _notifEnabled,
                          color: AppColors.primary,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _notifEnabled = v),
                        ),
                        _ToggleRow(
                          icon: Icons.volume_up_rounded,
                          label: s.sound,
                          subtitle: s.soundDesc,
                          value: _soundEnabled,
                          color: AppColors.accent,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _soundEnabled = v),
                        ),
                        _ToggleRow(
                          icon: Icons.bar_chart_rounded,
                          label: s.weeklyReport,
                          subtitle: s.weeklyReportDesc,
                          value: _weeklyReport,
                          color: AppColors.teal,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _weeklyReport = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Privacy section
                    _Section(
                      title: s.privacy,
                      isDark: isDark,
                      delay: 350,
                      children: [
                        _ToggleRow(
                          icon: Icons.location_on_rounded,
                          label: s.location,
                          subtitle: s.locationDesc,
                          value: _locationEnabled,
                          color: AppColors.danger,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _locationEnabled = v),
                        ),
                        _ActionRow(
                          icon: Icons.download_rounded,
                          label: s.exportData,
                          color: AppColors.info,
                          isDark: isDark,
                          onTap: () {},
                        ),
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
                    const SizedBox(height: 16),

                    // About section
                    _Section(
                      title: s.about,
                      isDark: isDark,
                      delay: 450,
                      children: [
                        _ActionRow(
                          icon: Icons.info_outline_rounded,
                          label: 'Version 1.0.0',
                          color: AppColors.textSecondary,
                          isDark: isDark,
                          trailing: const Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () {},
                        ),
                        _ActionRow(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Politique de confidentialité',
                          color: AppColors.info,
                          isDark: isDark,
                          onTap: () {},
                        ),
                        _ActionRow(
                          icon: Icons.star_outline_rounded,
                          label: 'Noter l\'application',
                          color: AppColors.accent,
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/login'),
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
                    ).animate(delay: 550.ms).fadeIn(duration: 400.ms),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () {},
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Supprimer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
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

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final Color color;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.color,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final Color color;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _DropdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.color,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.expand_more_rounded,
                color: AppColors.textSecondary, size: 18),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            dropdownColor:
                isDark ? AppColors.darkCard : Colors.white,
          ),
        ],
      ),
    );
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
