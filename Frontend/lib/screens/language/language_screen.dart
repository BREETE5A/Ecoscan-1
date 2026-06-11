import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;
  String? _selected;

  static const _languages = [
    _LangData(
      code: 'fr',
      name: 'Français',
      native: 'Français',
      flag: '🇫🇷',
      greeting: 'Bonjour !',
      desc: 'Langue par défaut',
    ),
    _LangData(
      code: 'en',
      name: 'English',
      native: 'English',
      flag: '🇬🇧',
      greeting: 'Hello!',
      desc: 'Default language',
    ),
    _LangData(
      code: 'ar',
      name: 'العربية',
      native: 'العربية',
      flag: '🇲🇦',
      greeting: '!مرحباً',
      desc: 'اللغة العربية',
    ),
    _LangData(
      code: 'es',
      name: 'Español',
      native: 'Español',
      flag: '🇪🇸',
      greeting: '¡Hola!',
      desc: 'Idioma español',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    final current = ref.read(localeProvider).languageCode;
    _selected = current;
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_selected != null) {
      ref.read(localeProvider.notifier).setLocale(Locale(_selected!));
    }
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, _) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF0D1F12),
                Color(0xFF1A3320),
                Color(0xFF27AE60),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.4 + _bgCtrl.value * 0.2,
                1.0,
              ],
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildHeader(),
            const SizedBox(height: 48),
            ..._languages.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _LangCard(
                    data: e.value,
                    isSelected: _selected == e.value.code,
                    delay: e.key * 120,
                    onTap: () => setState(() => _selected = e.value.code),
                  ),
                )),
            const Spacer(),
            _buildConfirmButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
          ),
          child: const Icon(Icons.language_rounded, color: Colors.white, size: 44),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              duration: 700.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 500.ms),
        const SizedBox(height: 20),
        const Text(
          'Choisissez votre langue',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 500.ms),
        const SizedBox(height: 8),
        Text(
          'Choose your language  /  اختر لغتك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 350.ms),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selected != null ? _confirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Continuer / Continue / متابعة'),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .slideY(begin: 0.3, duration: 500.ms, delay: 600.ms);
  }
}

class _LangCard extends StatefulWidget {
  final _LangData data;
  final bool isSelected;
  final int delay;
  final VoidCallback onTap;

  const _LangCard({
    required this.data,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_LangCard> createState() => _LangCardState();
}

class _LangCardState extends State<_LangCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleCtrl.reverse();
  void _onTapUp(_) {
    _scaleCtrl.forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleCtrl,
      builder: (_, child) => Transform.scale(scale: _scaleCtrl.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => _scaleCtrl.forward(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.15),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(widget.data.flag,
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.native,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.data.greeting,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: widget.isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.primary, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, duration: 400.ms);
  }
}

class _LangData {
  final String code;
  final String name;
  final String native;
  final String flag;
  final String greeting;
  final String desc;

  const _LangData({
    required this.code,
    required this.name,
    required this.native,
    required this.flag,
    required this.greeting,
    required this.desc,
  });
}
