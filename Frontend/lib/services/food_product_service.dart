import 'package:dio/dio.dart';

class FoodProduct {
  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;
  final String nutriScore;  // A, B, C, D, E ou ''
  final String ecoScore;    // A, B, C, D, E ou ''
  final String packaging;   // ex: "Plastique, Carton"
  final String quantity;
  final String categories;
  final String countries;
  final List<String> labels; // Bio, Fair Trade, ...
  final String ingredients;

  const FoodProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.nutriScore,
    required this.ecoScore,
    required this.packaging,
    required this.quantity,
    required this.categories,
    required this.countries,
    required this.labels,
    required this.ingredients,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> p, String barcode) {
    String _str(dynamic v) => (v ?? '').toString().trim();

    final labelTags = (p['labels_tags'] as List?)
        ?.map((e) => e.toString().replaceAll('en:', '').replaceAll('fr:', ''))
        .where((e) => e.isNotEmpty)
        .toList() ?? [];

    return FoodProduct(
      barcode:     barcode,
      name:        _str(p['product_name_fr']) .isNotEmpty
                     ? _str(p['product_name_fr'])
                     : _str(p['product_name']),
      brand:       _str(p['brands']),
      imageUrl:    _str(p['image_front_url']),
      nutriScore:  _str(p['nutriscore_grade']).toUpperCase(),
      ecoScore:    _str(p['ecoscore_grade']).toUpperCase(),
      packaging:   _str(p['packaging']),
      quantity:    _str(p['quantity']),
      categories:  _str(p['categories']),
      countries:   _str(p['countries']),
      labels:      labelTags,
      ingredients: _str(p['ingredients_text_fr']).isNotEmpty
                     ? _str(p['ingredients_text_fr'])
                     : _str(p['ingredients_text']),
    );
  }
}

class FoodProductService {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'https://world.openfoodfacts.org/api/v2/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'User-Agent': 'EcoScan/1.0 (badreddinehammoucha@gmail.com)'},
  ));

  static Future<FoodProduct?> fetch(String barcode) async {
    try {
      final resp = await _dio.get(
        'product/$barcode.json',
        queryParameters: {
          'fields':
              'product_name,product_name_fr,brands,image_front_url,'
              'nutriscore_grade,ecoscore_grade,packaging,quantity,'
              'categories,countries,labels_tags,ingredients_text,ingredients_text_fr',
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
