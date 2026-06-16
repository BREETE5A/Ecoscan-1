import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';

class WaterFootprintScreen extends ConsumerStatefulWidget {
  const WaterFootprintScreen({super.key});

  @override
  ConsumerState<WaterFootprintScreen> createState() => _WaterFootprintScreenState();
}

class _WaterFootprintScreenState extends ConsumerState<WaterFootprintScreen> {
  double _dishes = 2;
  double _laundry = 3;
  double _garden = 0;

  static const _kDishes  = 'wf_dishes';
  static const _kLaundry = 'wf_laundry';
  static const _kGarden  = 'wf_garden';

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dishes  = prefs.getDouble(_kDishes)  ?? 2;
      _laundry = prefs.getDouble(_kLaundry) ?? 3;
      _garden  = prefs.getDouble(_kGarden)  ?? 0;
    });
  }

  Future<void> _save(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // Consommation en litres
  double get _dishesL    => _dishes * 15;
  double get _laundryL   => (_laundry / 7) * 60;
  double get _gardenL    => _garden * 15;
  double get _total      => _dishesL + _laundryL + _gardenL;

  static const _moroccanAvg = 143.0;

  Color get _totalColor {
    if (_total <= 30)  return const Color(0xFF00C853);
    if (_total <= 60)  return const Color(0xFFFFAB00);
    if (_total <= 100) return const Color(0xFFFF6D00);
    return const Color(0xFFD50000);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, lang),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildResultCard(isDark, lang).animate().scale(
                      begin: const Offset(0.9, 0.9), duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 20),
                    _buildSliders(isDark, lang).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),
                    _buildTips(isDark, lang).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, String lang) {
    final title = lang == 'ar' ? 'بصمة الماء' :
                  lang == 'en' ? 'Water Footprint' :
                  lang == 'es' ? 'Huella hídrica' : 'Empreinte eau';
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
        Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildResultCard(bool isDark, String lang) {
    final color = _totalColor;
    final avg = lang == 'ar' ? 'المعدل المغربي: 143 ل/يوم (البنك الدولي)' :
                lang == 'en' ? 'Moroccan average: 143 L/day (World Bank)' :
                lang == 'es' ? 'Promedio marroquí: 143 L/día (Banco Mundial)' :
                'Moyenne marocaine : 143 L/jour (Banque Mondiale)';
    final label = lang == 'ar' ? 'ل/يوم' : lang == 'en' ? 'L/day' : 'L/jour';
    final diff = (_total - _moroccanAvg).abs().round();
    final above = _total > _moroccanAvg;
    final compare = above
        ? (lang == 'ar' ? '+$diff ل فوق المعدل' : lang == 'en' ? '+$diff L above average' : '+$diff L au-dessus de la moyenne')
        : (lang == 'ar' ? '-$diff ل تحت المعدل' : lang == 'en' ? '-$diff L below average' : '-$diff L en dessous de la moyenne');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        const Icon(Icons.water_drop_rounded, color: Colors.white, size: 40),
        const SizedBox(height: 10),
        Text('${_total.round()}', style: const TextStyle(fontFamily: 'Poppins',
            fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
            color: Colors.white.withValues(alpha: 0.85))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(compare, style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Text(avg, style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75))),
      ]),
    );
  }

  Widget _buildSliders(bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06), blurRadius: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lang == 'ar' ? 'تفاصيل الاستهلاك' : lang == 'en' ? 'Consumption details' : 'Détail de votre consommation',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.textPrimary)),
        const SizedBox(height: 16),
        _WaterSlider(
          icon: Icons.set_meal_rounded,
          label: lang == 'ar' ? 'غسيل الأطباق' : lang == 'en' ? 'Dish washing' : 'Vaisselle',
          value: _dishes, min: 0, max: 6, unit: lang == 'ar' ? 'مرة/يوم' : lang == 'en' ? 'x/day' : 'x/jour',
          liters: _dishesL, color: const Color(0xFF00897B), isDark: isDark,
          onChanged: (v) { setState(() => _dishes = v);  _save(_kDishes,  v); },
        ),
        _WaterSlider(
          icon: Icons.local_laundry_service_rounded,
          label: lang == 'ar' ? 'غسيل الملابس' : lang == 'en' ? 'Laundry' : 'Machine à laver',
          value: _laundry, min: 0, max: 14, unit: lang == 'ar' ? 'مرة/أسبوع' : lang == 'en' ? 'x/week' : 'x/semaine',
          liters: _laundryL, color: const Color(0xFF7B1FA2), isDark: isDark,
          onChanged: (v) { setState(() => _laundry = v); _save(_kLaundry, v); },
        ),
        _WaterSlider(
          icon: Icons.grass_rounded,
          label: lang == 'ar' ? 'ري الحديقة' : lang == 'en' ? 'Garden watering' : 'Arrosage jardin',
          value: _garden, min: 0, max: 60, unit: lang == 'ar' ? 'دقيقة/يوم' : lang == 'en' ? 'min/day' : 'min/jour',
          liters: _gardenL, color: const Color(0xFF388E3C), isDark: isDark,
          onChanged: (v) { setState(() => _garden = v);  _save(_kGarden,  v); },
        ),
      ]),
    );
  }

  Widget _buildTips(bool isDark, String lang) {
    final tips = lang == 'ar' ? [
      'إصلاح الصنبور المتسرب يوفر 30 لتراً يومياً',
      'غسيل الملابس بماء بارد يقلل الاستهلاك بـ 30%',
      'ري الحديقة في الصباح الباكر يقلل التبخر',
    ] : lang == 'en' ? [
      'Fixing a leaky tap saves 30L/day',
      'Washing clothes in cold water reduces consumption by 30%',
      'Watering garden early morning reduces evaporation',
    ] : lang == 'es' ? [
      'Reparar un grifo con fuga ahorra 30 L/día',
      'Lavar la ropa en agua fría reduce el consumo en un 30%',
      'Regar el jardín a primera hora reduce la evaporación',
    ] : [
      'Réparer un robinet qui fuit économise 30 L/jour',
      'Laver le linge à l\'eau froide réduit la consommation de 30%',
      'Arroser le jardin tôt le matin réduit l\'évaporation',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0288D1).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFF0288D1), size: 20),
          const SizedBox(width: 8),
          Text(lang == 'ar' ? 'نصائح للتوفير' : lang == 'en' ? 'Saving tips' : 'Conseils économies',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                  fontWeight: FontWeight.w700, color: Color(0xFF0288D1))),
        ]),
        const SizedBox(height: 12),
        ...tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.water_drop_rounded, color: Color(0xFF0288D1), size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text(t, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 13, color: Color(0xFF0288D1)))),
          ]),
        )),
      ]),
    );
  }
}

class _WaterSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final double liters;
  final Color color;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _WaterSlider({
    required this.icon, required this.label, required this.value,
    required this.min, required this.max, required this.unit,
    required this.liters, required this.color, required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Poppins',
              fontSize: 13, fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkText : AppColors.textPrimary))),
          Text('${value.round()} $unit', style: TextStyle(fontFamily: 'Poppins',
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('${liters.round()} L', style: TextStyle(fontFamily: 'Poppins',
              fontSize: 11, color: AppColors.textSecondary)),
        ]),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ]),
    );
  }
}
