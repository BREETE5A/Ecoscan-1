import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
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
  Duration _timeLeft = const Duration(hours: 18, minutes: 34, seconds: 12);

  static const _daily = [
    _ChallengeData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scanner 3 déchets',
      titleEn: 'Scan 3 items',
      titleAr: 'امسح 3 عناصر',
      desc: 'Utilisez le scanner pour identifier 3 types de déchets différents',
      descEn: 'Use the scanner to identify 3 different waste types',
      descAr: 'استخدم الماسح الضوئي لتحديد 3 أنواع مختلفة من النفايات',
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
      desc: "Recyclez au moins 500g de plastique aujourd'hui",
      descEn: 'Recycle at least 500g of plastic today',
      descAr: 'أعد تدوير ما لا يقل عن 500 جرام من البلاستيك اليوم',
      points: 30,
      progress: 1.0,
      current: 1,
      total: 1,
      color: AppColors.plastic,
      icon2: Icons.check_circle_rounded,
    ),
    _ChallengeData(
      icon: Icons.share_rounded,
      title: 'Partager un conseil',
      titleEn: 'Share a tip',
      titleAr: 'شارك نصيحة',
      desc: 'Partagez un conseil écologique avec un ami',
      descEn: 'Share an eco tip with a friend',
      descAr: 'شارك نصيحة بيئية مع صديق',
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
      desc: 'Lisez 5 fiches du guide de tri des déchets',
      descEn: 'Read 5 items from the waste sorting guide',
      descAr: 'اقرأ 5 بطاقات من دليل فرز النفايات',
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
      desc: 'Identifiez et triez un déchet organique (restes alimentaires, épluchures)',
      descEn: 'Identify and sort one organic waste item (food scraps, peels)',
      descAr: 'حدد نفاية عضوية واحدة وافرزها (بقايا طعام، قشور)',
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
      desc: 'Ouvrez la carte et repérez un centre de recyclage près de chez vous',
      descEn: 'Open the map and locate a recycling center near you',
      descAr: 'افتح الخريطة وحدد مركز إعادة التدوير بالقرب منك',
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
      desc: "Posez une question à l'assistant EcoBot sur le recyclage",
      descEn: 'Ask the EcoBot assistant a recycling question',
      descAr: 'اطرح سؤالاً على مساعد EcoBot حول إعادة التدوير',
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
      desc: "Identifiez un déchet électronique et trouvez le bon point de collecte",
      descEn: 'Identify an electronic waste item and find the right drop-off point',
      descAr: 'حدد جهازًا إلكترونيًا وابحث عن نقطة التجميع الصحيحة',
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
      desc: 'Utilisez un sac réutilisable lors de vos achats aujourd\'hui',
      descEn: 'Use a reusable bag for your shopping today',
      descAr: 'استخدم حقيبة قابلة لإعادة الاستخدام لمشترياتك اليوم',
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
      desc: 'Découvrez 3 faits "Le saviez-vous?" dans l\'application',
      descEn: 'Discover 3 "Did you know?" facts in the app',
      descAr: 'اكتشف 3 حقائق "هل تعلم؟" في التطبيق',
      points: 10,
      progress: 0.33,
      current: 1,
      total: 3,
      color: Color(0xFF1ABC9C),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.delete_sweep_rounded,
      title: 'Trier 5 types différents',
      titleEn: 'Sort 5 different types',
      titleAr: 'افرز 5 أنواع مختلفة',
      desc: 'Identifiez 5 types de déchets distincts dans votre journée',
      descEn: 'Identify 5 distinct waste types throughout your day',
      descAr: 'حدد 5 أنواع مختلفة من النفايات خلال يومك',
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
      desc: 'Effectuez un geste zéro déchet : compostage, vrac, contenant réutilisable',
      descEn: 'Do one zero-waste action: composting, bulk shopping, or reusable container',
      descAr: 'قم بفعل صفر نفايات: تسميد، شراء بالجملة، أو حاوية قابلة للتدوير',
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
      desc: 'Scannez au moins un déchet chaque jour pendant 7 jours',
      descEn: 'Scan at least one item every day for 7 days',
      descAr: 'امسح عنصرًا واحدًا على الأقل كل يوم لمدة 7 أيام',
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
      desc: 'Déposez 3 appareils électroniques dans les bons bacs',
      descEn: 'Drop off 3 electronic devices at the right bins',
      descAr: 'ضع 3 أجهزة إلكترونية في الحاويات الصحيحة',
      points: 150,
      progress: 0.33,
      current: 1,
      total: 3,
      color: AppColors.electronics,
      icon2: Icons.devices_rounded,
    ),
    _ChallengeData(
      icon: Icons.group_rounded,
      title: 'Éco-ambassadeur',
      titleEn: 'Eco-ambassador',
      titleAr: 'سفير بيئي',
      desc: 'Invitez 2 amis à rejoindre EcoScan',
      descEn: 'Invite 2 friends to join EcoScan',
      descAr: 'ادعُ 2 من الأصدقاء للانضمام إلى EcoScan',
      points: 100,
      progress: 0.5,
      current: 1,
      total: 2,
      color: Color(0xFF9B59B6),
      icon2: Icons.person_add_rounded,
    ),
    _ChallengeData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scanner 20 déchets',
      titleEn: 'Scan 20 waste items',
      titleAr: 'امسح 20 نفاية',
      desc: 'Atteignez 20 scans cette semaine pour booster votre impact',
      descEn: 'Reach 20 scans this week to boost your impact',
      descAr: 'حقق 20 مسحًا هذا الأسبوع لتعزيز تأثيرك',
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
      desc: 'Rendez-vous dans 2 centres de recyclage différents cette semaine',
      descEn: 'Visit 2 different recycling centers this week',
      descAr: 'توجه إلى مركزَي إعادة تدوير مختلفَين هذا الأسبوع',
      points: 180,
      progress: 0.5,
      current: 1,
      total: 2,
      color: Color(0xFF3498DB),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.recycling_rounded,
      title: 'Économiser 2 kg plastique',
      titleEn: 'Save 2 kg of plastic',
      titleAr: 'وفر 2 كغ من البلاستيك',
      desc: 'Recyclez ou évitez 2 kg de plastique cette semaine',
      descEn: 'Recycle or avoid 2 kg of plastic this week',
      descAr: 'أعد تدوير أو تجنب 2 كيلوغرام من البلاستيك هذا الأسبوع',
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
      desc: 'Diffusez 5 conseils de tri à vos amis ou sur les réseaux sociaux',
      descEn: 'Share 5 sorting tips with friends or on social media',
      descAr: 'شارك 5 نصائح الفرز مع أصدقائك أو على وسائل التواصل الاجتماعي',
      points: 120,
      progress: 0.4,
      current: 2,
      total: 5,
      color: AppColors.teal,
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.compost_rounded,
      title: 'Composter 3 fois',
      titleEn: 'Compost 3 times',
      titleAr: 'قم بالتسميد 3 مرات',
      desc: 'Déposez vos déchets organiques en composteur 3 fois cette semaine',
      descEn: 'Add to compost 3 times this week',
      descAr: 'أضف نفاياتك العضوية إلى السماد 3 مرات هذا الأسبوع',
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
      desc: 'Lisez toutes les catégories du guide de tri des déchets',
      descEn: 'Read all categories of the waste sorting guide',
      descAr: 'اقرأ جميع فئات دليل فرز النفايات',
      points: 200,
      progress: 0.22,
      current: 2,
      total: 9,
      color: Color(0xFF1565C0),
      icon2: Icons.circle_outlined,
    ),
    _ChallengeData(
      icon: Icons.family_restroom_rounded,
      title: 'Inviter 3 amis',
      titleEn: 'Invite 3 friends',
      titleAr: 'ادعُ 3 أصدقاء',
      desc: 'Partagez EcoScan avec 3 amis et aidez-les à commencer à trier',
      descEn: 'Share EcoScan with 3 friends and help them start sorting',
      descAr: 'شارك EcoScan مع 3 أصدقاء وساعدهم على البدء في الفرز',
      points: 200,
      progress: 0.33,
      current: 1,
      total: 3,
      color: Color(0xFFE91E63),
      icon2: Icons.circle_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft -= const Duration(seconds: 1);
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
    final userScans = ref.watch(userProvider).scans;

    // Défi "Scanner 3 déchets" : progression réelle depuis user.scans
    final scanCurrent = userScans.clamp(0, 3);
    final dynamicDaily = [
      _ChallengeData(
        icon: _daily[0].icon, icon2: _daily[0].icon2,
        title: _daily[0].title, titleEn: _daily[0].titleEn, titleAr: _daily[0].titleAr,
        desc: _daily[0].desc, descEn: _daily[0].descEn, descAr: _daily[0].descAr,
        points: _daily[0].points, color: _daily[0].color,
        current: scanCurrent, total: 3,
        progress: (scanCurrent / 3).clamp(0.0, 1.0),
      ),
      ..._daily.skip(1),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s, isDark),
            _buildStreakBanner(isDark),
            const SizedBox(height: 12),
            _buildTabBar(isDark),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _ChallengeList(challenges: dynamicDaily, isDark: isDark, lang: lang),
                  _ChallengeList(challenges: _weekly, isDark: isDark, lang: lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppStrings s, bool isDark) {
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
            child: const Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  '5 🔥',
                  style: TextStyle(
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

  Widget _buildStreakBanner(bool isDark) {
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
                  const Text(
                    'Série de 5 jours !',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Continuez pour débloquer un badge spécial',
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
              child: const Text(
                '2 de plus',
                style: TextStyle(
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

  Widget _buildTabBar(bool isDark) {
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
          tabs: const [
            Tab(text: 'Quotidiens'),
            Tab(text: 'Hebdomadaires'),
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
    required this.data,
    required this.isDark,
    required this.lang,
    required this.delay,
  });

  String get _title => lang == 'en'
      ? data.titleEn
      : lang == 'ar'
          ? data.titleAr
          : data.title;

  String get _desc => lang == 'en'
      ? data.descEn
      : lang == 'ar'
          ? data.descAr
          : data.desc;

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
                    lang == 'en'
                        ? 'Completed!'
                        : lang == 'ar'
                            ? 'مكتمل!'
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
  final String desc;
  final String descEn;
  final String descAr;
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
    required this.desc,
    required this.descEn,
    required this.descAr,
    required this.points,
    required this.progress,
    required this.current,
    required this.total,
    required this.color,
  });
}
