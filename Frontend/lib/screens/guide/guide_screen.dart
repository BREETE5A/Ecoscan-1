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
        tipEn: 'Crush to reduce volume. Rinse. Aluminium is infinitely recyclable — saves 8 kg CO₂/kg. Casablanca: orange ECOVAL bins.',
        tipAr: 'اسحق لتقليل الحجم. اشطف. الألمنيوم قابل لإعادة التدوير إلى ما لا نهاية — يوفر 8 كجم CO₂/كجم. الدار البيضاء: صناديق ECOVAL البرتقالية.',
        tipEs: 'Aplasta para reducir el volumen. Enjuaga. El aluminio es reciclable infinitamente — ahorra 8 kg CO₂/kg. Casablanca: contenedores naranja ECOVAL.'),
    _Item('Boîte conserve acier (Aïcha, Diamanor)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.inventory_rounded, AppColors.metal,
        'Rincer. Le couvercle peut rester (replier les bords). Accepté dans tous les bacs jaunes ECOVAL au Maroc.',
        nameEn: 'Steel food can (Aïcha, Diamanor)', nameAr: 'علبة فولاذية (عائشة، ديامانور)', nameEs: 'Lata de conserva de acero (Aïcha, Diamanor)',
        tipEn: 'Rinse. The lid can stay (fold the edges). Accepted in all ECOVAL yellow bins in Morocco.',
        tipAr: 'اشطف. يمكن إبقاء الغطاء (طوِّ الحواف). مقبول في جميع صناديق ECOVAL الصفراء في المغرب.',
        tipEs: 'Enjuaga. La tapa puede quedarse (dobla los bordes). Aceptado en todos los contenedores amarillos ECOVAL de Marruecos.'),
    _Item('Capsule métallique (bouteille, bocal)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.radio_button_unchecked_rounded, AppColors.metal,
        'Petites capsules : glisser dans une boîte conserve vide avant de fermer. Évite qu\'elles tombent dans les machines de tri.',
        nameEn: 'Metal cap (bottle, jar)', nameAr: 'غطاء معدني (زجاجة، برطمان)', nameEs: 'Cápsula metálica (botella, tarro)',
        tipEn: 'Small caps: slip into an empty can before closing. Prevents them from falling into sorting machines.',
        tipAr: 'الأغطية الصغيرة: ضعها في علبة حفظ فارغة قبل إغلاقها. يمنع سقوطها في آلات الفرز.',
        tipEs: 'Tapas pequeñas: introducirlas en una lata vacía antes de cerrarla. Evita que caigan en las máquinas de clasificación.'),
    _Item('Barquette aluminium (cuisine, tajine)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.takeout_dining_rounded, AppColors.metal,
        'Rincer si possible. Même légèrement souillée, elle reste recyclable. Écraser en boule.',
        nameEn: 'Aluminum tray (cooking, tajine)', nameAr: 'صينية ألمنيوم (للطبخ، طاجين)', nameEs: 'Bandeja de aluminio (cocina, tajine)',
        tipEn: 'Rinse if possible. Even slightly soiled, still recyclable. Crush into a ball.',
        tipAr: 'اشطف إن أمكن. حتى لو كانت ملوثة قليلاً لا تزال قابلة لإعادة التدوير. اسحقها في كرة.',
        tipEs: 'Enjuaga si es posible. Incluso ligeramente sucia, sigue siendo reciclable. Aplástala en bola.'),
    _Item('Papier aluminium froissé en boule', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.layers_rounded, AppColors.metal,
        'Froisser en boule compacte (min 5cm) pour faciliter le tri mécanique. Si très souillé de nourriture → poubelle.',
        nameEn: 'Crumpled aluminum foil ball', nameAr: 'ورق ألمنيوم مجعّد على شكل كرة', nameEs: 'Papel de aluminio arrugado en bola',
        tipEn: 'Crumple into a compact ball (min 5 cm) to ease mechanical sorting. If heavily soiled with food → trash.',
        tipAr: 'اجعله كرة مضغوطة (5 سم على الأقل) لتسهيل الفرز الآلي. إذا كان ملوثاً جداً بالطعام → القمامة.',
        tipEs: 'Arrugar en una bola compacta (mín. 5 cm) para facilitar la clasificación mecánica. Si está muy sucia con comida → basura.'),
    _Item('Couvercle métallique (pot, bocal)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.circle_outlined, AppColors.metal,
        'Séparer du bocal en verre et mettre dans le bac jaune. Le bocal va dans la colonne verte.',
        nameEn: 'Metal lid (jar, pot)', nameAr: 'غطاء معدني (وعاء، برطمان)', nameEs: 'Tapa metálica (tarro, frasco)',
        tipEn: 'Separate from the glass jar and put in the yellow bin. The jar goes in the green column.',
        tipAr: 'افصله عن البرطمان الزجاجي وضعه في الصندوق الأصفر. البرطمان يذهب إلى العمود الأخضر.',
        tipEs: 'Separar del tarro de vidrio y poner en el contenedor amarillo. El tarro va en la columna verde.'),
    _Item('Aérosol vide dégazé (déodorant, laque)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.air_rounded, AppColors.metal,
        'OBLIGATOIREMENT vide et dégazé (appuyer jusqu\'à silence). Ne jamais percer. Laisser le bouchon plastique.',
        nameEn: 'Empty deflated aerosol (deodorant, hairspray)', nameAr: 'بخاخ فارغ مفرّغ من الغاز (مزيل عرق، لاك)', nameEs: 'Aerosol vacío desgasificado (desodorante, laca)',
        tipEn: 'MUST be empty and deflated (press until silent). Never pierce. Leave the plastic cap on.',
        tipAr: 'يجب أن يكون فارغاً ومفرغاً من الغاز تماماً (اضغط حتى الصمت). لا تثقبه أبداً. اترك الغطاء البلاستيكي.',
        tipEs: 'DEBE estar vacío y desgasificado (presionar hasta el silencio). Nunca perforar. Dejar el tapón plástico.'),
    _Item('Boîte biscuits métal (Bimo, LU)', 'Métal', 'OUI', 'Bac jaune ECOVAL',
        Icons.cookie_rounded, AppColors.metal,
        'Retirer les emballages papier intérieurs. Écraser si possible pour réduire le volume.',
        nameEn: 'Metal biscuit tin (Bimo, LU)', nameAr: 'علبة بسكويت معدنية (بيمو، لو)', nameEs: 'Lata de galletas (Bimo, LU)',
        tipEn: 'Remove inner paper wrappings. Crush if possible to reduce volume.',
        tipAr: 'أزل الأغلفة الورقية الداخلية. اسحق إن أمكن لتقليل الحجم.',
        tipEs: 'Retirar los envoltorios de papel interiores. Aplastar si es posible para reducir el volumen.'),
    _Item('Ferraille / Casserole acier usagée', 'Métal', 'OUI', 'Déchetterie — zone métal',
        Icons.plumbing_rounded, AppColors.metal,
        'Déchetterie (zone métaux) ou ferracha. Refondu et réutilisé dans la sidérurgie marocaine.',
        nameEn: 'Scrap metal / Used steel pan', nameAr: 'خردة / قدر فولاذي مستعمل', nameEs: 'Chatarra / Cazuela de acero usada',
        tipEn: 'Recycling center (metal zone) or ferracha. Remelted and reused in Moroccan steel industry.',
        tipAr: 'مركز إعادة التدوير (منطقة المعادن) أو الفراشة. يُعاد صهره واستخدامه في صناعة الصلب المغربية.',
        tipEs: 'Centro de reciclaje (zona de metales) o ferracha. Refundido y reutilizado en la industria siderúrgica marroquí.'),
    _Item('Pile alcaline (AA, AAA, 9V)', 'Métal', 'NON', 'Collecteur piles',
        Icons.battery_full_rounded, AppColors.metal,
        'JAMAIS au bac jaune ! Contient mercure, cadmium. Déposer dans les collecteurs en supermarché (Marjane, Carrefour, Label\'Vie).',
        nameEn: 'Alkaline battery (AA, AAA, 9V)', nameAr: 'بطارية قلوية (AA، AAA، 9V)', nameEs: 'Pila alcalina (AA, AAA, 9V)',
        tipEn: 'NEVER in the yellow bin! Contains mercury, cadmium. Drop off at supermarket collectors (Marjane, Carrefour, Label\'Vie).',
        tipAr: 'لا تضعها في الصندوق الأصفر أبداً! تحتوي على الزئبق والكادميوم. أودعها في جامعي البطاريات بالسوبرماركت (مرجان، كارفور، لابيل في).',
        tipEs: 'NUNCA en el contenedor amarillo. Contiene mercurio, cadmio. Depositar en los colectores de supermercados (Marjane, Carrefour, Label\'Vie).'),
    _Item('Aérosol non vide / sous pression', 'Métal', 'NON', 'Déchetterie — dangereux',
        Icons.dangerous_rounded, AppColors.metal,
        'Risque d\'explosion. Déchetterie zone produits dangereux. Ne jamais percer ni jeter à la poubelle ordinaire.',
        nameEn: 'Non-empty / pressurized aerosol', nameAr: 'بخاخ غير فارغ / تحت ضغط', nameEs: 'Aerosol no vacío / a presión',
        tipEn: 'Risk of explosion. Recycling center hazardous zone. Never pierce or throw in regular trash.',
        tipAr: 'خطر انفجار. مركز إعادة التدوير منطقة المنتجات الخطرة. لا تثقبه ولا ترميه في القمامة العادية.',
        tipEs: 'Riesgo de explosión. Centro de reciclaje zona peligrosa. Nunca perforar ni tirar en la basura normal.'),
    _Item('Boîte peinture métal avec résidus', 'Métal', 'NON', 'Déchetterie — dangereux',
        Icons.format_paint_rounded, AppColors.metal,
        'Les résidus de peinture contaminent. Déchetterie zone produits dangereux. Si complètement sèche et vide → bac jaune.',
        nameEn: 'Metal paint can with residue', nameAr: 'علبة طلاء معدنية مع بقايا', nameEs: 'Lata de pintura metálica con residuos',
        tipEn: 'Paint residues contaminate. Recycling center hazardous zone. If completely dry and empty → yellow bin.',
        tipAr: 'بقايا الطلاء تلوّث. مركز إعادة التدوير منطقة المنتجات الخطرة. إذا كانت جافة تماماً وفارغة → الصندوق الأصفر.',
        tipEs: 'Los residuos de pintura contaminan. Centro de reciclaje zona peligrosa. Si está completamente seca y vacía → contenedor amarillo.'),

    // ── VERRE ─────────────────────────────────────────────────────────────────
    _Item('Bouteille verre (Sidi Ali, Ain Atlas, Oulmes)', 'Verre', 'OUI', 'Colonne verte',
        Icons.local_bar_outlined, AppColors.glass,
        'Rincer. Ne pas casser. Le bouchon métallique peut rester ou aller au bac jaune. Colonne verte = uniquement verre creux.',
        nameEn: 'Glass bottle (Sidi Ali, Ain Atlas, Oulmes)', nameAr: 'زجاجة زجاجية (سيدي علي، عين أطلس، أولمس)', nameEs: 'Botella de vidrio (Sidi Ali, Ain Atlas, Oulmes)',
        tipEn: 'Rinse. Do not break. Metal cap can stay or go in yellow bin. Green column = hollow glass only.',
        tipAr: 'اشطف. لا تكسر. يمكن إبقاء الغطاء المعدني أو وضعه في الصندوق الأصفر. العمود الأخضر = زجاج مجوف فقط.',
        tipEs: 'Enjuaga. No romper. El tapón metálico puede quedarse o ir al contenedor amarillo. Columna verde = solo vidrio hueco.'),
    _Item('Bocal confiture / conserve (Aïcha, Aicha)', 'Verre', 'OUI', 'Colonne verte',
        Icons.lunch_dining_rounded, AppColors.glass,
        'Rincer rapidement. Couvercle métallique → bac jaune. Bocal verre → colonne verte. Ne pas emballer dans un sac plastique.',
        nameEn: 'Jam / preserve jar (Aïcha)', nameAr: 'برطمان مربى / مربيات (عائشة)', nameEs: 'Tarro de mermelada / conserva (Aïcha)',
        tipEn: 'Quick rinse. Metal lid → yellow bin. Glass jar → green column. Do not wrap in a plastic bag.',
        tipAr: 'شطف سريع. الغطاء المعدني → صندوق أصفر. البرطمان الزجاجي → عمود أخضر. لا تلفّه في كيس بلاستيكي.',
        tipEs: 'Enjuague rápido. Tapa metálica → contenedor amarillo. Tarro de vidrio → columna verde. No envolver en bolsa plástica.'),
    _Item('Pot bébé (Blédina, Nestlé Bébé)', 'Verre', 'OUI', 'Colonne verte',
        Icons.child_care_rounded, AppColors.glass,
        'Rincer. Très recyclable. Même les petits pots sont acceptés. Colonne verte des villes (Casablanca, Rabat, Marrakech).',
        nameEn: 'Baby food jar (Blédina, Nestlé Bébé)', nameAr: 'برطمان غذاء الأطفال (بليدينا، نستله بيبي)', nameEs: 'Tarro para bebé (Blédina, Nestlé Bébé)',
        tipEn: 'Rinse. Very recyclable. Even small jars are accepted. Green column in cities (Casablanca, Rabat, Marrakech).',
        tipAr: 'اشطف. قابل للتدوير كثيراً. حتى البرطمانات الصغيرة مقبولة. العمود الأخضر في المدن (الدار البيضاء، الرباط، مراكش).',
        tipEs: 'Enjuaga. Muy reciclable. Incluso los tarros pequeños son aceptados. Columna verde en ciudades (Casablanca, Rabat, Marrakech).'),
    _Item('Flacon parfum en verre', 'Verre', 'OUI', 'Colonne verte',
        Icons.spa_rounded, AppColors.glass,
        'Vider complètement. Retirer la pompe plastique si possible (va à la poubelle ordinaire). Le verre → colonne verte.',
        nameEn: 'Glass perfume bottle', nameAr: 'قارورة عطر زجاجية', nameEs: 'Frasco de perfume de vidrio',
        tipEn: 'Empty completely. Remove the plastic pump if possible (goes in regular trash). Glass → green column.',
        tipAr: 'افرغه تماماً. أزل مضخة البلاستيك إن أمكن (تذهب إلى القمامة العادية). الزجاج → عمود أخضر.',
        tipEs: 'Vaciar completamente. Retirar la bomba de plástico si es posible (va a la basura normal). Vidrio → columna verde.'),
    _Item('Carafe / vase en verre ordinaire', 'Verre', 'OUI', 'Colonne verte',
        Icons.local_drink_rounded, AppColors.glass,
        'Verre ordinaire recyclable. Ne pas confondre avec cristal (non recyclable). Déposer doucement pour éviter la casse.',
        nameEn: 'Glass carafe / vase', nameAr: 'إبريق / مزهرية زجاجية عادية', nameEs: 'Jarra / jarrón de vidrio ordinario',
        tipEn: 'Ordinary glass is recyclable. Do not confuse with crystal (not recyclable). Place gently to avoid breakage.',
        tipAr: 'الزجاج العادي قابل لإعادة التدوير. لا تخلط مع الكريستال (غير قابل للتدوير). ضعه برفق لتجنب الكسر.',
        tipEs: 'El vidrio ordinario es reciclable. No confundir con el cristal (no reciclable). Colocar suavemente para evitar rotura.'),
    _Item('Pot de miel en verre', 'Verre', 'OUI', 'Colonne verte',
        Icons.emoji_nature_rounded, AppColors.glass,
        'Rincer à l\'eau tiède pour décoller le miel. Couvercle métallique → bac jaune. Accepté dans toutes les colonnes vertes.',
        nameEn: 'Glass honey jar', nameAr: 'برطمان عسل زجاجي', nameEs: 'Tarro de miel de vidrio',
        tipEn: 'Rinse with warm water to dissolve honey. Metal lid → yellow bin. Accepted in all green columns.',
        tipAr: 'اشطفه بالماء الدافئ لإذابة العسل. الغطاء المعدني → صندوق أصفر. مقبول في جميع الأعمدة الخضراء.',
        tipEs: 'Enjuagar con agua tibia para disolver la miel. Tapa metálica → contenedor amarillo. Aceptado en todas las columnas verdes.'),
    _Item('Verre brisé / cassé', 'Verre', 'NON', 'Déchetterie (carton épais)',
        Icons.broken_image_rounded, AppColors.glass,
        'DANGER : blesse les agents de tri. Envelopper dans du carton épais et du ruban adhésif. Jamais dans la colonne verte.',
        nameEn: 'Broken / shattered glass', nameAr: 'زجاج مكسور', nameEs: 'Vidrio roto / quebrado',
        tipEn: 'DANGER: injures sorting workers. Wrap in thick cardboard and tape. Never in the green column.',
        tipAr: 'خطر: يُصيب عمال الفرز. لفّ في كرتون سميك وشريط لاصق. لا تضعه أبداً في العمود الأخضر.',
        tipEs: 'PELIGRO: lesiona a los trabajadores de clasificación. Envolver en cartón grueso y cinta adhesiva. Nunca en la columna verde.'),
    _Item('Miroir', 'Verre', 'NON', 'Déchetterie',
        Icons.square_rounded, AppColors.glass,
        'Composition chimique différente du verre ordinaire (revêtement argenté). Non recyclable avec le verre. Déchetterie.',
        nameEn: 'Mirror', nameAr: 'مرآة', nameEs: 'Espejo',
        tipEn: 'Different chemical composition from ordinary glass (silver coating). Not recyclable with glass. Recycling center.',
        tipAr: 'تركيبة كيميائية مختلفة عن الزجاج العادي (طلاء فضي). غير قابل للتدوير مع الزجاج. مركز إعادة التدوير.',
        tipEs: 'Composición química diferente del vidrio ordinario (revestimiento plateado). No reciclable con el vidrio. Centro de reciclaje.'),
    _Item('Verre trempé (pare-brise, vitre auto)', 'Verre', 'NON', 'Déchetterie',
        Icons.directions_car_rounded, AppColors.glass,
        'Traitement thermique spécial incompatible avec le recyclage du verre ordinaire. Casse en miettes → contamination.',
        nameEn: 'Tempered glass (windshield, car window)', nameAr: 'زجاج مقسّى (زجاج سيارة)', nameEs: 'Vidrio templado (parabrisas, ventana de auto)',
        tipEn: 'Special heat treatment incompatible with ordinary glass recycling. Crumbles into tiny pieces → contamination.',
        tipAr: 'معالجة حرارية خاصة غير متوافقة مع تدوير الزجاج العادي. يتكسر إلى فتات → تلوث.',
        tipEs: 'Tratamiento térmico especial incompatible con el reciclaje del vidrio ordinario. Se desmenuza → contaminación.'),
    _Item('Pyrex / plat en verre réfractaire', 'Verre', 'NON', 'Déchetterie',
        Icons.microwave_rounded, AppColors.glass,
        'Borosilicate : point de fusion différent. Contamine le lot de verre recyclé. Déchetterie ou don si en bon état.',
        nameEn: 'Pyrex / heat-resistant glass dish', nameAr: 'باير / طبق زجاجي مقاوم للحرارة', nameEs: 'Pyrex / plato de vidrio refractario',
        tipEn: 'Borosilicate: different melting point. Contaminates recycled glass batch. Recycling center or donate if in good condition.',
        tipAr: 'بوروسيليكات: نقطة انصهار مختلفة. يلوّث مجموعة الزجاج المُعاد تدويره. مركز إعادة التدوير أو تبرّع إذا كان بحالة جيدة.',
        tipEs: 'Borosilicato: punto de fusión diferente. Contamina el lote de vidrio reciclado. Centro de reciclaje o donar si está en buen estado.'),
    _Item('Faïence / céramique / porcelaine', 'Verre', 'NON', 'Déchetterie',
        Icons.emoji_food_beverage_rounded, AppColors.glass,
        'Pas du verre ! Composition totalement différente. Déchetterie ou ressourcerie si intact. Jamais dans la colonne verte.',
        nameEn: 'Earthenware / ceramic / porcelain', nameAr: 'فخار / سيراميك / خزف', nameEs: 'Loza / cerámica / porcelana',
        tipEn: 'Not glass! Completely different composition. Recycling center or charity if intact. Never in the green column.',
        tipAr: 'ليس زجاجاً! تركيبة مختلفة تماماً. مركز إعادة التدوير أو الجمعيات إذا كان سليماً. أبداً في العمود الأخضر.',
        tipEs: 'No es vidrio. Composición completamente diferente. Centro de reciclaje o donación si está intacto. Nunca en la columna verde.'),
    _Item('Ampoule (toute technologie)', 'Verre', 'NON', 'Point luminaire',
        Icons.lightbulb_outlined, AppColors.glass,
        'Points de collecte luminaires : grandes surfaces bricolage (Bricoma, Mr. Bricolage), déchetterie. LED et fluocompactes = DEEE.',
        nameEn: 'Light bulb (any type)', nameAr: 'مصباح (أي نوع)', nameEs: 'Bombilla (cualquier tipo)',
        tipEn: 'Collection points: DIY stores (Bricoma, Mr. Bricolage), recycling center. LED and CFL = WEEE.',
        tipAr: 'نقاط جمع الإضاءة: متاجر الأدوات (بريكوما، مستر بريكولاج)، مركز إعادة التدوير. LED وموفر الطاقة = DEEE.',
        tipEs: 'Puntos de recogida: tiendas de bricolaje (Bricoma, Mr. Bricolage), centro de reciclaje. LED y CFL = RAEE.'),

    // ── ORGANIQUE ─────────────────────────────────────────────────────────────
    _Item('Épluchures fruits et légumes', 'Organique', 'OUI', 'Composteur / Bac marron',
        Icons.eco_rounded, Color(0xFF795548),
        'Représente 65% des déchets marocains. Idéal pour compost maison (balcon ou jardin). Se décompose en 2-6 mois.',
        nameEn: 'Fruit and vegetable peels', nameAr: 'قشور الفواكه والخضروات', nameEs: 'Cáscaras de frutas y verduras',
        tipEn: 'Represents 65% of Moroccan waste. Ideal for home compost (balcony or garden). Decomposes in 2–6 months.',
        tipAr: 'تمثل 65% من النفايات المغربية. مثالية لسماد منزلي (شرفة أو حديقة). تتحلل في 2-6 أشهر.',
        tipEs: 'Representa el 65% de los residuos marroquíes. Ideal para compost casero (balcón o jardín). Se descompone en 2-6 meses.'),
    _Item('Marc de café (Cafés Najjar, Bouskoura)', 'Organique', 'OUI', 'Composteur',
        Icons.coffee_rounded, Color(0xFF795548),
        'Excellent activateur de compost. Mélanger avec des matières sèches (feuilles mortes). Améliore la structure du sol.',
        nameEn: 'Coffee grounds (Najjar, Bouskoura)', nameAr: 'تفل القهوة (نجار، بوسكورة)', nameEs: 'Posos de café (Najjar, Bouskoura)',
        tipEn: 'Excellent compost activator. Mix with dry materials (dead leaves). Improves soil structure.',
        tipAr: 'محفز ممتاز للسماد. اخلطه مع المواد الجافة (أوراق جافة). يحسّن بنية التربة.',
        tipEs: 'Excelente activador de compost. Mezclar con materiales secos (hojas muertas). Mejora la estructura del suelo.'),
    _Item('Sachets thé usagés (Lipton, Atay Baraka)', 'Organique', 'OUI', 'Composteur',
        Icons.local_cafe_rounded, Color(0xFF795548),
        'Enlever les agrafes métalliques avant de composter. Certains sachets synthétiques (nylon) → poubelle ordinaire.',
        nameEn: 'Used tea bags (Lipton, Atay Baraka)', nameAr: 'أكياس شاي مستعملة (ليبتون، أتاي بركة)', nameEs: 'Bolsas de té usadas (Lipton, Atay Baraka)',
        tipEn: 'Remove metal staples before composting. Some synthetic bags (nylon) → regular trash.',
        tipAr: 'أزل الدبابيس المعدنية قبل التسميد. بعض الأكياس الاصطناعية (نايلون) → القمامة العادية.',
        tipEs: 'Retirar las grapas metálicas antes de compostar. Algunas bolsas sintéticas (nylon) → basura normal.'),
    _Item('Restes de pain / harcha / msemen', 'Organique', 'OUI', 'Composteur',
        Icons.breakfast_dining_rounded, Color(0xFF795548),
        'Déchirer en petits morceaux pour accélérer la décomposition. Attention : dans un composteur ouvert, peut attirer des oiseaux.',
        nameEn: 'Leftover bread / harcha / msemen', nameAr: 'بقايا الخبز / الهرشة / المسمن', nameEs: 'Sobras de pan / harcha / msemen',
        tipEn: 'Tear into small pieces to speed decomposition. Note: in an open composter, may attract birds.',
        tipAr: 'قطّعه إلى قطع صغيرة لتسريع التحلل. ملاحظة: في السماد المفتوح قد يجذب الطيور.',
        tipEs: 'Trocear en piezas pequeñas para acelerar la descomposición. Nota: en un compostador abierto puede atraer aves.'),
    _Item('Coquilles d\'œuf', 'Organique', 'OUI', 'Composteur',
        Icons.egg_outlined, Color(0xFF795548),
        'Écraser avant de composter — apportent du calcium au sol. Se décomposent lentement (1 an). Excellent pour rééquilibrer le pH.',
        nameEn: 'Eggshells', nameAr: 'قشور البيض', nameEs: 'Cáscaras de huevo',
        tipEn: 'Crush before composting — provide calcium to the soil. Decompose slowly (1 year). Great for rebalancing pH.',
        tipAr: 'اسحق قبل التسميد — تمد التربة بالكالسيوم. تتحلل ببطء (سنة واحدة). ممتازة لإعادة توازن درجة الحموضة.',
        tipEs: 'Triturar antes de compostar — aportan calcio al suelo. Se descomponen lentamente (1 año). Ideal para reequilibrar el pH.'),
    _Item('Feuilles mortes / gazon / herbes', 'Organique', 'OUI', 'Composteur',
        Icons.grass_rounded, Color(0xFF795548),
        'Mélanger vert (azote : feuilles fraîches, épluchures) et sec (carbone : feuilles mortes, carton). Rapport idéal 1/3 vert, 2/3 sec.',
        nameEn: 'Dead leaves / lawn clippings / plants', nameAr: 'أوراق جافة / عشب / نباتات', nameEs: 'Hojas secas / césped / hierba',
        tipEn: 'Mix green (nitrogen: fresh leaves, peels) and dry (carbon: dead leaves, cardboard). Ideal ratio: 1/3 green, 2/3 dry.',
        tipAr: 'اخلط الأخضر (النيتروجين: أوراق طازجة، قشور) مع الجاف (الكربون: أوراق جافة، كرتون). النسبة المثلى: 1/3 أخضر، 2/3 جاف.',
        tipEs: 'Mezclar verde (nitrógeno: hojas frescas, cáscaras) y seco (carbono: hojas muertas, cartón). Proporción ideal: 1/3 verde, 2/3 seco.'),
    _Item('Sciure de bois non traité', 'Organique', 'OUI', 'Composteur',
        Icons.carpenter_rounded, Color(0xFF795548),
        'Bon apport de carbone pour le compost. Uniquement bois naturel non peint, non verni. Pas de panneaux agglomérés (colle chimique).',
        nameEn: 'Untreated sawdust', nameAr: 'نشارة خشب غير معالج', nameEs: 'Serrín de madera sin tratar',
        tipEn: 'Good carbon input for compost. Only untreated, unpainted, unvarnished wood. No chipboard (chemical glue).',
        tipAr: 'إدخال جيد للكربون في السماد. خشب طبيعي غير مطلي وغير مورنش فقط. لا ألواح حبيبية (غراء كيميائي).',
        tipEs: 'Buena aportación de carbono para el compost. Solo madera natural sin pintar ni barnizar. No aglomerados (pegamento químico).'),
    _Item('Carton déchiré non imprimé', 'Organique', 'OUI', 'Composteur',
        Icons.inventory_2_rounded, Color(0xFF795548),
        'En petits morceaux humidifiés. Apport de carbone. Éviter carton imprimé (encres) ou ciré. Préférer le bac bleu si propre.',
        nameEn: 'Torn unprinted cardboard', nameAr: 'كرتون ممزق غير مطبوع', nameEs: 'Cartón roto sin imprimir',
        tipEn: 'In small dampened pieces. Carbon input. Avoid printed or waxed cardboard. Prefer the blue bin if clean.',
        tipAr: 'قطع صغيرة مبللة. مصدر للكربون. تجنب الكرتون المطبوع (أحبار) أو المشمّع. يفضّل الصندوق الأزرق إذا كان نظيفاً.',
        tipEs: 'En trozos pequeños humedecidos. Aportación de carbono. Evitar cartón impreso o encerado. Preferir el contenedor azul si está limpio.'),
    _Item('Viande et poisson (restes)', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.set_meal_rounded, Color(0xFF795548),
        'Attire rongeurs et insectes dans un composteur ouvert. Poubelle ordinaire. Exception : composteur fermé en biogaz (collectivités).',
        nameEn: 'Meat and fish leftovers', nameAr: 'بقايا اللحم والسمك', nameEs: 'Sobras de carne y pescado',
        tipEn: 'Attracts rodents and insects in an open composter. Regular trash. Exception: sealed biogas composter (municipalities).',
        tipAr: 'يجذب القوارض والحشرات في سماد مفتوح. القمامة العادية. استثناء: سماد غاز حيوي مغلق (البلديات).',
        tipEs: 'Atrae roedores e insectos en un compostador abierto. Basura normal. Excepción: compostador de biogás sellado (municipios).'),
    _Item('Produits laitiers (yaourt, fromage)', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.local_drink_rounded, Color(0xFF795548),
        'Fermentation rapide = odeurs et nuisibles. Poubelle ordinaire. Les emballages plastiques/carton → bacs recyclage.',
        nameEn: 'Dairy products (yogurt, cheese)', nameAr: 'منتجات الألبان (زبادي، جبن)', nameEs: 'Productos lácteos (yogur, queso)',
        tipEn: 'Fast fermentation = odors and pests. Regular trash. Plastic/cardboard packaging → recycling bins.',
        tipAr: 'تخمّر سريع = روائح وآفات. القمامة العادية. أغلفة البلاستيك/الكرتون → صناديق إعادة التدوير.',
        tipEs: 'Fermentación rápida = olores y plagas. Basura normal. Envases de plástico/cartón → contenedores de reciclaje.'),
    _Item('Huile de cuisson usagée', 'Organique', 'NON', 'Collecte spéciale huile',
        Icons.oil_barrel_rounded, Color(0xFF795548),
        'JAMAIS dans l\'évier (bouche les canalisations). Solidifier dans un contenant fermé → poubelle, ou rapporter en collecte spéciale.',
        nameEn: 'Used cooking oil', nameAr: 'زيت الطهي المستعمل', nameEs: 'Aceite de cocina usado',
        tipEn: 'NEVER down the sink (clogs pipes). Solidify in a sealed container → trash, or return to a special collection point.',
        tipAr: 'لا تصبّه في المصرف أبداً (يسد الأنابيب). يصلّب في وعاء مغلق → قمامة، أو يُعاد إلى نقطة جمع خاصة.',
        tipEs: 'NUNCA por el desagüe (obstruye tuberías). Solidificar en recipiente sellado → basura, o devolver a un punto de recogida especial.'),
    _Item('Couches bébé / protection hygiénique', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.child_friendly_rounded, Color(0xFF795548),
        'Non recyclables et non compostables. Poubelle ordinaire. Des filières spécialisées émergent mais pas encore au Maroc.',
        nameEn: 'Baby diapers / hygiene protection', nameAr: 'حفاضات الأطفال / الحماية الصحية', nameEs: 'Pañales / protección higiénica',
        tipEn: 'Non-recyclable and non-compostable. Regular trash. Specialized streams are emerging but not yet in Morocco.',
        tipAr: 'غير قابلة للتدوير وغير قابلة للتسميد. القمامة العادية. أنظمة متخصصة ناشئة لكن غير موجودة بعد في المغرب.',
        tipEs: 'No reciclables ni compostables. Basura normal. Sistemas especializados emergentes pero aún no en Marruecos.'),
    _Item('Cendres froides (barbecue, cheminée)', 'Organique', 'NON', 'Poubelle ordinaire',
        Icons.local_fire_department_rounded, Color(0xFF795548),
        'En très petite quantité dans le compost si froid (apport de potasse). En grande quantité → poubelle. Jamais chaude.',
        nameEn: 'Cold ashes (barbecue, fireplace)', nameAr: 'رماد بارد (شواء، مدفأة)', nameEs: 'Cenizas frías (barbacoa, chimenea)',
        tipEn: 'In very small cold amounts in compost (potassium input). In large quantities → trash. Never while still hot.',
        tipAr: 'بكميات صغيرة جداً وباردة في السماد (مصدر البوتاسيوم). بكميات كبيرة → قمامة. لا تضعها ساخنة أبداً.',
        tipEs: 'En cantidades muy pequeñas y frías en el compost (aporte de potasio). En grandes cantidades → basura. Nunca caliente.'),

    // ── ÉLECTRONIQUE ──────────────────────────────────────────────────────────
    _Item('Smartphone / Téléphone portable', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.phone_android_rounded, AppColors.electronics,
        'Décret 2-12-695 : reprise obligatoire. ECOVAL rembourse jusqu\'à 500 DH. Points ECOVAL : Marjane, Carrefour, Cosmos Electro.',
        nameEn: 'Smartphone / Mobile phone', nameAr: 'هاتف ذكي / جوّال', nameEs: 'Smartphone / Teléfono móvil',
        tipEn: 'Decree 2-12-695: mandatory take-back. ECOVAL reimburses up to 500 DH. ECOVAL points: Marjane, Carrefour, Cosmos Electro.',
        tipAr: 'المرسوم 2-12-695: استرداد إلزامي. ECOVAL تدفع حتى 500 درهم. نقاط ECOVAL: مرجان، كارفور، كوزمو إلكترو.',
        tipEs: 'Decreto 2-12-695: recogida obligatoria. ECOVAL reembolsa hasta 500 DH. Puntos ECOVAL: Marjane, Carrefour, Cosmos Electro.'),
    _Item('Tablette / iPad', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.tablet_rounded, AppColors.electronics,
        'Effacer les données avant dépôt (réinitialisation usine). Contient lithium, coltan, or — métaux précieux valorisables.',
        nameEn: 'Tablet / iPad', nameAr: 'لوحي / آيباد', nameEs: 'Tableta / iPad',
        tipEn: 'Erase data before drop-off (factory reset). Contains lithium, coltan, gold — valuable recoverable metals.',
        tipAr: 'امسح البيانات قبل التسليم (إعادة ضبط المصنع). يحتوي على ليثيوم وكولتان وذهب — معادن ثمينة قابلة للاسترداد.',
        tipEs: 'Borrar datos antes de la entrega (restablecimiento de fábrica). Contiene litio, coltán, oro — metales preciosos recuperables.'),
    _Item('Ordinateur / Laptop', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL / Déchetterie',
        Icons.laptop_rounded, AppColors.electronics,
        'Effacer le disque dur (formatage complet). ECOVAL ou déchetterie zone DEEE. Certains constructeurs proposent la reprise gratuite.',
        nameEn: 'Computer / Laptop', nameAr: 'حاسوب / كمبيوتر محمول', nameEs: 'Ordenador / Portátil',
        tipEn: 'Erase the hard drive (full format). ECOVAL or recycling center WEEE zone. Some manufacturers offer free take-back.',
        tipAr: 'امسح القرص الصلب (تنسيق كامل). ECOVAL أو مركز إعادة التدوير منطقة DEEE. بعض المصنعين يقدمون استرداداً مجانياً.',
        tipEs: 'Borrar el disco duro (formato completo). ECOVAL o centro RAEE. Algunos fabricantes ofrecen recogida gratuita.'),
    _Item('Télévision / Écran PC', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.tv_rounded, AppColors.electronics,
        'Reprise 1 pour 1 chez le vendeur à l\'achat d\'un neuf (obligation légale). Ou éco-point ECOVAL. Contient plomb dans les anciens CRT.',
        nameEn: 'TV / Computer screen', nameAr: 'تلفزيون / شاشة كمبيوتر', nameEs: 'Televisión / Pantalla PC',
        tipEn: '1-for-1 take-back when buying new (legal obligation). Or ECOVAL point. Old CRT models contain lead.',
        tipAr: 'استرداد 1 مقابل 1 عند شراء جديد (التزام قانوني). أو نقطة ECOVAL. الأجهزة القديمة CRT تحتوي على رصاص.',
        tipEs: 'Recogida 1 por 1 al comprar uno nuevo (obligación legal). O punto ECOVAL. Los modelos CRT antiguos contienen plomo.'),
    _Item('Réfrigérateur / Congélateur', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.kitchen_rounded, AppColors.electronics,
        'Gros électroménager : ECOVAL organise la collecte à domicile. Contient des frigorigènes (gaz à effet de serre) à traiter.',
        nameEn: 'Refrigerator / Freezer', nameAr: 'ثلاجة / مجمّد', nameEs: 'Refrigerador / Congelador',
        tipEn: 'ECOVAL arranges home collection for large appliances. Contains refrigerants (greenhouse gases) to be treated.',
        tipAr: 'ECOVAL تنظم الجمع المنزلي للأجهزة الكبيرة. يحتوي على مبردات (غازات دفيئة) تحتاج إلى معالجة.',
        tipEs: 'ECOVAL organiza la recogida a domicilio para grandes electrodomésticos. Contiene refrigerantes (gases de efecto invernadero) a tratar.'),
    _Item('Machine à laver / Lave-vaisselle', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.local_laundry_service_rounded, AppColors.electronics,
        'Reprise possible par le vendeur. ECOVAL organise collecte. Récupération du cuivre des moteurs et de l\'acier inoxydable.',
        nameEn: 'Washing machine / Dishwasher', nameAr: 'غسالة / غسالة أطباق', nameEs: 'Lavadora / Lavavajillas',
        tipEn: 'Take-back possible by the retailer. ECOVAL arranges collection. Copper from motors and stainless steel are recovered.',
        tipAr: 'استرداد ممكن من البائع. ECOVAL تنظم الجمع. استرداد النحاس من المحركات والفولاذ المقاوم للصدأ.',
        tipEs: 'Recogida posible por el vendedor. ECOVAL organiza la recogida. Se recupera el cobre de los motores y el acero inoxidable.'),
    _Item('Climatiseur / Split (unité intérieure)', 'Électronique', 'COLLECTE SPÉCIALE', 'Technicien agréé',
        Icons.ac_unit_rounded, AppColors.electronics,
        'Le frigorigène doit être récupéré par un technicien agréé avant démontage. Puis éco-point ECOVAL pour le reste.',
        nameEn: 'Air conditioner / Split unit (indoor)', nameAr: 'مكيف هواء / وحدة داخلية', nameEs: 'Aire acondicionado / Split (unidad interior)',
        tipEn: 'Refrigerant must be recovered by a certified technician before dismantling. Then ECOVAL point for the rest.',
        tipAr: 'يجب استرداد المبرد من قبل فني معتمد قبل التفكيك. ثم نقطة ECOVAL لبقية الأجزاء.',
        tipEs: 'El refrigerante debe ser recuperado por un técnico certificado antes del desmontaje. Luego punto ECOVAL para el resto.'),
    _Item('Pile / Batterie Li-ion (téléphone, vélo)', 'Électronique', 'COLLECTE SPÉCIALE', 'Collecteur ECOVAL',
        Icons.battery_charging_full_rounded, AppColors.electronics,
        'JAMAIS à la poubelle (risque d\'incendie). Collecteurs ECOVAL, Marjane, Label\'Vie. Ne pas court-circuiter avec du ruban adhésif sur les bornes.',
        nameEn: 'Li-ion battery (phone, bike)', nameAr: 'بطارية ليثيوم أيون (هاتف، دراجة)', nameEs: 'Batería Li-ion (teléfono, bicicleta)',
        tipEn: 'NEVER in the trash (fire risk). ECOVAL, Marjane, Label\'Vie collectors. Cover terminals with tape to prevent short-circuit.',
        tipAr: 'لا تضعها في القمامة أبداً (خطر حريق). جامعو ECOVAL، مرجان، لابيل في. ضع شريطاً على الأطراف لمنع الدائرة القصيرة.',
        tipEs: 'NUNCA en la basura (riesgo de incendio). Colectores ECOVAL, Marjane, Label\'Vie. Cubrir terminales con cinta para evitar cortocircuito.'),
    _Item('Chargeur / Câble USB / Adaptateur', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.cable_rounded, AppColors.electronics,
        'Regrouper dans un sac. Éco-point ECOVAL ou point de collecte en magasin électronique (Biougnach, Electroplanet).',
        nameEn: 'Charger / USB cable / Adapter', nameAr: 'شاحن / كابل USB / محوّل', nameEs: 'Cargador / Cable USB / Adaptador',
        tipEn: 'Bundle in a bag. ECOVAL point or in-store collection (Biougnach, Electroplanet).',
        tipAr: 'اجمعها في كيس. نقطة ECOVAL أو الجمع بالمتجر (بيوناش، إليكتروبلانيت).',
        tipEs: 'Agrupar en una bolsa. Punto ECOVAL o recogida en tienda (Biougnach, Electroplanet).'),
    _Item('Ampoule LED / Fluocompacte', 'Électronique', 'COLLECTE SPÉCIALE', 'Point luminaire',
        Icons.lightbulb_rounded, AppColors.electronics,
        'Points de collecte : Bricoma, Mr. Bricolage, grandes surfaces. Contient mercure (fluocompactes) → manipulation délicate.',
        nameEn: 'LED / CFL light bulb', nameAr: 'مصباح LED / موفر للطاقة', nameEs: 'Bombilla LED / CFL',
        tipEn: 'Collection points: Bricoma, Mr. Bricolage, supermarkets. CFL bulbs contain mercury → handle carefully.',
        tipAr: 'نقاط الجمع: بريكوما، مستر بريكولاج، المحلات الكبرى. مصابيح الطاقة الموفرة تحتوي على زئبق → تعامل بحذر.',
        tipEs: 'Puntos de recogida: Bricoma, Mr. Bricolage, supermercados. Las CFL contienen mercurio → manipular con cuidado.'),
    _Item('Imprimante / Cartouche d\'encre', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.print_rounded, AppColors.electronics,
        'Cartouches : programmes de reprise fabricant (HP, Epson, Canon). Imprimantes complètes → éco-point ECOVAL.',
        nameEn: 'Printer / Ink cartridge', nameAr: 'طابعة / خرطوشة حبر', nameEs: 'Impresora / Cartucho de tinta',
        tipEn: 'Cartridges: manufacturer take-back programs (HP, Epson, Canon). Full printers → ECOVAL point.',
        tipAr: 'الخراطيش: برامج استرداد المصنّع (HP، Epson، Canon). الطابعات الكاملة → نقطة ECOVAL.',
        tipEs: 'Cartuchos: programas de devolución del fabricante (HP, Epson, Canon). Impresoras completas → punto ECOVAL.'),
    _Item('Four micro-ondes', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.microwave_rounded, AppColors.electronics,
        'Contient des composants électroniques et magnétrons. Éco-point ECOVAL ou reprise vendeur. Ne jamais démonter soi-même.',
        nameEn: 'Microwave oven', nameAr: 'فرن الميكروويف', nameEs: 'Horno microondas',
        tipEn: 'Contains electronic components and magnetrons. ECOVAL point or retailer take-back. Never disassemble yourself.',
        tipAr: 'يحتوي على مكونات إلكترونية ومغناطرونات. نقطة ECOVAL أو استرداد البائع. لا تفككه بنفسك أبداً.',
        tipEs: 'Contiene componentes electrónicos y magnetrones. Punto ECOVAL o devolución al vendedor. Nunca desmontar uno mismo.'),
    _Item('Aspirateur / Petit électroménager', 'Électronique', 'COLLECTE SPÉCIALE', 'Éco-point ECOVAL',
        Icons.cleaning_services_rounded, AppColors.electronics,
        'Tous les appareils électriques sont concernés par le Décret 2-12-695. Éco-point ECOVAL ou déchetterie zone DEEE.',
        nameEn: 'Vacuum cleaner / Small appliance', nameAr: 'مكنسة كهربائية / أجهزة منزلية صغيرة', nameEs: 'Aspiradora / Pequeño electrodoméstico',
        tipEn: 'All electrical appliances are covered by Decree 2-12-695. ECOVAL point or recycling center WEEE zone.',
        tipAr: 'جميع الأجهزة الكهربائية مشمولة بالمرسوم 2-12-695. نقطة ECOVAL أو مركز إعادة التدوير منطقة DEEE.',
        tipEs: 'Todos los aparatos eléctricos están cubiertos por el Decreto 2-12-695. Punto ECOVAL o centro RAEE zona DEEE.'),

    // ── TEXTILE ───────────────────────────────────────────────────────────────
    _Item('Vêtements en bon état', 'Textile', 'OUI', 'Borne textile / Souk fripe',
        Icons.checkroom_rounded, Color(0xFF9B59B6),
        'Déposer propres dans un sac en borne textile. Tradition de sadaqa : don à des associations (Caritas Maroc, Croix-Rouge).',
        nameEn: 'Clothing in good condition', nameAr: 'ملابس بحالة جيدة', nameEs: 'Ropa en buen estado',
        tipEn: 'Drop off clean in a bag at a textile bin. Sadaqa tradition: donate to charities (Caritas Maroc, Red Cross).',
        tipAr: 'أودِعها نظيفة في كيس بحاوية النسيج. تقليد الصدقة: تبرع للجمعيات (كاريتاس المغرب، الصليب الأحمر).',
        tipEs: 'Depositar limpias en una bolsa en el contenedor textil. Tradición de sadaqa: donar a organizaciones benéficas (Caritas Maroc, Cruz Roja).'),
    _Item('Vêtements abîmés / déchirés', 'Textile', 'OUI', 'Borne textile',
        Icons.settings_backup_restore_rounded, Color(0xFF9B59B6),
        'Même abîmés, recyclés en chiffons industriels, isolants thermiques ou couvertures. Ne pas jeter à la poubelle.',
        nameEn: 'Damaged / torn clothing', nameAr: 'ملابس تالفة / ممزقة', nameEs: 'Ropa dañada / rasgada',
        tipEn: 'Even damaged, recycled into industrial rags, thermal insulation or blankets. Do not throw in the trash.',
        tipAr: 'حتى التالفة، تُعاد تدويرها كخرق صناعية أو عوازل حرارية أو بطانيات. لا ترمها في القمامة.',
        tipEs: 'Incluso dañada, reciclada en trapos industriales, aislamiento térmico o mantas. No tirar en la basura.'),
    _Item('Chaussures (toutes matières)', 'Textile', 'OUI', 'Borne textile',
        Icons.directions_run_rounded, Color(0xFF9B59B6),
        'Attacher par paires avec un lacet. Mettre dans un sac. Même très usées — valorisées ou recyclées en semelles de terrain de sport.',
        nameEn: 'Shoes (all materials)', nameAr: 'أحذية (جميع المواد)', nameEs: 'Zapatos (todos los materiales)',
        tipEn: 'Tie in pairs with a lace. Put in a bag. Even very worn — valued or recycled into sports field surfaces.',
        tipAr: 'اربطها بالأزواج بربطة حذاء. ضعها في كيس. حتى المتهالكة — تُقدَّر أو تُعاد تدويرها في أسطح الملاعب الرياضية.',
        tipEs: 'Atar en pares con el cordón. Poner en una bolsa. Incluso muy gastadas — valoradas o recicladas en superficies de campos deportivos.'),
    _Item('Sac en tissu / sac à main tissu', 'Textile', 'OUI', 'Borne textile',
        Icons.shopping_bag_rounded, Color(0xFF9B59B6),
        'Nettoyer si possible. Borne textile ou association. Alternative au sac plastique à encourager (Loi 77-15 depuis 2016).',
        nameEn: 'Fabric bag / fabric handbag', nameAr: 'حقيبة قماشية / حقيبة يد قماشية', nameEs: 'Bolsa de tela / bolso de tela',
        tipEn: 'Clean if possible. Textile bin or charity. Alternative to plastic bags encouraged (Law 77-15 since 2016).',
        tipAr: 'نظّف إن أمكن. حاوية النسيج أو الجمعية. بديل للأكياس البلاستيكية مُشجَّع (القانون 77-15 منذ 2016).',
        tipEs: 'Limpiar si es posible. Contenedor textil o asociación. Alternativa a las bolsas plásticas fomentada (Ley 77-15 desde 2016).'),
    _Item('Linge de maison (draps, serviettes, rideaux)', 'Textile', 'OUI', 'Borne textile',
        Icons.bed_rounded, Color(0xFF9B59B6),
        'Propre et sec. Borne textile ou ressourcerie. Les draps usagés deviennent des chiffons industriels pour les garages.',
        nameEn: 'Household linen (sheets, towels, curtains)', nameAr: 'مفروشات (ملاءات، مناشف، ستائر)', nameEs: 'Ropa de hogar (sábanas, toallas, cortinas)',
        tipEn: 'Clean and dry. Textile bin or charity. Used sheets become industrial rags for garages.',
        tipAr: 'نظيف وجاف. حاوية النسيج أو الجمعيات. الملاءات المستعملة تصبح خرقاً صناعية للمرائب.',
        tipEs: 'Limpia y seca. Contenedor textil o asociación. Las sábanas usadas se convierten en trapos industriales para garajes.'),
    _Item('Peluches / jouets tissu propres', 'Textile', 'OUI', 'Borne textile / Association',
        Icons.toys_rounded, Color(0xFF9B59B6),
        'Propres et sans piles. Associations caritatives (Bayti, SOS Villages d\'Enfants Maroc) ou bornes textile.',
        nameEn: 'Clean stuffed toys / fabric toys', nameAr: 'دمى / ألعاب قماشية نظيفة', nameEs: 'Peluches / juguetes de tela limpios',
        tipEn: 'Clean and battery-free. Charities (Bayti, SOS Villages d\'Enfants Maroc) or textile bins.',
        tipAr: 'نظيفة وبدون بطاريات. جمعيات خيرية (بيتي، SOS قرى الأطفال بالمغرب) أو حاويات النسيج.',
        tipEs: 'Limpios y sin pilas. Organizaciones benéficas (Bayti, SOS Villages d\'Enfants Maroc) o contenedores textiles.'),
    _Item('Ceinture cuir / sac cuir', 'Textile', 'OUI', 'Borne textile / Souk fripe',
        Icons.watch_rounded, Color(0xFF9B59B6),
        'Souk fripe marocain (Derb Ghallef, Mellah de Marrakech) ou bornes textile. Le cuir a une longue durée de vie.',
        nameEn: 'Leather belt / leather bag', nameAr: 'حزام جلدي / حقيبة جلدية', nameEs: 'Cinturón de cuero / bolso de cuero',
        tipEn: 'Moroccan flea market (Derb Ghallef, Marrakech Mellah) or textile bins. Leather has a long lifespan.',
        tipAr: 'سوق الفراشة المغربي (درب غلف، ملاح مراكش) أو حاويات النسيج. للجلد عمر مديد.',
        tipEs: 'Mercado de segunda mano marroquí (Derb Ghallef, Mellah de Marrakech) o contenedores textiles. El cuero tiene una larga vida útil.'),
    _Item('Burnous / Djellaba usagée', 'Textile', 'OUI', 'Borne textile / Association',
        Icons.people_rounded, Color(0xFF9B59B6),
        'Tradition marocaine de sadaqa. Associations ou bornes textile. La laine est recyclable en isolant ou en nouveau tissu.',
        nameEn: 'Used burnous / djellaba', nameAr: 'برنوس / جلابة مستعملة', nameEs: 'Burnús / Djellaba usada',
        tipEn: 'Moroccan sadaqa tradition. Charities or textile bins. Wool is recyclable into insulation or new fabric.',
        tipAr: 'تقليد الصدقة المغربي. الجمعيات أو حاويات النسيج. الصوف قابل لإعادة التدوير كعازل أو قماش جديد.',
        tipEs: 'Tradición marroquí de sadaqa. Asociaciones o contenedores textiles. La lana es reciclable en aislamiento o nuevo tejido.'),
    _Item('Sous-vêtements usagés', 'Textile', 'NON', 'Poubelle ordinaire',
        Icons.do_not_disturb_rounded, Color(0xFF9B59B6),
        'Pour des raisons d\'hygiène, non acceptés dans les bornes textile ni les associations. Poubelle ordinaire.',
        nameEn: 'Used underwear', nameAr: 'ملابس داخلية مستعملة', nameEs: 'Ropa interior usada',
        tipEn: 'For hygiene reasons, not accepted in textile bins or charities. Regular trash.',
        tipAr: 'لأسباب صحية، غير مقبول في حاويات النسيج أو الجمعيات. القمامة العادية.',
        tipEs: 'Por razones de higiene, no aceptada en contenedores textiles ni asociaciones. Basura normal.'),
    _Item('Vêtements souillés chimiques / peinture', 'Textile', 'NON', 'Déchetterie',
        Icons.dangerous_rounded, Color(0xFF9B59B6),
        'Contaminent les autres textiles. Si souillés de produits chimiques → déchetterie zone dangereux.',
        nameEn: 'Chemical / paint-stained clothing', nameAr: 'ملابس ملوثة بمواد كيميائية / طلاء', nameEs: 'Ropa manchada de productos químicos / pintura',
        tipEn: 'Contaminates other textiles. If soiled with chemicals → recycling center hazardous zone.',
        tipAr: 'تلوّث النسيج الآخر. إذا كانت ملوثة بمواد كيميائية → مركز إعادة التدوير منطقة الخطر.',
        tipEs: 'Contamina otros textiles. Si están manchados con productos químicos → centro de reciclaje zona peligrosa.'),
    _Item('Matelas / oreillers', 'Textile', 'NON', 'Déchetterie / Collecte encombrants',
        Icons.hotel_rounded, Color(0xFF9B59B6),
        'Trop volumineux pour les bornes. Collecte encombrants de la commune (Casablanca 0801003737, Rabat 0537726364) ou déchetterie.',
        nameEn: 'Mattress / pillows', nameAr: 'مرتبة / وسائد', nameEs: 'Colchón / almohadas',
        tipEn: 'Too bulky for bins. Municipality bulky waste collection (Casablanca 0801003737, Rabat 0537726364) or recycling center.',
        tipAr: 'حجم كبير للغاية للحاويات. جمع النفايات الضخمة للبلدية (الدار البيضاء 0801003737، الرباط 0537726364) أو مركز إعادة التدوير.',
        tipEs: 'Demasiado voluminoso para los contenedores. Recogida de voluminosos del municipio (Casablanca 0801003737, Rabat 0537726364) o centro de reciclaje.'),

    // ── PLASTIQUE ─────────────────────────────────────────────────────────────
    _Item('Bouteille PET (Sidi Ali, Ain Atlas, Pepsi)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.opacity_rounded, AppColors.plastic,
        'Rincer. Écraser pour réduire le volume. Bouchon peut rester vissé. L\'un des plastiques les plus recyclés au Maroc (ECOVAL).',
        nameEn: 'PET bottle (Sidi Ali, Ain Atlas, Pepsi)', nameAr: 'زجاجة PET (سيدي علي، عين أطلس، بيبسي)', nameEs: 'Botella PET (Sidi Ali, Ain Atlas, Pepsi)',
        tipEn: 'Rinse. Crush to reduce volume. Cap can stay screwed on. One of the most recycled plastics in Morocco (ECOVAL).',
        tipAr: 'اشطف. اسحق لتقليل الحجم. يمكن إبقاء الغطاء ملولباً. أحد أكثر البلاستيك تدويراً في المغرب (ECOVAL).',
        tipEs: 'Enjuaga. Aplasta para reducir el volumen. El tapón puede quedarse enroscado. Uno de los plásticos más reciclados en Marruecos (ECOVAL).'),
    _Item('Flacon PEHD (shampoing Pantene, lait Centrale Laitière)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.cleaning_services_rounded, AppColors.plastic,
        'Vider et rincer. Écraser. Le PEHD (code 2) est très recyclable — redevient tuyaux, mobilier urbain, sacs poubelles.',
        nameEn: 'HDPE bottle (Pantene shampoo, Centrale Laitière milk)', nameAr: 'زجاجة PEHD (شامبو بانتين، حليب المركزية)', nameEs: 'Botella PEHD (champú Pantene, leche Centrale Laitière)',
        tipEn: 'Empty and rinse. Crush. HDPE (code 2) is very recyclable — becomes pipes, street furniture, trash bags.',
        tipAr: 'أفرغه واشطفه. اسحق. PEHD (رمز 2) قابل للتدوير جداً — يتحول إلى أنابيب وأثاث حضري وأكياس مهملات.',
        tipEs: 'Vaciar y enjuagar. Aplastar. El PEHD (código 2) es muy reciclable — se convierte en tuberías, mobiliario urbano, bolsas de basura.'),
    _Item('Barquette alimentaire rincée', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.takeout_dining_rounded, AppColors.plastic,
        'Rincer pour enlever les résidus. Même légèrement souillée, elle reste recyclable. Code plastique 1 (PET) ou 5 (PP) préférables.',
        nameEn: 'Rinsed food tray', nameAr: 'صينية طعام مشطوفة', nameEs: 'Bandeja alimentaria enjuagada',
        tipEn: 'Rinse to remove residue. Even slightly soiled, still recyclable. Plastic code 1 (PET) or 5 (PP) preferred.',
        tipAr: 'اشطف لإزالة البقايا. حتى لو كانت ملوثة قليلاً تبقى قابلة للتدوير. رمز البلاستيك 1 (PET) أو 5 (PP) مفضّل.',
        tipEs: 'Enjuagar para eliminar residuos. Incluso ligeramente sucia, sigue siendo reciclable. Código plástico 1 (PET) o 5 (PP) preferido.'),
    _Item('Pot de yaourt (Danone Jaouda, Yawmi)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.icecream_rounded, AppColors.plastic,
        'Rincer rapidement. Le couvercle en alu → bac jaune aussi. Accepté dans tous les bacs ECOVAL du Maroc.',
        nameEn: 'Yogurt pot (Danone Jaouda, Yawmi)', nameAr: 'كوب زبادي (دانون جودة، يومي)', nameEs: 'Tarrina de yogur (Danone Jaouda, Yawmi)',
        tipEn: 'Quick rinse. The aluminum lid → yellow bin too. Accepted in all ECOVAL bins in Morocco.',
        tipAr: 'شطف سريع. الغطاء الألمنيوم → صندوق أصفر أيضاً. مقبول في جميع صناديق ECOVAL في المغرب.',
        tipEs: 'Enjuague rápido. La tapa de aluminio → contenedor amarillo también. Aceptado en todos los contenedores ECOVAL de Marruecos.'),
    _Item('Bidon plastique propre (eau de Javel, huile)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.water_drop_rounded, AppColors.plastic,
        'Vider complètement et rincer 3 fois. Écraser. Le PEHD des bidons est très valorisé. Éviter les bidons de produits chimiques purs.',
        nameEn: 'Clean plastic container (bleach, oil)', nameAr: 'جركان بلاستيكي نظيف (ماء جافيل، زيت)', nameEs: 'Bidón plástico limpio (lejía, aceite)',
        tipEn: 'Empty completely and rinse 3 times. Crush. HDPE containers are highly valued. Avoid containers of pure chemicals.',
        tipAr: 'أفرغه تماماً واشطفه 3 مرات. اسحق. حاويات PEHD ذات قيمة عالية. تجنب حاويات المواد الكيميائية النقية.',
        tipEs: 'Vaciar completamente y enjuagar 3 veces. Aplastar. Los bidones de PEHD son muy valorados. Evitar contenedores de productos químicos puros.'),
    _Item('Bouchon plastique vissé', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.circle_rounded, AppColors.plastic,
        'Le bouchon vissé sur la bouteille écrasée est accepté. Collectes solidaires de bouchons pour associations (Bouchons de l\'Espoir Maroc).',
        nameEn: 'Screwed plastic cap', nameAr: 'سدادة بلاستيكية ملولبة', nameEs: 'Tapón de plástico enroscado',
        tipEn: 'Cap screwed onto crushed bottle is accepted. Solidarity cap collections for charities (Bouchons de l\'Espoir Maroc).',
        tipAr: 'الغطاء الملولب على الزجاجة المسحوقة مقبول. جمع تضامني للأغطية للجمعيات (أغطية الأمل المغرب).',
        tipEs: 'El tapón enroscado en la botella aplastada está aceptado. Colectas solidarias de tapones para asociaciones (Bouchons de l\'Espoir Maroc).'),
    _Item('Emballage plastique rigide propre (code 1, 2, 5)', 'Plastique', 'OUI', 'Bac jaune ECOVAL',
        Icons.inventory_rounded, AppColors.plastic,
        'PET (1), PEHD (2), PP (5) = les plus recyclables. Regarder le code triangle en dessous de l\'emballage.',
        nameEn: 'Clean rigid plastic packaging (code 1, 2, 5)', nameAr: 'تغليف بلاستيكي صلب نظيف (رمز 1، 2، 5)', nameEs: 'Envase plástico rígido limpio (código 1, 2, 5)',
        tipEn: 'PET (1), HDPE (2), PP (5) = most recyclable. Check the triangle code on the bottom of the packaging.',
        tipAr: 'PET (1)، PEHD (2)، PP (5) = الأكثر قابلية للتدوير. تحقق من رمز المثلث في أسفل التغليف.',
        tipEs: 'PET (1), HDPE (2), PP (5) = los más reciclables. Consultar el código triangular en la base del envase.'),
    _Item('Sac plastique (tous types)', 'Plastique', 'INTERDIT', 'Interdit — Loi 77-15',
        Icons.shopping_bag_outlined, AppColors.plastic,
        'INTERDIT en production et distribution depuis juillet 2016 (Loi 77-15). Amende : 1000 DH à 1 million DH. Utiliser sac tissu ou panier.',
        nameEn: 'Plastic bag (all types)', nameAr: 'كيس بلاستيكي (جميع الأنواع)', nameEs: 'Bolsa plástica (todos los tipos)',
        tipEn: 'BANNED from production and distribution since July 2016 (Law 77-15). Fine: 1,000 to 1 million DH. Use fabric bag or basket.',
        tipAr: 'محظور في الإنتاج والتوزيع منذ يوليو 2016 (القانون 77-15). غرامة: 1000 إلى مليون درهم. استخدم كيس قماش أو سلة.',
        tipEs: 'PROHIBIDO en producción y distribución desde julio de 2016 (Ley 77-15). Multa: 1.000 a 1 millón de DH. Usar bolsa de tela o cesta.'),
    _Item('Film plastique souple (emballage)', 'Plastique', 'NON', 'Borne dédiée / Poubelle',
        Icons.wrap_text_rounded, AppColors.plastic,
        'Non recyclable dans les bacs jaunes — bloque les machines de tri. Certains supermarchés (Carrefour) ont des bornes pour films plastiques.',
        nameEn: 'Soft plastic film (packaging)', nameAr: 'غشاء بلاستيكي مرن (تغليف)', nameEs: 'Film plástico flexible (embalaje)',
        tipEn: 'Not recyclable in yellow bins — clogs sorting machines. Some supermarkets (Carrefour) have dedicated film bins.',
        tipAr: 'غير قابل للتدوير في الصناديق الصفراء — يسد آلات الفرز. بعض السوبرماركت (كارفور) لديها صناديق مخصصة للأفلام البلاستيكية.',
        tipEs: 'No reciclable en contenedores amarillos — obstruye las máquinas de clasificación. Algunos supermercados (Carrefour) tienen contenedores dedicados para films.'),
    _Item('Polystyrène expansé (emballage, barquette poisson)', 'Plastique', 'NON', 'Déchetterie',
        Icons.view_in_ar_rounded, AppColors.plastic,
        'Difficile à recycler au Maroc. Déchetterie ou compactage spécialisé. Volume énorme pour peu de matière — problème majeur de pollution.',
        nameEn: 'Expanded polystyrene (packaging, fish tray)', nameAr: 'البوليسترين المتمدد (تغليف، صينية سمك)', nameEs: 'Poliestireno expandido (embalaje, bandeja de pescado)',
        tipEn: 'Difficult to recycle in Morocco. Recycling center or specialized compaction. Huge volume for little material — major pollution issue.',
        tipAr: 'صعب تدويره في المغرب. مركز إعادة التدوير أو ضغط متخصص. حجم ضخم لمادة قليلة — مشكلة تلوث كبرى.',
        tipEs: 'Difícil de reciclar en Marruecos. Centro de reciclaje o compactación especializada. Gran volumen para poca materia — problema importante de contaminación.'),
    _Item('Tube dentifrice (Colgate, Signal)', 'Plastique', 'NON', 'Poubelle ordinaire',
        Icons.brush_rounded, AppColors.plastic,
        'Multicouche aluminium + plastique = non recyclable. Poubelle ordinaire. Programme de reprise Colgate en pharmacies partenaires.',
        nameEn: 'Toothpaste tube (Colgate, Signal)', nameAr: 'أنبوب معجون أسنان (كولجيت، سيجنال)', nameEs: 'Tubo de pasta de dientes (Colgate, Signal)',
        tipEn: 'Multilayer aluminium + plastic = not recyclable. Regular trash. Colgate take-back program in partner pharmacies.',
        tipAr: 'متعدد الطبقات ألمنيوم + بلاستيك = غير قابل للتدوير. القمامة العادية. برنامج استرداد Colgate في الصيدليات الشريكة.',
        tipEs: 'Multicapa aluminio + plástico = no reciclable. Basura normal. Programa de devolución Colgate en farmacias asociadas.'),
    _Item('Paille plastique', 'Plastique', 'NON', 'Poubelle ordinaire',
        Icons.remove_rounded, AppColors.plastic,
        'Trop légère et petite pour les machines de tri. Poubelle ordinaire. Préférer paille en inox, bambou, papier ou verre réutilisable.',
        nameEn: 'Plastic straw', nameAr: 'شفاطة بلاستيكية', nameEs: 'Pajita de plástico',
        tipEn: 'Too light and small for sorting machines. Regular trash. Prefer stainless steel, bamboo, paper or reusable glass straws.',
        tipAr: 'خفيفة جداً وصغيرة لآلات الفرز. القمامة العادية. يُفضَّل قش الفولاذ المقاوم للصدأ أو البامبو أو الورق أو الزجاج المعاد استخدامه.',
        tipEs: 'Demasiado ligera y pequeña para las máquinas de clasificación. Basura normal. Preferir pajitas de acero inoxidable, bambú, papel o vidrio reutilizable.'),
    _Item('Emballage multicouche (brique de jus, sachets café)', 'Plastique', 'NON', 'Poubelle ordinaire',
        Icons.layers_rounded, AppColors.plastic,
        'Mélange plastique + aluminium + carton inséparable mécaniquement. Pas de filière de recyclage au Maroc actuellement.',
        nameEn: 'Multi-layer packaging (juice carton, coffee sachets)', nameAr: 'تغليف متعدد الطبقات (عبوة عصير، أكياس قهوة)', nameEs: 'Envase multicapa (brick de zumo, sobres de café)',
        tipEn: 'Mix of plastic + aluminium + cardboard that cannot be mechanically separated. No recycling stream in Morocco yet.',
        tipAr: 'خليط من البلاستيك + الألمنيوم + الكرتون لا يمكن فصله ميكانيكياً. لا توجد بعد سلسلة تدوير في المغرب.',
        tipEs: 'Mezcla de plástico + aluminio + cartón inseparable mecánicamente. Aún no hay cadena de reciclaje en Marruecos.'),

    // ── PAPIER / CARTON ───────────────────────────────────────────────────────
    _Item('Journal / Magazine (Al Ahdath, L\'Économiste, TelQuel)', 'Papier', 'OUI', 'Bac bleu / Ferracha',
        Icons.article_outlined, AppColors.paper,
        'Plier ou empiler. Ne pas mouiller. La ferracha (récupérateur informel) joue un rôle essentiel dans le recyclage du papier au Maroc.',
        nameEn: 'Newspaper / Magazine (Al Ahdath, L\'Économiste, TelQuel)', nameAr: 'جريدة / مجلة (الأحداث، الاقتصادية، تيلكيل)', nameEs: 'Periódico / Revista (Al Ahdath, L\'Économiste, TelQuel)',
        tipEn: 'Fold or stack. Do not wet. The ferracha (informal collector) plays a key role in paper recycling in Morocco.',
        tipAr: 'طوِّ أو ارصفه. لا تبلّله. الفراشة (المحصّل غير الرسمي) تلعب دوراً أساسياً في تدوير الورق بالمغرب.',
        tipEs: 'Doblar o apilar. No mojar. La ferracha (recolector informal) juega un papel clave en el reciclaje del papel en Marruecos.'),
    _Item('Carton ondulé aplati', 'Papier', 'OUI', 'Bac bleu / Ferracha',
        Icons.inventory_2_rounded, AppColors.paper,
        'Aplatir avant de mettre dans le bac. Enlever les agrafes et le ruban adhésif. Repris par l\'industrie papetière marocaine (CMCP).',
        nameEn: 'Flattened corrugated cardboard', nameAr: 'كرتون مموج مفرود', nameEs: 'Cartón corrugado aplanado',
        tipEn: 'Flatten before putting in the bin. Remove staples and adhesive tape. Collected by the Moroccan paper industry (CMCP).',
        tipAr: 'افرده قبل وضعه في الصندوق. أزل الدبابيس وشريط التثبيت. تسترده الصناعة الورقية المغربية (CMCP).',
        tipEs: 'Aplanar antes de poner en el contenedor. Retirar grapas y cinta adhesiva. Recogido por la industria papelera marroquí (CMCP).'),
    _Item('Boîte carton (céréales Kellogg\'s, conserves Aïcha)', 'Papier', 'OUI', 'Bac bleu',
        Icons.breakfast_dining_rounded, AppColors.paper,
        'Aplatir. Retirer les sachets plastiques intérieurs (→ bac jaune si recyclable, sinon poubelle). Pureté du carton très importante.',
        nameEn: 'Cardboard box (Kellogg\'s cereals, Aïcha cans)', nameAr: 'علبة كرتون (حبوب كيلوغز، علب عائشة)', nameEs: 'Caja de cartón (cereales Kellogg\'s, conservas Aïcha)',
        tipEn: 'Flatten. Remove inner plastic bags (→ yellow bin if recyclable, otherwise waste bin). Cardboard purity is very important.',
        tipAr: 'افرده. أزل الأكياس البلاستيكية الداخلية (→ صندوق أصفر إذا كانت قابلة للتدوير، وإلا إلى القمامة). نقاء الكرتون مهم جداً.',
        tipEs: 'Aplanar. Retirar las bolsas plásticas interiores (→ contenedor amarillo si son reciclables, de lo contrario papelera). La pureza del cartón es muy importante.'),
    _Item('Enveloppe (avec ou sans fenêtre plastique)', 'Papier', 'OUI', 'Bac bleu',
        Icons.mail_outlined, AppColors.paper,
        'La fenêtre plastique est acceptée dans la plupart des collectes. Retirer les autocollants si possible. Sans le contenu papier.',
        nameEn: 'Envelope (with or without plastic window)', nameAr: 'مظروف (مع أو بدون نافذة بلاستيكية)', nameEs: 'Sobre (con o sin ventana de plástico)',
        tipEn: 'The plastic window is accepted in most collections. Remove stickers if possible. Without the paper contents.',
        tipAr: 'النافذة البلاستيكية مقبولة في معظم التجميعات. أزل الملصقات إن أمكن. بدون المحتوى الورقي.',
        tipEs: 'La ventana plástica es aceptada en la mayoría de las recogidas. Retirar pegatinas si es posible. Sin el contenido en papel.'),
    _Item('Cahier / Papier bureau (fax, imprimante)', 'Papier', 'OUI', 'Bac bleu',
        Icons.description_outlined, AppColors.paper,
        'Retirer les spirales métalliques (→ bac jaune). Les trombones et agrafes sont acceptés. Ne pas mixer avec papier mouillé.',
        nameEn: 'Notebook / Office paper (fax, printer)', nameAr: 'دفتر / ورق مكتبي (فاكس، طابعة)', nameEs: 'Cuaderno / Papel de oficina (fax, impresora)',
        tipEn: 'Remove metal spirals (→ yellow bin). Paper clips and staples are accepted. Do not mix with wet paper.',
        tipAr: 'أزل الزوايا المعدنية الحلزونية (→ صندوق أصفر). مشابك الورق والدبابيس مقبولة. لا تخلط مع الورق المبلل.',
        tipEs: 'Retirar las espirales metálicas (→ contenedor amarillo). Los clips y grapas están aceptados. No mezclar con papel mojado.'),
    _Item('Brique alimentaire (Centrale Laitière, Candia)', 'Papier', 'OUI', 'Bac bleu',
        Icons.local_drink_rounded, AppColors.paper,
        'Rincer. Écraser. Certaines collectes en bac bleu, d\'autres en bac jaune selon la ville. Vérifier auprès de votre commune.',
        nameEn: 'Food carton (Centrale Laitière, Candia)', nameAr: 'علبة أغذية مقوى (المركزية الحليبية، كانديا)', nameEs: 'Cartón de alimentación (Centrale Laitière, Candia)',
        tipEn: 'Rinse. Crush. Some collections in blue bin, others in yellow bin depending on city. Check with your municipality.',
        tipAr: 'اشطف. اسحق. بعض التجميعات في صندوق أزرق وأخرى في صندوق أصفر حسب المدينة. استفسر من بلديتك.',
        tipEs: 'Enjuagar. Aplastar. Algunas recogidas en contenedor azul, otras en amarillo según la ciudad. Consultar con tu municipio.'),
    _Item('Annuaire téléphonique / catalogue', 'Papier', 'OUI', 'Bac bleu / Ferracha',
        Icons.menu_book_rounded, AppColors.paper,
        'Papier non couché = très recyclable. La ferracha marocaine rachète ce type de papier. Dépôt en bac bleu ou point de collecte.',
        nameEn: 'Phone directory / catalogue', nameAr: 'دليل هاتفي / كتالوج', nameEs: 'Guía telefónica / catálogo',
        tipEn: 'Uncoated paper = very recyclable. The Moroccan ferracha buys this type of paper. Drop in blue bin or collection point.',
        tipAr: 'ورق غير مطلي = قابل للتدوير كثيراً. الفراشة المغربية تشتري هذا النوع من الورق. في الصندوق الأزرق أو نقطة التجميع.',
        tipEs: 'Papel no estucado = muy reciclable. La ferracha marroquí compra este tipo de papel. Depositar en contenedor azul o punto de recogida.'),
    _Item('Ticket de caisse thermique', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.receipt_rounded, AppColors.paper,
        'Contient du Bisphénol A (BPA) — perturbateur endocrinien qui contamine les autres papiers. JAMAIS au bac bleu.',
        nameEn: 'Thermal cash register receipt', nameAr: 'إيصال صراف حراري', nameEs: 'Ticket de caja térmico',
        tipEn: 'Contains Bisphenol A (BPA) — endocrine disruptor that contaminates other paper. NEVER in the blue bin.',
        tipAr: 'يحتوي على بيسفينول A (BPA) — مشتّت هرموني يلوّث الأوراق الأخرى. لا تضعه أبداً في الصندوق الأزرق.',
        tipEs: 'Contiene Bisfenol A (BPA) — disruptor endocrino que contamina el resto del papel. NUNCA en el contenedor azul.'),
    _Item('Papier cuisson siliconé', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.kitchen_rounded, AppColors.paper,
        'Le revêtement silicone empêche le recyclage. Poubelle ordinaire. Préférer tapis de cuisson réutilisable en silicone.',
        nameEn: 'Silicone-coated baking paper', nameAr: 'ورق خبز مطلي بالسيليكون', nameEs: 'Papel de horno siliconado',
        tipEn: 'The silicone coating prevents recycling. Regular waste bin. Prefer reusable silicone baking mat.',
        tipAr: 'طلاء السيليكون يمنع التدوير. القمامة العادية. يُفضَّل حصيرة خبز سيليكون قابلة لإعادة الاستخدام.',
        tipEs: 'El revestimiento de silicona impide el reciclaje. Papelera normal. Preferir un tapete de silicona reutilizable.'),
    _Item('Emballage cadeau brillant / pailleté', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.card_giftcard_rounded, AppColors.paper,
        'Le revêtement plastique ou métallique est non séparable. Poubelle ordinaire. Préférer papier kraft naturel recyclable.',
        nameEn: 'Shiny / glittery gift wrap', nameAr: 'ورق تغليف هدايا لامع / متألق', nameEs: 'Papel de regalo brillante / con purpurina',
        tipEn: 'The plastic or metallic coating is inseparable. Regular waste bin. Prefer recyclable natural kraft paper.',
        tipAr: 'الطبقة البلاستيكية أو المعدنية لا يمكن فصلها. القمامة العادية. يُفضَّل ورق كرافت طبيعي قابل للتدوير.',
        tipEs: 'El revestimiento plástico o metálico es inseparable. Papelera normal. Preferir papel kraft natural reciclable.'),
    _Item('Carton pizza gras / souillé', 'Papier', 'NON', 'Composteur (si non imprimé)',
        Icons.local_pizza_rounded, AppColors.paper,
        'La partie grasse contamine le lot de papier recyclé. Découper : partie propre → bac bleu, partie grasse → compost ou poubelle.',
        nameEn: 'Greasy / soiled pizza box', nameAr: 'علبة بيتزا دهنية / ملوثة', nameEs: 'Caja de pizza grasienta / sucia',
        tipEn: 'The greasy part contaminates the recycled paper batch. Cut it: clean part → blue bin, greasy part → compost or waste.',
        tipAr: 'الجزء الدهني يلوّث مجموعة الورق المُعاد تدويره. قصّه: الجزء النظيف → صندوق أزرق، الجزء الدهني → سماد أو قمامة.',
        tipEs: 'La parte grasienta contamina el lote de papel reciclado. Cortar: la parte limpia → contenedor azul, la parte grasienta → compost o basura.'),
    _Item('Papier aluminium / papier cuisson alu', 'Papier', 'NON', 'Bac jaune ECOVAL (métal)',
        Icons.layers_rounded, AppColors.paper,
        'Ce n\'est pas du papier — c\'est de l\'aluminium ! Froisser en boule compacte → bac jaune (métal).',
        nameEn: 'Aluminium foil / aluminium baking paper', nameAr: 'ورق ألمنيوم / ورق خبز ألمنيوم', nameEs: 'Papel de aluminio / papel de cocina de aluminio',
        tipEn: 'It\'s not paper — it\'s aluminium! Scrunch into a compact ball → yellow bin (metal).',
        tipAr: 'إنه ليس ورقاً — إنه ألمنيوم! اجعله كرة مضغوطة → صندوق أصفر (معادن).',
        tipEs: 'No es papel — ¡es aluminio! Arrugar en bola compacta → contenedor amarillo (metal).'),
    _Item('Papier hygiénique / mouchoir usagé', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.clean_hands_rounded, AppColors.paper,
        'Souillé de matières biologiques → non recyclable. Poubelle ordinaire. Le papier recyclé en mouchoirs ne peut pas être recyclé de nouveau.',
        nameEn: 'Toilet paper / used tissue', nameAr: 'ورق صحي / منديل مستعمل', nameEs: 'Papel higiénico / pañuelo usado',
        tipEn: 'Contaminated with biological material → not recyclable. Regular waste bin. Recycled tissue paper cannot be recycled again.',
        tipAr: 'ملوّث بمواد بيولوجية → غير قابل للتدوير. القمامة العادية. الورق المُعاد تدويره في المناديل لا يمكن إعادة تدويره مجدداً.',
        tipEs: 'Contaminado con material biológico → no reciclable. Papelera normal. El papel tisú reciclado no puede reciclarse de nuevo.'),
    _Item('Emballage fast-food gras (sac McDo, KFC)', 'Papier', 'NON', 'Poubelle ordinaire',
        Icons.fastfood_rounded, AppColors.paper,
        'Imprégné de graisse et souvent mélangé avec plastique. Non recyclable. Poubelle ordinaire.',
        nameEn: 'Greasy fast-food packaging (McDonald\'s, KFC bag)', nameAr: 'تغليف وجبات سريعة دهنية (ماكدونالدز، كي إف سي)', nameEs: 'Envase de comida rápida grasiento (bolsa McDonald\'s, KFC)',
        tipEn: 'Soaked in grease and often mixed with plastic. Not recyclable. Regular waste bin.',
        tipAr: 'مشبّع بالدهون ومخلوط أحياناً بالبلاستيك. غير قابل للتدوير. القمامة العادية.',
        tipEs: 'Empapado en grasa y a menudo mezclado con plástico. No reciclable. Papelera normal.'),

    // ── DÉCHETS DANGEREUX ─────────────────────────────────────────────────────
    _Item('Médicaments périmés', 'Dangereux', 'COLLECTE SPÉCIALE', 'Pharmacie agréée',
        Icons.medication_rounded, Color(0xFFE74C3C),
        'JAMAIS à la poubelle ni dans les toilettes (contamination eau). Rapporter en pharmacie. Maroc : filière de valorisation thermique.',
        nameEn: 'Expired medications', nameAr: 'أدوية منتهية الصلاحية', nameEs: 'Medicamentos caducados',
        tipEn: 'NEVER in the bin or toilet (water contamination). Return to pharmacy. Morocco: thermal recovery system.',
        tipAr: 'لا تضعها في القمامة ولا في المرحاض أبداً (تلوث المياه). أعِدها إلى الصيدلية. المغرب: نظام التثمين الحراري.',
        tipEs: 'NUNCA en la basura ni en el inodoro (contaminación del agua). Devolver a la farmacia. Marruecos: sistema de valorización térmica.'),
    _Item('Piles et batteries (toutes tailles)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Collecteur ECOVAL',
        Icons.battery_full_rounded, Color(0xFFE74C3C),
        'Contiennent mercure, cadmium, plomb. Collecteurs ECOVAL dans les supermarchés. JAMAIS dans la poubelle ordinaire (Loi 28-00).',
        nameEn: 'Batteries (all sizes)', nameAr: 'بطاريات (جميع الأحجام)', nameEs: 'Pilas y baterías (todos los tamaños)',
        tipEn: 'Contain mercury, cadmium, lead. ECOVAL collectors in supermarkets. NEVER in the regular waste bin (Law 28-00).',
        tipAr: 'تحتوي على الزئبق والكادميوم والرصاص. جامعو ECOVAL في السوبرماركت. لا تضعها أبداً في القمامة العادية (القانون 28-00).',
        tipEs: 'Contienen mercurio, cadmio, plomo. Colectores ECOVAL en supermercados. NUNCA en el cubo de basura normal (Ley 28-00).'),
    _Item('Huile moteur usagée', 'Dangereux', 'COLLECTE SPÉCIALE', 'Garage agréé',
        Icons.oil_barrel_rounded, Color(0xFFE74C3C),
        'Ne jamais verser dans les égouts (1L pollue 1 million L d\'eau). Garage agréé ou déchetterie. Filière de re-raffinage au Maroc.',
        nameEn: 'Used motor oil', nameAr: 'زيت محرك مستعمل', nameEs: 'Aceite de motor usado',
        tipEn: 'Never pour down drains (1L pollutes 1 million L of water). Approved garage or waste facility. Re-refining industry in Morocco.',
        tipAr: 'لا تصبّه في المجاري أبداً (1 لتر يلوّث مليون لتر ماء). مرآب معتمد أو مركز إعادة التدوير. صناعة إعادة التكرير في المغرب.',
        tipEs: 'Nunca verter por el desagüe (1L contamina 1 millón de L de agua). Taller aprobado o instalación de residuos. Industria de re-refinado en Marruecos.'),
    _Item('Peinture / Vernis / Solvant', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.format_paint_rounded, Color(0xFFE74C3C),
        'Garder dans le contenant d\'origine avec l\'étiquette. Déchetterie zone produits dangereux. Loi 28-00 : infraction pénale si abandon.',
        nameEn: 'Paint / Varnish / Solvent', nameAr: 'طلاء / ورنيش / مذيب', nameEs: 'Pintura / Barniz / Disolvente',
        tipEn: 'Keep in original container with label. Waste facility dangerous products area. Law 28-00: criminal offense if abandoned.',
        tipAr: 'احتفظ به في الوعاء الأصلي مع الملصق. مركز إعادة التدوير منطقة المنتجات الخطرة. القانون 28-00: جريمة جنائية إذا تُرك.',
        tipEs: 'Conservar en el envase original con etiqueta. Centro de residuos zona peligrosa. Ley 28-00: delito penal si se abandona.'),
    _Item('Produits ménagers chimiques (Javel, déboucheurs)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.science_rounded, Color(0xFFE74C3C),
        'Ne jamais mélanger (réactions dangereuses). Garder en contenant d\'origine. Déchetterie zone produits dangereux.',
        nameEn: 'Chemical household products (bleach, drain cleaners)', nameAr: 'منتجات منزلية كيميائية (جافيل، مزيلات انسداد)', nameEs: 'Productos domésticos químicos (lejía, destapacañerías)',
        tipEn: 'Never mix (dangerous reactions). Keep in original container. Waste facility dangerous products area.',
        tipAr: 'لا تخلطها أبداً (تفاعلات خطرة). احتفظ بها في الوعاء الأصلي. مركز إعادة التدوير منطقة المنتجات الخطرة.',
        tipEs: 'Nunca mezclar (reacciones peligrosas). Conservar en envase original. Centro de residuos zona peligrosa.'),
    _Item('Seringues / Aiguilles (DASRI)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Boîte DASRI / Pharmacie',
        Icons.vaccines_rounded, Color(0xFFE74C3C),
        'Déchets d\'Activités de Soins à Risques Infectieux. Boîtes DASRI disponibles en pharmacie. JAMAIS dans la poubelle ordinaire.',
        nameEn: 'Syringes / Needles (DASRI)', nameAr: 'حقن / إبر (نفايات طبية)', nameEs: 'Jeringas / Agujas (DASRI)',
        tipEn: 'Infectious Healthcare Waste. DASRI boxes available at pharmacy. NEVER in the regular waste bin.',
        tipAr: 'نفايات أنشطة الرعاية ذات المخاطر المعدية. صناديق DASRI متوفرة في الصيدليات. لا تضعها أبداً في القمامة العادية.',
        tipEs: 'Residuos de actividades sanitarias con riesgo infeccioso. Cajas DASRI disponibles en farmacias. NUNCA en el cubo de basura normal.'),
    _Item('Thermomètre à mercure', 'Dangereux', 'COLLECTE SPÉCIALE', 'Pharmacie / Déchetterie',
        Icons.thermostat_rounded, Color(0xFFE74C3C),
        'Le mercure est extrêmement toxique. En cas de casse : aérer, évacuer, ne pas aspirer. Rapporter entier en pharmacie ou déchetterie.',
        nameEn: 'Mercury thermometer', nameAr: 'ميزان حرارة زئبقي', nameEs: 'Termómetro de mercurio',
        tipEn: 'Mercury is extremely toxic. If broken: ventilate, evacuate, do not vacuum. Return whole to pharmacy or waste facility.',
        tipAr: 'الزئبق سام للغاية. في حالة الكسر: هوّد، أخلِ المكان، لا تستخدم المكنسة الكهربائية. أعِده كاملاً إلى الصيدلية أو مركز إعادة التدوير.',
        tipEs: 'El mercurio es extremadamente tóxico. Si se rompe: ventilar, evacuar, no aspirar. Devolver entero a la farmacia o centro de residuos.'),
    _Item('Pesticides / Herbicides / Insecticides', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.bug_report_rounded, Color(0xFFE74C3C),
        'Contaminants des eaux souterraines. Déchetterie zone dangereux. En milieu agricole : programme ECOPHYTO du Maroc.',
        nameEn: 'Pesticides / Herbicides / Insecticides', nameAr: 'مبيدات حشرية / مبيدات أعشاب / حشريات', nameEs: 'Pesticidas / Herbicidas / Insecticidas',
        tipEn: 'Groundwater contaminants. Waste facility dangerous area. In agricultural settings: Morocco\'s ECOPHYTO programme.',
        tipAr: 'ملوثات المياه الجوفية. مركز إعادة التدوير المنطقة الخطرة. في البيئة الزراعية: برنامج ECOPHYTO المغربي.',
        tipEs: 'Contaminantes de aguas subterráneas. Centro de residuos zona peligrosa. En entorno agrícola: programa ECOPHYTO de Marruecos.'),
    _Item('Acides / Bases concentrées', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — dangereux',
        Icons.warning_amber_rounded, Color(0xFFE74C3C),
        'Produits très corrosifs. Conserver en contenant d\'origine, ne jamais transférer dans une autre bouteille. Déchetterie zone dangereux.',
        nameEn: 'Concentrated acids / bases', nameAr: 'أحماض / قواعد مركزة', nameEs: 'Ácidos / Bases concentradas',
        tipEn: 'Highly corrosive products. Store in original container, never transfer to another bottle. Waste facility dangerous area.',
        tipAr: 'منتجات شديدة التآكل. احتفظ بها في الوعاء الأصلي، لا تنقلها إلى زجاجة أخرى أبداً. مركز إعادة التدوير المنطقة الخطرة.',
        tipEs: 'Productos muy corrosivos. Conservar en envase original, nunca transferir a otro recipiente. Centro de residuos zona peligrosa.'),
    _Item('Extincteur (poudre, CO₂, eau)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie / Professionnel',
        Icons.fire_extinguisher_rounded, Color(0xFFE74C3C),
        'Certains distributeurs assurent la reprise. Déchetterie ou professionnel agréé. Ne jamais percer ni jeter à la poubelle.',
        nameEn: 'Fire extinguisher (powder, CO₂, water)', nameAr: 'طفاية حريق (مسحوق، ثاني أكسيد الكربون، ماء)', nameEs: 'Extintor (polvo, CO₂, agua)',
        tipEn: 'Some distributors offer take-back. Waste facility or approved professional. Never pierce or throw in the bin.',
        tipAr: 'بعض الموزعين يضمنون الاسترداد. مركز إعادة التدوير أو محترف معتمد. لا تثقبه ولا ترميه في القمامة.',
        tipEs: 'Algunos distribuidores aseguran la recogida. Centro de residuos o profesional aprobado. Nunca perforar ni tirar en la basura.'),
    _Item('Amiante (plaques, tuiles)', 'Dangereux', 'COLLECTE SPÉCIALE', 'Déchetterie — amiante',
        Icons.dangerous_rounded, Color(0xFFE74C3C),
        'TRÈS DANGEREUX — fibre cancérigène. Ne jamais casser ni poncer. Filière spécialisée obligatoire. Contacter la commune ou l\'ONEE.',
        nameEn: 'Asbestos (sheets, tiles)', nameAr: 'أسبستوس (ألواح، قرميد)', nameEs: 'Amianto (placas, tejas)',
        tipEn: 'VERY DANGEROUS — carcinogenic fibre. Never break or sand. Mandatory specialised facility. Contact municipality or ONEE.',
        tipAr: 'خطير جداً — ألياف مسرطنة. لا تكسره ولا تصنفره أبداً. مسار متخصص إلزامي. تواصل مع البلدية أو ONEE.',
        tipEs: 'MUY PELIGROSO — fibra cancerígena. Nunca romper ni lijar. Instalación especializada obligatoria. Contactar al municipio o ONEE.'),
    _Item('Néons / Tubes fluorescents', 'Dangereux', 'COLLECTE SPÉCIALE', 'Point luminaire / Déchetterie',
        Icons.light_rounded, Color(0xFFE74C3C),
        'Contiennent du mercure. Ne jamais casser. Points de collecte luminaires (Bricoma, Mr. Bricolage) ou déchetterie zone DEEE.',
        nameEn: 'Neon / Fluorescent tubes', nameAr: 'أنابيب نيون / أنابيب فلورية', nameEs: 'Tubos de neón / fluorescentes',
        tipEn: 'Contain mercury. Never break. Lighting collection points (Bricoma, Mr. Bricolage) or WEEE waste facility.',
        tipAr: 'تحتوي على الزئبق. لا تكسرها أبداً. نقاط جمع الإضاءة (بريكوما، مستر بريكولاج) أو مركز إعادة التدوير منطقة DEEE.',
        tipEs: 'Contienen mercurio. Nunca romper. Puntos de recogida de iluminación (Bricoma, Mr. Bricolage) o centro RAEE zona DEEE.'),
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
        nameAr: 'الحاوية الصفراء ECOVAL', subtitleAr: 'البلاستيك والمعادن والتغليف',
        nameEs: 'Contenedor Amarillo ECOVAL', subtitleEs: 'Plásticos, metales, envases',
        itemsEn: ['Rinsed PET bottles and HDPE containers', 'Aluminium cans and steel food tins',
         'Rigid plastic trays and pots', 'Empty and deflated aerosols',
         'Metal biscuit tins, metal lids', 'ECOVAL: Casablanca, Rabat, Marrakech, Tangier, Agadir, Fes'],
        itemsAr: ['زجاجات PET وحاويات PEHD مشطوفة', 'علب الألومنيوم وعلب الفولاذ',
         'صواني وأوعية البلاستيك الصلبة', 'علب الرذاذ الفارغة والمفرغة من الغاز',
         'علب البسكويت المعدنية وأغطية المعدن', 'ECOVAL: الدار البيضاء، الرباط، مراكش، طنجة، أكادير، فاس'],
        itemsEs: ['Botellas PET y envases PEHD enjuagados', 'Latas de aluminio y botes de acero',
         'Bandejas y envases de plástico rígido', 'Aerosoles vacíos y despresurizados',
         'Latas metálicas de galletas, tapas metálicas', 'ECOVAL: Casablanca, Rabat, Marrakech, Tánger, Agadir, Fez']),
    _Bin('Colonne Verte', 'Verre uniquement',
        AppColors.glass, Icons.local_bar_outlined,
        ['Bouteilles verre (Sidi Ali, Ain Atlas, Oulmes)', 'Bocaux et pots en verre',
         'Flacons parfum et carafe verre', 'PAS : verre brisé, miroir, pyrex, ampoules',
         'Rincer avant dépôt — bouchon métal peut rester', 'Présentes dans 20 villes marocaines'],
        nameEn: 'Green Column', subtitleEn: 'Glass only',
        nameAr: 'العمود الأخضر', subtitleAr: 'الزجاج فقط',
        nameEs: 'Columna Verde', subtitleEs: 'Solo vidrio',
        itemsEn: ['Glass bottles (Sidi Ali, Ain Atlas, Oulmes)', 'Glass jars and pots',
         'Perfume bottles and glass carafes', 'NOT: broken glass, mirror, pyrex, bulbs',
         'Rinse before drop-off — metal cap can stay', 'Available in 20 Moroccan cities'],
        itemsAr: ['زجاجات الزجاج (سيدي علي، عين أطلس، أولمس)', 'برطمانات وأوعية الزجاج',
         'قوارير العطر وإبريق الزجاج', 'لا: الزجاج المكسور، المرايا، بيريكس، المصابيح',
         'اشطف قبل الإيداع — يمكن إبقاء الغطاء المعدني', 'متوفرة في 20 مدينة مغربية'],
        itemsEs: ['Botellas de vidrio (Sidi Ali, Ain Atlas, Oulmès)', 'Tarros y recipientes de vidrio',
         'Frascos de perfume y jarras de vidrio', 'NO: vidrio roto, espejo, pyrex, bombillas',
         'Enjuagar antes de depositar — la tapa metálica puede quedarse', 'Disponible en 20 ciudades marroquíes']),
    _Bin('Bac Bleu / Ferracha', 'Papiers et cartons',
        Color(0xFF3498DB), Icons.article_outlined,
        ['Journaux, magazines, catalogues', 'Carton ondulé aplati (retirer scotch)', 'Boîtes carton céréales et emballages',
         'Cahiers, papier bureau, enveloppes', 'Briques alimentaires rincées',
         'Ferracha : récupérateurs informels — rôle clé au Maroc'],
        nameEn: 'Blue Bin / Ferracha', subtitleEn: 'Paper and cardboard',
        nameAr: 'الحاوية الزرقاء / الفراشة', subtitleAr: 'الورق والكرتون',
        nameEs: 'Contenedor Azul / Ferracha', subtitleEs: 'Papel y cartón',
        itemsEn: ['Newspapers, magazines, catalogues', 'Flattened corrugated cardboard (remove tape)', 'Cereal boxes and paper packaging',
         'Notebooks, office paper, envelopes', 'Rinsed food cartons',
         'Ferracha: informal collectors — key role in Morocco'],
        itemsAr: ['الجرائد والمجلات والكتالوجات', 'الكرتون المموج المسطح (إزالة الشريط اللاصق)', 'علب الكرتون وتغليف الأغذية',
         'كراسات وورق المكتب والمظاريف', 'عبوات الأغذية السائلة المشطوفة',
         'الفراشة: جامعون غير رسميون — دور رئيسي في المغرب'],
        itemsEs: ['Periódicos, revistas, catálogos', 'Cartón ondulado aplastado (retirar cinta adhesiva)', 'Cajas de cereales y envases de papel',
         'Cuadernos, papel de oficina, sobres', 'Cartones de alimentos enjuagados',
         'Ferracha: recolectores informales — rol clave en Marruecos']),
    _Bin('Bac Marron / Composteur', 'Déchets organiques',
        Color(0xFF795548), Icons.compost_rounded,
        ['Épluchures fruits et légumes', 'Marc de café et sachets thé',
         'Pain, harcha, coquilles d\'œuf', 'Feuilles mortes, gazon, sciure bois naturel',
         '65% des déchets marocains sont organiques', 'Décomposition : 2 à 6 mois'],
        nameEn: 'Brown Bin / Composter', subtitleEn: 'Organic waste',
        nameAr: 'الحاوية البنية / المُسمِّد', subtitleAr: 'النفايات العضوية',
        nameEs: 'Contenedor Marrón / Compostador', subtitleEs: 'Residuos orgánicos',
        itemsEn: ['Fruit and vegetable peels', 'Coffee grounds and tea bags',
         'Bread, harcha, eggshells', 'Dead leaves, lawn clippings, natural sawdust',
         '65% of Moroccan waste is organic', 'Decomposition: 2 to 6 months'],
        itemsAr: ['قشور الفواكه والخضراوات', 'تفل القهوة وأكياس الشاي',
         'الخبز والهرشة وقشور البيض', 'الأوراق الميتة وقص العشب ونشارة الخشب الطبيعية',
         '65٪ من النفايات المغربية عضوية', 'التحلل: من 2 إلى 6 أشهر'],
        itemsEs: ['Pieles de frutas y verduras', 'Posos de café y bolsas de té',
         'Pan, harcha, cáscaras de huevo', 'Hojas secas, recortes de césped, serrín natural',
         'El 65% de los residuos marroquíes son orgánicos', 'Descomposición: de 2 a 6 meses']),
    _Bin('Borne Textile / Souk Fripe', 'Vêtements et chaussures',
        Color(0xFF9B59B6), Icons.checkroom_rounded,
        ['Vêtements en bon état (propres, secs)', 'Chaussures attachées par paires',
         'Linge de maison, peluches, sacs tissu', 'Tradition sadaqa : don à associations',
         'Souk fripe (Derb Ghallef, Mellah) pour revente', 'Caritas Maroc, SOS Villages d\'Enfants'],
        nameEn: 'Textile Bin / Souk Fripe', subtitleEn: 'Clothing and shoes',
        nameAr: 'بورن النسيج / سوق الفريبة', subtitleAr: 'الملابس والأحذية',
        nameEs: 'Punto Textil / Souk Fripe', subtitleEs: 'Ropa y calzado',
        itemsEn: ['Clean, dry clothing in good condition', 'Shoes tied in pairs',
         'Bed linen, soft toys, fabric bags', 'Sadaqa tradition: donations to associations',
         'Souk Fripe (Derb Ghallef, Mellah) for resale', 'Caritas Maroc, SOS Villages d\'Enfants'],
        itemsAr: ['الملابس النظيفة والجافة في حالة جيدة', 'الأحذية مربوطة في أزواج',
         'المفارش والألعاب الناعمة وحقائب القماش', 'تقليد الصدقة: تبرعات للجمعيات',
         'سوق الفريبة (درب غلف، الملاح) للبيع بالتجزئة', 'كاريتاس المغرب، SOS قرى الأطفال'],
        itemsEs: ['Ropa limpia y seca en buen estado', 'Zapatos atados por pares',
         'Ropa de cama, peluches, bolsas de tela', 'Tradición sadaqa: donaciones a asociaciones',
         'Souk Fripe (Derb Ghallef, Mellah) para reventa', 'Cáritas Maroc, SOS Aldeas Infantiles']),
    _Bin('Éco-point ECOVAL (DEEE)', 'Appareils électroniques',
        AppColors.electronics, Icons.electrical_services_rounded,
        ['Téléphones, tablettes, ordinateurs', 'Électroménager : frigo, machine à laver',
         'Piles, batteries, chargeurs, câbles', 'ECOVAL : jusqu\'à 500 DH remboursés',
         'Points dans Marjane, Carrefour, Cosmos Electro', 'Décret 2-12-695 — reprise obligatoire'],
        nameEn: 'ECOVAL Eco-point (WEEE)', subtitleEn: 'Electronic devices',
        nameAr: 'نقطة ECOVAL البيئية (DEEE)', subtitleAr: 'الأجهزة الإلكترونية',
        nameEs: 'Punto Eco ECOVAL (RAEE)', subtitleEs: 'Dispositivos electrónicos',
        itemsEn: ['Phones, tablets, computers', 'Appliances: fridge, washing machine',
         'Batteries, chargers, cables', 'ECOVAL: up to 500 DH reimbursed',
         'Drop-off at Marjane, Carrefour, Cosmos Electro', 'Decree 2-12-695 — mandatory take-back'],
        itemsAr: ['الهواتف والأجهزة اللوحية والحواسيب', 'الأجهزة المنزلية: الثلاجة والغسالة',
         'البطاريات والشواحن والكابلات', 'ECOVAL: حتى 500 درهم مسترداد',
         'نقاط الإيداع في مرجان وكارفور وكوزموس إلكترو', 'مرسوم 2-12-695 — الاسترجاع إلزامي'],
        itemsEs: ['Teléfonos, tabletas, ordenadores', 'Electrodomésticos: frigorífico, lavadora',
         'Pilas, cargadores, cables', 'ECOVAL: hasta 500 DH reembolsados',
         'Puntos de entrega en Marjane, Carrefour, Cosmos Electro', 'Decreto 2-12-695 — devolución obligatoria']),
  ];

  static const _laws = [
    _Legal('Loi 28-00 (2006)', 'Gestion et élimination des déchets',
        Icons.gavel_rounded,
        'Loi cadre : principe Pollueur-Payeur, 7 catégories officielles. Interdit abandon/brûlage. Sanctions : 500 à 500 000 DH + prison 1 à 12 mois. Oblige communes à élaborer Plans Directeurs Provinciaux de Gestion.',
        titleEn: 'Waste management and disposal',
        titleAr: 'إدارة النفايات والتخلص منها',
        titleEs: 'Gestión y eliminación de residuos',
        descEn: 'Framework law: Polluter-Pays principle, 7 official categories. Prohibits illegal dumping/burning. Penalties: 500 to 500,000 DH + 1 to 12 months prison. Municipalities must develop Provincial Waste Management Plans.',
        descAr: 'قانون إطار: مبدأ الملوث يدفع، 7 فئات رسمية. يحظر الإلقاء/الحرق غير القانوني. العقوبات: من 500 إلى 500,000 درهم + سجن من 1 إلى 12 شهرًا. على البلديات وضع مخططات إقليمية لتدبير النفايات.',
        descEs: 'Ley marco: principio Contaminador-Pagador, 7 categorías oficiales. Prohíbe vertidos ilegales y quemas. Sanciones: de 500 a 500.000 DH + prisión de 1 a 12 meses. Las municipalidades deben elaborar Planes Provinciales de Gestión de Residuos.'),
    _Legal('Loi 77-15 (2016)', 'Interdiction sacs plastique',
        Icons.shopping_bag_outlined,
        'Interdit fabrication, import, commercialisation sacs plastique < 60 microns. Amende fabricants : 200 000 à 1 000 000 DH. Amende commerçants : 1 000 à 10 000 DH. Prison 1 à 3 mois. Seuls sacs certifiés biodégradables (NM ISO 17088) autorisés.',
        titleEn: 'Plastic bag ban',
        titleAr: 'حظر الأكياس البلاستيكية',
        titleEs: 'Prohibición de bolsas de plástico',
        descEn: 'Prohibits production, import and sale of plastic bags < 60 microns. Manufacturer fine: 200,000 to 1,000,000 DH. Retailer fine: 1,000 to 10,000 DH. Prison 1 to 3 months. Only NM ISO 17088-certified biodegradable bags allowed.',
        descAr: 'يحظر تصنيع واستيراد وتسويق الأكياس البلاستيكية < 60 ميكرون. غرامة المصنعين: من 200,000 إلى 1,000,000 درهم. غرامة التجار: من 1,000 إلى 10,000 درهم. سجن من 1 إلى 3 أشهر. يُسمح فقط بالأكياس القابلة للتحلل المعتمدة (NM ISO 17088).',
        descEs: 'Prohíbe fabricación, importación y comercialización de bolsas de plástico < 60 micras. Multa fabricantes: 200.000 a 1.000.000 DH. Multa comerciantes: 1.000 a 10.000 DH. Prisión de 1 a 3 meses. Solo se permiten bolsas biodegradables certificadas (NM ISO 17088).'),
    _Legal('Décret 2-14-782 (2015)', 'DEEE — Responsabilité élargie producteurs',
        Icons.phone_android_rounded,
        'Fabricants et importateurs d\'électronique financent collecte et traitement DEEE. Objectif : 65% de collecte d\'ici 2030. Reprise obligatoire 1 pour 1 dans magasins > 400 m². Amende : 50 000 à 500 000 DH + 3 à 12 mois de prison.',
        titleEn: 'WEEE — Extended Producer Responsibility',
        titleAr: 'DEEE — المسؤولية الموسعة للمنتجين',
        titleEs: 'RAEE — Responsabilidad ampliada del productor',
        descEn: 'Electronics manufacturers and importers fund WEEE collection and treatment. Target: 65% collection rate by 2030. Mandatory 1-for-1 take-back in stores > 400 m². Fine: 50,000 to 500,000 DH + 3 to 12 months prison.',
        descAr: 'يموّل مصنعو الإلكترونيات ومستورديها جمع ومعالجة DEEE. الهدف: 65٪ معدل جمع بحلول 2030. استرجاع إلزامي 1 مقابل 1 في المحلات > 400 م². غرامة: من 50,000 إلى 500,000 درهم + سجن من 3 إلى 12 شهرًا.',
        descEs: 'Los fabricantes e importadores de electrónica financian la recogida y tratamiento de RAEE. Objetivo: 65% de tasa de recogida para 2030. Recogida obligatoria 1 por 1 en tiendas > 400 m². Multa: 50.000 a 500.000 DH + prisión de 3 a 12 meses.'),
    _Legal('Décret 2-09-139 (2009)', 'Déchets dangereux — Procédures',
        Icons.warning_amber_rounded,
        'Procédures de gestion, traitement et élimination des déchets dangereux. Déclaration obligatoire pour producteurs > 500 kg/an. Bordereau de suivi obligatoire. Complété par Arrêté 3286-08 (liste officielle), Arrêté 2073-14 (huiles usagées).',
        titleEn: 'Hazardous waste — Procedures',
        titleAr: 'النفايات الخطرة — الإجراءات',
        titleEs: 'Residuos peligrosos — Procedimientos',
        descEn: 'Procedures for management, treatment and disposal of hazardous waste. Mandatory declaration for producers > 500 kg/year. Mandatory tracking form. Supplemented by Order 3286-08 (official list), Order 2073-14 (used oils).',
        descAr: 'إجراءات إدارة ومعالجة والتخلص من النفايات الخطرة. إعلان إلزامي للمنتجين > 500 كغ/سنة. بيان تتبع إلزامي. يُكمله قرار 3286-08 (القائمة الرسمية)، قرار 2073-14 (الزيوت المستعملة).',
        descEs: 'Procedimientos de gestión, tratamiento y eliminación de residuos peligrosos. Declaración obligatoria para productores > 500 kg/año. Hoja de seguimiento obligatoria. Complementado por Orden 3286-08 (lista oficial), Orden 2073-14 (aceites usados).'),
    _Legal('SNGD 2030', 'Stratégie Nationale Gestion des Déchets',
        Icons.flag_rounded,
        'Budget 40 milliards DH (2021-2030). Objectifs : 90% collecte urbaine, 35 centres de tri dans villes > 50 000 hab., 20% taux de recyclage ménager, fermeture 300+ décharges sauvages, 50 unités de compostage. Tri à la source dans 20 villes pilotes d\'ici 2025.',
        titleEn: 'National Waste Management Strategy',
        titleAr: 'الاستراتيجية الوطنية لتدبير النفايات',
        titleEs: 'Estrategia Nacional de Gestión de Residuos',
        descEn: 'Budget 40 billion DH (2021–2030). Targets: 90% urban collection, 35 sorting centres in cities > 50,000 pop., 20% household recycling rate, closure of 300+ illegal dumps, 50 composting units. Source separation in 20 pilot cities by 2025.',
        descAr: 'ميزانية 40 مليار درهم (2021-2030). الأهداف: 90٪ جمع حضري، 35 مركز فرز في مدن > 50,000 ساكن، 20٪ معدل إعادة تدوير منزلي، إغلاق 300+ مطرح عشوائي، 50 وحدة تسميد. الفرز من المصدر في 20 مدينة نموذجية بحلول 2025.',
        descEs: 'Presupuesto de 40.000 millones DH (2021-2030). Objetivos: 90% de recogida urbana, 35 centros de clasificación en ciudades > 50.000 hab., 20% de tasa de reciclaje doméstico, cierre de 300+ vertederos ilegales, 50 unidades de compostaje. Separación en origen en 20 ciudades piloto para 2025.'),
    _Legal('Loi 99-12', 'Charte nationale environnement',
        Icons.balance_rounded,
        'Charte Nationale de l\'Environnement et du Développement Durable. Consacre le droit à un environnement sain. Base juridique de toutes les politiques environnementales marocaines.',
        titleEn: 'National environment charter',
        titleAr: 'الميثاق الوطني للبيئة',
        titleEs: 'Carta nacional del medio ambiente',
        descEn: 'National Charter for Environment and Sustainable Development. Enshrines the right to a healthy environment. Legal basis for all Moroccan environmental policies.',
        descAr: 'الميثاق الوطني للبيئة والتنمية المستدامة. يكرس الحق في بيئة سليمة. الأساس القانوني لجميع السياسات البيئية المغربية.',
        descEs: 'Carta Nacional del Medio Ambiente y el Desarrollo Sostenible. Consagra el derecho a un medio ambiente sano. Base jurídica de todas las políticas medioambientales marroquíes.'),
    _Legal('Convention de Bâle (1995)', 'Déchets dangereux transfrontaliers',
        Icons.public_rounded,
        'Ratifiée par le Maroc. Interdit export déchets dangereux vers pays non-OCDE sans preuve de traitement conforme. Sanction : 500 000 à 2 000 000 DH + 6 à 24 mois prison. Convention de Bamako (1991) renforce cette protection pour l\'Afrique.',
        titleEn: 'Transboundary hazardous waste',
        titleAr: 'النفايات الخطرة عبر الحدود',
        titleEs: 'Residuos peligrosos transfronterizos',
        descEn: 'Ratified by Morocco. Prohibits export of hazardous waste to non-OECD countries without proof of compliant treatment. Penalty: 500,000 to 2,000,000 DH + 6 to 24 months prison. Bamako Convention (1991) reinforces this protection for Africa.',
        descAr: 'مصادق عليها من المغرب. تحظر تصدير النفايات الخطرة إلى دول غير منظمة التعاون الاقتصادي دون إثبات المعالجة المطابقة. عقوبة: من 500,000 إلى 2,000,000 درهم + سجن من 6 إلى 24 شهرًا. تعزز اتفاقية باماكو (1991) هذه الحماية لأفريقيا.',
        descEs: 'Ratificada por Marruecos. Prohíbe exportar residuos peligrosos a países no-OCDE sin prueba de tratamiento conforme. Sanción: 500.000 a 2.000.000 DH + prisión de 6 a 24 meses. El Convenio de Bamako (1991) refuerza esta protección para África.'),
    _Legal('Accord de Paris (2016)', 'Réduction GES — 42% d\'ici 2030',
        Icons.eco_rounded,
        'Le Maroc s\'engage à réduire ses GES de 42% d\'ici 2030. Les déchets représentent 4,7% des émissions. Agenda ODD 2030 cible 12.5 : réduire de 50% la génération de déchets d\'ici 2030 par prévention, réutilisation et recyclage.',
        titleEn: 'GHG reduction — 42% by 2030',
        titleAr: 'تخفيض غازات الاحتباس الحراري — 42٪ بحلول 2030',
        titleEs: 'Reducción de GEI — 42% para 2030',
        descEn: 'Morocco commits to reducing GHG by 42% by 2030. Waste represents 4.7% of emissions. SDG 2030 target 12.5: reduce waste generation by 50% by 2030 through prevention, reuse and recycling.',
        descAr: 'يلتزم المغرب بتخفيض غازات الاحتباس الحراري بنسبة 42٪ بحلول 2030. تمثل النفايات 4.7٪ من الانبعاثات. هدف SDG 2030 رقم 12.5: تخفيض توليد النفايات بنسبة 50٪ بحلول 2030 عبر الوقاية وإعادة الاستخدام والتدوير.',
        descEs: 'Marruecos se compromete a reducir sus GEI un 42% para 2030. Los residuos representan el 4,7% de las emisiones. Objetivo ODS 2030 meta 12.5: reducir en un 50% la generación de residuos para 2030 mediante prevención, reutilización y reciclaje.'),
    _Legal('Décret 2-20-446 (2020)', 'Renforcement sanctions (+50%)',
        Icons.gavel_rounded,
        'Révision à la hausse des amendes environnementales (+50%). Zéro tolérance pour les rejets illégaux. En cas de préjudice grave, le tribunal ordonne la remise en état du site aux frais du contrevenant.',
        titleEn: 'Tightened penalties (+50%)',
        titleAr: 'تشديد العقوبات (+50٪)',
        titleEs: 'Endurecimiento de sanciones (+50%)',
        descEn: 'Upward revision of environmental fines (+50%). Zero tolerance for illegal discharges. In case of serious damage, the court orders site restoration at the offender\'s expense.',
        descAr: 'مراجعة تصاعدية للغرامات البيئية (+50٪). تسامح صفري مع الصرف غير القانوني. في حالة الضرر الجسيم، تأمر المحكمة بإعادة تأهيل الموقع على نفقة المخالف.',
        descEs: 'Revisión al alza de las multas medioambientales (+50%). Tolerancia cero con los vertidos ilegales. En caso de daño grave, el tribunal ordena la restauración del sitio a cargo del infractor.'),
    _Legal('Feuille Route Économie Circulaire 2030', 'Programme SWITCH-Med UE-Maroc',
        Icons.autorenew_rounded,
        'Adoptée en 2023 avec appui UE. 4 axes : Production Propre, Consommation Responsable, Gestion Optimisée des Déchets, Innovation & Numérique. Introduction de la consigne bouteilles verre/PET d\'ici 2026 (pilote Casa et Rabat). EcoScan s\'inscrit dans l\'Axe 4.',
        titleEn: 'EU-Morocco SWITCH-Med programme',
        titleAr: 'برنامج SWITCH-Med الاتحاد الأوروبي-المغرب',
        titleEs: 'Programa UE-Marruecos SWITCH-Med',
        descEn: 'Adopted in 2023 with EU support. 4 pillars: Clean Production, Responsible Consumption, Optimised Waste Management, Innovation & Digital. Introduction of glass/PET bottle deposit scheme by 2026 (Casa & Rabat pilot). EcoScan is part of Pillar 4.',
        descAr: 'اعتمدت عام 2023 بدعم أوروبي. 4 محاور: الإنتاج النظيف، الاستهلاك المسؤول، التدبير الأمثل للنفايات، الابتكار والرقمنة. إدخال نظام الوديعة لزجاجات الزجاج/PET بحلول 2026 (نموذج الدار البيضاء والرباط). EcoScan ضمن المحور 4.',
        descEs: 'Adoptada en 2023 con apoyo de la UE. 4 ejes: Producción Limpia, Consumo Responsable, Gestión Óptima de Residuos, Innovación y Digital. Introducción del sistema de depósito para botellas de vidrio/PET antes de 2026 (piloto Casa y Rabat). EcoScan forma parte del Eje 4.'),
  ];

  static const _operators = [
    _Operator('ECOVALOR', 'Plastique, Métal, Papier — National',
        Icons.recycling_rounded, Color(0xFF27AE60),
        'Opérateur national de valorisation. Tél : 0522 35 66 00 — Usine Aïn Sebaâ, Casablanca. Présent dans 20+ villes. Points de collecte dans Marjane, Carrefour, Label\'Vie.',
        roleEn: 'Plastic, Metal, Paper — National',
        roleAr: 'البلاستيك والمعدن والورق — وطني',
        roleEs: 'Plástico, Metal, Papel — Nacional',
        descEn: 'National recovery operator. Tel: 0522 35 66 00 — Aïn Sebaâ plant, Casablanca. Present in 20+ cities. Collection points at Marjane, Carrefour, Label\'Vie.',
        descAr: 'مشغّل وطني لتثمين النفايات. هاتف: 0522 35 66 00 — مصنع عين السبع، الدار البيضاء. حاضر في أكثر من 20 مدينة. نقاط جمع في مرجان وكارفور ولابيلفي.',
        descEs: 'Operador nacional de valorización. Tel: 0522 35 66 00 — Planta Aïn Sebaâ, Casablanca. Presente en más de 20 ciudades. Puntos de recogida en Marjane, Carrefour, Label\'Vie.'),
    _Operator('AVERDA Maroc', 'Collecte & tri sélectif — National',
        Icons.local_shipping_rounded, Color(0xFF2980B9),
        'Opérateur national collecte OM. Tél : 0537 71 10 10 — Rabat. Gestion déléguée dans plusieurs villes. Camions de collecte + centres de tri.',
        roleEn: 'Collection & selective sorting — National',
        roleAr: 'الجمع والفرز الانتقائي — وطني',
        roleEs: 'Recogida y clasificación selectiva — Nacional',
        descEn: 'National household waste collection operator. Tel: 0537 71 10 10 — Rabat. Delegated management in several cities. Collection trucks + sorting centres.',
        descAr: 'مشغّل وطني لجمع النفايات المنزلية. هاتف: 0537 71 10 10 — الرباط. تدبير مفوض في عدة مدن. شاحنات جمع + مراكز فرز.',
        descEs: 'Operador nacional de recogida de residuos domésticos. Tel: 0537 71 10 10 — Rabat. Gestión delegada en varias ciudades. Camiones de recogida + centros de clasificación.'),
    _Operator('SITA El Beida', 'Collecte ordures ménagères',
        Icons.delete_rounded, Color(0xFF5D6D7E),
        'Collecte et traitement des déchets ménagers. Tél : 0522 90 48 00 — Casablanca. Filiale groupe SUEZ Environnement.',
        roleEn: 'Household waste collection',
        roleAr: 'جمع النفايات المنزلية',
        roleEs: 'Recogida de residuos domésticos',
        descEn: 'Household waste collection and treatment. Tel: 0522 90 48 00 — Casablanca. Subsidiary of SUEZ Environnement group.',
        descAr: 'جمع ومعالجة النفايات المنزلية. هاتف: 0522 90 48 00 — الدار البيضاء. فرع مجموعة SUEZ Environnement.',
        descEs: 'Recogida y tratamiento de residuos domésticos. Tel: 0522 90 48 00 — Casablanca. Filial del grupo SUEZ Environnement.'),
    _Operator('TECMED', 'DEEE & déchets dangereux — National',
        Icons.electrical_services_rounded, AppColors.electronics,
        'Collecte et traitement DEEE (ordinateurs, téléphones, TV). Tél : 0523 32 00 00 — Mohammedia. Sites Tanger Nord aussi. Agréé MTEDD.',
        roleEn: 'WEEE & hazardous waste — National',
        roleAr: 'DEEE والنفايات الخطرة — وطني',
        roleEs: 'RAEE y residuos peligrosos — Nacional',
        descEn: 'WEEE collection and treatment (computers, phones, TVs). Tel: 0523 32 00 00 — Mohammedia. Also at Tangier North sites. Approved by MTEDD.',
        descAr: 'جمع ومعالجة DEEE (حواسيب، هواتف، تلفزيونات). هاتف: 0523 32 00 00 — المحمدية. مواقع بطنجة الشمالية أيضًا. معتمد من MTEDD.',
        descEs: 'Recogida y tratamiento de RAEE (ordenadores, teléfonos, TV). Tel: 0523 32 00 00 — Mohammedia. También en Tánger Norte. Autorizado por MTEDD.'),
    _Operator('Moroccan Green', 'PET & plastiques — National',
        Icons.opacity_rounded, AppColors.plastic,
        'Recyclage plastique PET et PEHD. Tél : 0522 40 09 09 — Casablanca. Collecte bouteilles PET auprès ménages et industries.',
        roleEn: 'PET & plastics — National',
        roleAr: 'PET والبلاستيك — وطني',
        roleEs: 'PET y plásticos — Nacional',
        descEn: 'PET and HDPE plastic recycling. Tel: 0522 40 09 09 — Casablanca. Collects PET bottles from households and industry.',
        descAr: 'إعادة تدوير البلاستيك PET وPEHD. هاتف: 0522 40 09 09 — الدار البيضاء. يجمع زجاجات PET من الأسر والصناعة.',
        descEs: 'Reciclaje de plástico PET y PEHD. Tel: 0522 40 09 09 — Casablanca. Recoge botellas PET de hogares e industria.'),
    _Operator('PREVOR Maroc', 'Déchets industriels dangereux',
        Icons.warning_amber_rounded, Color(0xFFE74C3C),
        'Collecte et traitement déchets industriels dangereux. Tél : 0522 23 45 67 — Casablanca. Agréé Ministère Transition Énergétique.',
        roleEn: 'Industrial hazardous waste',
        roleAr: 'النفايات الصناعية الخطرة',
        roleEs: 'Residuos industriales peligrosos',
        descEn: 'Industrial hazardous waste collection and treatment. Tel: 0522 23 45 67 — Casablanca. Approved by Ministry of Energy Transition.',
        descAr: 'جمع ومعالجة النفايات الصناعية الخطرة. هاتف: 0522 23 45 67 — الدار البيضاء. معتمد من وزارة الانتقال الطاقي.',
        descEs: 'Recogida y tratamiento de residuos industriales peligrosos. Tel: 0522 23 45 67 — Casablanca. Autorizado por el Ministerio de Transición Energética.'),
    _Operator('OZONE Environnement', 'Huiles usagées & solvants',
        Icons.water_drop_rounded, Color(0xFF8E44AD),
        'Collecte et valorisation des huiles de vidange usagées et solvants industriels. Tél : 0522 88 76 54 — Casablanca.',
        roleEn: 'Used oils & solvents',
        roleAr: 'الزيوت المستعملة والمذيبات',
        roleEs: 'Aceites usados y solventes',
        descEn: 'Collection and recovery of used motor oils and industrial solvents. Tel: 0522 88 76 54 — Casablanca.',
        descAr: 'جمع وتثمين زيوت المحرك المستعملة والمذيبات الصناعية. هاتف: 0522 88 76 54 — الدار البيضاء.',
        descEs: 'Recogida y valorización de aceites de motor usados y solventes industriales. Tel: 0522 88 76 54 — Casablanca.'),
    _Operator('ECO-TLC Maroc', 'Textiles & vêtements usagés',
        Icons.checkroom_rounded, Color(0xFF9B59B6),
        'Éco-organisme pour collecte et valorisation textiles usés. Tél : 0522 55 44 33 — Casablanca. Bornes de collecte dans 15+ villes.',
        roleEn: 'Textiles & used clothing',
        roleAr: 'المنسوجات والملابس المستعملة',
        roleEs: 'Textiles y ropa usada',
        descEn: 'Eco-organisation for used textile collection and recovery. Tel: 0522 55 44 33 — Casablanca. Collection bins in 15+ cities.',
        descAr: 'هيئة بيئية لجمع وتثمين المنسوجات المستعملة. هاتف: 0522 55 44 33 — الدار البيضاء. حاويات جمع في أكثر من 15 مدينة.',
        descEs: 'Eco-organismo para la recogida y valorización de textiles usados. Tel: 0522 55 44 33 — Casablanca. Contenedores de recogida en más de 15 ciudades.'),
    _Operator('SOUSS RECYCLAGE', 'Multi-matériaux — Sud Maroc',
        Icons.recycling_rounded, Color(0xFF1E8449),
        'Plastique, métal, papier — toute la région Souss-Massa. Tél : 0528 83 12 34 — Agadir. Centre de tri zone industrielle.',
        roleEn: 'Multi-material — Southern Morocco',
        roleAr: 'متعدد المواد — جنوب المغرب',
        roleEs: 'Multimaterial — Sur de Marruecos',
        descEn: 'Plastic, metal, paper — entire Souss-Massa region. Tel: 0528 83 12 34 — Agadir. Sorting centre in industrial zone.',
        descAr: 'البلاستيك والمعدن والورق — كامل منطقة سوس-ماسة. هاتف: 0528 83 12 34 — أكادير. مركز فرز في المنطقة الصناعية.',
        descEs: 'Plástico, metal, papel — toda la región Souss-Massa. Tel: 0528 83 12 34 — Agadir. Centro de clasificación en zona industrial.'),
    _Operator('RECYCLAGE MAGHREB', 'Multi-matériaux — National',
        Icons.loop_rounded, Color(0xFF2C3E50),
        'Recyclage multi-matériaux. Tél : 0522 67 89 01 — Aïn Sebaâ, Casablanca. Partenaire industrie et collectivités.',
        roleEn: 'Multi-material — National',
        roleAr: 'متعدد المواد — وطني',
        roleEs: 'Multimaterial — Nacional',
        descEn: 'Multi-material recycling. Tel: 0522 67 89 01 — Aïn Sebaâ, Casablanca. Partner to industry and local authorities.',
        descAr: 'إعادة تدوير متعددة المواد. هاتف: 0522 67 89 01 — عين السبع، الدار البيضاء. شريك الصناعة والجماعات الترابية.',
        descEs: 'Reciclaje multimaterial. Tel: 0522 67 89 01 — Aïn Sebaâ, Casablanca. Socio de la industria y las colectividades locales.'),
    _Operator('Zéro Zbel', 'ONG tri & sensibilisation',
        Icons.volunteer_activism_rounded, Color(0xFF7D6608),
        'ONG pionnière du tri au Maroc. contact@zerozabel.ma. Sensibilisation dans écoles, entreprises et communes. Programmes de compostage communautaire.',
        roleEn: 'NGO sorting & awareness',
        roleAr: 'جمعية فرز وتوعية',
        roleEs: 'ONG clasificación y sensibilización',
        descEn: 'Pioneer sorting NGO in Morocco. contact@zerozabel.ma. Awareness in schools, companies and municipalities. Community composting programmes.',
        descAr: 'جمعية رائدة في الفرز بالمغرب. contact@zerozabel.ma. توعية في المدارس والشركات والبلديات. برامج التسميد المجتمعي.',
        descEs: 'ONG pionera en clasificación en Marruecos. contact@zerozabel.ma. Sensibilización en escuelas, empresas y municipios. Programas de compostaje comunitario.'),
    _Operator('Green Morocco', 'Association environnement',
        Icons.park_rounded, Color(0xFF145A32),
        'Plages propres, nettoyages collectifs. Tél : 0522 55 11 22 — Casablanca. Projets recyclage communautaires et sensibilisation.',
        roleEn: 'Environmental association',
        roleAr: 'جمعية بيئية',
        roleEs: 'Asociación medioambiental',
        descEn: 'Beach clean-ups, collective cleanups. Tel: 0522 55 11 22 — Casablanca. Community recycling projects and awareness campaigns.',
        descAr: 'تنظيف الشواطئ والتنظيفات الجماعية. هاتف: 0522 55 11 22 — الدار البيضاء. مشاريع إعادة تدوير مجتمعية وحملات توعية.',
        descEs: 'Limpieza de playas y limpiezas colectivas. Tel: 0522 55 11 22 — Casablanca. Proyectos de reciclaje comunitario y campañas de sensibilización.'),
  ];

  static const _impacts = [
    _Impact('Métal (alu)', '8 kg CO₂ économisés par kg recyclé', '2 700 ans', Icons.hardware_rounded, AppColors.metal,
        categoryEn: 'Metal (aluminium)', benefitEn: '8 kg CO₂ saved per kg recycled', decompEn: '2,700 years',
        categoryAr: 'المعدن (الألومنيوم)', benefitAr: '8 كغ CO₂ موفرة لكل كغ مُعاد تدويره', decompAr: '2,700 سنة',
        categoryEs: 'Metal (aluminio)', benefitEs: '8 kg CO₂ ahorrados por kg reciclado', decompEs: '2.700 años'),
    _Impact('Verre', '300 kg CO₂ économisés par tonne', '4 000 ans', Icons.local_bar_outlined, AppColors.glass,
        categoryEn: 'Glass', benefitEn: '300 kg CO₂ saved per tonne', decompEn: '4,000 years',
        categoryAr: 'الزجاج', benefitAr: '300 كغ CO₂ موفرة لكل طن', decompAr: '4,000 سنة',
        categoryEs: 'Vidrio', benefitEs: '300 kg CO₂ ahorrados por tonelada', decompEs: '4.000 años'),
    _Impact('Plastique PET', '1,5 kg CO₂ économisés par kg', '500 ans', Icons.opacity_rounded, AppColors.plastic,
        categoryEn: 'PET Plastic', benefitEn: '1.5 kg CO₂ saved per kg', decompEn: '500 years',
        categoryAr: 'البلاستيك PET', benefitAr: '1.5 كغ CO₂ موفرة لكل كغ', decompAr: '500 سنة',
        categoryEs: 'Plástico PET', benefitEs: '1,5 kg CO₂ ahorrados por kg', decompEs: '500 años'),
    _Impact('Papier/Carton', '17 arbres sauvés par tonne', '3–6 mois', Icons.article_outlined, AppColors.paper,
        categoryEn: 'Paper/Cardboard', benefitEn: '17 trees saved per tonne', decompEn: '3–6 months',
        categoryAr: 'الورق/الكرتون', benefitAr: '17 شجرة منقذة لكل طن', decompAr: '3-6 أشهر',
        categoryEs: 'Papel/Cartón', benefitEs: '17 árboles salvados por tonelada', decompEs: '3-6 meses'),
    _Impact('Organique', '65% des déchets marocains', '2–6 mois', Icons.compost_rounded, Color(0xFF795548),
        categoryEn: 'Organic', benefitEn: '65% of Moroccan waste', decompEn: '2–6 months',
        categoryAr: 'العضوي', benefitAr: '65٪ من النفايات المغربية', decompAr: '2-6 أشهر',
        categoryEs: 'Orgánico', benefitEs: '65% de los residuos marroquíes', decompEs: '2-6 meses'),
    _Impact('Électronique', '70 kg CO₂ économisés/ordinateur', '> 1 000 ans', Icons.electrical_services_rounded, AppColors.electronics,
        categoryEn: 'Electronics', benefitEn: '70 kg CO₂ saved/computer', decompEn: '> 1,000 years',
        categoryAr: 'الإلكترونيات', benefitAr: '70 كغ CO₂ موفرة/حاسوب', decompAr: '> 1,000 سنة',
        categoryEs: 'Electrónica', benefitEs: '70 kg CO₂ ahorrados/ordenador', decompEs: '> 1.000 años'),
    _Impact('Textile', '3 200 L d\'eau économisés/kg coton', '200 ans (synthétique)', Icons.checkroom_rounded, Color(0xFF9B59B6),
        categoryEn: 'Textile', benefitEn: '3,200 L water saved/kg cotton', decompEn: '200 years (synthetic)',
        categoryAr: 'المنسوجات', benefitAr: '3,200 لتر ماء موفرة/كغ قطن', decompAr: '200 سنة (اصطناعي)',
        categoryEs: 'Textil', benefitEs: '3.200 L de agua ahorrados/kg de algodón', decompEs: '200 años (sintético)'),
    _Impact('Déchets dangereux', '1 L d\'huile = 1 million L d\'eau polluée', 'Permanent', Icons.warning_amber_rounded, Color(0xFFE74C3C),
        categoryEn: 'Hazardous waste', benefitEn: '1 L oil = 1 million L polluted water', decompEn: 'Permanent',
        categoryAr: 'النفايات الخطرة', benefitAr: '1 لتر زيت = 1 مليون لتر ماء ملوث', decompAr: 'دائم',
        categoryEs: 'Residuos peligrosos', benefitEs: '1 L de aceite = 1 millón L de agua contaminada', decompEs: 'Permanente'),
  ];

  static const _rules = [
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Rincer avant de trier',
        'Un rinçage rapide suffit. Les emballages propres garantissent la qualité du recyclat et protègent les agents de tri.',
        titleEn: 'Rinse before sorting',
        titleAr: 'اشطف قبل الفرز',
        titleEs: 'Enjuagar antes de clasificar',
        descEn: 'A quick rinse is enough. Clean packaging guarantees recyclate quality and protects sorting workers.',
        descAr: 'شطف سريع يكفي. التغليف النظيف يضمن جودة المعاد تدويره ويحمي عمال الفرز.',
        descEs: 'Un enjuague rápido es suficiente. Los envases limpios garantizan la calidad del material reciclado y protegen a los trabajadores de clasificación.'),
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Ne pas emballer dans un sac plastique',
        'Les sacs plastiques sont interdits au Maroc (Loi 77-15). Déposer les emballages directement dans le bac ou la borne.',
        titleEn: 'Don\'t wrap in a plastic bag',
        titleAr: 'لا تضع في كيس بلاستيكي',
        titleEs: 'No envolver en bolsa de plástico',
        descEn: 'Plastic bags are banned in Morocco (Law 77-15). Place packaging directly in the bin or drop-off point.',
        descAr: 'الأكياس البلاستيكية محظورة في المغرب (القانون 77-15). ضع التغليف مباشرة في الحاوية أو نقطة الإيداع.',
        descEs: 'Las bolsas de plástico están prohibidas en Marruecos (Ley 77-15). Depositar los envases directamente en el contenedor o punto de entrega.'),
    _Rule(Icons.check_circle_outline_rounded, AppColors.primary,
        'Écraser les bouteilles et boîtes',
        'Réduire le volume pour optimiser la capacité des bacs ECOVAL et faciliter le transport jusqu\'au centre de tri.',
        titleEn: 'Crush bottles and cans',
        titleAr: 'اسحق الزجاجات والعلب',
        titleEs: 'Aplastar botellas y latas',
        descEn: 'Reduce volume to optimise ECOVAL bin capacity and ease transport to the sorting centre.',
        descAr: 'قلّل الحجم لتحسين سعة حاويات ECOVAL وتسهيل النقل إلى مركز الفرز.',
        descEs: 'Reducir el volumen para optimizar la capacidad de los contenedores ECOVAL y facilitar el transporte al centro de clasificación.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Jamais de déchets dangereux dans les bacs',
        'Piles, médicaments, produits chimiques ont leurs propres filières. Ils contaminent et peuvent blesser les agents de tri.',
        titleEn: 'Never put hazardous waste in bins',
        titleAr: 'لا تضع النفايات الخطرة في الحاويات أبدًا',
        titleEs: 'Nunca poner residuos peligrosos en los contenedores',
        descEn: 'Batteries, medications, chemicals have their own streams. They contaminate and can injure sorting workers.',
        descAr: 'البطاريات والأدوية والمواد الكيميائية لها مسارات خاصة. إنها تلوث وقد تُصيب عمال الفرز.',
        descEs: 'Pilas, medicamentos y productos químicos tienen sus propias vías de gestión. Contaminan y pueden herir a los trabajadores de clasificación.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Pas de verre brisé dans la colonne verte',
        'Emballer dans du carton épais et apporter en déchetterie. Le verre brisé blesse les agents et bloque les machines.',
        titleEn: 'No broken glass in the green column',
        titleAr: 'لا زجاج مكسور في العمود الأخضر',
        descEn: 'Wrap in thick cardboard and bring to a recycling centre. Broken glass injures workers and jams machines.',
        descAr: 'لفّه في كرتون سميك وأحضره إلى مركز إعادة التدوير. الزجاج المكسور يُصيب العمال ويعطّل الآلات.',
        titleEs: 'No poner vidrio roto en la columna verde',
        descEs: 'Envolver en cartón grueso y llevar a un punto de reciclaje. El vidrio roto hiere a los trabajadores y atasca las máquinas.'),
    _Rule(Icons.cancel_outlined, AppColors.danger,
        'Ne pas jeter dans la nature — Loi 28-00',
        'L\'abandon de déchets est une infraction pénale au Maroc. Amende et poursuites possibles. La déchetterie la plus proche est à votre service.',
        titleEn: 'Don\'t litter — Law 28-00',
        titleAr: 'لا ترمِ في الطبيعة — القانون 28-00',
        titleEs: 'No tirar en la naturaleza — Ley 28-00',
        descEn: 'Littering is a criminal offence in Morocco. Fines and prosecution possible. Your nearest recycling centre is at your service.',
        descAr: 'إلقاء النفايات جريمة جنائية في المغرب. غرامات ومتابعات قضائية ممكنة. أقرب مركز إعادة تدوير في خدمتك.',
        descEs: 'Tirar basura en la naturaleza es un delito en Marruecos. Posibles multas y enjuiciamiento. El punto de reciclaje más cercano está a su servicio.'),
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
  final String tipAr;
  final String tipEs;
  const _Item(this.name, this.category, this.status, this.bin,
      this.icon, this.color, this.tip, {
    this.nameEn = '', this.nameAr = '', this.nameEs = '',
    this.tipEn = '', this.tipAr = '', this.tipEs = '',
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
      case 'ar': return tipAr.isEmpty ? (tipEn.isEmpty ? tip : tipEn) : tipAr;
      case 'es': return tipEs.isEmpty ? (tipEn.isEmpty ? tip : tipEn) : tipEs;
      default:   return tipEn.isEmpty ? tip : tipEn;
    }
  }
}

class _Bin {
  final String name, nameEn, nameAr, nameEs;
  final String subtitle, subtitleEn, subtitleAr, subtitleEs;
  final Color color;
  final IconData icon;
  final List<String> items, itemsEn, itemsAr, itemsEs;
  const _Bin(this.name, this.subtitle, this.color, this.icon, this.items, {
    this.nameEn = '', this.nameAr = '', this.nameEs = '',
    this.subtitleEn = '', this.subtitleAr = '', this.subtitleEs = '',
    this.itemsEn = const [], this.itemsAr = const [], this.itemsEs = const [],
  });
  String nameFor(String lang) {
    if (lang == 'ar' && nameAr.isNotEmpty) return nameAr;
    if (lang == 'es' && nameEs.isNotEmpty) return nameEs;
    if (lang != 'fr' && nameEn.isNotEmpty) return nameEn;
    return name;
  }
  String subtitleFor(String lang) {
    if (lang == 'ar' && subtitleAr.isNotEmpty) return subtitleAr;
    if (lang == 'es' && subtitleEs.isNotEmpty) return subtitleEs;
    if (lang != 'fr' && subtitleEn.isNotEmpty) return subtitleEn;
    return subtitle;
  }
  List<String> itemsFor(String lang) {
    if (lang == 'ar' && itemsAr.isNotEmpty) return itemsAr;
    if (lang == 'es' && itemsEs.isNotEmpty) return itemsEs;
    if (lang != 'fr' && itemsEn.isNotEmpty) return itemsEn;
    return items;
  }
}

class _Legal {
  final String code;
  final String title, titleEn, titleAr, titleEs;
  final IconData icon;
  final String desc, descEn, descAr, descEs;
  const _Legal(this.code, this.title, this.icon, this.desc, {
    this.titleEn = '', this.titleAr = '', this.titleEs = '',
    this.descEn = '', this.descAr = '', this.descEs = '',
  });
  String titleFor(String lang) {
    if (lang == 'ar' && titleAr.isNotEmpty) return titleAr;
    if (lang == 'es' && titleEs.isNotEmpty) return titleEs;
    if (lang != 'fr' && titleEn.isNotEmpty) return titleEn;
    return title;
  }
  String descFor(String lang) {
    if (lang == 'ar' && descAr.isNotEmpty) return descAr;
    if (lang == 'es' && descEs.isNotEmpty) return descEs;
    if (lang != 'fr' && descEn.isNotEmpty) return descEn;
    return desc;
  }
}

class _Operator {
  final String name;
  final String role, roleEn, roleAr, roleEs;
  final IconData icon;
  final Color color;
  final String desc, descEn, descAr, descEs;
  const _Operator(this.name, this.role, this.icon, this.color, this.desc, {
    this.roleEn = '', this.roleAr = '', this.roleEs = '',
    this.descEn = '', this.descAr = '', this.descEs = '',
  });
  String roleFor(String lang) {
    if (lang == 'ar' && roleAr.isNotEmpty) return roleAr;
    if (lang == 'es' && roleEs.isNotEmpty) return roleEs;
    if (lang != 'fr' && roleEn.isNotEmpty) return roleEn;
    return role;
  }
  String descFor(String lang) {
    if (lang == 'ar' && descAr.isNotEmpty) return descAr;
    if (lang == 'es' && descEs.isNotEmpty) return descEs;
    if (lang != 'fr' && descEn.isNotEmpty) return descEn;
    return desc;
  }
}

class _Impact {
  final String category, categoryEn, categoryAr, categoryEs;
  final String benefit, benefitEn, benefitAr, benefitEs;
  final String decomp, decompEn, decompAr, decompEs;
  final IconData icon;
  final Color color;
  const _Impact(this.category, this.benefit, this.decomp, this.icon, this.color, {
    this.categoryEn = '', this.categoryAr = '', this.categoryEs = '',
    this.benefitEn = '',  this.benefitAr = '',  this.benefitEs = '',
    this.decompEn = '',   this.decompAr = '',   this.decompEs = '',
  });
  String categoryFor(String lang) {
    if (lang == 'ar' && categoryAr.isNotEmpty) return categoryAr;
    if (lang == 'es' && categoryEs.isNotEmpty) return categoryEs;
    if (lang != 'fr' && categoryEn.isNotEmpty) return categoryEn;
    return category;
  }
  String benefitFor(String lang) {
    if (lang == 'ar' && benefitAr.isNotEmpty) return benefitAr;
    if (lang == 'es' && benefitEs.isNotEmpty) return benefitEs;
    if (lang != 'fr' && benefitEn.isNotEmpty) return benefitEn;
    return benefit;
  }
  String decompFor(String lang) {
    if (lang == 'ar' && decompAr.isNotEmpty) return decompAr;
    if (lang == 'es' && decompEs.isNotEmpty) return decompEs;
    if (lang != 'fr' && decompEn.isNotEmpty) return decompEn;
    return decomp;
  }
}

class _Rule {
  final IconData icon;
  final Color color;
  final String title, titleEn, titleAr, titleEs;
  final String desc, descEn, descAr, descEs;
  const _Rule(this.icon, this.color, this.title, this.desc, {
    this.titleEn = '', this.titleAr = '', this.titleEs = '',
    this.descEn = '', this.descAr = '', this.descEs = '',
  });
  String titleFor(String lang) {
    if (lang == 'ar' && titleAr.isNotEmpty) return titleAr;
    if (lang == 'es' && titleEs.isNotEmpty) return titleEs;
    if (lang != 'fr' && titleEn.isNotEmpty) return titleEn;
    return title;
  }
  String descFor(String lang) {
    if (lang == 'ar' && descAr.isNotEmpty) return descAr;
    if (lang == 'es' && descEs.isNotEmpty) return descEs;
    if (lang != 'fr' && descEn.isNotEmpty) return descEn;
    return desc;
  }
}

class _RegionalOp {
  final String name;
  final String specialty, specialtyEn, specialtyAr, specialtyEs;
  final String phone;
  final String city;
  const _RegionalOp(this.name, this.specialty, this.phone, this.city, {
    this.specialtyEn = '', this.specialtyAr = '', this.specialtyEs = '',
  });
  String specialtyFor(String lang) {
    if (lang == 'ar' && specialtyAr.isNotEmpty) return specialtyAr;
    if (lang == 'es' && specialtyEs.isNotEmpty) return specialtyEs;
    if (lang != 'fr' && specialtyEn.isNotEmpty) return specialtyEn;
    return specialty;
  }
}

class _RegionData {
  final String name;
  final List<_RegionalOp> ops;
  const _RegionData(this.name, this.ops);
}

class _ImpactDetail {
  final String category, categoryEn, categoryAr, categoryEs;
  final IconData icon;
  final Color color;
  final String co2, co2En, co2Ar, co2Es;
  final String energy;
  final String decomp, decompEn, decompAr, decompEs;
  final List<String> positifs, positifsEn, positifsAr, positifsEs;
  final List<String> negatifs, negatifsEn, negatifsAr, negatifsEs;
  const _ImpactDetail({
    required this.category, this.categoryEn = '', this.categoryAr = '', this.categoryEs = '',
    required this.icon, required this.color,
    required this.co2, this.co2En = '', this.co2Ar = '', this.co2Es = '',
    required this.energy,
    required this.decomp, this.decompEn = '', this.decompAr = '', this.decompEs = '',
    required this.positifs, this.positifsEn = const [], this.positifsAr = const [], this.positifsEs = const [],
    required this.negatifs, this.negatifsEn = const [], this.negatifsAr = const [], this.negatifsEs = const [],
  });
  String categoryFor(String lang) {
    if (lang == 'ar' && categoryAr.isNotEmpty) return categoryAr;
    if (lang == 'es' && categoryEs.isNotEmpty) return categoryEs;
    if (lang != 'fr' && categoryEn.isNotEmpty) return categoryEn;
    return category;
  }
  String co2For(String lang) {
    if (lang == 'ar' && co2Ar.isNotEmpty) return co2Ar;
    if (lang == 'es' && co2Es.isNotEmpty) return co2Es;
    if (lang != 'fr' && co2En.isNotEmpty) return co2En;
    return co2;
  }
  String decompFor(String lang) {
    if (lang == 'ar' && decompAr.isNotEmpty) return decompAr;
    if (lang == 'es' && decompEs.isNotEmpty) return decompEs;
    if (lang != 'fr' && decompEn.isNotEmpty) return decompEn;
    return decomp;
  }
  List<String> positifsFor(String lang) {
    if (lang == 'ar' && positifsAr.isNotEmpty) return positifsAr;
    if (lang == 'es' && positifsEs.isNotEmpty) return positifsEs;
    if (lang != 'fr' && positifsEn.isNotEmpty) return positifsEn;
    return positifs;
  }
  List<String> negatifsFor(String lang) {
    if (lang == 'ar' && negatifsAr.isNotEmpty) return negatifsAr;
    if (lang == 'es' && negatifsEs.isNotEmpty) return negatifsEs;
    if (lang != 'fr' && negatifsEn.isNotEmpty) return negatifsEn;
    return negatifs;
  }
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

class _Sanction {
  final String name, nameEn, nameAr, nameEs;
  final String fine;
  final Color color;
  const _Sanction(this.name, this.fine, this.color, {
    this.nameEn = '', this.nameAr = '', this.nameEs = '',
  });
  String nameFor(String lang) {
    if (lang == 'ar' && nameAr.isNotEmpty) return nameAr;
    if (lang == 'es' && nameEs.isNotEmpty) return nameEs;
    if (lang != 'fr' && nameEn.isNotEmpty) return nameEn;
    return name;
  }
}

class _Norme {
  final String code;
  final String desc, descEn, descAr, descEs;
  const _Norme(this.code, this.desc, {
    this.descEn = '', this.descAr = '', this.descEs = '',
  });
  String descFor(String lang) {
    if (lang == 'ar' && descAr.isNotEmpty) return descAr;
    if (lang == 'es' && descEs.isNotEmpty) return descEs;
    if (lang != 'fr' && descEn.isNotEmpty) return descEn;
    return desc;
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
                  s.guideLegalBanner,
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
                  s.guideSanctionsHeader,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 10),
        ..._sanctions.map((sanction) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sanction.color.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04), blurRadius: 5)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: sanction.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.warning_amber_rounded, color: sanction.color, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sanction.nameFor(lang), style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(sanction.fine, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
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
              ..._normes.map((norme) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 4, height: 4,
                      margin: const EdgeInsets.fromLTRB(2, 5, 8, 0),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  Expanded(child: RichText(text: TextSpan(children: [
                    TextSpan(text: '${norme.code} — ', style: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    TextSpan(text: norme.descFor(lang), style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
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
    _Sanction('Dépôt illégal déchets ménagers', '500 à 5 000 DH (Loi 28-00 Art.45)', Color(0xFFE67E22),
        nameEn: 'Illegal deposit of household waste',
        nameAr: 'إيداع غير قانوني للنفايات المنزلية',
        nameEs: 'Depósito ilegal de residuos domésticos'),
    _Sanction('Abandon déchets sur voie publique', '1 000 à 10 000 DH (Loi 28-00 Art.46)', Color(0xFFE67E22),
        nameEn: 'Littering on public road',
        nameAr: 'إلقاء النفايات في الطريق العام',
        nameEs: 'Abandono de residuos en vía pública'),
    _Sanction('Décharge sauvage déchets industriels', '10 000 à 100 000 DH + 1 à 3 mois prison (Art.47)', Color(0xFFE74C3C),
        nameEn: 'Illegal industrial waste dumping',
        nameAr: 'مطرح عشوائي لنفايات صناعية',
        nameEs: 'Vertido ilegal de residuos industriales'),
    _Sanction('Rejet déchets dangereux sans autorisation', '100 000 à 500 000 DH + 3 à 12 mois prison (Art.48)', Color(0xFFE74C3C),
        nameEn: 'Discharge of hazardous waste without permit',
        nameAr: 'صرف نفايات خطرة بدون ترخيص',
        nameEs: 'Vertido de residuos peligrosos sin autorización'),
    _Sanction('Fabrication sacs plastiques interdits', '200 000 à 1 000 000 DH + 1 à 3 mois prison (Loi 77-15)', Color(0xFFE74C3C),
        nameEn: 'Manufacturing banned plastic bags',
        nameAr: 'تصنيع أكياس بلاستيكية محظورة',
        nameEs: 'Fabricación de bolsas de plástico prohibidas'),
    _Sanction('Commerce sacs plastiques interdits', '1 000 à 10 000 DH (Loi 77-15 Art.13)', Color(0xFFE67E22),
        nameEn: 'Trading banned plastic bags',
        nameAr: 'تسويق أكياس بلاستيكية محظورة',
        nameEs: 'Comercio de bolsas de plástico prohibidas'),
    _Sanction('Rejet huiles usagées en milieu naturel', '50 000 à 200 000 DH + 1 à 6 mois prison', Color(0xFFE74C3C),
        nameEn: 'Discharge of used oils in nature',
        nameAr: 'صرف الزيوت المستعملة في البيئة الطبيعية',
        nameEs: 'Vertido de aceites usados en la naturaleza'),
    _Sanction('Traitement DEEE sans agrément', '50 000 à 500 000 DH + 3 à 12 mois prison (Décret 2-14-782)', Color(0xFFE74C3C),
        nameEn: 'WEEE treatment without approval',
        nameAr: 'معالجة DEEE بدون اعتماد',
        nameEs: 'Tratamiento RAEE sin autorización'),
    _Sanction('Exportation illégale déchets dangereux', '500 000 à 2 000 000 DH + 6 à 24 mois (Conv. Bâle)', Color(0xFFC0392B),
        nameEn: 'Illegal export of hazardous waste',
        nameAr: 'تصدير غير قانوني للنفايات الخطرة',
        nameEs: 'Exportación ilegal de residuos peligrosos'),
    _Sanction('Pollution délibérée nappe phréatique', '1 000 000 DH+ et jusqu\'à 5 ans de prison', Color(0xFFC0392B),
        nameEn: 'Deliberate groundwater pollution',
        nameAr: 'تلوث متعمد للمياه الجوفية',
        nameEs: 'Contaminación deliberada de aguas subterráneas'),
    _Sanction('Non-déclaration déchets dangereux', '20 000 à 100 000 DH (Loi 28-00 Art.22)', Color(0xFFE67E22),
        nameEn: 'Non-declaration of hazardous waste',
        nameAr: 'عدم التصريح بالنفايات الخطرة',
        nameEs: 'No declaración de residuos peligrosos'),
    _Sanction('Infraction récidiviste (tous types)', 'Double de l\'amende + doublement de la peine (Art.53)', Color(0xFFE74C3C),
        nameEn: 'Repeat offence (all types)',
        nameAr: 'مخالفة متكررة (جميع الأنواع)',
        nameEs: 'Reincidencia (todos los tipos)'),
  ];

  static const _normes = [
    _Norme('NM 03.7.001', 'Classification des plastiques recyclables par code résine (1 à 7)',
        descEn: 'Classification of recyclable plastics by resin code (1 to 7)',
        descAr: 'تصنيف البلاستيك القابل لإعادة التدوير حسب رمز الراتنج (1 إلى 7)',
        descEs: 'Clasificación de plásticos reciclables por código de resina (1 a 7)'),
    _Norme('NM ISO 17088', 'Plastiques biodégradables et compostables — spécifications',
        descEn: 'Biodegradable and compostable plastics — specifications',
        descAr: 'البلاستيك القابل للتحلل والتسميد — المواصفات',
        descEs: 'Plásticos biodegradables y compostables — especificaciones'),
    _Norme('NM 13.030', 'Gestion des déchets solides — terminologie et classification',
        descEn: 'Solid waste management — terminology and classification',
        descAr: 'تدبير النفايات الصلبة — المصطلحات والتصنيف',
        descEs: 'Gestión de residuos sólidos — terminología y clasificación'),
    _Norme('NM 10.4.034', 'Piles et accumulateurs — collecte, traitement, recyclage',
        descEn: 'Batteries and accumulators — collection, treatment, recycling',
        descAr: 'الأعمدة والمراكم — الجمع والمعالجة وإعادة التدوير',
        descEs: 'Pilas y acumuladores — recogida, tratamiento, reciclaje'),
    _Norme('NM ISO 14044', 'Management environnemental — Analyse du Cycle de Vie (ACV)',
        descEn: 'Environmental management — Life Cycle Assessment (LCA)',
        descAr: 'الإدارة البيئية — تحليل دورة الحياة (ACV)',
        descEs: 'Gestión ambiental — Análisis del Ciclo de Vida (ACV)'),
    _Norme('NM ISO 14001', 'Systèmes de management environnemental — opérateurs recyclage',
        descEn: 'Environmental management systems — recycling operators',
        descAr: 'أنظمة الإدارة البيئية — مشغلو إعادة التدوير',
        descEs: 'Sistemas de gestión ambiental — operadores de reciclaje'),
    _Norme('NM 31.090', 'Appareils électroménagers — conditions de reprise et recyclage',
        descEn: 'Household appliances — take-back and recycling conditions',
        descAr: 'الأجهزة المنزلية — شروط الاسترجاع وإعادة التدوير',
        descEs: 'Electrodomésticos — condiciones de devolución y reciclaje'),
  ];
}

// ── Impact environnemental page ───────────────────────────────────────────────

class _ImpactDetailPage extends ConsumerWidget {
  final bool isDark;
  const _ImpactDetailPage({required this.isDark});

  static const _details = [
    _ImpactDetail(
      category: 'Métal & Aluminium', categoryEn: 'Metal & Aluminium', categoryAr: 'المعادن والألمنيوم', categoryEs: 'Metal y Aluminio',
      icon: Icons.hardware_rounded, color: AppColors.metal,
      co2: '8 kg CO₂/kg recyclé', co2En: '8 kg CO₂/kg recycled', co2Ar: '8 كجم CO₂/كجم معاد تدويره', co2Es: '8 kg CO₂/kg reciclado',
      energy: '95% énergie économisée',
      decomp: '2 700 ans', decompEn: '2,700 years', decompAr: '2,700 سنة', decompEs: '2.700 años',
      positifs: [
        'Recycler 1 kg d\'alu économise 8 kg CO₂ et évite l\'extraction de 4 kg de bauxite',
        'L\'alu peut être recyclé à l\'infini sans perdre ses propriétés mécaniques',
        '1 tonne d\'acier recyclé économise 1,1 t de minerai de fer et 630 kg de charbon',
        'Une canette recyclée économise assez d\'énergie pour alimenter une TV 3 heures',
      ],
      positifsEn: [
        'Recycling 1 kg of aluminium saves 8 kg CO₂ and avoids extracting 4 kg of bauxite',
        'Aluminium can be recycled infinitely without losing its mechanical properties',
        '1 tonne of recycled steel saves 1.1 t of iron ore and 630 kg of coal',
        'A recycled can saves enough energy to power a TV for 3 hours',
      ],
      positifsAr: [
        'إعادة تدوير 1 كجم من الألمنيوم يوفر 8 كجم CO₂ ويتجنب استخراج 4 كجم من البوكسيت',
        'يمكن إعادة تدوير الألمنيوم إلى ما لا نهاية دون فقدان خصائصه الميكانيكية',
        '1 طن من الفولاذ المعاد تدويره يوفر 1.1 طن من خام الحديد و630 كجم من الفحم',
        'علبة معاد تدويرها توفر طاقة كافية لتشغيل تلفزيون لمدة 3 ساعات',
      ],
      positifsEs: [
        'Reciclar 1 kg de aluminio ahorra 8 kg de CO₂ y evita extraer 4 kg de bauxita',
        'El aluminio se puede reciclar infinitamente sin perder sus propiedades mecánicas',
        '1 tonelada de acero reciclado ahorra 1,1 t de mineral de hierro y 630 kg de carbón',
        'Una lata reciclada ahorra suficiente energía para alimentar un televisor 3 horas',
      ],
      negatifs: [
        'L\'alu met 2 700 ans à se décomposer, libérant des oxydes métalliques toxiques',
        'La corrosion libère des ions qui contaminent les nappes phréatiques',
        'L\'extraction de bauxite détruit les écosystèmes forestiers tropicaux',
      ],
      negatifsEn: [
        'Aluminium takes 2,700 years to decompose, releasing toxic metal oxides',
        'Corrosion releases ions that contaminate groundwater',
        'Bauxite extraction destroys tropical forest ecosystems',
      ],
      negatifsAr: [
        'يستغرق الألمنيوم 2,700 سنة للتحلل، مطلقاً أكاسيد معدنية سامة',
        'يطلق التآكل أيونات تلوث المياه الجوفية',
        'يدمر استخراج البوكسيت النظم البيئية للغابات الاستوائية',
      ],
      negatifsEs: [
        'El aluminio tarda 2.700 años en descomponerse, liberando óxidos metálicos tóxicos',
        'La corrosión libera iones que contaminan las aguas subterráneas',
        'La extracción de bauxita destruye los ecosistemas forestales tropicales',
      ],
    ),
    _ImpactDetail(
      category: 'Verre', categoryEn: 'Glass', categoryAr: 'الزجاج', categoryEs: 'Vidrio',
      icon: Icons.local_bar_outlined, color: AppColors.glass,
      co2: '300 kg CO₂/tonne recyclée', co2En: '300 kg CO₂/tonne recycled', co2Ar: '300 كجم CO₂/طن معاد تدويره', co2Es: '300 kg CO₂/tonelada reciclada',
      energy: '26% énergie économisée',
      decomp: '4 000 ans', decompEn: '4,000 years', decompAr: '4,000 سنة', decompEs: '4.000 años',
      positifs: [
        'Recycler une tonne de verre économise 300 kg de CO₂ et 130 litres de pétrole',
        'Le verre recycle remplace 1,2 tonne de matières premières vierges',
        'Le verre est recyclable à l\'infini sans aucune perte de qualité ou de pureté',
        'Chaque bouteille recyclée économise assez d\'énergie pour éclairer une LED 4 heures',
      ],
      positifsEn: [
        'Recycling one tonne of glass saves 300 kg CO₂ and 130 litres of oil',
        'Recycled glass replaces 1.2 tonnes of virgin raw materials',
        'Glass is recyclable infinitely without any loss of quality or purity',
        'Each recycled bottle saves enough energy to light an LED for 4 hours',
      ],
      positifsAr: [
        'إعادة تدوير طن من الزجاج يوفر 300 كجم CO₂ و130 لتر بترول',
        'الزجاج المعاد تدويره يستبدل 1.2 طن من المواد الخام البكر',
        'الزجاج قابل للتدوير إلى ما لا نهاية دون فقدان الجودة أو النقاء',
        'كل زجاجة معاد تدويرها توفر طاقة كافية لإضاءة LED لمدة 4 ساعات',
      ],
      positifsEs: [
        'Reciclar una tonelada de vidrio ahorra 300 kg de CO₂ y 130 litros de petróleo',
        'El vidrio reciclado reemplaza 1,2 toneladas de materias primas vírgenes',
        'El vidrio es reciclable infinitamente sin pérdida de calidad o pureza',
        'Cada botella reciclada ahorra suficiente energía para iluminar un LED 4 horas',
      ],
      negatifs: [
        'Le verre met 4 000 ans à se désintégrer — le plus long de tous les matériaux courants',
        'Les éclats blessent la faune et s\'infiltrent dans la chaîne alimentaire marine',
        'L\'extraction de sable siliceux pour production neuve détruit les plages',
      ],
      negatifsEn: [
        'Glass takes 4,000 years to disintegrate — the longest of all common materials',
        'Shards injure wildlife and infiltrate the marine food chain',
        'Extraction of silica sand for new production destroys beaches',
      ],
      negatifsAr: [
        'يستغرق الزجاج 4,000 سنة للتفتت — الأطول بين جميع المواد الشائعة',
        'الشظايا تجرح الحياة البرية وتتسلل إلى السلسلة الغذائية البحرية',
        'استخراج الرمل الصواني للإنتاج الجديد يدمر الشواطئ',
      ],
      negatifsEs: [
        'El vidrio tarda 4.000 años en desintegrarse — el más duradero de todos los materiales comunes',
        'Los fragmentos hieren a la fauna y se infiltran en la cadena alimentaria marina',
        'La extracción de arena de sílice para nueva producción destruye las playas',
      ],
    ),
    _ImpactDetail(
      category: 'Plastique PET & Emballages', categoryEn: 'PET Plastic & Packaging', categoryAr: 'البلاستيك PET والتغليف', categoryEs: 'Plástico PET y Envases',
      icon: Icons.opacity_rounded, color: AppColors.plastic,
      co2: '1,5 kg CO₂/kg recyclé', co2En: '1.5 kg CO₂/kg recycled', co2Ar: '1.5 كجم CO₂/كجم معاد تدويره', co2Es: '1,5 kg CO₂/kg reciclado',
      energy: '76% énergie économisée',
      decomp: '500 ans', decompEn: '500 years', decompAr: '500 سنة', decompEs: '500 años',
      positifs: [
        'Recycler 1 kg de PET économise 1,5 kg CO₂ et 17 litres d\'eau',
        '1 bouteille PET recyclée = matière première pour 2 t-shirts en polyester recyclé',
        'Le HDPE recyclé (bidons, flacons) économise 1,8 kg CO₂ par kg traité',
        'Le polypropylène recyclé réduit de 73% les émissions vs production vierge',
      ],
      positifsEn: [
        'Recycling 1 kg of PET saves 1.5 kg CO₂ and 17 litres of water',
        '1 recycled PET bottle = raw material for 2 recycled polyester t-shirts',
        'Recycled HDPE (jugs, bottles) saves 1.8 kg CO₂ per kg processed',
        'Recycled polypropylene reduces emissions by 73% vs virgin production',
      ],
      positifsAr: [
        'إعادة تدوير 1 كجم من PET يوفر 1.5 كجم CO₂ و17 لتر ماء',
        'زجاجة PET معاد تدويرها = مادة خام لقميصين من البوليستر المعاد تدويره',
        'HDPE المعاد تدويره يوفر 1.8 كجم CO₂ لكل كجم معالج',
        'البولي بروبيلين المعاد تدويره يقلل الانبعاثات بنسبة 73٪ مقارنة بالإنتاج البكر',
      ],
      positifsEs: [
        'Reciclar 1 kg de PET ahorra 1,5 kg de CO₂ y 17 litros de agua',
        '1 botella PET reciclada = materia prima para 2 camisetas de poliéster reciclado',
        'El HDPE reciclado (garrafas, botellas) ahorra 1,8 kg CO₂ por kg procesado',
        'El polipropileno reciclado reduce las emisiones un 73% frente a la producción virgen',
      ],
      negatifs: [
        'Le PET met 500 ans à se dégrader, se fragmentant en microplastiques invisibles',
        'Les microplastiques ont été retrouvés dans le sang humain, les poumons et le placenta',
        'En Méditerranée (côte marocaine), le plastique est la 1ère pollution marine observée',
      ],
      negatifsEn: [
        'PET takes 500 years to degrade, fragmenting into invisible microplastics',
        'Microplastics have been found in human blood, lungs and placenta',
        'In the Mediterranean (Moroccan coast), plastic is the #1 marine pollution observed',
      ],
      negatifsAr: [
        'PET يستغرق 500 سنة للتحلل، متفتتاً إلى جسيمات دقيقة غير مرئية',
        'تم العثور على الجسيمات الدقيقة في الدم البشري والرئتين والمشيمة',
        'في البحر الأبيض المتوسط (الساحل المغربي)، البلاستيك هو التلوث البحري رقم 1',
      ],
      negatifsEs: [
        'El PET tarda 500 años en degradarse, fragmentándose en microplásticos invisibles',
        'Los microplásticos se han encontrado en sangre humana, pulmones y placenta',
        'En el Mediterráneo (costa marroquí), el plástico es la 1ª contaminación marina observada',
      ],
    ),
    _ImpactDetail(
      category: 'Papier & Carton', categoryEn: 'Paper & Cardboard', categoryAr: 'الورق والكرتون', categoryEs: 'Papel y Cartón',
      icon: Icons.article_outlined, color: AppColors.paper,
      co2: '900 kg CO₂/tonne évités', co2En: '900 kg CO₂/tonne avoided', co2Ar: '900 كجم CO₂/طن مُتجنَّب', co2Es: '900 kg CO₂/tonelada evitada',
      energy: '60% énergie économisée',
      decomp: '3–6 mois', decompEn: '3–6 months', decompAr: '3-6 أشهر', decompEs: '3-6 meses',
      positifs: [
        'Recycler une tonne de papier sauve 17 arbres et économise 7 000 litres d\'eau',
        'Le papier journal peut être recyclé jusqu\'à 7 fois avant que les fibres soient trop courtes',
        '1 tonne de carton ondulé recyclé économise 900 kg de CO₂ équivalent',
        'Le recyclage du papier réduit les déchets en décharge et la production de méthane',
      ],
      positifsEn: [
        'Recycling one tonne of paper saves 17 trees and 7,000 litres of water',
        'Newspaper can be recycled up to 7 times before fibres are too short',
        '1 tonne of recycled corrugated cardboard saves 900 kg CO₂ equivalent',
        'Paper recycling reduces landfill waste and methane production',
      ],
      positifsAr: [
        'إعادة تدوير طن من الورق ينقذ 17 شجرة ويوفر 7,000 لتر ماء',
        'يمكن إعادة تدوير صحيفة الجريدة حتى 7 مرات قبل أن تصبح الألياف قصيرة جداً',
        'طن من الكرتون المموج المعاد تدويره يوفر 900 كجم CO₂ مكافئ',
        'إعادة تدوير الورق تقلل من نفايات المطارح وإنتاج الميثان',
      ],
      positifsEs: [
        'Reciclar una tonelada de papel salva 17 árboles y ahorra 7.000 litros de agua',
        'El papel de periódico puede reciclarse hasta 7 veces antes de que las fibras sean demasiado cortas',
        '1 tonelada de cartón ondulado reciclado ahorra 900 kg de CO₂ equivalente',
        'El reciclaje de papel reduce los residuos en vertedero y la producción de metano',
      ],
      negatifs: [
        'Bien que biodégradable (3-6 mois), le papier enfoui produit du méthane (GES x25 vs CO₂)',
        'La production de papier vierge est l\'une des industries les plus gourmandes en eau douce',
        'Les encres et vernis sur certains papiers contaminent les sols lors de la décomposition',
      ],
      negatifsEn: [
        'Although biodegradable (3-6 months), buried paper produces methane (GHG x25 vs CO₂)',
        'Virgin paper production is one of the most freshwater-intensive industries',
        'Inks and varnishes on some papers contaminate soils during decomposition',
      ],
      negatifsAr: [
        'رغم قابليته للتحلل (3-6 أشهر)، الورق المدفون ينتج ميثاناً (غاز اصطباح x25 مقارنة بـCO₂)',
        'إنتاج الورق البكر من أكثر الصناعات استهلاكاً للمياه العذبة',
        'الأحبار والورنيشات على بعض الأوراق تلوث التربة أثناء التحلل',
      ],
      negatifsEs: [
        'Aunque biodegradable (3-6 meses), el papel enterrado produce metano (GEI x25 vs CO₂)',
        'La producción de papel virgen es una de las industrias más intensivas en agua dulce',
        'Las tintas y barnices de algunos papeles contaminan los suelos durante la descomposición',
      ],
    ),
    _ImpactDetail(
      category: 'Déchets Organiques', categoryEn: 'Organic Waste', categoryAr: 'النفايات العضوية', categoryEs: 'Residuos Orgánicos',
      icon: Icons.compost_rounded, color: Color(0xFF795548),
      co2: '-50% CH₄ en décharge', co2En: '-50% CH₄ in landfill', co2Ar: '-50٪ CH₄ في المطرح', co2Es: '-50% CH₄ en vertedero',
      energy: 'Biogaz utilisable',
      decomp: '2–6 mois', decompEn: '2–6 months', decompAr: '2-6 أشهر', decompEs: '2-6 meses',
      positifs: [
        '65% des ordures ménagères marocaines sont organiques — le gisement le plus important',
        '1 tonne de déchets organiques compostés produit 300 kg de compost prêt à l\'emploi',
        'La méthanisation produit du biogaz utilisable comme énergie propre',
        'Composter réduit de 50% les émissions de méthane qui se produiraient en décharge',
      ],
      positifsEn: [
        '65% of Moroccan household waste is organic — the largest resource',
        '1 tonne of composted organic waste produces 300 kg of ready-to-use compost',
        'Methanisation produces biogas usable as clean energy',
        'Composting reduces methane emissions by 50% vs landfill',
      ],
      positifsAr: [
        '65٪ من النفايات المنزلية المغربية عضوية — أكبر مورد',
        'طن من النفايات العضوية المُسمَّدة ينتج 300 كجم من السماد جاهز للاستخدام',
        'التخمير الحيوي ينتج غازاً حيوياً قابلاً للاستخدام كطاقة نظيفة',
        'التسميد يقلل انبعاثات الميثان بنسبة 50٪ مقارنة بالمطرح',
      ],
      positifsEs: [
        'El 65% de los residuos domésticos marroquíes son orgánicos — el mayor recurso',
        '1 tonelada de residuos orgánicos compostados produce 300 kg de compost listo para usar',
        'La metanización produce biogás utilizable como energía limpia',
        'Compostar reduce un 50% las emisiones de metano vs vertedero',
      ],
      negatifs: [
        'En décharge, les biodéchets fermentent en anaérobie et produisent du méthane (GES 25x CO₂)',
        'Les lixiviats (jus de putréfaction) contaminent les nappes phréatiques marocaines',
        'En été au Maroc, la chaleur accélère la putréfaction et dégrade la qualité de l\'air',
      ],
      negatifsEn: [
        'In landfill, organic waste ferments anaerobically producing methane (GHG 25x CO₂)',
        'Leachate (putrefaction juice) contaminates Moroccan groundwater',
        'In summer in Morocco, heat accelerates putrefaction and degrades air quality',
      ],
      negatifsAr: [
        'في المطرح، تتخمر المخلفات العضوية لاهوائياً منتجةً الميثان (غاز 25 ضعف CO₂)',
        'العصارة (عصير التعفن) تلوث المياه الجوفية المغربية',
        'في الصيف بالمغرب، الحرارة تسرع التعفن وتدهور جودة الهواء',
      ],
      negatifsEs: [
        'En vertedero, los residuos orgánicos fermentan anaeróbicamente produciendo metano (GEI 25x CO₂)',
        'Los lixiviados (jugo de putrefacción) contaminan los acuíferos marroquíes',
        'En verano en Marruecos, el calor acelera la putrefacción y degrada la calidad del aire',
      ],
    ),
    _ImpactDetail(
      category: 'Déchets Électroniques (DEEE)', categoryEn: 'Electronic Waste (WEEE)', categoryAr: 'النفايات الإلكترونية (DEEE)', categoryEs: 'Residuos Electrónicos (RAEE)',
      icon: Icons.electrical_services_rounded, color: AppColors.electronics,
      co2: '70 kg CO₂/ordinateur recyclé', co2En: '70 kg CO₂/computer recycled', co2Ar: '70 كجم CO₂/حاسوب معاد تدويره', co2Es: '70 kg CO₂/ordenador reciclado',
      energy: 'Or, Cuivre, Lithium, Cobalt récupérés',
      decomp: '> 1 000 ans', decompEn: '> 1,000 years', decompAr: '> 1,000 سنة', decompEs: '> 1.000 años',
      positifs: [
        'Recycler un ordinateur économise 70 kg CO₂ et récupère cuivre, or, argent et palladium',
        '1 tonne de téléphones contient 250 g d\'or — 80x plus riche qu\'une mine d\'or',
        'Le recyclage du lithium réduit la dépendance aux mines d\'Amérique du Sud',
        'Le Maroc génère ~100 000 tonnes de DEEE/an — un gisement de métaux précieux',
      ],
      positifsEn: [
        'Recycling a computer saves 70 kg CO₂ and recovers copper, gold, silver and palladium',
        '1 tonne of phones contains 250 g of gold — 80x richer than a gold mine',
        'Lithium recycling reduces dependence on South American mines',
        'Morocco generates ~100,000 tonnes of WEEE/year — a precious metal resource',
      ],
      positifsAr: [
        'إعادة تدوير حاسوب يوفر 70 كجم CO₂ ويسترد النحاس والذهب والفضة والبلاديوم',
        'طن من الهواتف يحتوي 250 جرام من الذهب — أغنى 80 مرة من منجم ذهب',
        'إعادة تدوير الليثيوم يقلل الاعتماد على مناجم أمريكا الجنوبية',
        'المغرب ينتج ~100,000 طن من DEEE/سنة — مورد للمعادن الثمينة',
      ],
      positifsEs: [
        'Reciclar un ordenador ahorra 70 kg de CO₂ y recupera cobre, oro, plata y paladio',
        '1 tonelada de teléfonos contiene 250 g de oro — 80x más rico que una mina de oro',
        'El reciclaje del litio reduce la dependencia de las minas de América del Sur',
        'Marruecos genera ~100.000 toneladas de RAEE/año — un recurso de metales preciosos',
      ],
      negatifs: [
        'Les batteries contiennent du plomb, cadmium et mercure qui s\'infiltrent dans les sols',
        'Le plomb des écrans CRT cause des maladies neurologiques graves, surtout chez les enfants',
        'Les DEEE brûlés informellement dégagent des dioxines et furanes — cancérigènes avérés',
      ],
      negatifsEn: [
        'Batteries contain lead, cadmium and mercury that seep into soils',
        'Lead from CRT screens causes serious neurological diseases, especially in children',
        'Informally burned WEEE releases dioxins and furans — proven carcinogens',
      ],
      negatifsAr: [
        'البطاريات تحتوي رصاصاً وكادميوماً وزئبقاً تتسرب إلى التربة',
        'رصاص شاشات CRT يسبب أمراضاً عصبية خطيرة خاصة لدى الأطفال',
        'DEEE المحروق بشكل غير رسمي يطلق ديوكسينات وفورانات — مسرطنات مؤكدة',
      ],
      negatifsEs: [
        'Las baterías contienen plomo, cadmio y mercurio que se filtran en los suelos',
        'El plomo de las pantallas CRT causa enfermedades neurológicas graves, especialmente en niños',
        'Los RAEE quemados informalmente emiten dioxinas y furanos — cancerígenos probados',
      ],
    ),
    _ImpactDetail(
      category: 'Textiles', categoryEn: 'Textiles', categoryAr: 'المنسوجات', categoryEs: 'Textiles',
      icon: Icons.checkroom_rounded, color: Color(0xFF9B59B6),
      co2: '5,5 kg CO₂/kg recyclé', co2En: '5.5 kg CO₂/kg recycled', co2Ar: '5.5 كجم CO₂/كجم معاد تدويره', co2Es: '5,5 kg CO₂/kg reciclado',
      energy: '3 200 L eau économisés/kg coton',
      decomp: '200 ans (synthétiques)', decompEn: '200 years (synthetics)', decompAr: '200 سنة (اصطناعية)', decompEs: '200 años (sintéticos)',
      positifs: [
        'Recycler 1 kg de coton économise 3 200 litres d\'eau — ressource précieuse au Maroc',
        'Des vêtements en bon état donnés prolongent leur cycle de vie de 2 à 9 ans',
        '1 jean recyclé nécessite 7x moins d\'eau qu\'un jean en coton vierge',
        'Le secteur textile marocain (leader export) peut intégrer des fibres recyclées',
      ],
      positifsEn: [
        'Recycling 1 kg of cotton saves 3,200 litres of water — a precious resource in Morocco',
        'Good condition donated clothes extend their life cycle by 2 to 9 years',
        '1 recycled pair of jeans requires 7x less water than virgin cotton jeans',
        'The Moroccan textile sector (export leader) can integrate recycled fibres',
      ],
      positifsAr: [
        'إعادة تدوير 1 كجم من القطن يوفر 3,200 لتر ماء — مورد ثمين بالمغرب',
        'الملابس الموهوبة في حالة جيدة تطيل دورة حياتها من 2 إلى 9 سنوات',
        'جينز معاد تدويره يحتاج 7 مرات ماء أقل من جينز قطن بكر',
        'القطاع النسيجي المغربي (رائد التصدير) يمكنه إدماج ألياف معاد تدويرها',
      ],
      positifsEs: [
        'Reciclar 1 kg de algodón ahorra 3.200 litros de agua — recurso precioso en Marruecos',
        'La ropa en buen estado donada prolonga su ciclo de vida de 2 a 9 años',
        '1 vaquero reciclado necesita 7x menos agua que unos vaqueros de algodón virgen',
        'El sector textil marroquí (líder exportador) puede integrar fibras recicladas',
      ],
      negatifs: [
        'Les textiles synthétiques (polyester, nylon) mettent 200 ans à se décomposer',
        'Chaque lavage libère 700 000 microfibres plastiques dans les eaux usées',
        'Les teintures non traitées contaminent les cours d\'eau (visible dans certains oueds)',
      ],
      negatifsEn: [
        'Synthetic textiles (polyester, nylon) take 200 years to decompose',
        'Each wash releases 700,000 plastic microfibres into wastewater',
        'Untreated dyes contaminate waterways (visible in some oueds)',
      ],
      negatifsAr: [
        'المنسوجات الاصطناعية (بوليستر، نايلون) تستغرق 200 سنة للتحلل',
        'كل غسيل يطلق 700,000 ألياف دقيقة بلاستيكية في مياه الصرف',
        'الأصباغ غير المعالجة تلوث مجاري المياه (مرئي في بعض الأودية)',
      ],
      negatifsEs: [
        'Los textiles sintéticos (poliéster, nylon) tardan 200 años en descomponerse',
        'Cada lavado libera 700.000 microfibras plásticas en las aguas residuales',
        'Los tintes no tratados contaminan los cursos de agua (visible en algunos ueds)',
      ],
    ),
    _ImpactDetail(
      category: 'Déchets Dangereux', categoryEn: 'Hazardous Waste', categoryAr: 'النفايات الخطرة', categoryEs: 'Residuos Peligrosos',
      icon: Icons.warning_amber_rounded, color: Color(0xFFE74C3C),
      co2: '1 pile = 1 m² sol pollué 50 ans', co2En: '1 battery = 1 m² soil polluted 50 yrs', co2Ar: '1 بطارية = 1 م² تربة ملوثة 50 سنة', co2Es: '1 pila = 1 m² suelo contaminado 50 años',
      energy: '1 L huile = 1 million L eau polluée',
      decomp: 'Permanent sans traitement', decompEn: 'Permanent without treatment', decompAr: 'دائم بدون معالجة', decompEs: 'Permanente sin tratamiento',
      positifs: [
        'Un traitement approprié évite la contamination permanente des sols et nappes',
        'Les métaux des piles et batteries (plomb, cadmium) sont récupérables et valorisables',
        'Les huiles usagées traitées produisent un combustible alternatif pour l\'industrie',
      ],
      positifsEn: [
        'Proper treatment prevents permanent contamination of soils and groundwater',
        'Metals from batteries (lead, cadmium) can be recovered and valorised',
        'Treated used oils produce an alternative fuel for industry',
      ],
      positifsAr: [
        'المعالجة المناسبة تمنع التلوث الدائم للتربة والمياه الجوفية',
        'يمكن استرداد وتثمين المعادن من البطاريات (رصاص، كادميوم)',
        'الزيوت المستعملة المعالجة تنتج وقوداً بديلاً للصناعة',
      ],
      positifsEs: [
        'El tratamiento adecuado evita la contaminación permanente de suelos y acuíferos',
        'Los metales de las baterías (plomo, cadmio) pueden recuperarse y valorizarse',
        'Los aceites usados tratados producen un combustible alternativo para la industria',
      ],
      negatifs: [
        'Une pile jetée en décharge pollue 1 m² de sol pendant 50 ans avec mercure et cadmium',
        'Les produits chimiques enfouis migrent vers les nappes phréatiques en quelques années',
        'L\'incinération sauvage de déchets dangereux libère des dioxines cancérigènes dans l\'air',
      ],
      negatifsEn: [
        'A battery thrown in landfill pollutes 1 m² of soil for 50 years with mercury and cadmium',
        'Buried chemicals migrate to groundwater within a few years',
        'Informal burning of hazardous waste releases cancerogenic dioxins into the air',
      ],
      negatifsAr: [
        'بطارية ملقاة في مطرح تلوث 1 م² من التربة لمدة 50 سنة بالزئبق والكادميوم',
        'المواد الكيميائية المدفونة تهاجر نحو المياه الجوفية خلال سنوات قليلة',
        'الحرق غير الرسمي للنفايات الخطرة يطلق ديوكسينات مسرطنة في الهواء',
      ],
      negatifsEs: [
        'Una pila arrojada en vertedero contamina 1 m² de suelo durante 50 años con mercurio y cadmio',
        'Los productos químicos enterrados migran hacia los acuíferos en pocos años',
        'La quema informal de residuos peligrosos libera dioxinas cancerígenas al aire',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
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
                lang: lang,
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
                        child: Text(d.categoryFor(lang),
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
                      _StatChip(label: d.co2For(lang), icon: Icons.co2_rounded, color: d.color),
                      const SizedBox(width: 6),
                      _StatChip(label: d.decompFor(lang), icon: Icons.hourglass_bottom_rounded, color: Colors.orange),
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
                      ...d.positifsFor(lang).map((p) => Padding(
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
                      ...d.negatifsFor(lang).map((n) => Padding(
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
      _RegionalOp('LYDEC', 'Gestion déchets + signalement pollutions', '0801 00 48 48', 'Casablanca',
          specialtyEn: 'Waste management + pollution reporting',
          specialtyAr: 'تدبير النفايات + الإبلاغ عن التلوث',
          specialtyEs: 'Gestión de residuos + denuncia de contaminación'),
      _RegionalOp('Mairie de Casablanca', 'Éco-points, collecte municipale, centres de tri', '0522 27 81 00', 'Casablanca',
          specialtyEn: 'Eco-points, municipal collection, sorting centres',
          specialtyAr: 'نقاط بيئية، جمع بلدي، مراكز الفرز',
          specialtyEs: 'Eco-puntos, recogida municipal, centros de clasificación'),
      _RegionalOp('ECOVALOR — Aïn Sebaâ', 'Tri & valorisation plastique/métal/papier', '0522 35 66 00', 'Aïn Sebaâ',
          specialtyEn: 'Sorting & recovery of plastic/metal/paper',
          specialtyAr: 'فرز وتثمين البلاستيك/المعادن/الورق',
          specialtyEs: 'Clasificación y valorización de plástico/metal/papel'),
      _RegionalOp('TECMED — Mohammedia', 'Collecte DEEE (ordi, téléphones, TV)', '0523 32 00 00', 'Mohammedia',
          specialtyEn: 'WEEE collection (computers, phones, TV)',
          specialtyAr: 'جمع DEEE (حواسيب، هواتف، تلفزيون)',
          specialtyEs: 'Recogida RAEE (ordenadores, teléfonos, TV)'),
      _RegionalOp('Déchetterie Lissasfa', 'Tous déchets — tous types', '0522 91 02 03', 'Lissasfa',
          specialtyEn: 'All waste — all types',
          specialtyAr: 'جميع النفايات — جميع الأنواع',
          specialtyEs: 'Todos los residuos — todos los tipos'),
      _RegionalOp('H&M Collect', 'Bornes collecte textile', '0522 20 30 40', 'Casablanca Mall',
          specialtyEn: 'Textile collection bins',
          specialtyAr: 'صناديق جمع المنسوجات',
          specialtyEs: 'Puntos de recogida textil'),
    ]),
    _RegionData('Rabat-Salé-Kénitra', [
      _RegionalOp('Mairie de Rabat', 'Tri sélectif, éco-points Agdal & Hassan', '0537 76 36 36', 'Rabat',
          specialtyEn: 'Selective sorting, eco-points Agdal & Hassan',
          specialtyAr: 'فرز انتقائي، نقاط بيئية أكدال والحسن',
          specialtyEs: 'Clasificación selectiva, eco-puntos Agdal y Hassan'),
      _RegionalOp('AVERDA — Rabat', 'Collecte OM Rabat, Salé, Témara', '0537 71 10 10', 'Rabat',
          specialtyEn: 'Household waste collection Rabat, Salé, Témara',
          specialtyAr: 'جمع النفايات المنزلية بالرباط وسلا وتمارة',
          specialtyEs: 'Recogida RSU Rabat, Salé, Témara'),
      _RegionalOp('SITA Salé', 'Collecte & traitement déchets', '0537 85 22 33', 'Salé',
          specialtyEn: 'Waste collection & treatment',
          specialtyAr: 'جمع ومعالجة النفايات',
          specialtyEs: 'Recogida y tratamiento de residuos'),
      _RegionalOp('Centre Tri Témara', 'Tri sélectif plastique, papier, métal', '0537 74 55 66', 'Témara',
          specialtyEn: 'Selective sorting: plastic, paper, metal',
          specialtyAr: 'فرز انتقائي: بلاستيك، ورق، معادن',
          specialtyEs: 'Clasificación selectiva: plástico, papel, metal'),
      _RegionalOp('RADEEF / Kénitra', 'Gestion déchets Kénitra', '0537 37 10 10', 'Kénitra',
          specialtyEn: 'Waste management Kénitra',
          specialtyAr: 'تدبير النفايات بالقنيطرة',
          specialtyEs: 'Gestión de residuos Kénitra'),
    ]),
    _RegionData('Marrakech-Safi', [
      _RegionalOp('Mairie de Marrakech', 'Collecte OM, éco-points médina & Guéliz', '0524 44 94 95', 'Marrakech',
          specialtyEn: 'Household collection, eco-points medina & Guéliz',
          specialtyAr: 'جمع المنزلي، نقاط بيئية المدينة القديمة وكيليز',
          specialtyEs: 'Recogida doméstica, eco-puntos medina y Guéliz'),
      _RegionalOp('PIZZORNO Environnement', 'Collecte et traitement déchets', '0524 33 44 55', 'Marrakech',
          specialtyEn: 'Waste collection and treatment',
          specialtyAr: 'جمع ومعالجة النفايات',
          specialtyEs: 'Recogida y tratamiento de residuos'),
      _RegionalOp('Centre Tri Marrakech', 'Tri plastique, papier, métal, verre', '0524 30 20 10', 'Marrakech',
          specialtyEn: 'Sorting: plastic, paper, metal, glass',
          specialtyAr: 'فرز: بلاستيك، ورق، معادن، زجاج',
          specialtyEs: 'Clasificación: plástico, papel, metal, vidrio'),
      _RegionalOp('Déchetterie Rte Casablanca', 'Encombrants, DEEE, dangereux', '0524 31 00 00', 'Marrakech',
          specialtyEn: 'Bulky waste, WEEE, hazardous',
          specialtyAr: 'نفايات ضخمة، DEEE، خطرة',
          specialtyEs: 'Residuos voluminosos, RAEE, peligrosos'),
    ]),
    _RegionData('Tanger-Tétouan-Al Hoceïma', [
      _RegionalOp('Mairie de Tanger', 'Collecte OM, tri sélectif, éco-points', '0539 93 27 00', 'Tanger',
          specialtyEn: 'Household collection, selective sorting, eco-points',
          specialtyAr: 'جمع منزلي، فرز انتقائي، نقاط بيئية',
          specialtyEs: 'Recogida doméstica, clasificación selectiva, eco-puntos'),
      _RegionalOp('TECMED Nord', 'DEEE, électronique, batteries', '0539 33 44 55', 'Tanger',
          specialtyEn: 'WEEE, electronics, batteries',
          specialtyAr: 'DEEE، إلكترونيات، بطاريات',
          specialtyEs: 'RAEE, electrónica, baterías'),
      _RegionalOp('Centre Tri Tanger Med', 'Tri industriel zone portuaire', '0539 34 00 00', 'Tanger Med',
          specialtyEn: 'Industrial sorting — port zone',
          specialtyAr: 'فرز صناعي — منطقة الميناء',
          specialtyEs: 'Clasificación industrial — zona portuaria'),
      _RegionalOp('Mairie Tétouan', 'Collecte OM Tétouan, Martil', '0539 96 22 00', 'Tétouan',
          specialtyEn: 'Household collection Tétouan, Martil',
          specialtyAr: 'جمع منزلي تطوان ومارتيل',
          specialtyEs: 'Recogida doméstica Tetuán, Martil'),
      _RegionalOp('Déchetterie Ibn Batouta', 'Tous déchets — triage initial', '0539 31 22 33', 'Tanger',
          specialtyEn: 'All waste — initial sorting',
          specialtyAr: 'جميع النفايات — فرز أولي',
          specialtyEs: 'Todos los residuos — clasificación inicial'),
    ]),
    _RegionData('Fès-Meknès', [
      _RegionalOp('Mairie de Fès', 'Collecte OM, programme tri sélectif', '0535 62 47 00', 'Fès',
          specialtyEn: 'Household collection, selective sorting programme',
          specialtyAr: 'جمع منزلي، برنامج الفرز الانتقائي',
          specialtyEs: 'Recogida doméstica, programa de clasificación selectiva'),
      _RegionalOp('AMENSOUSS Meknès', 'Gestion déchets Meknès', '0535 52 20 30', 'Meknès',
          specialtyEn: 'Waste management Meknès',
          specialtyAr: 'تدبير النفايات بمكناس',
          specialtyEs: 'Gestión de residuos Meknès'),
      _RegionalOp('Centre Tri Sidi Brahim', 'Tri papier, plastique, métal', '0535 64 30 40', 'Fès',
          specialtyEn: 'Sorting: paper, plastic, metal',
          specialtyAr: 'فرز: ورق، بلاستيك، معادن',
          specialtyEs: 'Clasificación: papel, plástico, metal'),
      _RegionalOp('DEEE Point Collecte Meknès', 'Électronique, piles, batteries', '0535 51 30 40', 'Meknès',
          specialtyEn: 'Electronics, batteries, cells',
          specialtyAr: 'إلكترونيات، بطاريات، خلايا',
          specialtyEs: 'Electrónica, pilas, baterías'),
    ]),
    _RegionData('Souss-Massa (Agadir)', [
      _RegionalOp('Mairie d\'Agadir', 'Collecte OM, éco-points Agadir', '0528 84 36 36', 'Agadir',
          specialtyEn: 'Household collection, eco-points Agadir',
          specialtyAr: 'جمع منزلي، نقاط بيئية أكادير',
          specialtyEs: 'Recogida doméstica, eco-puntos Agadir'),
      _RegionalOp('SOUSS RECYCLAGE', 'Plastique, métal, papier — toute la région', '0528 83 12 34', 'Agadir',
          specialtyEn: 'Plastic, metal, paper — entire region',
          specialtyAr: 'بلاستيك، معادن، ورق — كامل الجهة',
          specialtyEs: 'Plástico, metal, papel — toda la región'),
      _RegionalOp('AMENSOUSS SA', 'Gestion déchets Agadir, Tiznit, Taroudant', '0528 82 30 40', 'Agadir',
          specialtyEn: 'Waste management Agadir, Tiznit, Taroudant',
          specialtyAr: 'تدبير النفايات أكادير وتيزنيت وتارودانت',
          specialtyEs: 'Gestión de residuos Agadir, Tiznit, Taroudant'),
      _RegionalOp('Déchetterie Aït Melloul', 'Encombrants, DEEE, dangereux', '0528 83 50 60', 'Aït Melloul',
          specialtyEn: 'Bulky waste, WEEE, hazardous',
          specialtyAr: 'نفايات ضخمة، DEEE، خطرة',
          specialtyEs: 'Residuos voluminosos, RAEE, peligrosos'),
    ]),
    _RegionData('Oriental (Oujda)', [
      _RegionalOp('Mairie d\'Oujda', 'Collecte OM, éco-points Oujda', '0536 68 24 00', 'Oujda',
          specialtyEn: 'Household collection, eco-points Oujda',
          specialtyAr: 'جمع منزلي، نقاط بيئية وجدة',
          specialtyEs: 'Recogida doméstica, eco-puntos Oujda'),
      _RegionalOp('RADEEO', 'Gestion déchets et eau Oujda', '0536 68 14 00', 'Oujda',
          specialtyEn: 'Waste and water management Oujda',
          specialtyAr: 'تدبير النفايات والماء بوجدة',
          specialtyEs: 'Gestión de residuos y agua Oujda'),
      _RegionalOp('Centre Tri Oujda', 'Tri plastique, métal, papier', '0536 68 30 40', 'Oujda',
          specialtyEn: 'Sorting: plastic, metal, paper',
          specialtyAr: 'فرز: بلاستيك، معادن، ورق',
          specialtyEs: 'Clasificación: plástico, metal, papel'),
      _RegionalOp('Nador Propreté', 'Collecte OM Nador, Zayo', '0536 33 22 33', 'Nador',
          specialtyEn: 'Household collection Nador, Zayo',
          specialtyAr: 'جمع منزلي الناظور وزايو',
          specialtyEs: 'Recogida doméstica Nador, Zayo'),
    ]),
    _RegionData('Béni Mellal-Khénifra', [
      _RegionalOp('Mairie de Béni Mellal', 'Collecte OM, éco-points', '0523 48 22 00', 'Béni Mellal',
          specialtyEn: 'Household collection, eco-points',
          specialtyAr: 'جمع منزلي، نقاط بيئية',
          specialtyEs: 'Recogida doméstica, eco-puntos'),
      _RegionalOp('Centre Tri Béni Mellal', 'Plastique, papier, métal', '0523 48 30 40', 'Béni Mellal',
          specialtyEn: 'Plastic, paper, metal',
          specialtyAr: 'بلاستيك، ورق، معادن',
          specialtyEs: 'Plástico, papel, metal'),
      _RegionalOp('RADEE Khénifra', 'Gestion déchets Khénifra', '0535 58 10 20', 'Khénifra',
          specialtyEn: 'Waste management Khénifra',
          specialtyAr: 'تدبير النفايات بخنيفرة',
          specialtyEs: 'Gestión de residuos Khénifra'),
    ]),
    _RegionData('Drâa-Tafilalet', [
      _RegionalOp('Mairie d\'Errachidia', 'Collecte OM, éco-points', '0535 57 22 00', 'Errachidia',
          specialtyEn: 'Household collection, eco-points',
          specialtyAr: 'جمع منزلي، نقاط بيئية',
          specialtyEs: 'Recogida doméstica, eco-puntos'),
      _RegionalOp('Mairie de Ouarzazate', 'Collecte OM, tri sélectif touristique', '0524 88 22 00', 'Ouarzazate',
          specialtyEn: 'Household collection, tourist selective sorting',
          specialtyAr: 'جمع منزلي، فرز انتقائي سياحي',
          specialtyEs: 'Recogida doméstica, clasificación selectiva turística'),
      _RegionalOp('ONEE — Signalement', 'Rejets illégaux, pollution eau', '0800 00 20 20', 'National',
          specialtyEn: 'Illegal discharges, water pollution',
          specialtyAr: 'الصرف غير القانوني، تلوث المياه',
          specialtyEs: 'Vertidos ilegales, contaminación del agua'),
    ]),
    _RegionData('Laâyoune & Dakhla', [
      _RegionalOp('Mairie de Laâyoune', 'Collecte OM, gestion municipale', '0528 89 22 00', 'Laâyoune',
          specialtyEn: 'Household collection, municipal management',
          specialtyAr: 'جمع منزلي، تدبير بلدي',
          specialtyEs: 'Recogida doméstica, gestión municipal'),
      _RegionalOp('Dakhla Propreté', 'Collecte OM Dakhla', '0528 93 22 33', 'Dakhla',
          specialtyEn: 'Household collection Dakhla',
          specialtyAr: 'جمع منزلي الداخلة',
          specialtyEs: 'Recogida doméstica Dakhla'),
      _RegionalOp('Association Sahara Vert', 'Collecte déchets zone saharienne', '0528 89 30 40', 'Laâyoune',
          specialtyEn: 'Waste collection in Saharan zone',
          specialtyAr: 'جمع النفايات في المنطقة الصحراوية',
          specialtyEs: 'Recogida de residuos en zona sahariana'),
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
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
          _OperatorCard(op: _ConsignesTab._operators[i], isDark: isDark, lang: lang)
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
              child: Text(s.guideRegDir,
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
                              Text(op.specialtyFor(lang),
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
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    return _DetailPageBase(
      title: s.guideGoldenRules,
      subtitle: s.guideGoldenRulesSubtitle,
      icon: Icons.star_rounded,
      headerColor: const Color(0xFF9B59B6),
      isDark: isDark,
      children: [
        ...List.generate(_ConsignesTab._rules.length, (i) {
          return _RuleCard(rule: _ConsignesTab._rules[i], isDark: isDark, lang: lang)
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
        'Numéro vert gratuit 24h/24. Signalement de tout rejet illégal, pollution eau ou sol sur le territoire national.',
        descEn: 'Free green number 24/7. Report any illegal discharge, water or soil pollution on national territory.',
        descAr: 'رقم أخضر مجاني 24/24. الإبلاغ عن أي صرف غير قانوني أو تلوث مائي أو أرضي على الأراضي الوطنية.',
        descEs: 'Número verde gratuito 24h/24. Denuncia cualquier vertido ilegal, contaminación del agua o del suelo en el territorio nacional.'),
    _ContactInfo('Protection Civile', '15',
        '', '',
        Icons.local_fire_department_rounded, Color(0xFFE74C3C),
        'Urgence absolue en cas de déversement chimique accidentel, incendie de décharge ou accident industriel.',
        descEn: 'Absolute emergency in case of accidental chemical spill, landfill fire or industrial accident.',
        descAr: 'طوارئ مطلقة في حالة تسرب كيميائي عرضي أو حريق مطرح أو حادث صناعي.',
        descEs: 'Emergencia absoluta en caso de derrame químico accidental, incendio en vertedero o accidente industrial.'),
    _ContactInfo('Marine Royale — Pollution Marine', '10911',
        '', '',
        Icons.sailing_rounded, Color(0xFF1A5276),
        'Signalement pollution marine sur les côtes marocaines. Disponible 24h/24. Priorité côtes atlantique et méditerranée.',
        descEn: 'Marine pollution reporting on Moroccan coasts. Available 24/7. Priority: Atlantic and Mediterranean coasts.',
        descAr: 'الإبلاغ عن التلوث البحري على السواحل المغربية. متوفر 24/24. الأولوية: السواحل الأطلسية والمتوسطية.',
        descEs: 'Denuncia de contaminación marina en las costas marroquíes. Disponible 24h/24. Prioridad: costas atlántica y mediterránea.'),
    // ── Institutions gouvernementales ─────────────────────────────────────────
    _ContactInfo('Ministère Transition Énergétique (MTEDD)', '0537 57 93 00',
        'info@environnement.gov.ma', 'www.environnement.gov.ma',
        Icons.account_balance_rounded, Color(0xFF27AE60),
        'Autorité de tutelle. Élabore la réglementation, délivre les agréments, contrôle les plans directeurs et inspecte les opérateurs.',
        descEn: 'Supervisory authority. Drafts regulations, issues approvals, controls masterplans and inspects operators.',
        descAr: 'سلطة الوصاية. تضع اللوائح، تمنح التراخيص، تراقب المخططات التوجيهية وتتفتش على المشغلين.',
        descEs: 'Autoridad de tutela. Elabora la normativa, concede licencias, controla los planes directores e inspecciona los operadores.'),
    _ContactInfo('AMEE — Agence Marocaine Efficacité Énergétique', '0537 57 25 00',
        '', 'www.amee.ma',
        Icons.energy_savings_leaf_rounded, Color(0xFF2ECC71),
        'Pilote les programmes d\'économie circulaire, valorisation déchets industriels et programme AMEP plastiques.',
        descEn: 'Leads circular economy programmes, industrial waste recovery and AMEP plastics programme.',
        descAr: 'تقود برامج الاقتصاد الدائري وتثمين النفايات الصناعية وبرنامج AMEP للبلاستيك.',
        descEs: 'Lidera los programas de economía circular, valorización de residuos industriales y programa AMEP de plásticos.'),
    _ContactInfo('Wilaya de Casablanca', '0522 22 36 36',
        '', '',
        Icons.location_city_rounded, Color(0xFF2C3E50),
        'Urgences environnement Casablanca. Signalement pollutions, décharges sauvages et déversements chimiques dans la région.',
        descEn: 'Environmental emergencies in Casablanca. Report pollution, illegal dumps and chemical spills in the region.',
        descAr: 'طوارئ البيئة بالدار البيضاء. الإبلاغ عن التلوث والمطارح العشوائية والتسريبات الكيميائية في الجهة.',
        descEs: 'Emergencias medioambientales en Casablanca. Denuncia contaminación, vertederos ilegales y derrames químicos en la región.'),
    _ContactInfo('Wilaya de Rabat', '0537 72 72 72',
        '', '',
        Icons.location_city_rounded, Color(0xFF34495E),
        'Urgences environnement Rabat. Signalement pollutions, décharges sauvages et déversements chimiques dans la région.',
        descEn: 'Environmental emergencies in Rabat. Report pollution, illegal dumps and chemical spills in the region.',
        descAr: 'طوارئ البيئة بالرباط. الإبلاغ عن التلوث والمطارح العشوائية والتسريبات الكيميائية في الجهة.',
        descEs: 'Emergencias medioambientales en Rabat. Denuncia contaminación, vertederos ilegales y derrames químicos en la región.'),
    // ── ONGs nationales ────────────────────────────────────────────────────────
    _ContactInfo('Association Zéro Zbel', '',
        'contact@zerozabel.ma', 'www.zerozabel.ma',
        Icons.volunteer_activism_rounded, Color(0xFF7D6608),
        'ONG pionnière du tri sélectif au Maroc. Sensibilisation dans les écoles, entreprises et communes. Programmes de compostage.',
        descEn: 'Pioneer NGO for selective sorting in Morocco. Awareness in schools, companies and municipalities. Composting programmes.',
        descAr: 'منظمة غير حكومية رائدة في الفرز الانتقائي بالمغرب. توعية في المدارس والشركات والبلديات. برامج التسميد.',
        descEs: 'ONG pionera en clasificación selectiva en Marruecos. Sensibilización en escuelas, empresas y municipios. Programas de compostaje.'),
    _ContactInfo('Green Morocco', '0522 55 11 22',
        '', '',
        Icons.park_rounded, Color(0xFF1E8449),
        'Plages propres, nettoyages collectifs. Projets de sensibilisation au recyclage communautaire à l\'échelle nationale.',
        descEn: 'Clean beaches, collective cleanups. Recycling awareness projects at national community level.',
        descAr: 'شواطئ نظيفة وحملات تنظيف جماعية. مشاريع التوعية بإعادة التدوير المجتمعية على المستوى الوطني.',
        descEs: 'Playas limpias, limpiezas colectivas. Proyectos de sensibilización sobre reciclaje comunitario a escala nacional.'),
    _ContactInfo('Plastic Free Morocco', '',
        'plasticfreemo@gmail.com', '',
        Icons.do_not_disturb_on_rounded, Color(0xFF8E44AD),
        'Réduction plastique à usage unique. Sensibilisation et lobbying pour l\'application stricte de la Loi 77-15.',
        descEn: 'Single-use plastic reduction. Awareness and lobbying for strict enforcement of Law 77-15.',
        descAr: 'تقليص البلاستيك أحادي الاستخدام. توعية وضغط من أجل التطبيق الصارم للقانون 77-15.',
        descEs: 'Reducción del plástico de un solo uso. Sensibilización y presión para la aplicación estricta de la Ley 77-15.'),
    _ContactInfo('GreenWish Maroc', '0522 44 55 66',
        '', '',
        Icons.eco_rounded, Color(0xFF16A085),
        'Projets recyclage communautaires. Financement de micro-projets de tri et compostage dans les quartiers.',
        descEn: 'Community recycling projects. Funding for micro-projects for sorting and composting in neighbourhoods.',
        descAr: 'مشاريع إعادة التدوير المجتمعية. تمويل مشاريع صغيرة للفرز والتسميد في الأحياء.',
        descEs: 'Proyectos de reciclaje comunitarios. Financiación de microproyectos de clasificación y compostaje en los barrios.'),
    _ContactInfo('Caritas Maroc', '0522 29 11 22',
        '', '',
        Icons.favorite_rounded, Color(0xFFE74C3C),
        'Collecte et redistribution de vêtements, objets usagés. Points de dépôt à Casablanca, Rabat, Tanger, Marrakech.',
        descEn: 'Collection and redistribution of clothing and used items. Drop-off points in Casablanca, Rabat, Tangier, Marrakech.',
        descAr: 'جمع وإعادة توزيع الملابس والمواد المستعملة. نقاط إيداع في الدار البيضاء والرباط وطنجة ومراكش.',
        descEs: 'Recogida y redistribución de ropa y objetos usados. Puntos de entrega en Casablanca, Rabat, Tánger, Marrakech.'),
    _ContactInfo('Secours Catholique', '0537 73 44 55',
        '', '',
        Icons.volunteer_activism_rounded, Color(0xFFE67E22),
        'Don de vêtements et objets usagés. Redistribution aux personnes dans le besoin. Base : Rabat.',
        descEn: 'Donation of clothing and used items. Redistribution to people in need. Base: Rabat.',
        descAr: 'تبرع بالملابس والمواد المستعملة. إعادة توزيعها على المحتاجين. المقر: الرباط.',
        descEs: 'Donación de ropa y objetos usados. Redistribución a personas necesitadas. Base: Rabat.'),
    // ── Régies et opérateurs ─────────────────────────────────────────────────
    _ContactInfo('ECOVALOR', '0522 35 66 00',
        '', '',
        Icons.recycling_rounded, Color(0xFF27AE60),
        'Tri et valorisation plastique/métal/papier. Usine Aïn Sebaâ, Casablanca. Principal opérateur national de recyclage matériaux.',
        descEn: 'Plastic/metal/paper sorting and recovery. Aïn Sebaâ plant, Casablanca. Main national materials recycling operator.',
        descAr: 'فرز وتثمين البلاستيك والمعادن والورق. مصنع عين السبع، الدار البيضاء. المشغل الوطني الرئيسي لإعادة تدوير المواد.',
        descEs: 'Clasificación y valorización de plástico/metal/papel. Planta Aïn Sebaâ, Casablanca. Principal operador nacional de reciclaje de materiales.'),
    _ContactInfo('AVERDA Maroc', '0537 71 10 10',
        '', '',
        Icons.local_shipping_rounded, Color(0xFF2980B9),
        'Opérateur collecte OM dans plusieurs villes. Siège : Rabat. Gestion déléguée des déchets ménagers à l\'échelle nationale.',
        descEn: 'Household waste collection operator in several cities. HQ: Rabat. Delegated management of household waste at national scale.',
        descAr: 'مشغل جمع النفايات المنزلية في عدة مدن. المقر: الرباط. تدبير مفوض للنفايات المنزلية على الصعيد الوطني.',
        descEs: 'Operador de recogida de RSU en varias ciudades. Sede: Rabat. Gestión delegada de residuos domésticos a escala nacional.'),
    _ContactInfo('TECMED', '0523 32 00 00',
        '', '',
        Icons.electrical_services_rounded, Color(0xFFF39C12),
        'Collecte et traitement DEEE. Sites à Mohammedia et Tanger Nord. Agréé Ministère Transition Énergétique.',
        descEn: 'WEEE collection and treatment. Sites in Mohammedia and Tangier North. Approved by Ministry of Energy Transition.',
        descAr: 'جمع ومعالجة DEEE. مواقع في المحمدية وطنجة الشمالية. معتمد من وزارة الانتقال الطاقي.',
        descEs: 'Recogida y tratamiento de RAEE. Instalaciones en Mohammedia y Tánger Norte. Autorizado por el Ministerio de Transición Energética.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
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
                    Text(c.descFor(lang),
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
  final String descEn, descAr, descEs;
  const _ContactInfo(this.name, this.phone, this.email, this.website,
      this.icon, this.color, this.desc, {
    this.descEn = '', this.descAr = '', this.descEs = '',
  });
  String descFor(String lang) {
    if (lang == 'ar' && descAr.isNotEmpty) return descAr;
    if (lang == 'es' && descEs.isNotEmpty) return descEs;
    if (lang != 'fr' && descEn.isNotEmpty) return descEn;
    return desc;
  }
}
