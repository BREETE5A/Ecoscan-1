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

// ── Carte recyclabilité ───────────────────────────────────────────────────────
// ── Détection matériau ───────────────────────────────────────────────────────
enum _MaterialType { glass, plastic, metal, cardboard, unknown }

_MaterialType _detectMaterial(String packaging) {
  final p = packaging.toLowerCase();
  if (p.contains('verre') || p.contains('glass')) {
    return _MaterialType.glass;
  }
  if (p.contains('carton') || p.contains('cardboard') ||
      p.contains('papier') || p.contains('paper')) {
    return _MaterialType.cardboard;
  }
  if (p.contains('aluminium') || p.contains('aluminum') ||
      p.contains('acier')     || p.contains('steel') ||
      p.contains('métal')     || p.contains('metal')) {
    return _MaterialType.metal;
  }
  if (p.contains('pet')       || p.contains('hdpe') || p.contains('ldpe') ||
      p.contains('plastique') || p.contains('plastic') ||
      p.contains('recyclable')) {
    return _MaterialType.plastic;
  }
  return _MaterialType.unknown;
}

// ── Carte recyclabilité enrichie ─────────────────────────────────────────────
class _RecyclabilityCard extends StatelessWidget {
  final FoodProduct product;
  final bool isDark;
  final AppStrings s;
  const _RecyclabilityCard({required this.product, required this.isDark, required this.s});

  @override
  Widget build(BuildContext context) {
    final mat       = _detectMaterial(product.packaging);
    final recyclable = mat != _MaterialType.unknown;

    // Couleurs & libellés selon matériau
    final Color mainColor;
    final Color binColor;
    final String matName;
    final String binName;
    final List<String> steps;
    final IconData matIcon;

    switch (mat) {
      case _MaterialType.glass:
        mainColor = const Color(0xFF2E7D32);
        binColor  = const Color(0xFF2E7D32);
        matName   = s.catGlass;
        binName   = s.binGreen;
        steps     = s.barcodeGlassSteps();
        matIcon   = Icons.liquor_rounded;
      case _MaterialType.cardboard:
        mainColor = const Color(0xFF1565C0);
        binColor  = const Color(0xFF1565C0);
        matName   = s.catCardboard;
        binName   = s.binBlue;
        steps     = s.barcodeCardboardSteps();
        matIcon   = Icons.inventory_2_rounded;
      case _MaterialType.metal:
        mainColor = const Color(0xFFF9A825);
        binColor  = const Color(0xFFF9A825);
        matName   = s.catMetal;
        binName   = s.binYellow;
        steps     = s.barcodeMetalSteps();
        matIcon   = Icons.local_drink_rounded;
      case _MaterialType.plastic:
        mainColor = const Color(0xFFE65100);
        binColor  = const Color(0xFFF9A825);
        matName   = s.catPlastic;
        binName   = s.binYellow;
        steps     = s.barcodePlasticSteps();
        matIcon   = Icons.water_drop_rounded;
      case _MaterialType.unknown:
        mainColor = const Color(0xFF616161);
        binColor  = const Color(0xFF212121);
        matName   = s.barcodeUnknown;
        binName   = s.binBlack;
        steps     = s.barcodeNonRecyclableSteps();
        matIcon   = Icons.help_outline_rounded;
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
        border: Border.all(color: mainColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Ligne 1 : matériau + recyclable + Eco-Score ──────────────────
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(matIcon, color: mainColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.barcodeMaterial, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary,
            )),
            Text(matName, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 15,
              fontWeight: FontWeight.bold, color: mainColor,
            )),
          ])),
          // Badge recyclable / non recyclable
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (recyclable ? const Color(0xFF00C853) : const Color(0xFFD50000))
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: recyclable ? const Color(0xFF00C853) : const Color(0xFFD50000),
                width: 1.5,
              ),
            ),
            child: Text(
              recyclable ? s.barcodeRecyclable : s.barcodeNotRecyclable,
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold,
                color: recyclable ? const Color(0xFF00C853) : const Color(0xFFD50000),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 14),
        Divider(color: mainColor.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 14),

        // ── Ligne 2 : bac recommandé ─────────────────────────────────────
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: binColor, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: binColor.withValues(alpha: 0.4), blurRadius: 6)]),
            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.barcodeBin, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary,
            )),
            Text(binName, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 13,
              fontWeight: FontWeight.w700, color: binColor,
            )),
          ]),
          if (product.ecoScore.isNotEmpty) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ecoColor, borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Eco-Score ${product.ecoScore}', style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.bold, color: Colors.white,
              )),
            ),
          ],
        ]),

        const SizedBox(height: 14),

        // ── Ligne 3 : instructions étape par étape ───────────────────────
        Text(s.barcodeHowToRecycle, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 13,
          fontWeight: FontWeight.w700, color: mainColor,
        )),
        const SizedBox(height: 8),
        ...List.generate(steps.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 22, height: 22,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: mainColor, shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('${i + 1}', style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.bold, color: Colors.white,
              )),
            ),
            Expanded(child: Text(steps[i], style: TextStyle(
              fontFamily: 'Poppins', fontSize: 13,
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ))),
          ]),
        )),

      ]),
    );
  }
}
