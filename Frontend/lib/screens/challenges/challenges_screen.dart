import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/challenges_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Timer _timer;
  late Duration _timeLeft;

  static const _daily = [
    _ChallengeData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scanner 3 déchets',
      titleEn: 'Scan 3 items',
      titleAr: 'امسح 3 عناصر',
      titleEs: 'Escanear 3 residuos',
      desc: 'Utilisez le scanner pour identifier 3 types de déchets différents',
      descEn: 'Use the scanner to identify 3 different waste types',
      descAr: 'استخدم الماسح الضوئي لتحديد 3 أنواع مختلفة من النفايات',
      descEs: 'Usa el escáner para identificar 3 tipos diferentes de residuos',
      points: 50,
      progress: 0.67,
      current: 2,
      total: 3,
      color: AppColors.primary,
      icon2: Icons.check_circle_outline_rounded,
    ),
    _ChallengeData(
      icon: Icons.recycling_rounded,
      title: 'Recycler du plastique',
      titleEn: 'Recycle plastic',
      titleAr: 'إعادة تدوير البلاستيك',
      titleEs: 'Reciclar plástico',
      desc: "Recyclez au moins 500g de plastique aujourd'hui",
      descEn: 'Recycle at least 500g of plastic today',
      descAr: 'أعد تدوير ما لا يقل عن 500 جرام من البلاستيك اليوم',
      descEs: 'Recicla al menos 500g de plástico hoy',
      points: 30,
      progress: 0.0,
      current: 0,
      total: 1,
      color: AppColors.plastic,
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.share_rounded,
      title: 'Partager un conseil',
      titleEn: 'Share a tip',
      titleAr: 'شارك نصيحة',
      titleEs: 'Compartir un consejo',
      desc: 'Partagez un conseil écologique avec un ami',
      descEn: 'Share an eco tip with a friend',
      descAr: 'شارك نصيحة بيئية مع صديق',
      descEs: 'Comparte un consejo ecológico con un amigo',
      points: 20,
      progress: 0.0,
      current: 0,
      total: 1,
      color: AppColors.teal,
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.menu_book_rounded,
      title: 'Consulter le guide',
      titleEn: 'Check the guide',
      titleAr: 'راجع الدليل',
      titleEs: 'Consultar la guía',
      desc: 'Lisez 5 fiches du guide de tri des déchets',
      descEn: 'Read 5 items from the waste sorting guide',
      descAr: 'اقرأ 5 بطاقات من دليل فرز النفايات',
      descEs: 'Lee 5 fichas de la guía de clasificación de residuos',
      points: 15,
      progress: 0.4,
      current: 2,
      total: 5,
      color: Color(0xFF3498DB),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.compost_rounded,
      title: 'Scanner un déchet organique',
      titleEn: 'Scan organic waste',
      titleAr: 'امسح نفايات عضوية',
      titleEs: 'Escanear residuo orgánico',
      desc: 'Identifiez et triez un déchet organique (restes alimentaires, épluchures)',
      descEn: 'Identify and sort one organic waste item (food scraps, peels)',
      descAr: 'حدد نفاية عضوية واحدة وافرزها (بقايا طعام، قشور)',
      descEs: 'Identifica y clasifica un residuo orgánico (restos de comida, pieles)',
      points: 25,
      progress: 0.0,
      current: 0,
      total: 1,
      color: Color(0xFF795548),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.map_rounded,
      title: 'Trouver un centre de tri',
      titleEn: 'Find a recycling center',
      titleAr: 'ابحث عن مركز الفرز',
      titleEs: 'Encontrar un centro de reciclaje',
      desc: 'Ouvrez la carte et repérez un centre de recyclage près de chez vous',
      descEn: 'Open the map and locate a recycling center near you',
      descAr: 'افتح الخريطة وحدد مركز إعادة التدوير بالقرب منك',
      descEs: 'Abre el mapa y localiza un centro de reciclaje cerca de ti',
      points: 20,
      progress: 0.0,
      current: 0,
      total: 1,
      color: Color(0xFF9B59B6),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.smart_toy_rounded,
      title: 'Utiliser EcoBot',
      titleEn: 'Use EcoBot',
      titleAr: 'استخدم EcoBot',
      titleEs: 'Usar EcoBot',
      desc: "Posez une question à l'assistant EcoBot sur le recyclage",
      descEn: 'Ask the EcoBot assistant a recycling question',
      descAr: 'اطرح سؤالاً على مساعد EcoBot حول إعادة التدوير',
      descEs: 'Haz una pregunta al asistente EcoBot sobre el reciclaje',
      points: 15,
      progress: 0.0,
      current: 0,
      total: 1,
      color: Color(0xFFF39C12),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.devices_rounded,
      title: 'Scanner un DEEE',
      titleEn: 'Scan e-waste',
      titleAr: 'امسح نفايات إلكترونية',
      titleEs: 'Escanear residuo electrónico',
      desc: "Identifiez un déchet électronique et trouvez le bon point de collecte",
      descEn: 'Identify an electronic waste item and find the right drop-off point',
      descAr: 'حدد جهازًا إلكترونيًا وابحث عن نقطة التجميع الصحيحة',
      descEs: 'Identifica un residuo electrónico y encuentra el punto de recogida correcto',
      points: 40,
      progress: 0.0,
      current: 0,
      total: 1,
      color: Color(0xFF7B1FA2),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.shopping_bag_outlined,
      title: 'Éviter le sac plastique',
      titleEn: 'Avoid plastic bag',
      titleAr: 'تجنب الكيس البلاستيكي',
      titleEs: 'Evitar la bolsa de plástico',
      desc: 'Utilisez un sac réutilisable lors de vos achats aujourd\'hui',
      descEn: 'Use a reusable bag for your shopping today',
      descAr: 'استخدم حقيبة قابلة لإعادة الاستخدام لمشترياتك اليوم',
      descEs: 'Usa una bolsa reutilizable en tus compras de hoy',
      points: 25,
      progress: 0.0,
      current: 0,
      total: 1,
      color: Color(0xFF27AE60),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Lire 3 faits éco',
      titleEn: 'Read 3 eco facts',
      titleAr: 'اقرأ 3 حقائق بيئية',
      titleEs: 'Leer 3 datos ecológicos',
      desc: 'Découvrez 3 faits "Le saviez-vous?" dans l\'application',
      descEn: 'Discover 3 "Did you know?" facts in the app',
      descAr: 'اكتشف 3 حقائق "هل تعلم؟" في التطبيق',
      descEs: 'Descubre 3 datos "¿Sabías que?" en la aplicación',
      points: 10,
      progress: 0.0,
      current: 0,
      total: 3,
      color: Color(0xFF1ABC9C),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.delete_sweep_rounded,
      title: 'Trier 5 types différents',
      titleEn: 'Sort 5 different types',
      titleAr: 'افرز 5 أنواع مختلفة',
      titleEs: 'Clasificar 5 tipos distintos',
      desc: 'Identifiez 5 types de déchets distincts dans votre journée',
      descEn: 'Identify 5 distinct waste types throughout your day',
      descAr: 'حدد 5 أنواع مختلفة من النفايات خلال يومك',
      descEs: 'Identifica 5 tipos distintos de residuos durante tu día',
      points: 60,
      progress: 0.0,
      current: 0,
      total: 5,
      color: Color(0xFFFF6B35),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.eco_rounded,
      title: 'Geste zéro déchet',
      titleEn: 'Zero-waste action',
      titleAr: 'فعل صفر نفايات',
      titleEs: 'Acción cero residuos',
      desc: 'Effectuez un geste zéro déchet : compostage, vrac, contenant réutilisable',
      descEn: 'Do one zero-waste action: composting, bulk shopping, or reusable container',
      descAr: 'قم بفعل صفر نفايات: تسميد، شراء بالجملة، أو حاوية قابلة للتدوير',
      descEs: 'Haz una acción cero residuos: compostaje, compra a granel o envase reutilizable',
      points: 35,
      progress: 0.0,
      current: 0,
      total: 1,
      color: Color(0xFF2E7D32),
      icon2: Icons.circle_outlined,
    ),
  ];

  static const _weekly = [
    _ChallengeData(
      icon: Icons.emoji_events_rounded,
      title: 'Streak 7 jours',
      titleEn: '7-day streak',
      titleAr: '7 أيام متتالية',
      titleEs: 'Racha de 7 días',
      desc: 'Scannez au moins un déchet chaque jour pendant 7 jours',
      descEn: 'Scan at least one item every day for 7 days',
      descAr: 'امسح عنصرًا واحدًا على الأقل كل يوم لمدة 7 أيام',
      descEs: 'Escanea al menos un residuo cada día durante 7 días',
      points: 200,
      progress: 0.71,
      current: 5,
      total: 7,
      color: Color(0xFFFFD700),
      icon2: Icons.local_fire_department_rounded,
    ),
    _ChallengeData(
      icon: Icons.nature_rounded,
      title: 'Zéro déchet électronique',
      titleEn: 'Zero e-waste',
      titleAr: 'صفر نفايات إلكترونية',
      titleEs: 'Cero residuos electrónicos',
      desc: 'Déposez 3 appareils électroniques dans les bons bacs',
      descEn: 'Drop off 3 electronic devices at the right bins',
      descAr: 'ضع 3 أجهزة إلكترونية في الحاويات الصحيحة',
      descEs: 'Deposita 3 dispositivos electrónicos en los contenedores correctos',
      points: 150,
      progress: 0.0,
      current: 0,
      total: 3,
      color: AppColors.electronics,
      icon2: Icons.devices_rounded,
    ),
    _ChallengeData(
      icon: Icons.group_rounded,
      title: 'Éco-ambassadeur',
      titleEn: 'Eco-ambassador',
      titleAr: 'سفير بيئي',
      titleEs: 'Eco-embajador',
      desc: 'Invitez 2 amis à rejoindre EcoScan',
      descEn: 'Invite 2 friends to join EcoScan',
      descAr: 'ادعُ 2 من الأصدقاء للانضمام إلى EcoScan',
      descEs: 'Invita a 2 amigos a unirse a EcoScan',
      points: 100,
      progress: 0.0,
      current: 0,
      total: 2,
      color: Color(0xFF9B59B6),
      icon2: Icons.person_add_rounded,
    ),
    _ChallengeData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scanner 20 déchets',
      titleEn: 'Scan 20 waste items',
      titleAr: 'امسح 20 نفاية',
      titleEs: 'Escanear 20 residuos',
      desc: 'Atteignez 20 scans cette semaine pour booster votre impact',
      descEn: 'Reach 20 scans this week to boost your impact',
      descAr: 'حقق 20 مسحًا هذا الأسبوع لتعزيز تأثيرك',
      descEs: 'Alcanza 20 escaneos esta semana para potenciar tu impacto',
      points: 250,
      progress: 0.4,
      current: 8,
      total: 20,
      color: AppColors.primary,
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.place_rounded,
      title: 'Visiter 2 centres de tri',
      titleEn: 'Visit 2 recycling centers',
      titleAr: 'زُر مركزَي فرز',
      titleEs: 'Visitar 2 centros de reciclaje',
      desc: 'Rendez-vous dans 2 centres de recyclage différents cette semaine',
      descEn: 'Visit 2 different recycling centers this week',
      descAr: 'توجه إلى مركزَي إعادة تدوير مختلفَين هذا الأسبوع',
      descEs: 'Ve a 2 centros de reciclaje diferentes esta semana',
      points: 180,
      progress: 0.0,
      current: 0,
      total: 2,
      color: Color(0xFF3498DB),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.recycling_rounded,
      title: 'Économiser 2 kg plastique',
      titleEn: 'Save 2 kg of plastic',
      titleAr: 'وفر 2 كغ من البلاستيك',
      titleEs: 'Ahorrar 2 kg de plástico',
      desc: 'Recyclez ou évitez 2 kg de plastique cette semaine',
      descEn: 'Recycle or avoid 2 kg of plastic this week',
      descAr: 'أعد تدوير أو تجنب 2 كيلوغرام من البلاستيك هذا الأسبوع',
      descEs: 'Recicla o evita 2 kg de plástico esta semana',
      points: 300,
      progress: 0.0,
      current: 0,
      total: 2,
      color: AppColors.plastic,
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.share_rounded,
      title: 'Partager 5 conseils éco',
      titleEn: 'Share 5 eco tips',
      titleAr: 'شارك 5 نصائح بيئية',
      titleEs: 'Compartir 5 consejos eco',
      desc: 'Diffusez 5 conseils de tri à vos amis ou sur les réseaux sociaux',
      descEn: 'Share 5 sorting tips with friends or on social media',
      descAr: 'شارك 5 نصائح الفرز مع أصدقائك أو على وسائل التواصل الاجتماعي',
      descEs: 'Comparte 5 consejos de clasificación con amigos o en redes sociales',
      points: 120,
      progress: 0.0,
      current: 0,
      total: 5,
      color: AppColors.teal,
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.compost_rounded,
      title: 'Composter 3 fois',
      titleEn: 'Compost 3 times',
      titleAr: 'قم بالتسميد 3 مرات',
      titleEs: 'Compostar 3 veces',
      desc: 'Déposez vos déchets organiques en composteur 3 fois cette semaine',
      descEn: 'Add to compost 3 times this week',
      descAr: 'أضف نفاياتك العضوية إلى السماد 3 مرات هذا الأسبوع',
      descEs: 'Añade residuos orgánicos al compostador 3 veces esta semana',
      points: 150,
      progress: 0.0,
      current: 0,
      total: 3,
      color: Color(0xFF795548),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.menu_book_rounded,
      title: 'Terminer le guide complet',
      titleEn: 'Complete the full guide',
      titleAr: 'أكمل الدليل الكامل',
      titleEs: 'Completar la guía completa',
      desc: 'Lisez toutes les catégories du guide de tri des déchets',
      descEn: 'Read all categories of the waste sorting guide',
      descAr: 'اقرأ جميع فئات دليل فرز النفايات',
      descEs: 'Lee todas las categorías de la guía de clasificación de residuos',
      points: 200,
      progress: 0.0,
      current: 0,
      total: 9,
      color: Color(0xFF1565C0),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.family_restroom_rounded,
      title: 'Inviter 3 amis',
      titleEn: 'Invite 3 friends',
      titleAr: 'ادعُ 3 أصدقاء',
      titleEs: 'Invitar a 3 amigos',
      desc: 'Partagez EcoScan avec 3 amis et aidez-les à commencer à trier',
      descEn: 'Share EcoScan with 3 friends and help them start sorting',
      descAr: 'شارك EcoScan مع 3 أصدقاء وساعدهم على البدء في الفرز',
      descEs: 'Comparte EcoScan con 3 amigos y ayúdalos a empezar a clasificar',
      points: 200,
      progress: 0.0,
      current: 0,
      total: 3,
      color: Color(0xFFE91E63),
      icon2: Icons.circle_outlined,
    ),
  ];

  static Duration _timeUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _timeLeft = _timeUntilMidnight();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft -= const Duration(seconds: 1);
        } else {
          _timeLeft = _timeUntilMidnight();
        }
      });
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final cp = ref.watch(challengesProvider);

    // ── Défis quotidiens avec vraies données ──────────────────────────────────
    _ChallengeData patch(_ChallengeData base, int current, int total) =>
        _ChallengeData(
          icon: base.icon, icon2: base.icon2,
          title: base.title, titleEn: base.titleEn,
          titleAr: base.titleAr, titleEs: base.titleEs,
          desc: base.desc, descEn: base.descEn,
          descAr: base.descAr, descEs: base.descEs,
          points: base.points, color: base.color,
          current: current.clamp(0, total), total: total,
          progress: (current / total).clamp(0.0, 1.0),
        );

    final dynamicDaily = [
      patch(_daily[0], cp.dailyScans, 3),           // Scanner 3 déchets
      _daily[1],                                       // Recycler plastique
      patch(_daily[2], cp.shared ? 1 : 0, 1),        // Partager un conseil
      patch(_daily[3], cp.guideViews, 5),             // Consulter le guide
      _daily[4],                                       // Scanner déchet organique
      patch(_daily[5], cp.mapOpened ? 1 : 0, 1),     // Trouver un centre de tri
      patch(_daily[6], cp.ecoBotUsed ? 1 : 0, 1),    // Utiliser EcoBot
      ..._daily.skip(7),
    ];

    final dynamicWeekly = [
      patch(_weekly[0], user.streak, 7),              // Streak 7 jours
      ..._weekly.skip(1, ).take(2),
      patch(_weekly[3], cp.weeklyScans, 20),          // Scanner 20 déchets
      ..._weekly.skip(4),
    ];

    // Défis complétés déplacés en fin de liste
    dynamicDaily.sort((a, b) {
      final ac = a.progress >= 1.0;
      final bc = b.progress >= 1.0;
      if (ac == bc) return 0;
      return ac ? 1 : -1;
    });
    dynamicWeekly.sort((a, b) {
      final ac = a.progress >= 1.0;
      final bc = b.progress >= 1.0;
      if (ac == bc) return 0;
      return ac ? 1 : -1;
    });

    // Verrou : 5 scans requis pour accéder aux défis
    final statsAsync = ref.watch(userStatsStreamProvider);
    final currentScans = statsAsync.when(
      data: (u) => u.scans,
      loading: () => user.scans,
      error: (_, _) => user.scans,
    );
    if (currentScans < 5) {
      return Scaffold(
        body: SafeArea(child: _ChallengesLocked(currentScans: currentScans)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s, isDark, user.streak),
            _buildStreakBanner(isDark, s, user.streak),
            const SizedBox(height: 12),
            _buildTabBar(isDark, s),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _ChallengeList(challenges: dynamicDaily, isDark: isDark, lang: lang),
                  _ChallengeList(challenges: dynamicWeekly, isDark: isDark, lang: lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppStrings s, bool isDark, int streak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.challengesTitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                Text(
                  '${s.resetIn} ${_fmt(_timeLeft)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$streak 🔥',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideX(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildStreakBanner(bool isDark, AppStrings s, int streak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.streakDays(streak),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    s.streakBadge,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                s.streakMore((7 - streak).clamp(0, 7)),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideX(begin: -0.05);
  }

  Widget _buildTabBar(bool isDark, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.inputBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: s.challengeTabDaily),
            Tab(text: s.challengeTabWeekly),
          ],
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          dividerColor: Colors.transparent,
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }
}

class _ChallengeList extends StatelessWidget {
  final List<_ChallengeData> challenges;
  final bool isDark;
  final String lang;

  const _ChallengeList({
    required this.challenges,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
      itemCount: challenges.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ChallengeCard(
          key: ValueKey(challenges[i].title),
          data: challenges[i],
          isDark: isDark,
          lang: lang,
          delay: i * 80,
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final _ChallengeData data;
  final bool isDark;
  final String lang;
  final int delay;

  const _ChallengeCard({
    super.key,
    required this.data,
    required this.isDark,
    required this.lang,
    required this.delay,
  });

  String get _title {
    switch (lang) {
      case 'en': return data.titleEn;
      case 'ar': return data.titleAr;
      case 'es': return data.titleEs.isEmpty ? data.title : data.titleEs;
      default:   return data.title;
    }
  }

  String get _desc {
    switch (lang) {
      case 'en': return data.descEn;
      case 'ar': return data.descAr;
      case 'es': return data.descEs.isEmpty ? data.desc : data.descEs;
      default:   return data.desc;
    }
  }

  bool get _completed => data.progress >= 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: _completed
            ? Border.all(color: data.color.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _desc,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${data.points}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: data.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'pts',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: data.progress),
                    duration: Duration(milliseconds: 800 + delay),
                    curve: Curves.easeOut,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      backgroundColor:
                          isDark ? AppColors.darkInput : AppColors.inputBg,
                      valueColor: AlwaysStoppedAnimation<Color>(data.color),
                      minHeight: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${data.current}/${data.total}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (_completed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: data.color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    lang == 'en' ? 'Completed!'
                        : lang == 'ar' ? 'مكتمل!'
                        : lang == 'es' ? '¡Completado!'
                        : 'Complété !',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: data.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms);
  }
}

class _ChallengeData {
  final IconData icon;
  final IconData icon2;
  final String title;
  final String titleEn;
  final String titleAr;
  final String titleEs;
  final String desc;
  final String descEn;
  final String descAr;
  final String descEs;
  final int points;
  final double progress;
  final int current;
  final int total;
  final Color color;

  const _ChallengeData({
    required this.icon,
    required this.icon2,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    this.titleEs = '',
    required this.desc,
    required this.descEn,
    required this.descAr,
    this.descEs = '',
    required this.points,
    required this.progress,
    required this.current,
    required this.total,
    required this.color,
  });
}

// ── Écran de verrou Défis (requis : 5 scans / badge Éco-Actif) ───────────────
class _ChallengesLocked extends StatelessWidget {
  final int currentScans;
  const _ChallengesLocked({required this.currentScans});

  static const _required = 5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (currentScans / _required).clamp(0.0, 1.0);
    final remaining = _required - currentScans;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.lock_rounded, color: AppColors.accent, size: 46),
          ),
          const SizedBox(height: 24),
          const Text(
            'Défis verrouillés',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Badge requis : Éco-Actif',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        'Réalisez $_required scans pour débloquer les défis',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression : $currentScans/$_required scans',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$remaining restant${remaining > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor: isDark ? AppColors.darkInput : AppColors.inputBg,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Scannez des déchets avec l\'appareil photo pour progresser',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: isDark ? AppColors.primary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
