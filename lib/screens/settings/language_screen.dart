import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final currentCode = locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Langue / Language / اللغة / Idioma'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: LocaleNotifier.supportedLanguages.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lang = LocaleNotifier.supportedLanguages[index];
          final isSelected = lang['code'] == currentCode;

          return ListTile(
            leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
            title: Text(
              lang['native']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF2D6A4F) : null,
              ),
            ),
            subtitle: Text(lang['name']!, style: const TextStyle(fontSize: 13)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFF2D6A4F))
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(Locale(lang['code']!));
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
