import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
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

  LatLng? _userPosition;
  bool _isLoadingLocation = true;

  String _selected = 'Tous';
  final _search = TextEditingController();

  static const _filters = [
    'Tous', 'Plastique', 'Verre', 'Papier', 'Compost', 'Piles', 'Électronique', 'Textile',
    'Huiles', 'Métal',
  ];

  String? _selectedCity;
  int? _tapped;

  List<_Point> _osmPoints = [];
  bool _osmLoading = false;

  static const _cityCoords = <String, LatLng>{
    'Casablanca':  LatLng(33.5731, -7.5898),
    'Rabat':       LatLng(33.9716, -6.8498),
    'Tanger':      LatLng(35.7534, -5.7991),
    'Marrakech':   LatLng(31.6350, -8.0350),
    'Fès':         LatLng(33.9779, -4.9993),
    'Agadir':      LatLng(30.4278, -9.5981),
    'Oujda':       LatLng(34.6882, -1.9082),
    'Meknès':      LatLng(33.8957, -5.5555),
    'Kénitra':     LatLng(34.2610, -6.5802),
    'El Jadida':   LatLng(33.2340, -8.5041),
    'Béni Mellal': LatLng(32.3373, -6.3498),
    'Nador':       LatLng(35.1699, -2.9303),
    'Tétouan':     LatLng(35.5889, -5.3626),
    'Safi':        LatLng(32.2994, -9.2372),
    'Mohammedia':  LatLng(33.6866, -7.3828),
    'Laâyoune':    LatLng(27.1536, -13.2030),
    'Dakhla':      LatLng(23.6872, -15.9584),
    'Errachidia':  LatLng(31.9310, -4.4240),
    'Ouarzazate':  LatLng(30.9335, -6.9370),
    'Essaouira':   LatLng(31.5083, -9.7638),
  };

  // Sources : geocycle.com/fr/maroc · ecozalagh.com · smrr.ma · pndm.environnement.gov.ma · marjane.ma
  // Sources vérifiées : geocycle.com/fr/maroc · ecozalagh.com · smrr.ma · pndm.environnement.gov.ma
  static final _staticPoints = <_Point>[
    // ── GEOCYCLE – 4 plateformes industrielles (geocycle.com/fr/maroc) ──────────
    _Point('Geocycle – Bouskoura (Nouaceur)', 'Co-traitement industriel – 75 000 t/an',
        const LatLng(33.3700, -7.6500), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Geocycle – El Gara (Berrechid)', 'Co-traitement déchets dangereux',
        const LatLng(33.2692, -7.5847), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Geocycle – Route de Rabat km19 (Tanger)', 'Co-traitement industriel – 20 000 t/an',
        const LatLng(35.5950, -5.8300), AppColors.primary, Icons.factory_rounded, 'Tous'),
    _Point('Geocycle – Oum Azza (Rabat)', 'Valorisation déchets ménagers',
        const LatLng(33.8703, -6.8100), AppColors.primary, Icons.factory_rounded, 'Tous'),

    // ── ECO ZALAGH – 2 bases logistiques (ecozalagh.com) ─────────────────────────
    _Point('Eco Zalagh – Sidi Hajjaj (Casablanca)', 'Collecte • Tri • Valorisation déchets',
        const LatLng(33.5050, -7.4750), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Eco Zalagh – Gzenaya (Tanger)', 'Collecte • Tri • Valorisation déchets',
        const LatLng(35.6500, -5.9500), AppColors.primary, Icons.recycling_rounded, 'Tous'),

    // ── SMRR – 4 dépôts confirmés (smrr.ma) ──────────────────────────────────────
    _Point('SMRR – Tit Mellil (Casablanca)', 'Récupération PET • Papier • Carton',
        const LatLng(33.5800, -7.5000), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('SMRR – Dépôt Tanger', 'Récupération PET • Papier • Carton',
        const LatLng(35.7534, -5.7991), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('SMRR – Dépôt Agadir', 'Récupération PET • Papier • Carton',
        const LatLng(30.4278, -9.5981), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),
    _Point('SMRR – Dépôt Marrakech', 'Récupération PET • Papier • Carton',
        const LatLng(31.6700, -8.0600), AppColors.plastic, Icons.recycling_rounded, 'Plastique'),

    // ── LOGIPRO / TECMED – DEEE Casablanca ───────────────────────────────────────
    _Point('Logipro DEEE – Maarif (Casablanca)', 'Électronique • Électroménager',
        const LatLng(33.5800, -7.6400), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),
    _Point('TECMED – Zone Industrielle (Casablanca)', 'Électronique • Électroménager',
        const LatLng(33.6500, -7.5000), AppColors.electronics, Icons.electrical_services_rounded, 'Électronique'),

    // ── PNDM – 15 centres opérationnels (pndm.environnement.gov.ma) ──────────────
    _Point('Centre de Valorisation Fès', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.9779, -4.9993), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Oujda', 'PNDM complété • Tri • Recyclage',
        const LatLng(34.6882, -1.9082), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation El Jadida', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.2340, -8.5041), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Essaouira', 'PNDM complété • Tri • Recyclage',
        const LatLng(31.5083, -9.7638), AppColors.primary, Icons.recycling_rounded, 'Tous'),
    _Point('Centre de Valorisation Rabat / Oum Azza', 'PNDM complété • Tri • Recyclage',
        const LatLng(33.8703, -6.8100), AppColors.primary, Icons.recycling_rounded, 'Tous'),
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
  ];

  // ── Points OSM – coordonnées vérifiées Overpass API (Maroc uniquement) ──────
  // Note: anciens points "Laâyoune" supprimés — étaient en réalité à Lanzarote
  // (Îles Canaries, lat~29°N lon~-13.45°W) et non à Laâyoune (27.15°N,-13.20°W)
  static const _osmStaticPoints = <_Point>[
    // Agadir
    _Point('Bac plastique – Agadir', 'Plastique',
        LatLng(30.4106444, -9.5970950), AppColors.plastic, Icons.recycling_rounded, 'Plastique', isOsm: true),
    // Tan-Tan (coordonnées OSM 28.42°N,-11.11°W = Tan-Tan, non Guelmim à 28.99°N,-10.06°W)
    _Point('Ferraille – Tan-Tan', 'Ferraille • Déchets à vendre',
        LatLng(28.4270418, -11.1104707), Color(0xFF546E7A), Icons.hardware_rounded, 'Métal', isOsm: true),
    _Point('Magasin ferraille – Tan-Tan', 'Ferraille',
        LatLng(28.4270565, -11.1119375), Color(0xFF546E7A), Icons.hardware_rounded, 'Métal', isOsm: true),
    _Point('Déchetterie – Tan-Tan', 'Déchets divers',
        LatLng(28.4135111, -11.0973287), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    // Rabat
    _Point('Bac de recyclage – Rabat', 'Conteneur de tri',
        LatLng(34.0157562, -6.8291985), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    _Point('Bac de recyclage – Rabat', 'Conteneur de tri',
        LatLng(34.0152547, -6.8289285), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    _Point('Bac de recyclage – Rabat', 'Conteneur de tri',
        LatLng(34.0161735, -6.8295423), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    // Région Fès-Meknès (coords 34.04°N,-5.00°W ≠ Sidi Kacem 34.22°N,-5.71°W ni Meknès 33.90°N,-5.55°W)
    _Point('Bac de recyclage – région Fès-Meknès', 'Conteneur de tri',
        LatLng(34.0469765, -5.0052651), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    _Point('YUBA CYN – région Fès-Meknès', 'Recyclage industriel',
        LatLng(34.0392846, -5.0084477), AppColors.primary, Icons.factory_rounded, 'Tous', isOsm: true),
    // Casablanca
    _Point('Point S – Casablanca', 'Centre de transfert de déchets',
        LatLng(33.5802729, -7.6378586), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    // Taounate (coords 34.54°N,-4.65°W = Taounate, ~55km nord de Fès)
    _Point('Bac de recyclage – Taounate', 'Conteneur de tri',
        LatLng(34.5448495, -4.6497615), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
    // Tétouan
    _Point('2nd Hands Shop – Tétouan', 'Vêtements • Textile',
        LatLng(35.5639155, -5.3687911), Color(0xFF9C27B0), Icons.checkroom_rounded, 'Textile', isOsm: true),
    // Fnideq
    _Point('Centre de transfert – Fnideq', 'Centre de transfert déchets',
        LatLng(35.9018673, -5.2854477), AppColors.primary, Icons.recycling_rounded, 'Tous', isOsm: true),
  ];
  List<_Point> get _allPoints {
    final seenCoordCat = <String>{};
    final seenNames = <String>{};
    final result = <_Point>[];
    for (final p in [..._staticPoints, ..._osmStaticPoints, ..._osmPoints]) {
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
    if (_selectedCity != null) {
      pts = pts.where((p) => p.name.contains(_selectedCity!)).toList();
    }
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
    _fetchOsmPoints();
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
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _fetchOsmPoints() async {
    if (mounted) setState(() => _osmLoading = true);
    try {
      const query = '[out:json][timeout:60];'
          '(node[amenity=recycling](27.0,-13.2,36.0,-0.5);'
          'node[amenity=waste_transfer_station](27.0,-13.2,36.0,-0.5););'
          'out body;';
      final resp = await Dio().get<String>(
        'https://overpass-api.de/api/interpreter',
        queryParameters: {'data': query},
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      final data = jsonDecode(resp.data ?? '{}') as Map<String, dynamic>;
      final elements = (data['elements'] as List?) ?? [];
      final points = <_Point>[];
      final seen = <String>{};
      for (final e in elements) {
        final lat = (e['lat'] as num?)?.toDouble();
        final lon = (e['lon'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;
        // Exclure les points hors Maroc (ex. Îles Canaries lon < -13.2)
        if (lon < -13.2 || lon > 0.0 || lat < 27.0 || lat > 36.0) continue;
        final key = '${lat.toStringAsFixed(4)},${lon.toStringAsFixed(4)}';
        if (seen.contains(key)) continue;
        seen.add(key);
        final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final name = (tags['name'] as String?)?.isNotEmpty == true
            ? tags['name'] as String
            : 'Point de collecte OSM';
        final cat = _osmCategory(tags);
        final label = _osmMaterials(tags);
        final osmHours = tags['opening_hours'] as String?;
        points.add(_Point(name, label, LatLng(lat, lon),
            _catColor(cat), _catIcon(cat), cat,
            isOsm: true, osmHours: osmHours));
      }
      if (mounted) setState(() { _osmPoints = points; _osmLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _osmLoading = false);
    }
  }

  static String _osmCategory(Map<String, dynamic> t) {
    if (t['recycling:glass_bottles'] == 'yes' || t['recycling:glass'] == 'yes') return 'Verre';
    if (t['recycling:paper'] == 'yes' || t['recycling:cardboard'] == 'yes') return 'Papier';
    if (t['recycling:plastic_bottles'] == 'yes' || t['recycling:plastic'] == 'yes' ||
        t['recycling:plastic_packaging'] == 'yes') { return 'Plastique'; }
    if (t['recycling:cooking_oil'] == 'yes' || t['recycling:engine_oil'] == 'yes') return 'Huiles';
    if (t['recycling:cans'] == 'yes') return 'Métal';
    if (t['recycling:clothes'] == 'yes' || t['recycling:shoes'] == 'yes') return 'Textile';
    if (t['recycling:computers'] == 'yes' || t['recycling:mobile_phones'] == 'yes') return 'Électronique';
    return 'Tous';
  }

  static String _osmMaterials(Map<String, dynamic> t) {
    final m = <String>[];
    if (t['recycling:glass_bottles'] == 'yes' || t['recycling:glass'] == 'yes') m.add('Verre');
    if (t['recycling:paper'] == 'yes') m.add('Papier');
    if (t['recycling:cardboard'] == 'yes') m.add('Carton');
    if (t['recycling:plastic_bottles'] == 'yes' || t['recycling:plastic'] == 'yes') m.add('Plastique');
    if (t['recycling:cooking_oil'] == 'yes') m.add('Huile cuisine');
    if (t['recycling:engine_oil'] == 'yes') m.add('Huile moteur');
    if (t['recycling:cans'] == 'yes') m.add('Canettes');
    if (m.isEmpty) return 'OpenStreetMap';
    return m.join(' • ');
  }

  static Color _catColor(String cat) {
    switch (cat) {
      case 'Plastique':    return AppColors.plastic;
      case 'Verre':        return AppColors.glass;
      case 'Papier':       return AppColors.paper;
      case 'Huiles':       return const Color(0xFF795548);
      case 'Métal':        return const Color(0xFF546E7A);
      case 'Textile':      return const Color(0xFF9C27B0);
      case 'Électronique': return AppColors.electronics;
      default:             return AppColors.primary;
    }
  }

  static IconData _catIcon(String cat) {
    switch (cat) {
      case 'Plastique':    return Icons.recycling_rounded;
      case 'Verre':        return Icons.local_bar_rounded;
      case 'Papier':       return Icons.article_outlined;
      case 'Huiles':       return Icons.oil_barrel_rounded;
      case 'Métal':        return Icons.hardware_rounded;
      case 'Textile':      return Icons.checkroom_rounded;
      case 'Électronique': return Icons.electrical_services_rounded;
      default:             return Icons.recycling_rounded;
    }
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
                      const SizedBox(height: 8),

                      // Sélecteur de ville
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedCity,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary, size: 20),
                            hint: Row(children: [
                              const Icon(Icons.location_city_rounded,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(s.allCities,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  )),
                            ]),
                            selectedItemBuilder: (_) => [
                              null,
                              ..._cityCoords.keys,
                            ].map((city) => Align(
                              alignment: Alignment.centerLeft,
                              child: Row(children: [
                                const Icon(Icons.location_city_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(city ?? s.allCities,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    )),
                              ]),
                            )).toList(),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(s.allCities,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins', fontSize: 13)),
                              ),
                              ..._cityCoords.keys.map((city) =>
                                  DropdownMenuItem<String?>(
                                    value: city,
                                    child: Text(city,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins', fontSize: 13)),
                                  )),
                            ],
                            onChanged: (city) {
                              setState(() {
                                _selectedCity = city;
                                _tapped = null;
                              });
                              if (city != null) {
                                final coord = _cityCoords[city]!;
                                _mapController.move(coord, 13.0);
                              } else {
                                _mapController.move(
                                    const LatLng(31.79, -7.09), 5.5);
                              }
                            },
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 50.ms),
                      const SizedBox(height: 8),

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
                              decoration: BoxDecoration(
                                  color: _userPosition != null ? Colors.blue : AppColors.primary,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCard : Colors.white,
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
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.of(ref.read(localeProvider).languageCode).locatingText,
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Indicateur chargement OSM
          if (_osmLoading)
            Positioned(
              bottom: 140,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colors.white),
                    ),
                    SizedBox(width: 7),
                    Text('OpenStreetMap…', style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 11,
                        color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
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
        child: Icon(icon, size: 20, color: accent ?? AppColors.textPrimary),
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
                if (point.isOsm) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public_rounded, size: 9, color: Colors.blue),
                        SizedBox(width: 3),
                        Text('OpenStreetMap', style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 9,
                            color: Colors.blue, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
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
  final bool isOsm;
  final String? osmHours;

  const _Point(
      this.name, this.label, this.latLng, this.color, this.icon, this.category,
      {this.isOsm = false, this.osmHours});

  String get displayHours => displayHoursFor('fr');

  String displayHoursFor(String lang) {
    if (osmHours != null) return osmHours!;
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
