import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final int _balance = 1240;

  static const _categories = ['all', 'nature', 'coupons', 'donations', 'digital'];

  static const _rewards = [
    _RewardData(
      id: 'r1',
      title: 'Planter un arbre',
      titleEn: 'Plant a tree',
      titleAr: 'زراعة شجرة',
      desc: 'Un arbre planté en votre nom en Algérie',
      descEn: 'A tree planted in your name in Algeria',
      descAr: 'شجرة تُزرع باسمك في الجزائر',
      category: 'nature',
      cost: 500,
      icon: '🌳',
      color: AppColors.primary,
      redeemed: false,
    ),
    _RewardData(
      id: 'r2',
      title: '10% sur Ecostore',
      titleEn: '10% off Ecostore',
      titleAr: '10% خصم على Ecostore',
      desc: 'Coupon 10% sur la boutique en ligne Ecostore',
      descEn: '10% coupon on the Ecostore online shop',
      descAr: 'قسيمة 10% على متجر Ecostore الإلكتروني',
      category: 'coupons',
      cost: 300,
      icon: '🏷️',
      color: AppColors.accent,
      redeemed: true,
    ),
    _RewardData(
      id: 'r3',
      title: 'Don WWF Algérie',
      titleEn: 'WWF Algeria donation',
      titleAr: 'تبرع لـ WWF الجزائر',
      desc: '200 DA reversés au WWF Algérie',
      descEn: '200 DA donated to WWF Algeria',
      descAr: '200 دج تُتبرع بها لـ WWF الجزائر',
      category: 'donations',
      cost: 400,
      icon: '🐻',
      color: Color(0xFF9B59B6),
      redeemed: false,
    ),
    _RewardData(
      id: 'r4',
      title: 'Badge Premium',
      titleEn: 'Premium Badge',
      titleAr: 'شارة مميزة',
      desc: 'Débloquez un badge exclusif sur votre profil',
      descEn: 'Unlock an exclusive badge on your profile',
      descAr: 'افتح شارة حصرية على ملفك الشخصي',
      category: 'digital',
      cost: 150,
      icon: '🏅',
      color: Color(0xFFFFD700),
      redeemed: false,
    ),
    _RewardData(
      id: 'r5',
      title: 'Kit éco-jardinage',
      titleEn: 'Eco-gardening kit',
      titleAr: 'مجموعة البستنة البيئية',
      desc: 'Recevez un kit de graines bio à domicile',
      descEn: 'Receive an organic seed kit at home',
      descAr: 'احصل على مجموعة بذور عضوية في منزلك',
      category: 'nature',
      cost: 800,
      icon: '🌱',
      color: AppColors.teal,
      redeemed: false,
    ),
    _RewardData(
      id: 'r6',
      title: 'Fond d\'écran exclusif',
      titleEn: 'Exclusive wallpaper',
      titleAr: 'خلفية حصرية',
      desc: 'Pack de fonds d\'écran éco-thème',
      descEn: 'Eco-themed wallpaper pack',
      descAr: 'حزمة خلفيات ذات طابع بيئي',
      category: 'digital',
      cost: 100,
      icon: '🖼️',
      color: AppColors.info,
      redeemed: false,
    ),
  ];

  String _activeCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() => _activeCategory = _categories[_tab.index]);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<_RewardData> get _filtered => _activeCategory == 'all'
      ? _rewards
      : _rewards.where((r) => r.category == _activeCategory).toList();

  void _showRedeemDialog(BuildContext ctx, _RewardData reward, AppStrings s) {
    final lang = ref.read(localeProvider).languageCode;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _RedeemSheet(
        reward: reward,
        balance: _balance,
        lang: lang,
        s: s,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(s, isDark),
            _buildBalanceCard(s, isDark),
            _buildTabBar(s, isDark),
            Expanded(
              child: _buildGrid(isDark, lang, s),
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
                  s.rewardsTitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                Text(
                  lang == 'fr'
                      ? 'Échangez vos points contre des récompenses'
                      : lang == 'en'
                          ? 'Redeem your points for rewards'
                          : 'استبدل نقاطك بمكافآت',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get lang => ref.read(localeProvider).languageCode;

  Widget _buildBalanceCard(AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.yourBalance,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: _balance),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    builder: (_, v, _) => Text(
                      '$v pts',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('🌿', style: TextStyle(fontSize: 28)),
            ),
          ],
        ),
      ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.05),
    );
  }

  Widget _buildTabBar(AppStrings s, bool isDark) {
    final labels = {
      'all': s.filterAll,
      'nature': s.trees,
      'coupons': s.coupons,
      'donations': s.donations,
      'digital': s.digital,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: SizedBox(
        height: 40,
        child: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          tabs: _categories
              .map((c) => Tab(
                    child: Text(labels[c] ?? c),
                  ))
              .toList(),
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildGrid(bool isDark, String lang, AppStrings s) {
    final items = _filtered;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _RewardCard(
        reward: items[i],
        isDark: isDark,
        lang: lang,
        balance: _balance,
        delay: i * 80,
        onTap: () => _showRedeemDialog(ctx, items[i], s),
      ),
    );
  }
}

class _RewardCard extends StatefulWidget {
  final _RewardData reward;
  final bool isDark;
  final String lang;
  final int balance;
  final int delay;
  final VoidCallback onTap;

  const _RewardCard({
    required this.reward,
    required this.isDark,
    required this.lang,
    required this.balance,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sc;

  @override
  void initState() {
    super.initState();
    _sc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  bool get _canAfford => widget.balance >= widget.reward.cost;

  String get _title => widget.lang == 'en'
      ? widget.reward.titleEn
      : widget.lang == 'ar'
          ? widget.reward.titleAr
          : widget.reward.title;

  String get _desc => widget.lang == 'en'
      ? widget.reward.descEn
      : widget.lang == 'ar'
          ? widget.reward.descAr
          : widget.reward.desc;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sc,
      builder: (_, child) =>
          Transform.scale(scale: _sc.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _sc.reverse(),
        onTapUp: (_) {
          _sc.forward();
          widget.onTap();
        },
        onTapCancel: () => _sc.forward(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: widget.reward.redeemed
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.reward.color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.reward.icon,
                      style: const TextStyle(fontSize: 32)),
                  if (widget.reward.redeemed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.lang == 'en'
                            ? '✓ Done'
                            : widget.lang == 'ar'
                                ? '✓ تم'
                                : '✓ Obtenu',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark
                      ? AppColors.darkText
                      : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _desc,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.reward.cost} pts',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _canAfford
                          ? widget.reward.color
                          : AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _canAfford && !widget.reward.redeemed
                          ? widget.reward.color
                          : AppColors.textSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _canAfford && !widget.reward.redeemed
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

class _RedeemSheet extends StatelessWidget {
  final _RewardData reward;
  final int balance;
  final String lang;
  final AppStrings s;

  const _RedeemSheet({
    required this.reward,
    required this.balance,
    required this.lang,
    required this.s,
  });

  bool get _canAfford => balance >= reward.cost;

  String get _title =>
      lang == 'en' ? reward.titleEn : lang == 'ar' ? reward.titleAr : reward.title;

  String get _desc =>
      lang == 'en' ? reward.descEn : lang == 'ar' ? reward.descAr : reward.desc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(reward.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            _title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == 'en'
                      ? 'Cost'
                      : lang == 'ar'
                          ? 'التكلفة'
                          : 'Coût',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${reward.cost} pts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: reward.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canAfford && !reward.redeemed
                  ? () => Navigator.pop(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: reward.color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(
                reward.redeemed
                    ? s.redeemed
                    : _canAfford
                        ? s.redeem
                        : s.notEnoughPoints,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RewardData {
  final String id;
  final String title;
  final String titleEn;
  final String titleAr;
  final String desc;
  final String descEn;
  final String descAr;
  final String category;
  final int cost;
  final String icon;
  final Color color;
  final bool redeemed;

  const _RewardData({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.desc,
    required this.descEn,
    required this.descAr,
    required this.category,
    required this.cost,
    required this.icon,
    required this.color,
    required this.redeemed,
  });
}
