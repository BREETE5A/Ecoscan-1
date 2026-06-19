import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../l10n/app_strings.dart';
import '../../models/scan_entry.dart';
import '../../models/scan_result_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/scan_history_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/food_product_service.dart';
import '../../theme/app_theme.dart';

// ── Provider ────────────────────────────────────────────────────────────────
final _productProvider =
    FutureProvider.family<FoodProduct?, (String, String)>((ref, params) =>
        FoodProductService.fetch(params.$1, locale: params.$2));

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
  String? _savedForCode;
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
      _savedForCode = null;
      _scanning = true;
    });
  }

  void _saveBarcodeScan(FoodProduct product, String code) {
    if (_savedForCode == code) return;
    _savedForCode = code;

    final info = _detectMaterial(product);

    String category;
    String binColor;
    int points;
    double co2Grams;
    double recyclability;
    bool recyclable;

    switch (info.type) {
      case _MaterialType.glass:
        category = 'verre'; binColor = 'green'; points = 25;
        co2Grams = 55.0; recyclability = 1.0; recyclable = true;
      case _MaterialType.metal:
        category = 'metal'; binColor = 'yellow'; points = 20;
        co2Grams = 80.0; recyclability = 0.97; recyclable = true;
      case _MaterialType.cardboard:
        category = 'cardboard'; binColor = 'blue'; points = 10;
        co2Grams = 30.0; recyclability = 0.88; recyclable = true;
      case _MaterialType.plastic:
        category = 'plastique'; binColor = 'yellow'; points = 15;
        co2Grams = 45.0; recyclability = 0.92; recyclable = true;
      case _MaterialType.unknown:
        category = 'unknown'; binColor = 'black'; points = 5;
        co2Grams = 0.0; recyclability = 0.0; recyclable = false;
    }

    if (info.recyclable != null) recyclable = info.recyclable!;

    final entry = ScanEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product.name.isNotEmpty ? product.name : code,
      category: category,
      recyclable: recyclable,
      dangerous: false,
      points: points,
      co2Saved: co2Grams,
      recyclability: recyclability,
      binColor: binColor,
      scannedAt: DateTime.now(),
      mode: 'barcode',
      imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : null,
    );

    final result = ScanResultModel(
      rawClass: category,
      category: category,
      binColor: binColor,
      confidence: 1.0,
      co2SavedPerKg: co2Grams / 1000,
      scannedAt: DateTime.now(),
    );

    ref.read(scanHistoryProvider.notifier).addScan(entry);
    ref.read(userProvider.notifier).recordScan(result)
        .catchError((e) { if (kDebugMode) debugPrint('recordScan error: $e'); });
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.barcodeTitle, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              )),
              Text(s.barcodeCtaSub, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary,
              )),
            ],
          ),
        ),
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
    final locale = ref.read(localeProvider).languageCode;
    final async  = ref.watch(_productProvider((code, locale)));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, t) => _notFound(isDark, s),
      data:    (product) {
        if (product != null && _savedForCode != code) {
          Future.microtask(() { if (mounted) _saveBarcodeScan(product, code); });
        }
        return product == null
            ? _notFound(isDark, s)
            : _productCard(product, isDark, s);
      },
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
  'en:can':                                      'Boîte conserve',
  'en:tin':                                      'Boîte conserve',
  'en:tin-can':                                  'Boîte conserve',
  'en:food-can':                                 'Boîte conserve',
  'en:drink-can':                                'Canette',
  'en:aerosol-can':                              'Bombe aérosol',
  'en:metal-can':                                'Boîte métallique',
  // Bouteilles
  'en:bottle':                                   'Bouteille',
  'en:glass-bottle':                             'Bouteille en verre',
  'en:plastic-bottle':                           'Bouteille en plastique',
  'en:aluminium-bottle':                         'Bouteille aluminium',
  'en:metal-bottle':                             'Bouteille métallique',
  'en:squeeze-bottle':                           'Flacon souple',
  'en:spray-bottle':                             'Flacon spray',
  'en:pump-bottle':                              'Flacon pompe',
  'en:bottle-or-vial':                           'Bouteille / Flacon',
  'en:hip-flask':                                'Flasque',
  // Flacons / ampoules
  'en:vial':                                     'Flacon',
  'en:ampoule':                                  'Ampoule',
  // Bocaux / pots
  'en:jar':                                      'Bocal / Pot en verre',
  'en:glass-jar':                                'Bocal en verre',
  'en:jug':                                      'Carafe / Cruche',
  'en:jug-or-canister':                          'Cruche / Bidon',
  'en:canister':                                 'Bidon',
  'en:bucket':                                   'Seau',
  'en:small-bucket':                             'Petit seau',
  // Briques / cartons
  'en:carton':                                   'Brique carton',
  'en:tetra-pak':                                'Brique carton (Tetra Pak)',
  'en:brick':                                    'Brique carton',
  'en:small-brick':                              'Petite brique',
  'en:milk-carton':                              'Brique lait',
  // Boîtes carton
  'en:box':                                      'Boîte carton',
  'en:cardboard-box':                            'Boîte carton',
  'en:folding-box':                              'Boîte pliante',
  'en:clamshell':                                'Barquette coque',
  'en:egg-carton':                               'Boîte à œufs',
  'en:pizza-box':                                'Boîte à pizza',
  'en:pill-box':                                 'Boîte à comprimés',
  'en:case':                                     'Étui',
  'en:packet':                                   'Paquet',
  // Sachets / poches
  'en:bag':                                      'Sachet',
  'en:plastic-bag':                              'Sachet plastique',
  'en:paper-bag':                                'Sac papier',
  'en:individual-bag':                           'Sachet individuel',
  'en:carrying-bag':                             'Sac de transport',
  'en:string-bag':                               'Filet',
  'en:net':                                      'Filet',
  'en:mesh-bag':                                 'Filet',
  'en:pouch':                                    'Pochette',
  'en:stand-up-pouch':                           'Pochette doypack',
  'en:doy-pack':                                 'Pochette doypack',
  'en:sachet':                                   'Sachet individuel',
  'en:tea-bag':                                  'Sachet de thé',
  'en:envelope':                                 'Enveloppe',
  'en:bag-in-box':                               'Bag-in-Box',
  // Barquettes / assiettes
  'en:tray':                                     'Barquette',
  'en:plastic-tray':                             'Barquette plastique',
  'en:cardboard-tray':                           'Barquette carton',
  'en:foam-tray':                                'Barquette mousse',
  'en:aluminium-tray':                           'Barquette aluminium',
  'en:salad-bowl':                               'Saladier',
  'en:bowl':                                     'Bol',
  'en:tumbler':                                  'Gobelet',
  'en:dish':                                     'Assiette',
  'en:plate':                                    'Assiette',
  // Tubes
  'en:tube':                                     'Tube',
  'en:squeezable-tube':                          'Tube souple',
  'en:stick':                                    'Stick',
  'en:cosmetic-stick':                           'Stick cosmétique',
  // Emballages souples / films
  'en:wrap':                                     'Emballage souple',
  'en:film':                                     'Film plastique',
  'en:plastic-film':                             'Film plastique',
  'en:shrink-wrap':                              'Film rétractable',
  'en:bubble-wrap':                              'Film à bulles',
  'en:blister-pack':                             'Blister',
  'en:blister':                                  'Blister',
  'en:skin-pack':                                'Sous vide plastique',
  'en:wrapper':                                  'Emballage souple',
  'en:wax-paper':                                'Papier ciré',
  'en:waxed-paper':                              'Papier ciré',
  'en:roll':                                     'Rouleau',
  'en:sheet':                                    'Feuille',
  'en:strip':                                    'Bandelette',
  'en:overpack':                                 'Suremballage',
  // Pots / cups
  'en:cup':                                      'Pot / Cup',
  'en:yogurt-pot':                               'Pot de yaourt',
  'en:pot':                                      'Pot',
  'en:plastic-pot':                              'Pot plastique',
  'en:glass-pot':                                'Pot en verre',
  'en:terrine-pot':                              'Terrine',
  'en:individual-pot':                           'Pot individuel',
  // Capsules / dosettes
  'en:capsule':                                  'Capsule',
  'en:coffee-capsule':                           'Capsule café',
  'en:nespresso-compatible-capsules':            'Capsule Nespresso',
  'en:senseo-compatible-coffee-capsules':        'Capsule Senseo',
  'en:tassimo-compatible-capsules':              'Capsule Tassimo',
  'en:dolce-gusto-compatible-capsules':          'Capsule Dolce Gusto',
  'en:tea-capsules':                             'Capsule thé',
  'en:coffee-pad':                               'Dosette café',
  // Bouchons / couvercles / fermetures
  'en:lid':                                      'Couvercle',
  'en:lid-or-cap':                               'Couvercle / Bouchon',
  'en:cap':                                      'Bouchon',
  'en:bottle-cap':                               'Capsule bouteille',
  'en:screw-cap':                                'Bouchon vissant',
  'en:tethered-cap':                             'Bouchon attaché',
  'en:flip-top':                                 'Bouchon flip-top',
  'en:grinder-cap':                              'Bouchon moulin',
  'en:pouring-cap':                              'Bouchon verseur',
  'en:special-cap':                              'Bouchon spécial',
  'en:cork':                                     'Bouchon liège',
  'en:wine-cork':                                'Bouchon de vin',
  'en:champagne-cork':                           'Bouchon de champagne',
  'en:crown-cork':                               'Capsule couronne',
  'en:stopper':                                  'Bouchon',
  'en:seal':                                     'Opercule',
  'en:foil-seal':                                'Opercule aluminium',
  'en:neck-seal':                                'Sceau de col',
  // Accessoires
  'en:straw':                                    'Paille',
  'en:drinking-straw':                           'Paille',
  'en:spoon':                                    'Cuillère',
  'en:teaspoon':                                 'Petite cuillère',
  'en:tablespoon':                               'Grande cuillère',
  'en:fork':                                     'Fourchette',
  'en:knife':                                    'Couteau',
  'en:label':                                    'Étiquette',
  'en:sleeve':                                   'Manchon',
  'en:applicator':                               'Applicateur',
  'en:reducer':                                  'Réducteur',
  'en:spout':                                    'Bec verseur',
  'en:valve':                                    'Valve',
  'en:handle':                                   'Poignée',
  'en:inlay':                                    'Insert',
  'en:backing':                                  'Support',
  'en:cartridge':                                'Cartouche',
  'en:syringe':                                  'Seringue',
  'en:individual-dose':                          'Dose individuelle',
  // Grands contenants
  'en:barrel':                                   'Fût / Tonneau',
  'en:drum':                                     'Fût',
  'en:crate':                                    'Caisse',
  'en:pallet':                                   'Palette',
  'en:basket':                                   'Panier',
  'en:grouping-package':                         'Emballage groupé',
};

const _materialLabels = <String, String>{
  // Métaux
  'en:steel':                                        'Acier',
  'en:tin-plated-steel':                             'Acier étamé',
  'en:tinplate':                                     'Fer-blanc',
  'en:tin':                                          'Fer-blanc',
  'en:aluminium':                                    'Aluminium',
  'en:aluminum':                                     'Aluminium',
  'en:recycled-aluminium':                           'Aluminium recyclé',
  'en:recycled-aluminum':                            'Aluminium recyclé',
  'en:light-aluminium':                              'Aluminium léger',
  'en:aluminium-foil':                               'Feuille d\'aluminium',
  'en:metal':                                        'Métal',
  'en:recyclable-metals':                            'Métaux recyclables',
  // Verre
  'en:glass':                                        'Verre',
  'en:recycled-glass':                               'Verre recyclé',
  'en:clear-glass':                                  'Verre transparent',
  'en:uncoloured-glass':                             'Verre incolore',
  'en:colored-glass':                                'Verre coloré',
  'en:coloured-glass':                               'Verre coloré',
  'en:green-glass':                                  'Verre vert',
  'en:dark-sort-glass':                              'Verre foncé',
  'en:light-sort-glass':                             'Verre clair',
  // Plastiques standards
  'en:plastic':                                      'Plastique',
  'en:hard-plastic':                                 'Plastique rigide',
  'en:soft-plastic':                                 'Plastique souple',
  'en:mixed-plastics':                               'Plastiques mélangés',
  'en:recyclable-plastic':                           'Plastique recyclable',
  'en:recycled-plastic':                             'Plastique recyclé',
  // PET et variantes
  'en:pet-1-polyethylene-terephthalate':             'PET (Plastique n°1)',
  'en:pet':                                          'PET (Plastique)',
  'en:pet-transparent':                              'PET transparent',
  'en:pet-colored':                                  'PET coloré',
  'en:rpet-recycled-polyethylene-terephthalate':     'rPET (PET recyclé)',
  'en:rpet-transparent':                             'rPET transparent',
  'en:petg-polyethylene-terephthalate-glycol':       'PETG (Plastique)',
  'en:petmet-metalized-polyethylene-terephthalate':  'PET métallisé',
  'en:bpet-biobased-pet':                            'PET biosourcé',
  // HDPE
  'en:hdpe-2-high-density-polyethylene':             'HDPE (Plastique n°2)',
  'en:hdpe':                                         'HDPE (Plastique)',
  'en:mdpe-medium-density-polyethylene':             'MDPE (Plastique)',
  'en:ldpe-4-low-density-polyethylene':              'LDPE (Plastique n°4)',
  'en:ldpe':                                         'LDPE (Plastique)',
  'en:lldpe-linear-low-density-polyethylene':        'LLDPE (Plastique)',
  'en:pe-7-polyethylene':                            'PE (Polyéthylène n°7)',
  // PP et variantes
  'en:pp-5-polypropylene':                           'Polypropylène (PP n°5)',
  'en:pp':                                           'Polypropylène (PP)',
  'en:opp-oriented-polypropylen':                    'OPP (Polypropylène orienté)',
  'en:cpp-cast-polypropylen':                        'CPP (Polypropylène cast)',
  // PVC
  'en:pvc-3-polyvinyl-chloride':                     'PVC (Plastique n°3)',
  'en:pvc':                                          'PVC (Plastique)',
  'en:pvdc-7-polyvinylidene-chloride':               'PVDC (Plastique n°7)',
  // PS et variantes
  'en:ps-6-polystyrene':                             'Polystyrène (PS n°6)',
  'en:ps':                                           'Polystyrène (PS)',
  'en:eps-expanded-polystyrene':                     'Polystyrène expansé (EPS)',
  // Autres plastiques
  'en:o-7-other-plastics':                           'Autre plastique (n°7)',
  'en:other-plastics-7':                             'Autre plastique (n°7)',
  'en:abs-acrylonitrile-butadiene-styrene':          'ABS (Plastique)',
  'en:abs':                                          'ABS (Plastique)',
  'en:eva-ethylene-vinyl-acetate':                   'EVA',
  'en:eva':                                          'EVA',
  'en:evoh-ethylene-vinyl-alcohol':                  'EVOH (barrière)',
  'en:evoh':                                         'EVOH (barrière)',
  'en:nylon-polyamide':                              'Nylon (Polyamide)',
  'en:pa-polyamide':                                 'PA (Polyamide)',
  'en:polyamide':                                    'Polyamide',
  'en:pc-polycarbonate':                             'Polycarbonate (PC)',
  'en:polycarbonate':                                'Polycarbonate',
  'en:pmma-poly-methyl-methacrylate':                'PMMA (Acrylique)',
  'en:pmma-acrylic':                                 'PMMA (Acrylique)',
  'en:pu-pur-polyurethane':                          'Polyuréthane',
  'en:pla-polylactic-acid':                          'PLA (Bioplastique)',
  'en:bioplastic':                                   'Bioplastique',
  'en:biobased-plastic':                             'Plastique biosourcé',
  'en:biodegradable-plastic':                        'Plastique biodégradable',
  'en:bio-sourced-plastic':                          'Plastique biosourcé',
  // Papier / Carton
  'en:cardboard':                                    'Carton',
  'en:recycled-cardboard':                           'Carton recyclé',
  'en:non-corrugated-cardboard':                     'Carton plat',
  'en:waxed-cardboard':                              'Carton ciré',
  'en:armed-cardboard':                              'Carton armé',
  'en:grass-carton':                                 'Carton végétal',
  'en:paperboard':                                   'Carton souple',
  'en:paper':                                        'Papier',
  'en:kraft-paper':                                  'Papier kraft',
  'en:recycled-paper':                               'Papier recyclé',
  'en:fsc-paper':                                    'Papier FSC',
  'en:other-paper':                                  'Autre papier',
  'en:paper-or-cardboard':                           'Papier ou carton',
  'en:cellulose':                                    'Cellulose',
  'en:wax':                                          'Cire',
  'en:washi-tape':                                   'Washi',
  // Matériaux composites — briques aseptiques
  'en:composite-material':                           'Matériau composite',
  'en:tetra-pak':                                    'Brique Tetra Pak',
  'en:tetra-brik-aseptic':                           'Brique Tetra Brik',
  'en:tetra-fino-aseptic':                           'Brique Tetra Fino',
  'en:elopak':                                       'Brique Elopak',
  'en:pure-pak':                                     'Brique Pure-Pak',
  'en:pure-pak-sense-aseptic':                       'Brique Pure-Pak Sense',
  'en:pure-pak-esense':                              'Brique Pure-Pak eSense',
  'en:pure-pak-sense':                               'Brique Pure-Pak Sense',
  'en:pure-pak-imagine':                             'Brique Pure-Pak Imagine',
  'en:naturally-pure-pak':                           'Brique Pure-Pak',
  'en:pure-pak-classic':                             'Brique Pure-Pak Classic',
  'en:sig':                                          'Brique SIG',
  'en:sig-combibloc':                                'Brique SIG Combibloc',
  'en:d-pak':                                        'Brique D-Pak',
  'en:multilayer':                                   'Multicouche',
  // Composites mixtes
  'en:plastic-aluminium':                            'Plastique-aluminium',
  'en:glass-aluminium':                              'Verre-aluminium',
  'en:glass-plastic':                                'Verre-plastique',
  'en:glass-tinplate':                               'Verre-fer blanc',
  'en:paper-and-plastic':                            'Papier-plastique',
  'en:paper-and-fibreboard-aluminium':               'Papier-aluminium',
  'en:paper-and-cardboard-plastic-aluminium':        'Papier-plastique-aluminium',
  'en:recycled-material':                            'Matériau recyclé',
  // Matériaux naturels
  'en:wood':                                         'Bois',
  'en:cork':                                         'Liège',
  'en:cotton':                                       'Coton',
  'en:linen':                                        'Lin',
  'en:jute':                                         'Jute',
  'en:textile':                                      'Textile',
  'en:other-textiles':                               'Textile',
  'en:silicone':                                     'Silicone',
  'en:ceramic':                                      'Céramique',
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
      t.contains(':metal')    || t.contains('recyclable-metal')) { return _MaterialType.metal; }
  // ':tin' uniquement en tag exact (évite de matcher 'satin', 'atin', etc.)
  if (t == 'en:tin' || t.endsWith(':tin')) { return _MaterialType.metal; }
  // Briques composite (marques aseptiques) → carton
  if (t == 'en:tetra-pak'      || t.contains('tetra-brik') || t.contains('tetra-fino') ||
      t.contains('elopak')     || t.contains('pure-pak')   || t.contains('sig-combi') ||
      t == 'en:sig'            || t == 'en:d-pak') {
    return _MaterialType.cardboard;
  }
  if (t.contains('cardboard') || t.contains('paper') || t.contains('wood') ||
      t.contains('kraft') || t.contains('cellulose') || t.contains('multilayer') ||
      t.contains('paperboard') || t.contains('grass-carton') || t.contains('washi') ||
      t == 'en:wax' || t == 'en:composite-material') {
    return _MaterialType.cardboard;
  }
  if (t.contains('plastic')    || t.contains(':pet')   || t.contains(':hdpe') ||
      t.contains(':pvc')       || t.contains(':ldpe')  || t.contains(':lldpe') ||
      t.contains(':pp-')       || t == 'en:pp'         || t.contains(':opp') ||
      t.contains(':cpp')       || t.contains(':pvdc')  || t.contains(':pe-') ||
      t.contains(':pla-')      || t.contains(':eps-')  || t.contains(':petg') ||
      t.contains(':petmet')    || t.contains(':rpet')  || t.contains(':bpet') ||
      t.contains(':o-7')       || t.contains(':pu-')   || t.contains(':pur-') ||
      t.contains(':mdpe')      || t.contains(':abs')   || t.contains(':eva') ||
      t.contains(':evoh')      || t.contains(':ps-')   || t == 'en:ps' ||
      t.contains(':pmma')      || t.contains('acrylic') ||
      t.contains('polyprop')   || t.contains('polysty') || t.contains('polyethylene') ||
      t.contains('polylactic') || t.contains('polyureth') || t.contains('polycarbonate') ||
      t.contains('polyamide')  || t.contains('polyvinyl') || t.contains('bioplast') ||
      t.contains('silicone')   || t.contains(':pa-')) {
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

// Priorité effective d'un tag : les plastiques nommés battent le carton générique
int _tagPriority(String tag, _MaterialType type) {
  if (type == _MaterialType.plastic) {
    final t = tag.toLowerCase();
    if (t.contains(':pet')       || t.contains(':hdpe')  || t.contains(':pp') ||
        t.contains(':pvc')       || t.contains(':ldpe')  || t.contains(':lldpe') ||
        t.contains(':mdpe')      || t.contains(':pe-')   || t.contains(':opp') ||
        t.contains(':cpp')       || t.contains(':pvdc')  || t.contains(':ps-') ||
        t.contains(':eps-')      || t.contains(':abs')   || t.contains(':eva') ||
        t.contains(':evoh')      || t.contains(':pla-')  || t.contains(':petg') ||
        t.contains(':petmet')    || t.contains(':rpet')  || t.contains(':bpet') ||
        t.contains(':o-7')       || t.contains(':pu-')   || t.contains(':pa-') ||
        t.contains('polyprop')   || t.contains('polyethylene') || t.contains('polysty') ||
        t.contains('polylactic') || t.contains('polyureth')    || t.contains('polycarbonate') ||
        t.contains('polyamide')  || t.contains('polyvinyl')) {
      return 5; // plastique nommé > verre(4) > métal(3) > carton(2) > plastique générique(2)
    }
    return 2; // plastique générique (même niveau que carton)
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

    if (t.contains(':glass'))                                        { type = _MaterialType.glass;     label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':aluminium') || t.contains(':aluminum'))  { type = _MaterialType.metal;     label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':steel'))                                  { type = _MaterialType.metal;     label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':tinplate') || t == 'en:tin' || t.endsWith(':tin')) { type = _MaterialType.metal; label = 'Fer-blanc'; }
    else if (t.contains(':metal') || t.contains('recyclable-metal')) { type = _MaterialType.metal; label = 'Métal'; }
    // Briques composites (marques aseptiques) → carton
    else if (t == 'en:tetra-pak'   || t.contains('tetra-brik') || t.contains('tetra-fino') ||
             t.contains('elopak')  || t.contains('pure-pak')   || t.contains('sig-combi') ||
             t == 'en:sig'         || t == 'en:d-pak')             { type = _MaterialType.cardboard; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':cardboard') || t.contains('paperboard'))  { type = _MaterialType.cardboard; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':kraft'))                                  { type = _MaterialType.cardboard; label = 'Papier kraft'; }
    else if (t.contains(':paper'))                                  { type = _MaterialType.cardboard; label = _labelForTag(tag, _materialLabels); }
    // Plastiques nommés (score élevé dans _tagPriority)
    else if (t.contains(':rpet') || t.contains(':bpet'))            { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':pet-') || t == 'en:pet' || t.contains(':petg') || t.contains(':petmet')) { type = _MaterialType.plastic; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':hdpe') || t.contains(':mdpe') || t.contains(':lldpe')) { type = _MaterialType.plastic; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':pp-')  || t == 'en:pp' || t.contains(':opp') || t.contains(':cpp')) { type = _MaterialType.plastic; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':ldpe'))                                   { type = _MaterialType.plastic;   label = 'LDPE (Plastique n°4)'; }
    else if (t.contains(':pe-'))                                    { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':pvc') || t.contains(':pvdc'))             { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':ps-') || t == 'en:ps' || t.contains(':eps-')) { type = _MaterialType.plastic; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':pla-'))                                   { type = _MaterialType.plastic;   label = 'PLA (Bioplastique)'; }
    else if (t.contains(':pu-')  || t.contains(':pur-'))            { type = _MaterialType.plastic;   label = 'Polyuréthane'; }
    else if (t.contains(':pa-')  || t.contains(':o-7'))             { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':abs')  || t.contains(':eva') || t.contains(':evoh')) { type = _MaterialType.plastic; label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':pmma') || t.contains('acrylic'))          { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t.contains(':plastic') || t.contains('bioplast'))      { type = _MaterialType.plastic;   label = _labelForTag(tag, _materialLabels); }
    else if (t == 'en:wax' || t == 'en:composite-material')        { type = _MaterialType.cardboard; label = _labelForTag(tag, _materialLabels); }
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
  // Uniquement les catégories qui utilisent quasi-exclusivement le verre
  if (cat.contains('vins')  || cat.contains('wines')  ||
      cat.contains('spiritueux') || cat.contains('spirits') ||
      cat.contains('confiture') || cat.contains('jam') ||
      cat.contains('cornichon') || cat.contains('pickle') ||
      cat.contains('vinaigre') || cat.contains('vinegar') ||
      cat.contains('bocal') ||
      cats.any((c) => c.contains('wine') || c.contains('spirit') ||
                      c.contains('jam') || c.contains('spread') || c.contains('pickle') ||
                      c.contains('vinegar'))) { return _MaterialInfo(_MaterialType.glass, 'Verre', true); }
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
  // Vins/spiritueux → presque exclusivement verre
  if (cat.contains('vins') || cat.contains('wines') || cat.contains('spiritueux') ||
      cat.contains('spirits') ||
      cats.any((c) => c.contains('wine') || c.contains('spirit'))) {
    return 'Bouteille en verre';
  }
  // Confitures/cornichons/vinaigres → presque exclusivement bocal verre
  if (cat.contains('confiture') || cat.contains('jam') ||
      cat.contains('cornichon') || cat.contains('pickle') ||
      cat.contains('vinaigre') || cat.contains('vinegar') ||
      cat.contains('bocal') ||
      cats.any((c) => c.contains('jam') || c.contains('spread') || c.contains('pickle') ||
                      c.contains('vinegar'))) {
    return 'Bocal en verre';
  }
  // Eaux/sodas → bouteille (plastique ou verre selon produit)
  if (cat.contains('eaux minérales') || cat.contains('mineral waters') ||
      cat.contains('boissons gazeuses') || cat.contains('sodas') ||
      cats.any((c) => c.contains('mineral-water') || c.contains('soda'))) {
    return 'Bouteille';
  }
  // Laits/jus → peut être brique OU bouteille, ne pas inférer la forme
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
    final info       = _detectMaterial(product);
    final shapeFb    = _detectShape(product);   // fallback si API muette sur les formes
    final recyclable = info.recyclable ?? (info.type != _MaterialType.unknown);

    final Color mainColor;
    final IconData matIcon;
    final String matiereGeneric;

    switch (info.type) {
      case _MaterialType.glass:
        mainColor     = const Color(0xFF2E7D32);
        matIcon       = Icons.liquor_rounded;
        matiereGeneric = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Verre';
      case _MaterialType.cardboard:
        mainColor     = const Color(0xFF1565C0);
        matIcon       = Icons.inventory_2_rounded;
        matiereGeneric = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Carton / Papier';
      case _MaterialType.metal:
        mainColor     = const Color(0xFFF9A825);
        matIcon       = Icons.local_drink_rounded;
        matiereGeneric = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Métal';
      case _MaterialType.plastic:
        mainColor     = const Color(0xFFE65100);
        matIcon       = Icons.water_drop_rounded;
        matiereGeneric = info.preciseLabel.isNotEmpty ? info.preciseLabel : 'Plastique';
      case _MaterialType.unknown:
        mainColor     = const Color(0xFF616161);
        matIcon       = Icons.help_outline_rounded;
        matiereGeneric = '';
    }

    // ── Matières : tout ce que l'API retourne ─────────────────────────────
    final List<String> matChips = product.packagingMaterialsTags.isNotEmpty
        ? product.packagingMaterialsTags
            .map((t) => s.translatePackagingLabel(_labelForTag(t, _materialLabels)))
            .toSet().toList()
        : (matiereGeneric.isNotEmpty
            ? [s.translatePackagingLabel(matiereGeneric)]
            : []);

    // ── Formes : tout ce que l'API retourne ──────────────────────────────
    final List<String> shapeChips = product.packagingShapesTags.isNotEmpty
        ? product.packagingShapesTags
            .map((t) => s.translatePackagingLabel(_labelForTag(t, _shapeLabels)))
            .toSet().toList()
        : (shapeFb.isNotEmpty
            ? [s.translatePackagingLabel(shapeFb)]
            : []);

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
          Expanded(child: Text(s.barcodePackaging, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ))),
          if (recyclable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00C853), width: 1.5),
              ),
              child: Text(s.barcodeRecyclable,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    fontWeight: FontWeight.bold, color: Color(0xFF00C853))),
            ),
        ]),

        const SizedBox(height: 14),
        Divider(color: mainColor.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 14),

        // ── Formes : tout ce que l'API retourne ──────────────────────────
        _PackagingChipsRow(
          label: s.packagingTypeLabel,
          chips: shapeChips,
          emptyText: s.packagingNotSpecified,
          icon: Icons.category_outlined,
          color: mainColor,
          isDark: isDark,
        ),
        const SizedBox(height: 10),

        // ── Matières : tout ce que l'API retourne ────────────────────────
        _PackagingChipsRow(
          label: s.packagingMaterialLabel,
          chips: matChips,
          emptyText: s.packagingNotSpecified,
          icon: Icons.science_outlined,
          color: mainColor,
          isDark: isDark,
        ),

        // ── Eco-Score ────────────────────────────────────────────────────
        if (product.ecoScore.isNotEmpty) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: ecoColor, borderRadius: BorderRadius.circular(12),
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

class _PackagingChipsRow extends StatelessWidget {
  final String label;
  final List<String> chips;
  final String emptyText;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _PackagingChipsRow({
    required this.label, required this.chips, required this.emptyText,
    required this.icon, required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final empty = chips.isEmpty;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: empty ? 0.07 : 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: empty ? AppColors.textSecondary : color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 4),
        if (empty)
          Text(emptyText, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ))
        else
          Wrap(spacing: 6, runSpacing: 6, children: chips.map((chip) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Text(chip, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : color,
              )),
            ),
          ).toList()),
      ])),
    ]);
  }
}
