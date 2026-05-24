import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final currentCode = locale.languageCode;
    final s = AppStrings.of(currentCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF9FBF7),
      appBar: AppBar(
        title: Text(
          s.chooseLang,
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // System language option
          Container(
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
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Text('📱', style: TextStyle(fontSize: 28)),
              title: Text(
                s.systemLang,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                s.systemLangDesc,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                ref.read(localeProvider.notifier).resetToSystem();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
            child: Column(
              children: List.generate(LocaleNotifier.supportedLanguages.length, (index) {
                final lang = LocaleNotifier.supportedLanguages[index];
                final isSelected = lang['code'] == currentCode;
                return Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                      title: Text(
                        lang['native']!,
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
                        lang['name']!,
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
                        ref.read(localeProvider.notifier).setLocale(Locale(lang['code']!));
                        Navigator.pop(context);
                      },
                    ),
                    if (index < LocaleNotifier.supportedLanguages.length - 1)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: isDark ? AppColors.darkInput : AppColors.divider,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
