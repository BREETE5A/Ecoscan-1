import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _selectedCat = 0;

  static const _categories = [
    _Cat('Tous', Icons.category_rounded, AppColors.primary),
    _Cat('Plastique', Icons.opacity_rounded, AppColors.plastic),
    _Cat('Papier', Icons.article_outlined, AppColors.paper),
    _Cat('Verre', Icons.local_bar_outlined, AppColors.glass),
    _Cat('Organique', Icons.compost_rounded, Color(0xFF795548)),
    _Cat('Métal', Icons.hardware_rounded, AppColors.metal),
    _Cat('Électronique', Icons.electrical_services_rounded, AppColors.electronics),
  ];

  static const _items = [
    _Item('Bouteille PET', 'Plastique', true, 'Bac jaune', Icons.opacity_rounded, AppColors.plastic),
    _Item('Canette aluminium', 'Métal', true, 'Bac jaune', Icons.hardware_rounded, AppColors.metal),
    _Item('Journal / Magazine', 'Papier', true, 'Bac bleu', Icons.article_outlined, AppColors.paper),
    _Item('Bouteille en verre', 'Verre', true, 'Conteneur vert', Icons.local_bar_outlined, AppColors.glass),
    _Item('Épluchures de légumes', 'Organique', true, 'Composteur', Icons.compost_rounded, Color(0xFF795548)),
    _Item('Carton ondulé', 'Papier', true, 'Bac bleu', Icons.article_outlined, AppColors.paper),
    _Item('Téléphone portable', 'Électronique', false, 'Point e-déchet', Icons.phone_android_rounded, AppColors.electronics),
    _Item('Sac plastique', 'Plastique', false, 'Borne dédiée', Icons.shopping_bag_outlined, AppColors.plastic),
    _Item('Pile / Batterie', 'Électronique', false, 'Collecteur piles', Icons.battery_full_rounded, AppColors.electronics),
    _Item('Boîte de conserve', 'Métal', true, 'Bac jaune', Icons.hardware_rounded, AppColors.metal),
    _Item('Polystyrène', 'Plastique', false, 'Déchetterie', Icons.opacity_rounded, AppColors.plastic),
    _Item('Restes alimentaires', 'Organique', true, 'Composteur', Icons.restaurant_rounded, Color(0xFF795548)),
  ];

  List<_Item> get _filtered {
    final catFilter = _categories[_selectedCat].name;
    return _items.where((item) {
      final matchCat = catFilter == 'Tous' || item.category == catFilter;
      final matchQuery = _query.isEmpty ||
          item.name.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guide de Tri',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  Text(
                    'Apprenez à trier vos déchets correctement',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 14),
                  // Search
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un déchet...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              child: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: -0.05),
                  const SizedBox(height: 14),
                  // Category chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final active = _selectedCat == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCat = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: active
                                  ? cat.color
                                  : (isDark
                                      ? AppColors.darkCard
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon,
                                    size: 14,
                                    color: active
                                        ? Colors.white
                                        : cat.color),
                                const SizedBox(width: 5),
                                Text(
                                  cat.name,
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
                              ],
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
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 64,
                              color: AppColors.textLight
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucun résultat trouvé',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _GuideItem(
                        item: filtered[i],
                        isDark: isDark,
                      )
                          .animate(delay: (i * 60).ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.05),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final _Item item;
  final bool isDark;
  const _GuideItem({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.category,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: item.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (item.recyclable ? AppColors.primary : AppColors.danger)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.recyclable ? '♻ Recyclable' : '✗ Non recyclable',
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
              const SizedBox(height: 4),
              Text(
                item.bin,
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
    );
  }
}

class _Cat {
  final String name;
  final IconData icon;
  final Color color;
  const _Cat(this.name, this.icon, this.color);
}

class _Item {
  final String name;
  final String category;
  final bool recyclable;
  final String bin;
  final IconData icon;
  final Color color;
  const _Item(this.name, this.category, this.recyclable, this.bin, this.icon, this.color);
}
