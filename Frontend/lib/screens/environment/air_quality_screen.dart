import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../services/air_quality_service.dart';
import '../../theme/app_theme.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

// Clé de la ville sélectionnée manuellement (null = GPS)
final _selectedCityKeyProvider = StateProvider<String?>((ref) => null);

// Provider principal — réagit au changement de ville
final airQualityScreenProvider = FutureProvider<AirQualityResult>((ref) async {
  final key = ref.watch(_selectedCityKeyProvider);
  if (key != null) {
    // Ville sélectionnée manuellement → coords de cette ville
    final d = await AirQualityService.fetchByCityKey(key);
    return d != null
        ? AirQualityResult.success(d)
        : AirQualityResult.failure(AirQualityError.networkError);
  }
  // Pas de ville → GPS auto-détection
  return AirQualityService.fetchWithStatus();
});

// ── Screen ────────────────────────────────────────────────────────────────────
class AirQualityScreen extends ConsumerWidget {
  const AirQualityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang   = ref.watch(localeProvider).languageCode;
    final s      = AppStrings.of(lang);
    final async  = ref.watch(airQualityScreenProvider);
    final selKey = ref.watch(_selectedCityKeyProvider);

    // Nom de la ville sélectionnée (pour l'afficher dans le header)
    final selName = selKey != null
        ? moroccanCities
            .firstWhere((c) => c.key == selKey, orElse: () => moroccanCities.first)
            .name
        : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context, isDark, s, lang, selName, ref),
          Expanded(child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, t) => _buildError(context, isDark, s, lang,
                AirQualityError.networkError, ref),
            data: (result) {
              if (result.data != null) {
                return _buildContent(context, result.data!, isDark, lang, s,
                    gpsError: result.error, ref: ref);
              }
              return _buildError(context, isDark, s, lang,
                  result.error ?? AirQualityError.networkError, ref);
            },
          )),
        ]),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark, AppStrings s,
      String lang, String? selName, WidgetRef ref) {
    final cityLabel = lang == 'ar' ? 'اختر مدينتك'
        : lang == 'en' ? 'Choose city'
        : lang == 'es' ? 'Elegir ciudad'
        : 'Choisir ma ville';

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
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.qaAirQuality, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          )),
          if (selName != null)
            GestureDetector(
              // Tap sur la ville sélectionnée → revenir au GPS
              onTap: () => ref.read(_selectedCityKeyProvider.notifier).state = null,
              child: Row(children: [
                Text(selName, style: const TextStyle(fontFamily: 'Poppins',
                    fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 4),
                const Icon(Icons.close_rounded, size: 12, color: AppColors.textSecondary),
              ]),
            )
          else
            Row(children: [
              const Icon(Icons.gps_fixed_rounded, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(lang == 'ar' ? 'GPS تلقائي' : lang == 'en' ? 'Auto GPS'
                  : lang == 'es' ? 'GPS auto' : 'GPS auto',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.primary)),
            ]),
        ])),
        // Bouton GPS (reset si ville manuelle)
        if (selName != null)
          GestureDetector(
            onTap: () => ref.read(_selectedCityKeyProvider.notifier).state = null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text('GPS', style: const TextStyle(fontFamily: 'Poppins',
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          ),
        // Bouton sélecteur de ville
        GestureDetector(
          onTap: () => _showCityPicker(context, isDark, lang, cityLabel, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 15),
              const SizedBox(width: 5),
              Text(cityLabel, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w600, color: AppColors.primary,
              )),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Sélecteur de ville ──────────────────────────────────────────────────────
  void _showCityPicker(BuildContext context, bool isDark, String lang,
      String label, WidgetRef ref) {
    final s = AppStrings.of(lang);
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        )),
        // Option GPS automatique
        ListTile(
          leading: const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 20),
          title: Text(
            s.autoGpsDetect,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              fontWeight: ref.read(_selectedCityKeyProvider) == null
                  ? FontWeight.bold : FontWeight.normal,
              color: ref.read(_selectedCityKeyProvider) == null
                  ? AppColors.primary
                  : (isDark ? AppColors.darkText : AppColors.textPrimary),
            ),
          ),
          trailing: ref.read(_selectedCityKeyProvider) == null
              ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
          onTap: () {
            ref.read(_selectedCityKeyProvider.notifier).state = null;
            Navigator.pop(ctx);
          },
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: moroccanCities.length,
            itemBuilder: (_, i) {
              final city = moroccanCities[i];
              final selected = ref.read(_selectedCityKeyProvider) == city.key;
              return ListTile(
                leading: Icon(Icons.location_on_rounded,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    size: 20),
                title: Text(city.name, style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? AppColors.primary
                      : (isDark ? AppColors.darkText : AppColors.textPrimary),
                )),
                trailing: selected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(_selectedCityKeyProvider.notifier).state = city.key;
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  // ── Erreur GPS ou réseau ────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, bool isDark, AppStrings s,
      String lang, AirQualityError error, WidgetRef ref) {

    final String msg;
    final IconData icon;
    final String hint;

    switch (error) {
      case AirQualityError.gpsDisabled:
        msg  = lang == 'ar' ? 'GPS معطّل'
             : lang == 'en' ? 'GPS is disabled'
             : lang == 'es' ? 'GPS desactivado'
             : 'GPS désactivé';
        hint = lang == 'ar' ? 'فعّل GPS أو اختر مدينتك يدوياً'
             : lang == 'en' ? 'Enable GPS or choose your city manually'
             : lang == 'es' ? 'Activa el GPS o elige tu ciudad manualmente'
             : 'Activez le GPS ou choisissez votre ville manuellement';
        icon = Icons.gps_off_rounded;
      case AirQualityError.permissionDenied:
        msg  = lang == 'ar' ? 'تم رفض إذن GPS'
             : lang == 'en' ? 'GPS permission denied'
             : lang == 'es' ? 'Permiso GPS denegado'
             : 'Permission GPS refusée';
        hint = lang == 'ar' ? 'اختر مدينتك يدوياً'
             : lang == 'en' ? 'Choose your city manually'
             : lang == 'es' ? 'Elige tu ciudad manualmente'
             : 'Choisissez votre ville manuellement';
        icon = Icons.location_off_rounded;
      case AirQualityError.networkError:
        msg  = lang == 'ar' ? 'تعذّر تحميل البيانات'
             : lang == 'en' ? 'Cannot load data'
             : lang == 'es' ? 'No se pueden cargar los datos'
             : 'Impossible de charger les données';
        hint = lang == 'ar' ? 'تحقق من اتصالك بالإنترنت'
             : lang == 'en' ? 'Check your internet connection'
             : lang == 'es' ? 'Verifica tu conexión a Internet'
             : 'Vérifiez votre connexion Internet';
        icon = Icons.cloud_off_rounded;
    }

    final cityBtn = lang == 'ar' ? 'اختر مدينتك'
        : lang == 'en' ? 'Choose your city'
        : lang == 'es' ? 'Elegir ciudad'
        : 'Choisir ma ville';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(hint, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 28),
          // Bouton choisir ville (toujours disponible)
          ElevatedButton.icon(
            onPressed: () => _showCityPicker(context, isDark, lang, cityBtn, ref),
            icon: const Icon(Icons.location_city_rounded),
            label: Text(cityBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(220, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          if (error == AirQualityError.networkError) ...[
            const SizedBox(height: 12),
            // Bouton réessayer
            TextButton.icon(
              onPressed: () => ref.invalidate(airQualityScreenProvider),
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              label: Text(s.retry,
                  style: const TextStyle(fontFamily: 'Poppins',
                      color: AppColors.primary, fontSize: 14)),
            ),
          ],
        ]),
      ),
    );
  }

  // ── Contenu ─────────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, AirQualityData data,
      bool isDark, String lang, AppStrings s,
      {AirQualityError? gpsError, required WidgetRef ref}) {

    final color = Color(data.color);
    final level = lang == 'ar' ? data.levelAr
                : lang == 'en' ? data.levelEn
                : lang == 'es' ? data.levelEs
                : data.level;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [

        // Bannière : aucune station dans la ville détectée → redirection
        if (data.isRedirected)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.5)),
            ),
            child: Row(children: [
              const Icon(Icons.place_rounded, color: Color(0xFF1E88E5), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                lang == 'ar'
                  ? 'لا توجد محطة في ${data.detectedCity} — يُعرض بيانات ${data.city} (الأقرب)'
                  : lang == 'en'
                  ? 'No station in ${data.detectedCity} — showing ${data.city} (nearest)'
                  : lang == 'es'
                  ? 'Sin estación en ${data.detectedCity} — mostrando ${data.city} (más cercana)'
                  : 'Aucune station à ${data.detectedCity} — données de ${data.city} (la plus proche)',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    color: Color(0xFF1565C0)),
              )),
            ]),
          ).animate().fadeIn(duration: 300.ms),

        // Bannière info si GPS désactivé
        if (gpsError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCA28)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFF57F17), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                gpsError == AirQualityError.gpsDisabled
                  ? (lang == 'ar' ? 'GPS معطّل — فعّله للحصول على بيانات مدينتك بدقة'
                    : lang == 'en' ? 'GPS disabled — enable it to get your exact city data'
                    : lang == 'es' ? 'GPS desactivado — actívalo para datos de tu ciudad exacta'
                    : 'GPS désactivé — activez-le pour avoir les données de votre ville exacte')
                  : s.airQualityGpsHint,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    color: Color(0xFFF57F17)),
              )),
            ]),
          ).animate().fadeIn(duration: 300.ms),

        // Carte AQI principale
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20, offset: const Offset(0, 8),
            )],
          ),
          child: Column(children: [
            Text(data.city, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text('${data.aqi}', style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('AQI', style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(level, style: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ]),
        ).animate().scale(begin: const Offset(0.9, 0.9), duration: 500.ms,
            curve: Curves.elasticOut).fadeIn(duration: 400.ms),

        const SizedBox(height: 20),
        _PollutantsCard(data: data, isDark: isDark, lang: lang),
        const SizedBox(height: 16),
        _TipsCard(aqi: data.aqi, isDark: isDark, lang: lang),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ── Polluants (toutes les substances OWM avec couleurs AQI dynamiques) ───────
class _PollutantsCard extends StatelessWidget {
  final AirQualityData data;
  final bool isDark;
  final String lang;
  const _PollutantsCard({required this.data, required this.isDark, required this.lang});

  // Valeur max par substance pour la barre de progression
  static const _maxVal = {
    'PM2.5': 75.0,
    'PM10':  150.0,
    'NO₂':   200.0,
    'O₃':    180.0,
    'CO':    10000.0,
    'SO₂':   350.0,
    'NH₃':   200.0,
  };

  // Couleur selon la valeur relative à son seuil
  Color _barColor(String name, double v) {
    final max = _maxVal[name] ?? 200.0;
    final ratio = v / max;
    if (ratio < 0.2)  return const Color(0xFF00C853); // Bon
    if (ratio < 0.4)  return const Color(0xFFFFAB00); // Modéré
    if (ratio < 0.6)  return const Color(0xFFFF6D00); // Mauvais sensibles
    if (ratio < 0.8)  return const Color(0xFFD50000); // Mauvais
    return const Color(0xFF6200EA);                    // Très mauvais
  }

  String _displayValue(String name, double v) {
    if (name == 'CO') return '${(v / 1000).toStringAsFixed(1)} mg/m³';
    return '${v.toStringAsFixed(1)} µg/m³';
  }

  @override
  Widget build(BuildContext context) {
    final title = lang == 'ar' ? 'الملوثات'
                : lang == 'en' ? 'Pollutants'
                : lang == 'es' ? 'Contaminantes'
                : 'Polluants';

    final entries = data.pollutants.entries.where((e) => e.value > 0).toList();

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
        Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.textPrimary)),
        const SizedBox(height: 14),
        ...entries.map((e) {
          final max = _maxVal[e.key] ?? 200.0;
          final ratio = (e.value / max).clamp(0.0, 1.0);
          final barColor = _barColor(e.key, e.value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.key, style: TextStyle(fontFamily: 'Poppins',
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary)),
                Text(_displayValue(e.key, e.value),
                    style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: barColor)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: isDark ? AppColors.darkInput : AppColors.inputBg,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 8,
                ),
              ),
            ]),
          );
        }),
      ]),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

// ── Conseils selon AQI (5 niveaux, 4 langues) ────────────────────────────────
class _TipsCard extends StatelessWidget {
  final int aqi;
  final bool isDark;
  final String lang;
  const _TipsCard({required this.aqi, required this.isDark, required this.lang});

  List<String> get _tips {
    if (aqi <= 50) { switch (lang) {
      case 'ar': return ['الهواء نقي، استمتع بالأنشطة الخارجية', 'يوم مثالي للتنزه أو الرياضة', 'استمر في الممارسات البيئية الجيدة'];
      case 'en': return ['Air is clean, enjoy outdoor activities', 'Perfect day for a walk or sports', 'Keep up your good eco practices'];
      case 'es': return ['El aire es limpio, disfruta al aire libre', 'Día perfecto para pasear o deportes', 'Mantén tus buenas prácticas ecológicas'];
      default:   return ['L\'air est pur, profitez des activités en plein air', 'Journée idéale pour une promenade ou du sport', 'Continuez vos bonnes pratiques éco'];
    }}
    if (aqi <= 100) { switch (lang) {
      case 'ar': return ['مقبول للأنشطة الخارجية', 'الأشخاص الحساسون يجب أن يكونوا حذرين', 'تجنب حرق النفايات — يزيد التلوث'];
      case 'en': return ['Acceptable for outdoor activities', 'Sensitive people should be cautious', 'Avoid burning waste — increases pollution'];
      case 'es': return ['Aceptable para actividades al aire libre', 'Personas sensibles deben ser precavidas', 'Evita quemar residuos — aumenta la contaminación'];
      default:   return ['Acceptable pour les activités extérieures', 'Les personnes sensibles doivent être prudentes', 'Évitez de brûler des déchets — ça aggrave la pollution'];
    }}
    if (aqi <= 150) { switch (lang) {
      case 'ar': return ['الأنشطة المكثفة غير مستحسنة للفئات الحساسة', 'الأطفال وكبار السن يجب تقليل الوقت خارجاً', 'فكّر في ارتداء قناع عند الخروج'];
      case 'en': return ['Intense activity not recommended for sensitive groups', 'Children and elderly should limit outdoor time', 'Consider wearing a mask outside'];
      case 'es': return ['Actividad intensa no recomendada para grupos sensibles', 'Niños y mayores deben limitar tiempo al exterior', 'Considera usar mascarilla al salir'];
      default:   return ['Activité intense déconseillée pour les groupes sensibles', 'Enfants et personnes âgées : limitez le temps dehors', 'Envisagez de porter un masque à l\'extérieur'];
    }}
    if (aqi <= 200) { switch (lang) {
      case 'ar': return ['تجنب الأنشطة الخارجية المكثفة', 'ارتدِ قناعاً عند الخروج', 'أبلغ عن مصادر التلوث القريبة'];
      case 'en': return ['Avoid intense outdoor activities', 'Wear a mask when going outside', 'Report nearby pollution sources'];
      case 'es': return ['Evita actividades intensas al aire libre', 'Usa mascarilla al salir', 'Reporta fuentes de contaminación cercanas'];
      default:   return ['Évitez les activités extérieures intenses', 'Portez un masque si vous sortez', 'Signalez les sources de pollution proches'];
    }}
    switch (lang) {
      case 'ar': return ['ابقَ في المنزل قدر الإمكان', 'أغلق النوافذ وتجنب الخروج', 'أبلغ الجهات المختصة عن حوادث التلوث الشديد'];
      case 'en': return ['Stay indoors as much as possible', 'Close windows and avoid going outside', 'Report severe pollution incidents to authorities'];
      case 'es': return ['Permanece en interior tanto como sea posible', 'Cierra ventanas y evita salir', 'Reporta incidentes de contaminación grave'];
      default:   return ['Restez à l\'intérieur autant que possible', 'Fermez les fenêtres et évitez de sortir', 'Signalez les incidents de pollution grave aux autorités'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = lang == 'ar' ? 'نصائح صحية'
                : lang == 'en' ? 'Health tips'
                : lang == 'es' ? 'Consejos de salud'
                : 'Conseils santé';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
            fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 12),
        ..._tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(t, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13, color: AppColors.primary))),
          ]),
        )),
      ]),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}
