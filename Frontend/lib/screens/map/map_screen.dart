import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../providers/challenges_provider.dart';
import '../../theme/app_theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  late AnimationController _markerCtrl;
  late AnimationController _pulseCtrl;
  late MapController _mapController;

  String _selected = 'Tous';
  final _search = TextEditingController();

  static const _filters = [
    'Tous', 'Plastique', 'Verre', 'Papier', 'Compost', 'Piles', 'Électronique', 'Textile',
    'Huiles', 'Métal',
  ];

  LatLng? _userPosition;
  bool _isLoadingLocation = true;
  final List<_Point> _dynamicPoints = [];
  bool _isLoadingPoints = false;
  int? _tapped;

  // Sources : geocycle.com/fr/maroc · ecozalagh.com · smrr.ma · pndm.environnement.gov.ma · marjane.ma
  static final _staticPoints = <_Point>[
    // ── GEOCYCLE – 4 plateformes industrielles (geocycle.com/fr/maroc) ─────────
    _Point('Geocycle – Bouskoura (Nouaceur)', 'Co-traitement industriel – 75 000 t/an',
        const LatLng(33.3700, -7.6500), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Geocycle – El Gara (Berrechid)', 'Co-traitement déchets dangereux',
        const LatLng(33.2692, -7.5847), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Geocycle – Route de Rabat km19 (Tanger)', 'Co-traitement industriel – 20 000 t/an',
        const LatLng(35.5950, -5.8300), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Geocycle – Oum Azza (18 km est de Rabat)', 'Valorisation déchets ménagers',
        const LatLng(33.8800, -6.7000), AppColors.primary, Icons.factory_rounded, 'Tous'),

    // ── ECO ZALAGH – 2 bases logistiques (ecozalagh.com) ─────────────────────
    _Point('Eco Zalagh – Sidi Hajjaj (Casablanca)', 'Collecte • Tri • Valorisation déchets',
        const LatLng(33.5050, -7.4750), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Eco Zalagh – Gzenaya (Tanger)', 'Collecte • Tri • Valorisation déchets',
        const LatLng(35.6500, -5.9500), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── SMRR – 4 dépôts confirmés (smrr.ma) ──────────────────────────────────
    _Point('SMRR – Tit Mellil (Casablanca)', 'Récupération PET • Papier • Carton',
        const LatLng(33.5800, -7.5000), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('SMRR – Dépôt Tanger', 'Récupération PET • Papier • Carton',
        const LatLng(35.7534, -5.7991), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('SMRR – Dépôt Agadir', 'Récupération PET • Papier • Carton',
        const LatLng(30.4278, -9.5981), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('SMRR – Dépôt Marrakech', 'Récupération PET • Papier • Carton',
        const LatLng(31.6700, -8.0600), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── LOGIPRO / TECMED – DEEE (Casablanca) ─────────────────────────────────
    _Point('Logipro DEEE – Maarif (Casablanca)', 'Électronique • Électroménager',
        const LatLng(33.5800, -7.6400), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('TECMED – Zone Industrielle (Casablanca)', 'Électronique • Électroménager',
        const LatLng(33.6500, -7.5000), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── PNDM – 15 centres complétés (pndm.environnement.gov.ma) ─────────────
    _Point('Centre de Valorisation Fès', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.9779, -4.9993), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Oujda', 'PNDM complété • Tri • Recyclage',
        const LatLng(34.6882, -1.9082), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation El Jadida', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.2340, -8.5041), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Essaouira', 'PNDM complété • Tri • Recyclage',
        const LatLng(31.5083, -9.7638), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Rabat / Oum Azza', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.8800, -6.7000), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Berkane', 'PNDM complété • Tri • Recyclage',
        const LatLng(34.9223, -2.3198), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Figuig', 'PNDM complété • Tri • Recyclage',
        const LatLng(32.1095, -1.2296), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Guelmim', 'PNDM complété • Tri • Recyclage',
        const LatLng(28.9871, -10.0572), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Al Hoceima', 'PNDM complété • Tri • Recyclage',
        const LatLng(35.2517, -3.9372), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Agadir', 'PNDM complété • Tri • Recyclage',
        const LatLng(30.4278, -9.5981), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Nador', 'PNDM complété • Tri • Recyclage',
        const LatLng(35.1699, -2.9303), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Dakhla', 'PNDM complété • Tri • Recyclage',
        const LatLng(23.6872, -15.9584), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Mohammedia', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.6866, -7.3828), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Laayoune', 'PNDM complété • Tri • Recyclage',
        const LatLng(27.1536, -13.2030), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Khouribga', 'PNDM complété • Tri • Recyclage',
        const LatLng(32.8862, -6.9083), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── PNDM – 7 centres en construction ─────────────────────────────────────
    _Point('Centre de Valorisation Tanger', 'PNDM en construction',
        const LatLng(35.7534, -5.7991), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Marrakech', 'PNDM en construction',
        const LatLng(31.6350, -8.0350), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Casablanca', 'PNDM en construction',
        const LatLng(33.6112, -7.5131), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Safi', 'PNDM en construction',
        const LatLng(32.2994, -9.2372), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Meknes', 'PNDM en construction',
        const LatLng(33.8957, -5.5555), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Ouarzazate', 'PNDM en construction',
        const LatLng(30.9335, -6.9370), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Ifrane', 'PNDM en construction',
        const LatLng(33.5228, -5.1067), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── PNDM – Nouveau programme 2023-2034 + capitales provinciales ───────────
    _Point('Centre de Valorisation Kenitra', 'PNDM programme',
        const LatLng(34.2610, -6.5802), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Beni Mellal', 'PNDM programme',
        const LatLng(32.3373, -6.3498), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Settat', 'PNDM programme',
        const LatLng(33.0010, -7.6196), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Tetouan', 'Capitale régionale',
        const LatLng(35.5889, -5.3626), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Taza', 'Capitale provinciale',
        const LatLng(34.2300, -3.9978), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Khemisset', 'Capitale provinciale',
        const LatLng(33.8200, -6.0700), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Khenifra', 'Capitale provinciale',
        const LatLng(32.9362, -5.6707), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Errachidia', 'Capitale régionale',
        const LatLng(31.9310, -4.4240), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Taroudant', 'Capitale provinciale',
        const LatLng(30.4703, -8.8756), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Tiznit', 'Capitale provinciale',
        const LatLng(29.6974, -9.7328), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Larache', 'Capitale provinciale',
        const LatLng(35.1932, -6.1545), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Ksar El-Kebir', 'Grande ville Nord',
        const LatLng(35.0011, -5.9094), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Chefchaouen', 'Capitale provinciale',
        const LatLng(35.1689, -5.2636), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Zagora', 'Capitale provinciale',
        const LatLng(30.3282, -5.8367), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Tan-Tan', 'Capitale provinciale',
        const LatLng(28.4377, -11.1025), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Smara', 'Capitale provinciale',
        const LatLng(26.7408, -11.6787), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Boujdour', 'Capitale provinciale',
        const LatLng(26.1266, -14.4849), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Taourirt', 'Capitale provinciale',
        const LatLng(34.4097, -2.8975), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Guercif', 'Prefecture',
        const LatLng(34.2284, -3.3585), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation El Kelaa Sraghna', 'Grande ville',
        const LatLng(32.0533, -7.4081), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Midelt', 'Capitale provinciale',
        const LatLng(32.6811, -4.7344), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Tinghir', 'Capitale provinciale',
        const LatLng(31.5148, -5.5285), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Sale', 'Grande ville',
        const LatLng(34.0372, -6.8100), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Inezgane', 'Grande ville Souss',
        const LatLng(30.3556, -9.5378), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Asilah', 'Ville cotiere Nord',
        const LatLng(35.4651, -6.0350), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Fnideq', 'Ville frontaliere Nord',
        const LatLng(35.8492, -5.3589), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── MARJANE – Collecte piles ──────────────────────────────────────────────
    _Point('Marjane Hay Hassani – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.5683, -7.6742), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Bernoussi – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.6100, -7.5500), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Californie – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.6190, -7.6470), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Sidi Maarouf – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.5450, -7.6500), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Anfa Place – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.5930, -7.6500), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Hay Riad – Collecte Piles (Rabat)', 'Piles • Batteries',
        const LatLng(33.9502, -6.8360), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Souissi – Collecte Piles (Rabat)', 'Piles • Batteries',
        const LatLng(33.9884, -6.8680), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Label\'Vie Agdal – Collecte Piles (Rabat)', 'Piles • Batteries',
        const LatLng(33.9830, -6.8550), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Tanger – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.7673, -5.8388), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Fès – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.9700, -5.0050), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Agadir – Collecte Piles', 'Piles • Batteries',
        const LatLng(30.4142, -9.5818), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Oujda – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.6860, -1.9140), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Meknès – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.8851, -5.5399), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Kénitra – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.2503, -6.5946), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane El Jadida – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.2267, -8.5095), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Béni Mellal – Collecte Piles', 'Piles • Batteries',
        const LatLng(32.3300, -6.3600), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Nador – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.1750, -2.9350), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Marrakech – Collecte Piles', 'Piles • Batteries',
        const LatLng(31.6215, -8.0017), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Mohammedia – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.6880, -7.3780), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Khémisset – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.8255, -6.0632), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Taza – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.2300, -3.9978), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Laâyoune – Collecte Piles', 'Piles • Batteries',
        const LatLng(27.1536, -13.2030), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Settat – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.0010, -7.6196), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Ménara – Collecte Piles (Marrakech)', 'Piles • Batteries',
        const LatLng(31.6380, -8.0350), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour City Mall – Collecte Piles (Tanger)', 'Piles • Batteries',
        const LatLng(35.7700, -5.8300), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Borj Fès – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.9950, -4.9900), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Label\'Vie Racine – Collecte Piles (Casablanca)', 'Piles • Batteries',
        const LatLng(33.5950, -7.6380), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Twin Center – Collecte Piles (Casablanca)', 'Piles • Batteries',
        const LatLng(33.5983, -7.6315), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Témara – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.9200, -6.9110), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Salé – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.0234, -6.7960), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Tétouan – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.5720, -5.3780), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),

    // ── PAPIER – Collecte papier/carton ──────────────────────────────────────
    _Point('SMRR – Collecte Papier/Carton (Casablanca)', 'Journaux • Cartons • Archives',
        const LatLng(33.5800, -7.5000), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('SMRR – Collecte Papier/Carton (Tanger)', 'Journaux • Cartons • Archives',
        const LatLng(35.7534, -5.7991), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('SMRR – Collecte Papier/Carton (Agadir)', 'Journaux • Cartons • Archives',
        const LatLng(30.4278, -9.5981), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('SMRR – Collecte Papier/Carton (Marrakech)', 'Journaux • Cartons • Archives',
        const LatLng(31.6700, -8.0600), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Rabat', 'Journaux • Cartons • Cahiers',
        const LatLng(33.9716, -6.8498), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Fès', 'Journaux • Cartons',
        const LatLng(33.9779, -4.9993), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Oujda', 'Journaux • Cartons',
        const LatLng(34.6882, -1.9082), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Meknès', 'Journaux • Cartons',
        const LatLng(33.8957, -5.5555), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Kénitra', 'Journaux • Cartons',
        const LatLng(34.2610, -6.5802), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier El Jadida', 'Journaux • Cartons',
        const LatLng(33.2340, -8.5041), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Béni Mellal', 'Journaux • Cartons',
        const LatLng(32.3373, -6.3498), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Nador', 'Journaux • Cartons',
        const LatLng(35.1699, -2.9303), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Tétouan', 'Journaux • Cartons',
        const LatLng(35.5889, -5.3626), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Safi', 'Journaux • Cartons',
        const LatLng(32.2994, -9.2372), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Essaouira', 'Journaux • Cartons',
        const LatLng(31.5083, -9.7638), AppColors.paper, Icons.article_outlined, 'Papier'),

    // ── ECO-TLC – Collecte textile ────────────────────────────────────────────
    _Point('Eco-TLC Casablanca – Textile', 'Vêtements • Chaussures',
        const LatLng(33.5600, -7.6750), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Rabat – Textile', 'Vêtements • Textiles',
        const LatLng(34.0400, -6.7900), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Marrakech – Textile', 'Vêtements • Chaussures',
        const LatLng(31.6400, -7.9900), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Tanger – Textile', 'Vêtements • Textiles',
        const LatLng(35.7600, -5.8200), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Fès – Textile', 'Vêtements • Textiles',
        const LatLng(34.0150, -4.9950), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Oujda – Textile', 'Vêtements • Chaussures',
        const LatLng(34.6795, -1.9050), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Agadir – Textile', 'Vêtements • Chaussures',
        const LatLng(30.3600, -9.5300), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),

    // ── COMPOST – Centres de compostage ──────────────────────────────────────
    _Point('Centre de Compost Casablanca', 'Déchets organiques • Compostage',
        const LatLng(33.6050, -7.5250), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Rabat', 'Déchets organiques • Compostage',
        const LatLng(33.9600, -6.8750), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Ifrane', 'Déchets organiques • Compostage',
        const LatLng(33.5250, -5.1100), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Fès', 'Déchets organiques • Compostage',
        const LatLng(34.0200, -4.9800), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Meknès', 'Déchets organiques • Compostage',
        const LatLng(33.8800, -5.5600), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),

    // ── DEEE – Collecte électronique ──────────────────────────────────────────
    _Point('Centre Collecte DEEE Tanger', 'Électronique • Électroménager',
        const LatLng(35.7400, -5.8100), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Marrakech', 'Électronique • Électroménager',
        const LatLng(31.6350, -8.0100), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Meknès', 'Électronique • Électroménager',
        const LatLng(33.9000, -5.5400), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Béni Mellal', 'Électronique • Câbles',
        const LatLng(32.3450, -6.3620), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Mohammedia', 'Électronique • Électroménager',
        const LatLng(33.6900, -7.3800), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── HUILES – Collecte huiles usagées ─────────────────────────────────────
    _Point('Eco Zalagh – Huiles usagées (Casablanca)', 'Huiles moteur • Industrielles',
        const LatLng(33.5050, -7.4750), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Eco Zalagh – Huiles usagées (Tanger)', 'Huiles moteur • Industrielles',
        const LatLng(35.6500, -5.9500), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Rabat', 'Huiles moteur usagées',
        const LatLng(33.9716, -6.8498), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Marrakech', 'Huiles moteur usagées',
        const LatLng(31.6350, -8.0350), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Agadir', 'Huiles moteur usagées',
        const LatLng(30.4278, -9.5981), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Fès', 'Huiles moteur usagées',
        const LatLng(33.9779, -4.9993), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Oujda', 'Huiles moteur usagées',
        const LatLng(34.6882, -1.9082), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Meknès', 'Huiles moteur usagées',
        const LatLng(33.8957, -5.5555), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),

    // ── MÉTAL – Collecte ferraille et métaux ──────────────────────────────────
    _Point('SMRR – Ferraille & Métaux (Casablanca)', 'Acier • Aluminium • Cuivre',
        const LatLng(33.5800, -7.5000), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('SMRR – Ferraille & Métaux (Tanger)', 'Acier • Aluminium • Cuivre',
        const LatLng(35.7534, -5.7991), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('SMRR – Ferraille & Métaux (Agadir)', 'Acier • Aluminium • Cuivre',
        const LatLng(30.4278, -9.5981), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('SMRR – Ferraille & Métaux (Marrakech)', 'Acier • Aluminium • Cuivre',
        const LatLng(31.6700, -8.0600), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Rabat', 'Ferraille • Acier • Aluminium',
        const LatLng(33.9716, -6.8498), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Fès', 'Ferraille • Acier • Aluminium',
        const LatLng(33.9779, -4.9993), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Oujda', 'Ferraille • Acier • Aluminium',
        const LatLng(34.6882, -1.9082), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Meknès', 'Ferraille • Acier • Aluminium',
        const LatLng(33.8957, -5.5555), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Kénitra', 'Ferraille • Acier • Aluminium',
        const LatLng(34.2610, -6.5802), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Béni Mellal', 'Ferraille • Acier',
        const LatLng(32.3373, -6.3498), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),

    // ── VERRE – Bacs PET / Verre ──────────────────────────────────────────────
    _Point('ECOVAL Bouskoura – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(33.4600, -7.6500), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Ben M\'Sik – Bacs PET', 'Bouteilles PET • Aluminium',
        const LatLng(33.5700, -7.5600), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Hay Nahda – Bacs PET (Rabat)', 'Bouteilles PET • Verre',
        const LatLng(33.9700, -6.8700), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Tanger – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(35.7800, -5.8500), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Fès – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(34.0000, -5.0000), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Marrakech – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(31.6300, -7.9900), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Agadir – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(30.4050, -9.5800), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Oujda – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(34.6900, -1.9100), AppColors.glass, Icons.recycling_rounded, 'Verre'),

    // ── DÉCHETTERIES municipales ──────────────────────────────────────────────
    _Point('Déchetterie Hay Mohammadi', 'Tous types de déchets',
        const LatLng(33.5932, -7.5617), AppColors.primary, Icons.delete_sweep_rounded, 'Tous'),
    _Point('Déchetterie Salé', 'Tous types de déchets',
        const LatLng(34.0372, -6.7888), AppColors.primary, Icons.delete_sweep_rounded, 'Tous'),
    _Point('Déchetterie Centrale Oujda', 'Tous types de déchets',
        const LatLng(34.6715, -1.9135), AppColors.primary, Icons.delete_sweep_rounded, 'Tous'),

    // ── CENTRES VÉRIFIÉS – Sources officielles ────────────────────────────────
    // COVAD : Route Oulad Haddou, Sidi Maarouf, Casablanca (covad.ma)
    _Point('COVAD – Collecte Batteries & Plastique (Casablanca)', 'Batteries usagées • Plastique • Papier',
        const LatLng(33.5350, -7.6100), const Color(0xFF546E7A), Icons.battery_0_bar_rounded, 'Piles'),
    // CER Maroc : Km10 Route d'El Jadida, Lissasfa, Casablanca (cermaroc.ma)
    _Point('CER Maroc – Lissasfa (Casablanca)', 'Déchets industriels • Recyclage complet',
        const LatLng(33.5200, -7.6500), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    // Centre de tri Sidi Bernoussi : inauguré par SM le Roi 2014, Zone Ind. Sidi Bernoussi
    _Point('Centre de Tri Sidi Bernoussi (Casablanca)', 'Plastique • Papier • Métal – inauguré 2014',
        const LatLng(33.5943, -7.5180), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // ECOMED M'Nabha : plus grand centre de tri d'Afrique, commune M'Nabha, Marrakech
    _Point('ECOMED – Centre de Tri M\'Nabha (Marrakech)', 'Plus grand centre de tri d\'Afrique – 280 500 t/an',
        const LatLng(31.5850, -7.9500), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION TANGER-TÉTOUAN-AL HOCEIMA – villes secondaires ────────────────
    _Point('Centre de Collecte Ouazzane', 'PNDM programme',
        const LatLng(34.7900, -5.5800), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Eco-point M\'Diq', 'Collecte sélective • Tri',
        const LatLng(35.6864, -5.3174), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Ksar El-Kébir (zone ind.)', 'Déchets ménagers • Tri',
        const LatLng(35.0100, -5.9000), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION L'ORIENTAL – villes secondaires ───────────────────────────────
    _Point('Centre de Collecte Driouch', 'PNDM programme – capitale provinciale',
        const LatLng(34.9795, -3.3921), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Jerada', 'PNDM programme – capitale provinciale',
        const LatLng(34.3066, -2.1604), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Zaio', 'Collecte déchets – province Nador',
        const LatLng(34.9363, -2.7374), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Beni Ansar', 'Zone franche – collecte DEEE',
        const LatLng(35.2680, -2.9310), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── RÉGION FÈS-MEKNÈS – villes secondaires ───────────────────────────────
    _Point('Centre de Collecte Taounate', 'PNDM programme – capitale provinciale',
        const LatLng(34.5378, -4.6400), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte El Hajeb', 'Capitale provinciale',
        const LatLng(33.6874, -5.3710), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Sefrou', 'Capitale provinciale',
        const LatLng(33.8304, -4.8340), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Boulemane', 'Capitale provinciale',
        const LatLng(33.3700, -4.7300), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Azrou', 'Sous-préfecture Ifrane',
        const LatLng(33.4367, -5.2226), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Compost Azrou', 'Déchets organiques • Compostage',
        const LatLng(33.4430, -5.2180), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Collecte Moulay Yacoub', 'Préfecture Fès',
        const LatLng(34.0892, -5.1792), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION RABAT-SALÉ-KÉNITRA – villes secondaires ───────────────────────
    _Point('Centre de Collecte Sidi Kacem', 'Capitale provinciale',
        const LatLng(34.2220, -5.7060), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Sidi Slimane', 'Capitale provinciale',
        const LatLng(34.2588, -5.9245), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Tiflet', 'Province Khémisset',
        const LatLng(33.8946, -6.3076), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Témara', 'Préfecture Skhirate-Témara',
        const LatLng(33.9213, -6.9073), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION BÉNI MELLAL-KHÉNIFRA – villes secondaires ─────────────────────
    _Point('Centre de Collecte Azilal', 'Capitale provinciale',
        const LatLng(31.9650, -6.5712), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Fquih Ben Salah', 'Capitale provinciale',
        const LatLng(32.5023, -6.6903), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION CASABLANCA-SETTAT – villes secondaires ─────────────────────────
    _Point('Centre de Collecte Benslimane', 'Capitale provinciale',
        const LatLng(33.6183, -7.1264), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Médiouna', 'Préfecture Casablanca',
        const LatLng(33.4508, -7.5152), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Sidi Bennour', 'Capitale provinciale',
        const LatLng(32.6554, -8.4213), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Nouaceur', 'Zone aéroportuaire – tri industriel',
        const LatLng(33.3669, -7.5831), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION MARRAKECH-SAFI – villes secondaires ────────────────────────────
    _Point('Centre de Collecte Chichaoua', 'Capitale provinciale',
        const LatLng(31.5379, -8.7641), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Ben Guerir', 'Capitale Rehamna',
        const LatLng(32.2326, -7.9560), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Youssoufia', 'Capitale provinciale',
        const LatLng(32.2436, -8.5305), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Tahanaout', 'Capitale Al Haouz',
        const LatLng(31.3559, -7.9607), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Kalaa des Sraghna', 'Grande ville – Marrakech-Safi',
        const LatLng(32.0533, -7.4081), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION DRÂA-TAFILALET – villes secondaires ───────────────────────────
    _Point('Centre de Collecte Rissani', 'Province Errachidia',
        const LatLng(31.2794, -4.2631), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Boumalne Dadès', 'Province Tinghir',
        const LatLng(31.3696, -5.9966), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Erfoud', 'Province Errachidia',
        const LatLng(31.4342, -4.2324), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Kelaat M\'Gouna', 'Province Tinghir',
        const LatLng(31.2330, -6.1271), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION SOUSS-MASSA – villes secondaires ──────────────────────────────
    _Point('Centre de Collecte Biougra', 'Province Chtouka Aït Baha',
        const LatLng(30.2053, -9.3817), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Tata', 'Capitale provinciale',
        const LatLng(29.7468, -7.9723), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Aït Melloul', 'Grande ville Souss',
        const LatLng(30.3358, -9.4987), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION GUELMIM-OUED NOUN – villes secondaires ─────────────────────────
    _Point('Centre de Collecte Assa', 'Province Assa-Zag',
        const LatLng(28.6070, -9.4310), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Zag', 'Province Assa-Zag',
        const LatLng(28.0103, -9.3270), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION LAÂYOUNE-SAKIA EL HAMRA – villes secondaires ──────────────────
    _Point('Centre de Collecte Tarfaya', 'Province Tarfaya',
        const LatLng(27.9369, -12.9210), AppColors.teal, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Collecte Es-Semara', 'Province Es-Semara',
        const LatLng(26.7408, -11.6787), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── RÉGION DAKHLA-OUED ED DAHAB – villes secondaires ─────────────────────
    _Point('Centre de Collecte Aousserd', 'Province Aousserd',
        const LatLng(22.5535, -14.3328), AppColors.teal, Icons.recycling_rounded, 'Tous'),

    // ── TRI SÉLECTIF – arrondissements de Casablanca ──────────────────────────
    _Point('Eco-point Aïn Sebaa (Casablanca)', 'Tri sélectif • Plastique • Papier',
        const LatLng(33.5932, -7.4890), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Eco-point Hay Hassani (Casablanca)', 'Tri sélectif • Multi-matériaux',
        const LatLng(33.5502, -7.6850), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Eco-point Aïn Chock (Casablanca)', 'Tri sélectif • Multi-matériaux',
        const LatLng(33.5383, -7.6222), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Eco-point Sbata (Casablanca)', 'Tri sélectif • Multi-matériaux',
        const LatLng(33.5618, -7.5700), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Eco-point Derb Sultan (Casablanca)', 'Tri sélectif • Multi-matériaux',
        const LatLng(33.5746, -7.6110), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre RecyPneus – Sidi Bernoussi (Casablanca)', 'Pneus usagés • Caoutchouc',
        const LatLng(33.5900, -7.5150), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── MARJANE / SUPERMARCHÉ – collecte piles villes moyennes ───────────────
    _Point('Marjane Khouribga – Collecte Piles', 'Piles • Batteries',
        const LatLng(32.8862, -6.9083), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Safi – Collecte Piles', 'Piles • Batteries',
        const LatLng(32.2994, -9.2372), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Errachidia – Collecte Piles', 'Piles • Batteries',
        const LatLng(31.9310, -4.4240), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Ouarzazate – Collecte Piles', 'Piles • Batteries',
        const LatLng(30.9335, -6.9370), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Label\'Vie Guelmim – Collecte Piles', 'Piles • Batteries',
        const LatLng(28.9871, -10.0572), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Label\'Vie Tiznit – Collecte Piles', 'Piles • Batteries',
        const LatLng(29.6974, -9.7328), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Taroudant – Collecte Piles', 'Piles • Batteries',
        const LatLng(30.4703, -8.8756), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Kénitra Hay Masira – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.2400, -6.5700), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Béni Mellal Hay Isly – Collecte Piles', 'Piles • Batteries',
        const LatLng(32.3450, -6.3500), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Fnideq – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.8492, -5.3589), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Label\'Vie Al Hoceima – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.2517, -3.9372), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Berkane – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.9223, -2.3198), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Chefchaouen – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.1689, -5.2636), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Label\'Vie Larache – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.1932, -6.1545), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Market Témara – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.9213, -6.9073), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Carrefour Market Salé Tabriquet – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.0600, -6.8150), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Essaouira – Collecte Piles', 'Piles • Batteries',
        const LatLng(31.5083, -9.7638), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane El Kelaa Sraghna – Collecte Piles', 'Piles • Batteries',
        const LatLng(32.0533, -7.4081), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),

    // ── TEXTILE – collecte villes secondaires ────────────────────────────────
    _Point('Eco-TLC Meknès – Textile', 'Vêtements • Textiles',
        const LatLng(33.8957, -5.5555), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Kénitra – Textile', 'Vêtements • Chaussures',
        const LatLng(34.2610, -6.5802), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC El Jadida – Textile', 'Vêtements • Textiles',
        const LatLng(33.2340, -8.5041), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Mohammedia – Textile', 'Vêtements • Textiles',
        const LatLng(33.6866, -7.3828), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Béni Mellal – Textile', 'Vêtements • Textiles',
        const LatLng(32.3373, -6.3498), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Settat – Textile', 'Vêtements • Chaussures',
        const LatLng(33.0010, -7.6196), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Nador – Textile', 'Vêtements • Textiles',
        const LatLng(35.1699, -2.9303), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Safi – Textile', 'Vêtements • Chaussures',
        const LatLng(32.2994, -9.2372), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Tétouan – Textile', 'Vêtements • Textiles',
        const LatLng(35.5889, -5.3626), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),

    // ── VERRE / PET – bacs villes moyennes ───────────────────────────────────
    _Point('ECOVAL Kénitra – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(34.2610, -6.5802), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Meknès – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(33.8957, -5.5555), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL El Jadida – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(33.2340, -8.5041), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Tétouan – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(35.5889, -5.3626), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Nador – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(35.1699, -2.9303), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Béni Mellal – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(32.3373, -6.3498), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Safi – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(32.2994, -9.2372), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Settat – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(33.0010, -7.6196), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('ECOVAL Mohammedia – Bacs PET', 'Bouteilles PET • Verre',
        const LatLng(33.6866, -7.3828), AppColors.glass, Icons.recycling_rounded, 'Verre'),

    // ── COMPOST – centres supplémentaires ────────────────────────────────────
    _Point('Centre de Compost Agadir', 'Déchets organiques • Compostage',
        const LatLng(30.3800, -9.5600), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Marrakech', 'Déchets organiques • Compostage',
        const LatLng(31.6300, -7.9750), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Oujda', 'Déchets organiques • Compostage',
        const LatLng(34.6882, -1.9082), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Kénitra', 'Déchets organiques • Compostage',
        const LatLng(34.2610, -6.5802), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Tanger', 'Déchets organiques • Compostage',
        const LatLng(35.7534, -5.7991), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost El Jadida', 'Déchets organiques • Compostage',
        const LatLng(33.2340, -8.5041), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Béni Mellal', 'Déchets organiques • Compostage',
        const LatLng(32.3373, -6.3498), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),

    // ── DEEE – centres supplémentaires ───────────────────────────────────────
    _Point('Centre Collecte DEEE Rabat', 'Électronique • Électroménager',
        const LatLng(33.9716, -6.8498), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Kénitra', 'Électronique • Câbles',
        const LatLng(34.2610, -6.5802), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Fès', 'Électronique • Électroménager',
        const LatLng(33.9779, -4.9993), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Agadir', 'Électronique • Électroménager',
        const LatLng(30.4278, -9.5981), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Oujda', 'Électronique • Câbles',
        const LatLng(34.6882, -1.9082), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Tétouan', 'Électronique • Électroménager',
        const LatLng(35.5889, -5.3626), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Nador', 'Électronique • Câbles',
        const LatLng(35.1699, -2.9303), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE El Jadida', 'Électronique • Électroménager',
        const LatLng(33.2340, -8.5041), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── HUILES – centres supplémentaires ────────────────────────────────────
    _Point('Collecte Huiles – Tanger (zone ind.)', 'Huiles moteur usagées',
        const LatLng(35.7600, -5.8150), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Kénitra', 'Huiles moteur usagées',
        const LatLng(34.2610, -6.5802), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Mohammedia (zone ind.)', 'Huiles moteur – zone industrielle',
        const LatLng(33.6866, -7.3828), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Béni Mellal', 'Huiles moteur usagées',
        const LatLng(32.3373, -6.3498), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Nador', 'Huiles moteur usagées',
        const LatLng(35.1699, -2.9303), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),

    // ── PLASTIQUE – couverture complète Maroc ────────────────────────────────
    // Casablanca (arrondissements)
    _Point('Centre Tri Plastique – Sidi Maarouf (Casablanca)', 'PET • PEHD • PP',
        const LatLng(33.5450, -7.6500), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Lissasfa (Casablanca)', 'PET • Emballages',
        const LatLng(33.5200, -7.6500), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Médiouna (Casablanca)', 'PET • PEHD',
        const LatLng(33.4508, -7.5152), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Hay Mohammadi (Casablanca)', 'Bouteilles PET • Emballages',
        const LatLng(33.5932, -7.5617), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Maarif (Casablanca)', 'Bouteilles PET • Plastique rigide',
        const LatLng(33.5800, -7.6400), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Rabat / Salé / Témara
    _Point('Centre Tri Plastique – Rabat (Youssoufia)', 'PET • PEHD • PP',
        const LatLng(33.9716, -6.8498), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Salé (Tabriquet)', 'PET • Emballages plastique',
        const LatLng(34.0372, -6.7960), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Témara', 'PET • PEHD • PP',
        const LatLng(33.9213, -6.9073), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Mohammedia / Kénitra / Settat
    _Point('Centre Tri Plastique – Mohammedia', 'PET • Emballages plastique',
        const LatLng(33.6866, -7.3828), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Kénitra', 'PET • PEHD',
        const LatLng(34.2610, -6.5802), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Settat', 'PET • Emballages',
        const LatLng(33.0010, -7.6196), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Berrechid', 'PET • PP • Emballages',
        const LatLng(33.2692, -7.5847), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Benslimane', 'Bouteilles PET • Plastique',
        const LatLng(33.6183, -7.1264), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Nord
    _Point('Centre Tri Plastique – Tanger (zone ind.)', 'PET • PEHD • PP',
        const LatLng(35.7700, -5.8200), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Tétouan', 'PET • Emballages plastique',
        const LatLng(35.5889, -5.3626), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Larache', 'Bouteilles PET • Plastique rigide',
        const LatLng(35.1932, -6.1545), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Al Hoceima', 'Bouteilles PET • Emballages',
        const LatLng(35.2517, -3.9372), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Chefchaouen', 'Bouteilles PET • Plastique',
        const LatLng(35.1689, -5.2636), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Fnideq', 'Bouteilles PET • Emballages',
        const LatLng(35.8492, -5.3589), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Asilah', 'Bouteilles PET • Plastique rigide',
        const LatLng(35.4651, -6.0350), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Oriental
    _Point('Centre Tri Plastique – Oujda', 'PET • PEHD • PP',
        const LatLng(34.6882, -1.9082), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Nador', 'Bouteilles PET • Emballages',
        const LatLng(35.1699, -2.9303), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Berkane', 'Bouteilles PET • Plastique',
        const LatLng(34.9223, -2.3198), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Driouch', 'Bouteilles PET • Emballages',
        const LatLng(34.9795, -3.3921), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Taourirt', 'Bouteilles PET • Plastique',
        const LatLng(34.4097, -2.8975), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Fès-Meknès
    _Point('Centre Tri Plastique – Fès (zone ind.)', 'PET • PEHD • PP',
        const LatLng(33.9700, -5.0050), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Meknès', 'PET • Emballages plastique',
        const LatLng(33.8957, -5.5555), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Taza', 'Bouteilles PET • Emballages',
        const LatLng(34.2300, -3.9978), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Sefrou', 'Bouteilles PET • Plastique',
        const LatLng(33.8304, -4.8340), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – El Hajeb', 'Bouteilles PET • Emballages',
        const LatLng(33.6874, -5.3710), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Centre / Béni Mellal-Khénifra
    _Point('Centre Tri Plastique – Béni Mellal', 'PET • PEHD • PP',
        const LatLng(32.3373, -6.3498), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Khénifra', 'Bouteilles PET • Emballages',
        const LatLng(32.9362, -5.6707), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Khouribga', 'Bouteilles PET • Plastique',
        const LatLng(32.8862, -6.9083), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Azilal', 'Bouteilles PET • Emballages',
        const LatLng(31.9650, -6.5712), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Fquih Ben Salah', 'Bouteilles PET • Plastique',
        const LatLng(32.5023, -6.6903), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Marrakech-Safi
    _Point('Centre Tri Plastique – Marrakech (Sidi Ghanem)', 'PET • PEHD • PP',
        const LatLng(31.6800, -8.0500), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Centre Tri Plastique – Safi', 'PET • Emballages plastique',
        const LatLng(32.2994, -9.2372), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Essaouira', 'Bouteilles PET • Emballages',
        const LatLng(31.5083, -9.7638), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – El Kelaa Sraghna', 'Bouteilles PET • Plastique',
        const LatLng(32.0533, -7.4081), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Youssoufia', 'Bouteilles PET • Emballages',
        const LatLng(32.2436, -8.5305), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // El Jadida / Sidi Bennour
    _Point('Centre Tri Plastique – El Jadida', 'PET • PEHD • PP',
        const LatLng(33.2340, -8.5041), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Sidi Bennour', 'Bouteilles PET • Plastique',
        const LatLng(32.6554, -8.4213), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Souss-Massa
    _Point('Centre Tri Plastique – Agadir (zone ind.)', 'PET • PEHD • PP',
        const LatLng(30.4100, -9.5600), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Inezgane', 'Bouteilles PET • Emballages',
        const LatLng(30.3556, -9.5378), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Taroudant', 'Bouteilles PET • Plastique',
        const LatLng(30.4703, -8.8756), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Tiznit', 'Bouteilles PET • Emballages',
        const LatLng(29.6974, -9.7328), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Biougra', 'Bouteilles PET • Plastique',
        const LatLng(30.2053, -9.3817), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Tata', 'Bouteilles PET • Emballages',
        const LatLng(29.7468, -7.9723), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Drâa-Tafilalet
    _Point('Bac Plastique – Errachidia', 'Bouteilles PET • Plastique',
        const LatLng(31.9310, -4.4240), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Ouarzazate', 'Bouteilles PET • Emballages',
        const LatLng(30.9335, -6.9370), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Zagora', 'Bouteilles PET • Plastique',
        const LatLng(30.3282, -5.8367), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Midelt', 'Bouteilles PET • Emballages',
        const LatLng(32.6811, -4.7344), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Tinghir', 'Bouteilles PET • Plastique',
        const LatLng(31.5148, -5.5285), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Guelmim / Sud
    _Point('Bac Plastique – Guelmim', 'Bouteilles PET • Emballages',
        const LatLng(28.9871, -10.0572), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Tan-Tan', 'Bouteilles PET • Plastique',
        const LatLng(28.4377, -11.1025), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Sidi Ifni', 'Bouteilles PET • Emballages',
        const LatLng(29.3786, -10.1735), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    // Provinces sahariennes
    _Point('Bac Plastique – Laâyoune', 'Bouteilles PET • Plastique',
        const LatLng(27.1536, -13.2030), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Dakhla', 'Bouteilles PET • Emballages',
        const LatLng(23.6872, -15.9584), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Smara', 'Bouteilles PET • Plastique',
        const LatLng(26.7408, -11.6787), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Bac Plastique – Boujdour', 'Bouteilles PET • Emballages',
        const LatLng(26.1266, -14.4849), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── MÉTAL – centres supplémentaires ──────────────────────────────────────
    _Point('Centre Collecte Métal – Settat', 'Ferraille • Acier',
        const LatLng(33.0010, -7.6196), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Mohammedia (zone ind.)', 'Ferraille – zone industrielle',
        const LatLng(33.6866, -7.3828), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Tanger (zone ind.)', 'Acier • Aluminium • Cuivre',
        const LatLng(35.7700, -5.8100), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Agadir (zone ind.)', 'Acier • Aluminium',
        const LatLng(30.4050, -9.5400), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Nador', 'Ferraille • Métaux',
        const LatLng(35.1699, -2.9303), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – El Jadida', 'Ferraille • Acier',
        const LatLng(33.2340, -8.5041), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Tétouan', 'Acier • Aluminium',
        const LatLng(35.5889, -5.3626), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── VERRE – couverture complète Maroc ────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Bac Verre – Rabat (Agdal)', 'Bouteilles verre • Bocaux',
        const LatLng(33.9830, -6.8550), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Salé', 'Bouteilles verre • Bocaux',
        const LatLng(34.0372, -6.7888), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Meknès', 'Bouteilles verre • Bocaux',
        const LatLng(33.8957, -5.5555), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Kénitra', 'Bouteilles verre • Bocaux',
        const LatLng(34.2610, -6.5802), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Mohammedia', 'Bouteilles verre • Bocaux',
        const LatLng(33.6866, -7.3828), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – El Jadida', 'Bouteilles verre • Bocaux',
        const LatLng(33.2340, -8.5041), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Essaouira', 'Bouteilles verre • Bocaux',
        const LatLng(31.5083, -9.7638), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Tétouan', 'Bouteilles verre • Bocaux',
        const LatLng(35.5889, -5.3626), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Nador', 'Bouteilles verre • Bocaux',
        const LatLng(35.1699, -2.9303), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Al Hoceima', 'Bouteilles verre • Bocaux',
        const LatLng(35.2517, -3.9372), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Béni Mellal', 'Bouteilles verre • Bocaux',
        const LatLng(32.3373, -6.3498), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Safi', 'Bouteilles verre • Bocaux',
        const LatLng(32.2994, -9.2372), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Settat', 'Bouteilles verre • Bocaux',
        const LatLng(33.0010, -7.6196), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Laâyoune', 'Bouteilles verre • Bocaux',
        const LatLng(27.1536, -13.2030), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Dakhla', 'Bouteilles verre • Bocaux',
        const LatLng(23.6872, -15.9584), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Errachidia', 'Bouteilles verre • Bocaux',
        const LatLng(31.9310, -4.4240), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Ouarzazate', 'Bouteilles verre • Bocaux',
        const LatLng(30.9335, -6.9370), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Khouribga', 'Bouteilles verre • Bocaux',
        const LatLng(32.8862, -6.9083), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Berkane', 'Bouteilles verre • Bocaux',
        const LatLng(34.9223, -2.3198), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Khémisset', 'Bouteilles verre • Bocaux',
        const LatLng(33.8200, -6.0700), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Taza', 'Bouteilles verre • Bocaux',
        const LatLng(34.2300, -3.9978), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Taroudant', 'Bouteilles verre • Bocaux',
        const LatLng(30.4703, -8.8756), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Tiznit', 'Bouteilles verre • Bocaux',
        const LatLng(29.6974, -9.7328), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Guelmim', 'Bouteilles verre • Bocaux',
        const LatLng(28.9871, -10.0572), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Tan-Tan', 'Bouteilles verre • Bocaux',
        const LatLng(28.4377, -11.1025), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Larache', 'Bouteilles verre • Bocaux',
        const LatLng(35.1932, -6.1545), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Chefchaouen', 'Bouteilles verre • Bocaux',
        const LatLng(35.1689, -5.2636), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Zagora', 'Bouteilles verre • Bocaux',
        const LatLng(30.3282, -5.8367), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Midelt', 'Bouteilles verre • Bocaux',
        const LatLng(32.6811, -4.7344), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Ifrane', 'Bouteilles verre • Bocaux',
        const LatLng(33.5228, -5.1067), AppColors.glass, Icons.recycling_rounded, 'Verre'),
    _Point('Bac Verre – Khénifra', 'Bouteilles verre • Bocaux',
        const LatLng(32.9362, -5.6707), AppColors.glass, Icons.recycling_rounded, 'Verre'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── PAPIER – couverture complète Maroc ───────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Centre Collecte Papier Casablanca (Aïn Sebaa)', 'Journaux • Cartons • Archives',
        const LatLng(33.5932, -7.4890), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Casablanca (Maarif)', 'Journaux • Cartons',
        const LatLng(33.5800, -7.6400), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Salé', 'Journaux • Cartons • Cahiers',
        const LatLng(34.0372, -6.7888), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Témara', 'Journaux • Cartons',
        const LatLng(33.9213, -6.9073), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Mohammedia', 'Journaux • Cartons',
        const LatLng(33.6866, -7.3828), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Tanger', 'Journaux • Cartons • Archives',
        const LatLng(35.7534, -5.7991), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Tétouan', 'Journaux • Cartons',
        const LatLng(35.5889, -5.3626), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Al Hoceima', 'Journaux • Cartons',
        const LatLng(35.2517, -3.9372), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Larache', 'Journaux • Cartons',
        const LatLng(35.1932, -6.1545), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Berkane', 'Journaux • Cartons',
        const LatLng(34.9223, -2.3198), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Nador', 'Journaux • Cartons',
        const LatLng(35.1699, -2.9303), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Taza', 'Journaux • Cartons',
        const LatLng(34.2300, -3.9978), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Ifrane', 'Journaux • Cartons',
        const LatLng(33.5228, -5.1067), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Agadir', 'Journaux • Cartons • Archives',
        const LatLng(30.4278, -9.5981), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Inezgane', 'Journaux • Cartons',
        const LatLng(30.3556, -9.5378), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Taroudant', 'Journaux • Cartons',
        const LatLng(30.4703, -8.8756), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Tiznit', 'Journaux • Cartons',
        const LatLng(29.6974, -9.7328), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Marrakech', 'Journaux • Cartons • Archives',
        const LatLng(31.6350, -8.0350), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Safi', 'Journaux • Cartons',
        const LatLng(32.2994, -9.2372), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier El Kelaa Sraghna', 'Journaux • Cartons',
        const LatLng(32.0533, -7.4081), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Khouribga', 'Journaux • Cartons',
        const LatLng(32.8862, -6.9083), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Khémisset', 'Journaux • Cartons',
        const LatLng(33.8200, -6.0700), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Settat', 'Journaux • Cartons',
        const LatLng(33.0010, -7.6196), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Khénifra', 'Journaux • Cartons',
        const LatLng(32.9362, -5.6707), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Azilal', 'Journaux • Cartons',
        const LatLng(31.9650, -6.5712), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Laâyoune', 'Journaux • Cartons',
        const LatLng(27.1536, -13.2030), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Dakhla', 'Journaux • Cartons',
        const LatLng(23.6872, -15.9584), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Guelmim', 'Journaux • Cartons',
        const LatLng(28.9871, -10.0572), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Errachidia', 'Journaux • Cartons',
        const LatLng(31.9310, -4.4240), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Centre Collecte Papier Ouarzazate', 'Journaux • Cartons',
        const LatLng(30.9335, -6.9370), AppColors.paper, Icons.article_outlined, 'Papier'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── COMPOST – couverture complète Maroc ──────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Centre de Compost Tétouan', 'Déchets organiques • Compostage',
        const LatLng(35.5889, -5.3626), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Al Hoceima', 'Déchets organiques • Compostage',
        const LatLng(35.2517, -3.9372), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Larache', 'Déchets organiques • Compostage',
        const LatLng(35.1932, -6.1545), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Nador', 'Déchets organiques • Compostage',
        const LatLng(35.1699, -2.9303), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Tanger (Gzenaya)', 'Déchets organiques • Compostage',
        const LatLng(35.6500, -5.9500), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Mohammedia', 'Déchets organiques • Compostage',
        const LatLng(33.6866, -7.3828), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Settat', 'Déchets organiques • Compostage',
        const LatLng(33.0010, -7.6196), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Béni Mellal', 'Déchets organiques • Compostage',
        const LatLng(32.3373, -6.3498), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost El Jadida', 'Déchets organiques • Compostage',
        const LatLng(33.2340, -8.5041), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Safi', 'Déchets organiques • Compostage',
        const LatLng(32.2994, -9.2372), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Essaouira', 'Déchets organiques • Compostage',
        const LatLng(31.5083, -9.7638), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost El Kelaa Sraghna', 'Déchets organiques • Compostage',
        const LatLng(32.0533, -7.4081), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Nador (biologique)', 'Déchets organiques • Compostage',
        const LatLng(35.1750, -2.9350), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Guelmim', 'Déchets organiques • Compostage',
        const LatLng(28.9871, -10.0572), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Errachidia', 'Déchets organiques • Compostage',
        const LatLng(31.9310, -4.4240), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Ouarzazate', 'Déchets organiques • Compostage',
        const LatLng(30.9335, -6.9370), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Laâyoune', 'Déchets organiques • Compostage',
        const LatLng(27.1536, -13.2030), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Dakhla', 'Déchets organiques • Compostage',
        const LatLng(23.6872, -15.9584), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Kénitra', 'Déchets organiques • Compostage',
        const LatLng(34.2610, -6.5802), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Salé', 'Déchets organiques • Compostage',
        const LatLng(34.0372, -6.7888), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Khémisset', 'Déchets organiques • Compostage',
        const LatLng(33.8200, -6.0700), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Khouribga', 'Déchets organiques • Compostage',
        const LatLng(32.8862, -6.9083), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Taroudant', 'Déchets organiques • Compostage',
        const LatLng(30.4703, -8.8756), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Centre de Compost Tiznit', 'Déchets organiques • Compostage',
        const LatLng(29.6974, -9.7328), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── ÉLECTRONIQUE / DEEE – couverture complète Maroc ──────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Centre Collecte DEEE Casablanca (Lissasfa)', 'DEEE • Gros électroménager',
        const LatLng(33.5200, -7.6500), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Casablanca (Aïn Sebaa)', 'Électronique • Câbles',
        const LatLng(33.5932, -7.4890), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Tanger (zone ind.)', 'Électronique • Électroménager',
        const LatLng(35.7600, -5.8100), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Tétouan', 'Électronique • Électroménager',
        const LatLng(35.5889, -5.3626), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Al Hoceima', 'Électronique • Câbles',
        const LatLng(35.2517, -3.9372), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Larache', 'Électronique • Électroménager',
        const LatLng(35.1932, -6.1545), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Nador', 'Électronique • Câbles',
        const LatLng(35.1699, -2.9303), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Oujda', 'Électronique • Électroménager',
        const LatLng(34.6882, -1.9082), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Berkane', 'Électronique • Câbles',
        const LatLng(34.9223, -2.3198), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Kénitra', 'Électronique • Électroménager',
        const LatLng(34.2610, -6.5802), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Salé', 'Électronique • Câbles',
        const LatLng(34.0372, -6.7888), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Khémisset', 'Électronique • Électroménager',
        const LatLng(33.8200, -6.0700), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Meknès', 'Électronique • Électroménager',
        const LatLng(33.8957, -5.5555), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Fès', 'Électronique • Câbles',
        const LatLng(33.9779, -4.9993), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Taza', 'Électronique • Électroménager',
        const LatLng(34.2300, -3.9978), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Settat', 'Électronique • Câbles',
        const LatLng(33.0010, -7.6196), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE El Jadida', 'Électronique • Électroménager',
        const LatLng(33.2340, -8.5041), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Marrakech (Sidi Ghanem)', 'DEEE • Gros électroménager',
        const LatLng(31.6800, -8.0500), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Safi', 'Électronique • Câbles',
        const LatLng(32.2994, -9.2372), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Essaouira', 'Électronique • Électroménager',
        const LatLng(31.5083, -9.7638), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Béni Mellal', 'Électronique • Câbles',
        const LatLng(32.3373, -6.3498), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Khouribga', 'Électronique • Électroménager',
        const LatLng(32.8862, -6.9083), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Khénifra', 'Électronique • Câbles',
        const LatLng(32.9362, -5.6707), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Agadir', 'DEEE • Gros électroménager',
        const LatLng(30.4278, -9.5981), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Inezgane', 'Électronique • Câbles',
        const LatLng(30.3556, -9.5378), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Taroudant', 'Électronique • Électroménager',
        const LatLng(30.4703, -8.8756), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Tiznit', 'Électronique • Câbles',
        const LatLng(29.6974, -9.7328), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Guelmim', 'Électronique • Électroménager',
        const LatLng(28.9871, -10.0572), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Laâyoune', 'Électronique • Câbles',
        const LatLng(27.1536, -13.2030), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Dakhla', 'Électronique • Électroménager',
        const LatLng(23.6872, -15.9584), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Errachidia', 'Électronique • Câbles',
        const LatLng(31.9310, -4.4240), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Ouarzazate', 'Électronique • Électroménager',
        const LatLng(30.9335, -6.9370), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre Collecte DEEE Mohammedia', 'DEEE • Zone industrielle',
        const LatLng(33.6866, -7.3828), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── TEXTILE – couverture complète Maroc ──────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Eco-TLC Al Hoceima – Textile', 'Vêtements • Chaussures',
        const LatLng(35.2517, -3.9372), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Larache – Textile', 'Vêtements • Textiles',
        const LatLng(35.1932, -6.1545), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Chefchaouen – Textile', 'Vêtements • Chaussures',
        const LatLng(35.1689, -5.2636), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Berkane – Textile', 'Vêtements • Textiles',
        const LatLng(34.9223, -2.3198), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Kénitra – Textile', 'Vêtements • Chaussures',
        const LatLng(34.2610, -6.5802), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Salé – Textile', 'Vêtements • Textiles',
        const LatLng(34.0372, -6.7888), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Rabat – Textile (Hay Riad)', 'Vêtements • Textiles',
        const LatLng(33.9502, -6.8360), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Khémisset – Textile', 'Vêtements • Chaussures',
        const LatLng(33.8200, -6.0700), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Meknès – Textile', 'Vêtements • Textiles',
        const LatLng(33.8957, -5.5555), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Khouribga – Textile', 'Vêtements • Chaussures',
        const LatLng(32.8862, -6.9083), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC El Jadida – Textile', 'Vêtements • Textiles',
        const LatLng(33.2340, -8.5041), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Mohammedia – Textile', 'Vêtements • Chaussures',
        const LatLng(33.6866, -7.3828), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Settat – Textile', 'Vêtements • Textiles',
        const LatLng(33.0010, -7.6196), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Béni Mellal – Textile', 'Vêtements • Chaussures',
        const LatLng(32.3373, -6.3498), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC El Kelaa Sraghna – Textile', 'Vêtements • Textiles',
        const LatLng(32.0533, -7.4081), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Safi – Textile', 'Vêtements • Chaussures',
        const LatLng(32.2994, -9.2372), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Essaouira – Textile', 'Vêtements • Textiles',
        const LatLng(31.5083, -9.7638), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Nador – Textile', 'Vêtements • Chaussures',
        const LatLng(35.1699, -2.9303), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Tétouan – Textile', 'Vêtements • Textiles',
        const LatLng(35.5889, -5.3626), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Inezgane – Textile', 'Vêtements • Chaussures',
        const LatLng(30.3556, -9.5378), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Taroudant – Textile', 'Vêtements • Textiles',
        const LatLng(30.4703, -8.8756), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Tiznit – Textile', 'Vêtements • Chaussures',
        const LatLng(29.6974, -9.7328), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Guelmim – Textile', 'Vêtements • Textiles',
        const LatLng(28.9871, -10.0572), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Laâyoune – Textile', 'Vêtements • Chaussures',
        const LatLng(27.1536, -13.2030), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Eco-TLC Dakhla – Textile', 'Vêtements • Textiles',
        const LatLng(23.6872, -15.9584), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── HUILES – couverture complète Maroc ───────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Collecte Huiles – Casablanca (Maarif)', 'Huiles moteur • Alimentaires',
        const LatLng(33.5800, -7.6400), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Casablanca (Ain Sebaa)', 'Huiles moteur usagées',
        const LatLng(33.5932, -7.4890), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Rabat', 'Huiles moteur usagées',
        const LatLng(33.9716, -6.8498), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Salé', 'Huiles moteur usagées',
        const LatLng(34.0372, -6.7888), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Kénitra', 'Huiles moteur usagées',
        const LatLng(34.2610, -6.5802), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Tanger', 'Huiles moteur • Industrielles',
        const LatLng(35.7534, -5.7991), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Tétouan', 'Huiles moteur usagées',
        const LatLng(35.5889, -5.3626), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Nador', 'Huiles moteur usagées',
        const LatLng(35.1699, -2.9303), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Al Hoceima', 'Huiles moteur usagées',
        const LatLng(35.2517, -3.9372), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Berkane', 'Huiles moteur usagées',
        const LatLng(34.9223, -2.3198), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Settat', 'Huiles moteur usagées',
        const LatLng(33.0010, -7.6196), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – El Jadida', 'Huiles moteur usagées',
        const LatLng(33.2340, -8.5041), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Safi', 'Huiles moteur • Industrielles',
        const LatLng(32.2994, -9.2372), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Essaouira', 'Huiles moteur usagées',
        const LatLng(31.5083, -9.7638), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Béni Mellal', 'Huiles moteur usagées',
        const LatLng(32.3373, -6.3498), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Khouribga', 'Huiles moteur • Industrielles',
        const LatLng(32.8862, -6.9083), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Marrakech', 'Huiles moteur usagées',
        const LatLng(31.6350, -8.0350), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Agadir', 'Huiles moteur • Industrielles',
        const LatLng(30.4278, -9.5981), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Inezgane', 'Huiles moteur usagées',
        const LatLng(30.3556, -9.5378), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Taroudant', 'Huiles moteur usagées',
        const LatLng(30.4703, -8.8756), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Tiznit', 'Huiles moteur usagées',
        const LatLng(29.6974, -9.7328), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Guelmim', 'Huiles moteur usagées',
        const LatLng(28.9871, -10.0572), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Laâyoune', 'Huiles moteur usagées',
        const LatLng(27.1536, -13.2030), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Dakhla', 'Huiles moteur usagées',
        const LatLng(23.6872, -15.9584), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Errachidia', 'Huiles moteur usagées',
        const LatLng(31.9310, -4.4240), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Ouarzazate', 'Huiles moteur usagées',
        const LatLng(30.9335, -6.9370), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),
    _Point('Collecte Huiles – Meknès', 'Huiles moteur • Industrielles',
        const LatLng(33.8957, -5.5555), const Color(0xFF4E342E), Icons.oil_barrel_rounded, 'Huiles'),

    // ══════════════════════════════════════════════════════════════════════════
    // ── MÉTAL – couverture complète Maroc ────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    _Point('Centre Collecte Métal – Rabat (zone ind.)', 'Ferraille • Acier • Aluminium',
        const LatLng(33.9600, -6.8600), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Salé', 'Ferraille • Acier',
        const LatLng(34.0372, -6.7888), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Témara', 'Ferraille • Acier',
        const LatLng(33.9213, -6.9073), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Tanger (Gzenaya)', 'Acier • Aluminium • Cuivre',
        const LatLng(35.6500, -5.9500), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Tétouan', 'Ferraille • Acier',
        const LatLng(35.5889, -5.3626), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Al Hoceima', 'Ferraille • Métaux',
        const LatLng(35.2517, -3.9372), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Larache', 'Ferraille • Acier',
        const LatLng(35.1932, -6.1545), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Nador', 'Ferraille • Acier • Aluminium',
        const LatLng(35.1699, -2.9303), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Berkane', 'Ferraille • Métaux',
        const LatLng(34.9223, -2.3198), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Taza', 'Ferraille • Acier',
        const LatLng(34.2300, -3.9978), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Meknès', 'Acier • Aluminium • Cuivre',
        const LatLng(33.8957, -5.5555), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Ifrane', 'Ferraille • Acier',
        const LatLng(33.5228, -5.1067), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Khémisset', 'Ferraille • Acier',
        const LatLng(33.8200, -6.0700), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Marrakech (zone ind.)', 'Acier • Aluminium • Cuivre',
        const LatLng(31.6800, -8.0500), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Safi (phosphates)', 'Acier • Métaux industriels',
        const LatLng(32.2994, -9.2372), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Essaouira', 'Ferraille • Acier',
        const LatLng(31.5083, -9.7638), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Khouribga (OCP)', 'Acier • Métaux industriels',
        const LatLng(32.8862, -6.9083), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Khénifra', 'Ferraille • Acier',
        const LatLng(32.9362, -5.6707), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Azilal', 'Ferraille • Métaux',
        const LatLng(31.9650, -6.5712), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Inezgane', 'Ferraille • Acier',
        const LatLng(30.3556, -9.5378), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Taroudant', 'Ferraille • Métaux',
        const LatLng(30.4703, -8.8756), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Tiznit', 'Ferraille • Acier',
        const LatLng(29.6974, -9.7328), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Guelmim', 'Ferraille • Métaux',
        const LatLng(28.9871, -10.0572), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Laâyoune', 'Acier • Aluminium',
        const LatLng(27.1536, -13.2030), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Dakhla', 'Ferraille • Métaux',
        const LatLng(23.6872, -15.9584), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Errachidia', 'Ferraille • Acier',
        const LatLng(31.9310, -4.4240), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
    _Point('Centre Collecte Métal – Ouarzazate', 'Ferraille • Métaux',
        const LatLng(30.9335, -6.9370), const Color(0xFF546E7A), Icons.hardware_rounded, 'Métal'),
  ];

  List<_Point> get _allPoints {
    final source = _dynamicPoints.isNotEmpty ? _dynamicPoints : _staticPoints;
    final seenCoordCat = <String>{};
    final seenNames = <String>{};
    final result = <_Point>[];
    for (final p in source) {
      final coordKey = '${p.latLng.latitude.toStringAsFixed(4)},${p.latLng.longitude.toStringAsFixed(4)},${p.category}';
      final nameKey = p.name.toLowerCase().trim();
      if (!seenCoordCat.contains(coordKey) && !seenNames.contains(nameKey)) {
        seenCoordCat.add(coordKey);
        seenNames.add(nameKey);
        result.add(p);
      }
    }
    return result;
  }

  List<_Point> get _visiblePoints {
    var pts = _allPoints.toList();
    if (_selected != 'Tous') {
      pts = pts.where((p) => p.category == _selected).toList();
    }
    final q = _search.text.toLowerCase();
    if (q.isNotEmpty) {
      pts = pts
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.label.toLowerCase().contains(q))
          .toList();
    }
    // Trier par distance réelle si la position utilisateur est disponible
    if (_userPosition != null) {
      const calc = Distance();
      pts.sort((a, b) {
        final da = calc(_userPosition!, a.latLng);
        final db = calc(_userPosition!, b.latLng);
        return da.compareTo(db);
      });
    }
    return pts;
  }

  // Points dans un rayon de 5 km autour de l'utilisateur
  List<_Point> get _nearbyPoints {
    if (_userPosition == null) return [];
    const calc = Distance();
    return _visiblePoints
        .where((p) => calc(_userPosition!, p.latLng) <= 5000)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _markerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _markerCtrl.forward();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengesProvider.notifier).openMap();
    });
  }

  @override
  void dispose() {
    _markerCtrl.dispose();
    _pulseCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } catch (_) {
        // Timeout ou erreur GPS — utiliser la dernière position connue
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      final userLoc = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;

      setState(() {
        _userPosition = userLoc;
        _isLoadingLocation = false;
        _tapped = null;
      });
      _mapController.move(userLoc, 14.5);
      _fetchNearbyPoints(userLoc);
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _fetchNearbyPoints(LatLng center) async {
    // Points dynamiques désactivés — les centres statiques couvrent tout le Maroc.
    if (mounted) setState(() => _isLoadingPoints = false);
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 15.0);
    } else {
      _initLocation();
    }
  }

  String _distanceText(_Point point, String lang) {
    if (_userPosition == null) return '';
    const d = Distance();
    final meters = d(_userPosition!, point.latLng);
    if (lang == 'ar') {
      if (meters < 1000) return '${meters.round()} م';
      return '${(meters / 1000).toStringAsFixed(1)} كم';
    }
    if (lang == 'es') {
      if (meters < 1000) return '${meters.round()} m';
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _filterLabel(String key, AppStrings s) {
    switch (key) {
      case 'Tous':        return s.catAll;
      case 'Plastique':   return s.catPlastic;
      case 'Verre':       return s.catGlass;
      case 'Papier':      return s.catPaper;
      case 'Compost':     return s.catCompost;
      case 'Piles':       return s.catBatteries;
      case 'Électronique': return s.catElectronic;
      case 'Textile':     return s.catTextile;
      case 'Huiles':      return s.catOil;
      case 'Métal':       return s.catMetal;
      default:            return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final visible = _visiblePoints;
    final all = _allPoints;

    return Scaffold(
      body: Stack(
        children: [
          // Carte OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(31.79, -7.09),
              initialZoom: 5.5,
              minZoom: 5,
              maxZoom: 19,
              onTap: (tap, ll) => setState(() => _tapped = null),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecoscan.ecoscan',
                maxZoom: 19,
              ),

              // Marqueur position utilisateur
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (ctx, child) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 20 + _pulseCtrl.value * 30,
                              height: 20 + _pulseCtrl.value * 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withValues(
                                    alpha: 0.18 - _pulseCtrl.value * 0.14),
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.45),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Marqueurs points de recyclage
              MarkerLayer(
                markers: List.generate(visible.length, (i) {
                  final p = visible[i];
                  final originalIdx = all.indexOf(p);
                  return Marker(
                    point: p.latLng,
                    width: 56,
                    height: 68,
                    child: GestureDetector(
                      onTap: () {
                        setState(() =>
                            _tapped = _tapped == originalIdx ? null : originalIdx);
                        _mapController.move(p.latLng, 15.0);
                      },
                      child: AnimatedBuilder(
                        animation: _markerCtrl,
                        builder: (_, child) {
                          final delay = i / math.max(visible.length, 1);
                          final progress =
                              ((_markerCtrl.value - delay).clamp(0.0, 1.0) /
                                      (1.0 - delay + 0.001))
                                  .clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, -20 * (1 - progress)),
                            child: Opacity(opacity: progress, child: child),
                          );
                        },
                        child: _MarkerPin(
                          color: p.color,
                          icon: p.icon,
                          selected: _tapped == originalIdx,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          // Overlay supérieur : barre de recherche + filtres
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: [
                      // Barre de recherche
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: s.searchCollection,
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.textSecondary),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_search.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18),
                                    onPressed: () {
                                      _search.clear();
                                      setState(() {});
                                    },
                                  ),
                                if (_isLoadingPoints)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 14),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary),
                                    ),
                                  ),
                              ],
                            ),
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                      const SizedBox(height: 10),

                      // Filtres par catégorie
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, idx) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final f = _filters[i];
                            final active = _selected == f;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected = f;
                                  _tapped = null;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkCard
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.07),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _filterLabel(f, s),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
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
                              ),
                            )
                                .animate(delay: (i * 50).ms)
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: -0.1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Carte info du point sélectionné
                if (_tapped != null && _tapped! < all.length)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _InfoCard(
                      point: all[_tapped!],
                      isDark: isDark,
                      lang: ref.watch(localeProvider).languageCode,
                      distance: _distanceText(all[_tapped!], ref.read(localeProvider).languageCode),
                      s: s,
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
                  ),

                // Légende + compteur
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard.withValues(alpha: 0.95)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _LegendItem(AppColors.primary, s.legendGeneral),
                            _LegendItem(AppColors.plastic, s.catPlastic),
                            _LegendItem(AppColors.glass, s.catGlass),
                            _LegendItem(const Color(0xFF795548), s.catCompost),
                            _LegendItem(AppColors.electronics, s.legendElectro),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _userPosition != null
                                  ? s.pointsInRadius(_nearbyPoints.length)
                                  : s.pointsAvailable(visible.length),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ),
              ],
            ),
          ),

          // Contrôles zoom + localisation — remontés pour ne pas chevaucher "Y aller"
          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              children: [
                _MapBtn(
                  icon: Icons.add_rounded,
                  onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1),
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1),
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: _isLoadingLocation
                      ? Icons.location_searching_rounded
                      : (_userPosition != null
                          ? Icons.my_location_rounded
                          : Icons.location_off_rounded),
                  onTap: _centerOnUser,
                  accent: _userPosition != null ? Colors.blue : null,
                ),
              ],
            ),
          ),

          // Indicateur de localisation en cours
          if (_isLoadingLocation)
            Positioned(
              top: 155,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        s.locatingText,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bouton carte ──────────────────────────────────────────────────────────────

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;
  const _MapBtn({required this.icon, required this.onTap, this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon,
            size: 20, color: accent ?? AppColors.textPrimary),
      ),
    );
  }
}

// ── Épingle de marqueur ───────────────────────────────────────────────────────

class _MarkerPin extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool selected;
  const _MarkerPin({required this.color, required this.icon, required this.selected});

  @override
  State<_MarkerPin> createState() => _MarkerPinState();
}

class _MarkerPinState extends State<_MarkerPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.selected ? 50 : 40,
            height: widget.selected ? 50 : 40,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white, width: widget.selected ? 3 : 2),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.45),
                  blurRadius: widget.selected ? 18 : 8,
                  spreadRadius: widget.selected ? 3 : 0,
                ),
              ],
            ),
            child: Icon(widget.icon,
                color: Colors.white, size: widget.selected ? 24 : 18),
          ),
          CustomPaint(
            painter: _PinTail(widget.color),
            size: const Size(10, 8),
          ),
        ],
      ),
    );
  }
}

class _PinTail extends CustomPainter {
  final Color color;
  const _PinTail(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PinTail old) => old.color != color;
}

// ── Carte info point sélectionné ─────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final _Point point;
  final bool isDark;
  final String distance;
  final String lang;
  final AppStrings s;
  const _InfoCard(
      {required this.point, required this.isDark, required this.distance,
       required this.lang, required this.s});

  Future<void> _openMaps() async {
    final lat = point.latLng.latitude;
    final lng = point.latLng.longitude;
    final name = Uri.encodeComponent(point.name);
    try {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng'
        '&destination_place_name=$name'
        '&travelmode=driving',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
      // Fallback: geo URI (ouvre l'app carte par défaut)
      final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
      if (await canLaunchUrl(geo)) {
        await launchUrl(geo, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Si aucune app carte n'est installée, ignorer silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.97)
            : Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: point.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(point.icon, color: point.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.nameFor(lang),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  point.labelFor(lang),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        point.displayHoursFor(lang),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (distance.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        const Icon(Icons.near_me_rounded,
                            size: 11, color: Colors.blue),
                        const SizedBox(width: 3),
                        Text(
                          lang == 'ar'
                              ? '${point.displayAddressFor(lang)} · $distance'
                              : '$distance · ${point.displayAddressFor(lang)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _openMaps,
            icon: const Icon(Icons.directions_rounded, size: 14),
            label: Text(s.directions),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item de légende ───────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Modèle de point ───────────────────────────────────────────────────────────

class _Point {
  final String name;
  final String label;
  final LatLng latLng;
  final Color color;
  final IconData icon;
  final String category;

  const _Point(
      this.name, this.label, this.latLng, this.color, this.icon, this.category);

  String get displayHours => displayHoursFor('fr');

  String displayHoursFor(String lang) {
    final n = name.toLowerCase();
    if (n.contains('marjane')) {
      switch (lang) {
        case 'ar': return '7 أيام/7  ·  9:00 – 22:00';
        case 'es': return '7d/7  ·  9:00 – 22:00';
        case 'en': return '7d/7  ·  9:00 am – 10:00 pm';
        default:   return '7j/7  ·  9h00 – 22h00';
      }
    }
    if (n.contains('geocycle') || n.contains('eco zalagh') || n.contains('logipro')) {
      switch (lang) {
        case 'ar': return 'الإثنين – الجمعة  ·  8:00 – 17:00';
        case 'es': return 'Lun – Vie  ·  8:00 – 17:00';
        case 'en': return 'Mon – Fri  ·  8:00 am – 5:00 pm';
        default:   return 'Lun – Ven  ·  8h00 – 17h00';
      }
    }
    if (category == 'Verre' || category == 'Plastique' ||
        category == 'Papier' || category == 'Compost') {
      return lang == 'ar' ? '24/7' : '24h/24  ·  7j/7';
    }
    if (category == 'Textile') {
      switch (lang) {
        case 'ar': return 'الإثنين – السبت  ·  9:00 – 18:00';
        case 'es': return 'Lun – Sáb  ·  9:00 – 18:00';
        case 'en': return 'Mon – Sat  ·  9:00 am – 6:00 pm';
        default:   return 'Lun – Sam  ·  9h00 – 18h00';
      }
    }
    if (category == 'Piles') {
      switch (lang) {
        case 'ar': return 'حسب ساعات المتجر';
        case 'es': return 'Según horario de tienda';
        case 'en': return 'According to store hours';
        default:   return 'Selon horaires du magasin';
      }
    }
    if (n.contains('déchetterie')) {
      switch (lang) {
        case 'ar': return 'الإثنين – السبت  ·  8:00 – 16:00';
        case 'es': return 'Lun – Sáb  ·  8:00 – 16:00';
        case 'en': return 'Mon – Sat  ·  8:00 am – 4:00 pm';
        default:   return 'Lun – Sam  ·  8h00 – 16h00';
      }
    }
    switch (lang) {
      case 'ar': return 'الإثنين – السبت  ·  8:00 – 17:00';
      case 'es': return 'Lun – Sáb  ·  8:00 – 17:00';
      case 'en': return 'Mon – Sat  ·  8:00 am – 5:00 pm';
      default:   return 'Lun – Sam  ·  8h00 – 17h00';
    }
  }

  // ── Traduction des noms de points ──────────────────────────────────────────
  String nameFor(String lang) {
    if (lang == 'fr') return name;

    const prefixes = <String, List<String>>{
      // fr → [en, ar, es]
      'Centre de Valorisation': ['Valorization Center',         'مركز تثمين',                    'Centro de Valorización'],
      'Centre de Collecte':     ['Collection Center',           'مركز الجمع',                    'Centro de Recogida'],
      'Centre de Compost':      ['Composting Center',           'مركز التسميد',                  'Centro de Compostaje'],
      'Centre de Tri':          ['Sorting Center',              'مركز الفرز',                    'Centro de Clasificación'],
      'Centre Tri Plastique':   ['Plastic Sorting Center',      'مركز فرز البلاستيك',            'Centro de Clasificación Plástico'],
      'Centre Collecte Papier': ['Paper Collection Center',     'مركز جمع الورق',                'Centro de Recogida de Papel'],
      'Centre Collecte DEEE':   ['E-Waste Collection Center',   'مركز جمع النفايات الإلكترونية', 'Centro de Recogida RAEE'],
      'Centre Collecte Métal':  ['Metal Collection Center',     'مركز جمع المعادن',              'Centro de Recogida de Metal'],
      'Bac Plastique':          ['Plastic Bin',                 'حاوية بلاستيك',                 'Contenedor de Plástico'],
      'Bac Verre':              ['Glass Bin',                   'حاوية زجاج',                    'Contenedor de Vidrio'],
      'Eco-point':              ['Eco-point',                   'نقطة إيكو',                     'Eco-punto'],
      'Collecte Huiles':        ['Used Oil Collection',         'جمع الزيوت المستعملة',          'Recogida de Aceites'],
      'Déchetterie':            ['Waste Collection Site',       'موقع جمع النفايات',             'Punto Limpio'],
    };

    const suffixes = <String, List<String>>{
      '– Collecte Piles':         ['– Battery Collection',     '– جمع البطاريات',           '– Recogida de Pilas'],
      '– Bacs PET':               ['– PET Bins',               '– حاويات PET',              '– Contenedores PET'],
      '– Textile':                ['– Textile',                '– نسيج',                    '– Textil'],
      '– Ferraille & Métaux':     ['– Scrap & Metals',         '– خردة ومعادن',             '– Chatarra y Metales'],
      '– Collecte Papier/Carton': ['– Paper/Cardboard',        '– جمع الورق والكرتون',      '– Recogida Papel/Cartón'],
      '– Huiles usagées':         ['– Used Oil',               '– زيوت مستعملة',            '– Aceites Usados'],
      '(zone ind.)':              ['(ind. zone)',               '(المنطقة الصناعية)',        '(zona ind.)'],
      'zone ind.':                ['ind. zone',                 'المنطقة الصناعية',          'zona ind.'],
    };

    // Noms de villes/quartiers en arabe et espagnol
    // fr → [en (unchanged), ar, es]
    const cities = <String, List<String>>{
      'Casablanca':         ['Casablanca',    'الدار البيضاء',   'Casablanca'],
      'Rabat':              ['Rabat',         'الرباط',          'Rabat'],
      'Salé':               ['Salé',          'سلا',             'Salé'],
      'Témara':             ['Témara',        'تمارة',           'Témara'],
      'Marrakech':          ['Marrakech',     'مراكش',           'Marrakech'],
      'Tanger':             ['Tanger',        'طنجة',            'Tánger'],
      'Fès':                ['Fes',           'فاس',             'Fez'],
      'Meknès':             ['Meknes',        'مكناس',           'Mequinez'],
      'Oujda':              ['Oujda',         'وجدة',            'Uchda'],
      'Agadir':             ['Agadir',        'أكادير',          'Agadir'],
      'Kénitra':            ['Kénitra',       'القنيطرة',        'Kenitra'],
      'Tétouan':            ['Tétouan',       'تطوان',           'Tetuán'],
      'Nador':              ['Nador',         'الناظور',         'Nador'],
      'Al Hoceima':         ['Al Hoceima',    'الحسيمة',         'Al Hoceima'],
      'Berkane':            ['Berkane',       'بركان',           'Berkane'],
      'El Jadida':          ['El Jadida',     'الجديدة',         'El Jadida'],
      'Essaouira':          ['Essaouira',     'الصويرة',         'Esauira'],
      'Laâyoune':           ['Laayoune',      'العيون',          'El Aaiún'],
      'Dakhla':             ['Dakhla',        'الداخلة',         'Dajla'],
      'Mohammedia':         ['Mohammedia',    'المحمدية',        'Mohammedia'],
      'Khouribga':          ['Khouribga',     'خريبكة',          'Khouribga'],
      'Béni Mellal':        ['Beni Mellal',   'بني ملال',        'Beni Mellal'],
      'Beni Mellal':        ['Beni Mellal',   'بني ملال',        'Beni Mellal'],
      'Settat':             ['Settat',        'سطات',            'Settat'],
      'Safi':               ['Safi',          'آسفي',            'Safí'],
      'Errachidia':         ['Errachidia',    'الراشيدية',       'Errachidia'],
      'Ouarzazate':         ['Ouarzazate',    'ورزازات',         'Uarzazat'],
      'Zagora':             ['Zagora',        'زاكورة',          'Zagora'],
      'Khémisset':          ['Khémisset',     'الخميسات',        'Khémisset'],
      'Khénifra':           ['Khénifra',      'خنيفرة',          'Khénifra'],
      'Taza':               ['Taza',          'تازة',            'Taza'],
      'Chefchaouen':        ['Chefchaouen',   'شفشاون',          'Chauen'],
      'Larache':            ['Larache',       'العرائش',         'Larache'],
      'Guelmim':            ['Guelmim',       'كلميم',           'Guelmim'],
      'Tan-Tan':            ['Tan-Tan',       'طانطان',          'Tan-Tan'],
      'Smara':              ['Smara',         'السمارة',         'Smara'],
      'Boujdour':           ['Boujdour',      'بوجدور',          'Bojador'],
      'Taroudant':          ['Taroudant',     'تارودانت',        'Taroudant'],
      'Tiznit':             ['Tiznit',        'تزنيت',           'Tiznit'],
      'Inezgane':           ['Inezgane',      'إنزكان',          'Inezgane'],
      'Ifrane':             ['Ifrane',        'إفران',           'Ifrane'],
      'Azrou':              ['Azrou',         'أزرو',            'Azrou'],
      'Sefrou':             ['Sefrou',        'صفرو',            'Sefrou'],
      'Taounate':           ['Taounate',      'تاونات',          'Taounate'],
      'El Hajeb':           ['El Hajeb',      'الحاجب',          'El Hajeb'],
      'Tiflet':             ['Tiflet',        'تيفلت',           'Tiflet'],
      'Sidi Kacem':         ['Sidi Kacem',    'سيدي قاسم',       'Sidi Kacem'],
      'Sidi Slimane':       ['Sidi Slimane',  'سيدي سليمان',     'Sidi Slimane'],
      'Berrechid':          ['Berrechid',     'برشيد',           'Berrechid'],
      'Azilal':             ['Azilal',        'أزيلال',          'Azilal'],
      'Fquih Ben Salah':    ['Fquih Ben Salah','الفقيه بن صالح', 'Fquih Ben Salah'],
      'Benslimane':         ['Benslimane',    'بنسليمان',        'Benslimane'],
      'Médiouna':           ['Médiouna',      'مديونة',          'Mediouna'],
      'Sidi Bennour':       ['Sidi Bennour',  'سيدي بنور',       'Sidi Bennour'],
      'Ben Guerir':         ['Ben Guerir',    'بن كرير',         'Ben Guerir'],
      'Youssoufia':         ['Youssoufia',    'اليوسفية',        'Youssoufia'],
      'Chichaoua':          ['Chichaoua',     'شيشاوة',          'Chichaoua'],
      'Tahanaout':          ['Tahanaout',     'تحناوت',          'Tahanaout'],
      'Rissani':            ['Rissani',       'الريصاني',        'Rissani'],
      'Midelt':             ['Midelt',        'ميدلت',           'Midelt'],
      'Tinghir':            ['Tinghir',       'تنغير',           'Tinghir'],
      'Boumalne Dadès':     ['Boumalne Dades','بومالن دادس',     'Boumalne Dadès'],
      'Erfoud':             ['Erfoud',        'أرفود',           'Erfoud'],
      'Tata':               ['Tata',          'طاطا',            'Tata'],
      'Biougra':            ['Biougra',       'بيوكرى',          'Biougra'],
      'Assa':               ['Assa',          'أسا',             'Assa'],
      'Tarfaya':            ['Tarfaya',       'طرفاية',          'Tarfaya'],
      'Aousserd':           ['Aousserd',      'أوسرد',           'Aousserd'],
      'Driouch':            ['Driouch',       'الدريوش',         'Driouch'],
      'Jerada':             ['Jerada',        'جرادة',           'Jerada'],
      'Zaio':               ['Zaio',          'زايو',            'Zaio'],
      'Taourirt':           ['Taourirt',      'تاوريرت',         'Taourirt'],
      'Guercif':            ['Guercif',       'كرسيف',           'Guercif'],
      'Asilah':             ['Asilah',        'أصيلة',           'Asilah'],
      'Fnideq':             ['Fnideq',        'الفنيدق',         'Fnideq'],
      'Ouazzane':           ['Ouazzane',      'وزان',            'Ouazzane'],
      'Moulay Yacoub':      ["Moulay Yacoub", 'مولاي يعقوب',    "Moulay Yacoub"],
      'Boulemane':          ['Boulemane',     'بولمان',          'Boulemane'],
      'Nouaceur':           ['Nouaceur',      'النواصر',         'Nouaceur'],
      "M'Diq":              ["M'Diq",         'المضيق',          "M'Diq"],
      'Ksar El-Kébir':      ['Ksar El-Kebir', 'القصر الكبير',   'Alcazarquivir'],
      'El Kelaa Sraghna':   ['El Kelaa Sraghna','قلعة السراغنة','El Kelaa de los Sraghna'],
      // Quartiers / zones
      'Sidi Bernoussi':     ['Sidi Bernoussi','سيدي برنوصي',    'Sidi Bernoussi'],
      'Sidi Ghanem':        ['Sidi Ghanem',   'سيدي غانم',      'Sidi Ghanem'],
      'Sidi Hajjaj':        ['Sidi Hajjaj',   'سيدي حجاج',      'Sidi Hajjaj'],
      'Lissasfa':           ['Lissasfa',      'ليساسفة',        'Lissasfa'],
      'Gzenaya':            ['Gzenaya',       'غزناية',         'Gzenaya'],
      'Tit Mellil':         ['Tit Mellil',    'تيط مليل',       'Tit Mellil'],
      'Oum Azza':           ['Oum Azza',      'أم عزة',         'Oum Azza'],
      'Hay Hassani':        ['Hay Hassani',   'حي الحسني',      'Hay Hassani'],
      'Hay Riad':           ['Hay Riad',      'حي رياض',        'Hay Riad'],
      'Hay Mohammadi':      ['Hay Mohammadi', 'حي المحمدي',     'Hay Mohammadi'],
      'Maarif':             ['Maarif',        'المعاريف',       'Maarif'],
      'Aïn Sebaa':          ['Ain Sebaa',     'عين السبع',      'Ain Sebaa'],
      'Ain Sebaa':          ['Ain Sebaa',     'عين السبع',      'Ain Sebaa'],
      'Aïn Chock':          ['Ain Chock',     'عين الشق',       'Ain Chock'],
      'Ain Chock':          ['Ain Chock',     'عين الشق',       'Ain Chock'],
      'Agdal':              ['Agdal',         'أكدال',          'Agdal'],
      'Sbata':              ['Sbata',         'سباتة',          'Sbata'],
      'Derb Sultan':        ['Derb Sultan',   'درب السلطان',    'Derb Sultan'],
      'Bernoussi':          ['Bernoussi',     'برنوصي',         'Bernoussi'],
      'Tabriquet':          ['Tabriquet',     'طابريقت',        'Tabriquet'],
      'Hay Masira':         ['Hay Masira',    'حي المسيرة',     'Hay Masira'],
      'Hay Isly':           ['Hay Isly',      'حي إسلي',        'Hay Isly'],
      'Hay Nahda':          ['Hay Nahda',     'حي النهضة',      'Hay Nahda'],
      "Ben M'Sik":          ["Ben M'Sik",     'بن مسيك',        "Ben M'Sik"],
      'M\'Nabha':           ["M'Nabha",       'مناबهة',         "M'Nabha"],
      'Racine':             ['Racine',        'الراسين',        'Racine'],
      'Souissi':            ['Souissi',       'السويسي',        'Souissi'],
    };

    final idx = lang == 'en' ? 0 : lang == 'ar' ? 1 : 2;
    String n = name;

    // 1. Traduire le préfixe
    for (final e in prefixes.entries) {
      if (n.startsWith(e.key)) {
        n = n.replaceFirst(e.key, e.value[idx]);
        break;
      }
    }
    // 2. Traduire les suffixes fonctionnels
    for (final e in suffixes.entries) {
      if (n.contains(e.key)) {
        n = n.replaceAll(e.key, e.value[idx]);
      }
    }
    // 3. Traduire les noms de villes / quartiers (ordre du plus long au plus court pour éviter les correspondances partielles)
    final sortedCities = cities.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final e in sortedCities) {
      if (n.contains(e.key)) {
        n = n.replaceAll(e.key, e.value[idx]);
        break; // une ville par nom de point
      }
    }
    return n;
  }

  // ── Traduction des labels ────────────────────────────────────────────────────
  String labelFor(String lang) {
    if (lang == 'fr') return label;
    // Table complète de traduction
    const Map<String, List<String>> t = {
      // fr → [en, ar, es]
      // ─ PNDM / Centres généraux ─
      'PNDM complété • Tri • Recyclage':          ['PNDM completed • Sorting • Recycling', 'PNDM مكتمل • فرز • إعادة تدوير', 'PNDM completado • Clasificación • Reciclaje'],
      'PNDM en construction':                      ['PNDM under construction', 'PNDM قيد الإنشاء', 'PNDM en construcción'],
      'PNDM programme':                            ['PNDM programme', 'برنامج PNDM', 'Programa PNDM'],
      'PNDM programme – capitale provinciale':     ['PNDM programme – provincial capital', 'برنامج PNDM – عاصمة إقليمية', 'Programa PNDM – capital provincial'],
      'Capitale régionale':                        ['Regional capital', 'عاصمة جهوية', 'Capital regional'],
      'Capitale provinciale':                      ['Provincial capital', 'عاصمة إقليمية', 'Capital provincial'],
      'Grande ville':                              ['Major city', 'مدينة كبرى', 'Ciudad importante'],
      'Grande ville Nord':                         ['Major northern city', 'مدينة كبرى في الشمال', 'Ciudad importante del Norte'],
      'Grande ville Souss':                        ['Major Souss city', 'مدينة كبرى في سوس', 'Ciudad importante de Souss'],
      'Prefecture':                                ['Prefecture', 'عمالة', 'Prefectura'],
      'Sous-préfecture Ifrane':                    ['Ifrane sub-prefecture', 'جماعة إفران', 'Subprefectura Ifrane'],
      'Sous-prefecture Ifrane':                    ['Ifrane sub-prefecture', 'جماعة إفران', 'Subprefectura Ifrane'],
      'Préfecture Fès':                            ['Fès prefecture', 'عمالة فاس', 'Prefectura Fès'],
      'Préfecture Casablanca':                     ['Casablanca prefecture', 'عمالة الدار البيضاء', 'Prefectura Casablanca'],
      'Préfecture Skhirate-Témara':                ['Skhirate-Témara prefecture', 'عمالة الصخيرات-تمارة', 'Prefectura Skhirate-Témara'],
      'Province Khémisset':                        ['Khémisset province', 'إقليم الخميسات', 'Provincia Khémisset'],
      'Province Errachidia':                       ['Errachidia province', 'إقليم الرشيدية', 'Provincia Errachidia'],
      'Province Tinghir':                          ['Tinghir province', 'إقليم تنغير', 'Provincia Tinghir'],
      'Province Nador':                            ['Nador province', 'إقليم الناظور', 'Provincia Nador'],
      'Province Chtouka Aït Baha':                 ['Chtouka Aït Baha province', 'إقليم شتوكة آيت باها', 'Provincia Chtouka Aït Baha'],
      'Province Aousserd':                         ['Aousserd province', 'إقليم أوسرد', 'Provincia Aousserd'],
      'Province Assa-Zag':                         ['Assa-Zag province', 'إقليم آسا الزاك', 'Provincia Assa-Zag'],
      'Province Tarfaya':                          ['Tarfaya province', 'إقليم طرفاية', 'Provincia Tarfaya'],
      'Province Es-Semara':                        ['Es-Semara province', 'إقليم السمارة', 'Provincia Es-Semara'],
      'Zone aéroportuaire – tri industriel':       ['Airport zone – industrial sorting', 'منطقة المطار – فرز صناعي', 'Zona aeroportuaria – clasificación industrial'],
      'Zone franche – collecte DEEE':              ['Free zone – e-waste collection', 'المنطقة الحرة – جمع DEEE', 'Zona franca – recogida RAEE'],
      'Déchets ménagers • Tri':                    ['Household waste • Sorting', 'نفايات منزلية • فرز', 'Residuos domésticos • Clasificación'],
      // ─ Industriels ─
      'Co-traitement industriel – 75 000 t/an':   ['Industrial co-processing – 75,000 t/yr', 'معالجة صناعية مشتركة – 75 000 ط/سنة', 'Co-tratamiento industrial – 75 000 t/año'],
      'Co-traitement industriel – 20 000 t/an':   ['Industrial co-processing – 20,000 t/yr', 'معالجة صناعية مشتركة – 20 000 ط/سنة', 'Co-tratamiento industrial – 20 000 t/año'],
      'Co-traitement industriel':                  ['Industrial co-processing', 'المعالجة الصناعية المشتركة', 'Co-tratamiento industrial'],
      'Co-traitement déchets dangereux':           ['Hazardous waste co-processing', 'معالجة مشتركة للنفايات الخطرة', 'Co-tratamiento residuos peligrosos'],
      "Plus grand centre de tri d'Afrique – 280 500 t/an": ["Largest sorting center in Africa – 280,500 t/yr", 'أكبر مركز فرز في إفريقيا – 280 500 ط/سنة', "Mayor centro de clasificación de África – 280 500 t/año"],
      'Valorisation déchets ménagers':             ['Household waste recovery', 'تثمين النفايات المنزلية', 'Valorización residuos domésticos'],
      'Déchets industriels • Recyclage complet':   ['Industrial waste • Full recycling', 'نفايات صناعية • إعادة تدوير شاملة', 'Residuos industriales • Reciclaje completo'],
      'Plastique • Papier • Métal – inauguré 2014':['Plastic • Paper • Metal – opened 2014', 'بلاستيك • ورق • معادن – افتُتح 2014', 'Plástico • Papel • Metal – inaugurado 2014'],
      // ─ Collecte/Tri ─
      'Collecte • Tri • Valorisation déchets':     ['Collection • Sorting • Recovery', 'جمع • فرز • تثمين', 'Recogida • Clasificación • Valorización'],
      'Tri • Valorisation déchets':                ['Sorting • Waste recovery', 'الفرز • تثمين النفايات', 'Clasificación • Valorización'],
      'Tri • Recyclage général':                   ['Sorting • General recycling', 'الفرز • إعادة التدوير العام', 'Clasificación • Reciclaje general'],
      'Collecte sélective • Plastique • Papier':   ['Selective collection • Plastic • Paper', 'جمع انتقائي • بلاستيك • ورق', 'Recogida selectiva • Plástico • Papel'],
      'Collecte sélective • Tri':                  ['Selective collection • Sorting', 'جمع انتقائي • فرز', 'Recogida selectiva • Clasificación'],
      'Collecte sélective':                        ['Selective collection', 'جمع انتقائي', 'Recogida selectiva'],
      'Collecte déchets':                          ['Waste collection', 'جمع النفايات', 'Recogida de residuos'],
      'Collecte déchets – province Nador':         ['Waste collection – Nador province', 'جمع النفايات – إقليم الناظور', 'Recogida de residuos – provincia Nador'],
      'Tri sélectif • Plastique • Papier':         ['Selective sorting • Plastic • Paper', 'فرز انتقائي • بلاستيك • ورق', 'Clasificación selectiva • Plástico • Papel'],
      'Tri sélectif • Multi-matériaux':            ['Selective sorting • Multi-material', 'فرز انتقائي • متعدد المواد', 'Clasificación selectiva • Multimaterial'],
      'Tri sélectif industriel':                   ['Industrial selective sorting', 'فرز صناعي انتقائي', 'Clasificación selectiva industrial'],
      'Tous types de déchets':                     ['All types of waste', 'جميع أنواع النفايات', 'Todo tipo de residuos'],
      // ─ Plastique ─
      'Récupération PET • Papier • Carton':        ['PET recovery • Paper • Cardboard', 'استرداد PET • ورق • كرتون', 'Recuperación PET • Papel • Cartón'],
      'PET • PEHD • PP':                           ['PET • HDPE • PP', 'PET • PEHD • PP', 'PET • PEHD • PP'],
      'PET • Emballages plastique':                ['PET • Plastic packaging', 'PET • عبوات بلاستيكية', 'PET • Envases plástico'],
      'PET • PEHD':                                ['PET • HDPE', 'PET • PEHD', 'PET • PEHD'],
      'PET • Emballages':                          ['PET • Packaging', 'PET • عبوات', 'PET • Envases'],
      'PET • PP • Emballages':                     ['PET • PP • Packaging', 'PET • PP • عبوات', 'PET • PP • Envases'],
      'Plastique • Papier • Métal':                ['Plastic • Paper • Metal', 'بلاستيك • ورق • معادن', 'Plástico • Papel • Metal'],
      'Plastique • Papier':                        ['Plastic • Paper', 'بلاستيك • ورق', 'Plástico • Papel'],
      'Plastique • Verre':                         ['Plastic • Glass', 'بلاستيك • زجاج', 'Plástico • Vidrio'],
      'Bouteilles PET • Verre':                    ['PET bottles • Glass', 'زجاجات PET • زجاج', 'Botellas PET • Vidrio'],
      'Bouteilles PET • Aluminium':                ['PET bottles • Aluminium', 'زجاجات PET • ألومنيوم', 'Botellas PET • Aluminio'],
      'Bouteilles PET • Emballages':               ['PET bottles • Packaging', 'زجاجات PET • عبوات', 'Botellas PET • Envases'],
      'Bouteilles PET • Plastique rigide':         ['PET bottles • Rigid plastic', 'زجاجات PET • بلاستيك صلب', 'Botellas PET • Plástico rígido'],
      'Bouteilles PET • Plastique':                ['PET bottles • Plastic', 'زجاجات PET • بلاستيك', 'Botellas PET • Plástico'],
      // ─ Verre ─
      'Bouteilles verre • Bocaux':                 ['Glass bottles • Jars', 'زجاجات زجاج • برطمانات', 'Botellas vidrio • Tarros'],
      'Bouteilles • Bocaux':                       ['Bottles • Jars', 'زجاجات • برطمانات', 'Botellas • Tarros'],
      // ─ Papier ─
      'Journaux • Cartons • Archives':             ['Newspapers • Cardboard • Archives', 'جرائد • كراتين • أرشيف', 'Periódicos • Cartón • Archivos'],
      'Journaux • Cartons • Cahiers':              ['Newspapers • Cardboard • Books', 'جرائد • كراتين • كتب', 'Periódicos • Cartón • Libros'],
      'Journaux • Cartons':                        ['Newspapers • Cardboard', 'جرائد • كراتين', 'Periódicos • Cartón'],
      // ─ Compost ─
      'Déchets organiques • Compostage':           ['Organic waste • Composting', 'نفايات عضوية • تسميد', 'Residuos orgánicos • Compostaje'],
      'Déchets organiques':                        ['Organic waste', 'نفايات عضوية', 'Residuos orgánicos'],
      // ─ Piles ─
      'Piles • Batteries':                         ['Batteries', 'بطاريات', 'Pilas • Baterías'],
      'Batteries usagées • Plastique • Papier':    ['Used batteries • Plastic • Paper', 'بطاريات مستعملة • بلاستيك • ورق', 'Baterías usadas • Plástico • Papel'],
      // ─ Électronique ─
      'Électronique • Électroménager':             ['Electronics • Appliances', 'الإلكترونيات • الأجهزة المنزلية', 'Electrónica • Electrodomésticos'],
      'Électroménager • Câbles':                   ['Appliances • Cables', 'أجهزة منزلية • كابلات', 'Electrodomésticos • Cables'],
      'Électronique • Câbles':                     ['Electronics • Cables', 'الإلكترونيات • كابلات', 'Electrónica • Cables'],
      'DEEE • Gros électroménager':                ['WEEE • Large appliances', 'DEEE • أجهزة كبيرة', 'RAEE • Grandes electrodomésticos'],
      'Électronique • Électroménager – zone industrielle': ['Electronics • Appliances – industrial zone', 'إلكترونيات • أجهزة – منطقة صناعية', 'Electrónica • Electrodomésticos – zona industrial'],
      // ─ Textile ─
      'Vêtements • Chaussures':                    ['Clothing • Shoes', 'ملابس • أحذية', 'Ropa • Calzado'],
      'Vêtements • Textiles':                      ['Clothing • Textiles', 'ملابس • منسوجات', 'Ropa • Textiles'],
      // ─ Huiles ─
      'Huiles moteur • Industrielles':             ['Motor oil • Industrial', 'زيوت المحرك • صناعية', 'Aceite de motor • Industrial'],
      'Huiles moteur usagées':                     ['Used motor oil', 'زيوت محرك مستعملة', 'Aceite de motor usado'],
      'Huiles moteur usagées – zone industrielle': ['Used motor oil – industrial zone', 'زيوت محرك مستعملة – منطقة صناعية', 'Aceite motor usado – zona industrial'],
      'Huiles moteur • Alimentaires':              ['Motor oil • Food-grade oil', 'زيوت محرك • زيوت غذائية', 'Aceite motor • Aceite alimentario'],
      // ─ Métal ─
      'Ferraille • Acier • Aluminium':             ['Scrap • Steel • Aluminium', 'خردة • فولاذ • ألومنيوم', 'Chatarra • Acero • Aluminio'],
      'Ferraille • Acier':                         ['Scrap • Steel', 'خردة • فولاذ', 'Chatarra • Acero'],
      'Ferraille • Métaux':                        ['Scrap • Metals', 'خردة • معادن', 'Chatarra • Metales'],
      'Ferraille – zone industrielle':             ['Scrap – industrial zone', 'خردة – منطقة صناعية', 'Chatarra – zona industrial'],
      'Acier • Aluminium • Cuivre':                ['Steel • Aluminium • Copper', 'فولاذ • ألومنيوم • نحاس', 'Acero • Aluminio • Cobre'],
      'Acier • Aluminium':                         ['Steel • Aluminium', 'فولاذ • ألومنيوم', 'Acero • Aluminio'],
      'Acier • Métaux industriels':                ['Steel • Industrial metals', 'فولاذ • معادن صناعية', 'Acero • Metales industriales'],
      'Acier • Aluminium – zone industrielle':     ['Steel • Aluminium – industrial zone', 'فولاذ • ألومنيوم – منطقة صناعية', 'Acero • Aluminio – zona industrial'],
      // ─ Spécifiques ─
      'Pneus usagés • Caoutchouc':                 ['Used tyres • Rubber', 'إطارات مستعملة • مطاط', 'Neumáticos usados • Caucho'],
    };
    final idx = lang == 'en' ? 0 : lang == 'ar' ? 1 : 2;
    final translated = t[label];
    if (translated != null) return translated[idx];
    return label;
  }

  // Retourne le nom de la ville dans la langue demandée
  String displayAddressFor(String lang) {
    final n = name;
    // Détection de la ville (logique identique à l'ancien displayAddress)
    String fr;
    if (n.contains('Casablanca') || n.contains('Aïn Sebaa') ||
        n.contains('Hay Hassani') || n.contains('Twin Center') ||
        n.contains('Bernoussi') || n.contains('Hay Mohammadi') ||
        n.contains('Sidi Maarouf') || n.contains('Maarif') ||
        n.contains('Médiouna') || n.contains('Sidi Hajjaj')) { fr = 'Casablanca'; }
    else if (n.contains('Rabat') || n.contains('Agdal') || n.contains('Hay Riad') ||
        n.contains('Oum Azza') || n.contains('Mohammed V')) { fr = 'Rabat'; }
    else if (n.contains('Salé'))          { fr = 'Salé'; }
    else if (n.contains('Tanger'))        { fr = 'Tanger'; }
    else if (n.contains('Fès') || n.contains('Fes')) { fr = 'Fès'; }
    else if (n.contains('Agadir') || n.contains('Aït Melloul')) { fr = 'Agadir'; }
    else if (n.contains('Oujda'))         { fr = 'Oujda'; }
    else if (n.contains('Meknès') || n.contains('Meknes')) { fr = 'Meknès'; }
    else if (n.contains('Marrakech'))     { fr = 'Marrakech'; }
    else if (n.contains('Tétouan') || n.contains('Tetouan')) { fr = 'Tétouan'; }
    else if (n.contains('Nador'))         { fr = 'Nador'; }
    else if (n.contains('Al Hoceima'))    { fr = 'Al Hoceima'; }
    else if (n.contains('El Jadida'))     { fr = 'El Jadida'; }
    else if (n.contains('Essaouira'))     { fr = 'Essaouira'; }
    else if (n.contains('Berkane'))       { fr = 'Berkane'; }
    else if (n.contains('Figuig'))        { fr = 'Figuig'; }
    else if (n.contains('Guelmim'))       { fr = 'Guelmim'; }
    else if (n.contains('Laâyoune'))      { fr = 'Laâyoune'; }
    else if (n.contains('Dakhla'))        { fr = 'Dakhla'; }
    else if (n.contains('Mohammedia'))    { fr = 'Mohammedia'; }
    else if (n.contains('Khouribga'))     { fr = 'Khouribga'; }
    else if (n.contains('Berrechid') || n.contains('El Gara')) { fr = 'Berrechid'; }
    else if (n.contains('Kénitra') || n.contains('Kenitra')) { fr = 'Kénitra'; }
    else if (n.contains('Béni Mellal') || n.contains('Beni Mellal')) { fr = 'Béni Mellal'; }
    else if (n.contains('Settat'))        { fr = 'Settat'; }
    else if (n.contains('Safi'))          { fr = 'Safi'; }
    else if (n.contains('Tiznit'))        { fr = 'Tiznit'; }
    else if (n.contains('Errachidia'))    { fr = 'Errachidia'; }
    else if (n.contains('Taroudant'))     { fr = 'Taroudant'; }
    else if (n.contains('Azrou'))         { fr = 'Azrou'; }
    else if (n.contains('Azilal'))        { fr = 'Azilal'; }
    else if (n.contains('Aousserd'))      { fr = 'Aousserd'; }
    else if (n.contains('Assa'))          { fr = 'Assa'; }
    else if (n.contains('Benslimane'))    { fr = 'Benslimane'; }
    else if (n.contains('Biougra') || n.contains('Chtouka')) { fr = 'Biougra'; }
    else if (n.contains('Boulemane'))     { fr = 'Boulemane'; }
    else if (n.contains('Boumalne') || n.contains('Dadès')) { fr = 'Boumalne Dadès'; }
    else if (n.contains('Chichaoua'))     { fr = 'Chichaoua'; }
    else if (n.contains('Ben Guerir') || n.contains('Rehamna')) { fr = 'Ben Guerir'; }
    else if (n.contains('Beni Ansar'))    { fr = 'Béni Ansar'; }
    else if (n.contains('Driouch'))       { fr = 'Driouch'; }
    else if (n.contains('El Hajeb'))      { fr = 'El Hajeb'; }
    else if (n.contains('Erfoud'))        { fr = 'Erfoud'; }
    else if (n.contains('Fquih Ben Salah')) { fr = 'Fquih Ben Salah'; }
    else if (n.contains('Guercif'))       { fr = 'Guercif'; }
    else if (n.contains('Jerada'))        { fr = 'Jerada'; }
    else if (n.contains('Kelaat') || n.contains("M'Gouna")) { fr = "Kelaat M'Gouna"; }
    else if (n.contains('Midelt'))        { fr = 'Midelt'; }
    else if (n.contains('Moulay Yacoub')) { fr = 'Moulay Yacoub'; }
    else if (n.contains("M'Diq") || n.contains('Mdiq')) { fr = "M'Diq"; }
    else if (n.contains('Nouaceur'))      { fr = 'Nouaceur'; }
    else if (n.contains('Ouazzane'))      { fr = 'Ouazzane'; }
    else if (n.contains('Rissani'))       { fr = 'Rissani'; }
    else if (n.contains('Sefrou'))        { fr = 'Sefrou'; }
    else if (n.contains('Sidi Bennour'))  { fr = 'Sidi Bennour'; }
    else if (n.contains('Sidi Ifni'))     { fr = 'Sidi Ifni'; }
    else if (n.contains('Sidi Kacem'))    { fr = 'Sidi Kacem'; }
    else if (n.contains('Sidi Slimane')) { fr = 'Sidi Slimane'; }
    else if (n.contains('Tahanaout') || n.contains('Al Haouz')) { fr = 'Tahanaout'; }
    else if (n.contains('Tarfaya'))       { fr = 'Tarfaya'; }
    else if (n.contains('Taounate'))      { fr = 'Taounate'; }
    else if (n.contains('Tata'))          { fr = 'Tata'; }
    else if (n.contains('Tiflet'))        { fr = 'Tiflet'; }
    else if (n.contains('Tinghir'))       { fr = 'Tinghir'; }
    else if (n.contains('Youssoufia'))    { fr = 'Youssoufia'; }
    else if (n.contains('Zaio'))          { fr = 'Zaio'; }
    else if (n.contains('Zag'))           { fr = 'Zag'; }
    else if (n.contains('Inezgane'))      { fr = 'Inezgane'; }
    else if (n.contains('Asilah'))        { fr = 'Asilah'; }
    else if (n.contains('Fnideq'))        { fr = 'Fnideq'; }
    else if (n.contains('Smara') || n.contains('Es-Semara')) { fr = 'Es-Semara'; }
    else if (n.contains('Boujdour'))      { fr = 'Boujdour'; }
    else if (n.contains('Témara') || n.contains('Temara')) { fr = 'Témara'; }
    else if (n.contains('Taza'))          { fr = 'Taza'; }
    else if (n.contains('Zagora'))        { fr = 'Zagora'; }
    else if (n.contains('Khénifra'))      { fr = 'Khénifra'; }
    else if (n.contains('Khémisset'))     { fr = 'Khémisset'; }
    else if (n.contains('Ifrane'))        { fr = 'Ifrane'; }
    else if (n.contains('El Kelaa'))      { fr = 'El Kelaa Sraghna'; }
    else if (n.contains('Ksar El'))       { fr = 'Ksar El-Kébir'; }
    else if (n.contains('Ouarzazate'))    { fr = 'Ouarzazate'; }
    else { fr = 'Maroc'; }

    if (lang == 'fr') return fr;

    // Table de traduction ville : fr → [en, ar, es]
    const Map<String, List<String>> cityT = {
      'Casablanca':        ['Casablanca',      'الدار البيضاء',  'Casablanca'],
      'Rabat':             ['Rabat',           'الرباط',         'Rabat'],
      'Salé':              ['Salé',            'سلا',            'Salé'],
      'Tanger':            ['Tanger',          'طنجة',           'Tánger'],
      'Fès':               ['Fes',             'فاس',            'Fez'],
      'Agadir':            ['Agadir',          'أكادير',         'Agadir'],
      'Oujda':             ['Oujda',           'وجدة',           'Uchda'],
      'Meknès':            ['Meknes',          'مكناس',          'Mequinez'],
      'Marrakech':         ['Marrakech',       'مراكش',          'Marrakech'],
      'Tétouan':           ['Tétouan',         'تطوان',          'Tetuán'],
      'Nador':             ['Nador',           'الناظور',        'Nador'],
      'Al Hoceima':        ['Al Hoceima',      'الحسيمة',        'Al Hoceima'],
      'El Jadida':         ['El Jadida',       'الجديدة',        'El Jadida'],
      'Essaouira':         ['Essaouira',       'الصويرة',        'Esauira'],
      'Berkane':           ['Berkane',         'بركان',          'Berkane'],
      'Figuig':            ['Figuig',          'فجيج',           'Figuig'],
      'Guelmim':           ['Guelmim',         'كلميم',          'Guelmim'],
      'Laâyoune':          ['Laayoune',        'العيون',         'El Aaiún'],
      'Dakhla':            ['Dakhla',          'الداخلة',        'Dajla'],
      'Mohammedia':        ['Mohammedia',      'المحمدية',       'Mohammedia'],
      'Khouribga':         ['Khouribga',       'خريبكة',         'Khouribga'],
      'Berrechid':         ['Berrechid',       'برشيد',          'Berrechid'],
      'Kénitra':           ['Kénitra',         'القنيطرة',       'Kenitra'],
      'Béni Mellal':       ['Beni Mellal',     'بني ملال',       'Beni Mellal'],
      'Settat':            ['Settat',          'سطات',           'Settat'],
      'Safi':              ['Safi',            'آسفي',           'Safí'],
      'Tiznit':            ['Tiznit',          'تزنيت',          'Tiznit'],
      'Errachidia':        ['Errachidia',      'الراشيدية',      'Errachidia'],
      'Taroudant':         ['Taroudant',       'تارودانت',       'Taroudant'],
      'Azrou':             ['Azrou',           'أزرو',           'Azrou'],
      'Azilal':            ['Azilal',          'أزيلال',         'Azilal'],
      'Aousserd':          ['Aousserd',        'أوسرد',          'Aousserd'],
      'Assa':              ['Assa',            'أسا',            'Assa'],
      'Benslimane':        ['Benslimane',      'بنسليمان',       'Benslimane'],
      'Biougra':           ['Biougra',         'بيوكرى',         'Biougra'],
      'Boulemane':         ['Boulemane',       'بولمان',         'Boulemane'],
      'Boumalne Dadès':    ['Boumalne Dades',  'بومالن دادس',    'Boumalne Dadès'],
      'Chichaoua':         ['Chichaoua',       'شيشاوة',         'Chichaoua'],
      'Ben Guerir':        ['Ben Guerir',      'بن كرير',        'Ben Guerir'],
      'Béni Ansar':        ['Beni Ansar',      'بني أنصار',      'Beni Ansar'],
      'Driouch':           ['Driouch',         'الدريوش',        'Driouch'],
      'El Hajeb':          ['El Hajeb',        'الحاجب',         'El Hajeb'],
      'Erfoud':            ['Erfoud',          'أرفود',          'Erfoud'],
      'Fquih Ben Salah':   ['Fquih Ben Salah', 'الفقيه بن صالح','Fquih Ben Salah'],
      'Guercif':           ['Guercif',         'كرسيف',          'Guercif'],
      'Jerada':            ['Jerada',          'جرادة',          'Jerada'],
      "Kelaat M'Gouna":    ["Kelaat M'Gouna",  'قلعة مكونة',     "Kelaat M'Gouna"],
      'Midelt':            ['Midelt',          'ميدلت',          'Midelt'],
      'Moulay Yacoub':     ['Moulay Yacoub',   'مولاي يعقوب',   'Moulay Yacoub'],
      "M'Diq":             ["M'Diq",           'المضيق',         "M'Diq"],
      'Nouaceur':          ['Nouaceur',        'النواصر',        'Nouaceur'],
      'Ouazzane':          ['Ouazzane',        'وزان',           'Ouazzane'],
      'Rissani':           ['Rissani',         'الريصاني',       'Rissani'],
      'Sefrou':            ['Sefrou',          'صفرو',           'Sefrou'],
      'Sidi Bennour':      ['Sidi Bennour',    'سيدي بنور',      'Sidi Bennour'],
      'Sidi Ifni':         ['Sidi Ifni',       'سيدي إفني',      'Sidi Ifni'],
      'Sidi Kacem':        ['Sidi Kacem',      'سيدي قاسم',      'Sidi Kacem'],
      'Sidi Slimane':      ['Sidi Slimane',    'سيدي سليمان',   'Sidi Slimane'],
      'Tahanaout':         ['Tahanaout',       'تحناوت',         'Tahanaout'],
      'Tarfaya':           ['Tarfaya',         'طرفاية',         'Tarfaya'],
      'Taounate':          ['Taounate',        'تاونات',         'Taounate'],
      'Tata':              ['Tata',            'طاطا',           'Tata'],
      'Tiflet':            ['Tiflet',          'تيفلت',          'Tiflet'],
      'Tinghir':           ['Tinghir',         'تنغير',          'Tinghir'],
      'Youssoufia':        ['Youssoufia',      'اليوسفية',       'Youssoufia'],
      'Zaio':              ['Zaio',            'زايو',           'Zaio'],
      'Zag':               ['Zag',             'الزاك',          'Zag'],
      'Inezgane':          ['Inezgane',        'إنزكان',         'Inezgane'],
      'Asilah':            ['Asilah',          'أصيلة',          'Asilah'],
      'Fnideq':            ['Fnideq',          'الفنيدق',        'Fnideq'],
      'Es-Semara':         ['Es-Semara',       'السمارة',        'Es-Semara'],
      'Boujdour':          ['Boujdour',        'بوجدور',         'Bojador'],
      'Témara':            ['Témara',          'تمارة',          'Témara'],
      'Taza':              ['Taza',            'تازة',           'Taza'],
      'Zagora':            ['Zagora',          'زاكورة',         'Zagora'],
      'Khénifra':          ['Khénifra',        'خنيفرة',         'Khénifra'],
      'Khémisset':         ['Khémisset',       'الخميسات',       'Khémisset'],
      'Ifrane':            ['Ifrane',          'إفران',          'Ifrane'],
      'El Kelaa Sraghna':  ['El Kelaa Sraghna','قلعة السراغنة', 'El Kelaa de los Sraghna'],
      'Ksar El-Kébir':     ['Ksar El-Kebir',   'القصر الكبير',  'Alcazarquivir'],
      'Ouarzazate':        ['Ouarzazate',      'ورزازات',        'Uarzazat'],
      'Maroc':             ['Morocco',         'المغرب',         'Marruecos'],
    };

    final idx = lang == 'en' ? 0 : lang == 'ar' ? 1 : 2;
    return cityT[fr]?[idx] ?? fr;
  }
}
