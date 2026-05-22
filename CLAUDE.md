# CLAUDE.md — EcoScan : Intégration Backend + TFLite

> Lu automatiquement par Claude Code.
> COMMENCE par lire ce fichier entièrement avant de toucher au moindre fichier.

---

## ÉTAPE 0 — Analyse de la situation existante

Avant toute modification, Claude Code doit :

1. Lire `main.dart` pour comprendre le point d'entrée
2. Lire `lib/screens/home/` pour voir les données hardcodées
3. Lire `lib/screens/profile/` idem
4. Lire `lib/screens/chat/` pour voir l'état actuel du chatbot
5. Lire `lib/screens/scan/` pour voir le flux de scan actuel
6. Lire `lib/providers/` pour voir les providers existants
7. Lire `lib/services/` pour voir les services existants
8. Lire `lib/models/` pour voir les modèles existants
9. Lire `pubspec.yaml` pour voir les dépendances actuelles
10. Lire `Backend/main.py` pour confirmer les endpoints disponibles
11. Lire `Backend/app/routes/chat_routes.py` pour voir l'endpoint /chat
12. Lire `Backend/app/services/rag_chatbot.py` pour comprendre le chatbot
13. Lire `Backend/app/schemas/chat_schema.py` pour les schémas

⚠️ NE PAS supposer quoi que ce soit. Lire d'abord, agir ensuite.

---

## Structure réelle du projet

```
EcoScan/
├── CLAUDE.md                          ← ce fichier
│
├── Backend/                           ← FastAPI existant et fonctionnel
│   ├── main.py                        ← app FastAPI, endpoint POST /chat
│   ├── app/
│   │   ├── routes/
│   │   │   └── chat_routes.py         ← route /chat
│   │   ├── schemas/
│   │   │   └── chat_schema.py         ← ChatRequest { message: str }
│   │   │                                 ChatResponse { response: str }
│   │   └── services/
│   │       └── rag_chatbot.py         ← EcoScanRAGChatbot.ask(question) → str
│   ├── chroma_ecoscan/
│   │   └── chroma.sqlite3             ← base vectorielle RAG (ne pas toucher)
│   ├── .env.example                   ← copier en .env avec GOOGLE_API_KEY
│   └── requirements.txt
│
└── flutter_app/                       ← app Flutter existante
    ├── pubspec.yaml
    ├── assets/
    │   └── models/
    │       └── model.tflite           ← modèle MobileNetV2 (déjà en place)
    └── lib/
        ├── constants/
        ├── l10n/
        ├── models/                    ← modèles existants à compléter
        ├── providers/                 ← providers existants à compléter
        ├── router/
        ├── screens/
        │   ├── auth/
        │   ├── badges/                ← priorité basse
        │   ├── challenges/            ← priorité basse
        │   ├── chat/                  ← PRIORITÉ HAUTE (brancher /chat)
        │   ├── guide/
        │   ├── history/
        │   ├── home/                  ← PRIORITÉ HAUTE (données statiques)
        │   ├── language/
        │   ├── leaderboard/           ← priorité moyenne
        │   ├── map/
        │   ├── notifications/
        │   ├── onboarding/
        │   ├── profile/               ← PRIORITÉ HAUTE (données statiques)
        │   ├── rewards/               ← priorité basse
        │   ├── scan/                  ← PRIORITÉ HAUTE (brancher TFLite)
        │   ├── settings/
        │   ├── splash/
        │   └── stats/
        ├── services/                  ← services existants à compléter
        ├── theme/
        └── widgets/
```

---

## Règle fondamentale

> Adapter le code existant, ne jamais le réécrire de zéro.
> Si un provider, service ou modèle existe déjà, le compléter.
> Si un fichier n'existe pas, le créer.
> Toujours vérifier avant de créer.

---

## ÉTAPE 1 — Vérifier et compléter les modèles

### Vérifier `lib/models/`
- Si `user_model.dart` existe → vérifier qu'il contient : `points`, `scans`, `co2Saved`, `level`, `xp`, `xpMax`, `badges`, `rank`, `weeklyProgress`. Ajouter les champs manquants.
- Si absent → créer avec ces champs :

```dart
class UserModel {
  final String id;
  final String name;
  final String city;
  final int points;
  final int scans;
  final int badges;
  final int rank;
  final int level;
  final int xp;
  final int xpMax;
  final double co2Saved;
  final double weeklyGoalKg;
  final double weeklyProgress;

  const UserModel({
    required this.id, required this.name, required this.city,
    required this.points, required this.scans, required this.badges,
    required this.rank, required this.level, required this.xp,
    required this.xpMax, required this.co2Saved,
    required this.weeklyGoalKg, required this.weeklyProgress,
  });

  factory UserModel.empty() => const UserModel(
    id: '', name: 'Utilisateur', city: 'Maroc',
    points: 0, scans: 0, badges: 0, rank: 0,
    level: 1, xp: 0, xpMax: 200,
    co2Saved: 0, weeklyGoalKg: 10.0, weeklyProgress: 0.0,
  );

  UserModel copyWith({
    int? points, int? scans, double? co2Saved,
    double? weeklyProgress, int? badges, int? rank,
    int? level, int? xp, int? xpMax,
  }) => UserModel(
    id: id, name: name, city: city,
    points: points ?? this.points,
    scans: scans ?? this.scans,
    badges: badges ?? this.badges,
    rank: rank ?? this.rank,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    xpMax: xpMax ?? this.xpMax,
    co2Saved: co2Saved ?? this.co2Saved,
    weeklyGoalKg: weeklyGoalKg,
    weeklyProgress: weeklyProgress ?? this.weeklyProgress,
  );
}
```

- Si `scan_result_model.dart` existe → vérifier qu'il a `fromJson`. Sinon créer :

```dart
class ScanResultModel {
  final String rawClass;
  final String category;
  final String binColor;
  final double confidence;
  final double co2SavedPerKg;
  final DateTime scannedAt;

  const ScanResultModel({
    required this.rawClass, required this.category,
    required this.binColor, required this.confidence,
    required this.co2SavedPerKg, required this.scannedAt,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) =>
    ScanResultModel(
      rawClass: json['raw_class'] ?? '',
      category: json['category'] ?? 'Inconnu',
      binColor: json['bin_color'] ?? 'gris',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      co2SavedPerKg: (json['co2_saved_per_kg'] as num?)?.toDouble() ?? 1.0,
      scannedAt: DateTime.now(),
    );
}
```

---

## ÉTAPE 2 — Vérifier et compléter les services

### Vérifier `lib/services/`

**`api_service.dart`** — Si existe, vérifier qu'il a `chat()` et `scanImage()`.
Si absent ou incomplet, ajouter :

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ MODIFIER selon environnement :
  // Émulateur Android : 'http://10.0.2.2:8000'
  // Vrai appareil     : 'http://TON_IP_LOCAL:8000'  ← remplacer TON_IP_LOCAL
  // Production        : 'https://ton-backend.onrender.com'
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Appel chatbot → Backend/app/routes/chat_routes.py
  static Future<String> chat(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['response'] as String;
    }
    throw Exception('Erreur chatbot: ${response.statusCode}');
  }

  // Health check
  static Future<bool> isBackendAlive() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) { return false; }
  }
}
```

**`tflite_service.dart`** — Si existe, vérifier qu'il a `classify(File)`.
Si absent ou incomplet :

```dart
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  static Interpreter? _interpreter;

  // ⚠️ Adapter les labels selon les vraies classes du modèle
  static const List<String> labels = [
    'cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'
  ];

  static const Map<String, Map<String, String>> categoryInfo = {
    'plastic':   {'label': 'Plastique', 'bin': 'jaune',  'emoji': '🟡'},
    'glass':     {'label': 'Verre',     'bin': 'vert',   'emoji': '🟢'},
    'metal':     {'label': 'Métal',     'bin': 'gris',   'emoji': '⚫'},
    'paper':     {'label': 'Papier',    'bin': 'bleu',   'emoji': '🔵'},
    'cardboard': {'label': 'Carton',    'bin': 'bleu',   'emoji': '🔵'},
    'trash':     {'label': 'Ordures',   'bin': 'noir',   'emoji': '⚫'},
  };

  static Future<void> init() async {
    _interpreter ??= await Interpreter.fromAsset('assets/models/model.tflite');
  }

  static Future<Map<String, dynamic>> classify(File imageFile) async {
    await init();
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes)!;
    final resized = img.copyResize(decoded, width: 224, height: 224);

    final input = List.generate(1, (_) =>
      List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    final output = [List.filled(labels.length, 0.0)];
    _interpreter!.run(input, output);

    final scores = output[0];
    final maxIdx = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
    final label = labels[maxIdx];
    final info = categoryInfo[label] ?? {'label': label, 'bin': 'inconnu', 'emoji': '❓'};

    return {
      'raw_class': label,
      'category': info['label'],
      'bin_color': info['bin'],
      'emoji': info['emoji'],
      'confidence': scores[maxIdx],
      'co2_saved_per_kg': 1.0,
      'source': 'tflite_offline',
    };
  }
}
```

**`storage_service.dart`** — Si existe, vérifier persistance points/scans/CO₂.
Si absent :

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/scan_result_model.dart';

class StorageService {
  static const _keyScans   = 'user_scans_count';
  static const _keyPoints  = 'user_points';
  static const _keyCo2     = 'user_co2_grams';
  static const _keyHistory = 'scan_history';

  static Future<int> getScans() async =>
    (await SharedPreferences.getInstance()).getInt(_keyScans) ?? 0;

  static Future<int> getPoints() async =>
    (await SharedPreferences.getInstance()).getInt(_keyPoints) ?? 0;

  static Future<double> getCo2() async =>
    (await SharedPreferences.getInstance()).getDouble(_keyCo2) ?? 0.0;

  static Future<void> addScan(ScanResultModel result, int pts) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyScans,  (p.getInt(_keyScans)  ?? 0) + 1);
    await p.setInt(_keyPoints, (p.getInt(_keyPoints) ?? 0) + pts);
    await p.setDouble(_keyCo2, (p.getDouble(_keyCo2) ?? 0) + result.co2SavedPerKg * 100);

    final raw = p.getString(_keyHistory);
    final history = raw != null ? List<Map>.from(jsonDecode(raw)) : [];
    history.insert(0, {
      'category': result.category,
      'bin_color': result.binColor,
      'confidence': result.confidence,
      'scanned_at': result.scannedAt.toIso8601String(),
    });
    if (history.length > 50) history.removeLast();
    await p.setString(_keyHistory, jsonEncode(history));
  }

  static Future<List<Map>> getHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyHistory);
    return raw != null ? List<Map>.from(jsonDecode(raw)) : [];
  }
}
```

---

## ÉTAPE 3 — Vérifier et compléter les providers

### Vérifier `lib/providers/`

Si un `UserProvider` ou équivalent existe → l'adapter pour lire depuis `StorageService`.
Si absent → créer `lib/providers/user_provider.dart` :

```dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/scan_result_model.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel.empty();
  List<Map> _recentScans = [];
  bool _isLoading = false;

  UserModel get user => _user;
  List<Map> get recentScans => _recentScans;
  bool get isLoading => _isLoading;

  Future<void> loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    final scans   = await StorageService.getScans();
    final points  = await StorageService.getPoints();
    final co2     = await StorageService.getCo2();
    final history = await StorageService.getHistory();

    _user = UserModel(
      id: 'local_user',
      name: _user.name.isEmpty ? 'Utilisateur' : _user.name,
      city: _user.city.isEmpty ? 'Maroc' : _user.city,
      points: points,
      scans: scans,
      badges: _computeBadges(scans, points),
      rank: 0,
      level: (points ~/ 200) + 1,
      xp: points % 200,
      xpMax: 200,
      co2Saved: co2,
      weeklyGoalKg: 10.0,
      weeklyProgress: (co2 / 10000).clamp(0.0, 1.0),
    );

    _recentScans = history.take(4).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordScan(ScanResultModel result) async {
    await StorageService.addScan(result, 10);
    await loadFromStorage();
  }

  void setName(String name) {
    _user = _user.copyWith();
    notifyListeners();
  }

  int _computeBadges(int scans, int points) {
    int c = 0;
    if (scans >= 1)    c++;
    if (scans >= 10)   c++;
    if (scans >= 50)   c++;
    if (points >= 100) c++;
    if (points >= 500) c++;
    return c;
  }
}
```

---

## ÉTAPE 4 — Modifier main.dart

Lire `main.dart` d'abord. Vérifier si `MultiProvider` est déjà présent.
Si non, wrapper le `MaterialApp` existant :

```dart
// Ajouter import :
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

// Wrapper l'app existante :
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()..loadFromStorage()),
    // garder tous les providers déjà existants
  ],
  child: /* ton MaterialApp existant */,
)
```

---

## ÉTAPE 5 — Modifier lib/screens/chat/

Lire les fichiers dans `lib/screens/chat/`.

**Cas A — Le chatbot envoie déjà des messages mais avec des réponses mockées :**
Trouver la fonction qui retourne la réponse et remplacer par :
```dart
import '../../services/api_service.dart';

// Remplacer la réponse mockée par :
final reply = await ApiService.chat(userMessage);
```

**Cas B — L'écran chat est vide ou absent :**
Copier le contenu suivant dans le fichier principal de l'écran chat :
- Interface bulle utilisateur (droite, vert foncé `#2D6A4F`)
- Interface bulle EcoBot (gauche, blanc avec ombre)
- Indicateur de frappe animé (3 points qui pulsent)
- Zone de saisie avec bouton envoi
- Appel `ApiService.chat(message)` sur envoi
- Gestion erreur réseau avec message utilisateur

---

## ÉTAPE 6 — Modifier lib/screens/scan/

Lire les fichiers dans `lib/screens/scan/`.

Trouver la fonction qui traite l'image capturée et la remplacer par :

```dart
import '../../services/tflite_service.dart';
import '../../services/api_service.dart';
import '../../models/scan_result_model.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

Future<void> analyzeImage(File imageFile) async {
  setState(() => isAnalyzing = true);

  Map<String, dynamic> result;
  try {
    // Essayer backend online en premier (plus précis)
    result = await ApiService.scanImage(imageFile);
  } catch (_) {
    // Fallback TFLite offline si pas de connexion
    result = await TFLiteService.classify(imageFile);
  }

  final scanResult = ScanResultModel.fromJson(result);

  // Mettre à jour les stats (points, CO₂, historique)
  await context.read<UserProvider>().recordScan(scanResult);

  setState(() => isAnalyzing = false);

  // Afficher le résultat — adapter selon la navigation existante
  // Ne pas changer la navigation, juste passer scanResult au lieu des données statiques
}
```

⚠️ Ne pas changer la navigation existante. Juste remplacer les données passées à l'écran résultat.

---

## ÉTAPE 7 — Modifier lib/screens/home/

Lire les fichiers dans `lib/screens/home/`.

Ajouter en haut du widget principal :
```dart
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// Dans build() :
final user = context.watch<UserProvider>().user;
final recentScans = context.watch<UserProvider>().recentScans;
```

Remplacer chaque valeur hardcodée trouvée :
```
'Amine Benali'  →  user.name
'Amine'         →  user.name.split(' ').first
1240            →  user.points
47              →  user.scans
'870 g'         →  '${user.co2Saved.toStringAsFixed(0)} g'
0.75            →  user.weeklyProgress  (progress bar)
12.5            →  user.weeklyGoalKg
'2.4 kg CO₂'   →  '${(user.co2Saved/1000).toStringAsFixed(1)} kg CO₂'
'0.3 arbres'    →  '${(user.co2Saved/8000).toStringAsFixed(1)} arbres'
'40 L'          →  '${(user.co2Saved*0.05).toStringAsFixed(0)} L'
Liste 4 scans   →  recentScans.isEmpty ? widget "Aucun scan" : liste dynamique
```

---

## ÉTAPE 8 — Modifier lib/screens/profile/

Lire les fichiers dans `lib/screens/profile/`.

Même import UserProvider. Remplacer :
```
'Amine Benali'        →  user.name
'Éco-Warrior • Oujda' →  'Niveau ${user.level} • ${user.city}'
1240                  →  user.points
47                    →  user.scans
8                     →  user.badges
12 (rang)             →  user.rank == 0 ? 'N/A' : '#${user.rank}'
'Niveau 7'            →  'Niveau ${user.level}'
'1240/1800 XP'        →  '${user.xp}/${user.xpMax} XP'
value: 0.69           →  value: user.xp / user.xpMax
badges statiques      →  boucle : index < user.badges → unlocked, sinon locked
```

---

## ÉTAPE 9 — Modifier lib/screens/leaderboard/

Lire les fichiers dans `lib/screens/leaderboard/`.

```dart
final user = context.watch<UserProvider>().user;

// Sur l'entrée isMe: true, remplacer :
// nom hardcodé   →  user.name
// points hardcodés →  user.points
// scans hardcodés  →  user.scans
```

Garder les autres joueurs tels quels pour l'instant (pas de vraie DB encore).

---

## ÉTAPE 10 — Mettre à jour pubspec.yaml

Lire `pubspec.yaml`. Ajouter uniquement les dépendances manquantes :

```yaml
dependencies:
  provider: ^6.1.2           # si absent
  http: ^1.2.0               # si absent
  tflite_flutter: ^0.10.4    # si absent
  image: ^4.1.7              # si absent
  shared_preferences: ^2.2.3 # si absent

flutter:
  assets:
    - assets/models/model.tflite   # si absent
```

Ne pas supprimer les dépendances existantes.

---

## Règles absolues

1. **Lire avant d'écrire** — toujours lire le fichier existant avant de le modifier
2. **Ne jamais réécrire** un fichier entier si seules quelques lignes changent
3. **Ne jamais supprimer** du UI ou des fonctionnalités existantes
4. **Adapter** au code existant, pas l'inverse
5. **Aucune valeur hardcodée** pour nom, points, scans, CO₂, niveau, badges, rang
6. **`context.watch`** pour afficher des données dans les widgets
7. **`context.read`** pour les callbacks (onTap, onPressed)
8. **Signaler** si un fichier est ambigu avant de le modifier

---

## Commandes pour lancer et tester

```bash
# 1. Lancer le backend
cd Backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# 2. Vérifier que le backend répond
curl http://localhost:8000/health
# → {"status":"healthy"}

# 3. Tester le chatbot
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Comment recycler le plastique ?"}'

# 4. Lancer Flutter
cd flutter_app
flutter pub get
flutter run
```

---

## En cas de conflit ou d'ambiguïté

Si Claude Code trouve une situation non couverte par ce fichier :
- Lire le fichier concerné
- Appliquer le principe le plus proche décrit ici
- Signaler ce qui a été fait et pourquoi
` :

```dart
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// Dans build() :
final user = context.watch<UserProvider>().user;
final recentScans = context.watch<UserProvider>().recentScans;
```

### Remplacements home_screen.dart

```
❌ 'Amine Benali'                    →  ✅ user.name
❌ 'Amine'                           →  ✅ user.name.split(' ').first
❌ 1240  (points)                    →  ✅ user.points
❌ 47    (scans)                     →  ✅ user.scans
❌ '870 g'                           →  ✅ '${user.co2Saved.toStringAsFixed(0)} g'
❌ 12.5  (objectif kg)               →  ✅ user.weeklyGoalKg
❌ 0.75  (progress bar)              →  ✅ user.weeklyProgress
❌ '2.4 kg CO₂'                     →  ✅ '${(user.co2Saved/1000).toStringAsFixed(1)} kg CO₂'
❌ '0.3 arbres'                      →  ✅ '${(user.co2Saved/8000).toStringAsFixed(2)} arbres'
❌ '40 L'                            →  ✅ '${(user.co2Saved*0.05).toStringAsFixed(0)} L'
❌ Liste statique 4 scans            →  ✅ recentScans (si vide → widget "Aucun scan encore")
❌ 12847 scans communautaires        →  laisser en attendant une vraie DB
```

### Remplacements profile_screen.dart

```
❌ 'Amine Benali'                    →  ✅ user.name
❌ 'Éco-Warrior • Oujda'            →  ✅ 'Niveau ${user.level} • ${user.city}'
❌ 1240  (points)                    →  ✅ user.points
❌ 47    (scans)                     →  ✅ user.scans
❌ 8     (badges)                    →  ✅ user.badges
❌ 12    (rang)                      →  ✅ user.rank == 0 ? 'N/A' : '#${user.rank}'
❌ 'Niveau 7'                        →  ✅ 'Niveau ${user.level}'
❌ '1240/1800 XP'                    →  ✅ '${user.xp}/${user.xpMax} XP'
❌ LinearProgressIndicator(value: 0.69) → ✅ LinearProgressIndicator(value: user.xp / user.xpMax)
❌ 4 badges statiques unlocked: true →  ✅ boucle : index < user.badges → unlocked, sinon locked
```

---

## 11. ÉTAPE 8 — leaderboard_screen.dart

Lire le fichier. Trouver l'entrée avec `isMe: true` ou nom hardcodé.

```dart
final user = context.watch<UserProvider>().user;

// Remplacer sur l'entrée isMe :
❌ 'Amine Benali'   →  ✅ user.name
❌ points hardcodés →  ✅ user.points
❌ scans hardcodés  →  ✅ user.scans
```

Les autres joueurs (fictifs) peuvent rester jusqu'à avoir une vraie base de données.

---

## 12. ÉTAPE 9 — badges_screen.dart

Lire le fichier. Trouver la liste des badges avec `unlocked: true/false` hardcodés.

```dart
final user = context.watch<UserProvider>().user;

// Remplacer la logique unlocked :
// ❌ unlocked: true  (hardcodé)
// ✅ unlocked: badgeIndex < user.badges
```

---

## 13. ÉTAPE 10 — challenges_screen.dart

Lire le fichier. Trouver les valeurs de progress hardcodées (0.67, 1.0, etc.)

```dart
final user = context.watch<UserProvider>().user;

// Progress défi principal basée sur les scans réels :
// ❌ 0.67  (hardcodé)
// ✅ (user.scans % 10) / 10.0   (ex: défi "scanner 10 objets")

// Timer : si le timestamp est hardcodé, remplacer par :
// DateTime.now().add(const Duration(hours: 8))  
// jusqu'à avoir un vrai système de défis
```

---

## 14. ÉTAPE 11 — pubspec.yaml

Lire `pubspec.yaml`. Ajouter uniquement les dépendances absentes :

```yaml
dependencies:
  # Ajouter si absent :
  provider: ^6.1.2
  http: ^1.2.0
  tflite_flutter: ^0.10.4
  image: ^4.1.7
  shared_preferences: ^2.2.3

flutter:
  assets:
    # Ajouter si absent :
    - assets/models/model.tflite
```

---

## 15. Ordre d'exécution STRICT pour Claude Code

```
1.  Lire tous les fichiers cibles (ÉTAPE 0) — OBLIGATOIRE
2.  Créer/adapter lib/models/user_model.dart
3.  Créer/adapter lib/models/scan_result_model.dart
4.  Créer/adapter lib/services/api_service.dart
5.  Créer/adapter lib/services/tflite_service.dart
6.  Créer/adapter lib/services/storage_service.dart
7.  Créer/adapter lib/providers/user_provider.dart
8.  Modifier lib/main.dart → ajouter UserProvider au MultiProvider
9.  Modifier lib/screens/chat/ → connecter à ApiService.chat()
10. Modifier lib/screens/scan/ → connecter à TFLite + ApiService.scanImage()
11. Modifier lib/screens/home/ → remplacer valeurs hardcodées
12. Modifier lib/screens/profile/ → remplacer valeurs hardcodées
13. Modifier lib/screens/leaderboard/ → données utilisateur réelles
14. Modifier lib/screens/badges/ → unlocked dynamique
15. Modifier lib/screens/challenges/ → progress dynamique
16. Mettre à jour pubspec.yaml
17. Lancer : flutter pub get
```

---

## 16. Lancer le backend avant les tests

```bash
# Dans le dossier Backend/
cd Backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Tester que le chatbot répond :
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Comment recycler le plastique ?"}'
```

**⚠️ Vérifier que `.env` existe** (copier depuis `.env.example` et remplir `GOOGLE_API_KEY`).

---

## 17. Tester sur vrai appareil

Trouver l'IP locale du PC sur le WiFi :
```bash
# Windows
ipconfig  →  chercher "Adresse IPv4" ex: 192.168.1.45

# Mac/Linux
ifconfig  →  chercher inet ex: 192.168.1.45
```

Modifier dans `api_service.dart` :
```dart
static const String baseUrl = 'http://192.168.1.45:8000';
```

Téléphone et PC doivent être sur le **même réseau WiFi**.

