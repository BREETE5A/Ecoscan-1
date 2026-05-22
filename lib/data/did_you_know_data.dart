import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DidYouKnowFact {
  final String id;
  final String fact;
  final String category; // 'plastique' | 'verre' | 'papier' | 'metal' | 'organique' | 'general' | 'maroc'
  final IconData icon;
  final Color color;

  const DidYouKnowFact({
    required this.id,
    required this.fact,
    required this.category,
    required this.icon,
    required this.color,
  });
}

const List<DidYouKnowFact> allFacts = [
  // ── Plastique ───────────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f01',
    fact: 'Une bouteille plastique met 400 ans à se décomposer dans la nature.',
    category: 'plastique',
    icon: Icons.opacity_rounded,
    color: AppColors.plastic,
  ),
  DidYouKnowFact(
    id: 'f02',
    fact: 'Le Maroc a interdit les sacs plastique oxodégradables en 2016 avec la Loi 77-15.',
    category: 'maroc',
    icon: Icons.gavel_rounded,
    color: Color(0xFFEF5350),
  ),
  DidYouKnowFact(
    id: 'f03',
    fact: 'Recycler 1 tonne de plastique économise 5 800 kWh d\'énergie.',
    category: 'plastique',
    icon: Icons.bolt_rounded,
    color: AppColors.accent,
  ),
  DidYouKnowFact(
    id: 'f04',
    fact: 'Chaque année, 8 millions de tonnes de plastique finissent dans les océans.',
    category: 'plastique',
    icon: Icons.water_rounded,
    color: Color(0xFF0288D1),
  ),
  DidYouKnowFact(
    id: 'f05',
    fact: 'Un bouchon plastique recyclé peut devenir un nouveau stylo ou un pot de fleur.',
    category: 'plastique',
    icon: Icons.recycling_rounded,
    color: AppColors.primary,
  ),

  // ── Verre ───────────────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f06',
    fact: 'Le verre met 4 000 ans à se décomposer. Il est recyclable à 100% indéfiniment.',
    category: 'verre',
    icon: Icons.local_bar_outlined,
    color: AppColors.glass,
  ),
  DidYouKnowFact(
    id: 'f07',
    fact: 'Recycler 1 tonne de verre économise 300 kg de CO₂ et 1,2 tonne de matières premières.',
    category: 'verre',
    icon: Icons.air_rounded,
    color: Color(0xFF29B6F6),
  ),
  DidYouKnowFact(
    id: 'f08',
    fact: 'Une bouteille en verre recyclée économise assez d\'énergie pour alimenter une ampoule LED 4 heures.',
    category: 'verre',
    icon: Icons.lightbulb_rounded,
    color: Color(0xFFF9A825),
  ),
  DidYouKnowFact(
    id: 'f09',
    fact: 'Le miroir et le verre trempé ne vont PAS dans le bac à verre — ils fondent à des températures différentes.',
    category: 'verre',
    icon: Icons.do_not_disturb_alt_rounded,
    color: Color(0xFFEF5350),
  ),

  // ── Papier / Carton ─────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f10',
    fact: 'Pour produire 1 tonne de papier neuf, il faut 17 arbres. Recyclez-le !',
    category: 'papier',
    icon: Icons.article_outlined,
    color: AppColors.paper,
  ),
  DidYouKnowFact(
    id: 'f11',
    fact: 'Le ticket de caisse contient du Bisphénol A (BPA) — ne le recyclez pas, il contamine.',
    category: 'papier',
    icon: Icons.receipt_rounded,
    color: Color(0xFFFF7043),
  ),
  DidYouKnowFact(
    id: 'f12',
    fact: 'La CMCP (papeterie marocaine) traite chaque année des milliers de tonnes de carton recyclé.',
    category: 'maroc',
    icon: Icons.factory_rounded,
    color: Color(0xFF795548),
  ),
  DidYouKnowFact(
    id: 'f13',
    fact: 'Un journal recyclé peut redevenir du papier en seulement 7 jours.',
    category: 'papier',
    icon: Icons.newspaper_rounded,
    color: AppColors.paper,
  ),

  // ── Métal ───────────────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f14',
    fact: 'L\'aluminium peut être recyclé en 60 jours, de la poubelle au rayon supermarché.',
    category: 'metal',
    icon: Icons.hardware_rounded,
    color: AppColors.metal,
  ),
  DidYouKnowFact(
    id: 'f15',
    fact: 'Recycler 1 kg d\'aluminium économise 8 kg de CO₂ et 95% de l\'énergie de production.',
    category: 'metal',
    icon: Icons.energy_savings_leaf_rounded,
    color: AppColors.primary,
  ),
  DidYouKnowFact(
    id: 'f16',
    fact: 'Une canette d\'aluminium met 200 à 500 ans à se décomposer dans la nature.',
    category: 'metal',
    icon: Icons.timelapse_rounded,
    color: Color(0xFF607D8B),
  ),
  DidYouKnowFact(
    id: 'f17',
    fact: 'Une boîte de conserve peut devenir une pièce de vélo, une chaise ou un pont en acier.',
    category: 'metal',
    icon: Icons.construction_rounded,
    color: AppColors.metal,
  ),

  // ── Organique ───────────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f18',
    fact: 'Au Maroc, 65% des déchets ménagers sont organiques et peuvent être compostés.',
    category: 'maroc',
    icon: Icons.pie_chart_rounded,
    color: Color(0xFF66BB6A),
  ),
  DidYouKnowFact(
    id: 'f19',
    fact: 'Le marc de café repoussé les escargots et fertilise les plantes — ne le jetez pas !',
    category: 'organique',
    icon: Icons.coffee_rounded,
    color: Color(0xFF795548),
  ),
  DidYouKnowFact(
    id: 'f20',
    fact: 'Un composteur familial réduit de 30% le volume de vos poubelles.',
    category: 'organique',
    icon: Icons.compost_rounded,
    color: Color(0xFF2E7D32),
  ),
  DidYouKnowFact(
    id: 'f21',
    fact: 'Les épluchures d\'orange compostées améliorent la structure du sol en argile.',
    category: 'organique',
    icon: Icons.eco_rounded,
    color: Color(0xFFFF7043),
  ),

  // ── DEEE / Électronique ──────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f22',
    fact: 'Le Décret 2-12-695 oblige les producteurs à collecter les appareils DEEE au Maroc.',
    category: 'maroc',
    icon: Icons.gavel_rounded,
    color: AppColors.electronics,
  ),
  DidYouKnowFact(
    id: 'f23',
    fact: 'Un smartphone contient de l\'or, de l\'argent, du cobalt et du lithium recyclables.',
    category: 'general',
    icon: Icons.smartphone_rounded,
    color: Color(0xFF5C6BC0),
  ),
  DidYouKnowFact(
    id: 'f24',
    fact: 'ECOVAL dispose de 500+ éco-points au Maroc pour déposer vos appareils DEEE.',
    category: 'maroc',
    icon: Icons.location_on_rounded,
    color: AppColors.primary,
  ),
  DidYouKnowFact(
    id: 'f25',
    fact: 'Un réfrigérateur contient des gaz fluorés très nuisibles à l\'ozone — ne le cassez pas !',
    category: 'general',
    icon: Icons.kitchen_rounded,
    color: Color(0xFF0277BD),
  ),

  // ── Général / Impact ─────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f26',
    fact: 'Recycler une tonne de déchets crée 10x plus d\'emplois que l\'incinération.',
    category: 'general',
    icon: Icons.people_rounded,
    color: AppColors.primary,
  ),
  DidYouKnowFact(
    id: 'f27',
    fact: 'Le Programme National de Déchets Ménagers (PNDM) vise 100% de mise en décharge contrôlée d\'ici 2030.',
    category: 'maroc',
    icon: Icons.flag_rounded,
    color: Color(0xFF1565C0),
  ),
  DidYouKnowFact(
    id: 'f28',
    fact: 'Une pile alcaline mal jetée peut contaminer 1 m³ de sol et 1 000 L d\'eau.',
    category: 'general',
    icon: Icons.battery_alert_rounded,
    color: Color(0xFFEF5350),
  ),
  DidYouKnowFact(
    id: 'f29',
    fact: 'Recycler diminue les émissions de gaz à effet de serre équivalentes à retirer des millions de voitures.',
    category: 'general',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF546E7A),
  ),
  DidYouKnowFact(
    id: 'f30',
    fact: 'L\'association Zéro Zbel organise des clean-ups dans les plages marocaines chaque mois.',
    category: 'maroc',
    icon: Icons.beach_access_rounded,
    color: Color(0xFF00BCD4),
  ),

  // ── Eau / Énergie ────────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f31',
    fact: 'Recycler 1 tonne de plastique économise 5 000 à 6 000 litres d\'eau.',
    category: 'plastique',
    icon: Icons.water_drop_rounded,
    color: AppColors.info,
  ),
  DidYouKnowFact(
    id: 'f32',
    fact: 'Produire du papier recyclé consomme 60% moins d\'eau que du papier vierge.',
    category: 'papier',
    icon: Icons.water_rounded,
    color: Color(0xFF0288D1),
  ),
  DidYouKnowFact(
    id: 'f33',
    fact: 'Le recyclage du verre nécessite 40% moins d\'énergie que la fabrication à partir de sable.',
    category: 'verre',
    icon: Icons.bolt_rounded,
    color: AppColors.accent,
  ),

  // ── Textile ──────────────────────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f34',
    fact: 'Une veste en polyester recyclée nécessite 70% moins d\'énergie que du polyester neuf.',
    category: 'general',
    icon: Icons.checkroom_rounded,
    color: Color(0xFF7986CB),
  ),
  DidYouKnowFact(
    id: 'f35',
    fact: 'Au Maroc, les souks de fripe (vêtements de seconde main) sont une forme de recyclage textile ancestrale.',
    category: 'maroc',
    icon: Icons.store_rounded,
    color: Color(0xFFAB47BC),
  ),

  // ── Comportement / Conseils ──────────────────────────────────────────────────
  DidYouKnowFact(
    id: 'f36',
    fact: 'Rincer un bocal avant de le recycler réduit les risques de contamination du lot entier.',
    category: 'general',
    icon: Icons.cleaning_services_rounded,
    color: AppColors.primary,
  ),
  DidYouKnowFact(
    id: 'f37',
    fact: 'Un emballage gras ou souillé contamine et rend les autres déchets non recyclables.',
    category: 'general',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFF39C12),
  ),
  DidYouKnowFact(
    id: 'f38',
    fact: 'Aplatir les boîtes et bouteilles avant de les trier libère de la place dans les bacs.',
    category: 'general',
    icon: Icons.compress_rounded,
    color: AppColors.primary,
  ),
  DidYouKnowFact(
    id: 'f39',
    fact: 'Les médicaments périmés doivent être rapportés en pharmacie — pas dans les poubelles.',
    category: 'general',
    icon: Icons.medication_rounded,
    color: Color(0xFF26A69A),
  ),
  DidYouKnowFact(
    id: 'f40',
    fact: 'EcoScan vous aide à identifier les bons bacs de tri selon les normes ECOVAL au Maroc.',
    category: 'maroc',
    icon: Icons.document_scanner_rounded,
    color: AppColors.primary,
  ),
];
