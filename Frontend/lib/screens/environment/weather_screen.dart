import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../services/weather_service.dart';
import '../../theme/app_theme.dart';

final _weatherProvider = FutureProvider<WeatherData?>(
    (ref) => WeatherService.fetchByLocation());

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s     = AppStrings.of(ref.watch(localeProvider).languageCode);
    final async = ref.watch(_weatherProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(children: [
          _header(context, isDark, s),
          Expanded(child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => _error(isDark, s),
            data:    (data) => data == null ? _error(isDark, s) : _content(data, isDark, s),
          )),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark, AppStrings s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text(s.weatherTitle, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        )),
      ]),
    );
  }

  Widget _error(bool isDark, AppStrings s) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.cloud_off_rounded, size: 60, color: AppColors.textSecondary),
      const SizedBox(height: 16),
      Text(s.weatherLoadError, style: const TextStyle(
          fontFamily: 'Poppins', color: AppColors.textSecondary)),
    ]));
  }

  Widget _content(WeatherData data, bool isDark, AppStrings s) {
    final gradient = _gradientFor(data.condition);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Carte principale
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 20, offset: const Offset(0, 8),
            )],
          ),
          child: Column(children: [
            Text(data.city, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(_weatherEmoji(data.condition), style: const TextStyle(fontSize: 60)),
            Text('${data.temp.round()}°C', style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 56,
                fontWeight: FontWeight.bold, color: Colors.white)),
            Text(data.description, style: TextStyle(fontFamily: 'Poppins',
                fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _statChip(Icons.water_drop_rounded, '${data.humidity}%', s.weatherHumidity),
              _statChip(Icons.air_rounded, '${data.windSpeed.round()} m/s', s.weatherWind),
            ]),
          ]),
        ).animate().scale(begin: const Offset(0.9, 0.9), duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 20),

        _EcoTipsCard(data: data, isDark: isDark, s: s)
            .animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 16),

        _HydrationCard(temp: data.temp, isDark: isDark, s: s)
            .animate(delay: 350.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Poppins',
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8))),
      ]),
    );
  }

  LinearGradient _gradientFor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'clouds':
        return const LinearGradient(colors: [Color(0xFF78909C), Color(0xFFB0BEC5)],
            begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'rain': case 'drizzle':
        return const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'thunderstorm':
        return const LinearGradient(colors: [Color(0xFF37474F), Color(0xFF78909C)],
            begin: Alignment.topLeft, end: Alignment.bottomRight);
      default:
        return const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  String _weatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':       return '☀️';
      case 'clouds':      return '☁️';
      case 'rain': case 'drizzle': return '🌧️';
      case 'thunderstorm':return '⛈️';
      case 'snow':        return '❄️';
      case 'mist': case 'fog': return '🌫️';
      default:            return '🌤️';
    }
  }
}

class _EcoTipsCard extends StatelessWidget {
  final WeatherData data;
  final bool isDark;
  final AppStrings s;
  const _EcoTipsCard({required this.data, required this.isDark, required this.s});

  List<String> get tips {
    final cond = data.condition.toLowerCase();
    final t    = data.temp;

    // Condition météo prioritaire sur la température
    if (cond.contains('thunderstorm'))           return s.weatherTipsStormy;
    if (cond.contains('snow'))                   return s.weatherTipsSnow;
    if (cond.contains('rain') || cond.contains('drizzle')) return s.weatherTipsRainy;
    if (cond.contains('mist') || cond.contains('fog'))     return s.weatherTipsMist;

    // Paliers de température (5 niveaux)
    if (t < 5)  return s.weatherTipsVeryCold;
    if (t < 15) return s.weatherTipsCold;
    if (t < 25) return s.weatherTipsMild;
    if (t < 35) return s.weatherTipsWarm;
    return s.weatherTipsHot;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.weatherEcoTipsTitle, style: TextStyle(fontFamily: 'Poppins',
            fontSize: 15, fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.eco_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(t, style: TextStyle(fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark ? AppColors.darkText : AppColors.textPrimary))),
          ]),
        )),
      ]),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final double temp;
  final bool isDark;
  final AppStrings s;
  const _HydrationCard({required this.temp, required this.isDark, required this.s});

  int get _liters => temp >= 35 ? 3 : 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0288D1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.weatherHydTitle, style: const TextStyle(fontFamily: 'Poppins',
            fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0288D1))),
        const SizedBox(height: 8),
        Text(s.weatherHydMsg(temp.round(), _liters),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                color: Color(0xFF0288D1))),
        const SizedBox(height: 12),
        Row(children: List.generate(_liters, (i) =>
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.water_drop_rounded, color: Color(0xFF0288D1), size: 28),
          ),
        )),
      ]),
    );
  }
}
