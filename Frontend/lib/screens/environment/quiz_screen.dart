import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';

class _Question {
  final String fr, en, ar, es;
  final List<String> optionsFr, optionsEn, optionsAr, optionsEs;
  final int correct;
  final String explanationFr, explanationEn, explanationAr, explanationEs;

  const _Question({
    required this.fr, required this.en, required this.ar, required this.es,
    required this.optionsFr, required this.optionsEn, required this.optionsAr, required this.optionsEs,
    required this.correct,
    required this.explanationFr, required this.explanationEn,
    required this.explanationAr, required this.explanationEs,
  });
}

const _questions = [

  // ── 1 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Dans quel bac jette-t-on les bouteilles en plastique au Maroc ?',
    en: 'Which bin should plastic bottles go in Morocco?',
    ar: 'في أي حاوية تُرمى زجاجات البلاستيك في المغرب؟',
    es: '¿En qué contenedor van las botellas de plástico en Marruecos?',
    optionsFr: ['Bac noir', 'Bac jaune ECOVAL', 'Colonne verte', 'Bac marron'],
    optionsEn: ['Black bin', 'Yellow ECOVAL bin', 'Green column', 'Brown bin'],
    optionsAr: ['الحاوية السوداء', 'الحاوية الصفراء ECOVAL', 'العمود الأخضر', 'الحاوية البنية'],
    optionsEs: ['Contenedor negro', 'Contenedor amarillo ECOVAL', 'Columna verde', 'Contenedor marrón'],
    correct: 1,
    explanationFr: 'Les bouteilles PET vont dans le bac jaune ECOVAL pour être recyclées.',
    explanationEn: 'PET bottles go in the yellow ECOVAL bin to be recycled.',
    explanationAr: 'تذهب زجاجات PET إلى الحاوية الصفراء ECOVAL لإعادة تدويرها.',
    explanationEs: 'Las botellas PET van en el contenedor amarillo ECOVAL para ser recicladas.',
  ),

  // ── 2 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Combien de temps met une bouteille en verre à se décomposer ?',
    en: 'How long does a glass bottle take to decompose?',
    ar: 'كم يستغرق تحلل زجاجة الزجاج؟',
    es: '¿Cuánto tarda en descomponerse una botella de vidrio?',
    optionsFr: ['100 ans', '500 ans', '4 000 ans', '10 ans'],
    optionsEn: ['100 years', '500 years', '4,000 years', '10 years'],
    optionsAr: ['100 سنة', '500 سنة', '4000 سنة', '10 سنوات'],
    optionsEs: ['100 años', '500 años', '4.000 años', '10 años'],
    correct: 2,
    explanationFr: 'Le verre met 4 000 ans à se décomposer — recyclons-le !',
    explanationEn: 'Glass takes 4,000 years to decompose — let\'s recycle it!',
    explanationAr: 'يستغرق الزجاج 4000 سنة للتحلل — فلنعيد تدويره!',
    explanationEs: 'El vidrio tarda 4.000 años en descomponerse — ¡reciclémoslo!',
  ),

  // ── 3 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quelle loi marocaine interdit les sacs plastiques ?',
    en: 'Which Moroccan law bans plastic bags?',
    ar: 'ما هو القانون المغربي الذي يحظر الأكياس البلاستيكية؟',
    es: '¿Qué ley marroquí prohíbe las bolsas de plástico?',
    optionsFr: ['Loi 28-00', 'Loi 77-15', 'Loi 99-12', 'Loi 11-03'],
    optionsEn: ['Law 28-00', 'Law 77-15', 'Law 99-12', 'Law 11-03'],
    optionsAr: ['قانون 28-00', 'قانون 77-15', 'قانون 99-12', 'قانون 11-03'],
    optionsEs: ['Ley 28-00', 'Ley 77-15', 'Ley 99-12', 'Ley 11-03'],
    correct: 1,
    explanationFr: 'La loi 77-15 interdit les sacs plastiques depuis 2016 au Maroc.',
    explanationEn: 'Law 77-15 bans plastic bags in Morocco since 2016.',
    explanationAr: 'يحظر قانون 77-15 الأكياس البلاستيكية في المغرب منذ 2016.',
    explanationEs: 'La Ley 77-15 prohíbe las bolsas de plástico en Marruecos desde 2016.',
  ),

  // ── 4 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Où déposer un téléphone usagé au Maroc ?',
    en: 'Where to drop off an old phone in Morocco?',
    ar: 'أين يُودَع الهاتف القديم في المغرب؟',
    es: '¿Dónde depositar un teléfono viejo en Marruecos?',
    optionsFr: ['Bac jaune', 'Éco-point ECOVAL', 'Bac noir', 'Colonne verte'],
    optionsEn: ['Yellow bin', 'ECOVAL eco-point', 'Black bin', 'Green column'],
    optionsAr: ['الحاوية الصفراء', 'نقطة ECOVAL البيئية', 'الحاوية السوداء', 'العمود الأخضر'],
    optionsEs: ['Contenedor amarillo', 'Punto eco ECOVAL', 'Contenedor negro', 'Columna verde'],
    correct: 1,
    explanationFr: 'Les DEEE (déchets électroniques) se déposent aux 500+ éco-points ECOVAL.',
    explanationEn: 'E-waste goes to 500+ ECOVAL eco-points across Morocco.',
    explanationAr: 'تُودَع النفايات الإلكترونية في أكثر من 500 نقطة ECOVAL بيئية.',
    explanationEs: 'Los residuos electrónicos van a los 500+ puntos eco ECOVAL de Marruecos.',
  ),

  // ── 5 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quel pourcentage des déchets marocains est organique ?',
    en: 'What percentage of Moroccan waste is organic?',
    ar: 'ما نسبة النفايات العضوية في المغرب؟',
    es: '¿Qué porcentaje de los residuos marroquíes es orgánico?',
    optionsFr: ['20%', '40%', '65%', '90%'],
    optionsEn: ['20%', '40%', '65%', '90%'],
    optionsAr: ['20%', '40%', '65%', '90%'],
    optionsEs: ['20%', '40%', '65%', '90%'],
    correct: 2,
    explanationFr: '65% des déchets marocains sont organiques — le compostage est crucial.',
    explanationEn: '65% of Moroccan waste is organic — composting is crucial.',
    explanationAr: '65% من النفايات المغربية عضوية — التسميد أمر بالغ الأهمية.',
    explanationEs: 'El 65% de los residuos marroquíes son orgánicos — el compostaje es crucial.',
  ),

  // ── 6 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Recycler 1 kg d\'aluminium économise combien d\'énergie ?',
    en: 'Recycling 1 kg of aluminium saves how much energy?',
    ar: 'إعادة تدوير 1 كغ من الألومنيوم يوفر كمية الطاقة؟',
    es: '¿Cuánta energía ahorra reciclar 1 kg de aluminio?',
    optionsFr: ['50%', '75%', '95%', '30%'],
    optionsEn: ['50%', '75%', '95%', '30%'],
    optionsAr: ['50%', '75%', '95%', '30%'],
    optionsEs: ['50%', '75%', '95%', '30%'],
    correct: 2,
    explanationFr: 'Recycler l\'aluminium économise 95% d\'énergie vs la production neuve.',
    explanationEn: 'Recycling aluminium saves 95% energy vs new production.',
    explanationAr: 'إعادة تدوير الألومنيوم يوفر 95% من الطاقة مقارنة بالإنتاج الجديد.',
    explanationEs: 'Reciclar aluminio ahorra un 95% de energía frente a la producción nueva.',
  ),

  // ── 7 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Le verre peut être recyclé combien de fois ?',
    en: 'How many times can glass be recycled?',
    ar: 'كم مرة يمكن إعادة تدوير الزجاج؟',
    es: '¿Cuántas veces se puede reciclar el vidrio?',
    optionsFr: ['5 fois', '10 fois', 'À l\'infini', '20 fois'],
    optionsEn: ['5 times', '10 times', 'Infinitely', '20 times'],
    optionsAr: ['5 مرات', '10 مرات', 'بلا نهاية', '20 مرة'],
    optionsEs: ['5 veces', '10 veces', 'Infinitamente', '20 veces'],
    correct: 2,
    explanationFr: 'Le verre est recyclable à 100% et à l\'infini sans perte de qualité.',
    explanationEn: 'Glass is 100% recyclable infinitely without quality loss.',
    explanationAr: 'الزجاج قابل لإعادة التدوير بنسبة 100% وإلى ما لا نهاية.',
    explanationEs: 'El vidrio es reciclable al 100% infinitamente sin pérdida de calidad.',
  ),

  // ── 8 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Où va le carton pizza gras ?',
    en: 'Where does greasy pizza cardboard go?',
    ar: 'أين تذهب علبة البيتزا الدهنية؟',
    es: '¿Dónde va el cartón de pizza grasiento?',
    optionsFr: ['Bac bleu recyclage', 'Bac noir ordures', 'Composteur', 'Colonne verte'],
    optionsEn: ['Blue recycling bin', 'Black waste bin', 'Compost', 'Green column'],
    optionsAr: ['الحاوية الزرقاء للتدوير', 'الحاوية السوداء للقمامة', 'السماد', 'العمود الأخضر'],
    optionsEs: ['Contenedor azul reciclaje', 'Contenedor negro basura', 'Compost', 'Columna verde'],
    correct: 1,
    explanationFr: 'Le carton gras ne se recycle pas — il va dans les ordures ménagères.',
    explanationEn: 'Greasy cardboard cannot be recycled — it goes in general waste.',
    explanationAr: 'الكرتون الدهني لا يمكن تدويره — يذهب إلى النفايات العامة.',
    explanationEs: 'El cartón grasiento no se puede reciclar — va a la basura general.',
  ),

  // ── 9 ─────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Que faire des médicaments périmés au Maroc ?',
    en: 'What to do with expired medicines in Morocco?',
    ar: 'ماذا تفعل بالأدوية المنتهية الصلاحية في المغرب؟',
    es: '¿Qué hacer con los medicamentos caducados en Marruecos?',
    optionsFr: ['Jeter à la poubelle', 'Ramener en pharmacie', 'Jeter dans les toilettes', 'Brûler'],
    optionsEn: ['Throw in bin', 'Return to pharmacy', 'Flush down toilet', 'Burn'],
    optionsAr: ['رمي في القمامة', 'إعادتها للصيدلية', 'رميها في المرحاض', 'حرقها'],
    optionsEs: ['Tirar a la basura', 'Devolver a la farmacia', 'Tirar por el inodoro', 'Quemar'],
    correct: 1,
    explanationFr: 'Les médicaments périmés doivent être ramenés en pharmacie pour destruction sécurisée.',
    explanationEn: 'Expired medicines must be returned to pharmacies for safe disposal.',
    explanationAr: 'يجب إعادة الأدوية المنتهية الصلاحية إلى الصيدلية للتخلص منها بأمان.',
    explanationEs: 'Los medicamentos caducados deben devolverse a las farmacias para su eliminación segura.',
  ),

  // ── 10 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Combien de litres d\'eau peut contaminer une pile bouton ?',
    en: 'How many liters of water can one button battery contaminate?',
    ar: 'كم لتراً من الماء يمكن أن تلوثه بطارية واحدة؟',
    es: '¿Cuántos litros de agua puede contaminar una pila de botón?',
    optionsFr: ['1 000 L', '10 000 L', '400 000 L', '100 L'],
    optionsEn: ['1,000 L', '10,000 L', '400,000 L', '100 L'],
    optionsAr: ['1000 لتر', '10000 لتر', '400000 لتر', '100 لتر'],
    optionsEs: ['1.000 L', '10.000 L', '400.000 L', '100 L'],
    correct: 2,
    explanationFr: 'Une pile bouton peut contaminer jusqu\'à 400 000 litres d\'eau.',
    explanationEn: 'One button battery can contaminate up to 400,000 liters of water.',
    explanationAr: 'يمكن لبطارية واحدة أن تلوث ما يصل إلى 400,000 لتر من الماء.',
    explanationEs: 'Una pila de botón puede contaminar hasta 400.000 litros de agua.',
  ),

  // ── 11 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Combien de temps met un sac plastique à se décomposer ?',
    en: 'How long does a plastic bag take to decompose?',
    ar: 'كم يستغرق تحلل كيس البلاستيك؟',
    es: '¿Cuánto tarda en descomponerse una bolsa de plástico?',
    optionsFr: ['10 ans', '50 ans', '450 ans', '1 000 ans'],
    optionsEn: ['10 years', '50 years', '450 years', '1,000 years'],
    optionsAr: ['10 سنوات', '50 سنة', '450 سنة', '1000 سنة'],
    optionsEs: ['10 años', '50 años', '450 años', '1.000 años'],
    correct: 2,
    explanationFr: 'Un sac plastique ordinaire met 450 ans à se décomposer dans la nature.',
    explanationEn: 'An ordinary plastic bag takes 450 years to decompose in nature.',
    explanationAr: 'يستغرق الكيس البلاستيكي العادي 450 سنة للتحلل في الطبيعة.',
    explanationEs: 'Una bolsa de plástico ordinaria tarda 450 años en descomponerse en la naturaleza.',
  ),

  // ── 12 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'L\'aluminium peut être recyclé combien de fois ?',
    en: 'How many times can aluminium be recycled?',
    ar: 'كم مرة يمكن إعادة تدوير الألومنيوم؟',
    es: '¿Cuántas veces se puede reciclar el aluminio?',
    optionsFr: ['3 fois', '10 fois', '50 fois', 'À l\'infini'],
    optionsEn: ['3 times', '10 times', '50 times', 'Infinitely'],
    optionsAr: ['3 مرات', '10 مرات', '50 مرة', 'بلا نهاية'],
    optionsEs: ['3 veces', '10 veces', '50 veces', 'Infinitamente'],
    correct: 3,
    explanationFr: 'Comme le verre, l\'aluminium est recyclable à l\'infini sans perte de qualité.',
    explanationEn: 'Like glass, aluminium can be recycled infinitely without losing quality.',
    explanationAr: 'مثل الزجاج، يمكن إعادة تدوير الألومنيوم إلى ما لا نهاية دون فقدان الجودة.',
    explanationEs: 'Como el vidrio, el aluminio puede reciclarse infinitamente sin perder calidad.',
  ),

  // ── 13 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Recycler 1 tonne de papier permet d\'économiser combien d\'arbres ?',
    en: 'Recycling 1 tonne of paper saves how many trees?',
    ar: 'إعادة تدوير طن واحد من الورق يوفر كم شجرة؟',
    es: '¿Cuántos árboles salva reciclar 1 tonelada de papel?',
    optionsFr: ['5 arbres', '17 arbres', '50 arbres', '100 arbres'],
    optionsEn: ['5 trees', '17 trees', '50 trees', '100 trees'],
    optionsAr: ['5 أشجار', '17 شجرة', '50 شجرة', '100 شجرة'],
    optionsEs: ['5 árboles', '17 árboles', '50 árboles', '100 árboles'],
    correct: 1,
    explanationFr: 'Recycler une tonne de papier sauve 17 arbres, 26 000 L d\'eau et 4 100 kWh d\'électricité.',
    explanationEn: 'Recycling one tonne of paper saves 17 trees, 26,000 L of water, and 4,100 kWh of electricity.',
    explanationAr: 'إعادة تدوير طن واحد من الورق توفر 17 شجرة و26,000 لتر ماء و4,100 كيلوواط/ساعة.',
    explanationEs: 'Reciclar una tonelada de papel salva 17 árboles, 26.000 L de agua y 4.100 kWh de electricidad.',
  ),

  // ── 14 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quel matériau met le plus longtemps à se décomposer ?',
    en: 'Which material takes the longest to decompose?',
    ar: 'أي مادة تستغرق أطول وقت للتحلل؟',
    es: '¿Qué material tarda más en descomponerse?',
    optionsFr: ['Plastique', 'Verre', 'Métal', 'Polystyrène'],
    optionsEn: ['Plastic', 'Glass', 'Metal', 'Styrofoam'],
    optionsAr: ['البلاستيك', 'الزجاج', 'المعدن', 'البوليسترين'],
    optionsEs: ['Plástico', 'Vidrio', 'Metal', 'Poliestireno'],
    correct: 1,
    explanationFr: 'Le verre met environ 4 000 ans, bien plus que le plastique (450 ans) ou le métal (100 ans).',
    explanationEn: 'Glass takes about 4,000 years, far more than plastic (450 years) or metal (100 years).',
    explanationAr: 'يستغرق الزجاج حوالي 4000 سنة، وهو أكثر بكثير من البلاستيك (450 سنة) أو المعدن (100 سنة).',
    explanationEs: 'El vidrio tarda unos 4.000 años, mucho más que el plástico (450 años) o el metal (100 años).',
  ),

  // ── 15 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quelle couleur de bac pour les déchets organiques ?',
    en: 'What color bin is used for organic waste?',
    ar: 'ما لون حاوية النفايات العضوية؟',
    es: '¿De qué color es el contenedor para residuos orgánicos?',
    optionsFr: ['Jaune', 'Vert', 'Marron', 'Bleu'],
    optionsEn: ['Yellow', 'Green', 'Brown', 'Blue'],
    optionsAr: ['أصفر', 'أخضر', 'بني', 'أزرق'],
    optionsEs: ['Amarillo', 'Verde', 'Marrón', 'Azul'],
    correct: 2,
    explanationFr: 'Le bac marron est dédié aux biodéchets (restes alimentaires, épluchures, marc de café…).',
    explanationEn: 'The brown bin is dedicated to biodegradable waste (food scraps, peels, coffee grounds…).',
    explanationAr: 'الحاوية البنية مخصصة للنفايات البيولوجية (بقايا الطعام، القشور، تفل القهوة…).',
    explanationEs: 'El contenedor marrón está destinado a los residuos biodegradables (restos de comida, mondaduras, posos de café…).',
  ),

  // ── 16 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Qu\'est-ce que le compostage ?',
    en: 'What is composting?',
    ar: 'ما هو التسميد (الكومبوست)؟',
    es: '¿Qué es el compostaje?',
    optionsFr: ['Brûler les déchets', 'Transformer les déchets organiques en engrais', 'Recycler le plastique', 'Enfouir les déchets'],
    optionsEn: ['Burning waste', 'Turning organic waste into fertiliser', 'Recycling plastic', 'Burying waste'],
    optionsAr: ['حرق النفايات', 'تحويل النفايات العضوية إلى سماد', 'إعادة تدوير البلاستيك', 'دفن النفايات'],
    optionsEs: ['Quemar residuos', 'Convertir residuos orgánicos en abono', 'Reciclar plástico', 'Enterrar residuos'],
    correct: 1,
    explanationFr: 'Le compostage décompose les matières organiques pour produire un engrais naturel utilisable au jardin.',
    explanationEn: 'Composting decomposes organic matter to produce natural fertiliser usable in the garden.',
    explanationAr: 'التسميد يحلل المواد العضوية لإنتاج سماد طبيعي صالح للاستخدام في الحديقة.',
    explanationEs: 'El compostaje descompone la materia orgánica para producir un abono natural utilizable en el jardín.',
  ),

  // ── 17 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quelle fraction des déchets plastiques mondiaux est réellement recyclée ?',
    en: 'What fraction of global plastic waste is actually recycled?',
    ar: 'ما نسبة النفايات البلاستيكية العالمية التي يُعاد تدويرها فعلياً؟',
    es: '¿Qué fracción de los residuos plásticos mundiales se recicla realmente?',
    optionsFr: ['Environ 9%', 'Environ 30%', 'Environ 50%', 'Environ 70%'],
    optionsEn: ['About 9%', 'About 30%', 'About 50%', 'About 70%'],
    optionsAr: ['حوالي 9%', 'حوالي 30%', 'حوالي 50%', 'حوالي 70%'],
    optionsEs: ['Alrededor del 9%', 'Alrededor del 30%', 'Alrededor del 50%', 'Alrededor del 70%'],
    correct: 0,
    explanationFr: 'Seulement ~9% des plastiques produits depuis les années 50 ont été recyclés. 91% finissent en décharge ou dans la nature.',
    explanationEn: 'Only ~9% of all plastics produced since the 1950s have been recycled. 91% end up in landfill or nature.',
    explanationAr: 'فقط حوالي 9% من جميع البلاستيك المنتج منذ الخمسينيات أُعيد تدويره. 91% ينتهي في مكبات أو في الطبيعة.',
    explanationEs: 'Solo ~9% de todos los plásticos producidos desde los años 50 han sido reciclados. El 91% acaba en vertederos o en la naturaleza.',
  ),

  // ── 18 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quel code plastique est le plus facilement recyclable ?',
    en: 'Which plastic code is most easily recycled?',
    ar: 'أي رمز بلاستيكي الأسهل إعادة تدويره؟',
    es: '¿Qué código de plástico es el más fácil de reciclar?',
    optionsFr: ['PET (code 1)', 'PVC (code 3)', 'PS (code 6)', 'Autre (code 7)'],
    optionsEn: ['PET (code 1)', 'PVC (code 3)', 'PS (code 6)', 'Other (code 7)'],
    optionsAr: ['PET (الرمز 1)', 'PVC (الرمز 3)', 'PS (الرمز 6)', 'أخرى (الرمز 7)'],
    optionsEs: ['PET (código 1)', 'PVC (código 3)', 'PS (código 6)', 'Otro (código 7)'],
    correct: 0,
    explanationFr: 'Le PET (code 1) — bouteilles d\'eau et sodas — est le plastique le plus recyclé au monde.',
    explanationEn: 'PET (code 1) — water and soda bottles — is the most recycled plastic in the world.',
    explanationAr: 'PET (الرمز 1) — زجاجات الماء والمشروبات الغازية — هو البلاستيك الأكثر إعادة تدويراً في العالم.',
    explanationEs: 'El PET (código 1) — botellas de agua y refrescos — es el plástico más reciclado del mundo.',
  ),

  // ── 19 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Que signifie le symbole des trois flèches en triangle ?',
    en: 'What does the three-arrow triangle symbol mean?',
    ar: 'ماذا يعني رمز المثلث ذي الأسهم الثلاثة؟',
    es: '¿Qué significa el símbolo del triángulo de tres flechas?',
    optionsFr: ['Le produit est biodégradable', 'Le matériau est recyclable', 'Le produit est dangereux', 'Le produit est bio'],
    optionsEn: ['The product is biodegradable', 'The material is recyclable', 'The product is dangerous', 'The product is organic'],
    optionsAr: ['المنتج قابل للتحلل الحيوي', 'المادة قابلة لإعادة التدوير', 'المنتج خطير', 'المنتج عضوي'],
    optionsEs: ['El producto es biodegradable', 'El material es reciclable', 'El producto es peligroso', 'El producto es ecológico'],
    correct: 1,
    explanationFr: 'Le symbole Möbius (trois flèches) indique que le matériau est recyclable — pas forcément qu\'il sera recyclé.',
    explanationEn: 'The Möbius symbol (three arrows) means the material is recyclable — not necessarily that it will be recycled.',
    explanationAr: 'رمز موبيوس (الأسهم الثلاثة) يعني أن المادة قابلة لإعادة التدوير — وليس بالضرورة أنها ستُعاد.',
    explanationEs: 'El símbolo de Möbius (tres flechas) indica que el material es reciclable — no necesariamente que se reciclará.',
  ),

  // ── 20 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Les déchets électroniques représentent quel % des déchets dangereux mondiaux ?',
    en: 'E-waste represents what % of the world\'s hazardous waste?',
    ar: 'تمثل النفايات الإلكترونية كم بالمئة من النفايات الخطرة في العالم؟',
    es: '¿Los residuos electrónicos representan qué % de los residuos peligrosos mundiales?',
    optionsFr: ['2%', '10%', '70%', '50%'],
    optionsEn: ['2%', '10%', '70%', '50%'],
    optionsAr: ['2%', '10%', '70%', '50%'],
    optionsEs: ['2%', '10%', '70%', '50%'],
    correct: 2,
    explanationFr: 'Les e-déchets représentent ~2% des déchets mais 70% des déchets dangereux mondiaux !',
    explanationEn: 'E-waste is ~2% of waste but 70% of the world\'s hazardous waste!',
    explanationAr: 'النفايات الإلكترونية تمثل ~2% من النفايات لكن 70% من النفايات الخطرة في العالم!',
    explanationEs: '¡Los residuos electrónicos son ~2% de los residuos pero el 70% de los peligrosos del mundo!',
  ),

  // ── 21 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quel déchet peut contaminer tout un bac de recyclage ?',
    en: 'Which waste item can contaminate an entire recycling bin?',
    ar: 'أي نفاية يمكنها تلويث حاوية إعادة تدوير كاملة؟',
    es: '¿Qué residuo puede contaminar todo un contenedor de reciclaje?',
    optionsFr: ['Une cannette vide', 'Une bouteille d\'huile pleine', 'Un carton plié', 'Un journal'],
    optionsEn: ['An empty can', 'A full oil bottle', 'A folded cardboard', 'A newspaper'],
    optionsAr: ['علبة فارغة', 'زجاجة زيت ممتلئة', 'كرتون مطوي', 'جريدة'],
    optionsEs: ['Una lata vacía', 'Una botella de aceite llena', 'Un cartón doblado', 'Un periódico'],
    correct: 1,
    explanationFr: 'Une bouteille d\'huile non rincée peut contaminer tout le lot de recyclage, le rendant inutilisable.',
    explanationEn: 'An un-rinsed oil bottle can contaminate an entire recycling batch, making it unusable.',
    explanationAr: 'زجاجة زيت غير مشطوفة يمكنها تلويث دفعة إعادة التدوير بالكامل وجعلها غير قابلة للاستخدام.',
    explanationEs: 'Una botella de aceite sin enjuagar puede contaminar todo un lote de reciclaje, inutilizándolo.',
  ),

  // ── 22 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Fabriquer du papier recyclé consomme combien d\'eau de moins ?',
    en: 'Making recycled paper uses how much less water?',
    ar: 'إنتاج الورق المعاد تدويره يستهلك كمية أقل من الماء بكم؟',
    es: '¿Fabricar papel reciclado usa cuánta agua menos?',
    optionsFr: ['20% de moins', '50% de moins', '70% de moins', '90% de moins'],
    optionsEn: ['20% less', '50% less', '70% less', '90% less'],
    optionsAr: ['20% أقل', '50% أقل', '70% أقل', '90% أقل'],
    optionsEs: ['20% menos', '50% menos', '70% menos', '90% menos'],
    correct: 2,
    explanationFr: 'Produire du papier recyclé consomme 70% moins d\'eau que du papier vierge.',
    explanationEn: 'Producing recycled paper uses 70% less water than virgin paper.',
    explanationAr: 'إنتاج الورق المعاد تدويره يستهلك 70% من الماء أقل مقارنة بالورق الجديد.',
    explanationEs: 'Producir papel reciclado consume un 70% menos de agua que el papel virgen.',
  ),

  // ── 23 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Quelle est la durée de vie d\'une bouteille en plastique dans l\'océan ?',
    en: 'What is the lifespan of a plastic bottle in the ocean?',
    ar: 'ما هو عمر الزجاجة البلاستيكية في المحيط؟',
    es: '¿Cuánto dura una botella de plástico en el océan?',
    optionsFr: ['50 ans', '200 ans', '450 ans', '1 000 ans'],
    optionsEn: ['50 years', '200 years', '450 years', '1,000 years'],
    optionsAr: ['50 سنة', '200 سنة', '450 سنة', '1000 سنة'],
    optionsEs: ['50 años', '200 años', '450 años', '1.000 años'],
    correct: 2,
    explanationFr: 'Dans l\'océan, une bouteille plastique peut persister 450 ans tout en libérant des microplastiques.',
    explanationEn: 'In the ocean, a plastic bottle can persist for 450 years while releasing microplastics.',
    explanationAr: 'في المحيط، يمكن أن تستمر الزجاجة البلاستيكية 450 سنة مع إطلاق البلاستيك الدقيق.',
    explanationEs: 'En el océano, una botella de plástico puede persistir 450 años liberando microplásticos.',
  ),

  // ── 24 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Qu\'est-ce que l\'upcycling ?',
    en: 'What is upcycling?',
    ar: 'ما هو الـ Upcycling (إعادة الابتكار)؟',
    es: '¿Qué es el upcycling (suprarreciclaje)?',
    optionsFr: ['Recycler en perdant de la qualité', 'Réutiliser en ajoutant de la valeur', 'Brûler pour produire de l\'énergie', 'Trier les déchets automatiquement'],
    optionsEn: ['Recycling with quality loss', 'Reusing by adding value', 'Burning to produce energy', 'Sorting waste automatically'],
    optionsAr: ['إعادة التدوير مع فقدان الجودة', 'إعادة الاستخدام بإضافة قيمة', 'الحرق لإنتاج الطاقة', 'الفرز التلقائي للنفايات'],
    optionsEs: ['Reciclar perdiendo calidad', 'Reutilizar añadiendo valor', 'Quemar para producir energía', 'Clasificar residuos automáticamente'],
    correct: 1,
    explanationFr: 'L\'upcycling transforme un déchet en objet de valeur supérieure, contrairement au recyclage classique.',
    explanationEn: 'Upcycling transforms waste into a higher-value item, unlike standard recycling.',
    explanationAr: 'يحول الـ Upcycling النفاية إلى شيء ذي قيمة أعلى، على عكس إعادة التدوير التقليدية.',
    explanationEs: 'El upcycling transforma un residuo en un artículo de mayor valor, a diferencia del reciclaje estándar.',
  ),

  // ── 25 ────────────────────────────────────────────────────────────────────
  _Question(
    fr: 'Un Marocain produit en moyenne combien de kg de déchets par jour ?',
    en: 'How many kg of waste does an average Moroccan produce per day?',
    ar: 'كم كيلوغراماً من النفايات ينتج المغربي العادي يومياً؟',
    es: '¿Cuántos kg de residuos produce un marroquí medio al día?',
    optionsFr: ['0,3 kg', '0,75 kg', '1,5 kg', '3 kg'],
    optionsEn: ['0.3 kg', '0.75 kg', '1.5 kg', '3 kg'],
    optionsAr: ['0.3 كغ', '0.75 كغ', '1.5 كغ', '3 كغ'],
    optionsEs: ['0,3 kg', '0,75 kg', '1,5 kg', '3 kg'],
    correct: 1,
    explanationFr: 'Un Marocain produit environ 0,75 kg de déchets par jour, soit ~260 kg par an.',
    explanationEn: 'An average Moroccan produces about 0.75 kg of waste per day, ~260 kg per year.',
    explanationAr: 'ينتج المغربي العادي حوالي 0.75 كغ من النفايات يومياً، أي ~260 كغ سنوياً.',
    explanationEs: 'Un marroquí medio produce unos 0,75 kg de residuos al día, ~260 kg al año.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int  _current  = 0;
  int  _score    = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  void _answer(int idx) {
    if (_answered) return;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == _questions[_current].correct) _score++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() { _current++; _selected = null; _answered = false; });
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _current = 0; _score = 0;
      _selected = null; _answered = false; _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang   = ref.watch(localeProvider).languageCode;
    final s      = AppStrings.of(lang);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context, isDark, s),
          Expanded(child: _finished
              ? _buildResult(isDark, lang, s)
              : _buildQuestion(isDark, lang, s)),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppStrings s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey.shade100,
              shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(s.quizTitle, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary))),
        if (!_finished)
          Text('${_current + 1}/${_questions.length}',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                  fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildQuestion(bool isDark, String lang, AppStrings s) {
    final q           = _questions[_current];
    final question    = lang == 'ar' ? q.ar : lang == 'en' ? q.en : lang == 'es' ? q.es : q.fr;
    final options     = lang == 'ar' ? q.optionsAr : lang == 'en' ? q.optionsEn : lang == 'es' ? q.optionsEs : q.optionsFr;
    final explanation = lang == 'ar' ? q.explanationAr : lang == 'en' ? q.explanationEn : lang == 'es' ? q.explanationEs : q.explanationFr;
    final isLast      = _current == _questions.length - 1;
    final nextLabel   = isLast ? s.quizResult_ : s.quizNext;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_current + 1) / _questions.length,
            backgroundColor: isDark ? AppColors.darkInput : AppColors.inputBg,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),

        Text(question, style: TextStyle(fontFamily: 'Poppins', fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.textPrimary))
            .animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
        const SizedBox(height: 20),

        // Options
        ...List.generate(options.length, (i) {
          Color bg, border;
          if (!_answered) {
            bg = isDark ? AppColors.darkCard : Colors.white;
            border = Colors.transparent;
          } else if (i == q.correct) {
            bg = const Color(0xFF00C853).withValues(alpha: 0.15);
            border = const Color(0xFF00C853);
          } else if (i == _selected) {
            bg = const Color(0xFFD50000).withValues(alpha: 0.15);
            border = const Color(0xFFD50000);
          } else {
            bg = isDark ? AppColors.darkCard : Colors.white;
            border = Colors.transparent;
          }
          return GestureDetector(
            onTap: () => _answer(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 2),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8)],
              ),
              child: Row(children: [
                Expanded(child: Text(options[i], style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary))),
                if (_answered && i == q.correct)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 20),
                if (_answered && i == _selected && i != q.correct)
                  const Icon(Icons.cancel_rounded, color: Color(0xFFD50000), size: 20),
              ]),
            ).animate(delay: (i * 80).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05),
          );
        }),

        // Explication
        if (_answered) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(explanation, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, color: AppColors.primary))),
            ]),
          ).animate().fadeIn(duration: 400.ms),
        ],

        const Spacer(),

        if (_answered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(nextLabel, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
      ]),
    );
  }

  Widget _buildResult(bool isDark, String lang, AppStrings s) {
    final pct   = (_score / _questions.length * 100).round();
    final emoji = pct >= 80 ? '🏆' : pct >= 60 ? '🌿' : '📚';
    final title = pct >= 80 ? s.quizExcellent
                : pct >= 60 ? s.quizWellDone
                : s.quizKeepLearning;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 72))
              .animate().scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary))
              .animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(s.quizScore(_score, _questions.length),
              style: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w700))
              .animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          SizedBox(
            width: 140, height: 140,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: _score / _questions.length,
                strokeWidth: 12,
                backgroundColor: isDark ? AppColors.darkInput : AppColors.inputBg,
                valueColor: AlwaysStoppedAnimation<Color>(
                    pct >= 80 ? const Color(0xFF00C853)
                    : pct >= 60 ? AppColors.primary : AppColors.accent),
              ),
              Text('$pct%', style: TextStyle(fontFamily: 'Poppins', fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary)),
            ]),
          ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(s.quizRetry, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        ]),
      ),
    );
  }
}
