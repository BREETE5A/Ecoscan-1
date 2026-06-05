import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../services/food_product_service.dart';
import '../../theme/app_theme.dart';

// ── Provider ────────────────────────────────────────────────────────────────
final _productProvider =
    FutureProvider.family<FoodProduct?, String>((ref, code) =>
        FoodProductService.fetch(code));

// ── Screen ──────────────────────────────────────────────────────────────────
class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  String? _scannedCode;
  bool _scanning = true;

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) {
      setState(() {
        _scannedCode = code;
        _scanning = false;
      });
      _ctrl.stop();
    }
  }

  // Recrée le controller à chaque reset pour éviter le blocage après 2+ scans
  void _reset() {
    _ctrl.dispose();
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() {
      _scannedCode = null;
      _scanning = true;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s      = AppStrings.of(ref.watch(localeProvider).languageCode);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, s),
            Expanded(
              child: _scannedCode == null
                  ? _buildScanner(isDark, s)
                  : _buildResult(isDark, s, _scannedCode!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppStrings s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text(s.barcodeTitle, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        )),
      ]),
    );
  }

  // ── Camera viewfinder ────────────────────────────────────────────────────
  Widget _buildScanner(bool isDark, AppStrings s) {
    final hint = s.barcodeCamHint;

    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(controller: _ctrl, onDetect: _onDetect),

        // Viewfinder overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
        Container(
          width: 260,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: MobileScanner(controller: _ctrl, onDetect: _onDetect),
          ),
        ),

        // Corner decorations
        ..._corners(),

        // Hint text
        Positioned(
          bottom: 60,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(hint, style: const TextStyle(
              color: Colors.white, fontFamily: 'Poppins', fontSize: 14,
            )),
          ),
        ),
      ],
    );
  }

  List<Widget> _corners() {
    const size = 24.0;
    const thickness = 4.0;
    final color = AppColors.primary;

    final cx = (MediaQuery.of(context).size.width - 260) / 2;
    final cy = (MediaQuery.of(context).size.height - 160) / 2 - kToolbarHeight;

    return [
      Positioned(top: cy, left: cx, child: Container(width: size, height: size,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: thickness), left: BorderSide(color: color, width: thickness)), borderRadius: const BorderRadius.only(topLeft: Radius.circular(4))))),
      Positioned(top: cy, right: cx, child: Container(width: size, height: size,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: thickness), right: BorderSide(color: color, width: thickness)), borderRadius: const BorderRadius.only(topRight: Radius.circular(4))))),
      Positioned(bottom: cy + 100, left: cx, child: Container(width: size, height: size,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: thickness), left: BorderSide(color: color, width: thickness)), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4))))),
      Positioned(bottom: cy + 100, right: cx, child: Container(width: size, height: size,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: thickness), right: BorderSide(color: color, width: thickness)), borderRadius: const BorderRadius.only(bottomRight: Radius.circular(4))))),
    ];
  }

  // ── Product result ────────────────────────────────────────────────────────
  Widget _buildResult(bool isDark, AppStrings s, String code) {
    final async = ref.watch(_productProvider(code));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, t) => _notFound(isDark, s),
      data:    (product) => product == null
          ? _notFound(isDark, s)
          : _productCard(product, isDark, s),
    );
  }

  Widget _notFound(bool isDark, AppStrings s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(s.barcodeNotFound, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(s.barcodeScanAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(180, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _productCard(FoodProduct p, bool isDark, AppStrings s) {
    const gradeColors = {
      'A': Color(0xFF1B9E3E),
      'B': Color(0xFF85BB2F),
      'C': Color(0xFFF5C518),
      'D': Color(0xFFEF7D00),
      'E': Color(0xFFE63E11),
    };
    const grades = ['A', 'B', 'C', 'D', 'E'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── 1. Header produit ──────────────────────────────────────────
        if (p.imageUrl.isNotEmpty)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(p.imageUrl, height: 160, fit: BoxFit.contain,
                  errorBuilder: (ctx, e, st) => const SizedBox()),
            ),
          ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 14),

        Text(p.name.isNotEmpty ? p.name : s.barcodeUnknown,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textPrimary))
            .animate(delay: 80.ms).fadeIn().slideY(begin: 0.08),

        if (p.brand.isNotEmpty)
          Text(p.brand, style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 13, color: AppColors.textSecondary)),
        if (p.quantity.isNotEmpty)
          Text(p.quantity, style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 12, color: AppColors.textSecondary)),
        if (p.categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(p.categories.split(',').first.trim(),
                style: const TextStyle(fontFamily: 'Poppins',
                    fontSize: 12, color: AppColors.textSecondary)),
          ),

        const SizedBox(height: 20),

        // ── 2. RECYCLABILITÉ (le plus important — en premier) ──────────
        _RecyclabilityCard(product: p, isDark: isDark, s: s)
            .animate(delay: 120.ms).fadeIn().slideY(begin: 0.08),

        const SizedBox(height: 16),

        // ── 3. Nutri-Score ─────────────────────────────────────────────
        if (p.nutriScore.isNotEmpty)
          _ScoreDetailCard(
            title:    s.barcodeNutriTitle,
            subtitle: s.barcodeNutriSubtitle,
            grade:    p.nutriScore,
            explain:  s.nutriExplain(p.nutriScore),
            icon:     Icons.local_dining_rounded,
            allGrades: grades,
            gradeColors: gradeColors,
            isDark:   isDark,
            legendLabels: {
              'A': s.nutriExplain('A').split(' ').take(2).join(' '),
              'E': s.nutriExplain('E').split(' ').take(2).join(' '),
            },
          ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.08),

        if (p.nutriScore.isNotEmpty) const SizedBox(height: 12),

        // ── 4. Eco-Score ───────────────────────────────────────────────
        if (p.ecoScore.isNotEmpty)
          _ScoreDetailCard(
            title:    s.barcodeEcoTitle,
            subtitle: s.barcodeEcoSubtitle,
            grade:    p.ecoScore,
            explain:  s.ecoExplain(p.ecoScore),
            icon:     Icons.eco_rounded,
            allGrades: grades,
            gradeColors: gradeColors,
            isDark:   isDark,
            legendLabels: {
              'A': s.ecoExplain('A').split(' ').take(2).join(' '),
              'E': s.ecoExplain('E').split(' ').take(2).join(' '),
            },
          ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.08),

        if (p.ecoScore.isNotEmpty) const SizedBox(height: 12),

        // ── 5. Labels (bio, fair-trade…) ───────────────────────────────
        if (p.labels.isNotEmpty) ...[
          _labelsRow(p.labels, isDark).animate(delay: 260.ms).fadeIn(),
          const SizedBox(height: 12),
        ],

        // ── 6. Emballage ───────────────────────────────────────────────
        if (p.packaging.isNotEmpty)
          _infoCard(isDark: isDark, icon: Icons.recycling_rounded,
              color: AppColors.primary, title: s.barcodePackaging,
              value: p.packaging)
              .animate(delay: 280.ms).fadeIn().slideY(begin: 0.08),

        if (p.packaging.isNotEmpty) const SizedBox(height: 12),

        // ── 7. Pays d'origine ──────────────────────────────────────────
        if (p.countries.isNotEmpty)
          _infoCard(isDark: isDark, icon: Icons.public_rounded,
              color: const Color(0xFF5C6BC0), title: s.barcodeOrigin,
              value: p.countries)
              .animate(delay: 300.ms).fadeIn().slideY(begin: 0.08),

        if (p.countries.isNotEmpty) const SizedBox(height: 12),

        // ── 8. Ingrédients ─────────────────────────────────────────────
        if (p.ingredients.isNotEmpty)
          _infoCard(isDark: isDark, icon: Icons.list_alt_rounded,
              color: const Color(0xFF26A69A), title: s.barcodeIngred,
              value: p.ingredients, maxLines: 6)
              .animate(delay: 320.ms).fadeIn().slideY(begin: 0.08),

        const SizedBox(height: 24),

        // ── Bouton nouveau scan ────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.barcode_reader),
            label: Text(s.barcodeScanAgainBtn),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              side: const BorderSide(color: AppColors.primary, width: 2),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ).animate(delay: 360.ms).fadeIn().slideY(begin: 0.08),

        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _infoCard({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    int maxLines = 3,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8)],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
              fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary)),
        ])),
      ]),
    );
  }

  Widget _labelsRow(List<String> labels, bool isDark) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: labels.take(6).map((l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(l, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
            color: AppColors.primary, fontWeight: FontWeight.w500)),
      )).toList(),
    );
  }

}

// ── Carte score détaillée (Nutri-Score / Eco-Score) ───────────────────────────
class _ScoreDetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String grade;
  final String explain;
  final IconData icon;
  final List<String> allGrades;
  final Map<String, Color> gradeColors;
  final Map<String, String> legendLabels;
  final bool isDark;

  const _ScoreDetailCard({
    required this.title,
    required this.subtitle,
    required this.grade,
    required this.explain,
    required this.icon,
    required this.allGrades,
    required this.gradeColors,
    required this.legendLabels,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = gradeColors[grade] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
          blurRadius: 10,
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Titre + icône
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 11, color: AppColors.textSecondary)),
          ])),
          // Grande lettre
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4),
                    blurRadius: 8)]),
            alignment: Alignment.center,
            child: Text(grade, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ]),

        const SizedBox(height: 12),

        // Explication du grade
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(explain, style: TextStyle(fontFamily: 'Poppins',
              fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ),

        const SizedBox(height: 12),

        // Barre des 5 grades (A→E) avec surlignage du grade courant
        Row(children: allGrades.map((g) {
          final c = gradeColors[g] ?? Colors.grey;
          final active = g == grade;
          return Expanded(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: active ? 36 : 28,
            decoration: BoxDecoration(
              color: active ? c : c.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: active ? Border.all(color: c, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(g, style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: active ? 14 : 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : c,
            )),
          ));
        }).toList()),

        const SizedBox(height: 6),

        // Légende extrêmes
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(legendLabels['A'] ?? '', style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 10, color: Color(0xFF1B9E3E))),
          Text(legendLabels['E'] ?? '', style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 10, color: Color(0xFFE63E11))),
        ]),
      ]),
    );
  }
}

// ── Emballage : 100% données API Open Food Facts ─────────────────────────────
enum _MaterialType { glass, plastic, metal, cardboard, unknown }

class _MaterialInfo {
  final _MaterialType type;
  final String preciseLabel;
  final bool? recyclable;
  const _MaterialInfo(this.type, this.preciseLabel, this.recyclable);
}

// Table : tag API → label lisible (taxonomie complète OpenFoodFacts)
const _shapeLabels = <String, String>{
  // Boîtes / conserves
  'en:can':                          'Boîte conserve',
  'en:tin':                          'Boîte conserve',
  'en:tin-can':                      'Boîte conserve',
  'en:food-can':                     'Boîte conserve',
  'en:drink-can':                    'Canette',
  'en:aerosol-can':                  'Bombe aérosol',
  'en:metal-can':                    'Boîte métallique',
  // Bouteilles
  'en:bottle':                       'Bouteille',
  'en:glass-bottle':                 'Bouteille en verre',
  'en:plastic-bottle':               'Bouteille en plastique',
  'en:aluminium-bottle':             'Bouteille aluminium',
  'en:metal-bottle':                 'Bouteille métallique',
  'en:squeeze-bottle':               'Flacon souple',
  'en:spray-bottle':                 'Flacon spray',
  'en:pump-bottle':                  'Flacon pompe',
  // Bocaux / pots
  'en:jar':                          'Bocal / Pot en verre',
  'en:glass-jar':                    'Bocal en verre',
  'en:jug':                          'Carafe / Cruche',
  // Briques / cartons
  'en:carton':                       'Brique carton',
  'en:tetra-pak':                    'Brique carton (Tetra Pak)',
  'en:brick':                        'Brique carton',
  'en:milk-carton':                  'Brique lait',
  // Boîtes carton
  'en:box':                          'Boîte carton',
  'en:cardboard-box':                'Boîte carton',
  'en:folding-box':                  'Boîte pliante',
  'en:clamshell':                    'Barquette coque',
  // Sachets / poches
  'en:bag':                          'Sachet',
  'en:plastic-bag':                  'Sachet plastique',
  'en:paper-bag':                    'Sac papier',
  'en:string-bag':                   'Filet',
  'en:net':                          'Filet',
  'en:mesh-bag':                     'Filet',
  'en:pouch':                        'Pochette',
  'en:stand-up-pouch':               'Pochette doypack',
  'en:doy-pack':                     'Pochette doypack',
  'en:sachet':                       'Sachet individuel',
  'en:envelope':                     'Enveloppe',
  // Barquettes
  'en:tray':                         'Barquette',
  'en:plastic-tray':                 'Barquette plastique',
  'en:cardboard-tray':               'Barquette carton',
  'en:foam-tray':                    'Barquette mousse',
  'en:aluminium-tray':               'Barquette aluminium',
  // Tubes
  'en:tube':                         'Tube',
  'en:squeezable-tube':              'Tube souple',
  // Emballages souples / films
  'en:wrap':                         'Emballage souple',
  'en:film':                         'Film plastique',
  'en:plastic-film':                 'Film plastique',
  'en:shrink-wrap':                  'Film rétractable',
  'en:blister-pack':                 'Blister',
  'en:blister':                      'Blister',
  'en:skin-pack':                    'Sous vide plastique',
  'en:wrapper':                      'Emballage souple',
  'en:wax-paper':                    'Papier ciré',
  'en:waxed-paper':                  'Papier ciré',
  // Pots / cups
  'en:cup':                          'Pot / Cup',
  'en:yogurt-pot':                   'Pot de yaourt',
  'en:pot':                          'Pot',
  'en:plastic-pot':                  'Pot plastique',
  'en:glass-pot':                    'Pot en verre',
  // Bouchons / couvercles
  'en:lid':                          'Couvercle',
  'en:cap':                          'Bouchon',
  'en:bottle-cap':                   'Capsule bouteille',
  'en:screw-cap':                    'Bouchon vissant',
  'en:cork':                         'Bouchon liège',
  'en:stopper':                      'Bouchon',
  'en:seal':                         'Opercule',
  'en:foil-seal':                    'Opercule aluminium',
  // Accessoires
  'en:straw':                        'Paille',
  'en:spoon':                        'Cuillère',
  'en:label':                        'Étiquette',
  'en:sleeve':                       'Manchon',
  // Grands contenants
  'en:barrel':                       'Fût / Tonneau',
  'en:drum':                         'Fût',
  'en:crate':                        'Caisse',
  'en:pallet':                       'Palette',
};

const _materialLabels = <String, String>{
  // Métaux
  'en:steel':                                        'Acier',
  'en:tinplate':                                     'Fer-blanc',
  'en:tin':                                          'Fer-blanc',
  'en:aluminium':                                    'Aluminium',
  'en:aluminum':                                     'Aluminium',
  'en:recycled-aluminium':                           'Aluminium recyclé',
  'en:recycled-aluminum':                            'Aluminium recyclé',
  'en:metal':                                        'Métal',
  // Verre
  'en:glass':                                        'Verre',
  'en:recycled-glass':                               'Verre recyclé',
  'en:clear-glass':                                  'Verre transparent',
  'en:colored-glass':                                'Verre coloré',
  // Plastiques standards
  'en:plastic':                                      'Plastique',
  'en:pet-1-polyethylene-terephthalate':             'PET (Plastique n°1)',
  'en:pet':                                          'PET (Plastique)',
  'en:hdpe-2-high-density-polyethylene':             'HDPE (Plastique n°2)',
  'en:hdpe':                                         'HDPE (Plastique)',
  'en:pvc-3-polyvinyl-chloride':                     'PVC (Plastique n°3)',
  'en:pvc':                                          'PVC (Plastique)',
  'en:ldpe-4-low-density-polyethylene':              'LDPE (Plastique n°4)',
  'en:ldpe':                                         'LDPE (Plastique)',
  'en:pp-5-polypropylene':                           'Polypropylène (PP n°5)',
  'en:pp':                                           'Polypropylène (PP)',
  'en:ps-6-polystyrene':                             'Polystyrène (PS n°6)',
  'en:ps':                                           'Polystyrène (PS)',
  'en:other-plastics-7':                             'Autre plastique (n°7)',
  'en:abs-acrylonitrile-butadiene-styrene':          'ABS (Plastique)',
  'en:abs':                                          'ABS (Plastique)',
  'en:eva-ethylene-vinyl-acetate':                   'EVA',
  'en:eva':                                          'EVA',
  'en:evoh-ethylene-vinyl-alcohol':                  'EVOH (barrière)',
  'en:evoh':                                         'EVOH (barrière)',
  'en:nylon-polyamide':                              'Nylon (Polyamide)',
  'en:polyamide':                                    'Polyamide',
  'en:polycarbonate':                                'Polycarbonate',
  'en:pmma-acrylic':                                 'PMMA (Acrylique)',
  'en:recycled-plastic':                             'Plastique recyclé',
  'en:bioplastic':                                   'Bioplastique',
  'en:bio-sourced-plastic':                          'Plastique biosourcé',
  // Papier / Carton
  'en:cardboard':                                    'Carton',
  'en:recycled-cardboard':                           'Carton recyclé',
  'en:waxed-cardboard':                              'Carton ciré',
  'en:paper':                                        'Papier',
  'en:kraft-paper':                                  'Papier kraft',
  'en:recycled-paper':                               'Papier recyclé',
  'en:cellulose':                                    'Cellulose',
  // Matériaux composites
  'en:composite-material':                           'Matériau composite',
  'en:tetra-pak':                                    'Tetra Pak (composite)',
  'en:multilayer':                                   'Multicouche',
  // Matériaux naturels
  'en:wood':                                         'Bois',
  'en:cork':                                         'Liège',
  'en:cotton':                                       'Coton',
  'en:jute':                                         'Jute',
  'en:silicone':                                     'Silicone',
};

String _labelForTag(String tag, Map<String, String> map) {
  // Cherche correspondance exacte d'abord
  if (map.containsKey(tag)) return map[tag]!;
  // Puis correspondance partielle (ex: 'en:pet-1-...' → 'PET')
  for (final e in map.entries) {
    if (tag.startsWith(e.key) || e.key.startsWith(tag)) return e.value;
  }
  // Fallback : nettoie le tag
  return tag.replaceAll('en:', '').replaceAll('-', ' ').trim();
}

_MaterialType _typeFromMaterialTag(String tag) {
  final t = tag.toLowerCase();
  if (t.contains('glass'))     { return _MaterialType.glass; }
  if (t.contains('steel') || t.contains('alumin') || t.contains('tinplate') ||
      t.contains(':metal'))    { return _MaterialType.metal; }
  // ':tin' uniquement en tag exact (évite de matcher 'satin', 'atin', etc.)
  if (t == 'en:tin' || t.endsWith(':tin')) { return _MaterialType.metal; }
  if (t.contains('cardboard') || t.contains('paper') || t.contains('wood') ||
      t.contains('kraft') || t.contains('cellulose') ||
      t == 'en:tetra-pak' || t.contains('multilayer')) {
    return _MaterialType.cardboard;
  }
  if (t.contains('plastic') || t.contains(':pet') || t.contains(':hdpe') ||
      t.contains(':pvc')    || t.contains(':ldpe') || t.contains(':pp-') ||
      t == 'en:pp'          || t.contains('polyprop') || t.contains('polysty') ||
      t.contains('bioplast') || t.contains('polyamide') || t.contains('silicone')) {
    return _MaterialType.plastic;
  }
  return _MaterialType.unknown;
}

// Score de base par type de matière
int _materialScore(_MaterialType type) {
  switch (type) {
    case _MaterialType.glass:     return 4;
    case _MaterialType.metal:     return 3;
    case _MaterialType.cardboard: return 2;
    case _MaterialType.plastic:   return 2; // égal au carton
    case _MaterialType.unknown:   return 0;
  }
}

// Priorité effective d'un tag : les plastiques nommés (PET, HDPE, PP…) battent le carton générique
int _tagPriority(String tag, _MaterialType type) {
  if (type == _MaterialType.plastic) {
    final t = tag.toLowerCase();
    if (t.contains(':pet') || t.contains(':hdpe') || t.contains(':pp') ||
        t.contains(':pvc')  || t.contains(':ldpe') || t.contains(':ps-') ||
        t.contains(':abs')  || t.contains(':eva')  ||
        t.contains('polyprop') || t.contains('polyethylene') || t.contains('polysty')) {
      return 5; // plastique nommé > verre(4) > métal(3) > carton(2) > plastique générique(1)
    }
    return 1; // plastique générique
  }
  return _materialScore(type);
}

// Extrait la meilleure matière depuis une liste de tags
_MaterialInfo? _bestMaterialFromTags(List<String> tags, bool? recycling) {
  _MaterialType? best;
  String bestLabel = '';
  int bestScore = -1;

  for (final tag in tags) {
    final t = tag.toLowerCase();
    _MaterialType? type;
    String label = '';

    if (t.contains(':glass'))                                { type = _MaterialType.glass;     label = 'Verre'; }
    else if (t.contains(':aluminium') || t.contains(':aluminum')) { type = _MaterialType.metal; label = 'Aluminium'; }
    else if (t.contains(':steel'))                           { type = _MaterialType.metal;     label = 'Acier'; }
    else if (t.contains(':tinplate') || t == 'en:tin' || t.endsWith(':tin')) { type = _MaterialType.metal; label = 'Fer-blanc'; }
    else if (t.contains(':cardboard'))                       { type = _MaterialType.cardboard; label = 'Carton'; }
    else if (t.contains(':kraft'))                           { type = _MaterialType.cardboard; label = 'Papier kraft'; }
    else if (t.contains(':paper'))                           { type = _MaterialType.cardboard; label = 'Papier'; }
    else if (t.contains(':pet-') || t == 'en:pet')           { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':hdpe'))                            { type = _MaterialType.plastic;   label = 'HDPE (Plastique n°2)'; }
    else if (t.contains(':pp-') || t == 'en:pp')             { type = _MaterialType.plastic;   label = 'Polypropylène (PP n°5)'; }
    else if (t.contains(':pvc'))                             { type = _MaterialType.plastic;   label = 'PVC (Plastique n°3)'; }
    else if (t.contains(':ldpe'))                            { type = _MaterialType.plastic;   label = 'LDPE (Plastique n°4)'; }
    else if (t.contains(':ps-') || t.contains(':polysty'))   { type = _MaterialType.plastic;   label = 'Polystyrène (PS n°6)'; }
    else if (t.contains(':plastic'))                         { type = _MaterialType.plastic;   label = 'Plastique'; }
    else {
      // Fallback via _typeFromMaterialTag (ignore tags non-matériaux)
      final ft = _typeFromMaterialTag(t);
      if (ft != _MaterialType.unknown) { type = ft; label = _labelForTag(tag, _materialLabels); }
    }

    if (type != null) {
      final score = _tagPriority(tag, type);
      if (best == null || score > bestScore) {
        best = type;
        bestLabel = label;
        bestScore = score;
      }
    }
  }
  if (best == null) return null;
  return _MaterialInfo(best, bestLabel, recycling);
}

// ── Détection matière — API seulement ─────────────────────────────────────────
_MaterialInfo _detectMaterial(FoodProduct p) {
  // Recyclabilité depuis les tags dédiés
  bool? recycling;
  for (final t in p.packagingRecyclingTags) {
    if (t.contains('non-recyclable') || t.contains('not-recycled')) { recycling = false; break; }
    if (t.contains('recyclable') || t.contains('recycled'))         { recycling = true; }
  }

  // Priorité 1 : composants structurés
  if (p.packagingComponents.isNotEmpty) {
    _MaterialType? bestType;
    String bestLabel = '';
    bool? bestRecyclable;
    double bestWeight = -1;
    int bestTagScore = -1;

    // Formes d'accessoires à ignorer pour identifier le contenant principal
    const accessoryShapes = {
      'en:label', 'en:sleeve', 'en:straw', 'en:seal',
      'en:foil-seal', 'en:cap', 'en:screw-cap', 'en:bottle-cap',
      'en:cork', 'en:stopper', 'en:spoon',
    };

    final bool hasWeights = p.packagingComponents.any((c) => (c.weight ?? 0) > 0);

    for (final c in p.packagingComponents) {
      if (c.material.isEmpty) continue;
      if (accessoryShapes.contains(c.shape.toLowerCase())) continue;
      final type = _typeFromMaterialTag(c.material);
      if (type == _MaterialType.unknown) continue;

      final tagScore = _tagPriority(c.material, type);
      if (hasWeights) {
        final w = c.weight ?? 0;
        if (bestType == null || w > bestWeight || (w == bestWeight && tagScore > bestTagScore)) {
          bestType      = type;
          bestLabel     = _labelForTag(c.material, _materialLabels);
          bestRecyclable = c.isRecyclable;
          bestWeight    = w;
          bestTagScore  = tagScore;
        }
      } else {
        if (bestType == null || tagScore > bestTagScore) {
          bestType      = type;
          bestLabel     = _labelForTag(c.material, _materialLabels);
          bestRecyclable = c.isRecyclable;
          bestTagScore  = tagScore;
        }
      }
    }
    if (bestType != null) {
      return _MaterialInfo(bestType, bestLabel, bestRecyclable ?? recycling);
    }
  }

  // Priorité 2 : packaging_materials_tags (champ dédié — score sur tous les tags)
  final m2 = _bestMaterialFromTags(p.packagingMaterialsTags, recycling);
  if (m2 != null) return m2;

  // Priorité 3 : packaging_tags plats (score sur tous les tags)
  bool? tagRecyclable = recycling;
  for (final t in p.packagingTags) {
    if (t.contains('non-recyclable')) { tagRecyclable = false; break; }
    if (t.contains('recyclable'))     { tagRecyclable = true; }
  }
  final m3 = _bestMaterialFromTags(p.packagingTags, tagRecyclable);
  if (m3 != null) return m3;

  // Priorité 4 : champ packaging texte libre
  final text = p.packaging.toLowerCase();
  if (text.contains('verre')     || text.contains('glass'))                  { return _MaterialInfo(_MaterialType.glass,     'Verre',    true); }
  if (text.contains('aluminium') || text.contains('acier') ||
      text.contains('métal')     || text.contains('metal'))                  { return _MaterialInfo(_MaterialType.metal,     'Métal',    true); }
  if (text.contains('carton')    || text.contains('papier'))                 { return _MaterialInfo(_MaterialType.cardboard, 'Carton',   true); }
  if (text.contains('plastique') || text.contains('plastic') ||
      text.contains('pet')       || text.contains('hdpe'))                   { return _MaterialInfo(_MaterialType.plastic,   'Plastique',true); }

  // Priorité 5 : inférence par catégorie
  final cat  = p.categories.toLowerCase();
  final cats = p.categoriesTags;
  if (cat.contains('conserves') || cat.contains('canned') ||
      cats.any((c) => c.contains('canned') || c.contains('en-conserve')))   { return _MaterialInfo(_MaterialType.metal,     'Acier',        true); }
  if (cat.contains('vins')  || cat.contains('wines')  ||
      cat.contains('spiritueux') || cat.contains('spirits') ||
      cat.contains('huiles') || cat.contains('oils') ||
      cat.contains('confiture') || cat.contains('jam') ||
      cat.contains('moutarde') || cat.contains('mustard') ||
      cat.contains('sauce') || cat.contains('condiment') ||
      cat.contains('cornichon') || cat.contains('pickle') ||
      cat.contains('vinaigre') || cat.contains('vinegar') ||
      cat.contains('bocal') || cat.contains('aliment bébé') || cat.contains('baby food') ||
      cats.any((c) => c.contains('wine') || c.contains('spirit') || c.contains('oil') ||
                      c.contains('jam') || c.contains('spread') || c.contains('pickle') ||
                      c.contains('condiment') || c.contains('mustard') || c.contains('vinegar') ||
                      c.contains('baby-food') || c.contains('sauce'))) { return _MaterialInfo(_MaterialType.glass, 'Verre', true); }
  if (cat.contains('eaux minérales') || cat.contains('mineral waters') ||
      cat.contains('boissons gazeuses') || cat.contains('sodas') ||
      cats.any((c) => c.contains('mineral-water') || c.contains('soda') || c.contains('cola'))) { return _MaterialInfo(_MaterialType.plastic, 'Plastique', true); }
  // Céréales → boîte carton (fiable)
  if (cat.contains('céréales') || cat.contains('cereals') ||
      cats.any((c) => c.contains('cereal'))) { return _MaterialInfo(_MaterialType.cardboard, 'Boîte carton', true); }
  // Laits/jus → peuvent être brique carton OU bouteille plastique → ne pas inférer
  if (cat.contains('yaourts') || cat.contains('yogurts') ||
      cat.contains('fromages frais') ||
      cats.any((c) => c.contains('yogurt') || c.contains('fresh-cheese')))  { return _MaterialInfo(_MaterialType.plastic,   'Plastique',    true); }

  return _MaterialInfo(_MaterialType.unknown, '', null);
}

// ── Détection type (forme) ────────────────────────────────────────────────────
String _detectShape(FoodProduct p) {
  // Priorité 1 : composants structurés — forme du contenant avec la matière principale
  if (p.packagingComponents.isNotEmpty) {
    _MaterialType? bestType;
    String bestShape = '';

    for (final c in p.packagingComponents) {
      if (c.material.isNotEmpty) {
        final type = _typeFromMaterialTag(c.material);
        if (type != _MaterialType.unknown) {
          if (bestType == null || _materialScore(type) > _materialScore(bestType)) {
            bestType  = type;
            bestShape = c.shape.isNotEmpty ? _labelForTag(c.shape, _shapeLabels) : '';
          } else if (type == bestType && bestShape.isEmpty && c.shape.isNotEmpty) {
            bestShape = _labelForTag(c.shape, _shapeLabels);
          }
        }
      } else if (c.shape.isNotEmpty && bestType == null) {
        bestShape = _labelForTag(c.shape, _shapeLabels);
      }
    }
    if (bestShape.isNotEmpty) return bestShape;
  }

  // Priorité 2 : packaging_shapes_tags (champ dédié formes — plus fiable)
  for (final tag in p.packagingShapesTags) {
    final t = tag.toLowerCase();
    if (_shapeLabels.containsKey(t)) return _shapeLabels[t]!;
    for (final e in _shapeLabels.entries) {
      if (t.contains(e.key.replaceAll('en:', ''))) return e.value;
    }
  }

  // Priorité 3 : packaging_tags plats (extrait formes reconnues)
  for (final tag in p.packagingTags) {
    final t = tag.toLowerCase();
    if (_shapeLabels.containsKey(t)) return _shapeLabels[t]!;
    for (final e in _shapeLabels.entries) {
      if (t == e.key || t.startsWith(e.key)) return e.value;
    }
  }

  // Priorité 4 : packaging texte libre
  final text = p.packaging.toLowerCase();
  if (text.contains('boîte') || text.contains('conserve') || text.contains('can'))  { return 'Boîte conserve'; }
  if (text.contains('bouteille') || text.contains('bottle'))                          { return 'Bouteille'; }
  if (text.contains('sachet')    || text.contains('bag'))                             { return 'Sachet'; }
  if (text.contains('carton')    || text.contains('box'))                             { return 'Boîte carton'; }
  if (text.contains('pot')       || text.contains('jar'))                             { return 'Pot / Bocal'; }
  if (text.contains('tube'))                                                           { return 'Tube'; }
  if (text.contains('film')      || text.contains('pochette'))                        { return 'Emballage souple'; }

  // Priorité 5 : inférence par catégorie (élargie)
  final cat = p.categories.toLowerCase();
  final cats = p.categoriesTags;
  if (cat.contains('conserves') || cat.contains('canned') ||
      cats.any((c) => c.contains('canned') || c.contains('en-conserve'))) {
    return 'Boîte conserve';
  }
  if (cat.contains('vins') || cat.contains('wines') || cat.contains('spiritueux') ||
      cat.contains('spirits') || cat.contains('huiles') ||
      cats.any((c) => c.contains('wine') || c.contains('spirit') || c.contains('oil'))) {
    return 'Bouteille en verre';
  }
  if (cat.contains('confiture') || cat.contains('jam') ||
      cat.contains('moutarde') || cat.contains('mustard') ||
      cat.contains('sauce') || cat.contains('condiment') ||
      cat.contains('cornichon') || cat.contains('pickle') ||
      cat.contains('vinaigre') || cat.contains('vinegar') ||
      cat.contains('bocal') || cat.contains('aliment bébé') || cat.contains('baby food') ||
      cats.any((c) => c.contains('jam') || c.contains('spread') || c.contains('pickle') ||
                      c.contains('condiment') || c.contains('mustard') || c.contains('vinegar') ||
                      c.contains('baby-food') || c.contains('sauce'))) {
    return 'Bocal en verre';
  }
  if (cat.contains('eaux minérales') || cat.contains('mineral waters') ||
      cat.contains('boissons gazeuses') || cat.contains('sodas') ||
      cats.any((c) => c.contains('mineral-water') || c.contains('soda'))) {
    return 'Bouteille';
  }
  if (cat.contains('laits') || cat.contains('milks') ||
      cat.contains('jus de fruits') || cat.contains('fruit juices') ||
      cats.any((c) => c.contains('milk') || c.contains('fruit-juice'))) {
    return 'Brique carton';
  }
  if (cat.contains('yaourts') || cat.contains('yogurts') ||
      cat.contains('fromages frais') ||
      cats.any((c) => c.contains('yogurt') || c.contains('fresh-cheese'))) {
    return 'Pot / Cup';
  }
  if (cat.contains('biscuits') || cat.contains('cookies') ||
      cat.contains('céréales') || cat.contains('cereals') ||
      cats.any((c) => c.contains('biscuit') || c.contains('cereal'))) {
    return 'Boîte carton';
  }
  if (cat.contains('chips') || cat.contains('crackers') || cat.contains('snacks') ||
      cats.any((c) => c.contains('chip') || c.contains('snack'))) {
    return 'Sachet';
  }
  if (cat.contains('pâtes') || cat.contains('pasta') || cat.contains('riz') ||
      cat.contains('rice') || cat.contains('farine') || cat.contains('flour') ||
      cats.any((c) => c.contains('pasta') || c.contains('rice') || c.contains('flour'))) {
    return 'Sachet';
  }

  return '';
}

// ── Carte emballage (type + matière) ─────────────────────────────────────────
class _RecyclabilityCard extends StatelessWidget {
  final FoodProduct product;
  final bool isDark;
  final AppStrings s;
  const _RecyclabilityCard({required this.product, required this.isDark, required this.s});

  @override
  Widget build(BuildContext context) {
    final info      = _detectMaterial(product);
    final shape     = _detectShape(product);
    final recyclable = info.recyclable ?? (info.type != _MaterialType.unknown);

    final Color mainColor;
    final IconData matIcon;
    final String matiere;

    switch (info.type) {
      case _MaterialType.glass:
        mainColor = const Color(0xFF2E7D32);
        matIcon   = Icons.liquor_rounded;
        matiere   = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Verre';
      case _MaterialType.cardboard:
        mainColor = const Color(0xFF1565C0);
        matIcon   = Icons.inventory_2_rounded;
        matiere   = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Carton / Papier';
      case _MaterialType.metal:
        mainColor = const Color(0xFFF9A825);
        matIcon   = Icons.local_drink_rounded;
        matiere   = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Métal';
      case _MaterialType.plastic:
        mainColor = const Color(0xFFE65100);
        matIcon   = Icons.water_drop_rounded;
        matiere   = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Plastique';
      case _MaterialType.unknown:
        mainColor = const Color(0xFF616161);
        matIcon   = Icons.help_outline_rounded;
        matiere   = 'Non renseigné';
    }

    final ecoColor = product.ecoScore == 'A' ? const Color(0xFF1B9E3E)
        : product.ecoScore == 'B' ? const Color(0xFF85BB2F)
        : product.ecoScore == 'C' ? const Color(0xFFF5C518)
        : product.ecoScore == 'D' ? const Color(0xFFEF7D00)
        : product.ecoScore.isNotEmpty ? const Color(0xFFE63E11)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mainColor.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: mainColor.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── En-tête : icône + titre + badge recyclable ───────────────────
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(matIcon, color: mainColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Emballage', style: TextStyle(
            fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ))),
          // Badge recyclable uniquement si recyclable
          if (recyclable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00C853), width: 1.5),
              ),
              child: Text(
                s.barcodeRecyclable,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
              ),
            ),
        ]),

        const SizedBox(height: 14),
        Divider(color: mainColor.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 14),

        // ── Type de l'emballage ──────────────────────────────────────────
        _PackagingInfoRow(
          label: s.packagingTypeLabel,
          value: shape.isNotEmpty ? shape : s.packagingNotSpecified,
          icon: Icons.category_outlined,
          color: mainColor,
          isDark: isDark,
          muted: shape.isEmpty,
        ),
        const SizedBox(height: 10),

        // ── Matière de l'emballage ───────────────────────────────────────
        _PackagingInfoRow(
          label: s.packagingMaterialLabel,
          value: matiere,
          icon: Icons.science_outlined,
          color: mainColor,
          isDark: isDark,
          muted: info.type == _MaterialType.unknown,
        ),

        // ── Eco-Score ────────────────────────────────────────────────────
        if (product.ecoScore.isNotEmpty) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: ecoColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Eco-Score ${product.ecoScore}', style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                fontWeight: FontWeight.bold, color: Colors.white,
              )),
            ),
          ),
        ],
      ]),
    );
  }
}

class _PackagingInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool muted;
  const _PackagingInfoRow({
    required this.label, required this.value, required this.icon,
    required this.color, required this.isDark, this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: muted ? 0.07 : 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: muted ? AppColors.textSecondary : color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary,
        )),
        Text(value, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
          color: muted
              ? AppColors.textSecondary
              : (isDark ? AppColors.darkText : AppColors.textPrimary),
        )),
      ])),
    ]);
  }
}
