import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_strings.dart';
import '../../models/listing_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../theme/app_theme.dart';

// ── Helpers ────────────────────────────────────────────────────────────────────
Color typeColor(String type) => switch (type) {
  'don'     => const Color(0xFF27AE60),
  'vente'   => const Color(0xFF2980B9),
  'echange' => const Color(0xFFE67E22),
  _         => AppColors.primary,
};

IconData typeIcon(String type) => switch (type) {
  'don'     => Icons.volunteer_activism_rounded,
  'vente'   => Icons.sell_rounded,
  'echange' => Icons.swap_horiz_rounded,
  _         => Icons.tag_rounded,
};

String typeLabel(String type, AppStrings s) => switch (type) {
  'don'     => s.listingTypeDon,
  'vente'   => s.listingTypeVente,
  'echange' => s.listingTypeEchange,
  _         => type,
};

const _categories = [
  'Plastique', 'Verre', 'Métal', 'Papier', 'Textile',
  'Électronique', 'Organique', 'Mobilier', 'Autre',
];

const _moroccanCities = [
  'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger', 'Agadir',
  'Meknès', 'Oujda', 'Kénitra', 'Tétouan', 'Safi', 'El Jadida',
  'Béni Mellal', 'Nador', 'Mohammedia', 'Khouribga', 'Settat',
  'Berrechid', 'Khémisset', 'Inezgane', 'Larache', 'Ksar El-Kébir',
  'Guelmim', 'Berkane', 'Taourirt', 'Errachidia', 'Ouarzazate',
  'Taza', 'Ifrane', 'Azrou', 'Taroudant', 'Tiznit', 'Chefchaouen',
  'Al Hoceïma', 'Dakhla', 'Laâyoune', 'Smara', 'Essaouira',
  'Benslimane', 'Médiouna', 'Nouaceur', 'Salé', 'Témara',
  'Skhirat', 'Aïn Sebaâ', 'Hay Hassani', 'Aïn Chock', 'Sidi Bernoussi',
];

enum _SortMode { date, priceAsc }

// ── Écran principal ────────────────────────────────────────────────────────────
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String    _typeFilter = 'all';
  String    _cityFilter = '';
  _SortMode _sort       = _SortMode.date;

  final _searchCtrl = TextEditingController();
  bool _showSearch  = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ListingModel> _apply(List<ListingModel> all) {
    var list = all.toList();

    // Filtre type
    if (_typeFilter != 'all') list = list.where((l) => l.type == _typeFilter).toList();

    // Filtre ville
    if (_cityFilter.isNotEmpty) {
      list = list.where((l) =>
          l.city.toLowerCase().contains(_cityFilter.toLowerCase())).toList();
    }

    // Recherche texte
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((l) =>
          l.title.toLowerCase().contains(q) ||
          l.category.toLowerCase().contains(q) ||
          l.city.toLowerCase().contains(q)).toList();
    }

    // Tri
    switch (_sort) {
      case _SortMode.date:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortMode.priceAsc:
        list.sort((a, b) {
          final pa = a.price ?? 0;
          final pb = b.price ?? 0;
          return pa.compareTo(pb);
        });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final lang  = ref.watch(localeProvider).languageCode;
    final s     = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listingsAsync = ref.watch(marketplaceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(s, isDark),
            if (_showSearch) _buildSearchBar(s, isDark),
            _buildTypeFilters(s, isDark),
            _buildSortBar(s, isDark),
            Expanded(
              child: listingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (_, _) => const SizedBox.shrink(),
                data: (all) {
                  final items = _apply(all);
                  if (items.isEmpty) return _buildEmpty(s, isDark);
                  return _buildGrid(items, s, isDark);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, s, isDark),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(s.addListing,
            style: const TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
      child: Row(children: [
        Expanded(child: Text(s.marketplaceTitle,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textPrimary))
            .animate().fadeIn(duration: 400.ms).slideY(begin: -0.1)),
        IconButton(
          icon: Icon(_showSearch ? Icons.search_off_rounded : Icons.search_rounded),
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
          onPressed: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchCtrl.clear(); }),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded),
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
          tooltip: s.myAds,
          onPressed: () => context.push('/marketplace/my'),
        ),
      ]),
    );
  }

  // ── Barre de recherche ───────────────────────────────────────────────────────
  Widget _buildSearchBar(AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: s.searchHint,
          hintStyle: const TextStyle(fontFamily: 'Poppins',
              fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: _cityFilter.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => setState(() => _cityFilter = ''))
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Filtres type (Tous / Don / Vente / Échange) ──────────────────────────────
  Widget _buildTypeFilters(AppStrings s, bool isDark) {
    final filters = [
      ('all',     s.filterAll,          AppColors.primary),
      ('don',     s.listingTypeDon,     const Color(0xFF27AE60)),
      ('vente',   s.listingTypeVente,   const Color(0xFF2980B9)),
      ('echange', s.listingTypeEchange, const Color(0xFFE67E22)),
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: filters.map((f) {
          final sel = _typeFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _typeFilter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? f.$3 : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? f.$3 : f.$3.withValues(alpha: 0.3)),
                ),
                child: Text(f.$2, style: TextStyle(fontFamily: 'Poppins',
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : f.$3)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Barre de tri + filtre ville ──────────────────────────────────────────────
  Widget _buildSortBar(AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(children: [
        // Tri
        Expanded(child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _SortChip(s.sortRecent,   _SortMode.date,     _sort, isDark,
                () => setState(() => _sort = _SortMode.date)),
            const SizedBox(width: 8),
            _SortChip(s.sortPriceAsc, _SortMode.priceAsc, _sort, isDark,
                () => setState(() => _sort = _SortMode.priceAsc)),
          ]),
        )),
        // Filtre ville
        GestureDetector(
          onTap: () => _showCityFilter(context, isDark, s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _cityFilter.isNotEmpty
                  ? AppColors.primary
                  : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _cityFilter.isNotEmpty
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.location_on_rounded, size: 14,
                  color: _cityFilter.isNotEmpty ? Colors.white : AppColors.primary),
              const SizedBox(width: 4),
              Text(_cityFilter.isNotEmpty ? _cityFilter : s.listingCity,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _cityFilter.isNotEmpty ? Colors.white : AppColors.primary)),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showCityFilter(BuildContext ctx, bool isDark, AppStrings s) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CityFilterSheet(
        isDark: isDark, s: s,
        current: _cityFilter,
        onSelected: (city) {
          setState(() => _cityFilter = city);
          Navigator.pop(ctx);
        },
        onClear: () {
          setState(() => _cityFilter = '');
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildEmpty(AppStrings s, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.storefront_outlined, size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(s.noListings, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildGrid(List<ListingModel> items, AppStrings s, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12,
        mainAxisSpacing: 12, childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => ListingCard(
        listing: items[i], isDark: isDark, s: s,
        onTap: () => context.push('/marketplace/${items[i].id}'),
      ).animate(delay: (i * 50).ms)
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.92, 0.92)),
    );
  }

  void _showAddSheet(BuildContext ctx, AppStrings s, bool isDark) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddListingSheet(s: s, isDark: isDark),
    );
  }
}

// ── Chip tri ──────────────────────────────────────────────────────────────────
class _SortChip extends StatelessWidget {
  final String label;
  final _SortMode mode;
  final _SortMode current;
  final bool isDark;
  final VoidCallback onTap;
  const _SortChip(this.label, this.mode, this.current, this.isDark, this.onTap);

  @override
  Widget build(BuildContext context) {
    final sel = mode == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? AppColors.teal : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel ? AppColors.teal : AppColors.teal.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : AppColors.teal)),
      ),
    );
  }
}

// ── Filtre ville : liste des villes marocaines ────────────────────────────────
class _CityFilterSheet extends StatefulWidget {
  final bool isDark;
  final AppStrings s;
  final String current;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;
  const _CityFilterSheet({
    required this.isDark, required this.s, required this.current,
    required this.onSelected, required this.onClear,
  });

  @override
  State<_CityFilterSheet> createState() => _CityFilterSheetState();
}

class _CityFilterSheetState extends State<_CityFilterSheet> {
  final _search = TextEditingController();
  late List<String> _filtered;

  static final _sorted = [..._moroccanCities]..sort();

  @override
  void initState() {
    super.initState();
    _filtered = _sorted;
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? _sorted
          : _sorted.where((c) => c.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return DraggableScrollableSheet(
      initialChildSize: 0.65, maxChildSize: 0.9, minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text(widget.s.filterByCity,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary))),
              if (widget.current.isNotEmpty)
                TextButton(
                  onPressed: widget.onClear,
                  child: Text(widget.s.showAll,
                      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: _onSearch,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.s.searchCityHint,
                hintStyle: const TextStyle(fontFamily: 'Poppins',
                    color: AppColors.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true,
                fillColor: isDark ? AppColors.darkInput : AppColors.inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final city = _filtered[i];
                final sel  = city == widget.current;
                return ListTile(
                  dense: true,
                  onTap: () => widget.onSelected(city),
                  leading: Icon(Icons.location_on_rounded,
                      size: 18,
                      color: sel ? AppColors.primary : AppColors.textSecondary),
                  title: Text(city,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel
                              ? AppColors.primary
                              : (isDark ? AppColors.darkText : AppColors.textPrimary))),
                  trailing: sel
                      ? const Icon(Icons.check_rounded, size: 16, color: AppColors.primary)
                      : null,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Carte annonce (exportée pour réutilisation) ───────────────────────────────
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;
  final AppStrings s;
  final VoidCallback onTap;

  const ListingCard({
    super.key, required this.listing, required this.isDark,
    required this.s, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor(listing.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Photo
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(children: [
              listing.imageUrls.isNotEmpty
                  ? Image.network(listing.imageUrls.first,
                      height: 130, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(color))
                  : _placeholder(color),
              // Badge nbre photos
              if (listing.imageUrls.length > 1)
                Positioned(top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.photo_library_rounded, size: 10, color: Colors.white),
                      const SizedBox(width: 3),
                      Text('${listing.imageUrls.length}',
                          style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 9, color: Colors.white)),
                    ]),
                  )),
              // Badge vendeur de confiance
              if (listing.trustedSeller)
                Positioned(top: 6, left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.verified_rounded, size: 10, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(s.trustedLabel, style: const TextStyle(fontFamily: 'Poppins',
                          fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                    ]),
                  )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Badge type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(typeIcon(listing.type), size: 10, color: color),
                  const SizedBox(width: 3),
                  Text(typeLabel(listing.type, s),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
                          fontWeight: FontWeight.w600, color: color)),
                ]),
              ),
              const SizedBox(height: 5),
              Text(listing.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary)),
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 10, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Expanded(child: Text(listing.city, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        color: AppColors.textSecondary))),
              ]),
              // Étoiles
              if (listing.reviewCount > 0) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFD700)),
                  const SizedBox(width: 2),
                  Text('${listing.reviewAvg.toStringAsFixed(1)} (${listing.reviewCount})',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                          color: AppColors.textSecondary)),
                ]),
              ],
              const SizedBox(height: 4),
              listing.type == 'vente' && listing.price != null
                  ? Text('${listing.price!.round()} DH',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.bold, color: color))
                  : Text(listing.type == 'don' ? s.freeLabel : s.swapLabel,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                          fontWeight: FontWeight.w600, color: color)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder(Color color) => Container(
    height: 130,
    color: color.withValues(alpha: 0.1),
    child: Center(child: Icon(Icons.image_outlined, size: 36,
        color: color.withValues(alpha: 0.4))),
  );
}

// ── Formulaire ajout annonce ──────────────────────────────────────────────────
class AddListingSheet extends ConsumerStatefulWidget {
  final AppStrings s;
  final bool isDark;
  const AddListingSheet({super.key, required this.s, required this.isDark});

  @override
  ConsumerState<AddListingSheet> createState() => _AddListingSheetState();
}

class _AddListingSheetState extends ConsumerState<AddListingSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _waCtrl    = TextEditingController();

  String       _type         = 'don';
  String       _category     = 'Plastique';
  String       _selectedCity = '';
  String       _phonePrefix  = '+212';
  String       _waPrefix     = '+212';
  List<File>   _images       = [];
  bool         _loading      = false;
  bool         _submitted    = false;

  static const _countryCodes = [
    ('+212', '🇲🇦 Maroc'),
    ('+33',  '🇫🇷 France'),
    ('+34',  '🇪🇸 Espagne'),
    ('+32',  '🇧🇪 Belgique'),
    ('+31',  '🇳🇱 Pays-Bas'),
    ('+44',  '🇬🇧 Royaume-Uni'),
    ('+49',  '🇩🇪 Allemagne'),
    ('+39',  '🇮🇹 Italie'),
    ('+351', '🇵🇹 Portugal'),
    ('+1',   '🇺🇸 USA/Canada'),
    ('+213', '🇩🇿 Algérie'),
    ('+216', '🇹🇳 Tunisie'),
    ('+966', '🇸🇦 Arabie Saoudite'),
    ('+971', '🇦🇪 Émirats'),
    ('+974', '🇶🇦 Qatar'),
  ];

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _priceCtrl, _phoneCtrl, _waCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages(ImageSource src) async {
    if (src == ImageSource.gallery) {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 75, limit: 4);
      setState(() {
        final combined = [..._images, ...picked.map((x) => File(x.path))];
        _images = combined.take(4).toList();
      });
    } else {
      final picked = await ImagePicker().pickImage(source: src, imageQuality: 75);
      if (picked != null && _images.length < 4) {
        setState(() => _images.add(File(picked.path)));
      }
    }
  }


  void _pickCity(BuildContext ctx, bool isDark, AppStrings s) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CityFilterSheet(
        isDark: isDark, s: s,
        current: _selectedCity,
        onSelected: (city) {
          setState(() => _selectedCity = city);
          Navigator.pop(ctx);
        },
        onClear: () {
          setState(() => _selectedCity = '');
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity.isEmpty) return;
    setState(() => _loading = true);
    final ok = await ref.read(marketplaceActionsProvider).addListing(
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type:        _type,
      category:    _category,
      price:       _type == 'vente' ? double.tryParse(_priceCtrl.text) : null,
      city:        _selectedCity,
      phone:       '$_phonePrefix${_phoneCtrl.text.trim()}',
      whatsapp:    _waCtrl.text.trim().isEmpty ? '' : '$_waPrefix${_waCtrl.text.trim()}',
      imageFiles:  _images,
      latitude:    null,
      longitude:   null,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok != null) {
      Navigator.pop(context);
      final pts = _type == 'don' ? 15 : 5;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: typeColor(_type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: Text(widget.s.listingPublished(pts),
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s     = widget.s;
    final isDark = widget.isDark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.93, maxChildSize: 0.96, minChildSize: 0.5,
          expand: false,
          builder: (_, ctrl) => Form(
            key: _formKey,
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 14),
                Text(s.addListing, style: TextStyle(fontFamily: 'Poppins',
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary)),
                const SizedBox(height: 18),

                // ── Photos (jusqu'à 4) ──────────────────────────────────────
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((e) => Stack(children: [
                        Container(
                          width: 100, height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(e.value, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(top: 2, right: 12,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(e.key)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded,
                                  size: 12, color: Colors.white),
                            ),
                          )),
                      ])),
                      if (_images.length < 4)
                        GestureDetector(
                          onTap: () => _showPicker(context, s),
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  style: BorderStyle.solid),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 28,
                                  color: AppColors.primary.withValues(alpha: 0.6)),
                              const SizedBox(height: 4),
                              Text(s.addPhoto, textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                                      color: AppColors.primary.withValues(alpha: 0.8))),
                            ]),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Type ────────────────────────────────────────────────────
                Row(children: ['don', 'vente', 'echange'].map((t) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _type = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _type == t ? typeColor(t)
                              : (isDark ? AppColors.darkCard : AppColors.inputBg),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(children: [
                          Icon(typeIcon(t),
                              color: _type == t ? Colors.white : typeColor(t), size: 20),
                          const SizedBox(height: 4),
                          Text(typeLabel(t, s), style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _type == t ? Colors.white : typeColor(t))),
                        ]),
                      ),
                    ),
                  ),
                )).toList()),
                const SizedBox(height: 14),

                _Field(ctrl: _titleCtrl, label: s.listingTitle, isDark: isDark,
                    validator: (v) => v!.isEmpty ? '${s.listingTitle} requis' : null),
                const SizedBox(height: 10),
                _Field(ctrl: _descCtrl, label: s.listingDesc, isDark: isDark, maxLines: 3),
                const SizedBox(height: 10),
                if (_type == 'vente') ...[
                  _Field(ctrl: _priceCtrl, label: s.listingPrice, isDark: isDark,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  const SizedBox(height: 10),
                ],
                _DropField(label: s.listingCategory, value: _category,
                    items: _categories, isDark: isDark,
                    onChanged: (v) => setState(() => _category = v!)),
                const SizedBox(height: 10),
                // ── Sélecteur de ville ──────────────────────────────────
                GestureDetector(
                  onTap: () => _pickCity(context, isDark, s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: _selectedCity.isEmpty
                          ? null
                          : Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Row(children: [
                      Icon(Icons.location_on_rounded, size: 18,
                          color: _selectedCity.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        _selectedCity.isEmpty ? s.listingCity : _selectedCity,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                            color: _selectedCity.isEmpty
                                ? AppColors.textSecondary
                                : (isDark ? AppColors.darkText : AppColors.textPrimary)),
                      )),
                      Icon(Icons.arrow_drop_down_rounded, size: 22,
                          color: AppColors.textSecondary),
                    ]),
                  ),
                ),
                if (_submitted && _selectedCity.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(s.cityRequiredErr,
                        style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 11, color: Colors.red)),
                  ),
                const SizedBox(height: 10),
                _PhoneField(
                  ctrl: _phoneCtrl, label: s.listingPhone, s: s,
                  prefix: _phonePrefix, isDark: isDark,
                  countryCodes: _countryCodes,
                  onPrefixChanged: (v) => setState(() => _phonePrefix = v),
                  required: true,
                ),
                const SizedBox(height: 10),
                _PhoneField(
                  ctrl: _waCtrl, label: s.listingWhatsapp, s: s,
                  prefix: _waPrefix, isDark: isDark,
                  countryCodes: _countryCodes,
                  onPrefixChanged: (v) => setState(() => _waPrefix = v),
                  required: false,
                ),
                const SizedBox(height: 20),

                // ── Info EcoPoints ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor(_type).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.star_rounded, color: typeColor(_type), size: 18),
                    const SizedBox(width: 8),
                    Text(_type == 'don'
                        ? widget.s.ecoPointsDon
                        : widget.s.ecoPointsAd(5),
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                            fontWeight: FontWeight.w600, color: typeColor(_type))),
                  ]),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(s.publishAd, style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext ctx, AppStrings s) {
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
            title: Text(widget.s.cameraLabel, style: const TextStyle(fontFamily: 'Poppins')),
            onTap: () { Navigator.pop(ctx); _pickImages(ImageSource.camera); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
            title: Text(widget.s.galleryMultiple, style: const TextStyle(fontFamily: 'Poppins')),
            onTap: () { Navigator.pop(ctx); _pickImages(ImageSource.gallery); },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Champs réutilisables ──────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool isDark;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({required this.ctrl, required this.label, required this.isDark,
      this.maxLines = 1, this.keyboardType, this.inputFormatters, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      keyboardType: keyboardType, inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
          color: isDark ? AppColors.darkText : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
            color: AppColors.textSecondary),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _DropField({required this.label, required this.value,
      required this.items, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label,
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                color: AppColors.textSecondary),
            border: InputBorder.none),
        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.textPrimary),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Champ téléphone avec sélecteur de pays ────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String prefix;
  final bool isDark;
  final bool required;
  final AppStrings s;
  final List<(String, String)> countryCodes;
  final ValueChanged<String> onPrefixChanged;

  const _PhoneField({
    required this.ctrl, required this.label, required this.prefix,
    required this.isDark, required this.s, required this.countryCodes,
    required this.onPrefixChanged, required this.required,
  });

  void _showCountryPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 10),
          Text(s.countryCodeLabel, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...countryCodes.map((c) => ListTile(
            dense: true,
            leading: Text(c.$2.split(' ').first,
                style: const TextStyle(fontSize: 20)),
            title: Text(c.$2.split(' ').sublist(1).join(' '),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary)),
            trailing: Text(c.$1, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.primary)),
            selected: c.$1 == prefix,
            selectedColor: AppColors.primary,
            onTap: () { onPrefixChanged(c.$1); Navigator.pop(ctx); },
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Bouton préfixe pays
      GestureDetector(
        onTap: () => _showCountryPicker(context),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              countryCodes.firstWhere((c) => c.$1 == prefix,
                  orElse: () => countryCodes.first).$2.split(' ').first,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(prefix, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.primary)),
            const Icon(Icons.arrow_drop_down_rounded,
                size: 18, color: AppColors.textSecondary),
          ]),
        ),
      ),
      const SizedBox(width: 8),
      // Champ numéro
      Expanded(child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.phone,
        validator: required
            ? (v) {
                if (v == null || v.isEmpty) return s.phoneRequiredErr;
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 9) return s.phone9DigitsErr;
                return null;
              }
            : null,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: AppColors.textSecondary),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : AppColors.inputBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      )),
    ]);
  }
}
