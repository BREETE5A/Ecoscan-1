import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ChatService {
  late final Dio _dio;

  ChatService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: ApiConstants.timeoutSeconds),
        receiveTimeout: const Duration(seconds: ApiConstants.timeoutSeconds),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatEndpoint,
        data: {'message': message},
      );
      return response.data['response'] as String;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return _offlineFallback(message);
        case DioExceptionType.connectionError:
          return _offlineFallback(message);
        case DioExceptionType.badResponse:
          throw Exception('Erreur serveur ${e.response?.statusCode ?? ""}. Réessayez.');
        default:
          return _offlineFallback(message);
      }
    }
  }

  /// Réponses locales quand le backend n'est pas disponible.
  String _offlineFallback(String message) {
    final q = message.toLowerCase();

    if (q.contains('plastique') || q.contains('plastic')) {
      return '♻️ **Plastique** : Rincez les bouteilles et flacons avant de les mettre dans le bac jaune ECOVAL. Les sacs plastiques oxodégradables sont interdits au Maroc (Loi 77-15). Le film plastique souple et le polystyrène ne se recyclent pas.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('verre') || q.contains('glass')) {
      return '♻️ **Verre** : Déposez bouteilles et bocaux dans la colonne verte. Ne mettez pas : miroirs, verre trempé, pyrex, ampoules. Le verre est recyclable à 100% indéfiniment.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('papier') || q.contains('carton')) {
      return '♻️ **Papier/Carton** : Aplatissez les cartons avant de les mettre dans le bac bleu. Les tickets de caisse (BPA), le carton pizza gras et le papier hygiénique ne se recyclent pas.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('métal') || q.contains('metal') || q.contains('alu') || q.contains('canette')) {
      return '♻️ **Métal** : Canettes, boîtes de conserve, capsules → bac jaune ECOVAL. Recycler 1 kg d\'aluminium économise 8 kg de CO₂ et 95% de l\'énergie.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('électron') || q.contains('deee') || q.contains('téléphone') || q.contains('ordinateur')) {
      return '♻️ **DEEE** : Déposez vos appareils électroniques aux 500+ éco-points ECOVAL au Maroc. Décret 2-12-695 oblige les producteurs à assurer la collecte.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('organique') || q.contains('compost') || q.contains('déchet alimentaire') || q.contains('épluchure')) {
      return '♻️ **Organique** : 65% des déchets marocains sont organiques. Utilisez un composteur ou le bac marron. Épluchures, marc de café, sachets de thé → composteur. Viande, laitages → pas dans le composteur.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('pile') || q.contains('batterie')) {
      return '⚠️ **Piles/Batteries** : Ne jetez jamais dans la poubelle ordinaire ! Déposez-les dans les collecteurs en pharmacie, Marjane, ou éco-points. Une pile peut contaminer 1 000 L d\'eau.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('loi') || q.contains('réglementation') || q.contains('maroc')) {
      return '📋 **Lois au Maroc** :\n• Loi 28-00 : gestion des déchets\n• Loi 77-15 : interdiction sacs plastiques\n• Décret 2-12-695 : collecte DEEE\n• PNDM 2030 : 100% décharges contrôlées\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (q.contains('bonjour') || q.contains('salut') || q.contains('hello')) {
      return '👋 Bonjour ! Je suis EcoBot, votre assistant recyclage.\n\nJe fonctionne actuellement en mode hors ligne. Posez-moi vos questions sur le tri des déchets (plastique, verre, papier, métal, DEEE…).\n\n⚠️ Pour des réponses complètes via Gemini RAG, lancez le backend Python.';
    }

    return '🤖 Je suis en **mode hors ligne**. Le serveur backend (Gemini RAG) n\'est pas accessible.\n\nJe peux répondre à des questions sur : plastique, verre, papier, métal, DEEE, piles, compost, lois marocaines.\n\nPour activer le mode complet, lancez le backend Python sur votre PC.';
  }

  Future<bool> isHealthy() async {
    try {
      final response = await _dio.get(
        ApiConstants.healthEndpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
