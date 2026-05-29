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
  ];

  LatLng? _userPosition;
  bool _isLoadingLocation = true;
  final List<_Point> _dynamicPoints = [];
  bool _isLoadingPoints = false;
  int? _tapped;

  // Points de collecte et recyclage à travers tout le Maroc (données vérifiées)
  static final _staticPoints = <_Point>[
    // ── CASABLANCA ──────────────────────────────────────────────────────────
    _Point('Eco Zalagh – Médiouna', 'Tri • Valorisation déchets',
        const LatLng(33.4833, -7.5167), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Eco Zalagh – Sidi Hajjaj', 'Tri • Valorisation déchets',
        const LatLng(33.5050, -7.4750), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Geocycle – Route de la Mecque', 'Co-traitement industriel',
        const LatLng(33.5389, -7.7000), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Logipro DEEE – Maarif Extension', 'Électronique • Électroménager',
        const LatLng(33.5800, -7.6400), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('Centre de Tri Aïn Sebaa', 'Plastique • Papier • Métal',
        const LatLng(33.6112, -7.5131), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Marjane Hay Hassani – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.5683, -7.6742), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Twin Center – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.5992, -7.6328), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Marjane Bernoussi – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.6100, -7.5500), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Verre Maarif', 'Bouteilles • Bocaux',
        const LatLng(33.5882, -7.6376), AppColors.glass, Icons.local_bar_outlined, 'Verre'),
    _Point('Borne Plastique Sidi Maarouf', 'Bouteilles PET • Emballages',
        const LatLng(33.5490, -7.6365), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Déchetterie Hay Mohammadi', 'Tous types de déchets',
        const LatLng(33.5932, -7.5617), AppColors.primary, Icons.delete_sweep_rounded, 'Tous'),
    _Point('Point Papier Hay Hassani', 'Journaux • Cartons',
        const LatLng(33.5650, -7.6600), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Collecte Textile Casa – Oulad Ziane', 'Vêtements • Chaussures',
        const LatLng(33.5750, -7.5900), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),

    // ── RABAT / SALÉ ─────────────────────────────────────────────────────────
    _Point('Geocycle – Oum Azza Rabat', 'Co-traitement industriel',
        const LatLng(33.9000, -6.9500), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Centre de Valorisation Rabat', 'Tri • Recyclage général',
        const LatLng(33.9716, -6.8498), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Marjane Hay Riad – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.9502, -6.8360), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Recyclage Agdal', 'Plastique • Papier',
        const LatLng(33.9847, -6.8491), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Point Verre Hay Riad', 'Bouteilles • Bocaux',
        const LatLng(33.9600, -6.8400), AppColors.glass, Icons.local_bar_outlined, 'Verre'),
    _Point('Déchetterie Salé', 'Tous types de déchets',
        const LatLng(34.0372, -6.7888), AppColors.primary, Icons.delete_sweep_rounded, 'Tous'),
    _Point('Point Papier Université Mohammed V', 'Journaux • Cartons',
        const LatLng(33.9988, -6.8505), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Collecte Électronique Rabat', 'Électroménager • Câbles',
        const LatLng(33.9750, -6.8600), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── TANGER ───────────────────────────────────────────────────────────────
    _Point('Eco Zalagh – Grottes d\'Hercule', 'Tri • Valorisation déchets',
        const LatLng(35.7839, -5.9153), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Geocycle Tanger – Route Rabat K19', 'Co-traitement industriel',
        const LatLng(35.6800, -5.8500), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Marjane Tanger Iberia – Collecte Piles', 'Piles • Batteries',
        const LatLng(35.7673, -5.8388), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Centre Tri Municipal Tanger', 'Plastique • Papier • Métal',
        const LatLng(35.7534, -5.7991), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Point Verre Tanger Centre', 'Bouteilles • Bocaux',
        const LatLng(35.7700, -5.8000), AppColors.glass, Icons.local_bar_outlined, 'Verre'),
    _Point('Collecte Textile Tanger', 'Vêtements • Chaussures',
        const LatLng(35.7600, -5.8200), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),

    // ── FÈS ──────────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Fès', 'Tri • Recyclage général',
        const LatLng(33.9779, -4.9993), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Marjane Fès – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.9700, -5.0050), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Recyclage Fès Ville Nouvelle', 'Plastique • Verre',
        const LatLng(34.0100, -5.0100), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Point Papier Fès Al Bali', 'Journaux • Cartons',
        const LatLng(34.0600, -4.9700), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Collecte Électronique Fès', 'Électroménager • Câbles',
        const LatLng(34.0250, -5.0200), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── AGADIR ───────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Agadir', 'Tri • Recyclage général',
        const LatLng(30.4278, -9.5981), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Marjane Agadir – Collecte Piles', 'Piles • Batteries',
        const LatLng(30.4142, -9.5818), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Verre Agadir Centre', 'Bouteilles • Bocaux',
        const LatLng(30.4200, -9.5900), AppColors.glass, Icons.local_bar_outlined, 'Verre'),
    _Point('Centre Tri Aït Melloul', 'Plastique • Papier • Métal',
        const LatLng(30.3500, -9.4900), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Point Papier Agadir', 'Journaux • Cartons',
        const LatLng(30.4350, -9.5800), AppColors.paper, Icons.article_outlined, 'Papier'),

    // ── OUJDA ────────────────────────────────────────────────────────────────
    _Point('Centre de Tri Oujda', 'Plastique • Papier • Verre',
        const LatLng(34.6882, -1.9082), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Marjane Oujda – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.6860, -1.9140), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Verre Oujda Bd Hassan II', 'Bouteilles • Bocaux',
        const LatLng(34.6820, -1.9005), AppColors.glass, Icons.local_bar_outlined, 'Verre'),
    _Point('Déchetterie Centrale Oujda', 'Tous types de déchets',
        const LatLng(34.6715, -1.9135), AppColors.primary, Icons.delete_sweep_rounded, 'Tous'),
    _Point('Point Papier Université Oujda', 'Journaux • Cartons',
        const LatLng(34.6908, -1.9295), AppColors.paper, Icons.article_outlined, 'Papier'),
    _Point('Collecte Textile Oujda', 'Vêtements • Chaussures',
        const LatLng(34.6795, -1.9050), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),
    _Point('Bac Compost Oujda Hay Salam', 'Déchets organiques',
        const LatLng(34.6752, -1.9178), const Color(0xFF795548), Icons.compost_rounded, 'Compost'),
    _Point('Collecte Électronique Oujda', 'Électroménager • Câbles',
        const LatLng(34.6945, -1.9218), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── MEKNÈS ───────────────────────────────────────────────────────────────
    _Point('Centre Tri Zone Industrielle Meknès', 'Plastique • Papier • Métal',
        const LatLng(33.8957, -5.5555), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Marjane Meknès – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.8851, -5.5399), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Verre Meknès', 'Bouteilles • Bocaux',
        const LatLng(33.8900, -5.5500), AppColors.glass, Icons.local_bar_outlined, 'Verre'),

    // ── TÉTOUAN ──────────────────────────────────────────────────────────────
    _Point('Centre Tri Tétouan', 'Tri • Recyclage général',
        const LatLng(35.5889, -5.3626), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Point Recyclage Tétouan Ville', 'Plastique • Verre',
        const LatLng(35.5746, -5.3760), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── NADOR ────────────────────────────────────────────────────────────────
    _Point('Centre de Tri Nador', 'Tri • Recyclage général',
        const LatLng(35.1699, -2.9303), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Point Collecte Nador Centre', 'Plastique • Papier',
        const LatLng(35.1750, -2.9400), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── AL HOCEIMA ───────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Al Hoceima', 'Tri • Recyclage général',
        const LatLng(35.2517, -3.9372), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── EL JADIDA ────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation El Jadida', 'Tri • Recyclage général',
        const LatLng(33.2340, -8.5041), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Marjane El Jadida – Collecte Piles', 'Piles • Batteries',
        const LatLng(33.2267, -8.5095), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Verre El Jadida', 'Bouteilles • Bocaux',
        const LatLng(33.2300, -8.5000), AppColors.glass, Icons.local_bar_outlined, 'Verre'),

    // ── ESSAOUIRA ─────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Essaouira', 'Tri • Recyclage général',
        const LatLng(31.5083, -9.7638), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Point Collecte Essaouira Médina', 'Plastique • Papier',
        const LatLng(31.5120, -9.7700), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── BERKANE ───────────────────────────────────────────────────────────────
    _Point('Centre de Tri Berkane', 'Plastique • Papier • Métal',
        const LatLng(34.9223, -2.3198), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── FIGUIG ────────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Figuig', 'Tri • Recyclage général',
        const LatLng(32.1095, -1.2296), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── GUELMIM ───────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Guelmim', 'Tri • Recyclage général',
        const LatLng(28.9871, -10.0572), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── LAÂYOUNE ─────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Laâyoune', 'Tri • Recyclage général',
        const LatLng(27.1536, -13.2030), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Point Collecte Laâyoune', 'Plastique • Papier',
        const LatLng(27.1600, -13.1950), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── DAKHLA ───────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Dakhla', 'Tri • Recyclage général',
        const LatLng(23.6872, -15.9584), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── MOHAMMEDIA ────────────────────────────────────────────────────────────
    _Point('Centre de Valorisation Mohammedia', 'Tri • Recyclage général',
        const LatLng(33.6866, -7.3828), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Point Recyclage Mohammedia', 'Plastique • Papier',
        const LatLng(33.6900, -7.3900), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── KHOURIBGA ────────────────────────────────────────────────────────────
    _Point('Centre de Tri Khouribga', 'Plastique • Papier • Métal',
        const LatLng(32.8862, -6.9083), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── GEOCYCLE BERRECHID ────────────────────────────────────────────────────
    _Point('Geocycle – El Gara Berrechid', 'Co-traitement industriel',
        const LatLng(33.2692, -7.5847), AppColors.primary, Icons.factory_rounded, 'Tous'),

    // ── MARRAKECH ─────────────────────────────────────────────────────────────
    _Point('Marjane Marrakech – Collecte Piles', 'Piles • Batteries',
        const LatLng(31.6215, -8.0017), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),
    _Point('Point Collecte Marrakech Gueliz', 'Plastique • Verre',
        const LatLng(31.6348, -8.0100), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Point Verre Marrakech Hivernage', 'Bouteilles • Bocaux',
        const LatLng(31.6200, -8.0200), AppColors.glass, Icons.local_bar_outlined, 'Verre'),
    _Point('Collecte Textile Marrakech', 'Vêtements • Chaussures',
        const LatLng(31.6400, -7.9900), const Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile'),

    // ── KÉNITRA ──────────────────────────────────────────────────────────────
    _Point('Centre Tri Kénitra', 'Plastique • Papier',
        const LatLng(34.2610, -6.5802), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Marjane Kénitra – Collecte Piles', 'Piles • Batteries',
        const LatLng(34.2503, -6.5946), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),

    // ── BÉNI MELLAL ──────────────────────────────────────────────────────────
    _Point('Centre Tri Béni Mellal', 'Plastique • Papier • Métal',
        const LatLng(32.3373, -6.3498), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('Marjane Béni Mellal – Collecte Piles', 'Piles • Batteries',
        const LatLng(32.3300, -6.3600), const Color(0xFFFF9800), Icons.battery_charging_full_rounded, 'Piles'),

    // ── SETTAT / BERRECHID ────────────────────────────────────────────────────
    _Point('Point Recyclage Settat', 'Plastique • Papier',
        const LatLng(33.0010, -7.6196), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── SAFI ──────────────────────────────────────────────────────────────────
    _Point('Point Collecte Safi', 'Plastique • Papier',
        const LatLng(32.2994, -9.2372), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── TIZNIT ────────────────────────────────────────────────────────────────
    _Point('Centre Tri Tiznit', 'Plastique • Papier',
        const LatLng(29.6974, -9.7328), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── ERRACHIDIA ────────────────────────────────────────────────────────────
    _Point('Point Collecte Errachidia', 'Plastique • Papier',
        const LatLng(31.9310, -4.4240), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── TAROUDANT ─────────────────────────────────────────────────────────────
    _Point('Point Collecte Taroudant', 'Plastique • Papier',
        const LatLng(30.4703, -8.8756), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
  ];

  List<_Point> get _allPoints =>
      _dynamicPoints.isNotEmpty ? _dynamicPoints : _staticPoints;

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

  String _distanceText(_Point point) {
    if (_userPosition == null) return '';
    const d = Distance();
    final meters = d(_userPosition!, point.latLng);
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
                      distance: _distanceText(all[_tapped!]),
                      lang: ref.watch(localeProvider).languageCode,
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
                          children: const [
                            _LegendItem(AppColors.primary, 'Général'),
                            _LegendItem(AppColors.plastic, 'Plastique'),
                            _LegendItem(AppColors.glass, 'Verre'),
                            _LegendItem(Color(0xFF795548), 'Compost'),
                            _LegendItem(AppColors.electronics, 'Électro.'),
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
                                  ? '${visible.length} points dans votre secteur'
                                  : '${visible.length} points disponibles',
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Localisation en cours...',
                        style: TextStyle(
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
                  point.name,
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
                  Row(
                    children: [
                      const Icon(Icons.near_me_rounded,
                          size: 11, color: Colors.blue),
                      const SizedBox(width: 3),
                      Text(
                        '$distance · ${point.displayAddress}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

  String labelFor(String lang) {
    switch (label) {
      case 'Tri • Valorisation déchets':
        switch (lang) {
          case 'ar': return 'الفرز • تثمين النفايات';
          case 'es': return 'Clasificación • Valorización';
          case 'en': return 'Sorting • Waste recovery';
          default:   return label;
        }
      case 'Co-traitement industriel':
        switch (lang) {
          case 'ar': return 'المعالجة الصناعية المشتركة';
          case 'es': return 'Co-tratamiento industrial';
          case 'en': return 'Industrial co-processing';
          default:   return label;
        }
      case 'Électronique • Électroménager':
        switch (lang) {
          case 'ar': return 'الإلكترونيات • الأجهزة المنزلية';
          case 'es': return 'Electrónica • Electrodomésticos';
          case 'en': return 'Electronics • Appliances';
          default:   return label;
        }
      case 'Plastique • Papier • Métal':
        switch (lang) {
          case 'ar': return 'بلاستيك • ورق • معادن';
          case 'es': return 'Plástico • Papel • Metal';
          case 'en': return 'Plastic • Paper • Metal';
          default:   return label;
        }
      case 'Piles • Batteries':
        switch (lang) {
          case 'ar': return 'بطاريات';
          case 'es': return 'Pilas • Baterías';
          case 'en': return 'Batteries';
          default:   return label;
        }
      case 'Bouteilles • Bocaux':
        switch (lang) {
          case 'ar': return 'زجاجات • برطمانات';
          case 'es': return 'Botellas • Tarros';
          case 'en': return 'Bottles • Jars';
          default:   return label;
        }
      case 'Tous types de déchets':
        switch (lang) {
          case 'ar': return 'جميع أنواع النفايات';
          case 'es': return 'Todo tipo de residuos';
          case 'en': return 'All types of waste';
          default:   return label;
        }
      case 'Journaux • Cartons':
        switch (lang) {
          case 'ar': return 'جرائد • كراتين';
          case 'es': return 'Periódicos • Cartón';
          case 'en': return 'Newspapers • Cardboard';
          default:   return label;
        }
      case 'Vêtements • Chaussures':
        switch (lang) {
          case 'ar': return 'ملابس • أحذية';
          case 'es': return 'Ropa • Calzado';
          case 'en': return 'Clothing • Shoes';
          default:   return label;
        }
      case 'Déchets organiques':
        switch (lang) {
          case 'ar': return 'نفايات عضوية';
          case 'es': return 'Residuos orgánicos';
          case 'en': return 'Organic waste';
          default:   return label;
        }
      case 'Plastique • Verre':
        switch (lang) {
          case 'ar': return 'بلاستيك • زجاج';
          case 'es': return 'Plástico • Vidrio';
          case 'en': return 'Plastic • Glass';
          default:   return label;
        }
      case 'Plastique • Papier':
        switch (lang) {
          case 'ar': return 'بلاستيك • ورق';
          case 'es': return 'Plástico • Papel';
          case 'en': return 'Plastic • Paper';
          default:   return label;
        }
      case 'Électroménager • Câbles':
        switch (lang) {
          case 'ar': return 'أجهزة منزلية • كابلات';
          case 'es': return 'Electrodomésticos • Cables';
          case 'en': return 'Appliances • Cables';
          default:   return label;
        }
      case 'Tri • Recyclage général':
        switch (lang) {
          case 'ar': return 'الفرز • إعادة التدوير العام';
          case 'es': return 'Clasificación • Reciclaje general';
          case 'en': return 'Sorting • General recycling';
          default:   return label;
        }
      default: return label;
    }
  }

  String get displayAddress {
    final n = name;
    if (n.contains('Casablanca') || n.contains('Aïn Sebaa') ||
        n.contains('Hay Hassani') || n.contains('Twin Center') ||
        n.contains('Bernoussi') || n.contains('Hay Mohammadi') ||
        n.contains('Sidi Maarouf') || n.contains('Maarif') ||
        n.contains('Médiouna') || n.contains('Sidi Hajjaj')) {
      return 'Casablanca';
    }
    if (n.contains('Rabat') || n.contains('Agdal') || n.contains('Hay Riad') ||
        n.contains('Oum Azza') || n.contains('Mohammed V')) {
      return 'Rabat';
    }
    if (n.contains('Salé')) return 'Salé';
    if (n.contains('Tanger') || n.contains('Grottes') || n.contains('Iberia') ||
        n.contains('Malabata')) {
      return 'Tanger';
    }
    if (n.contains('Fès') || n.contains('Fes')) return 'Fès';
    if (n.contains('Agadir') || n.contains('Aït Melloul')) return 'Agadir';
    if (n.contains('Oujda')) return 'Oujda';
    if (n.contains('Meknès') || n.contains('Meknes')) return 'Meknès';
    if (n.contains('Marrakech') || n.contains('Gueliz') || n.contains('Hivernage')) return 'Marrakech';
    if (n.contains('Tétouan') || n.contains('Tetouan')) return 'Tétouan';
    if (n.contains('Nador')) return 'Nador';
    if (n.contains('Al Hoceima')) return 'Al Hoceima';
    if (n.contains('El Jadida')) return 'El Jadida';
    if (n.contains('Essaouira')) return 'Essaouira';
    if (n.contains('Berkane')) return 'Berkane';
    if (n.contains('Figuig')) return 'Figuig';
    if (n.contains('Guelmim')) return 'Guelmim';
    if (n.contains('Laâyoune')) return 'Laâyoune';
    if (n.contains('Dakhla')) return 'Dakhla';
    if (n.contains('Mohammedia')) return 'Mohammedia';
    if (n.contains('Khouribga')) return 'Khouribga';
    if (n.contains('Berrechid') || n.contains('El Gara')) return 'Berrechid';
    if (n.contains('Kénitra') || n.contains('Kenitra')) return 'Kénitra';
    if (n.contains('Béni Mellal') || n.contains('Beni Mellal')) return 'Béni Mellal';
    if (n.contains('Settat')) return 'Settat';
    if (n.contains('Safi')) return 'Safi';
    if (n.contains('Tiznit')) return 'Tiznit';
    if (n.contains('Errachidia')) return 'Errachidia';
    if (n.contains('Taroudant')) return 'Taroudant';
    return 'Maroc';
  }
}
