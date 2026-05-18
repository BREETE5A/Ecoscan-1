import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _markerCtrl;
  late MapController _mapController;
  String _selected = 'Tous';
  final _search = TextEditingController();

  final _filters = ['Tous', 'Plastique', 'Verre', 'Papier', 'Compost', 'Électronique'];

  // Real recycling collection points in Oujda, Morocco
  static const _points = [
    _Point('Centre de Tri Oujda', 'Plastique • Papier • Verre',
        LatLng(34.6882, -1.9082), AppColors.plastic, Icons.recycling_rounded),
    _Point('Bac Compost Hay Salam', 'Déchets organiques',
        LatLng(34.6752, -1.9178), Color(0xFF795548), Icons.compost_rounded),
    _Point('Collecte Électronique', 'Électroménager • Câbles',
        LatLng(34.6945, -1.9218), AppColors.electronics, Icons.electrical_services_rounded),
    _Point('Point Verre Bd Hassan II', 'Bouteilles • Bocaux',
        LatLng(34.6820, -1.9005), AppColors.glass, Icons.local_bar_outlined),
    _Point('Déchetterie Centrale', 'Tous types de déchets',
        LatLng(34.6715, -1.9135), AppColors.primary, Icons.delete_sweep_rounded),
    _Point('Bac Papier Université', 'Journaux • Cartons',
        LatLng(34.6908, -1.9295), AppColors.paper, Icons.article_outlined),
  ];

  int? _tapped;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _markerCtrl.forward();
  }

  @override
  void dispose() {
    _markerCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  List<_Point> get _visiblePoints {
    if (_selected == 'Tous') return _points;
    return _points.where((p) => p.label.contains(_selected)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Real OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(34.682, -1.912),
              initialZoom: 13.5,
              minZoom: 10,
              maxZoom: 18,
              onTap: (tapPosition, latLng) => setState(() => _tapped = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecoscan.ecoscan',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: List.generate(_visiblePoints.length, (i) {
                  final p = _visiblePoints[i];
                  return Marker(
                    point: p.latLng,
                    width: 56,
                    height: 68,
                    child: GestureDetector(
                      onTap: () {
                        final originalIdx = _points.indexOf(p);
                        setState(() => _tapped = _tapped == originalIdx ? null : originalIdx);
                        _mapController.move(p.latLng, 15.0);
                      },
                      child: AnimatedBuilder(
                        animation: _markerCtrl,
                        builder: (_, child) {
                          final delay = i / _visiblePoints.length;
                          final progress =
                              ((_markerCtrl.value - delay).clamp(0.0, 1.0) /
                                      (1 - delay + 0.001))
                                  .clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, -20 * (1 - progress)),
                            child: Opacity(opacity: progress, child: child),
                          );
                        },
                        child: _MarkerPin(
                          color: p.color,
                          icon: p.icon,
                          selected: _tapped == _points.indexOf(p),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          // Top overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      // Search bar
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
                          onChanged: (v) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Rechercher un point de collecte...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _search.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _search.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
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
                      const SizedBox(height: 12),
                      // Filter chips
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final f = _filters[i];
                            final active = _selected == f;
                            return GestureDetector(
                              onTap: () => setState(() => _selected = f),
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
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  f,
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
                                .animate(delay: (i * 60).ms)
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: -0.1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Info card for selected marker
                if (_tapped != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _InfoCard(
                      point: _points[_tapped!],
                      isDark: isDark,
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
                  ),
                // Bottom legend
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LegendItem(AppColors.primary, 'Général'),
                        _LegendItem(AppColors.plastic, 'Plastique'),
                        _LegendItem(AppColors.glass, 'Verre'),
                        _LegendItem(const Color(0xFF795548), 'Compost'),
                        _LegendItem(AppColors.electronics, 'Électro.'),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                ),
              ],
            ),
          ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _MapBtn(
                  icon: Icons.add_rounded,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.my_location_rounded,
                  onTap: () => _mapController.move(
                      const LatLng(34.682, -1.912), 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

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
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _MarkerPin extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool selected;
  const _MarkerPin(
      {required this.color, required this.icon, required this.selected});

  @override
  State<_MarkerPin> createState() => _MarkerPinState();
}

class _MarkerPinState extends State<_MarkerPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _scaleAnim = Tween(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
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
                  color: Colors.white,
                  width: widget.selected ? 3 : 2),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: widget.selected ? 16 : 8,
                  spreadRadius: widget.selected ? 3 : 0,
                ),
              ],
            ),
            child: Icon(widget.icon,
                color: Colors.white,
                size: widget.selected ? 24 : 18),
          ),
          CustomPaint(
            painter: _PinTailPainter(widget.color),
            size: const Size(10, 8),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}

class _InfoCard extends StatelessWidget {
  final _Point point;
  final bool isDark;
  const _InfoCard({required this.point, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: point.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(point.icon, color: point.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                Text(
                  point.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${point.latLng.latitude.toStringAsFixed(4)}, ${point.latLng.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Itinéraire',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Point {
  final String name;
  final String label;
  final LatLng latLng;
  final Color color;
  final IconData icon;
  const _Point(this.name, this.label, this.latLng, this.color, this.icon);
}
