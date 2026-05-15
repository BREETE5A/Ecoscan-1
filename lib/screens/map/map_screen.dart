import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _markerCtrl;
  String _selected = 'Tous';
  final _search = TextEditingController();

  final _filters = ['Tous', 'Plastique', 'Verre', 'Papier', 'Compost', 'Électronique'];

  static const _points = [
    _Point('Centre de Tri Oujda', 'Plastique • Papier • Verre', 0.35, 0.28, AppColors.plastic, Icons.recycling_rounded),
    _Point('Bac Compost Hay Salam', 'Déchets organiques', 0.55, 0.45, Color(0xFF795548), Icons.compost_rounded),
    _Point('Collecte Électronique', 'Électroménager • Câbles', 0.25, 0.60, AppColors.electronics, Icons.electrical_services_rounded),
    _Point('Point Verre Bd Hassan II', 'Bouteilles • Bocaux', 0.72, 0.35, AppColors.glass, Icons.local_bar_outlined),
    _Point('Déchetterie Centrale', 'Tous types de déchets', 0.62, 0.68, AppColors.primary, Icons.delete_sweep_rounded),
    _Point('Bac Papier Université', 'Journaux • Cartons', 0.42, 0.72, AppColors.paper, Icons.article_outlined),
  ];

  int? _tapped;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Map background
          CustomPaint(
            painter: _MapPainter(isDark: isDark),
            size: Size(size.width, size.height),
          ),

          // Markers
          ...List.generate(_points.length, (i) {
            final p = _points[i];
            final visible = _selected == 'Tous' || p.label.contains(_selected);
            return AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedBuilder(
                animation: _markerCtrl,
                builder: (_, child) {
                  final delay = i / _points.length;
                  final progress = ((_markerCtrl.value - delay).clamp(0.0, 1.0) / (1 - delay))
                      .clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, -20 * (1 - progress)),
                    child: Opacity(opacity: progress, child: child),
                  );
                },
                child: Positioned(
                  left: p.x * size.width - 22,
                  top: p.y * (size.height * 0.65) + 80,
                  child: GestureDetector(
                    onTap: () => setState(() => _tapped = _tapped == i ? null : i),
                    child: _MarkerPin(
                      color: p.color,
                      icon: p.icon,
                      selected: _tapped == i,
                    ),
                  ),
                ),
              ),
            );
          }),

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
                          decoration: InputDecoration(
                            hintText: 'Rechercher un point de collecte...',
                            prefixIcon: const Icon(Icons.search_rounded),
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
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                      color: isDark ? AppColors.darkCard : Colors.white,
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
        ],
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
        color: isDark ? AppColors.darkCard : Colors.white,
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

class _MapPainter extends CustomPainter {
  final bool isDark;
  _MapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? const Color(0xFF0D1F12) : const Color(0xFFE8F5E9);
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF1F3D26) : const Color(0xFFC8E6C9)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routes = [
      [Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3)],
      [Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.6)],
      [Offset(size.width * 0.25, 0), Offset(size.width * 0.28, size.height)],
      [Offset(size.width * 0.6, 0), Offset(size.width * 0.65, size.height)],
      [Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.72)],
    ];

    for (final r in routes) {
      canvas.drawLine(r[0], r[1], roadPaint);
    }

    // Park blocks
    final parkPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1A3A20)
          : const Color(0xFFA5D6A7).withValues(alpha: 0.5);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.35, size.height * 0.35,
                size.width * 0.22, size.height * 0.15),
            const Radius.circular(12)),
        parkPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.05, size.height * 0.62,
                size.width * 0.18, size.height * 0.1),
            const Radius.circular(8)),
        parkPaint);

    // Water
    final waterPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0D2D40)
          : const Color(0xFF90CAF9).withValues(alpha: 0.4);
    final waterPath = Path()
      ..moveTo(size.width * 0.0, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.68,
          size.width * 0.3, size.height * 0.64)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.60,
          size.width * 0.6, size.height * 0.62)
      ..lineTo(size.width * 0.6, size.height * 0.66)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.65,
          size.width * 0.3, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.72,
          size.width * 0.0, size.height * 0.69)
      ..close();
    canvas.drawPath(waterPath, waterPaint);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.isDark != isDark;
}

class _Point {
  final String name;
  final String label;
  final double x;
  final double y;
  final Color color;
  final IconData icon;
  const _Point(this.name, this.label, this.x, this.y, this.color, this.icon);
}
