import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

// ── Daily eco-facts (one per day, rotates automatically) ──────────────────────
const _kEcoFacts = [
  'Un sac plastique met 400 ans à se dégrader dans la nature.',
  "Recycler une canette d'aluminium économise 95 % d'énergie par rapport à la production neuve.",
  'Chaque tonne de papier recyclé sauve 17 arbres et économise 2,5 tonnes de CO₂.',
  'Le Maroc produit environ 5 millions de tonnes de déchets solides par an.',
  'Une bouteille en verre peut être recyclée à l\'infini sans perdre sa pureté.',
  'Les déchets électroniques représentent 70 % des toxines dans les décharges mondiales.',
  'Recycler une bouteille en verre économise l\'énergie pour alimenter une ampoule 4 heures.',
  'Le plastique PET (bouteilles d\'eau) peut être recyclé en fibres textiles.',
  'Un téléphone portable contient de l\'or, de l\'argent et du cuivre récupérables.',
  'Les emballages représentent 30 % des déchets ménagers au Maroc.',
  'La décomposition des déchets organiques produit du méthane, 25 × plus puissant que le CO₂.',
  'Composter 1 kg de déchets organiques réduit les émissions de 0,5 kg de CO₂.',
  'Le verre met 4 000 ans à se décomposer dans la nature.',
  'Une pile bouton peut contaminer 400 000 litres d\'eau si mal éliminée.',
  'Le Plan National des Déchets du Maroc vise 100 % de collecte d\'ici 2030.',
  'Les textiles non recyclés représentent 10 % des émissions mondiales de carbone.',
  '1 tonne d\'aluminium recyclé économise 4 tonnes de bauxite.',
  'Les déchets alimentaires représentent un tiers de tous les aliments produits dans le monde.',
  'Un journal peut être recyclé jusqu\'à 7 fois avant que ses fibres ne soient trop courtes.',
  'Les bouteilles en plastique mettent entre 400 et 1 000 ans à se dégrader.',
  'Le Maroc est le premier pays africain à interdire les sacs plastiques à usage unique (2016).',
  'Recycler 1 tonne de plastique économise 1,8 tonne de pétrole.',
  'Les piles usagées contiennent du mercure, du cadmium et du plomb – métaux lourds très toxiques.',
  'La production d\'une voiture génère autant de CO₂ que la conduite pendant 2 ans.',
  'Trier vos déchets augmente le taux de recyclage et réduit les coûts de traitement.',
  'Le carton peut être recyclé jusqu\'à 5 fois avant de perdre ses propriétés.',
  'En recyclant vos DEEE, vous récupérez des matières premières rares et précieuses.',
  '80 % des matériaux d\'un smartphone peuvent être récupérés et réutilisés.',
  'Un seul arbre peut absorber jusqu\'à 22 kg de CO₂ par an.',
  'Les déchets ménagers marocains contiennent 60–70 % de déchets organiques.',
  'La production d\'une tonne de papier vierge consomme 100 000 litres d\'eau.',
  'Le recyclage du verre réduit les émissions de CO₂ de 20 % par rapport au neuf.',
  'L\'économie circulaire pourrait créer 4 millions d\'emplois en Afrique d\'ici 2030.',
  'Les micro-plastiques ont été retrouvés dans le sang humain et dans l\'Himalaya.',
  'Chaque Marocain produit en moyenne 0,8 kg de déchets par jour.',
  'Le compostage réduit de 30 % la quantité de déchets envoyés en décharge.',
  'Les cannettes recyclées peuvent être de retour sur les étagères en 60 jours.',
  'Le plastique PVC (n°3) est difficile à recycler et libère des toxines à l\'incinération.',
  '91 % du plastique produit dans le monde n\'a jamais été recyclé.',
  'Racheter une bouteille d\'eau coûte 1 000 fois plus que l\'eau du robinet.',
  'Le Maroc ambitionne d\'atteindre 52 % d\'énergies renouvelables d\'ici 2030.',
  'Une boîte de conserve en acier met 50 ans à se dégrader dans la nature.',
  'Le plastique oxodégradable n\'est PAS biodégradable – il se fragmente en micro-plastiques.',
  'Les huiles usagées ne doivent jamais être versées dans les égouts.',
  '1 litre d\'huile de moteur peut contaminer 1 million de litres d\'eau.',
  'Les médicaments périmés doivent être rapportés en pharmacie, jamais dans les toilettes.',
  'Le bois traité (vernis, peint) ne peut pas être composté ni brûlé sans filtres.',
  'Les magazines glacés (papier couché) sont plus difficiles à recycler que le papier ordinaire.',
  'L\'impression recto-verso économise 50 % de papier.',
  'Un foyer marocain jette en moyenne 30 % de sa nourriture achetée.',
  'La fast fashion produit 20 % de la pollution des eaux mondiales.',
  'Réparer plutôt que remplacer réduit de 80 % l\'empreinte carbone d\'un appareil.',
  'Acheter en vrac élimine jusqu\'à 40 % des emballages plastiques.',
  'Un sac en toile doit être utilisé au moins 50 fois pour compenser son impact de production.',
  'Le recyclage d\'une tonne de plastique évite l\'émission de 1,5 tonne de CO₂.',
  'Les décharges sauvages coûtent 3 × plus cher à nettoyer qu\'une collecte organisée.',
  '76 000 tonnes de plastique entrent dans la Méditerranée chaque année.',
  'Marrakech a recyclé 15 000 tonnes de déchets en 2022, une première pour le Maroc.',
  'Le tri sélectif est un geste citoyen qui bénéficie à toute la planète.',
  'Chaque canette recyclée économise assez d\'énergie pour alimenter une TV pendant 3 heures.',
  'Le papier d\'aluminium peut être recyclé avec les métaux si bien nettoyé.',
];

String get _todayFact {
  final dayIndex = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  return _kEcoFacts[dayIndex % _kEcoFacts.length];
}

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _categories = ['all', 'nature', 'coupons', 'donations', 'digital'];

  static const _rewards = [
    // ── Nature ─────────────────────────────────────────────────────────────
    _RewardData(
      id: 'r1',
      title: 'Planter un arbre',
      titleEn: 'Plant a tree',
      titleAr: 'زراعة شجرة',
      desc: 'Un arbre planté en votre nom au Maroc',
      descEn: 'A tree planted in your name in Morocco',
      descAr: 'شجرة تُزرع باسمك في المغرب',
      category: 'nature',
      cost: 500,
      icon: '🌳',
      color: AppColors.primary,
      redeemed: false,
    ),
    _RewardData(
      id: 'r2',
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
      id: 'r3',
      title: 'Adopter un corail',
      titleEn: 'Adopt a coral',
      titleAr: 'تبنَّ مرجانة',
      desc: 'Financez la restauration d\'un corail en Méditerranée',
      descEn: 'Fund the restoration of a coral in the Mediterranean',
      descAr: 'موّل استعادة مرجانة في البحر الأبيض المتوسط',
      category: 'nature',
      cost: 600,
      icon: '🪸',
      color: Color(0xFFFF6B6B),
      redeemed: false,
    ),
    _RewardData(
      id: 'r4',
      title: 'Sauvegarder 1 m² forêt',
      titleEn: 'Save 1 m² of forest',
      titleAr: 'أنقذ 1 م² من الغابة',
      desc: 'Préservez 1 m² de forêt marocaine menacée',
      descEn: 'Preserve 1 m² of threatened Moroccan forest',
      descAr: 'احمِ 1 متر مربع من الغابات المغربية المهددة',
      category: 'nature',
      cost: 450,
      icon: '🌲',
      color: Color(0xFF2E7D32),
      redeemed: false,
    ),
    _RewardData(
      id: 'r5',
      title: 'Planter des fleurs sauvages',
      titleEn: 'Plant wildflowers',
      titleAr: 'ازرع أزهارًا برية',
      desc: 'Un sachet de graines de fleurs sauvages locales offert',
      descEn: 'A packet of local wildflower seeds offered',
      descAr: 'كيس بذور زهور برية محلية مُهدى إليك',
      category: 'nature',
      cost: 250,
      icon: '🌸',
      color: Color(0xFFE91E63),
      redeemed: false,
    ),
    _RewardData(
      id: 'r6',
      title: 'Composteur de balcon',
      titleEn: 'Balcony composter',
      titleAr: 'سماد الشرفة',
      desc: 'Recevez un mini-composteur adapté aux appartements',
      descEn: 'Receive a mini-composter suited for apartments',
      descAr: 'احصل على سماد صغير مناسب للشقق',
      category: 'nature',
      cost: 1000,
      icon: '♻️',
      color: Color(0xFF795548),
      redeemed: false,
    ),
    // ── Coupons ────────────────────────────────────────────────────────────
    _RewardData(
      id: 'r7',
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
      id: 'r8',
      title: '15% sur BioMarché',
      titleEn: '15% off BioMarché',
      titleAr: '15% خصم على BioMarché',
      desc: 'Réduction sur votre prochain achat bio',
      descEn: 'Discount on your next organic purchase',
      descAr: 'خصم على مشترياتك العضوية القادمة',
      category: 'coupons',
      cost: 400,
      icon: '🥬',
      color: AppColors.primary,
      redeemed: false,
    ),
    _RewardData(
      id: 'r9',
      title: 'Livraison gratuite',
      titleEn: 'Free delivery',
      titleAr: 'توصيل مجاني',
      desc: 'Livraison offerte sur votre commande Naturalia',
      descEn: 'Free delivery on your Naturalia order',
      descAr: 'توصيل مجاني لطلبك من Naturalia',
      category: 'coupons',
      cost: 200,
      icon: '🚚',
      color: Color(0xFF1ABC9C),
      redeemed: false,
    ),
    _RewardData(
      id: 'r10',
      title: '-20% Aswak Assalam',
      titleEn: '-20% Aswak Assalam',
      titleAr: '-20% عند عسواق السلام',
      desc: 'Bon de réduction sur les produits éco-responsables',
      descEn: 'Discount voucher on eco-responsible products',
      descAr: 'قسيمة خصم على المنتجات الصديقة للبيئة',
      category: 'coupons',
      cost: 500,
      icon: '🛒',
      color: Color(0xFF3498DB),
      redeemed: false,
    ),
    _RewardData(
      id: 'r11',
      title: 'Code promo Decathlon',
      titleEn: 'Decathlon promo code',
      titleAr: 'رمز ترويجي Decathlon',
      desc: '10% sur les articles de sport durables Decathlon',
      descEn: '10% off sustainable Decathlon sports items',
      descAr: '10% خصم على المستلزمات الرياضية المستدامة من Decathlon',
      category: 'coupons',
      cost: 350,
      icon: '🏕️',
      color: Color(0xFF0288D1),
      redeemed: false,
    ),
    // ── Donations ──────────────────────────────────────────────────────────
    _RewardData(
      id: 'r12',
      title: 'Don WWF Maroc',
      titleEn: 'WWF Morocco donation',
      titleAr: 'تبرع لـ WWF المغرب',
      desc: '200 MAD reversés au WWF Maroc pour la nature',
      descEn: '200 MAD donated to WWF Morocco for nature',
      descAr: '200 درهم تُتبرع بها لـ WWF المغرب من أجل الطبيعة',
      category: 'donations',
      cost: 400,
      icon: '🐻',
      color: Color(0xFF9B59B6),
      redeemed: false,
    ),
    _RewardData(
      id: 'r13',
      title: 'Don SOS Forêts Maroc',
      titleEn: 'SOS Forests Morocco donation',
      titleAr: 'تبرع لـ SOS غابات المغرب',
      desc: 'Aidez à replanter les forêts détruites par les incendies',
      descEn: 'Help replant forests destroyed by wildfires',
      descAr: 'ساعد في إعادة تشجير الغابات المدمرة بالحرائق',
      category: 'donations',
      cost: 300,
      icon: '🌳',
      color: Color(0xFF2E7D32),
      redeemed: false,
    ),
    _RewardData(
      id: 'r14',
      title: 'Don Greenpeace Afrique',
      titleEn: 'Greenpeace Africa donation',
      titleAr: 'تبرع لـ Greenpeace إفريقيا',
      desc: '500 MAD reversés à Greenpeace Afrique du Nord',
      descEn: '500 MAD donated to Greenpeace North Africa',
      descAr: '500 درهم تُتبرع بها لـ Greenpeace شمال إفريقيا',
      category: 'donations',
      cost: 500,
      icon: '🌱',
      color: AppColors.primary,
      redeemed: false,
    ),
    _RewardData(
      id: 'r15',
      title: 'Adopter un animal en danger',
      titleEn: 'Adopt an endangered animal',
      titleAr: 'تبنَّ حيوانًا مهددًا بالانقراض',
      desc: 'Parrainer symboliquement un guépard du Sahara',
      descEn: 'Symbolically sponsor a Saharan cheetah',
      descAr: 'رعاية رمزية لفهد الصحراء المهدد بالانقراض',
      category: 'donations',
      cost: 700,
      icon: '🦁',
      color: Color(0xFFFF8F00),
      redeemed: false,
    ),
    // ── Digital ────────────────────────────────────────────────────────────
    _RewardData(
      id: 'r16',
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
      id: 'r17',
      title: "Fond d'écran exclusif",
      titleEn: 'Exclusive wallpaper',
      titleAr: 'خلفية حصرية',
      desc: "Pack de fonds d'écran éco-thème",
      descEn: 'Eco-themed wallpaper pack',
      descAr: 'حزمة خلفيات ذات طابع بيئي',
      category: 'digital',
      cost: 100,
      icon: '🖼️',
      color: AppColors.info,
      redeemed: false,
    ),
    _RewardData(
      id: 'r18',
      title: 'Badge Éco-Guerrier',
      titleEn: 'Eco-Warrior Badge',
      titleAr: 'شارة المحارب البيئي',
      desc: 'Affichez votre titre de défenseur de la nature',
      descEn: 'Display your nature defender title',
      descAr: 'اعرض لقب المدافع عن الطبيعة',
      category: 'digital',
      cost: 250,
      icon: '⚔️',
      color: Color(0xFFFF6B35),
      redeemed: false,
    ),
    _RewardData(
      id: 'r19',
      title: 'Cadre photo profil Vert',
      titleEn: 'Green profile frame',
      titleAr: 'إطار صورة أخضر',
      desc: 'Cadre animé feuilles vertes pour votre avatar',
      descEn: 'Animated green leaf frame for your avatar',
      descAr: 'إطار متحرك بأوراق خضراء لصورتك الشخصية',
      category: 'digital',
      cost: 80,
      icon: '🍃',
      color: AppColors.primary,
      redeemed: false,
    ),
    _RewardData(
      id: 'r20',
      title: 'Pack stickers éco',
      titleEn: 'Eco sticker pack',
      titleAr: 'حزمة ملصقات بيئية',
      desc: '20 stickers exclusifs sur le thème du recyclage',
      descEn: '20 exclusive recycling-themed stickers',
      descAr: '20 ملصقًا حصريًا بموضوع إعادة التدوير',
      category: 'digital',
      cost: 120,
      icon: '🌿',
      color: AppColors.teal,
      redeemed: false,
    ),
    _RewardData(
      id: 'r21',
      title: 'Titre "Expert Recycleur"',
      titleEn: '"Recycling Expert" title',
      titleAr: 'لقب "خبير إعادة التدوير"',
      desc: 'Affichez ce titre prestigieux sur votre profil',
      descEn: 'Display this prestigious title on your profile',
      descAr: 'اعرض هذا اللقب المرموق على ملفك الشخصي',
      category: 'digital',
      cost: 350,
      icon: '🏆',
      color: Color(0xFFFFD700),
      redeemed: false,
    ),
    _RewardData(
      id: 'r22',
      title: 'Avatar Arbre de vie',
      titleEn: 'Tree of Life avatar',
      titleAr: 'صورة شجرة الحياة',
      desc: 'Avatar animé personnalisé en forme d\'arbre majestueux',
      descEn: 'Animated custom avatar shaped as a majestic tree',
      descAr: 'صورة متحركة مخصصة على شكل شجرة رائعة',
      category: 'digital',
      cost: 200,
      icon: '🌳',
      color: Color(0xFF2E7D32),
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

  void _showRedeemDialog(BuildContext ctx, _RewardData reward, AppStrings s, int balance, Set<String> redeemed) {
    final lang = ref.read(localeProvider).languageCode;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _RedeemSheet(
        reward: reward,
        balance: balance,
        lang: lang,
        s: s,
        isRedeemed: redeemed.contains(reward.id),
        onRedeem: () async {
          final ok = await ref.read(rewardsProvider.notifier).redeem(reward.id, reward.cost);
          if (ok && ctx.mounted) {
            Navigator.pop(ctx);
            NotificationService.showNewRewardUnlocked(reward.title);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balance = ref.watch(userProvider).points;
    final redeemed = ref.watch(rewardsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(s, isDark, lang),
            _buildBalanceCard(s, isDark, balance),
            _buildTabBar(s, isDark),
            Expanded(
              child: _buildContent(isDark, lang, s, balance, redeemed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppStrings s, bool isDark, String lang) {
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

  Widget _buildBalanceCard(AppStrings s, bool isDark, int balance) {
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
                    tween: IntTween(begin: 0, end: balance),
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
              .map((c) => Tab(child: Text(labels[c] ?? c)))
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

  Widget _buildContent(bool isDark, String lang, AppStrings s, int balance, Set<String> redeemed) {
    final items = _filtered;
    return CustomScrollView(
      slivers: [
        // "Le saviez-vous?" daily fact card (visible only in "all" tab)
        if (_activeCategory == 'all')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _DailyFactCard(isDark: isDark),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _RewardCard(
                reward: items[i],
                isDark: isDark,
                lang: lang,
                balance: balance,
                delay: i * 80,
                isRedeemed: redeemed.contains(items[i].id),
                onTap: () => _showRedeemDialog(ctx, items[i], s, balance, redeemed),
              ),
              childCount: items.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Daily fact card ───────────────────────────────────────────────────────────
class _DailyFactCard extends StatelessWidget {
  final bool isDark;
  const _DailyFactCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fact = _todayFact;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1ABC9C), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('💡', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Le saviez-vous ?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fact,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.05);
  }
}

class _RewardCard extends StatefulWidget {
  final _RewardData reward;
  final bool isDark;
  final String lang;
  final int balance;
  final int delay;
  final bool isRedeemed;
  final VoidCallback onTap;

  const _RewardCard({
    required this.reward,
    required this.isDark,
    required this.lang,
    required this.balance,
    required this.delay,
    required this.isRedeemed,
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
            border: widget.isRedeemed
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
                  if (widget.isRedeemed)
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
                      color: _canAfford && !widget.isRedeemed
                          ? widget.reward.color
                          : AppColors.textSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _canAfford && !widget.isRedeemed
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
  final bool isRedeemed;
  final VoidCallback onRedeem;

  const _RedeemSheet({
    required this.reward,
    required this.balance,
    required this.lang,
    required this.s,
    required this.isRedeemed,
    required this.onRedeem,
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
              onPressed: _canAfford && !isRedeemed ? onRedeem : null,
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
                isRedeemed
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
