import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/did_you_know_data.dart';
import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';
import '../services/rotation_service.dart';
import '../theme/app_theme.dart';

class DidYouKnowCard extends ConsumerStatefulWidget {
  const DidYouKnowCard({super.key});

  @override
  ConsumerState<DidYouKnowCard> createState() => _DidYouKnowCardState();
}

class _DidYouKnowCardState extends ConsumerState<DidYouKnowCard> {
  DidYouKnowFact? _fact;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadFact();
    // Refresh every minute to catch hourly rotation.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _loadFact());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadFact() async {
    final fact = await RotationService.getCurrentFact();
    if (mounted) setState(() => _fact = fact);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);

    if (_fact == null) {
      return const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final fact = _fact!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            fact.color.withValues(alpha: isDark ? 0.25 : 0.12),
            fact.color.withValues(alpha: isDark ? 0.12 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fact.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fact.color.withValues(alpha: 0.15),
            ),
            child: Icon(fact.icon, color: fact.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      size: 12,
                      color: fact.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.didYouKnow,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: fact.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  fact.factFor(lang),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, duration: 400.ms, curve: Curves.easeOut);
  }
}
