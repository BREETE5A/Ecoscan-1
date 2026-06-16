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
];
