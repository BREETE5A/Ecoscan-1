import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
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
      desc: 'Recyclez au moins 500g de plastique aujourd\'hui',
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
                  _ChallengeList(challenges: _daily, isDark: isDark, lang: lang),
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
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text(
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
          delay: i * 100,
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
