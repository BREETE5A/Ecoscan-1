import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all';
  String _searchQuery = '';

  static const _items = [
    _ScanItem(
      name: 'Bouteille en plastique',
      nameEn: 'Plastic bottle',
      nameAr: 'زجاجة بلاستيكية',
      category: 'plastic',
      recyclable: true,
      points: 15,
      time: 'Il y a 2 h',
      timeEn: '2h ago',
      timeAr: 'منذ ساعتين',
      icon: Icons.local_drink_rounded,
      color: AppColors.plastic,
    ),
    _ScanItem(
      name: 'Boîte de conserve',
      nameEn: 'Metal can',
      nameAr: 'علبة معلبات',
      category: 'metal',
      recyclable: true,
      points: 20,
      time: 'Il y a 5 h',
      timeEn: '5h ago',
      timeAr: 'منذ 5 ساعات',
      icon: Icons.breakfast_dining_rounded,
      color: AppColors.metal,
    ),
    _ScanItem(
      name: 'Journal',
      nameEn: 'Newspaper',
      nameAr: 'جريدة',
      category: 'paper',
      recyclable: true,
      points: 10,
      time: 'Hier, 14:30',
      timeEn: 'Yesterday, 14:30',
      timeAr: 'أمس، 14:30',
      icon: Icons.article_rounded,
      color: AppColors.paper,
    ),
    _ScanItem(
      name: 'Bouteille en verre',
      nameEn: 'Glass bottle',
      nameAr: 'زجاجة زجاجية',
      category: 'glass',
      recyclable: true,
      points: 25,
      time: 'Hier, 09:15',
      timeEn: 'Yesterday, 09:15',
      timeAr: 'أمس، 09:15',
      icon: Icons.wine_bar_rounded,
      color: AppColors.glass,
    ),
    _ScanItem(
      name: 'Emballage alimentaire',
      nameEn: 'Food packaging',
      nameAr: 'عبوة غذائية',
      category: 'plastic',
      recyclable: false,
      points: 5,
      time: 'Il y a 2 j',
      timeEn: '2 days ago',
      timeAr: 'منذ يومين',
      icon: Icons.fastfood_rounded,
      color: AppColors.textSecondary,
    ),
    _ScanItem(
      name: 'Téléphone cassé',
      nameEn: 'Broken phone',
      nameAr: 'هاتف مكسور',
      category: 'electronics',
      recyclable: true,
      points: 40,
      time: 'Il y a 3 j',
      timeEn: '3 days ago',
      timeAr: 'منذ 3 أيام',
      icon: Icons.phone_android_rounded,
      color: AppColors.electronics,
    ),
    _ScanItem(
      name: 'Épluchures de légumes',
      nameEn: 'Vegetable peelings',
      nameAr: 'قشور الخضروات',
      category: 'organic',
      recyclable: true,
      points: 10,
      time: 'Il y a 4 j',
      timeEn: '4 days ago',
      timeAr: 'منذ 4 أيام',
      icon: Icons.eco_rounded,
      color: AppColors.organic,
    ),
  ];

  List<_ScanItem> get _filtered {
    return _items.where((item) {
      if (_filter == 'recyclable' && !item.recyclable) return false;
      if (_filter == 'nonRecyclable' && item.recyclable) return false;
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.nameEn.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s, isDark),
            _buildSummaryRow(s, isDark),
            _buildSearchBar(s, isDark),
            _buildFilterChips(s, isDark),
            const SizedBox(height: 4),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty(s, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryTile(
                          item: filtered[i],
                          isDark: isDark,
                          lang: lang,
                          delay: i * 60,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.historyTitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          Text(
            '${_items.length} ${_filter == 'all' ? (s.totalScans.toLowerCase()) : ''}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AppStrings s, bool isDark) {
    final totalPts = _items.fold(0, (sum, i) => sum + i.points);
    final recyclableCount = _items.where((i) => i.recyclable).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _StatChip(
            label: s.totalScans,
            value: '${_items.length}',
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
            isDark: isDark,
            delay: 100,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: s.pointsEarned,
            value: '+$totalPts',
            icon: Icons.stars_rounded,
            color: AppColors.accent,
            isDark: isDark,
            delay: 180,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: s.recyclable,
            value: '$recyclableCount/${_items.length}',
            icon: Icons.recycling_rounded,
            color: AppColors.teal,
            isDark: isDark,
            delay: 260,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: s.search,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
    );
  }

  Widget _buildFilterChips(AppStrings s, bool isDark) {
    final filters = [
      ('all', s.filterAll),
      ('recyclable', s.recyclable),
      ('nonRecyclable', s.nonRecyclable),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: filters.map((f) {
          final active = _filter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildEmpty(AppStrings s, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.05, 1.05),
                duration: 1500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            s.noHistory,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final int delay;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: delay))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, duration: 400.ms),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _ScanItem item;
  final bool isDark;
  final String lang;
  final int delay;

  const _HistoryTile({
    required this.item,
    required this.isDark,
    required this.lang,
    required this.delay,
  });

  String get _name => lang == 'en'
      ? item.nameEn
      : lang == 'ar'
          ? item.nameAr
          : item.name;

  String get _time => lang == 'en'
      ? item.timeEn
      : lang == 'ar'
          ? item.timeAr
          : item.time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      item.recyclable
                          ? Icons.recycling_rounded
                          : Icons.delete_outline_rounded,
                      size: 12,
                      color: item.recyclable
                          ? AppColors.primary
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _time,
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${item.points} pts',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.recyclable
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lang == 'en'
                      ? (item.recyclable ? 'Recyclable' : 'Non-recyclable')
                      : lang == 'ar'
                          ? (item.recyclable
                              ? 'قابل للتدوير'
                              : 'غير قابل للتدوير')
                          : (item.recyclable ? 'Recyclable' : 'Non recyclable'),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: item.recyclable
                        ? AppColors.primary
                        : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.05, duration: 350.ms);
  }
}

class _ScanItem {
  final String name;
  final String nameEn;
  final String nameAr;
  final String category;
  final bool recyclable;
  final int points;
  final String time;
  final String timeEn;
  final String timeAr;
  final IconData icon;
  final Color color;

  const _ScanItem({
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.category,
    required this.recyclable,
    required this.points,
    required this.time,
    required this.timeEn,
    required this.timeAr,
    required this.icon,
    required this.color,
  });
}
