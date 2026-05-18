import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _selectedCat = 0;
  late TabController _tabCtrl;

  static const _categories = [
    _Cat('Tous',         Icons.category_rounded,              AppColors.primary),
    _Cat('Plastique',    Icons.opacity_rounded,               AppColors.plastic),
    _Cat('Papier',       Icons.article_outlined,              AppColors.paper),
    _Cat('Verre',        Icons.local_bar_outlined,            AppColors.glass),
    _Cat('Métal',        Icons.hardware_rounded,              AppColors.metal),
    _Cat('Organique',    Icons.compost_rounded,               Color(0xFF795548)),
    _Cat('Électronique', Icons.electrical_services_rounded,   AppColors.electronics),
    _Cat('Dangereux',    Icons.warning_amber_rounded,         Color(0xFFE74C3C)),
    _Cat('Textile',      Icons.checkroom_rounded,             Color(0xFF9B59B6)),
  ];

  static const _items = [
    // ── Plastique ──────────────────────────────────────────────────────────
    _Item('Bouteille PET (eau, soda)', 'Plastique', true,  'Bac jaune',     Icons.opacity_rounded,         AppColors.plastic,
        'Rincer avant de jeter. Écraser pour réduire le volume. Ne pas laisser le bouchon dessus.'),
    _Item('Bouteille PEHD (lait, shampoing)', 'Plastique', true,  'Bac jaune', Icons.opacity_rounded,      AppColors.plastic,
        'Vider et rincer. Le bouchon peut rester si vissé. Écraser.'),
    _Item('Barquette alimentaire',    'Plastique', true,  'Bac jaune',     Icons.takeout_dining_rounded,   AppColors.plastic,
        'Rincer si possible. Éviter les barquettes très sales.'),
    _Item('Sac plastique',           'Plastique', false, 'Borne dédiée',  Icons.shopping_bag_outlined,    AppColors.plastic,
        'Ne pas mettre dans le bac jaune ! Déposer dans les bornes spéciales en supermarché.'),
    _Item('Film plastique / Sachet',  'Plastique', false, 'Poubelle ordinaire', Icons.wrap_text_rounded,  AppColors.plastic,
        'Les films souples ne sont généralement pas collectés en bac jaune. Vérifier localement.'),
    _Item('Polystyrène (emballage)',  'Plastique', false, 'Déchetterie',   Icons.view_in_ar_rounded,      AppColors.plastic,
        'Très difficile à recycler. Déchetterie ou point de collecte spécifique.'),
    _Item('Tube dentifrice',         'Plastique', false, 'Poubelle ordinaire', Icons.water_drop_rounded, AppColors.plastic,
        'Difficile à recycler à cause des résidus. Poubelle ordinaire.'),
    _Item('Pot de yaourt',           'Plastique', true,  'Bac jaune',     Icons.icecream_rounded,        AppColors.plastic,
        'Rincer rapidement. Accepté dans la plupart des bacs jaunes.'),

    // ── Papier ─────────────────────────────────────────────────────────────
    _Item('Journal / Magazine',      'Papier', true,  'Bac bleu',        Icons.article_outlined,         AppColors.paper,
        'Plier ou empiler. Ne pas mouiller. Retirer les parties plastifiées si possible.'),
    _Item('Carton ondulé',           'Papier', true,  'Bac bleu',        Icons.inventory_2_rounded,      AppColors.paper,
        'Aplatir avant de mettre dans le bac. Enlever les agrafes et scotch.'),
    _Item('Boîte en carton (céréales)', 'Papier', true, 'Bac bleu',      Icons.breakfast_dining_rounded, AppColors.paper,
        'Aplatir et retirer les sachets intérieurs plastiques.'),
    _Item('Carton de pizza (propre)', 'Papier', true,  'Bac bleu',       Icons.local_pizza_rounded,      AppColors.paper,
        'Seulement si propre ! Si gras ou souillé → composteur ou poubelle ordinaire.'),
    _Item('Papier d\'emballage cadeau','Papier', false,'Poubelle ordinaire',Icons.card_giftcard_rounded,  AppColors.paper,
        'Souvent plastifié ou pailleté → non recyclable. Préférer du papier kraft.'),
    _Item('Papier cuisson / alu',    'Papier', false, 'Poubelle ordinaire', Icons.kitchen_rounded,       AppColors.paper,
        'Le papier cuisson est siliconé, non recyclable. L\'alu va dans le bac métal.'),
    _Item('Ticket de caisse',        'Papier', false, 'Poubelle ordinaire', Icons.receipt_rounded,       AppColors.paper,
        'Contient du bisphénol A (BPA), contamine les autres papiers. Poubelle.'),
    _Item('Enveloppe avec fenêtre',  'Papier', true,  'Bac bleu',        Icons.mail_outlined,            AppColors.paper,
        'La fenêtre plastique est acceptable. Retirer les autocollants si possible.'),

    // ── Verre ──────────────────────────────────────────────────────────────
    _Item('Bouteille en verre',      'Verre', true,  'Conteneur vert',  Icons.local_bar_outlined,        AppColors.glass,
        'Rincer. Ne pas casser. Le bouchon métallique peut rester. Ne pas emballer.'),
    _Item('Bocal en verre (confiture)', 'Verre', true, 'Conteneur vert', Icons.lunch_dining_rounded,     AppColors.glass,
        'Rincer. Le couvercle métallique peut être séparé pour le bac métal.'),
    _Item('Flacon de parfum',        'Verre', true,  'Conteneur vert',  Icons.spa_rounded,               AppColors.glass,
        'Vider complètement. Enlever la pompe plastique si possible.'),
    _Item('Verre brisé / Miroir',    'Verre', false, 'Déchetterie',     Icons.broken_image_rounded,      AppColors.glass,
        'DANGER ! Envelopper dans du carton épais avant déchetterie. Ne jamais mettre dans le conteneur.'),
    _Item('Verre réfractaire (Pyrex)','Verre', false, 'Déchetterie',    Icons.microwave_rounded,         AppColors.glass,
        'Composition différente du verre ordinaire → ne pas mélanger.'),
    _Item('Ampoule LED / fluocompacte','Verre', false,'Point luminaire', Icons.lightbulb_outlined,        AppColors.glass,
        'Déposer dans les points de collecte luminaires (magasins bricolage).'),

    // ── Métal ──────────────────────────────────────────────────────────────
    _Item('Canette aluminium',       'Métal', true,  'Bac jaune',       Icons.sports_bar_rounded,        AppColors.metal,
        'Écraser pour réduire le volume. L\'un des matériaux les plus rentables à recycler.'),
    _Item('Boîte de conserve',       'Métal', true,  'Bac jaune',       Icons.inventory_rounded,         AppColors.metal,
        'Rincer. Le couvercle peut rester dedans (replier pour éviter les coupures).'),
    _Item('Capsule café aluminium',  'Métal', false, 'Point collecte',  Icons.coffee_rounded,            AppColors.metal,
        'Programmes de reprise en magasins (Nespresso, etc.) ou points de collecte dédiés.'),
    _Item('Aérosol (déodorant vide)', 'Métal', true, 'Bac jaune',      Icons.air_rounded,               AppColors.metal,
        'Doit être VIDE et dégazé. Ne jamais percer. Laisser le bouchon plastique.'),
    _Item('Papier aluminium',        'Métal', true,  'Bac jaune',       Icons.layers_rounded,            AppColors.metal,
        'Froisser en boule pour faciliter le tri. Si souillé de nourriture, poubelle.'),
    _Item('Tuyau / Ferraille',       'Métal', true,  'Déchetterie',     Icons.plumbing_rounded,          AppColors.metal,
        'Déchetterie, zone métaux. Récupéré et refondu.'),

    // ── Organique ──────────────────────────────────────────────────────────
    _Item('Épluchures de légumes',   'Organique', true, 'Composteur',   Icons.eco_rounded,               Color(0xFF795548),
        'Idéal pour le compost maison ou le bac à compost communautaire.'),
    _Item('Marc de café / Sachets thé','Organique', true,'Composteur',  Icons.coffee_rounded,            Color(0xFF795548),
        'Excellent activateur de compost. Enlever les agrafes des sachets thé.'),
    _Item('Restes de pain',          'Organique', true, 'Composteur',   Icons.breakfast_dining_rounded,  Color(0xFF795548),
        'En petits morceaux pour accélérer la décomposition.'),
    _Item('Coquilles d\'œuf',        'Organique', true, 'Composteur',   Icons.egg_outlined,              Color(0xFF795548),
        'Écraser avant de mettre au compost. Apportent du calcium.'),
    _Item('Restes de viande / poisson','Organique', false,'Poubelle ordinaire',Icons.set_meal_rounded,   Color(0xFF795548),
        'Attire les nuisibles dans un compost ouvert. Poubelle ordinaire ou composteur fermé.'),
    _Item('Gazon / Feuilles mortes', 'Organique', true, 'Composteur',   Icons.grass_rounded,             Color(0xFF795548),
        'Excellent pour le compost. Mélanger vert (azote) et sec (carbone).'),

    // ── Électronique ───────────────────────────────────────────────────────
    _Item('Téléphone portable',      'Électronique', false,'Point e-déchet', Icons.phone_android_rounded, AppColors.electronics,
        'Déposer en magasin (obligation légale de reprise). Contient métaux rares précieux.'),
    _Item('Ordinateur / Tablette',   'Électronique', false,'Déchetterie', Icons.laptop_rounded,          AppColors.electronics,
        'Zone DEEE de la déchetterie. Effacer les données avant dépôt.'),
    _Item('Pile / Batterie',         'Électronique', false,'Collecteur piles', Icons.battery_full_rounded, AppColors.electronics,
        'JAMAIS à la poubelle ! Collecteurs en supermarché, pharmacie, mairie.'),
    _Item('Chargeur / Câble USB',    'Électronique', false,'Point e-déchet', Icons.cable_rounded,        AppColors.electronics,
        'Dépôt en magasin électronique ou déchetterie DEEE.'),
    _Item('Ampoule classique',       'Électronique', false,'Point luminaire',Icons.lightbulb_rounded,    AppColors.electronics,
        'Points de collecte en grande surface bricolage ou déchetterie.'),
    _Item('Télévision / Écran',      'Électronique', false,'Déchetterie', Icons.tv_rounded,              AppColors.electronics,
        'Déchetterie DEEE. Possibilité de reprise par le vendeur à l\'achat d\'un neuf.'),
    _Item('Réfrigérateur / Lave-linge','Électronique', false,'Déchetterie',Icons.kitchen_rounded,       AppColors.electronics,
        'Gros électroménager : déchetterie ou reprise 1 pour 1 par le vendeur.'),

    // ── Dangereux ──────────────────────────────────────────────────────────
    _Item('Médicaments périmés',     'Dangereux', false,'Pharmacie',    Icons.medication_rounded,        Color(0xFFE74C3C),
        'JAMAIS à la poubelle ni dans les égouts ! Déposer en pharmacie (collecte Cyclamed).'),
    _Item('Peinture / Solvant',      'Dangereux', false,'Déchetterie',  Icons.format_paint_rounded,      Color(0xFFE74C3C),
        'Zone produits dangereux de la déchetterie. Garder dans le contenant d\'origine.'),
    _Item('Huile moteur usagée',     'Dangereux', false,'Garage / Déchetterie',Icons.oil_barrel_rounded, Color(0xFFE74C3C),
        'Ne jamais verser dans les égouts. Déposer chez un garagiste ou en déchetterie.'),
    _Item('Produits chimiques ménagers','Dangereux', false,'Déchetterie',Icons.science_rounded,          Color(0xFFE74C3C),
        'Zone produits dangereux. Conserver dans emballage d\'origine avec étiquette.'),
    _Item('Seringues / Piquants',    'Dangereux', false,'Collecteur spécial',Icons.vaccines_rounded,     Color(0xFFE74C3C),
        'Boîtes DASRI disponibles en pharmacie. Ne jamais mettre dans la poubelle ordinaire.'),
    _Item('Extincteur',              'Dangereux', false,'Déchetterie',  Icons.fire_extinguisher_rounded, Color(0xFFE74C3C),
        'Zone déchets dangereux. Certains professionnels assurent la reprise.'),

    // ── Textile ────────────────────────────────────────────────────────────
    _Item('Vêtements en bon état',   'Textile', false,'Borne textile',  Icons.checkroom_rounded,         Color(0xFF9B59B6),
        'Don via bornes de collecte (Le Relais, Emmaüs, Croix-Rouge). Mettre dans un sac propre.'),
    _Item('Vêtements abîmés',        'Textile', false,'Borne textile',  Icons.checkroom_rounded,         Color(0xFF9B59B6),
        'Même abîmés, ils sont recyclés en chiffons industriels ou isolants. Ne pas jeter !'),
    _Item('Chaussures',              'Textile', false,'Borne textile',  Icons.directions_run_rounded,    Color(0xFF9B59B6),
        'Par paires. Mettre dans un sac. Même usées, elles sont valorisées.'),
    _Item('Linge de maison',         'Textile', false,'Borne textile',  Icons.bed_rounded,               Color(0xFF9B59B6),
        'Draps, serviettes, rideaux. Propres et secs. Borne textile ou ressourceries.'),
    _Item('Jouets en tissu / peluches','Textile', false,'Borne textile',Icons.toys_rounded,              Color(0xFF9B59B6),
        'Propres et secs. Associations caritatives ou bornes de collecte.'),
  ];

  List<_Item> get _filtered {
    final catName = _categories[_selectedCat].name;
    return _items.where((item) {
      final matchCat = catName == 'Tous' || item.category == catName;
      final matchQ = _query.isEmpty ||
          item.name.toLowerCase().contains(_query.toLowerCase()) ||
          item.category.toLowerCase().contains(_query.toLowerCase()) ||
          item.tip.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guide de Tri',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Triez mieux, recyclez plus',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_items.length} déchets',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                    const SizedBox(height: 14),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un déchet...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.white.withValues(alpha: 0.8)),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: Icon(Icons.close_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.8)),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 14),
                    // Tabs
                    TabBar(
                      controller: _tabCtrl,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13),
                      tabs: const [
                        Tab(text: 'Déchets'),
                        Tab(text: 'Consignes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category chips (only for Déchets tab) ────────────────────────
          if (_tabCtrl.index == 0)
            Container(
              color: isDark ? AppColors.darkSurface : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final active = _selectedCat == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCat = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? cat.color
                              : (isDark
                                  ? AppColors.darkCard
                                  : AppColors.inputBg),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon,
                                size: 13,
                                color: active ? Colors.white : cat.color),
                            const SizedBox(width: 5),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: active
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkText
                                        : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Tab 1 — Items list
                filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.textLight
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            const Text(
                              'Aucun résultat trouvé',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _GuideCard(
                          item: filtered[i],
                          isDark: isDark,
                        )
                            .animate(delay: (i * 40).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.04),
                      ),

                // Tab 2 — Consignes
                _ConsignesTab(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guide Card with expandable tip ───────────────────────────────────────────

class _GuideCard extends StatefulWidget {
  final _Item item;
  final bool isDark;
  const _GuideCard({required this.item, required this.isDark});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: _expanded
              ? Border.all(color: item.color.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: item.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            item.recyclable
                                ? Icons.recycling_rounded
                                : Icons.block_rounded,
                            size: 12,
                            color: item.recyclable
                                ? AppColors.primary
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.recyclable ? 'Recyclable' : 'Non recyclable',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: item.recyclable
                                  ? AppColors.primary
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.bin,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: item.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates_rounded,
                        color: item.color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.tip,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Consignes Tab ─────────────────────────────────────────────────────────────

class _ConsignesTab extends StatelessWidget {
  final bool isDark;
  const _ConsignesTab({required this.isDark});

  static const _bins = [
    _Bin('Bac Jaune', 'Emballages recyclables',
        Color(0xFFF39C12),
        Icons.recycling_rounded,
        ['Bouteilles et flacons plastiques', 'Canettes et boîtes métal', 'Cartons d\'emballage', 'Briques alimentaires', 'Aérosols vides']),
    _Bin('Bac Bleu', 'Papiers et journaux',
        Color(0xFF3498DB),
        Icons.article_outlined,
        ['Journaux et magazines', 'Catalogues et prospectus', 'Enveloppes et papier bureau', 'Cahiers et livres', 'Boîtes en carton aplaties']),
    _Bin('Conteneur Vert', 'Verre uniquement',
        AppColors.glass,
        Icons.local_bar_outlined,
        ['Bouteilles en verre', 'Bocaux et pots en verre', 'Flacons en verre', 'Ne pas mettre : miroirs, verre trempé']),
    _Bin('Bac Gris/Noir', 'Poubelle ordinaire',
        Color(0xFF607D8B),
        Icons.delete_outline_rounded,
        ['Restes alimentaires (sans compost)', 'Emballages souillés', 'Papier gras ou plastifié', 'Litière animale', 'Mouchoirs usagés']),
    _Bin('Composteur', 'Déchets organiques',
        Color(0xFF795548),
        Icons.compost_rounded,
        ['Épluchures de fruits et légumes', 'Marc de café et sachets de thé', 'Coquilles d\'œuf', 'Gazon et feuilles mortes', 'Pain et pâtes (sans sauce)']),
    _Bin('Déchetterie', 'Déchets spéciaux',
        Color(0xFF9B59B6),
        Icons.location_on_rounded,
        ['Peintures et solvants', 'Huiles usagées', 'Gros appareils électroniques', 'Meubles et encombrants', 'Gravats et déchets verts']),
  ];

  static const _rules = [
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Vider et rincer',
        'Rincez légèrement les emballages pour éviter les odeurs et la contamination des autres recyclables.'),
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Ne pas écraser le verre',
        'Le verre doit rester intact pour être recyclé. Ne jamais le mettre dans un sac plastique.'),
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Pas de sacs plastiques dans le bac jaune',
        'Les sacs plastiques bloquent les machines de tri. Déposer dans les bornes dédiées.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Pas d\'emballages souillés',
        'Un emballage très sale (huile, sauce) contamine tout le lot. Poubelle ordinaire si très sale.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Jamais de piles ou médicaments',
        'Ces produits dangereux ont des filières dédiées. Pharmacie pour les médicaments, collecteurs pour les piles.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Pas de déchets dangereux',
        'Produits chimiques, peintures, solvants = déchetterie zone produits dangereux uniquement.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Bacs section
        _SectionHeader('Les bacs de tri', Icons.delete_sweep_rounded, isDark),
        const SizedBox(height: 12),
        ...List.generate(_bins.length, (i) =>
          _BinCard(bin: _bins[i], isDark: isDark)
              .animate(delay: (i * 60).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05),
        ),
        const SizedBox(height: 24),

        // Rules section
        _SectionHeader('Règles d\'or du tri', Icons.star_rounded, isDark),
        const SizedBox(height: 12),
        ...List.generate(_rules.length, (i) =>
          _RuleCard(rule: _rules[i], isDark: isDark)
              .animate(delay: (i * 60).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05),
        ),
        const SizedBox(height: 24),

        // Eco tip card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Le saviez-vous ?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Recycler 1 tonne d\'aluminium économise 95% d\'énergie par rapport à la production primaire.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  const _SectionHeader(this.title, this.icon, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BinCard extends StatelessWidget {
  final _Bin bin;
  final bool isDark;
  const _BinCard({required this.bin, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bin.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 8,
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
                  color: bin.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(bin.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bin.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      bin.subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: bin.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bin.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: 8, top: 1),
                      decoration: BoxDecoration(
                        color: bin.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final _Rule rule;
  final bool isDark;
  const _RuleCard({required this.rule, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(rule.icon, color: rule.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rule.desc,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _Cat {
  final String name;
  final IconData icon;
  final Color color;
  const _Cat(this.name, this.icon, this.color);
}

class _Item {
  final String name;
  final String category;
  final bool recyclable;
  final String bin;
  final IconData icon;
  final Color color;
  final String tip;
  const _Item(this.name, this.category, this.recyclable, this.bin,
      this.icon, this.color, this.tip);
}

class _Bin {
  final String name;
  final String subtitle;
  final Color color;
  final IconData icon;
  final List<String> items;
  const _Bin(this.name, this.subtitle, this.color, this.icon, this.items);
}

class _Rule {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _Rule(this.icon, this.color, this.title, this.desc);
}
