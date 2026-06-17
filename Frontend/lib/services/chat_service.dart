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

  /// Supprime les symboles markdown que Gemini génère parfois (**, *, ##, __)
  String _cleanMarkdown(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll(RegExp(r'#{1,6} '), '')
        .replaceAll(RegExp(r'^\* ', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\*{3,}$', multiLine: true), '')
        .trim();
  }

  Future<String> sendMessage(String message, {List<Map<String, String>> history = const []}) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatEndpoint,
        data: {
          'message': message,
          'history': history,
        },
      );
      final raw = response.data['response'] as String;
      return _cleanMarkdown(raw);
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

    // ── Navigation dans l'application ────────────────────────────────────────
    if (_containsAny(q, ['mot de passe', 'password', 'كلمة المرور', 'contraseña', 'mdp',
        'كلمة السر', 'passord', 'باسوورد', 'سيكريتا'])) {
      return '🔐 Pour changer votre **mot de passe** :\nProfil → Paramètres → Changer le mot de passe.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['email', 'e-mail', 'adresse mail', 'البريد الإلكتروني', 'correo',
        'ميل', 'إيميل', 'البريد'])) {
      return '📧 Pour changer votre **email** :\nProfil → Paramètres → Changer l\'email.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['modifier profil', 'edit profile', 'photo profil', 'تعديل الملف',
        'editar perfil', 'changer nom', 'بدل الاسم', 'بدل صورة', 'صورة البروفيل', 'غير الاسم'])) {
      return '👤 Pour modifier votre **profil** (nom, photo) :\nProfil → Modifier le profil.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['badge', 'شارة', 'insignia', 'شارات', 'وسام', 'وسامات'])) {
      return '🏅 Pour voir vos **badges** :\nAccueil → Badges.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['statistique', 'stat', 'إحصائيات', 'estadística', 'co2',
        'recyclé combien', 'شحال ريسيكليت', 'إحصاء', 'نقط ديالي', 'كم كيلو'])) {
      return '📊 Pour voir vos **statistiques de recyclage** :\nAccueil → Statistiques.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['scanner', 'scan', 'photo déchet', 'مسح', 'escanear',
        'سكان', 'صور الزبل', 'صور القمامة', 'كيفاش نسكان', 'سكانيري'])) {
      return '📷 Pour **scanner un déchet** (IA photo) :\nAppuyez sur le bouton caméra central de la barre de navigation.\nPour un **code-barres** alimentaire : Accueil → Code-barres.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['carte', 'map', 'خريطة', 'mapa', 'point de collecte',
        'où déposer', 'près de moi', 'وين نلقى', 'فين نحط', 'قريب مني', 'خريطة ديال'])) {
      return '🗺️ Pour trouver les **points de collecte** près de vous :\nOnglet Carte dans la barre de navigation.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['défi', 'challenge', 'تحدي', 'reto', 'تحديات', 'شالنج'])) {
      return '🎯 Pour voir les **défis écologiques** :\nAccueil → Défis.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['récompense', 'reward', 'مكافأة', 'recompensa', 'point',
        'مكافآت', 'جائزة', 'بوانا', 'نقط ديال'])) {
      return '🎁 Pour voir vos **récompenses et points** :\nAccueil → Récompenses.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['classement', 'leaderboard', 'ترتيب', 'clasificación',
        'meilleur recycleur', 'ترتيب ديال', 'شكون لول', 'كلاسمون'])) {
      return '🏆 Pour voir le **classement des recycleurs** :\nAccueil → Classement.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['marketplace', 'marché', 'annonce', 'vendre', 'acheter',
        'سوق', 'mercado', 'بيع', 'شرا', 'مارك بلايس', 'إعلان'])) {
      return '🛍️ Pour accéder au **Marketplace** d\'objets recyclés :\nOnglet Marketplace dans la barre de navigation.\nPour vos annonces : Marketplace → Mes annonces.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['quiz', 'اختبار', 'test écologique', 'كويز', 'اختبار بيئي', 'أسئلة'])) {
      return '🧠 Pour faire le **quiz recyclage** (25 questions) :\nAccueil → Quiz recyclage.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['qualité de l\'air', 'air quality', 'جودة الهواء',
        'calidad del aire', 'هواء', 'تلوث الهواء', 'جودة ديال الهواء'])) {
      return '🌿 Pour voir la **qualité de l\'air** :\nAccueil → Qualité de l\'air.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['empreinte eau', 'water footprint', 'البصمة المائية',
        'huella hídrica', 'بصمة الماء', 'استهلاك الماء', 'empreinte hydrique'])) {
      return '💧 Pour suivre votre **empreinte eau** :\nAccueil → Empreinte eau.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['historique', 'history', 'سجل', 'historial', 'mes scans',
        'هيستوريك', 'ليست ديال', 'سجل ديال', 'سكانات ديالي'])) {
      return '📋 Pour voir l\'**historique de vos scans** :\nAccueil → Historique.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['paramètre', 'setting', 'إعدادات', 'ajuste', 'langue',
        'thème', 'notification', 'باراميتر', 'إعداد', 'لوغا', 'لغة'])) {
      return '⚙️ Pour accéder aux **paramètres** de l\'app :\nProfil → Paramètres.\n\n⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }

    // ── Contacts opérateurs ───────────────────────────────────────────────────
    if (_containsAny(q, ['contact', 'téléphone', 'numéro', 'appeler', 'هاتف', 'اتصل',
        'teléfono', 'نومرو', 'رقم', 'تيليفون', 'اتصال', 'كونتاكت', 'tous les contacts',
        'liste contacts', 'operateur', 'opérateur', 'مشغل', 'operador'])) {
      return '📞 **Opérateurs de recyclage au Maroc** (données vérifiées) :\n\n'
          '♻️ **Collecte & recyclage :**\n'
          '• AVERDA (collecte urbaine) : 0522 92 32 60 — averda.com\n'
          '• ARMA Rabat : 0537 66 32 90 — contact@arma.ma — arma.ma\n'
          '• SMRR (papier/carton/PET) : 0522 51 09 94 — adm@smrr.ma — smrr.ma\n'
          '• ECOVALOR (plastique/métal/papier) : 0522 35 66 00\n'
          '• TECMED Tanger : 0539 95 85 89\n\n'
          '📱 **DEEE (appareils électroniques) :**\n'
          '• Eco Zalagh : 0661 51 47 11 — Contact@ecozalagh.com — ecozalagh.com\n'
          '• ECOVAL Holcim (industriel uniquement) : 0522 58 20 05\n\n'
          '🌱 **ONG & associations :**\n'
          '• Zéro Zbel : contact@zerozabel.ma — zerozabel.ma\n'
          '• Caritas Maroc : 0522 29 11 22\n'
          '• Secours Catholique (Rabat) : 0537 73 44 55\n\n'
          '🏛️ **Institutions :**\n'
          '• ONEE (pollution eau/sol) : 0537 75 96 00 — info@onee.ma — onee.ma\n'
          '• MTEDD (ministère) : 0537 57 04 68 — www.mtedd.gov.ma\n'
          '• AMEE (économie circulaire) : 0537 28 73 53 — contact@amee.ma — amee.ma\n\n'
          '🚨 **Urgences :**\n'
          '• SAMU : 15 | Protection Civile : 150 | Police : 19 | Gendarmerie : 177\n'
          '• ONDE (enfants) : 2511 — 2511.ma\n'
          '• Femmes victimes de violence : 08000 8888\n\n'
          '📲 **Liste complète dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }
    if (_containsAny(q, ['ecoval', 'écoval', 'إيكوفال', 'بوكس أصفر', 'كونتونور أصفر',
        'bac jaune', 'حاوية صفراء'])) {
      return '♻️ **ECOVAL** au Maroc :\n'
          '• Bacs jaunes ECOVAL : plastiques (PET, PEHD), métaux, emballages rigides\n'
          '  → Points dans Marjane, Carrefour, Cosmos Electro\n'
          '• ECOVAL Holcim (industriel uniquement) : 0522 58 20 05\n'
          '• Pour DEEE (téléphones, ordi, TV) → Eco Zalagh : 0661 51 47 11 — Contact@ecozalagh.com\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }
    if (_containsAny(q, ['encombrant', 'matelas', 'meuble volumineux',
        'فراش خايب', 'كنبة', 'طابلو', 'أتاي كبير', 'حوايج كبار'])) {
      return '🚛 **Collecte des encombrants** (matelas, meubles volumineux…) :\n'
          '• Casablanca : AVERDA 0522 92 32 60 ou app "Casa Mdinti"\n'
          '• Rabat : ARMA Environnement 0537 66 32 90 — contact@arma.ma\n'
          '• Autres villes : contacter votre commune ou opérateur local\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }
    if (_containsAny(q, ['arma', 'ARMA', 'ارما', 'collecte rabat', 'ramassage rabat'])) {
      return '♻️ **ARMA Environnement** — Rabat :\n'
          '• Téléphone : 0537 66 32 90\n'
          '• Email : contact@arma.ma\n'
          '• Site : arma.ma\n'
          '• Adresse : Av. Mehdi Ben Barka, Lot Soumia N°5, Souissi, Rabat\n'
          '• Rôle : Collecte OM Rabat depuis 2015. Encombrants → les contacter directement.\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }
    if (_containsAny(q, ['smrr', 'SMRR', 'papier recyclage', 'carton recyclage', 'pet recyclage'])) {
      return '♻️ **SMRR** — Société Marocaine de Récupération et de Recyclage :\n'
          '• Téléphone : 0522 51 09 94\n'
          '• Email : adm@smrr.ma\n'
          '• Site : smrr.ma\n'
          '• Adresse : Zone Ind. Tit Mellil, Casablanca\n'
          '• Rôle : Leader recyclage papier/carton/PET — Casablanca, Tanger, Agadir, Marrakech.\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }
    if (_containsAny(q, ['eco zalagh', 'ecozalagh', 'إيكو زلاغ', 'deee', 'weee',
        'téléphone usagé', 'ordi usagé', 'لابتوب خايب', 'تيليفون خايب'])) {
      return '📱 **Eco Zalagh** — DEEE (appareils électroniques) :\n'
          '• Téléphone : 0661 51 47 11\n'
          '• Email : Contact@ecozalagh.com\n'
          '• Site : ecozalagh.com\n'
          '• Adresse : Sidi Hajaj Oulad Mrah, Casablanca\n'
          '• Couvre : Casablanca, Rabat, Tanger, Fès, Meknès, Marrakech\n'
          '• Rôle : Collecte smartphones, PC, TV, électroménager, batteries Li-ion.\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }
    if (_containsAny(q, ['onee', 'ONEE', 'pollution eau', 'rejet illégal', 'تلوث الماء',
        'contamination eau', 'déversement', 'signaler pollution',
        'mklf b lma', 'mklf lma', 'li mklf', 'responsable eau', 'responsible water',
        'lma', 'lmaa', 'lma3', 'coupure eau', 'qat3 lma', 'distribution eau',
        'water company', 'water supply', 'شركة الماء', 'مكتب الماء', 'الماء الصالح'])) {
      return '💧 **ONEE** — Office National Électricité & Eau Potable :\n'
          '• Téléphone : 0537 75 96 00 (gratuit 24h/24)\n'
          '• Email : info@onee.ma — onee.ma\n'
          '• Rôle : Responsable national de l\'eau potable et signalement pollution.\n\n'
          '🏙️ **Régies locales (facturation/coupures) :**\n'
          '• Casablanca : LYDEC\n'
          '• Rabat-Salé : REDAL\n'
          '• Tanger-Tétouan : AMENDIS\n'
          '• Autres villes : contacter votre commune ou ONEE directement.\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — backend non disponible.*';
    }

    // ── Tri des déchets ───────────────────────────────────────────────────────
    if (_containsAny(q, ['plastique', 'plastic', 'بلاستيك', 'pet', 'bouteille plastique',
        'قوارير', 'بلاسطيك', 'كيسان', 'كيسة', 'كيس', 'بلاستيكة', 'قارورة'])) {
      return '♻️ **Plastique** : Rincez les bouteilles et flacons → bac jaune ECOVAL. '
          'Les sacs plastiques sont interdits au Maroc (Loi 77-15). '
          'Film plastique souple et polystyrène → poubelle.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['verre', 'glass', 'زجاج', 'vidrio', 'bocal', 'bouteille verre',
        'قاروة ديال الزجاج', 'كاس', 'زجاجة', 'قارورة زجاج'])) {
      return '♻️ **Verre** : Bouteilles et bocaux → colonne verte. '
          'Ne mettez pas : miroirs, verre trempé, pyrex, ampoules. '
          'Le verre est recyclable à 100% indéfiniment.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['papier', 'carton', 'ورق', 'papel', 'journal', 'magazine',
        'كارطون', 'ورقة', 'جرنان', 'بريد', 'كارتون'])) {
      return '♻️ **Papier/Carton** : Au Maroc, la ferracha assure l\'essentiel du recyclage.\n'
          'Journaux, cartons aplatis, boîtes céréales → ferracha ou bac bleu (rare).\n'
          'Tickets de caisse (BPA), carton pizza gras, papier hygiénique → poubelle.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['métal', 'metal', 'alu', 'canette', 'معدن', 'aluminium',
        'علبة', 'علب', 'قصدير', 'كانيطة', 'حديد', 'صفيح'])) {
      return '♻️ **Métal** : Canettes, boîtes de conserve, capsules → bac jaune ECOVAL. '
          '1 kg d\'alu recyclé économise 8 kg CO₂ et 95% d\'énergie.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['électron', 'deee', 'weee', 'ordinateur', 'téléphone', 'إلكتروني',
        'تيليفون', 'كومبيوتر', 'شاشة', 'تيلي', 'حاسوب', 'لابتوب', 'تابليت',
        'جهاز خايب', 'موبايل خايب', 'شاحور'])) {
      return '♻️ **DEEE** : Appareils électroniques = déchets dangereux (Loi 28-00).\n'
          '• Effacez vos données avant de déposer.\n'
          '• Éco-points ECOVAL : Marjane, Carrefour, Cosmos Electro\n'
          '• Ou contacter Eco Zalagh : 0661 51 47 11 (ecozalagh.com)\n\n'
          '📲 **Dans l\'app :** Accueil → Guide de Tri → Opérateurs & contacts\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['organique', 'compost', 'épluchure', 'عضوي', 'composteur',
        'قشر', 'خضرة', 'بقايا الكلة', 'زبل عضوي', 'تفاهة', 'خضار', 'فواكه'])) {
      return '♻️ **Organique** : Plus de 60% des déchets marocains sont organiques. '
          'Épluchures, marc de café, pain → composteur. '
          'Viande, poisson, laitages → poubelle ordinaire.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['pile', 'batterie', 'بطارية', 'battery',
        'بيلة', 'بيلات', 'باطاري', 'بيل ديال', 'باتيري'])) {
      return '⚠️ **Piles/Batteries** : Ne jetez JAMAIS dans la poubelle ! '
          'Déposez dans les collecteurs Marjane, Carrefour, Label\'Vie ou éco-points. '
          'Une pile = 1 000 L d\'eau contaminée.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['loi', 'réglementation', 'قانون', 'ley', 'interdit', 'amende',
        'قانون البيئة', 'غرامة', 'ممنوع', 'حرام', 'مخالفة'])) {
      return '📋 **Lois environnementales au Maroc** (vérifiées) :\n'
          '• Loi 28-00 (2006) : gestion des déchets — amendes jusqu\'à 2 000 000 DH\n'
          '• Loi 77-15 (2016) : interdiction sacs plastiques "Zéro Mika"\n'
          '• Loi 49-17 (2022) : évaluation environnementale\n'
          '• PNVDM 2023-2034 : 21,14 milliards DH pour réhabilitation décharges\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['textile', 'vêtement', 'habit', 'ملابس', 'ropa',
        'حوايج', 'ليباس', 'ثياب', 'صبادر', 'جلابة', 'قفطان', 'سروال'])) {
      return '♻️ **Textile** : Déposez vêtements et chaussures dans les bornes textiles. '
          'Même abîmés, ils sont recyclés en chiffons industriels. '
          'Caritas Maroc, SOS Villages d\'Enfants acceptent les dons.\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['dangereux', 'médicament', 'peinture', 'solvant', 'خطير',
        'peligroso', 'دوا', 'دواء', 'دوا خايب', 'صبغة', 'زيت محرك', 'حقنة'])) {
      return '⚠️ **Déchets dangereux** :\n'
          '• Médicaments (دوا خايب) → pharmacie agréée\n'
          '• Huile moteur (زيت المحرك) → garage agréé\n'
          '• Peintures/solvants → déchetterie zone dangereux\n'
          '• Seringues (حقنة) → boîte DASRI en pharmacie\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }
    if (_containsAny(q, ['bonjour', 'salut', 'hello', 'مرحبا', 'السلام', 'hola', 'مرحب',
        'آش حال', 'لاباس', 'صباح الخير', 'مساء الخير', 'سلام عليكم', 'كيداير'])) {
      return '👋 Bonjour ! Je suis EcoBot, votre assistant EcoScan.\n\n'
          'Je peux vous aider à :\n'
          '• Trier vos déchets (plastique, verre, métal…)\n'
          '• Naviguer dans l\'app (changer mdp, voir stats…)\n'
          '• Trouver des contacts d\'opérateurs de recyclage\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }

    // ── Déchets génériques en darija ─────────────────────────────────────────
    if (_containsAny(q, ['زبل', 'نفاية', 'قمامة', 'فين نحط', 'واش نرمي',
        'كيفاش نريسيكلي', 'وين نرمي', 'ريسيكلاج', 'فرز'])) {
      return '♻️ **Tri des déchets au Maroc** :\n'
          '• قوارير البلاستيك → bac jaune ECOVAL (Marjane, Carrefour)\n'
          '• الزجاج → colonne verte (عمود أخضر)\n'
          '• الورق/الكارطون → ferracha (الفراشة)\n'
          '• العلب المعدنية → bac jaune ECOVAL\n'
          '• الأجهزة الإلكترونية → Eco Zalagh 0661 51 47 11\n\n'
          '⚠️ *Mode hors ligne — lancez le backend pour des réponses complètes.*';
    }

    return '🤖 Je suis en **mode hors ligne**. Le serveur backend (Gemini RAG) n\'est pas accessible.\n\n'
        'Je peux répondre sur : tri des déchets, navigation dans l\'app, contacts opérateurs.\n\n'
        'Pour activer le mode complet, lancez le backend Python sur votre PC.';
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

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
