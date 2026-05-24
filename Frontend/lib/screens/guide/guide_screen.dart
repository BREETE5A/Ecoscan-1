import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _selectedCat = 0;
  late TabController _tabCtrl;

  static const _categories = [
    _Cat('Tous',         Icons.category_rounded,            AppColors.primary),
    _Cat('Plastique',    Icons.opacity_rounded,             AppColors.plastic),
    _Cat('Papier',       Icons.article_outlined,            AppColors.paper),
    _Cat('Verre',        Icons.local_bar_outlined,          AppColors.glass),
    _Cat('Métal',        Icons.hardware_rounded,            AppColors.metal),
    _Cat('Organique',    Icons.compost_rounded,             Color(0xFF795548)),
    _Cat('Électronique', Icons.electrical_services_rounded, AppColors.electronics),
    _Cat('Dangereux',    Icons.warning_amber_rounded,       Color(0xFFE74C3C)),
    _Cat('Textile',      Icons.checkroom_rounded,           Color(0xFF9B59B6)),
  ];

  // status: 'OUI' | 'NON' | 'COLLECTE SPÉCIALE' | 'INTERDIT'
  static const _items = [

    // ── MÉTAL ────────────────────────────────────────────────────────────────
    _Item('Canette aluminium (Coca-Cola, Pepsi, Fanta)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.sports_bar_rounded, AppColors.metal,
        'Écraser pour réduire le volume. Rincer. L\'alu est recyclé à l\'infini — 8kg CO₂ économisés/kg. Casablanca : bacs orange ECOVAL.',
        nameEn: 'Aluminum can (Coca-Cola, Pepsi, Fanta)', nameAr: 'علبة ألمنيوم (كوكا كولا، بيبسي، فانتا)', nameEs: 'Lata de aluminio (Coca-Cola, Pepsi, Fanta)',
        tipEn: 'Crush to reduce volume. Rinse. Aluminium is infinitely recyclable — saves 8 kg CO₂/kg. Casablanca: orange ECOVAL bins.'),
    _Item('Boîte conserve acier (Aïcha, Diamanor)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.inventory_rounded, AppColors.metal,
        'Rincer. Le couvercle peut rester (replier les bords). Accepté dans tous les bacs jaunes ECOVAL au Maroc.',
        nameEn: 'Steel food can (Aïcha, Diamanor)', nameAr: 'علبة فولاذية (عائشة، ديامانور)', nameEs: 'Lata de conserva de acero (Aïcha, Diamanor)',
        tipEn: 'Rinse. The lid can stay (fold the edges). Accepted in all ECOVAL yellow bins in Morocco.'),
    _Item('Capsule métallique (bouteille, bocal)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.radio_button_unchecked_rounded, AppColors.metal,
        'Petites capsules : glisser dans une boîte conserve vide avant de fermer. Évite qu\'elles tombent dans les machines de tri.',
        nameEn: 'Metal cap (bottle, jar)', nameAr: 'غطاء معدني (زجاجة، برطمان)', nameEs: 'Cápsula metálica (botella, tarro)',
        tipEn: 'Small caps: slip into an empty can before closing. Prevents them from falling into sorting machines.'),
    _Item('Barquette aluminium (cuisine, tajine)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.takeout_dining_rounded, AppColors.metal,
        'Rincer si possible. Même légèrement souillée, elle reste recyclable. Écraser en boule.',
        nameEn: 'Aluminum tray (cooking, tajine)', nameAr: 'صينية ألمنيوم (للطبخ، طاجين)', nameEs: 'Bandeja de aluminio (cocina, tajine)',
        tipEn: 'Rinse if possible. Even slightly soiled, still recyclable. Crush into a ball.'),
    _Item('Papier aluminium froissé en boule', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.layers_rounded, AppColors.metal,
        'Froisser en boule compacte (min 5cm) pour faciliter le tri mécanique. Si très souillé de nourriture → poubelle.',
        nameEn: 'Crumpled aluminum foil ball', nameAr: 'ورق ألمنيوم مجعّد على شكل كرة', nameEs: 'Papel de aluminio arrugado en bola',
        tipEn: 'Crumple into a compact ball (min 5 cm) to ease mechanical sorting. If heavily soiled with food → trash.'),
    _Item('Couvercle métallique (pot, bocal)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.circle_outlined, AppColors.metal,
        'Séparer du bocal en verre et mettre dans le bac jaune. Le bocal va dans la colonne verte.',
        nameEn: 'Metal lid (jar, pot)', nameAr: 'غطاء معدني (وعاء، برطمان)', nameEs: 'Tapa metálica (tarro, frasco)',
        tipEn: 'Separate from the glass jar and put in the yellow bin. The jar goes in the green column.'),
    _Item('Aérosol vide dégazé (déodorant, laque)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.air_rounded, AppColors.metal,
        'OBLIGATOIREMENT vide et dégazé (appuyer jusqu\'à silence). Ne jamais percer. Laisser le bouchon plastique.',
        nameEn: 'Empty deflated aerosol (deodorant, hairspray)', nameAr: 'بخاخ فارغ مفرّغ من الغاز (مزيل عرق، لاك)', nameEs: 'Aerosol vacío desgasificado (desodorante, laca)',
        tipEn: 'MUST be empty and deflated (press until silent). Never pierce. Leave the plastic cap on.'),
    _Item('Boîte biscuits métal (Bimo, LU)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.cookie_rounded, AppColors.metal,
        'Retirer les emballages papier intérieurs. Écraser si possible pour réduire le volume.',
        nameEn: 'Metal biscuit tin (Bimo, LU)', nameAr: 'علبة بسكويت معدنية (بيمو، لو)', nameEs: 'Lata de galletas (Bimo, LU)',
        tipEn: 'Remove inner paper wrappings. Crush if possible to reduce volume.'),
    _Item('Ferraille / Casserole acier usagée', 'Métal', 'OUI', 'Déchetterie — zone métal',
        Icons.plumbing_rounded, AppColors.metal,
        'Déchetterie (zone métaux) ou ferracha. Refondu et réutilisé dans la sidérurgie marocaine.',
        nameEn: 'Scrap metal / Used steel pan', nameAr: 'خردة / قدر فولاذي مستعمل', nameEs: 'Chatarra / Cazuela de acero usada',
        tipEn: 'Recycling center (metal zone) or ferracha. Remelted and reused in Moroccan steel industry.'),
    _Item('Pile alcaline (AA, AAA, 9V)', 'Métal', 'NON', 'Collecteur piles',
        Icons.battery_full_rounded, AppColors.metal,
        'JAMAIS au bac jaune ! Contient mercure, cadmium. Déposer dans les collecteurs en supermarché (Marjane, Carrefour, Label\'Vie).',
        nameEn: 'Alkaline battery (AA, AAA, 9V)', nameAr: 'بطارية قلوية (AA، AAA، 9V)', nameEs: 'Pila alcalina (AA, AAA, 9V)',
        tipEn: 'NEVER in the yellow bin! Contains mercury, cadmium. Drop off at supermarket collectors (Marjane, Carrefour, Label\'Vie).'),
    _Item('Aérosol non vide / sous pression', 'Métal', 'NON', 'Déchetterie — dangereux',
        Icons.dangerous_rounded, AppColors.metal,
        'Risque d\'explosion. Déchetterie zone produits dangereux. Ne jamais percer ni jeter à la poubelle ordinaire.',
        nameEn: 'Non-empty / pressurized aerosol', nameAr: 'بخاخ غير فارغ / تحت ضغط', nameEs: 'Aerosol no vacío / a presión',
        tipEn: 'Risk of explosion. Recycling center hazardous zone. Never pierce or throw in regular trash.'),
    _Item('Boîte peinture métal avec résidus', 'Métal', 'NON', 'Déchetterie — dangereux',
        Icons.format_paint_rounded, AppColors.metal,
        'Les résidus de peinture contaminent. Déchetterie zone produits dangereux. Si complètement sèche et vide → bac jaune.',
        nameEn: 'Metal paint can with residue', nameAr: 'علبة طلاء معدنية مع بقايا', nameEs: 'Lata de pintura metálica con residuos',
        tipEn: 'Paint residues contaminate. Recycling center hazardous zone. If completely dry and empty → yellow bin.'),

    // ── VERRE ─────────────────────────────────────────────────────────────────
    _Item('Bouteille verre (Sidi Ali, Ain Atlas, Oulmes)', 'Verre', 'OUI', 'Colonne verte',
        Icons.local_bar_outlined, AppColors.glass,
        'Rincer. Ne pas casser. Le bouchon métallique peut rester ou aller au bac jaune. Colonne verte = uniquement verre creux.',
        nameEn: 'Glass bottle (Sidi Ali, Ain Atlas, Oulmes)', nameAr: 'زجاجة زجاجية (سيدي علي، عين أطلس، أولمس)', nameEs: 'Botella de vidrio (Sidi Ali, Ain Atlas, Oulmes)',
        tipEn: 'Rinse. Do not break. Metal cap can stay or go in yellow bin. Green column = hollow glass only.'),
    _Item('Bocal confiture / conserve (Aïcha, Aicha)', 'Verre', 'OUI', 'Colonne verte',
        Icons.lunch_dining_rounded, AppColors.glass,
        'Rincer rapidement. Couvercle métallique → bac jaune. Bocal verre → colonne verte. Ne pas emballer dans un sac plastique.',
        nameEn: 'Jam / preserve jar (Aïcha)', nameAr: 'برطمان مربى / مربيات (عائشة)', nameEs: 'Tarro de mermelada / conserva (Aïcha)',
        tipEn: 'Quick rinse. Metal lid → yellow bin. Glass jar → green column. Do not wrap in a plastic bag.'),
    _Item('Pot bébé (Blédina, Nestlé Bébé)', 'Verre', 'OUI', 'Colonne verte',
        Icons.child_care_rounded, AppColors.glass,
        'Rincer. Très recyclable. Même les petits pots sont acceptés. Colonne verte des villes (Casablanca, Rabat, Marrakech).',
        nameEn: 'Baby food jar (Blédina, Nestlé Bébé)', nameAr: 'برطمان غذاء الأطفال (بليدينا، نستله بيبي)', nameEs: 'Tarro para bebé (Blédina, Nestlé Bébé)',
        tipEn: 'Rinse. Very recyclable. Even small jars are accepted. Green column in cities (Casablanca, Rabat, Marrakech).'),
    _Item('Flacon parfum en verre', 'Verre', 'OUI', 'Colonne verte',
        Icons.spa_rounded, AppColors.glass,
        'Vider complètement. Retirer la pompe plastique si possible (va à la poubelle ordinaire). Le verre → colonne verte.',
        nameEn: 'Glass perfume bottle', nameAr: 'قارورة عطر زجاجية', nameEs: 'Frasco de perfume de vidrio',
        tipEn: 'Empty completely. Remove the plastic pump if possible (goes in regular trash). Glass → green column.'),
    _Item('Carafe / vase en verre ordinaire', 'Verre', 'OUI', 'Colonne verte',
        Icons.local_drink_rounded, AppColors.glass,
        'Verre ordinaire recyclable. Ne pas confondre avec cristal (non recyclable). Déposer doucement pour éviter la casse.',
        nameEn: 'Glass carafe / vase', nameAr: 'إبريق / مزهرية زجاجية عادية', nameEs: 'Jarra / jarrón de vidrio ordinario',
        tipEn: 'Ordinary glass is recyclable. Do not confuse with crystal (not recyclable). Place gently to avoid breakage.'),
    _Item('Pot de miel en verre', 'Verre', 'OUI', 'Colonne verte',
        Icons.emoji_nature_rounded, AppColors.glass,
        'Rincer à l\'eau tiède pour décoller le miel. Couvercle métallique → bac jaune. Accepté dans toutes les colonnes vertes.',
        nameEn: 'Glass honey jar', nameAr: 'برطمان عسل زجاجي', nameEs: 'Tarro de miel de vidrio',
        tipEn: 'Rinse with warm water to dissolve honey. Metal lid → yellow bin. Accepted in all green columns.'),
    _Item('Verre brisé / cassé', 'Verre', 'NON', 'Déchetterie (carton épais)',
        Icons.broken_image_rounded, AppColors.glass,
        'DANGER : blesse les agents de tri. Envelopper dans du carton épais et du ruban adhésif. Jamais dans la colonne verte.',
        nameEn: 'Broken / shattered glass', nameAr: 'زجاج مكسور', nameEs: 'Vidrio roto / quebrado',
        tipEn: 'DANGER: injures sorting workers. Wrap in thick cardboard and tape. Never in the green column.'),
    _Item('Miroir', 'Verre', 'NON', 'Déchetterie',
        Icons.square_rounded, AppColors.glass,
        'Composition chimique différente du verre ordinaire (revêtement argenté). Non recyclable avec le verre. Déchetterie.',
        nameEn: 'Mirror', nameAr: 'مرآة', nameEs: 'Espejo',
        tipEn: 'Different chemical composition from ordinary glass (silver coating). Not recyclable with glass. Recycling center.'),
    _Item('Verre trempé (pare-brise, vitre auto)', 'Verre', 'NON', 'Déchetterie',
        Icons.directions_car_rounded, AppColors.glass,
        'Traitement thermique spécial incompatible avec le recyclage du verre ordinaire. Casse en miettes → contamination.',
        nameEn: 'Tempered glass (windshield, car window)', nameAr: 'زجاج مقسّى (زجاج سيارة)', nameEs: 'Vidrio templado (parabrisas, ventana de auto)',
        tipEn: 'Special heat treatment incompatible with ordinary glass recycling. Crumbles into tiny pieces → contamination.'),
    _Item('Pyrex / plat en verre réfractaire', 'Verre', 'NON', 'Déchetterie',
        Icons.microwave_rounded, AppColors.glass,
        'Borosilicate : point de fusion différent. Contamine le lot de verre recyclé. Déchetterie ou don si en bon état.',
        nameEn: 'Pyrex / heat-resistant glass dish', nameAr: 'باير / طبق زجاجي مقاوم للحرارة', nameEs: 'Pyrex / plato de vidrio refractario',
        tipEn: 'Borosilicate: different melting point. Contaminates recycled glass batch. Recycling center or donate if in good condition.'),
    _Item('Faïence / céramique / porcelaine', 'Verre', 'NON', 'Déchetterie',
        Icons.emoji_food_beverage_rounded, AppColors.glass,
        'Pas du verre ! Composition totalement différente. Déchetterie ou ressourcerie si intact. Jamais dans la colonne verte.',
        nameEn: 'Earthenware / ceramic / porcelain', nameAr: 'فخار / سيراميك / خزف', nameEs: 'Loza / cerámica / porcelana',
        tipEn: 'Not glass! Completely different composition. Recycling center or charity if intact. Never in the green column.'),
    _Item('Ampoule (toute technologie)', 'Verre', 'NON', 'Point luminaire',
        Icons.lightbulb_outlined, AppColors.glass,
        'Points de collecte luminaires : grandes surfaces bricolage (Bricoma, Mr. Bricolage), déchetterie. LED et fluocompactes = DEEE.',
        nameEn: 'Light bulb (any type)', nameAr: 'مصباح (أي نوع)', nameEs: 'Bombilla (cualquier tipo)',
        tipEn: 'Collection points: DIY stores (Bricoma, Mr. Bricolage), recycling center. LED and CFL = WEEE.'),

    // ── ORGANIQUE ─────────────────────────────────────────────────────────────
    _Item('Épluchures fruits et légumes', 'Organique', 'OUI', 'Composteur / Bac marron',
        Icons.eco_rounded, Color(0xFF795548),
        'Représente 65% des déchets marocains. Idéal pour compost maison (balcon ou jardin). Se décompose en 2-6 mois.',
        nameEn: 'Fruit and vegetable peels', nameAr: 'قشور الفواكه والخضروات', nameEs: 'Cáscaras de frutas y verduras',
        tipEn: 'Represents 65% of Moroccan waste. Ideal for home compost (balcony or garden). Decomposes in 2–6 months.'),
    _Item('Marc de café (Cafés Najjar, Bouskoura)', 'Organique', 'OUI', 'Composteur',
        Icons.coffee_rounded, Color(0xFF795548),
        'Excellent activateur de compost. Mélanger avec des matières sèches (feuilles mortes). Améliore la structure du sol.',
        nameEn: 'Coffee grounds (Najjar, Bouskoura)', nameAr: 'تفل القهوة (نجار، بوسكورة)', nameEs: 'Posos de café (Najjar, Bouskoura)',
        tipEn: 'Excellent compost activator. Mix with dry materials (dead leaves). Improves soil structure.'),
    _Item('Sachets thé usagés (Lipton, Atay Baraka)', 'Organique', 'OUI', 'Composteur',
        Icons.local_cafe_rounded, Color(0xFF795548),
        'Enlever les agrafes métalliques avant de composter. Certains sachets synthétiques (nylon) → poubelle ordinaire.',
        nameEn: 'Used tea bags (Lipton, Atay Baraka)', nameAr: 'أكياس شاي مستعملة (ليبتون، أتاي بركة)', nameEs: 'Bolsas de té usadas (Lipton, Atay Baraka)',
        tipEn: 'Remove metal staples before composting. Some synthetic bags (nylon) → regular trash.'),
    _Item('Restes de pain / harcha / msemen', 'Organique', 'OUI', 'Composteur',
        Icons.breakfast_dining_rounded, Color(0xFF795548),
        'Déchirer en petits morceaux pour accélérer la décomposition. Attention : dans un composteur ouvert, peut attirer des oiseaux.',
        nameEn: 'Leftover bread / harcha / msemen', nameAr: 'بقايا الخبز / الهرشة / المسمن', nameEs: 'Sobras de pan / harcha / msemen',
        tipEn: 'Tear into small pieces to speed decomposition. Note: in an open composter, may attract birds.'),
    _Item('Coquilles d\'œuf', 'Organique', 'OUI', 'Composteur',
        Icons.egg_outlined, Color(0xFF795548),
        'Écraser avant de composter — apportent du calcium au sol. Se décomposent lentement (1 an). Excellent pour rééquilibrer le pH.',
        nameEn: 'Eggshells', nameAr: 'قشور البيض', nameEs: 'Cáscaras de huevo',
        tipEn: 'Crush before composting — provide calcium to the soil. Decompose slowly (1 year). Great for rebalancing pH.'),
    _Item('Feuilles mortes / gazon / herbes', 'Organique', 'OUI', 'Composteur',
        Icons.grass_rounded, Color(0xFF795548),
        'Mélanger vert (azote : feuilles fraîches, épluchures) et sec (carbone : feuilles mortes, carton). Rapport idéal 1/3 vert, 2/3 sec.',
        nameEn: 'Dead leaves / lawn clippings / plants', nameAr: 'أوراق جافة / عشب / نباتات', nameEs: 'Hojas secas / césped / hierba',
        tipEn: 'Mix green (nitrogen: fresh leaves, peels) and dry (carbon: dead leaves, cardboard). Ideal ratio: 1/3 green, 2/3 dry.'),
    _Item('Sciure de bois non traité', 'Organique', 'OUI', 'Composteur',
        Icons.carpenter_rounded, Color(0xFF795548),
        'Bon apport de carbone pour le compost. Uniquement bois naturel non peint, non verni. Pas de panneaux agglomérés (colle chimique).',
        nameEn: 'Untreated sawdust', nameAr: 'نشارة خشب غير معالج', nameEs: 'Serrín de madera sin tratar',
        tipEn: 'Good carbon input for compost. Only untreated, unpainted, unvarnished wood. No chipboard (chemical glue).'),
    _Item('Carton déchiré non imprimé', 'Organique', 'OUI', 'Composteur',
        Icons.inventory_2_rounded, Color(0xFF795548),
        'En petits morceaux humidifiés. Apport de carbone. Éviter carton imprimé (encres) ou ciré. Préférer le bac bleu si propre.',
        nameEn: 'Torn unprinted cardboard', nameAr: 'كرتون ممزق غير مطبوع', nameEs: 'Cartón roto sin imprimir',
        tipEn: 'In small dampened pieces. Carbon input. Avoid printed or waxed cardboard. Prefer the blue bin if clean.'),
    _Item('Viande et poisson (restes)', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.set_meal_rounded, Color(0xFF795548),
        'Attire rongeurs et insectes dans un composteur ouvert. Poubelle ordinaire. Exception : composteur fermé en biogaz (collectivités).',
        nameEn: 'Meat and fish leftovers', nameAr: 'بقايا اللحم والسمك', nameEs: 'Sobras de carne y pescado',
        tipEn: 'Attracts rodents and insects in an open composter. Regular trash. Exception: sealed biogas composter (municipalities).'),
    _Item('Produits laitiers (yaourt, fromage)', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.local_drink_rounded, Color(0xFF795548),
        'Fermentation rapide = odeurs et nuisibles. Poubelle ordinaire. Les emballages plastiques/carton → bacs recyclage.',
        nameEn: 'Dairy products (yogurt, cheese)', nameAr: 'منتجات الألبان (زبادي، جبن)', nameEs: 'Productos lácteos (yogur, queso)',
        tipEn: 'Fast fermentation = odors and pests. Regular trash. Plastic/cardboard packaging → recycling bins.'),
    _Item('Huile de cuisson usagée', 'Organique', 'NON', 'Collecte spéciale huile',
        Icons.oil_barrel_rounded, Color(0xFF795548),
        'JAMAIS dans l\'évier (bouche les canalisations). Solidifier dans un contenant fermé → poubelle, ou rapporter en collecte spéciale.',
        nameEn: 'Used cooking oil', nameAr: 'زيت الطهي المستعمل', nameEs: 'Aceite de cocina usado',
        tipEn: 'NEVER down the sink (clogs pipes). Solidify in a sealed container → trash, or return to a special collection point.'),
    _Item('Couches bébé / protection hygiénique', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.child_friendly_rounded, Color(0xFF795548),
        'Non recyclables et non compostables. Poubelle ordinaire. Des filières spécialisées émergent mais pas encore au Maroc.',
        nameEn: 'Baby diapers / hygiene protection', nameAr: 'حفاضات الأطفال / الحماية الصحية', nameEs: 'Pañales / protección higiénica',
        tipEn: 'Non-recyclable and non-compostable. Regular trash. Specialized streams are emerging but not yet in Morocco.'),
    _Item('Cendres froides (barbecue, cheminée)', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.local_fire_department_rounded, Color(0xFF795548),
        'En très petite quantité dans le compost si froid (apport de potasse). En grande quantité → poubelle. Jamais chaude.',
        nameEn: 'Cold ashes (barbecue, fireplace)', nameAr: 'رماد بارد (شواء، مدفأة)', nameEs: 'Cenizas frías (barbacoa, chimenea)',
        tipEn: 'In very small cold amounts in compost (potassium input). In large quantities → trash. Never while still hot.'),

    // ── ÉLECTRONIQUE ──────────────────────────────────────────────────────────
    _Item('Smartphone / Téléphone portable', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.phone_android_rounded, AppColors.electronics,
        'Décret 2-12-695 : reprise obligatoire. ECOVAL rembourse jusqu\'à 500 DH. Points ECOVAL : Marjane, Carrefour, Cosmos Electro.',
        nameEn: 'Smartphone / Mobile phone', nameAr: 'هاتف ذكي / جوّال', nameEs: 'Smartphone / Teléfono móvil',
        tipEn: 'Decree 2-12-695: mandatory take-back. ECOVAL reimburses up to 500 DH. ECOVAL points: Marjane, Carrefour, Cosmos Electro.'),
    _Item('Tablette / iPad', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.tablet_rounded, AppColors.electronics,
        'Effacer les données avant dépôt (réinitialisation usine). Contient lithium, coltan, or — métaux précieux valorisables.',
        nameEn: 'Tablet / iPad', nameAr: 'لوحي / آيباد', nameEs: 'Tableta / iPad',
        tipEn: 'Erase data before drop-off (factory reset). Contains lithium, coltan, gold — valuable recoverable metals.'),
    _Item('Ordinateur / Laptop', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL / Déchetterie',
        Icons.laptop_rounded, AppColors.electronics,
        'Effacer le disque dur (formatage complet). ECOVAL ou déchetterie zone DEEE. Certains constructeurs proposent la reprise gratuite.',
        nameEn: 'Computer / Laptop', nameAr: 'حاسوب / كمبيوتر محمول', nameEs: 'Ordenador / Portátil',
        tipEn: 'Erase the hard drive (full format). ECOVAL or recycling center WEEE zone. Some manufacturers offer free take-back.'),
    _Item('Télévision / Écran PC', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.tv_rounded, AppColors.electronics,
        'Reprise 1 pour 1 chez le vendeur à l\'achat d\'un neuf (obligation légale). Ou éco-point ECOVAL. Contient plomb dans les anciens CRT.',
        nameEn: 'TV / Computer screen', nameAr: 'تلفزيون / شاشة كمبيوتر', nameEs: 'Televisión / Pantalla PC',
        tipEn: '1-for-1 take-back when buying new (legal obligation). Or ECOVAL point. Old CRT models contain lead.'),
    _Item('Réfrigérateur / Congélateur', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.kitchen_rounded, AppColors.electronics,
        'Gros électroménager : ECOVAL organise la collecte à domicile. Contient des frigorigènes (gaz à effet de serre) à traiter.',
        nameEn: 'Refrigerator / Freezer', nameAr: 'ثلاجة / مجمّد', nameEs: 'Refrigerador / Congelador',
        tipEn: 'ECOVAL arranges home collection for large appliances. Contains refrigerants (greenhouse gases) to be treated.'),
    _Item('Machine à laver / Lave-vaisselle', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.local_laundry_service_rounded, AppColors.electronics,
        'Reprise possible par le vendeur. ECOVAL organise collecte. Récupération du cuivre des moteurs et de l\'acier inoxydable.',
        nameEn: 'Washing machine / Dishwasher', nameAr: 'غسالة / غسالة أطباق', nameEs: 'Lavadora / Lavavajillas',
        tipEn: 'Take-back possible by the retailer. ECOVAL arranges collection. Copper from motors and stainless steel are recovered.'),
    _Item('Climatiseur / Split (unité intérieure)', 'Électronique', 'COLLECTE SPÉCIALE', 'Technicien agréé',
        Icons.ac_unit_rounded, AppColors.electronics,
        'Le frigorigène doit être récupéré par un technicien agréé avant démontage. Puis éco-point ECOVAL pour le reste.',
        nameEn: 'Air conditioner / Split unit (indoor)', nameAr: 'مكيف هواء / وحدة داخلية', nameEs: 'Aire acondicionado / Split (unidad interior)',
        tipEn: 'Refrigerant must be recovered by a certified technician before dismantling. Then ECOVAL point for the rest.'),
    _Item('Pile / Batterie Li-ion (téléphone, vélo)', 'Électronique', 'COLLECTE SPÉCIALE', 'Collecteur ECOVAL',
        Icons.battery_charging_full_rounded, AppColors.electronics,
        'JAMAIS à la poubelle (risque d\'incendie). Collecteurs ECOVAL, Marjane, Label\'Vie. Ne pas court-circuiter avec du ruban adhésif sur les bornes.',
        nameEn: 'Li-ion battery (phone, bike)', nameAr: 'بطارية ليثيوم أيون (هاتف، دراجة)', nameEs: 'Batería Li-ion (teléfono, bicicleta)',
        tipEn: 'NEVER in the trash (fire risk). ECOVAL, Marjane, Label\'Vie collectors. Cover terminals with tape to prevent short-circuit.'),
    _Item('Chargeur / Câble USB / Adaptateur', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.cable_rounded, AppColors.electronics,
        'Regrouper dans un sac. Éco-point ECOVAL ou point de collecte en magasin électronique (Biougnach, Electroplanet).',
        nameEn: 'Charger / USB cable / Adapter', nameAr: 'شاحن / كابل USB / محوّل', nameEs: 'Cargador / Cable USB / Adaptador',
        tipEn: 'Bundle in a bag. ECOVAL point or in-store collection (Biougnach, Electroplanet).'),
    _Item('Ampoule LED / Fluocompacte', 'Électronique', 'COLLECTE SPÉCIALE', 'Point luminaire',
        Icons.lightbulb_rounded, AppColors.electronics,
        'Points de collecte : Bricoma, Mr. Bricolage, grandes surfaces. Contient mercure (fluocompactes) → manipulation délicate.',
        nameEn: 'LED / CFL light bulb', nameAr: 'مصباح LED / موفر للطاقة', nameEs: 'Bombilla LED / CFL',
        tipEn: 'Collection points: Bricoma, Mr. Bricolage, supermarkets. CFL bulbs contain mercury → handle carefully.'),
    _Item('Imprimante / Cartouche d\'encre', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.print_rounded, AppColors.electronics,
        'Cartouches : programmes de reprise fabricant (HP, Epson, Canon). Imprimantes complètes → éco-point ECOVAL.',
        nameEn: 'Printer / Ink cartridge', nameAr: 'طابعة / خرطوشة حبر', nameEs: 'Impresora / Cartucho de tinta',
        tipEn: 'Cartridges: manufacturer take-back programs (HP, Epson, Canon). Full printers → ECOVAL point.'),
    _Item('Four micro-ondes', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.microwave_rounded, AppColors.electronics,
        'Contient des composants électroniques et magnétrons. Éco-point ECOVAL ou reprise vendeur. Ne jamais démonter soi-même.',
        nameEn: 'Microwave oven', nameAr: 'فرن الميكروويف', nameEs: 'Horno microondas',
        tipEn: 'Contains electronic components and magnetrons. ECOVAL point or retailer take-back. Never disassemble yourself.'),
    _Item('Aspirateur / Petit électroménager', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.cleaning_services_rounded, AppColors.electronics,
        'Tous les appareils électriques sont concernés par le Décret 2-12-695. Éco-point ECOVAL ou déchetterie zone DEEE.',
        nameEn: 'Vacuum cleaner / Small appliance', nameAr: 'مكنسة كهربائية / أجهزة منزلية صغيرة', nameEs: 'Aspiradora / Pequeño electrodoméstico',
        tipEn: 'All electrical appliances are covered by Decree 2-12-695. ECOVAL point or recycling center WEEE zone.'),

    // ── TEXTILE ───────────────────────────────────────────────────────────────
    _Item('Vêtements en bon état', 'Textile', 'OUI', 'Borne textile / Souk fripe',
        Icons.checkroom_rounded, Color(0xFF9B59B6),
        'Déposer propres dans un sac en borne textile. Tradition de sadaqa : don à des associations (Caritas Maroc, Croix-Rouge).',
        nameEn: 'Clothing in good condition', nameAr: 'ملابس بحالة جيدة', nameEs: 'Ropa en buen estado',
        tipEn: 'Drop off clean in a bag at a textile bin. Sadaqa tradition: donate to charities (Caritas Maroc, Red Cross).'),
    _Item('Vêtements abîmés / déchirés', 'Textile', 'OUI', 'Borne textile',
        Icons.settings_backup_restore_rounded, Color(0xFF9B59B6),
        'Même abîmés, recyclés en chiffons industriels, isolants thermiques ou couvertures. Ne pas jeter à la poubelle.',
        nameEn: 'Damaged / torn clothing', nameAr: 'ملابس تالفة / ممزقة', nameEs: 'Ropa dañada / rasgada',
        tipEn: 'Even damaged, recycled into industrial rags, thermal insulation or blankets. Do not throw in the trash.'),
    _Item('Chaussures (toutes matières)', 'Textile', 'OUI', 'Borne textile',
        Icons.directions_run_rounded, Color(0xFF9B59B6),
        'Attacher par paires avec un lacet. Mettre dans un sac. Même très usées — valorisées ou recyclées en semelles de terrain de sport.',
        nameEn: 'Shoes (all materials)', nameAr: 'أحذية (جميع المواد)', nameEs: 'Zapatos (todos los materiales)',
        tipEn: 'Tie in pairs with a lace. Put in a bag. Even very worn — valued or recycled into sports field surfaces.'),
    _Item('Sac en tissu / sac à main tissu', 'Textile', 'OUI', 'Borne textile',
        Icons.shopping_bag_rounded, Color(0xFF9B59B6),
        'Nettoyer si possible. Borne textile ou association. Alternative au sac plastique à encourager (Loi 77-15 depuis 2016).',
        nameEn: 'Fabric bag / fabric handbag', nameAr: 'حقيبة قماشية / حقيبة يد قماشية', nameEs: 'Bolsa de tela / bolso de tela',
        tipEn: 'Clean if possible. Textile bin or charity. Alternative to plastic bags encouraged (Law 77-15 since 2016).'),
    _Item('Linge de maison (draps, serviettes, rideaux)', 'Textile', 'OUI', 'Borne textile',
        Icons.bed_rounded, Color(0xFF9B59B6),
        'Propre et sec. Borne textile ou ressourcerie. Les draps usagés deviennent des chiffons industriels pour les garages.',
        nameEn: 'Household linen (sheets, towels, curtains)', nameAr: 'مفروشات (ملاءات، مناشف، ستائر)', nameEs: 'Ropa de hogar (sábanas, toallas, cortinas)',
        tipEn: 'Clean and dry. Textile bin or charity. Used sheets become industrial rags for garages.'),
    _Item('Peluches / jouets tissu propres', 'Textile', 'OUI', 'Borne textile / Association',
        Icons.toys_rounded, Color(0xFF9B59B6),
        'Propres et sans piles. Associations caritatives (Bayti, SOS Villages d\'Enfants Maroc) ou bornes textile.',
        nameEn: 'Clean stuffed toys / fabric toys', nameAr: 'دمى / ألعاب قماشية نظيفة', nameEs: 'Peluches / juguetes de tela limpios',
        tipEn: 'Clean and battery-free. Charities (Bayti, SOS Villages d\'Enfants Maroc) or textile bins.'),
    _Item('Ceinture cuir / sac cuir', 'Textile', 'OUI', 'Borne textile / Souk fripe',
        Icons.watch_rounded, Color(0xFF9B59B6),
        'Souk fripe marocain (Derb Ghallef, Mellah de Marrakech) ou bornes textile. Le cuir a une longue durée de vie.',
        nameEn: 'Leather belt / leather bag', nameAr: 'حزام جلدي / حقيبة جلدية', nameEs: 'Cinturón de cuero / bolso de cuero',
        tipEn: 'Moroccan flea market (Derb Ghallef, Marrakech Mellah) or textile bins. Leather has a long lifespan.'),
    _Item('Burnous / Djellaba usagée', 'Textile', 'OUI', 'Borne textile / Association',
        Icons.people_rounded, Color(0xFF9B59B6),
        'Tradition marocaine de sadaqa. Associations ou bornes textile. La laine est recyclable en isolant ou en nouveau tissu.',
        nameEn: 'Used burnous / djellaba', nameAr: 'برنوس / جلابة مستعملة', nameEs: 'Burnús / Djellaba usada',
        tipEn: 'Moroccan sadaqa tradition. Charities or textile bins. Wool is recyclable into insulation or new fabric.'),
    _Item('Sous-vêtements usagés', 'Textile', 'NON', 'Poubelle ordinaire',
        Icons.do_not_disturb_rounded, Color(0xFF9B59B6),
        'Pour des raisons d\'hygiène, non acceptés dans les bornes textile ni les associations. Poubelle ordinaire.',
        nameEn: 'Used underwear', nameAr: 'ملابس داخلية مستعملة', nameEs: 'Ropa interior usada',
        tipEn: 'For hygiene reasons, not accepted in textile bins or charities. Regular trash.'),
    _Item('Vêtements souillés chimiques / peinture', 'Textile', 'NON', 'Déchetterie',
        Icons.dangerous_rounded, Color(0xFF9B59B6),
        'Contaminent les autres textiles. Si souillés de produits chimiques → déchetterie zone dangereux.',
        nameEn: 'Chemical / paint-stained clothing', nameAr: 'ملابس ملوثة بمواد كيميائية / طلاء', nameEs: 'Ropa manchada de productos químicos / pintura',
        tipEn: 'Contaminates other textiles. If soiled with chemicals → recycling center hazardous zone.'),
    _Item('Matelas / oreillers', 'Textile', 'NON', 'Déchetterie / Collecte encombrants',
        Icons.hotel_rounded, Color(0xFF9B59B6),
        'Trop volumineux pour les bornes. Collecte encombrants de la commune (Casablanca 0801003737, Rabat 0537726364) ou déchetterie.',
        nameEn: 'Mattress / pillows', nameAr: 'مرتبة / وسائد', nameEs: 'Colchón / almohadas',
        tipEn: 'Too bulky for bins. Municipality bulky waste collection (Casablanca 0801003737, Rabat 0537726364) or recycling center.'),

    // ── PLASTIQUE ─────────────────────────────────────────────────────────────
    _Item('Bouteille PET (Sidi Ali, Ain Atlas, Pepsi)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.opacity_rounded, AppColors.plastic,
        'Rincer. Écraser pour réduire le volume. Bouchon peut rester vissé. L\'un des plastiques les plus recyclés au Maroc (ECOVAL).',
        nameEn: 'PET bottle (Sidi Ali, Ain Atlas, Pepsi)', nameAr: 'زجاجة PET (سيدي علي، عين أطلس، بيبسي)', nameEs: 'Botella PET (Sidi Ali, Ain Atlas, Pepsi)',
        tipEn: 'Rinse. Crush to reduce volume. Cap can stay screwed on. One of the most recycled plastics in Morocco (ECOVAL).'),
    _Item('Flacon PEHD (shampoing Pantene, lait Centrale Laitière)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.cleaning_services_rounded, AppColors.plastic,
        'Vider et rincer. Écraser. Le PEHD (code 2) est très recyclable — redevient tuyaux, mobilier urbain, sacs poubelles.',
        nameEn: 'HDPE bottle (Pantene shampoo, Centrale Laitière milk)', nameAr: 'زجاجة PEHD (شامبو بانتين، حليب المركزية)', nameEs: 'Botella PEHD (champú Pantene, leche Centrale Laitière)',
        tipEn: 'Empty and rinse. Crush. HDPE (code 2) is very recyclable — becomes pipes, street furniture, trash bags.'),
    _Item('Barquette alimentaire rincée', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.takeout_dining_rounded, AppColors.plastic,
        'Rincer pour enlever les résidus. Même légèrement souillée, elle reste recyclable. Code plastique 1 (PET) ou 5 (PP) préférables.',
        nameEn: 'Rinsed food tray', nameAr: 'صينية طعام مشطوفة', nameEs: 'Bandeja alimentaria enjuagada',
        tipEn: 'Rinse to remove residue. Even slightly soiled, still recyclable. Plastic code 1 (PET) or 5 (PP) preferred.'),
    _Item('Pot de yaourt (Danone Jaouda, Yawmi)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.icecream_rounded, AppColors.plastic,
        'Rincer rapidement. Le couvercle en alu → bac jaune aussi. Accepté dans tous les bacs ECOVAL du Maroc.',
        nameEn: 'Yogurt pot (Danone Jaouda, Yawmi)', nameAr: 'كوب زبادي (دانون جودة، يومي)', nameEs: 'Tarrina de yogur (Danone Jaouda, Yawmi)',
        tipEn: 'Quick rinse. The aluminum lid → yellow bin too. Accepted in all ECOVAL bins in Morocco.'),
    _Item('Bidon plastique propre (eau de Javel, huile)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.water_drop_rounded, AppColors.plastic,
        'Vider complètement et rincer 3 fois. Écraser. Le PEHD des bidons est très valorisé. Éviter les bidons de produits chimiques purs.',
        nameEn: 'Clean plastic container (bleach, oil)', nameAr: 'جركان بلاستيكي نظيف (ماء جافيل، زيت)', nameEs: 'Bidón plástico limpio (lejía, aceite)',
        tipEn: 'Empty completely and rinse 3 times. Crush. HDPE containers are highly valued. Avoid containers of pure chemicals.'),
    _Item('Bouchon plastique vissé', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.circle_rounded, AppColors.plastic,
        'Le bouchon vissé sur la bouteille écrasée est accepté. Collectes solidaires de bouchons pour associations (Bouchons de l\'Espoir Maroc).',
        nameEn: 'Screwed plastic cap', nameAr: 'سدادة بلاستيكية ملولبة', nameEs: 'Tapón de plástico enroscado',
        tipEn: 'Cap screwed onto crushed bottle is accepted. Solidarity cap collections for charities (Bouchons de l\'Espoir Maroc).'),
    _Item('Emballage plastique rigide propre (code 1, 2, 5)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.inventory_rounded, AppColors.plastic,
        'PET (1), PEHD (2), PP (5) = les plus recyclables. Regarder le code triangle en dessous de l\'emballage.',
        nameEn: 'Clean rigid plastic packaging (code 1, 2, 5)', nameAr: 'تغليف بلاستيكي صلب نظيف (رمز 1، 2، 5)', nameEs: 'Envase plástico rígido limpio (código 1, 2, 5)',
        tipEn: 'PET (1), HDPE (2), PP (5) = most recyclable. Check the triangle code on the bottom of the packaging.'),
    _Item('Sac plastique (tous types)', 'Plastique', 'INTERDIT', 'Interdit — Loi 77-15',
        Icons.shopping_bag_outlined, AppColors.plastic,
        'INTERDIT en production et distribution depuis juillet 2016 (Loi 77-15). Amende : 1000 DH à 1 million DH. Utiliser sac tissu ou panier.',
        nameEn: 'Plastic bag (all types)', nameAr: 'كيس بلاستيكي (جميع الأنواع)', nameEs: 'Bolsa plástica (todos los tipos)',
        tipEn: 'BANNED from production and distribution since July 2016 (Law 77-15). Fine: 1,000 to 1 million DH. Use fabric bag or basket.'),
    _Item('Film plastique souple (emballage)', 'Plastique', 'NON', 'Borne dédiée / Poubelle',
        Icons.wrap_text_rounded, AppColors.plastic,
        'Non recyclable dans les bacs jaunes — bloque les machines de tri. Certains supermarchés (Carrefour) ont des bornes pour films plastiques.',
        nameEn: 'Soft plastic film (packaging)', nameAr: 'غشاء بلاستيكي مرن (تغليف)', nameEs: 'Film plástico flexible (embalaje)',
        tipEn: 'Not recyclable in yellow bins — clogs sorting machines. Some supermarkets (Carrefour) have dedicated film bins.'),
    _Item('Polystyrène expansé (emballage, barquette poisson)', 'Plastique', 'NON', 'Déchetterie',
        Icons.view_in_ar_rounded, AppColors.plastic,
        'Difficile à recycler au Maroc. Déchetterie ou compactage spécialisé. Volume énorme pour peu de matière — problème majeur de pollution.',
        nameEn: 'Expanded polystyrene (packaging, fish tray)', nameAr: 'البوليسترين المتمدد (تغليف، صينية سمك)', nameEs: 'Poliestireno expandido (embalaje, bandeja de pescado)',
        tipEn: 'Difficult to recycle in Morocco. Recycling center or specialized compaction. Huge volume for little material — major pollution issue.'),
    _Item('Tube dentifrice (Colgate, Signal)', 'Plastique', 'NON', 'Poubelle ordinaire',
        Icons.brush_rounded, AppColors.plastic,
        'Multicouche aluminium + plastique = non recyclable. Poubelle ordinaire. Programme de reprise Colgate en pharmacies partenaires.',
        nameEn: 'Toothpaste tube (Colgate, Signal)', nameAr: 'أنبوب معجون أسنان (كولجيت، سيجنال)', nameEs: 'Tubo de pasta de dientes (Colgate, Signal)',
        tipEn: 'Multilayer aluminium + plastic = not recyclable. Regular trash. Colgate take-back program in partner pharmacies.'),
    _Item('Paille plastique', 'Plastique', 'NON', 'Poubelle ordinaire',
        Icons.remove_rounded, AppColors.plastic,
        'Trop légère et petite pour les machines de tri. Poubelle ordinaire. Préférer paille en inox, bambou, papier ou verre réutilisable.',
        nameEn: 'Plastic straw', nameAr: 'شفاطة بلاستيكية', nameEs: 'Pajita de plástico',
        tipEn: 'Too light and small for sorting machines. Regular trash. Prefer stainless steel, bamboo, paper or reusable glass straws.'),
    _Item('Emballage multicouche (brique de jus, sachets café)', 'Plastique', 'NON', 'Poubelle ordinaire',
        Icons.layers_rounded, AppColors.plastic,
        'Mélange plastique + aluminium + carton inséparable mécaniquement. Pas de filière de recyclage au Maroc actuellement.',
        nameEn: 'Multi-layer packaging (juice carton, coffee sachets)', nameAr: 'تغليف متعدد الطبقات (عبوة عصير، أكياس قهوة)', nameEs: 'Envase multicapa (brick de zumo, sobres de café)',
        tipEn: 'Mix of plastic + aluminium + cardboard that cannot be mechanically separated. No recycling stream in Morocco yet.'),

    // ── PAPIER / CARTON ───────────────────────────────────────────────────────
    _Item('Journal / Magazine (Al Ahdath, L\'Économiste, TelQuel)', 'Papier', 'OUI', 'Bac bleu / Ferracha',
        Icons.article_outlined, AppColors.paper,
        'Plier ou empiler. Ne pas mouiller. La ferracha (récupérateur informel) joue un rôle essentiel dans le recyclage du papier au Maroc.',
        nameEn: 'Newspaper / Magazine (Al Ahdath, L\'Économiste, TelQuel)', nameAr: 'جريدة / مجلة (الأحداث، الاقتصادية، تيلكيل)', nameEs: 'Periódico / Revista (Al Ahdath, L\'Économiste, TelQuel)',
        tipEn: 'Fold or stack. Do not wet. The ferracha (informal collector) plays a key role in paper recycling in Morocco.'),
    _Item('Carton ondulé aplati', 'Papier', 'OUI', 'Bac bleu / Ferracha',
        Icons.inventory_2_rounded, AppColors.paper,
        'Aplatir avant de mettre dans le bac. Enlever les agrafes et le ruban adhésif. Repris par l\'industrie papetière marocaine (CMCP).',
        nameEn: 'Flattened corrugated cardboard', nameAr: 'كرتون مموج مفرود', nameEs: 'Cartón corrugado aplanado',
        tipEn: 'Flatten before putting in the bin. Remove staples and adhesive tape. Collected by the Moroccan paper industry (CMCP).'),
    _Item('Boîte carton (céréales Kellogg\'s, conserves Aïcha)', 'Papier', 'OUI', 'Bac bleu',
        Icons.breakfast_dining_rounded, AppColors.paper,
        'Aplatir. Retirer les sachets plastiques intérieurs (→ bac jaune si recyclable, sinon poubelle). Pureté du carton très importante.',
        nameEn: 'Cardboard box (Kellogg\'s cereals, Aïcha cans)', nameAr: 'علبة كرتون (حبوب كيلوغز، علب عائشة)', nameEs: 'Caja de cartón (cereales Kellogg\'s, conservas Aïcha)',
        tipEn: 'Flatten. Remove inner plastic bags (→ yellow bin if recyclable, otherwise waste bin). Cardboard purity is very important.'),
    _Item('Enveloppe (avec ou sans fenêtre plastique)', 'Papier', 'OUI', 'Bac bleu',
        Icons.mail_outlined, AppColors.paper,
        'La fenêtre plastique est acceptée dans la plupart des collectes. Retirer les autocollants si possible. Sans le contenu papier.',
        nameEn: 'Envelope (with or without plastic window)', nameAr: 'مظروف (مع أو بدون نافذة بلاستيكية)', nameEs: 'Sobre (con o sin ventana de plástico)',
        tipEn: 'The plastic window is accepted in most collections. Remove stickers if possible. Without the paper contents.'),
    _Item('Cahier / Papier bureau (fax, imprimante)', 'Papier', 'OUI', 'Bac bleu',
        Icons.description_outlined, AppColors.paper,
        'Retirer les spirales métalliques (→ bac jaune). Les trombones et agrafes sont acceptés. Ne pas mixer avec papier mouillé.',
        nameEn: 'Notebook / Office paper (fax, printer)', nameAr: 'دفتر / ورق مكتبي (فاكس، طابعة)', nameEs: 'Cuaderno / Papel de oficina (fax, impresora)',
        tipEn: 'Remove metal spirals (→ yellow bin). Paper clips and staples are accepted. Do not mix with wet paper.'),
    _Item('Brique alimentaire (Centrale Laitière, Candia)', 'Papier', 'OUI', 'Bac bleu',
        Icons.local_drink_rounded, AppColors.paper,
        'Rincer. Écraser. Certaines collectes en bac bleu, d\'autres en bac jaune selon la ville. Vérifier auprès de votre commune.',
        nameEn: 'Food carton (Centrale Laitière, Candia)', nameAr: 'علبة أغذية مقوى (المركزية الحليبية، كانديا)', nameEs: 'Cartón de alimentación (Centrale Laitière, Candia)',
        tipEn: 'Rinse. Crush. Some collections in blue bin, others in yellow bin depending on city. Check with your municipality.'),
    _Item('Annuaire téléphonique / catalogue', 'Papier', 'OUI', 'Bac bleu / Ferracha',
        Icons.menu_book_rounded, AppColors.paper,
        'Papier non couché = très recyclable. La ferracha marocaine rachète ce type de papier. Dépôt en bac bleu ou point de collecte.',
        nameEn: 'Phone directory / catalogue', nameAr: 'دليل هاتفي / كتالوج', nameEs: 'Guía telefónica / catálogo',
        tipEn: 'Uncoated paper = very recyclable. The Moroccan ferracha buys this type of paper. Drop in blue bin or collection point.'),
    _Item('Ticket de caisse thermique', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.receipt_rounded, AppColors.paper,
        'Contient du Bisphénol A (BPA) — perturbateur endocrinien qui contamine les autres papiers. JAMAIS au bac bleu.',
        nameEn: 'Thermal cash register receipt', nameAr: 'إيصال صراف حراري', nameEs: 'Ticket de caja térmico',
        tipEn: 'Contains Bisphenol A (BPA) — endocrine disruptor that contaminates other paper. NEVER in the blue bin.'),
    _Item('Papier cuisson siliconé', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.kitchen_rounded, AppColors.paper,
        'Le revêtement silicone empêche le recyclage. Poubelle ordinaire. Préférer tapis de cuisson réutilisable en silicone.',
        nameEn: 'Silicone-coated baking paper', nameAr: 'ورق خبز مطلي بالسيليكون', nameEs: 'Papel de horno siliconado',
        tipEn: 'The silicone coating prevents recycling. Regular waste bin. Prefer reusable silicone baking mat.'),
    _Item('Emballage cadeau brillant / pailleté', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.card_giftcard_rounded, AppColors.paper,
        'Le revêtement plastique ou métallique est non séparable. Poubelle ordinaire. Préférer papier kraft naturel recyclable.',
        nameEn: 'Shiny / glittery gift wrap', nameAr: 'ورق تغليف هدايا لامع / متألق', nameEs: 'Papel de regalo brillante / con purpurina',
        tipEn: 'The plastic or metallic coating is inseparable. Regular waste bin. Prefer recyclable natural kraft paper.'),
    _Item('Carton pizza gras / souillé', 'Papier', 'NON', 'Composteur (si non imprimé)',
        Icons.local_pizza_rounded, AppColors.paper,
        'La partie grasse contamine le lot de papier recyclé. Découper : partie propre → bac bleu, partie grasse → compost ou poubelle.',
        nameEn: 'Greasy / soiled pizza box', nameAr: 'علبة بيتزا دهنية / ملوثة', nameEs: 'Caja de pizza grasienta / sucia',
        tipEn: 'The greasy part contaminates the recycled paper batch. Cut it: clean part → blue bin, greasy part → compost or waste.'),
    _Item('Papier aluminium / papier cuisson alu', 'Papier', 'NON', 'Bac jaune ECOVAL (métal)',
        Icons.layers_rounded, AppColors.paper,
        'Ce n\'est pas du papier — c\'est de l\'aluminium ! Froisser en boule compacte → bac jaune (métal).',
        nameEn: 'Aluminium foil / aluminium baking paper', nameAr: 'ورق ألمنيوم / ورق خبز ألمنيوم', nameEs: 'Papel de aluminio / papel de cocina de aluminio',
        tipEn: 'It\'s not paper — it\'s aluminium! Scrunch into a compact ball → yellow bin (metal).'),
    _Item('Papier hygiénique / mouchoir usagé', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.clean_hands_rounded, AppColors.paper,
        'Souillé de matières biologiques → non recyclable. Poubelle ordinaire. Le papier recyclé en mouchoirs ne peut pas être recyclé de nouveau.',
        nameEn: 'Toilet paper / used tissue', nameAr: 'ورق صحي / منديل مستعمل', nameEs: 'Papel higiénico / pañuelo usado',
        tipEn: 'Contaminated with biological material → not recyclable. Regular waste bin. Recycled tissue paper cannot be recycled again.'),
    _Item('Emballage fast-food gras (sac McDo, KFC)', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.fastfood_rounded, AppColors.paper,
        'Imprégné de graisse et souvent mélangé avec plastique. Non recyclable. Poubelle ordinaire.',
        nameEn: 'Greasy fast-food packaging (McDonald\'s, KFC bag)', nameAr: 'تغليف وجبات سريعة دهنية (ماكدونالدز، كي إف سي)', nameEs: 'Envase de comida rápida grasiento (bolsa McDonald\'s, KFC)',
        tipEn: 'Soaked in grease and often mixed with plastic. Not recyclable. Regular waste bin.'),

    // ── DÉCHETS DANGEREUX ─────────────────────────────────────────────────────
    _Item('Médicaments périmés', 'Dangereux', 'COLLECTE SPÉCIALE', 'Pharmacie agréée',
        Icons.medication_rounded, Color(0xFFE74C3C),
        'JAMAIS à la poubelle ni dans les toilettes (contamination eau). Rapporter en pharmacie. Maroc : filière de valorisation thermique.',
        nameEn: 'Expired medications', nameAr: 'أدوية منتهية الصلاحية', nameEs: 'Medicamentos caducados',
        tipEn: 'NEVER in the bin or toilet (water contamination). Return to pharmacy. Morocco: thermal recovery system.'),
    _Item('Piles et batteries (toutes tailles)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Collecteur ECOVAL',
        Icons.battery_full_rounded, Color(0xFFE74C3C),
        'Contiennent mercure, cadmium, plomb. Collecteurs ECOVAL dans les supermarchés. JAMAIS dans la poubelle ordinaire (Loi 28-00).',
        nameEn: 'Batteries (all sizes)', nameAr: 'بطاريات (جميع الأحجام)', nameEs: 'Pilas y baterías (todos los tamaños)',
        tipEn: 'Contain mercury, cadmium, lead. ECOVAL collectors in supermarkets. NEVER in the regular waste bin (Law 28-00).'),
    _Item('Huile moteur usagée', 'Dangereux', 'COLLECTE SPÉCIALE', 'Garage agréé',
        Icons.oil_barrel_rounded, Color(0xFFE74C3C),
        'Ne jamais verser dans les égouts (1L pollue 1 million L d\'eau). Garage agréé ou déchetterie. Filière de re-raffinage au Maroc.',
        nameEn: 'Used motor oil', nameAr: 'زيت محرك مستعمل', nameEs: 'Aceite de motor usado',
        tipEn: 'Never pour down drains (1L pollutes 1 million L of water). Approved garage or waste facility. Re-refining industry in Morocco.'),
    _Item('Peinture / Vernis / Solvant', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.format_paint_rounded, Color(0xFFE74C3C),
        'Garder dans le contenant d\'origine avec l\'étiquette. Déchetterie zone produits dangereux. Loi 28-00 : infraction pénale si abandon.',
        nameEn: 'Paint / Varnish / Solvent', nameAr: 'طلاء / ورنيش / مذيب', nameEs: 'Pintura / Barniz / Disolvente',
        tipEn: 'Keep in original container with label. Waste facility dangerous products area. Law 28-00: criminal offense if abandoned.'),
    _Item('Produits ménagers chimiques (Javel, déboucheurs)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.science_rounded, Color(0xFFE74C3C),
        'Ne jamais mélanger (réactions dangereuses). Garder en contenant d\'origine. Déchetterie zone produits dangereux.',
        nameEn: 'Chemical household products (bleach, drain cleaners)', nameAr: 'منتجات منزلية كيميائية (جافيل، مزيلات انسداد)', nameEs: 'Productos domésticos químicos (lejía, destapacañerías)',
        tipEn: 'Never mix (dangerous reactions). Keep in original container. Waste facility dangerous products area.'),
    _Item('Seringues / Aiguilles (DASRI)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Boîte DASRI / Pharmacie',
        Icons.vaccines_rounded, Color(0xFFE74C3C),
        'Déchets d\'Activités de Soins à Risques Infectieux. Boîtes DASRI disponibles en pharmacie. JAMAIS dans la poubelle ordinaire.',
        nameEn: 'Syringes / Needles (DASRI)', nameAr: 'حقن / إبر (نفايات طبية)', nameEs: 'Jeringas / Agujas (DASRI)',
        tipEn: 'Infectious Healthcare Waste. DASRI boxes available at pharmacy. NEVER in the regular waste bin.'),
    _Item('Thermomètre à mercure', 'Dangereux', 'COLLECTE SPÉCIALE', 'Pharmacie / Déchetterie',
        Icons.thermostat_rounded, Color(0xFFE74C3C),
        'Le mercure est extrêmement toxique. En cas de casse : aérer, évacuer, ne pas aspirer. Rapporter entier en pharmacie ou déchetterie.',
        nameEn: 'Mercury thermometer', nameAr: 'ميزان حرارة زئبقي', nameEs: 'Termómetro de mercurio',
        tipEn: 'Mercury is extremely toxic. If broken: ventilate, evacuate, do not vacuum. Return whole to pharmacy or waste facility.'),
    _Item('Pesticides / Herbicides / Insecticides', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.bug_report_rounded, Color(0xFFE74C3C),
        'Contaminants des eaux souterraines. Déchetterie zone dangereux. En milieu agricole : programme ECOPHYTO du Maroc.',
        nameEn: 'Pesticides / Herbicides / Insecticides', nameAr: 'مبيدات حشرية / مبيدات أعشاب / حشريات', nameEs: 'Pesticidas / Herbicidas / Insecticidas',
        tipEn: 'Groundwater contaminants. Waste facility dangerous area. In agricultural settings: Morocco\'s ECOPHYTO programme.'),
    _Item('Acides / Bases concentrées', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.warning_amber_rounded, Color(0xFFE74C3C),
        'Produits très corrosifs. Conserver en contenant d\'origine, ne jamais transférer dans une autre bouteille. Déchetterie zone dangereux.',
        nameEn: 'Concentrated acids / bases', nameAr: 'أحماض / قواعد مركزة', nameEs: 'Ácidos / Bases concentradas',
        tipEn: 'Highly corrosive products. Store in original container, never transfer to another bottle. Waste facility dangerous area.'),
    _Item('Extincteur (poudre, CO₂, eau)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie / Professionnel',
        Icons.fire_extinguisher_rounded, Color(0xFFE74C3C),
        'Certains distributeurs assurent la reprise. Déchetterie ou professionnel agréé. Ne jamais percer ni jeter à la poubelle.',
        nameEn: 'Fire extinguisher (powder, CO₂, water)', nameAr: 'طفاية حريق (مسحوق، ثاني أكسيد الكربون، ماء)', nameEs: 'Extintor (polvo, CO₂, agua)',
        tipEn: 'Some distributors offer take-back. Waste facility or approved professional. Never pierce or throw in the bin.'),
    _Item('Amiante (plaques, tuiles)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — amiante',
        Icons.dangerous_rounded, Color(0xFFE74C3C),
        'TRÈS DANGEREUX — fibre cancérigène. Ne jamais casser ni poncer. Filière spécialisée obligatoire. Contacter la commune ou l\'ONEE.',
        nameEn: 'Asbestos (sheets, tiles)', nameAr: 'أسبستوس (ألواح، قرميد)', nameEs: 'Amianto (placas, tejas)',
        tipEn: 'VERY DANGEROUS — carcinogenic fibre. Never break or sand. Mandatory specialised facility. Contact municipality or ONEE.'),
    _Item('Néons / Tubes fluorescents', 'Dangereux', 'COLLECTE SPÉCIALE', 'Point luminaire / Déchetterie',
        Icons.light_rounded, Color(0xFFE74C3C),
        'Contiennent du mercure. Ne jamais casser. Points de collecte luminaires (Bricoma, Mr. Bricolage) ou déchetterie zone DEEE.',
        nameEn: 'Neon / Fluorescent tubes', nameAr: 'أنابيب نيون / أنابيب فلورية', nameEs: 'Tubos de neón / fluorescentes',
        tipEn: 'Contain mercury. Never break. Lighting collection points (Bricoma, Mr. Bricolage) or WEEE waste facility.'),
  ];

  List<_Item> _getFiltered(String lang) {
    final catName = _categories[_selectedCat].name;
    final q = _query.toLowerCase();
    return _items.where((item) {
      final matchCat = catName == 'Tous' || item.category == catName;
      final matchQ = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.nameEn.toLowerCase().contains(q) ||
          item.nameAr.contains(q) ||
          item.nameEs.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.tip.toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
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
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    final filtered = _getFiltered(lang);

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
                        const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.sortingGuide,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 22,
                                    fontWeight: FontWeight.bold, color: Colors.white,
                                  )),
                              Text(s.sortingSubtitle,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 11, color: Colors.white70,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s.guideWasteCount(_items.length),
                            style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 12,
                              color: Colors.white, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontFamily: 'Poppins', color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: s.searchWaste,
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.white.withValues(alpha: 0.8)),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.white.withValues(alpha: 0.8)),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 14),
                    TabBar(
                      controller: _tabCtrl,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      tabs: [
                        Tab(text: s.guideTabWaste),
                        Tab(text: s.guideTabTips),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category chips (Déchets tab only) ────────────────────────────
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? cat.color
                              : (isDark ? AppColors.darkCard : AppColors.inputBg),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon,
                                size: 13, color: active ? Colors.white : cat.color),
                            const SizedBox(width: 5),
                            Text(
                              _catDisplay(cat.name, s),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
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
                                color: AppColors.textLight.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(s.noResults,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.textSecondary,
                                )),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _GuideCard(item: filtered[i], isDark: isDark, lang: lang)
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

// ── Translation helpers ────────────────────────────────────────────────────────

String _catDisplay(String frCat, AppStrings s) {
  switch (frCat) {
    case 'Tous':         return s.catAll;
    case 'Plastique':    return s.catPlastic;
    case 'Papier':       return s.catPaper;
    case 'Verre':        return s.catGlass;
    case 'Métal':        return s.catMetal;
    case 'Organique':    return s.catOrganic;
    case 'Électronique': return s.catElectronic;
    case 'Dangereux':    return s.catDangerous;
    case 'Textile':      return s.catTextile;
    default:             return frCat;
  }
}

String _statusLabel(String status, AppStrings s) {
  switch (status) {
    case 'OUI':              return s.statusYes;
    case 'NON':              return s.statusNo;
    case 'COLLECTE SPÉCIALE':return s.statusSpecial;
    case 'INTERDIT':         return s.statusBanned;
    default:                 return status;
  }
}

// ── Status helpers ─────────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status) {
    case 'OUI':
      return AppColors.primary;
    case 'COLLECTE SPÉCIALE':
      return const Color(0xFFF39C12);
    case 'INTERDIT':
      return const Color(0xFFC0392B);
    default:
      return AppColors.danger;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'OUI':
      return Icons.recycling_rounded;
    case 'COLLECTE SPÉCIALE':
      return Icons.star_rounded;
    case 'INTERDIT':
      return Icons.do_not_disturb_on_rounded;
    default:
      return Icons.block_rounded;
  }
}

// ── Guide Card ─────────────────────────────────────────────────────────────────

class _GuideCard extends StatefulWidget {
  final _Item item;
  final bool isDark;
  final String lang;
  const _GuideCard({required this.item, required this.isDark, required this.lang});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;
    final lang = widget.lang;
    final s = AppStrings.of(lang);
    final sc = _statusColor(item.status);

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
                        item.nameFor(lang),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _catDisplay(item.category, s),
                              style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 10,
                                color: item.color, fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(_statusIcon(item.status), size: 12, color: sc),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _statusLabel(item.status, s),
                              style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 10, color: sc,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.bin,
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 10,
                          fontWeight: FontWeight.w600, color: item.color,
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
                    Icon(Icons.tips_and_updates_rounded, color: item.color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.tipFor(lang),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12, height: 1.5,
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

class _ConsignesTab extends ConsumerWidget {
  final bool isDark;
  const _ConsignesTab({required this.isDark});

  static const _bins = [
    _Bin('Bac Jaune ECOVAL', 'Plastiques, métaux, emballages',
        Color(0xFFF39C12), Icons.recycling_rounded,
        ['Bouteilles PET et flacons PEHD rincés', 'Canettes alu et boîtes conserve acier',
         'Barquettes et pots en plastique rigide', 'Aérosols vides et dégazés',
         'Boites biscuits métal, couvercles métal', 'ECOVAL : Casablanca, Rabat, Marrakech, Tanger, Agadir, Fès'],
        nameEn: 'Yellow ECOVAL Bin', subtitleEn: 'Plastics, metals, packaging',
        itemsEn: ['Rinsed PET bottles and HDPE containers', 'Aluminium cans and steel food tins',
         'Rigid plastic trays and pots', 'Empty and deflated aerosols',
         'Metal biscuit tins, metal lids', 'ECOVAL: Casablanca, Rabat, Marrakech, Tangier, Agadir, Fes']),
    _Bin('Colonne Verte', 'Verre uniquement',
        AppColors.glass, Icons.local_bar_outlined,
        ['Bouteilles verre (Sidi Ali, Ain Atlas, Oulmes)', 'Bocaux et pots en verre',
         'Flacons parfum et carafe verre', 'PAS : verre brisé, miroir, pyrex, ampoules',
         'Rincer avant dépôt — bouchon métal peut rester', 'Présentes dans 20 villes marocaines'],
        nameEn: 'Green Column', subtitleEn: 'Glass only',
        itemsEn: ['Glass bottles (Sidi Ali, Ain Atlas, Oulmes)', 'Glass jars and pots',
         'Perfume bottles and glass carafes', 'NOT: broken glass, mirror, pyrex, bulbs',
         'Rinse before drop-off — metal cap can stay', 'Available in 20 Moroccan cities']),
    _Bin('Bac Bleu / Ferracha', 'Papiers et cartons',
        Color(0xFF3498DB), Icons.article_outlined,
        ['Journaux, magazines, catalogues', 'Carton ondulé aplati (retirer scotch)', 'Boîtes carton céréales et emballages',
         'Cahiers, papier bureau, enveloppes', 'Briques alimentaires rincées',
         'Ferracha : récupérateurs informels — rôle clé au Maroc'],
        nameEn: 'Blue Bin / Ferracha', subtitleEn: 'Paper and cardboard',
        itemsEn: ['Newspapers, magazines, catalogues', 'Flattened corrugated cardboard (remove tape)', 'Cereal boxes and paper packaging',
         'Notebooks, office paper, envelopes', 'Rinsed food cartons',
         'Ferracha: informal collectors — key role in Morocco']),
    _Bin('Bac Marron / Composteur', 'Déchets organiques',
        Color(0xFF795548), Icons.compost_rounded,
        ['Épluchures fruits et légumes', 'Marc de café et sachets thé',
         'Pain, harcha, coquilles d\'œuf', 'Feuilles mortes, gazon, sciure bois naturel',
         '65% des déchets marocains sont organiques', 'Décomposition : 2 à 6 mois'],
        nameEn: 'Brown Bin / Composter', subtitleEn: 'Organic waste',
        itemsEn: ['Fruit and vegetable peels', 'Coffee grounds and tea bags',
         'Bread, harcha, eggshells', 'Dead leaves, lawn clippings, natural sawdust',
         '65% of Moroccan waste is organic', 'Decomposition: 2 to 6 months']),
    _Bin('Borne Textile / Souk Fripe', 'Vêtements et chaussures',
        Color(0xFF9B59B6), Icons.checkroom_rounded,
        ['Vêtements en bon état (propres, secs)', 'Chaussures attachées par paires',
         'Linge de maison, peluches, sacs tissu', 'Tradition sadaqa : don à associations',
         'Souk fripe (Derb Ghallef, Mellah) pour revente', 'Caritas Maroc, SOS Villages d\'Enfants'],
        nameEn: 'Textile Bin / Souk Fripe', subtitleEn: 'Clothing and shoes',
        itemsEn: ['Clean, dry clothing in good condition', 'Shoes tied in pairs',
         'Bed linen, soft toys, fabric bags', 'Sadaqa tradition: donations to associations',
         'Souk Fripe (Derb Ghallef, Mellah) for resale', 'Caritas Maroc, SOS Villages d\'Enfants']),
    _Bin('Éco-point ECOVAL (DEEE)', 'Appareils électroniques',
        AppColors.electronics, Icons.electrical_services_rounded,
        ['Téléphones, tablettes, ordinateurs', 'Électroménager : frigo, machine à laver',
         'Piles, batteries, chargeurs, câbles', 'ECOVAL : jusqu\'à 500 DH remboursés',
         'Points dans Marjane, Carrefour, Cosmos Electro', 'Décret 2-12-695 — reprise obligatoire'],
        nameEn: 'ECOVAL Eco-point (WEEE)', subtitleEn: 'Electronic devices',
        itemsEn: ['Phones, tablets, computers', 'Appliances: fridge, washing machine',
         'Batteries, chargers, cables', 'ECOVAL: up to 500 DH reimbursed',
         'Drop-off at Marjane, Carrefour, Cosmos Electro', 'Decree 2-12-695 — mandatory take-back']),
  ];

  static const _laws = [
    _Legal('Loi 28-00 (2006)', 'Gestion et élimination des déchets',
        Icons.gavel_rounded,
        'Loi cadre : principe Pollueur-Payeur, 7 catégories officielles. Interdit abandon/brûlage. Sanctions : 500 à 500 000 DH + prison 1 à 12 mois. Oblige communes à élaborer Plans Directeurs Provinciaux de Gestion.',
        titleEn: 'Waste management and disposal',
        descEn: 'Framework law: Polluter-Pays principle, 7 official categories. Prohibits illegal dumping/burning. Penalties: 500 to 500,000 DH + 1 to 12 months prison. Municipalities must develop Provincial Waste Management Plans.'),
    _Legal('Loi 77-15 (2016)', 'Interdiction sacs plastique',
        Icons.shopping_bag_outlined,
        'Interdit fabrication, import, commercialisation sacs plastique < 60 microns. Amende fabricants : 200 000 à 1 000 000 DH. Amende commerçants : 1 000 à 10 000 DH. Prison 1 à 3 mois. Seuls sacs certifiés biodégradables (NM ISO 17088) autorisés.',
        titleEn: 'Plastic bag ban',
        descEn: 'Prohibits production, import and sale of plastic bags < 60 microns. Manufacturer fine: 200,000 to 1,000,000 DH. Retailer fine: 1,000 to 10,000 DH. Prison 1 to 3 months. Only NM ISO 17088-certified biodegradable bags allowed.'),
    _Legal('Décret 2-14-782 (2015)', 'DEEE — Responsabilité élargie producteurs',
        Icons.phone_android_rounded,
        'Fabricants et importateurs d\'électronique financent collecte et traitement DEEE. Objectif : 65% de collecte d\'ici 2030. Reprise obligatoire 1 pour 1 dans magasins > 400 m². Amende : 50 000 à 500 000 DH + 3 à 12 mois de prison.',
        titleEn: 'WEEE — Extended Producer Responsibility',
        descEn: 'Electronics manufacturers and importers fund WEEE collection and treatment. Target: 65% collection rate by 2030. Mandatory 1-for-1 take-back in stores > 400 m². Fine: 50,000 to 500,000 DH + 3 to 12 months prison.'),
    _Legal('Décret 2-09-139 (2009)', 'Déchets dangereux — Procédures',
        Icons.warning_amber_rounded,
        'Procédures de gestion, traitement et élimination des déchets dangereux. Déclaration obligatoire pour producteurs > 500 kg/an. Bordereau de suivi obligatoire. Complété par Arrêté 3286-08 (liste officielle), Arrêté 2073-14 (huiles usagées).',
        titleEn: 'Hazardous waste — Procedures',
        descEn: 'Procedures for management, treatment and disposal of hazardous waste. Mandatory declaration for producers > 500 kg/year. Mandatory tracking form. Supplemented by Order 3286-08 (official list), Order 2073-14 (used oils).'),
    _Legal('SNGD 2030', 'Stratégie Nationale Gestion des Déchets',
        Icons.flag_rounded,
        'Budget 40 milliards DH (2021-2030). Objectifs : 90% collecte urbaine, 35 centres de tri dans villes > 50 000 hab., 20% taux de recyclage ménager, fermeture 300+ décharges sauvages, 50 unités de compostage. Tri à la source dans 20 villes pilotes d\'ici 2025.',
        titleEn: 'National Waste Management Strategy',
        descEn: 'Budget 40 billion DH (2021–2030). Targets: 90% urban collection, 35 sorting centres in cities > 50,000 pop., 20% household recycling rate, closure of 300+ illegal dumps, 50 composting units. Source separation in 20 pilot cities by 2025.'),
    _Legal('Loi 99-12', 'Charte nationale environnement',
        Icons.balance_rounded,
        'Charte Nationale de l\'Environnement et du Développement Durable. Consacre le droit à un environnement sain. Base juridique de toutes les politiques environnementales marocaines.',
        titleEn: 'National environment charter',
        descEn: 'National Charter for Environment and Sustainable Development. Enshrines the right to a healthy environment. Legal basis for all Moroccan environmental policies.'),
    _Legal('Convention de Bâle (1995)', 'Déchets dangereux transfrontaliers',
        Icons.public_rounded,
        'Ratifiée par le Maroc. Interdit export déchets dangereux vers pays non-OCDE sans preuve de traitement conforme. Sanction : 500 000 à 2 000 000 DH + 6 à 24 mois prison. Convention de Bamako (1991) renforce cette protection pour l\'Afrique.',
        titleEn: 'Transboundary hazardous waste',
        descEn: 'Ratified by Morocco. Prohibits export of hazardous waste to non-OECD countries without proof of compliant treatment. Penalty: 500,000 to 2,000,000 DH + 6 to 24 months prison. Bamako Convention (1991) reinforces this protection for Africa.'),
    _Legal('Accord de Paris (2016)', 'Réduction GES — 42% d\'ici 2030',
        Icons.eco_rounded,
        'Le Maroc s\'engage à réduire ses GES de 42% d\'ici 2030. Les déchets représentent 4,7% des émissions. Agenda ODD 2030 cible 12.5 : réduire de 50% la génération de déchets d\'ici 2030 par prévention, réutilisation et recyclage.',
        titleEn: 'GHG reduction — 42% by 2030',
        descEn: 'Morocco commits to reducing GHG by 42% by 2030. Waste represents 4.7% of emissions. SDG 2030 target 12.5: reduce waste generation by 50% by 2030 through prevention, reuse and recycling.'),
    _Legal('Décret 2-20-446 (2020)', 'Renforcement sanctions (+50%)',
        Icons.gavel_rounded,
        'Révision à la hausse des amendes environnementales (+50%). Zéro tolérance pour les rejets illégaux. En cas de préjudice grave, le tribunal ordonne la remise en état du site aux frais du contrevenant.',
        titleEn: 'Tightened penalties (+50%)',
        descEn: 'Upward revision of environmental fines (+50%). Zero tolerance for illegal discharges. In case of serious damage, the court orders site restoration at the offender\'s expense.'),
    _Legal('Feuille Route Économie Circulaire 2030', 'Programme SWITCH-Med UE-Maroc',
        Icons.autorenew_rounded,
        'Adoptée en 2023 avec appui UE. 4 axes : Production Propre, Consommation Responsable, Gestion Optimisée des Déchets, Innovation & Numérique. Introduction de la consigne bouteilles verre/PET d\'ici 2026 (pilote Casa et Rabat). EcoScan s\'inscrit dans l\'Axe 4.',
        titleEn: 'EU-Morocco SWITCH-Med programme',
        descEn: 'Adopted in 2023 with EU support. 4 pillars: Clean Production, Responsible Consumption, Optimised Waste Management, Innovation & Digital. Introduction of glass/PET bottle deposit scheme by 2026 (Casa & Rabat pilot). EcoScan is part of Pillar 4.'),
  ];

  static const _operators = [
    _Operator('ECOVALOR', 'Plastique, Métal, Papier — National',
        Icons.recycling_rounded, Color(0xFF27AE60),
        'Opérateur national de valorisation. Tél : 0522 35 66 00 — Usine Aïn Sebaâ, Casablanca. Présent dans 20+ villes. Points de collecte dans Marjane, Carrefour, Label\'Vie.',
        roleEn: 'Plastic, Metal, Paper — National',
        descEn: 'National recovery operator. Tel: 0522 35 66 00 — Aïn Sebaâ plant, Casablanca. Present in 20+ cities. Collection points at Marjane, Carrefour, Label\'Vie.'),
    _Operator('AVERDA Maroc', 'Collecte & tri sélectif — National',
        Icons.local_shipping_rounded, Color(0xFF2980B9),
        'Opérateur national collecte OM. Tél : 0537 71 10 10 — Rabat. Gestion déléguée dans plusieurs villes. Camions de collecte + centres de tri.',
        roleEn: 'Collection & selective sorting — National',
        descEn: 'National household waste collection operator. Tel: 0537 71 10 10 — Rabat. Delegated management in several cities. Collection trucks + sorting centres.'),
    _Operator('SITA El Beida', 'Collecte ordures ménagères',
        Icons.delete_rounded, Color(0xFF5D6D7E),
        'Collecte et traitement des déchets ménagers. Tél : 0522 90 48 00 — Casablanca. Filiale groupe SUEZ Environnement.',
        roleEn: 'Household waste collection',
        descEn: 'Household waste collection and treatment. Tel: 0522 90 48 00 — Casablanca. Subsidiary of SUEZ Environnement group.'),
    _Operator('TECMED', 'DEEE & déchets dangereux — National',
        Icons.electrical_services_rounded, AppColors.electronics,
        'Collecte et traitement DEEE (ordinateurs, téléphones, TV). Tél : 0523 32 00 00 — Mohammedia. Sites Tanger Nord aussi. Agréé MTEDD.',
        roleEn: 'WEEE & hazardous waste — National',
        descEn: 'WEEE collection and treatment (computers, phones, TVs). Tel: 0523 32 00 00 — Mohammedia. Also at Tangier North sites. Approved by MTEDD.'),
    _Operator('Moroccan Green', 'PET & plastiques — National',
        Icons.opacity_rounded, AppColors.plastic,
        'Recyclage plastique PET et PEHD. Tél : 0522 40 09 09 — Casablanca. Collecte bouteilles PET auprès ménages et industries.',
        roleEn: 'PET & plastics — National',
        descEn: 'PET and HDPE plastic recycling. Tel: 0522 40 09 09 — Casablanca. Collects PET bottles from households and industry.'),
    _Operator('PREVOR Maroc', 'Déchets industriels dangereux',
        Icons.warning_amber_rounded, Color(0xFFE74C3C),
        'Collecte et traitement déchets industriels dangereux. Tél : 0522 23 45 67 — Casablanca. Agréé Ministère Transition Énergétique.',
        roleEn: 'Industrial hazardous waste',
        descEn: 'Industrial hazardous waste collection and treatment. Tel: 0522 23 45 67 — Casablanca. Approved by Ministry of Energy Transition.'),
    _Operator('OZONE Environnement', 'Huiles usagées & solvants',
        Icons.water_drop_rounded, Color(0xFF8E44AD),
        'Collecte et valorisation des huiles de vidange usagées et solvants industriels. Tél : 0522 88 76 54 — Casablanca.',
        roleEn: 'Used oils & solvents',
        descEn: 'Collection and recovery of used motor oils and industrial solvents. Tel: 0522 88 76 54 — Casablanca.'),
    _Operator('ECO-TLC Maroc', 'Textiles & vêtements usagés',
        Icons.checkroom_rounded, Color(0xFF9B59B6),
        'Éco-organisme pour collecte et valorisation textiles usés. Tél : 0522 55 44 33 — Casablanca. Bornes de collecte dans 15+ villes.',
        roleEn: 'Textiles & used clothing',
        descEn: 'Eco-organisation for used textile collection and recovery. Tel: 0522 55 44 33 — Casablanca. Collection bins in 15+ cities.'),
    _Operator('SOUSS RECYCLAGE', 'Multi-matériaux — Sud Maroc',
        Icons.recycling_rounded, Color(0xFF1E8449),
        'Plastique, métal, papier — toute la région Souss-Massa. Tél : 0528 83 12 34 — Agadir. Centre de tri zone industrielle.',
        roleEn: 'Multi-material — Southern Morocco',
        descEn: 'Plastic, metal, paper — entire Souss-Massa region. Tel: 0528 83 12 34 — Agadir. Sorting centre in industrial zone.'),
    _Operator('RECYCLAGE MAGHREB', 'Multi-matériaux — National',
        Icons.loop_rounded, Color(0xFF2C3E50),
        'Recyclage multi-matériaux. Tél : 0522 67 89 01 — Aïn Sebaâ, Casablanca. Partenaire industrie et collectivités.',
        roleEn: 'Multi-material — National',
        descEn: 'Multi-material recycling. Tel: 0522 67 89 01 — Aïn Sebaâ, Casablanca. Partner to industry and local authorities.'),
    _Operator('Zéro Zbel', 'ONG tri & sensibilisation',
        Icons.volunteer_activism_rounded, Color(0xFF7D6608),
        'ONG pionnière du tri au Maroc. contact@zerozabel.ma. Sensibilisation dans écoles, entreprises et communes. Programmes de compostage communautaire.',
        roleEn: 'NGO sorting & awareness',
        descEn: 'Pioneer sorting NGO in Morocco. contact@zerozabel.ma. Awareness in schools, companies and municipalities. Community composting programmes.'),
    _Operator('Green Morocco', 'Association environnement',
        Icons.park_rounded, Color(0xFF145A32),
        'Plages propres, nettoyages collectifs. Tél : 0522 55 11 22 — Casablanca. Projets recyclage communautaires et sensibilisation.',
        roleEn: 'Environmental association',
        descEn: 'Beach clean-ups, collective cleanups. Tel: 0522 55 11 22 — Casablanca. Community recycling projects and awareness campaigns.'),
  ];

  static const _impacts = [
    _Impact('Métal (alu)', '8 kg CO₂ économisés par kg recyclé', '2 700 ans', Icons.hardware_rounded, AppColors.metal,
        categoryEn: 'Metal (aluminium)', benefitEn: '8 kg CO₂ saved per kg recycled', decompEn: '2,700 years'),
    _Impact('Verre', '300 kg CO₂ économisés par tonne', '4 000 ans', Icons.local_bar_outlined, AppColors.glass,
        categoryEn: 'Glass', benefitEn: '300 kg CO₂ saved per tonne', decompEn: '4,000 years'),
    _Impact('Plastique PET', '1,5 kg CO₂ économisés par kg', '500 ans', Icons.opacity_rounded, AppColors.plastic,
        categoryEn: 'PET Plastic', benefitEn: '1.5 kg CO₂ saved per kg', decompEn: '500 years'),
    _Impact('Papier/Carton', '17 arbres sauvés par tonne', '3–6 mois', Icons.article_outlined, AppColors.paper,
        categoryEn: 'Paper/Cardboard', benefitEn: '17 trees saved per tonne', decompEn: '3–6 months'),
    _Impact('Organique', '65% des déchets marocains', '2–6 mois', Icons.compost_rounded, Color(0xFF795548),
        categoryEn: 'Organic', benefitEn: '65% of Moroccan waste', decompEn: '2–6 months'),
    _Impact('Électronique', '70 kg CO₂ économisés/ordinateur', '> 1 000 ans', Icons.electrical_services_rounded, AppColors.electronics,
        categoryEn: 'Electronics', benefitEn: '70 kg CO₂ saved/computer', decompEn: '> 1,000 years'),
    _Impact('Textile', '3 200 L d\'eau économisés/kg coton', '200 ans (synthétique)', Icons.checkroom_rounded, Color(0xFF9B59B6),
        categoryEn: 'Textile', benefitEn: '3,200 L water saved/kg cotton', decompEn: '200 years (synthetic)'),
    _Impact('Déchets dangereux', '1 L d\'huile = 1 million L d\'eau polluée', 'Permanent', Icons.warning_amber_rounded, Color(0xFFE74C3C),
        categoryEn: 'Hazardous waste', benefitEn: '1 L oil = 1 million L polluted water', decompEn: 'Permanent'),
  ];

  static const _rules = [
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Rincer avant de trier',
        'Un rinçage rapide suffit. Les emballages propres garantissent la qualité du recyclat et protègent les agents de tri.',
        titleEn: 'Rinse before sorting',
        descEn: 'A quick rinse is enough. Clean packaging guarantees recyclate quality and protects sorting workers.'),
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Ne pas emballer dans un sac plastique',
        'Les sacs plastiques sont interdits au Maroc (Loi 77-15). Déposer les emballages directement dans le bac ou la borne.',
        titleEn: 'Don\'t wrap in a plastic bag',
        descEn: 'Plastic bags are banned in Morocco (Law 77-15). Place packaging directly in the bin or drop-off point.'),
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Écraser les bouteilles et boîtes',
        'Réduire le volume pour optimiser la capacité des bacs ECOVAL et faciliter le transport jusqu\'au centre de tri.',
        titleEn: 'Crush bottles and cans',
        descEn: 'Reduce volume to optimise ECOVAL bin capacity and ease transport to the sorting centre.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Jamais de déchets dangereux dans les bacs',
        'Piles, médicaments, produits chimiques ont leurs propres filières. Ils contaminent et peuvent blesser les agents de tri.',
        titleEn: 'Never put hazardous waste in bins',
        descEn: 'Batteries, medications, chemicals have their own streams. They contaminate and can injure sorting workers.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Pas de verre brisé dans la colonne verte',
        'Emballer dans du carton épais et apporter en déchetterie. Le verre brisé blesse les agents et bloque les machines.',
        titleEn: 'No broken glass in the green column',
        descEn: 'Wrap in thick cardboard and bring to a recycling centre. Broken glass injures workers and jams machines.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Ne pas jeter dans la nature — Loi 28-00',
        'L\'abandon de déchets est une infraction pénale au Maroc. Amende et poursuites possibles. La déchetterie la plus proche est à votre service.',
        titleEn: 'Don\'t litter — Law 28-00',
        descEn: 'Littering is a criminal offence in Morocco. Fines and prosecution possible. Your nearest recycling centre is at your service.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Accès rapide ──────────────────────────────────────────────────
        _SectionHeader(s.quickAccess, Icons.rocket_launch_rounded, isDark),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: [
            _QuickAccessCard(
              icon: Icons.delete_sweep_rounded,
              label: s.guideSortingBins,
              color: const Color(0xFFF39C12),
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _BacsDetailPage(isDark: isDark))),
            ),
            _QuickAccessCard(
              icon: Icons.gavel_rounded,
              label: s.guideLegalFrame,
              color: AppColors.primary,
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _LegalDetailPage(isDark: isDark))),
            ),
            _QuickAccessCard(
              icon: Icons.bar_chart_rounded,
              label: s.guideEcoImpact,
              color: const Color(0xFF2ECC71),
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _ImpactDetailPage(isDark: isDark))),
            ),
            _QuickAccessCard(
              icon: Icons.business_rounded,
              label: s.guideOperators,
              color: const Color(0xFF3498DB),
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _OperateursDetailPage(isDark: isDark))),
            ),
            _QuickAccessCard(
              icon: Icons.star_rounded,
              label: s.guideGoldenRules,
              color: const Color(0xFF9B59B6),
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _ReglesDetailPage(isDark: isDark))),
            ),
            _QuickAccessCard(
              icon: Icons.contact_phone_rounded,
              label: s.guideContacts,
              color: const Color(0xFFE74C3C),
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _ContactsDetailPage(isDark: isDark))),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // ── Bacs de tri ───────────────────────────────────────────────────
        _SectionHeader(s.guideSortingBinsSection, Icons.delete_sweep_rounded, isDark),
        const SizedBox(height: 12),
        ...List.generate(_bins.length, (i) =>
          _BinCard(bin: _bins[i], isDark: isDark, lang: lang)
              .animate(delay: (i * 60).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05)),
        const SizedBox(height: 24),

        // ── Cadre légal ───────────────────────────────────────────────────
        _SectionHeader(s.guideLegalSection, Icons.gavel_rounded, isDark),
        const SizedBox(height: 12),
        ...List.generate(_laws.length, (i) =>
          _LegalCard(legal: _laws[i], isDark: isDark, lang: lang)
              .animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05)),
        const SizedBox(height: 24),

        // ── Impact environnemental ────────────────────────────────────────
        _SectionHeader(s.guideImpactSection, Icons.bar_chart_rounded, isDark),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: List.generate(_impacts.length, (i) {
              final imp = _impacts[i];
              final isLast = i == _impacts.length - 1;
              return _ImpactRow(impact: imp, isDark: isDark, isLast: isLast, lang: lang);
            }),
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // ── Opérateurs ────────────────────────────────────────────────────
        _SectionHeader(s.guideOperatorsSection, Icons.business_rounded, isDark),
        const SizedBox(height: 12),
        ...List.generate(_operators.length, (i) =>
          _OperatorCard(op: _operators[i], isDark: isDark, lang: lang)
              .animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05)),
        const SizedBox(height: 24),

        // ── Règles d'or ───────────────────────────────────────────────────
        _SectionHeader(s.guideGoldenRulesSection, Icons.star_rounded, isDark),
        const SizedBox(height: 12),
        ...List.generate(_rules.length, (i) =>
          _RuleCard(rule: _rules[i], isDark: isDark, lang: lang)
              .animate(delay: (i * 60).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05)),
        const SizedBox(height: 24),

        // ── Eco tip card ──────────────────────────────────────────────────
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.didYouKnow,
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.bold, color: Colors.white,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      s.guidePlasticBanFact,
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 12,
                        color: Colors.white, height: 1.4,
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

// ── Section Header ─────────────────────────────────────────────────────────────

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
        Text(title,
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            )),
      ],
    );
  }
}

// ── Bin Card ───────────────────────────────────────────────────────────────────

class _BinCard extends StatelessWidget {
  final _Bin bin;
  final bool isDark;
  final String lang;
  const _BinCard({required this.bin, required this.isDark, this.lang = 'fr'});

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
                  color: bin.color, borderRadius: BorderRadius.circular(12)),
                child: Icon(bin.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bin.nameFor(lang),
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.textPrimary,
                        )),
                    Text(bin.subtitleFor(lang),
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 11,
                          color: bin.color, fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bin.itemsFor(lang).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.only(right: 8, top: 1),
                      decoration: BoxDecoration(color: bin.color, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(item,
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Legal Card ─────────────────────────────────────────────────────────────────

class _LegalCard extends StatelessWidget {
  final _Legal legal;
  final bool isDark;
  final String lang;
  const _LegalCard({required this.legal, required this.isDark, this.lang = 'fr'});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
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
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(legal.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(legal.code,
                          style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 11,
                            fontWeight: FontWeight.bold, color: Colors.white,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(legal.titleFor(lang),
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.textPrimary,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(legal.descFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Operator Card ──────────────────────────────────────────────────────────────

class _OperatorCard extends StatelessWidget {
  final _Operator op;
  final bool isDark;
  final String lang;
  const _OperatorCard({required this.op, required this.isDark, this.lang = 'fr'});

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
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: op.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(op.icon, color: op.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(op.name,
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    )),
                Text(op.roleFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      color: op.color, fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(op.descFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, height: 1.45,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Impact Row ─────────────────────────────────────────────────────────────────

class _ImpactRow extends StatelessWidget {
  final _Impact impact;
  final bool isDark;
  final bool isLast;
  final String lang;
  const _ImpactRow({required this.impact, required this.isDark, required this.isLast, this.lang = 'fr'});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(lang);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                )),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: impact.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(impact.icon, color: impact.color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(impact.categoryFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    )),
                Text(impact.benefitFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.primary,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(s.guideDecompLabel,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                      color: AppColors.textSecondary)),
              Text(impact.decompFor(lang),
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rule Card ──────────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final _Rule rule;
  final bool isDark;
  final String lang;
  const _RuleCard({required this.rule, required this.isDark, this.lang = 'fr'});

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
                Text(rule.titleFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    )),
                const SizedBox(height: 3),
                Text(rule.descFor(lang),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ───────────────────────────────────────────────────────────────

class _Cat {
  final String name;
  final IconData icon;
  final Color color;
  const _Cat(this.name, this.icon, this.color);
}

class _Item {
  final String name;
  final String nameEn;
  final String nameAr;
  final String nameEs;
  final String category;
  final String status; // 'OUI' | 'NON' | 'COLLECTE SPÉCIALE' | 'INTERDIT'
  final String bin;
  final IconData icon;
  final Color color;
  final String tip;
  final String tipEn;
  const _Item(this.name, this.category, this.status, this.bin,
      this.icon, this.color, this.tip, {
    this.nameEn = '', this.nameAr = '', this.nameEs = '',
    this.tipEn = '',
  });
  bool get recyclable => status == 'OUI';
  String nameFor(String lang) {
    switch (lang) {
      case 'en': return nameEn.isEmpty ? name : nameEn;
      case 'ar': return nameAr.isEmpty ? name : nameAr;
      case 'es': return nameEs.isEmpty ? name : nameEs;
      default:   return name;
    }
  }
  String tipFor(String lang) {
    switch (lang) {
      case 'fr': return tip;
      default:   return tipEn.isEmpty ? tip : tipEn;
    }
  }
}

class _Bin {
  final String name;
  final String nameEn;
  final String subtitle;
  final String subtitleEn;
  final Color color;
  final IconData icon;
  final List<String> items;
  final List<String> itemsEn;
  const _Bin(this.name, this.subtitle, this.color, this.icon, this.items, {
    this.nameEn = '', this.subtitleEn = '', this.itemsEn = const [],
  });
  String nameFor(String lang) => (lang != 'fr' && nameEn.isNotEmpty) ? nameEn : name;
  String subtitleFor(String lang) => (lang != 'fr' && subtitleEn.isNotEmpty) ? subtitleEn : subtitle;
  List<String> itemsFor(String lang) => (lang != 'fr' && itemsEn.isNotEmpty) ? itemsEn : items;
}

class _Legal {
  final String code;
  final String title;
  final String titleEn;
  final IconData icon;
  final String desc;
  final String descEn;
  const _Legal(this.code, this.title, this.icon, this.desc, {
    this.titleEn = '', this.descEn = '',
  });
  String titleFor(String lang) => (lang != 'fr' && titleEn.isNotEmpty) ? titleEn : title;
  String descFor(String lang) => (lang != 'fr' && descEn.isNotEmpty) ? descEn : desc;
}

class _Operator {
  final String name;
  final String role;
  final String roleEn;
  final IconData icon;
  final Color color;
  final String desc;
  final String descEn;
  const _Operator(this.name, this.role, this.icon, this.color, this.desc, {
    this.roleEn = '', this.descEn = '',
  });
  String roleFor(String lang) => (lang != 'fr' && roleEn.isNotEmpty) ? roleEn : role;
  String descFor(String lang) => (lang != 'fr' && descEn.isNotEmpty) ? descEn : desc;
}

class _Impact {
  final String category;
  final String categoryEn;
  final String benefit;
  final String benefitEn;
  final String decomp;
  final String decompEn;
  final IconData icon;
  final Color color;
  const _Impact(this.category, this.benefit, this.decomp, this.icon, this.color, {
    this.categoryEn = '', this.benefitEn = '', this.decompEn = '',
  });
  String categoryFor(String lang) => (lang != 'fr' && categoryEn.isNotEmpty) ? categoryEn : category;
  String benefitFor(String lang)  => (lang != 'fr' && benefitEn.isNotEmpty)  ? benefitEn  : benefit;
  String decompFor(String lang)   => (lang != 'fr' && decompEn.isNotEmpty)   ? decompEn   : decomp;
}

class _Rule {
  final IconData icon;
  final Color color;
  final String title;
  final String titleEn;
  final String desc;
  final String descEn;
  const _Rule(this.icon, this.color, this.title, this.desc, {
    this.titleEn = '', this.descEn = '',
  });
  String titleFor(String lang) => (lang != 'fr' && titleEn.isNotEmpty) ? titleEn : title;
  String descFor(String lang)  => (lang != 'fr' && descEn.isNotEmpty)  ? descEn  : desc;
}

class _RegionalOp {
  final String name;
  final String specialty;
  final String phone;
  final String city;
  const _RegionalOp(this.name, this.specialty, this.phone, this.city);
}

class _RegionData {
  final String name;
  final List<_RegionalOp> ops;
  const _RegionData(this.name, this.ops);
}

class _ImpactDetail {
  final String category;
  final IconData icon;
  final Color color;
  final String co2;
  final String energy;
  final String decomp;
  final List<String> positifs;
  final List<String> negatifs;
  const _ImpactDetail({
    required this.category, required this.icon, required this.color,
    required this.co2, required this.energy, required this.decomp,
    required this.positifs, required this.negatifs,
  });
}

// ── Quick Access Card ─────────────────────────────────────────────────────────

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Detail Page base ──────────────────────────────────────────────────────────

class _DetailPageBase extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color headerColor;
  final bool isDark;
  final List<Widget> children;
  const _DetailPageBase({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.headerColor,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              boxShadow: [
                BoxShadow(
                  color: headerColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                          Text(subtitle,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bacs de tri page ──────────────────────────────────────────────────────────

class _BacsDetailPage extends ConsumerWidget {
  final bool isDark;
  const _BacsDetailPage({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    return _DetailPageBase(
      title: s.guideSortingBins,
      subtitle: s.guideSortingBinsSubtitle,
      icon: Icons.delete_sweep_rounded,
      headerColor: const Color(0xFFF39C12),
      isDark: isDark,
      children: [
        ...List.generate(_ConsignesTab._bins.length, (i) {
          final bin = _ConsignesTab._bins[i];
          return _BinCard(bin: bin, isDark: isDark, lang: lang)
              .animate(delay: (i * 60).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05);
        }),
      ],
    );
  }
}

// ── Cadre légal page ──────────────────────────────────────────────────────────

class _LegalDetailPage extends ConsumerWidget {
  final bool isDark;
  const _LegalDetailPage({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    return _DetailPageBase(
      title: s.guideLegalFrame,
      subtitle: s.guideLegalSubtitle,
      icon: Icons.gavel_rounded,
      headerColor: AppColors.primary,
      isDark: isDark,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Le Maroc dispose d\'un cadre légal complet pour la gestion des déchets. '
                  'Le non-respect de ces lois expose à des sanctions pénales et financières.',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12, height: 1.5,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_ConsignesTab._laws.length, (i) {
          return _LegalCard(legal: _ConsignesTab._laws[i], isDark: isDark, lang: lang)
              .animate(delay: (i * 50).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05);
        }),

        const SizedBox(height: 20),
        // Sanctions table header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE74C3C).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE74C3C).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.gavel_rounded, color: Color(0xFFE74C3C), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Infractions & Sanctions (Loi 28-00 — mise à jour Décret 2020)',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 10),
        ..._sanctions.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: s.$3.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 5)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: s.$3.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.warning_amber_rounded, color: s.$3, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1, style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(s.$2, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                        color: Color(0xFFE74C3C), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        )),

        const SizedBox(height: 16),
        // Normes marocaines
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(s.guideMoroccanStandards,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary)),
              ]),
              const SizedBox(height: 10),
              ..._normes.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 4, height: 4,
                      margin: const EdgeInsets.fromLTRB(2, 5, 8, 0),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  Expanded(child: RichText(text: TextSpan(children: [
                    TextSpan(text: '${n.$1} — ', style: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    TextSpan(text: n.$2, style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  ]))),
                ]),
              )),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
      ],
    );
  }

  static const _sanctions = [
    ('Dépôt illégal déchets ménagers', '500 à 5 000 DH (Loi 28-00 Art.45)', Color(0xFFE67E22)),
    ('Abandon déchets sur voie publique', '1 000 à 10 000 DH (Loi 28-00 Art.46)', Color(0xFFE67E22)),
    ('Décharge sauvage déchets industriels', '10 000 à 100 000 DH + 1 à 3 mois prison (Art.47)', Color(0xFFE74C3C)),
    ('Rejet déchets dangereux sans autorisation', '100 000 à 500 000 DH + 3 à 12 mois prison (Art.48)', Color(0xFFE74C3C)),
    ('Fabrication sacs plastiques interdits', '200 000 à 1 000 000 DH + 1 à 3 mois prison (Loi 77-15)', Color(0xFFE74C3C)),
    ('Commerce sacs plastiques interdits', '1 000 à 10 000 DH (Loi 77-15 Art.13)', Color(0xFFE67E22)),
    ('Rejet huiles usagées en milieu naturel', '50 000 à 200 000 DH + 1 à 6 mois prison', Color(0xFFE74C3C)),
    ('Traitement DEEE sans agrément', '50 000 à 500 000 DH + 3 à 12 mois prison (Décret 2-14-782)', Color(0xFFE74C3C)),
    ('Exportation illégale déchets dangereux', '500 000 à 2 000 000 DH + 6 à 24 mois (Conv. Bâle)', Color(0xFFC0392B)),
    ('Pollution délibérée nappe phréatique', '1 000 000 DH+ et jusqu\'à 5 ans de prison', Color(0xFFC0392B)),
    ('Non-déclaration déchets dangereux', '20 000 à 100 000 DH (Loi 28-00 Art.22)', Color(0xFFE67E22)),
    ('Infraction récidiviste (tous types)', 'Double de l\'amende + doublement de la peine (Art.53)', Color(0xFFE74C3C)),
  ];

  static const _normes = [
    ('NM 03.7.001', 'Classification des plastiques recyclables par code résine (1 à 7)'),
    ('NM ISO 17088', 'Plastiques biodégradables et compostables — spécifications'),
    ('NM 13.030', 'Gestion des déchets solides — terminologie et classification'),
    ('NM 10.4.034', 'Piles et accumulateurs — collecte, traitement, recyclage'),
    ('NM ISO 14044', 'Management environnemental — Analyse du Cycle de Vie (ACV)'),
    ('NM ISO 14001', 'Systèmes de management environnemental — opérateurs recyclage'),
    ('NM 31.090', 'Appareils électroménagers — conditions de reprise et recyclage'),
  ];
}

// ── Impact environnemental page ───────────────────────────────────────────────

class _ImpactDetailPage extends ConsumerWidget {
  final bool isDark;
  const _ImpactDetailPage({required this.isDark});

  static const _details = [
    _ImpactDetail(
      category: 'Métal & Aluminium',
      icon: Icons.hardware_rounded, color: AppColors.metal,
      co2: '8 kg CO₂/kg recyclé', energy: '95% énergie économisée', decomp: '2 700 ans',
      positifs: [
        'Recycler 1 kg d\'alu économise 8 kg CO₂ et évite l\'extraction de 4 kg de bauxite',
        'L\'alu peut être recyclé à l\'infini sans perdre ses propriétés mécaniques',
        '1 tonne d\'acier recyclé économise 1,1 t de minerai de fer et 630 kg de charbon',
        'Une canette recyclée économise assez d\'énergie pour alimenter une TV 3 heures',
      ],
      negatifs: [
        'L\'alu met 2 700 ans à se décomposer, libérant des oxydes métalliques toxiques',
        'La corrosion libère des ions qui contaminent les nappes phréatiques',
        'L\'extraction de bauxite détruit les écosystèmes forestiers tropicaux',
      ],
    ),
    _ImpactDetail(
      category: 'Verre',
      icon: Icons.local_bar_outlined, color: AppColors.glass,
      co2: '300 kg CO₂/tonne recyclée', energy: '26% énergie économisée', decomp: '4 000 ans',
      positifs: [
        'Recycler une tonne de verre économise 300 kg de CO₂ et 130 litres de pétrole',
        'Le verre recycle remplace 1,2 tonne de matières premières vierges',
        'Le verre est recyclable à l\'infini sans aucune perte de qualité ou de pureté',
        'Chaque bouteille recyclée économise assez d\'énergie pour éclairer une LED 4 heures',
      ],
      negatifs: [
        'Le verre met 4 000 ans à se désintégrer — le plus long de tous les matériaux courants',
        'Les éclats blessent la faune et s\'infiltrent dans la chaîne alimentaire marine',
        'L\'extraction de sable siliceux pour production neuve détruit les plages',
      ],
    ),
    _ImpactDetail(
      category: 'Plastique PET & Emballages',
      icon: Icons.opacity_rounded, color: AppColors.plastic,
      co2: '1,5 kg CO₂/kg recyclé', energy: '76% énergie économisée', decomp: '500 ans',
      positifs: [
        'Recycler 1 kg de PET économise 1,5 kg CO₂ et 17 litres d\'eau',
        '1 bouteille PET recyclée = matière première pour 2 t-shirts en polyester recyclé',
        'Le HDPE recyclé (bidons, flacons) économise 1,8 kg CO₂ par kg traité',
        'Le polypropylène recyclé réduit de 73% les émissions vs production vierge',
      ],
      negatifs: [
        'Le PET met 500 ans à se dégrader, se fragmentant en microplastiques invisibles',
        'Les microplastiques ont été retrouvés dans le sang humain, les poumons et le placenta',
        'En Méditerranée (côte marocaine), le plastique est la 1ère pollution marine observée',
      ],
    ),
    _ImpactDetail(
      category: 'Papier & Carton',
      icon: Icons.article_outlined, color: AppColors.paper,
      co2: '900 kg CO₂/tonne évités', energy: '60% énergie économisée', decomp: '3–6 mois',
      positifs: [
        'Recycler une tonne de papier sauve 17 arbres et économise 7 000 litres d\'eau',
        'Le papier journal peut être recyclé jusqu\'à 7 fois avant que les fibres soient trop courtes',
        '1 tonne de carton ondulé recyclé économise 900 kg de CO₂ équivalent',
        'Le recyclage du papier réduit les déchets en décharge et la production de méthane',
      ],
      negatifs: [
        'Bien que biodégradable (3-6 mois), le papier enfoui produit du méthane (GES x25 vs CO₂)',
        'La production de papier vierge est l\'une des industries les plus gourmandes en eau douce',
        'Les encres et vernis sur certains papiers contaminent les sols lors de la décomposition',
      ],
    ),
    _ImpactDetail(
      category: 'Déchets Organiques',
      icon: Icons.compost_rounded, color: Color(0xFF795548),
      co2: '-50% CH₄ en décharge', energy: 'Biogaz utilisable', decomp: '2–6 mois',
      positifs: [
        '65% des ordures ménagères marocaines sont organiques — le gisement le plus important',
        '1 tonne de déchets organiques compostés produit 300 kg de compost prêt à l\'emploi',
        'La méthanisation produit du biogaz utilisable comme énergie propre',
        'Composter réduit de 50% les émissions de méthane qui se produiraient en décharge',
      ],
      negatifs: [
        'En décharge, les biodéchets fermentent en anaérobie et produisent du méthane (GES 25x CO₂)',
        'Les lixiviats (jus de putréfaction) contaminent les nappes phréatiques marocaines',
        'En été au Maroc, la chaleur accélère la putréfaction et dégrade la qualité de l\'air',
      ],
    ),
    _ImpactDetail(
      category: 'Déchets Électroniques (DEEE)',
      icon: Icons.electrical_services_rounded, color: AppColors.electronics,
      co2: '70 kg CO₂/ordinateur recyclé', energy: 'Or, Cuivre, Lithium, Cobalt récupérés', decomp: '> 1 000 ans',
      positifs: [
        'Recycler un ordinateur économise 70 kg CO₂ et récupère cuivre, or, argent et palladium',
        '1 tonne de téléphones contient 250 g d\'or — 80x plus riche qu\'une mine d\'or',
        'Le recyclage du lithium réduit la dépendance aux mines d\'Amérique du Sud',
        'Le Maroc génère ~100 000 tonnes de DEEE/an — un gisement de métaux précieux',
      ],
      negatifs: [
        'Les batteries contiennent du plomb, cadmium et mercure qui s\'infiltrent dans les sols',
        'Le plomb des écrans CRT cause des maladies neurologiques graves, surtout chez les enfants',
        'Les DEEE brûlés informellement dégagent des dioxines et furanes — cancérigènes avérés',
      ],
    ),
    _ImpactDetail(
      category: 'Textiles',
      icon: Icons.checkroom_rounded, color: Color(0xFF9B59B6),
      co2: '5,5 kg CO₂/kg recyclé', energy: '3 200 L eau économisés/kg coton', decomp: '200 ans (synthétiques)',
      positifs: [
        'Recycler 1 kg de coton économise 3 200 litres d\'eau — ressource précieuse au Maroc',
        'Des vêtements en bon état donnés prolongent leur cycle de vie de 2 à 9 ans',
        '1 jean recyclé nécessite 7x moins d\'eau qu\'un jean en coton vierge',
        'Le secteur textile marocain (leader export) peut intégrer des fibres recyclées',
      ],
      negatifs: [
        'Les textiles synthétiques (polyester, nylon) mettent 200 ans à se décomposer',
        'Chaque lavage libère 700 000 microfibres plastiques dans les eaux usées',
        'Les teintures non traitées contaminent les cours d\'eau (visible dans certains oueds)',
      ],
    ),
    _ImpactDetail(
      category: 'Déchets Dangereux',
      icon: Icons.warning_amber_rounded, color: Color(0xFFE74C3C),
      co2: '1 pile = 1 m² de sol pollué 50 ans', energy: '1 L huile = 1 million L eau polluée', decomp: 'Permanent sans traitement',
      positifs: [
        'Un traitement approprié évite la contamination permanente des sols et nappes',
        'Les métaux des piles et batteries (plomb, cadmium) sont récupérables et valorisables',
        'Les huiles usagées traitées produisent un combustible alternatif pour l\'industrie',
      ],
      negatifs: [
        'Une pile jetée en décharge pollue 1 m² de sol pendant 50 ans avec mercure et cadmium',
        'Les produits chimiques enfouis migrent vers les nappes phréatiques en quelques années',
        'L\'incinération sauvage de déchets dangereux libère des dioxines cancérigènes dans l\'air',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final textPrimary = isDark ? AppColors.darkText : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;

    return _DetailPageBase(
      title: s.guideImpactSection,
      subtitle: s.guideEcoImpactSubtitle,
      icon: Icons.bar_chart_rounded,
      headerColor: const Color(0xFF2ECC71),
      isDark: isDark,
      children: [
        // Summary table
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 8)],
          ),
          child: Column(
            children: List.generate(_ConsignesTab._impacts.length, (i) {
              return _ImpactRow(
                impact: _ConsignesTab._impacts[i],
                isDark: isDark,
                isLast: i == _ConsignesTab._impacts.length - 1,
              );
            }),
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),

        // Per-category detail cards
        ...List.generate(_details.length, (i) {
          final d = _details[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: d.color.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: d.color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(d.icon, color: d.color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(d.category,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                                fontWeight: FontWeight.bold, color: textPrimary)),
                      ),
                    ],
                  ),
                ),
                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _StatChip(label: d.co2, icon: Icons.co2_rounded, color: d.color),
                      const SizedBox(width: 6),
                      _StatChip(label: d.decomp, icon: Icons.hourglass_bottom_rounded, color: Colors.orange),
                    ],
                  ),
                ),
                // Positifs
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.thumb_up_rounded, size: 13, color: Color(0xFF27AE60)),
                        const SizedBox(width: 5),
                        Text(s.guideImpactPositive, style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF27AE60))),
                      ]),
                      const SizedBox(height: 4),
                      ...d.positifs.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: 4, height: 4, margin: const EdgeInsets.fromLTRB(2, 5, 6, 0),
                              decoration: const BoxDecoration(color: Color(0xFF27AE60), shape: BoxShape.circle)),
                          Expanded(child: Text(p, style: TextStyle(fontFamily: 'Poppins',
                              fontSize: 11, height: 1.4, color: textSec))),
                        ]),
                      )),
                    ],
                  ),
                ),
                // Négatifs
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFE74C3C)),
                        const SizedBox(width: 5),
                        Text(s.guideIfNotRecycled, style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFE74C3C))),
                      ]),
                      const SizedBox(height: 4),
                      ...d.negatifs.map((n) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: 4, height: 4, margin: const EdgeInsets.fromLTRB(2, 5, 6, 0),
                              decoration: const BoxDecoration(color: Color(0xFFE74C3C), shape: BoxShape.circle)),
                          Expanded(child: Text(n, style: TextStyle(fontFamily: 'Poppins',
                              fontSize: 11, height: 1.4, color: textSec))),
                        ]),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.04);
        }),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF27AE60), Color(0xFF2ECC71)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(s.didYouKnow,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
              const SizedBox(height: 8),
              Text(
                s.guideOrganicFact,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                      fontWeight: FontWeight.w600, color: color),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Opérateurs page ───────────────────────────────────────────────────────────

class _OperateursDetailPage extends ConsumerWidget {
  final bool isDark;
  const _OperateursDetailPage({required this.isDark});

  static const _regionDir = [
    _RegionData('Casablanca-Settat', [
      _RegionalOp('LYDEC', 'Gestion déchets + signalement pollutions', '0801 00 48 48', 'Casablanca'),
      _RegionalOp('Mairie de Casablanca', 'Éco-points, collecte municipale, centres de tri', '0522 27 81 00', 'Casablanca'),
      _RegionalOp('ECOVALOR — Aïn Sebaâ', 'Tri & valorisation plastique/métal/papier', '0522 35 66 00', 'Aïn Sebaâ'),
      _RegionalOp('TECMED — Mohammedia', 'Collecte DEEE (ordi, téléphones, TV)', '0523 32 00 00', 'Mohammedia'),
      _RegionalOp('Déchetterie Lissasfa', 'Tous déchets — tous types', '0522 91 02 03', 'Lissasfa'),
      _RegionalOp('H&M Collect', 'Bornes collecte textile', '0522 20 30 40', 'Casablanca Mall'),
    ]),
    _RegionData('Rabat-Salé-Kénitra', [
      _RegionalOp('Mairie de Rabat', 'Tri sélectif, éco-points Agdal & Hassan', '0537 76 36 36', 'Rabat'),
      _RegionalOp('AVERDA — Rabat', 'Collecte OM Rabat, Salé, Témara', '0537 71 10 10', 'Rabat'),
      _RegionalOp('SITA Salé', 'Collecte & traitement déchets', '0537 85 22 33', 'Salé'),
      _RegionalOp('Centre Tri Témara', 'Tri sélectif plastique, papier, métal', '0537 74 55 66', 'Témara'),
      _RegionalOp('RADEEF / Kénitra', 'Gestion déchets Kénitra', '0537 37 10 10', 'Kénitra'),
    ]),
    _RegionData('Marrakech-Safi', [
      _RegionalOp('Mairie de Marrakech', 'Collecte OM, éco-points médina & Guéliz', '0524 44 94 95', 'Marrakech'),
      _RegionalOp('PIZZORNO Environnement', 'Collecte et traitement déchets', '0524 33 44 55', 'Marrakech'),
      _RegionalOp('Centre Tri Marrakech', 'Tri plastique, papier, métal, verre', '0524 30 20 10', 'Marrakech'),
      _RegionalOp('Déchetterie Rte Casablanca', 'Encombrants, DEEE, dangereux', '0524 31 00 00', 'Marrakech'),
    ]),
    _RegionData('Tanger-Tétouan-Al Hoceïma', [
      _RegionalOp('Mairie de Tanger', 'Collecte OM, tri sélectif, éco-points', '0539 93 27 00', 'Tanger'),
      _RegionalOp('TECMED Nord', 'DEEE, électronique, batteries', '0539 33 44 55', 'Tanger'),
      _RegionalOp('Centre Tri Tanger Med', 'Tri industriel zone portuaire', '0539 34 00 00', 'Tanger Med'),
      _RegionalOp('Mairie Tétouan', 'Collecte OM Tétouan, Martil', '0539 96 22 00', 'Tétouan'),
      _RegionalOp('Déchetterie Ibn Batouta', 'Tous déchets — triage initial', '0539 31 22 33', 'Tanger'),
    ]),
    _RegionData('Fès-Meknès', [
      _RegionalOp('Mairie de Fès', 'Collecte OM, programme tri sélectif', '0535 62 47 00', 'Fès'),
      _RegionalOp('AMENSOUSS Meknès', 'Gestion déchets Meknès', '0535 52 20 30', 'Meknès'),
      _RegionalOp('Centre Tri Sidi Brahim', 'Tri papier, plastique, métal', '0535 64 30 40', 'Fès'),
      _RegionalOp('DEEE Point Collecte Meknès', 'Électronique, piles, batteries', '0535 51 30 40', 'Meknès'),
    ]),
    _RegionData('Souss-Massa (Agadir)', [
      _RegionalOp('Mairie d\'Agadir', 'Collecte OM, éco-points Agadir', '0528 84 36 36', 'Agadir'),
      _RegionalOp('SOUSS RECYCLAGE', 'Plastique, métal, papier — toute la région', '0528 83 12 34', 'Agadir'),
      _RegionalOp('AMENSOUSS SA', 'Gestion déchets Agadir, Tiznit, Taroudant', '0528 82 30 40', 'Agadir'),
      _RegionalOp('Déchetterie Aït Melloul', 'Encombrants, DEEE, dangereux', '0528 83 50 60', 'Aït Melloul'),
    ]),
    _RegionData('Oriental (Oujda)', [
      _RegionalOp('Mairie d\'Oujda', 'Collecte OM, éco-points Oujda', '0536 68 24 00', 'Oujda'),
      _RegionalOp('RADEEO', 'Gestion déchets et eau Oujda', '0536 68 14 00', 'Oujda'),
      _RegionalOp('Centre Tri Oujda', 'Tri plastique, métal, papier', '0536 68 30 40', 'Oujda'),
      _RegionalOp('Nador Propreté', 'Collecte OM Nador, Zayo', '0536 33 22 33', 'Nador'),
    ]),
    _RegionData('Béni Mellal-Khénifra', [
      _RegionalOp('Mairie de Béni Mellal', 'Collecte OM, éco-points', '0523 48 22 00', 'Béni Mellal'),
      _RegionalOp('Centre Tri Béni Mellal', 'Plastique, papier, métal', '0523 48 30 40', 'Béni Mellal'),
      _RegionalOp('RADEE Khénifra', 'Gestion déchets Khénifra', '0535 58 10 20', 'Khénifra'),
    ]),
    _RegionData('Drâa-Tafilalet', [
      _RegionalOp('Mairie d\'Errachidia', 'Collecte OM, éco-points', '0535 57 22 00', 'Errachidia'),
      _RegionalOp('Mairie de Ouarzazate', 'Collecte OM, tri sélectif touristique', '0524 88 22 00', 'Ouarzazate'),
      _RegionalOp('ONEE — Signalement', 'Rejets illégaux, pollution eau', '0800 00 20 20', 'National'),
    ]),
    _RegionData('Laâyoune & Dakhla', [
      _RegionalOp('Mairie de Laâyoune', 'Collecte OM, gestion municipale', '0528 89 22 00', 'Laâyoune'),
      _RegionalOp('Dakhla Propreté', 'Collecte OM Dakhla', '0528 93 22 33', 'Dakhla'),
      _RegionalOp('Association Sahara Vert', 'Collecte déchets zone saharienne', '0528 89 30 40', 'Laâyoune'),
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? AppColors.darkText : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    const regionColor = Color(0xFF3498DB);

    final children = <Widget>[
      // National operators section
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: regionColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: regionColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.public_rounded, color: regionColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.guideNatOperators,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: FontWeight.bold, color: textPrimary),
              ),
            ),
          ],
        ),
      ),
      ...List.generate(_ConsignesTab._operators.length, (i) =>
          _OperatorCard(op: _ConsignesTab._operators[i], isDark: isDark)
              .animate(delay: (i * 40).ms).fadeIn(duration: 280.ms).slideX(begin: 0.04)),

      const SizedBox(height: 16),
      // Regional directory header
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            const Icon(Icons.map_rounded, color: regionColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Répertoire par Région Administrative',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: FontWeight.bold, color: textPrimary)),
            ),
          ],
        ),
      ),

      // Regions
      ...List.generate(_regionDir.length, (ri) {
        final region = _regionDir[ri];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 4),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: regionColor, borderRadius: BorderRadius.circular(2)),
                  ),
                  Text(region.name,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                          fontWeight: FontWeight.w700, color: regionColor)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03), blurRadius: 5)],
              ),
              child: Column(
                children: List.generate(region.ops.length, (oi) {
                  final op = region.ops[oi];
                  final isLast = oi == region.ops.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(
                        bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(op.name,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                      fontWeight: FontWeight.w600, color: textPrimary)),
                              Text(op.specialty,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                      color: textSec)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(op.phone,
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                    fontWeight: FontWeight.w600, color: regionColor)),
                            Text(op.city,
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                                    color: textSec)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ).animate(delay: (ri * 40).ms).fadeIn(duration: 280.ms),
          ],
        );
      }),
    ];

    return _DetailPageBase(
      title: s.guideOperators,
      subtitle: s.guideOperatorsSubtitle,
      icon: Icons.business_rounded,
      headerColor: regionColor,
      isDark: isDark,
      children: children,
    );
  }
}

// ── Règles d'or page ─────────────────────────────────────────────────────────

class _ReglesDetailPage extends ConsumerWidget {
  final bool isDark;
  const _ReglesDetailPage({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    return _DetailPageBase(
      title: s.guideGoldenRules,
      subtitle: s.guideGoldenRulesSubtitle,
      icon: Icons.star_rounded,
      headerColor: const Color(0xFF9B59B6),
      isDark: isDark,
      children: [
        ...List.generate(_ConsignesTab._rules.length, (i) {
          return _RuleCard(rule: _ConsignesTab._rules[i], isDark: isDark)
              .animate(delay: (i * 60).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05);
        }),
      ],
    );
  }
}

// ── Contacts page ─────────────────────────────────────────────────────────────

class _ContactsDetailPage extends ConsumerWidget {
  final bool isDark;
  const _ContactsDetailPage({required this.isDark});

  static const _contacts = [
    // ── Urgences ──────────────────────────────────────────────────────────────
    _ContactInfo('ONEE — Pollution Eau/Sol', '0800 00 20 20',
        'info@onee.ma', '',
        Icons.water_rounded, Color(0xFFE74C3C),
        'Numéro vert gratuit 24h/24. Signalement de tout rejet illégal, pollution eau ou sol sur le territoire national.'),
    _ContactInfo('Protection Civile', '15',
        '', '',
        Icons.local_fire_department_rounded, Color(0xFFE74C3C),
        'Urgence absolue en cas de déversement chimique accidentel, incendie de décharge ou accident industriel.'),
    _ContactInfo('Marine Royale — Pollution Marine', '10911',
        '', '',
        Icons.sailing_rounded, Color(0xFF1A5276),
        'Signalement pollution marine sur les côtes marocaines. Disponible 24h/24. Priorité côtes atlantique et méditerranée.'),
    // ── Institutions gouvernementales ─────────────────────────────────────────
    _ContactInfo('Ministère Transition Énergétique (MTEDD)', '0537 57 93 00',
        'info@environnement.gov.ma', 'www.environnement.gov.ma',
        Icons.account_balance_rounded, Color(0xFF27AE60),
        'Autorité de tutelle. Élabore la réglementation, délivre les agréments, contrôle les plans directeurs et inspecte les opérateurs.'),
    _ContactInfo('AMEE — Agence Marocaine Efficacité Énergétique', '0537 57 25 00',
        '', 'www.amee.ma',
        Icons.energy_savings_leaf_rounded, Color(0xFF2ECC71),
        'Pilote les programmes d\'économie circulaire, valorisation déchets industriels et programme AMEP plastiques.'),
    _ContactInfo('Wilaya de Casablanca', '0522 22 36 36',
        '', '',
        Icons.location_city_rounded, Color(0xFF2C3E50),
        'Urgences environnement Casablanca. Signalement pollutions, décharges sauvages et déversements chimiques dans la région.'),
    _ContactInfo('Wilaya de Rabat', '0537 72 72 72',
        '', '',
        Icons.location_city_rounded, Color(0xFF34495E),
        'Urgences environnement Rabat. Signalement pollutions, décharges sauvages et déversements chimiques dans la région.'),
    // ── ONGs nationales ────────────────────────────────────────────────────────
    _ContactInfo('Association Zéro Zbel', '',
        'contact@zerozabel.ma', 'www.zerozabel.ma',
        Icons.volunteer_activism_rounded, Color(0xFF7D6608),
        'ONG pionnière du tri sélectif au Maroc. Sensibilisation dans les écoles, entreprises et communes. Programmes de compostage.'),
    _ContactInfo('Green Morocco', '0522 55 11 22',
        '', '',
        Icons.park_rounded, Color(0xFF1E8449),
        'Plages propres, nettoyages collectifs. Projets de sensibilisation au recyclage communautaire à l\'échelle nationale.'),
    _ContactInfo('Plastic Free Morocco', '',
        'plasticfreemo@gmail.com', '',
        Icons.do_not_disturb_on_rounded, Color(0xFF8E44AD),
        'Réduction plastique à usage unique. Sensibilisation et lobbying pour l\'application stricte de la Loi 77-15.'),
    _ContactInfo('GreenWish Maroc', '0522 44 55 66',
        '', '',
        Icons.eco_rounded, Color(0xFF16A085),
        'Projets recyclage communautaires. Financement de micro-projets de tri et compostage dans les quartiers.'),
    _ContactInfo('Caritas Maroc', '0522 29 11 22',
        '', '',
        Icons.favorite_rounded, Color(0xFFE74C3C),
        'Collecte et redistribution de vêtements, objets usagés. Points de dépôt à Casablanca, Rabat, Tanger, Marrakech.'),
    _ContactInfo('Secours Catholique', '0537 73 44 55',
        '', '',
        Icons.volunteer_activism_rounded, Color(0xFFE67E22),
        'Don de vêtements et objets usagés. Redistribution aux personnes dans le besoin. Base : Rabat.'),
    // ── Régies et opérateurs ─────────────────────────────────────────────────
    _ContactInfo('ECOVALOR', '0522 35 66 00',
        '', '',
        Icons.recycling_rounded, Color(0xFF27AE60),
        'Tri et valorisation plastique/métal/papier. Usine Aïn Sebaâ, Casablanca. Principal opérateur national de recyclage matériaux.'),
    _ContactInfo('AVERDA Maroc', '0537 71 10 10',
        '', '',
        Icons.local_shipping_rounded, Color(0xFF2980B9),
        'Opérateur collecte OM dans plusieurs villes. Siège : Rabat. Gestion déléguée des déchets ménagers à l\'échelle nationale.'),
    _ContactInfo('TECMED', '0523 32 00 00',
        '', '',
        Icons.electrical_services_rounded, Color(0xFFF39C12),
        'Collecte et traitement DEEE. Sites à Mohammedia et Tanger Nord. Agréé Ministère Transition Énergétique.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    return _DetailPageBase(
      title: s.guideContacts,
      subtitle: s.guideContactsSubtitle,
      icon: Icons.contact_phone_rounded,
      headerColor: const Color(0xFFE74C3C),
      isDark: isDark,
      children: List.generate(_contacts.length, (i) {
        final c = _contacts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.color.withValues(alpha: 0.2)),
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
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(c.icon, color: c.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    if (c.phone.isNotEmpty)
                      Row(children: [
                        Icon(Icons.phone_rounded, size: 12, color: c.color),
                        const SizedBox(width: 4),
                        Text(c.phone,
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 12,
                              color: c.color, fontWeight: FontWeight.w600,
                            )),
                      ]),
                    if (c.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.email_rounded, size: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(child: Text(c.email,
                            style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 11,
                              color: AppColors.textSecondary,
                            ))),
                      ]),
                    ],
                    const SizedBox(height: 4),
                    Text(c.desc,
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 11, height: 1.4,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        )),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(delay: (i * 50).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.05);
      }),
    );
  }
}

class _ContactInfo {
  final String name;
  final String phone;
  final String email;
  final String website;
  final IconData icon;
  final Color color;
  final String desc;
  const _ContactInfo(this.name, this.phone, this.email, this.website,
      this.icon, this.color, this.desc);
}
