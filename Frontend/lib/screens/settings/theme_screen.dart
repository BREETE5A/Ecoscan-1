import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);

    final options = [
      (ThemeMode.system, '📱', s.themeSystem,  s.themeSystemDesc),
      (ThemeMode.light,  '☀️', s.themeLight,   s.themeLightDesc),
      (ThemeMode.dark,   '🌙', s.themeDark,    s.themeDarkDesc),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
      appBar: AppBar(
        title: Text(
          s.appearance,
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            indent: 72,
            color: isDark ? AppColors.darkInput : AppColors.divider,
          ),
          itemBuilder: (context, i) {
            final (mode, emoji, title, subtitle) = options[i];
            final isSelected = current == mode;
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: Text(emoji, style: const TextStyle(fontSize: 28)),
              title: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkText : AppColors.textPrimary),
                ),
              ),
              subtitle: Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(mode);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
