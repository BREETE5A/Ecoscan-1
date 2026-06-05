import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_entry.dart';
import '../../models/user_model.dart';
import '../../providers/scan_history_provider.dart';
import '../../providers/user_provider.dart';

// ── Leaderboard Firestore (top 5) ─────────────────────────────────────────────
final _statsLeaderProvider = StreamProvider<List<(String, int, String)>>((ref) {
  const medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('ecoPoints', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs.asMap().entries.map((e) {
            final d = e.value.data();
            final name = ((d['displayName'] as String?) ?? 'User').trim();
            final pts  = (d['ecoPoints'] as num?)?.toInt() ?? 0;
            return (name, pts, medals[e.key]);
          }).toList());
});

// ── Circular gauge painter ────────────────────────────────────────────────────
class _GaugePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color trackColor;

  const _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepFull * progress,
        colors: [color.withValues(alpha: 0.6), color],
        transform: const GradientRotation(0),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepFull, false, trackPaint,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, sweepFull * progress, false, fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _tabIndex = 0;


  static const _days        = ['L', 'M', 'Me', 'J', 'V', 'S', 'D'];
  static const _monthLabels = ['S1', 'S2', 'S3', 'S4'];
  static const _yearLabels  = ['J', 'F', 'M', 'A', 'M', 'J',
      'J', 'A', 'S', 'O', 'N', 'D'];

  // ── Calcul graphique depuis l'historique réel ─────────────────────────────
  List<double> _weekData(List scans) {
    final now = DateTime.now();
    final result = List.filled(7, 0.0);
    for (final scan in scans) {
      final diff = now.difference(scan.scannedAt).inDays;
      if (diff < 7) result[6 - diff] += 0.35;
    }
    return result;
  }

  List<double> _monthData(List scans) {
    final now = DateTime.now();
    final result = List.filled(4, 0.0);
    for (final scan in scans) {
      final diff = now.difference(scan.scannedAt).inDays;
      if (diff < 28) result[(diff ~/ 7).clamp(0, 3)] += 0.35;
    }
    return result.reversed.toList();
  }

  List<double> _yearData(List scans) {
    final now = DateTime.now();
    final result = List.filled(12, 0.0);
    for (final scan in scans) {
      final diff = now.difference(scan.scannedAt).inDays;
      if (diff < 365) result[(diff ~/ 30).clamp(0, 11)] += 0.35;
    }
    return result.reversed.toList();
  }

  List<double> chartData(List scans) {
    switch (_tabIndex) {
      case 1: return _monthData(scans);
      case 2: return _yearData(scans);
      default: return _weekData(scans);
    }
  }

  List<String> get _labels {
    switch (_tabIndex) {
      case 1: return _monthLabels;
      case 2: return _yearLabels;
      default: return _days;
    }
  }


  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s      = AppStrings.of(ref.watch(localeProvider).languageCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Données dynamiques depuis Firestore (stream temps réel)
    final UserModel user        = ref.watch(userStatsStreamProvider).valueOrNull
                                ?? ref.watch(userProvider);
    final List<ScanEntry> history = ref.watch(scanHistoryStreamProvider).valueOrNull
                                  ?? ref.watch(scanHistoryProvider);

    final double totalCo2  = user.co2Saved;   // grammes depuis Firestore
    final int    totalPts  = user.points;      // depuis Firestore
    final int    totalScans = user.scans;      // depuis Firestore
    final double kgRecycled = totalScans * 0.35;
    final int    recyclable  = history.where((e) => e.recyclable).length;
    final double recycleRate = history.isNotEmpty ? recyclable / history.length : 0.0;
    final periods    = [s.periodWeek, s.periodMonth, s.periodYear];


    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.myStats,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  Text(
                    s.impactSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary cards (live from provider)
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _SummaryCard(
                    icon: Icons.scale_rounded,
                    label: s.recycledLabel,
                    value: '${kgRecycled.toStringAsFixed(1)} kg',
                    color: AppColors.primary,
                    isDark: isDark,
                  ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    icon: Icons.co2_rounded,
                    label: s.co2AvoidedLabel,
                    value: '${(totalCo2 / 1000).toStringAsFixed(1)} kg',
                    color: AppColors.teal,
                    isDark: isDark,
                  ).animate(delay: 230.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    icon: Icons.stars_rounded,
                    label: s.points,
                    value: '$totalPts pts',
                    color: AppColors.accent,
                    isDark: isDark,
                  ).animate(delay: 310.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    icon: Icons.recycling_rounded,
                    label: s.sortingRate,
                    value: '${(recycleRate * 100).round()}%',
                    color: AppColors.info,
                    isDark: isDark,
                  ).animate(delay: 390.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tab,
                  tabs: periods.map((p) => Tab(text: p)).toList(),
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  dividerColor: Colors.transparent,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Bar chart
                    Container(
                      height: 220,
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.2 : 0.06),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: BarChart(
                        BarChartData(
                          maxY: math.max(1.0, chartData(history).reduce((a, b) => a > b ? a : b) * 1.3),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              getTooltipItem: (group, _, rod, _) =>
                                  BarTooltipItem(
                                '${rod.toY.toStringAsFixed(1)} kg',
                                const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= _labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _labels[i],
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: List.generate(
                            chartData(history).length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: chartData(history)[i],
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: chartData(history).length > 8 ? 14 : 22,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
                    const SizedBox(height: 20),

                    // Circular gauges row
                    Row(
                      children: [
                        Expanded(
                          child: _CircularGauge(
                            label: s.kgSorted,
                            value: kgRecycled,
                            max: 50,
                            unit: 'kg',
                            color: AppColors.primary,
                            isDark: isDark,
                          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CircularGauge(
                            label: s.co2AvoidedLabel,
                            value: totalCo2 / 1000,
                            max: 20,
                            unit: 'kg',
                            color: AppColors.teal,
                            isDark: isDark,
                          ).animate().fadeIn(duration: 500.ms, delay: 380.ms),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CircularGauge(
                            label: s.points,
                            value: totalPts.toDouble(),
                            max: 1000,
                            unit: 'pts',
                            color: AppColors.accent,
                            isDark: isDark,
                          ).animate().fadeIn(duration: 500.ms, delay: 460.ms),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Leaderboard
                    _LeaderboardSection(
                      isDark: isDark,
                      userPoints: ref.watch(userProvider).points,
                      title: s.weeklyLeaderboard,
                      topLabel: s.top5,
                      youText: s.youLabel,
                    ).animate().fadeIn(duration: 500.ms, delay: 450.ms),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circular gauge widget ─────────────────────────────────────────────────────
class _CircularGauge extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String unit;
  final Color color;
  final bool isDark;

  const _CircularGauge({
    required this.label,
    required this.value,
    required this.max,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (value / max).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, progress, _) => SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _GaugePainter(
                      progress: progress,
                      color: color,
                      trackColor: isDark
                          ? AppColors.darkInput
                          : AppColors.inputBg,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value >= 100
                            ? value.round().toString()
                            : value.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaderboard section ───────────────────────────────────────────────────────
class _LeaderboardSection extends ConsumerWidget {
  final bool isDark;
  final int userPoints;
  final String title;
  final String topLabel;
  final String youText;

  const _LeaderboardSection({
    required this.isDark,
    required this.userPoints,
    required this.title,
    required this.topLabel,
    required this.youText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaders = ref.watch(_statsLeaderProvider).valueOrNull ?? [];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (leaders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(topLabel,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ),
            )
          else
            ...leaders.asMap().entries.map((e) {
              final i      = e.key;
              final leader = e.value;
              final isTop3 = i < 3;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + i * 80),
                curve: Curves.easeOut,
                builder: (_, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                        offset: Offset(20 * (1 - t), 0), child: child)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isTop3
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : (isDark ? AppColors.darkInput : AppColors.inputBg),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(leader.$3, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          leader.$1,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: isTop3 ? FontWeight.w600 : FontWeight.normal,
                            color: isDark ? AppColors.darkText : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${leader.$2} pts',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const Divider(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('👤', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    youText,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '$userPoints pts',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
