import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../providers/scan_history_provider.dart';
import '../../models/scan_entry.dart';
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

  Future<void> _clearAllHistory(AppStrings s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearHistory,
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: Text(s.clearHistoryConfirm,
            style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel,
                style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(scanHistoryProvider.notifier).clearHistory();
    }
  }

  List<ScanEntry> _applyFilters(List<ScanEntry> history) {
    return history.where((item) {
      if (_filter == 'recyclable' && !item.recyclable) return false;
      if (_filter == 'nonRecyclable' && item.recyclable) return false;
      if (_searchQuery.isNotEmpty &&
          !item.category.toLowerCase().contains(_searchQuery.toLowerCase())) {
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
    final history = ref.watch(scanHistoryProvider);
    final filtered = _applyFilters(history);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s, isDark, history),
            _buildSummaryRow(s, isDark, history),
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
                          entry: filtered[i],
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

  Widget _buildHeader(AppStrings s, bool isDark, List<ScanEntry> history) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                  '${history.length} ${_filter == 'all' ? (s.totalScans.toLowerCase()) : ''}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ],
            ),
          ),
          if (history.isNotEmpty)
            IconButton(
              tooltip: s.clearHistory,
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
              onPressed: () => _clearAllHistory(s),
            ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AppStrings s, bool isDark, List<ScanEntry> history) {
    final totalPts = history.fold(0, (sum, e) => sum + e.points);
    final recyclableCount = history.where((e) => e.recyclable).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _StatChip(
            label: s.totalScans,
            value: '${history.length}',
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
            value: '$recyclableCount/${history.length}',
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
                    color: active ? Colors.white : AppColors.textSecondary,
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
  final ScanEntry entry;
  final bool isDark;
  final String lang;
  final int delay;

  const _HistoryTile({
    required this.entry,
    required this.isDark,
    required this.lang,
    required this.delay,
  });

  String get _category => entry.category;
  // ScanEntry.binColor is capitalized ("Jaune", "Vert", "Bleu", "Noir", "Marron")
  String get _binColorNorm => entry.binColor.toLowerCase();
  bool get _recyclable => entry.recyclable;

  static const _categoryTranslations = <String, List<String>>{
    // key: [fr, en, ar, es]
    'plastique':    ['Plastique',     'Plastic',      'بلاستيك',       'Plástico'],
    'plastic':      ['Plastique',     'Plastic',      'بلاستيك',       'Plástico'],
    'verre':        ['Verre',         'Glass',        'زجاج',          'Vidrio'],
    'glass':        ['Verre',         'Glass',        'زجاج',          'Vidrio'],
    'métal':        ['Métal',         'Metal',        'معدن',          'Metal'],
    'metal':        ['Métal',         'Metal',        'معدن',          'Metal'],
    'papier':       ['Papier',        'Paper',        'ورق',           'Papel'],
    'paper':        ['Papier',        'Paper',        'ورق',           'Papel'],
    'carton':       ['Carton',        'Cardboard',    'كرتون',         'Cartón'],
    'cardboard':    ['Carton',        'Cardboard',    'كرتون',         'Cartón'],
    'électronique': ['Électronique',  'Electronic',   'إلكترونيات',    'Electrónico'],
    'electronique': ['Électronique',  'Electronic',   'إلكترونيات',    'Electrónico'],
    'electronic':   ['Électronique',  'Electronic',   'إلكترونيات',    'Electrónico'],
    'deee':         ['Électronique',  'Electronic',   'إلكترونيات',    'Electrónico'],
    'organique':    ['Organique',     'Organic',      'عضوي',          'Orgánico'],
    'organic':      ['Organique',     'Organic',      'عضوي',          'Orgánico'],
    'vetement':     ['Vêtement',      'Clothing',     'ملابس',         'Ropa'],
    'vêtement':     ['Vêtement',      'Clothing',     'ملابس',         'Ropa'],
    'clothing':     ['Vêtement',      'Clothing',     'ملابس',         'Ropa'],
    'textile':      ['Textile',       'Textile',      'منسوجات',       'Textil'],
    'pile':         ['Pile/Batterie', 'Battery',      'بطارية',        'Batería'],
    'battery':      ['Pile/Batterie', 'Battery',      'بطارية',        'Batería'],
    'huile':        ['Huile usagée',  'Used oil',     'زيت مستعمل',    'Aceite usado'],
    'unknown':      ['Inconnu',       'Unknown',      'غير معروف',     'Desconocido'],
    'inconnu':      ['Inconnu',       'Unknown',      'غير معروف',     'Desconocido'],
    'chaussures':   ['Chaussures',    'Shoes',        'أحذية',         'Zapatos'],
    'trash':        ['Déchet général','General waste', 'نفايات عامة',  'Residuo general'],
  };

  String _translateCategory(String lang) {
    final t = _categoryTranslations[_category.toLowerCase().trim()];
    if (t == null) return _category;
    switch (lang) {
      case 'en': return t[1];
      case 'ar': return t[2];
      case 'es': return t[3];
      default:   return t[0];
    }
  }

  String get _relativeTime {
    final diff = DateTime.now().difference(entry.scannedAt);
    if (lang == 'ar') {
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
      if (diff.inDays == 1) return 'أمس';
      return 'منذ ${diff.inDays} أيام';
    } else if (lang == 'en') {
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } else if (lang == 'es') {
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
      if (diff.inDays == 1) return 'Ayer';
      return 'Hace ${diff.inDays} días';
    } else {
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
      if (diff.inDays == 1) return 'Hier';
      return 'Il y a ${diff.inDays} j';
    }
  }

  IconData get _icon {
    switch (_category.toLowerCase()) {
      case 'plastique':
      case 'plastic':
        return Icons.local_drink_rounded;
      case 'verre':
      case 'glass':
        return Icons.wine_bar_rounded;
      case 'métal':
      case 'metal':
        return Icons.breakfast_dining_rounded;
      case 'papier':
      case 'paper':
        return Icons.article_rounded;
      case 'carton':
      case 'cardboard':
        return Icons.inventory_2_rounded;
      case 'électronique':
      case 'electronique':
      case 'electronic':
      case 'deee':
        return Icons.phone_android_rounded;
      case 'organique':
      case 'organic':
        return Icons.eco_rounded;
      case 'vetement':
      case 'vêtement':
      case 'clothing':
      case 'textile':
        return Icons.checkroom_rounded;
      case 'pile':
      case 'battery':
        return Icons.battery_charging_full_rounded;
      case 'chaussures':
        return Icons.hiking_rounded;
      case 'dangereux':
        return Icons.warning_rounded;
      case 'bois':
        return Icons.forest_rounded;
      case 'trash':
        return Icons.delete_rounded;
      default:
        return Icons.delete_outline_rounded;
    }
  }

  Color get _color {
    switch (_binColorNorm) {
      case 'jaune':
        return AppColors.plastic;
      case 'vert':
        return AppColors.glass;
      case 'bleu':
        return AppColors.paper;
      case 'gris':
        return AppColors.metal;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recyclableLabel = switch (lang) {
      'en' => _recyclable ? 'Recyclable' : 'Non-recyclable',
      'ar' => _recyclable ? 'قابل للتدوير' : 'غير قابل للتدوير',
      'es' => _recyclable ? 'Reciclable' : 'No reciclable',
      _    => _recyclable ? 'Recyclable' : 'Non recyclable',
    };

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
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translateCategory(lang),
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
                      _recyclable
                          ? Icons.recycling_rounded
                          : Icons.delete_outline_rounded,
                      size: 12,
                      color: _recyclable
                          ? AppColors.primary
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _relativeTime,
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
                '+${entry.points} pts',
                style: const TextStyle(
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
                  color: _recyclable
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  recyclableLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _recyclable ? AppColors.primary : AppColors.danger,
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
