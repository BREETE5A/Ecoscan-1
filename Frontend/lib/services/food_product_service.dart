import 'package:dio/dio.dart';

// ── Composant d'emballage structuré depuis ecoscore_data.packaging.packagings ──
class PackagingComponent {
  final String shape;     // ex: 'en:can', 'en:bottle'
  final String material;  // ex: 'en:steel', 'en:pet-1-polyethylene-terephthalate'
  final String recycling; // ex: 'en:recycled', 'en:non-recyclable-and-non-biodegradable-material'
  final double? weight;   // poids en grammes (utilisé pour trouver le composant principal)

  const PackagingComponent({
    required this.shape,
    required this.material,
    required this.recycling,
    this.weight,
  });

  bool? get isRecyclable {
    if (recycling.contains('non-recyclable') || recycling.contains('not-recycled')) {
      return false;
    }
    if (recycling.contains('recycled') || recycling.contains('recyclable')) {
      return true;
    }
    return null;
  }
}

class FoodProduct {
  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;
  final String nutriScore;
  final String ecoScore;
  final String packaging;
  final List<String> packagingTags;
  final List<String> packagingMaterialsTags;  // tags matériaux dédiés (plus fiables)
  final List<String> packagingShapesTags;     // tags formes dédiés
  final List<String> packagingRecyclingTags;  // tags recyclage dédiés
  final List<PackagingComponent> packagingComponents; // depuis ecoscore_data ou packagings direct
  final String quantity;
  final String categories;
  final List<String> categoriesTags;
  final String countries;
  final List<String> labels;
  final String ingredients;

  const FoodProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.nutriScore,
    required this.ecoScore,
    required this.packaging,
    required this.packagingTags,
    required this.packagingMaterialsTags,
    required this.packagingShapesTags,
    required this.packagingRecyclingTags,
    required this.packagingComponents,
    required this.quantity,
    required this.categories,
    required this.categoriesTags,
    required this.countries,
    required this.labels,
    required this.ingredients,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> p, String barcode) {
    String str(dynamic v) => (v ?? '').toString().trim();

    // Conversion sécurisée : gère null, List ET Map vide ({}) retourné par l'API
    List<String> safeList(dynamic v, {bool lowercase = false}) {
      if (v is! List) return [];
      return v
          .map((e) => lowercase ? e.toString().toLowerCase() : e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final labelTags = safeList(p['labels_tags'])
        .map((e) => e.replaceAll('en:', '').replaceAll('fr:', ''))
        .where((e) => e.isNotEmpty)
        .toList();

    final pkgTags          = safeList(p['packaging_tags']);
    final pkgMaterialsTags = safeList(p['packaging_materials_tags']);
    final pkgShapesTags    = safeList(p['packaging_shapes_tags']);
    final pkgRecyclingTags = safeList(p['packaging_recycling_tags']);
    final catTags          = safeList(p['categories_tags'], lowercase: true);

    // Extrait les composants structurés — packagings direct d'abord (types corrects),
    // puis ecoscore_data/environmental_score_data en fallback
    List<PackagingComponent> components = [];
    try {
      // Source 1 : packagings au niveau produit (données typées, poids = nombre)
      final directPkgs = p['packagings'] as List? ?? [];

      // Source 2 : ecoscore_data ou environmental_score_data (noms selon version API)
      final ecoData = (p['environmental_score_data'] ?? p['ecoscore_data']) as Map?;
      final pkgData = ecoData?['packaging'] as Map?;
      final ecoPkgs = pkgData?['packagings'] as List? ?? [];

      // Préfère packagings direct (poids numériques), sinon ecoscore
      final pkgsList = directPkgs.isNotEmpty ? directPkgs : ecoPkgs;

      components = pkgsList
          .map((m) {
            final map = m as Map? ?? {};
            // Poids peut être num (packagings direct) ou String (ecoscore_data)
            final wRaw = map['weight'] ?? map['weight_measured'];
            double? weightVal;
            if (wRaw is num) { weightVal = wRaw.toDouble(); }
            else if (wRaw is String) { weightVal = double.tryParse(wRaw); }
            return PackagingComponent(
              shape:     str(map['shape']),
              material:  str(map['material']),
              recycling: str(map['recycling']),
              weight:    weightVal,
            );
          })
          .where((c) => c.shape.isNotEmpty || c.material.isNotEmpty)
          .toList();
    } catch (_) {
      components = [];
    }

    return FoodProduct(
      barcode:                barcode,
      name:                   str(p['product_name_fr']).isNotEmpty
                                ? str(p['product_name_fr'])
                                : str(p['product_name']),
      brand:                  str(p['brands']),
      imageUrl:               str(p['image_front_url']),
      nutriScore:             str(p['nutriscore_grade']).toUpperCase(),
      ecoScore:               str(p['ecoscore_grade'] ?? p['environmental_score_grade']).toUpperCase(),
      packaging:              str(p['packaging']),
      packagingTags:          pkgTags,
      packagingMaterialsTags: pkgMaterialsTags,
      packagingShapesTags:    pkgShapesTags,
      packagingRecyclingTags: pkgRecyclingTags,
      packagingComponents:    components,
      quantity:               str(p['quantity']),
      categories:             str(p['categories']),
      categoriesTags:         catTags,
      countries:              str(p['countries']),
      labels:                 labelTags,
      ingredients:            str(p['ingredients_text_fr']).isNotEmpty
                                ? str(p['ingredients_text_fr'])
                                : str(p['ingredients_text']),
    );
  }
}

class FoodProductService {
  // Utilise l'endpoint legacy (pas /api/v2/ qui peut être instable)
  static final _dio = Dio(BaseOptions(
    baseUrl: 'https://world.openfoodfacts.org/',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'User-Agent': 'EcoScan/1.0 (badreddinehammoucha@gmail.com)'},
  ));

  static Future<FoodProduct?> fetch(String barcode) async {
    try {
      final resp = await _dio.get(
        'product/$barcode.json',
        queryParameters: {
          'fields':
              'product_name,product_name_fr,brands,image_front_url,'
              'nutriscore_grade,ecoscore_grade,environmental_score_grade,'
              'packaging,packaging_tags,'
              'packaging_materials_tags,packaging_shapes_tags,packaging_recycling_tags,'
              'packagings,ecoscore_data,environmental_score_data,'
              'quantity,categories,categories_tags,countries,labels_tags,'
              'ingredients_text,ingredients_text_fr',
        },
      );
      final data = resp.data as Map<String, dynamic>;
      if ((data['status'] ?? 0) != 1) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;
      return FoodProduct.fromJson(product, barcode);
    } catch (_) {
      return null;
    }
  }
}
