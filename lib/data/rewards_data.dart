import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RewardData {
  final String id;
  final String title;
  final String description;
  final String category; // 'badge' | 'privilege' | 'surprise'
  final int cost; // points requis
  final IconData icon;
  final Color color;
  final String partner; // partenaire ou '' si aucun

  const RewardData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cost,
    required this.icon,
    required this.color,
    this.partner = '',
  });
}

const List<RewardData> allRewards = [
  // ── Badges Virtuels ─────────────────────────────────────────────────────────
  RewardData(
    id: 'r01',
    title: 'Badge Éco-Guerrier',
    description: 'Badge exclusif pour les champions du tri au Maroc',
    category: 'badge',
    cost: 200,
    icon: Icons.military_tech_rounded,
    color: AppColors.primary,
  ),
  RewardData(
    id: 'r02',
    title: 'Badge Gardien de l\'Eau',
    description: 'Récompense pour avoir économisé 100 L d\'eau virtuelle',
    category: 'badge',
    cost: 300,
    icon: Icons.water_drop_rounded,
    color: AppColors.info,
  ),
  RewardData(
    id: 'r03',
    title: 'Badge Forêt Verte',
    description: 'Pour avoir sauvé 5 arbres virtuels par le recyclage',
    category: 'badge',
    cost: 250,
    icon: Icons.forest_rounded,
    color: Color(0xFF388E3C),
  ),
  RewardData(
    id: 'r04',
    title: 'Badge Éco-Tech',
    description: 'Décerné aux maîtres du recyclage électronique DEEE',
    category: 'badge',
    cost: 350,
    icon: Icons.electrical_services_rounded,
    color: AppColors.electronics,
  ),
  RewardData(
    id: 'r05',
    title: 'Badge Légende Maroc',
    description: 'Le badge ultime — réservé à l\'élite du tri marocain',
    category: 'badge',
    cost: 1000,
    icon: Icons.public_rounded,
    color: Color(0xFFFFD700),
  ),
  RewardData(
    id: 'r06',
    title: 'Badge Streaker',
    description: 'Scannez 7 jours de suite pour le décrocher',
    category: 'badge',
    cost: 400,
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF7043),
  ),
  RewardData(
    id: 'r07',
    title: 'Badge Champion CO₂',
    description: 'Économisez 5 kg de CO₂ au total',
    category: 'badge',
    cost: 500,
    icon: Icons.thermostat_rounded,
    color: Color(0xFFFF6F00),
  ),

  // ── Privilèges ──────────────────────────────────────────────────────────────
  RewardData(
    id: 'r08',
    title: 'Coupon -10% Carrefour',
    description: 'Réduction de 10% sur votre prochaine course alimentaire',
    category: 'privilege',
    cost: 500,
    icon: Icons.local_grocery_store_rounded,
    color: Color(0xFF1565C0),
    partner: 'Carrefour Maroc',
  ),
  RewardData(
    id: 'r09',
    title: 'Bon d\'achat Marjane 50 DH',
    description: 'Bon d\'achat valable dans tous les Marjane du Maroc',
    category: 'privilege',
    cost: 800,
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFE53935),
    partner: 'Marjane',
  ),
  RewardData(
    id: 'r10',
    title: 'Livraison Gratuite Jumia',
    description: '3 livraisons gratuites sur Jumia.ma',
    category: 'privilege',
    cost: 600,
    icon: Icons.local_shipping_rounded,
    color: Color(0xFFFF6F00),
    partner: 'Jumia Maroc',
  ),
  RewardData(
    id: 'r11',
    title: 'Abonnement Zéro Zbel',
    description: '1 mois d\'abonnement premium Zéro Zbel offert',
    category: 'privilege',
    cost: 700,
    icon: Icons.recycling_rounded,
    color: AppColors.primary,
    partner: 'Zéro Zbel',
  ),
  RewardData(
    id: 'r12',
    title: 'Crédit Inwi 20 DH',
    description: 'Rechargement téléphonique offert sur votre numéro Inwi',
    category: 'privilege',
    cost: 450,
    icon: Icons.sim_card_rounded,
    color: Color(0xFF7B1FA2),
    partner: 'Inwi',
  ),

  // ── Surprises ───────────────────────────────────────────────────────────────
  RewardData(
    id: 'r13',
    title: 'Surprise Éco-Mystère',
    description: 'Une récompense surprise choisie par EcoScan pour vous !',
    category: 'surprise',
    cost: 300,
    icon: Icons.card_giftcard_rounded,
    color: AppColors.purple,
  ),
  RewardData(
    id: 'r14',
    title: 'Don à GreenMaroc',
    description: 'Faites un don symbolique à l\'association GreenMaroc',
    category: 'surprise',
    cost: 150,
    icon: Icons.favorite_rounded,
    color: Color(0xFFE91E63),
    partner: 'GreenMaroc',
  ),
  RewardData(
    id: 'r15',
    title: 'Plantation d\'Arbre',
    description: 'Un arbre planté en votre nom au Maroc via l\'ONG Joud',
    category: 'surprise',
    cost: 1200,
    icon: Icons.park_rounded,
    color: Color(0xFF2E7D32),
    partner: 'Joud ONG',
  ),
];
