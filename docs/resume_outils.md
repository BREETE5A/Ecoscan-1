# Récapitulatif — Tous les outils EcoScan
## Généré automatiquement — 2026-06-03

---

## Flutter / Frontend (pubspec.yaml + pubspec.lock)

| Outil | Version (yaml) | Version (lock) | Rôle | Source |
|-------|---------------|---------------|------|--------|
| flutter | SDK | SDK | Framework mobile cross-platform | https://flutter.dev |
| flutter_riverpod | ^2.6.1 | Non verrouillé | State management global | https://pub.dev/packages/flutter_riverpod |
| go_router | ^14.6.2 | Non verrouillé | Navigation déclarative + routes protégées | https://pub.dev/packages/go_router |
| flutter_animate | ^4.5.2 | Non verrouillé | Animations UI fluides | https://pub.dev/packages/flutter_animate |
| fl_chart | ^0.70.0 | Non verrouillé | Graphiques (barres, camembert) stats | https://pub.dev/packages/fl_chart |
| shimmer | ^3.0.0 | Non verrouillé | Squelettes de chargement | https://pub.dev/packages/shimmer |
| confetti | ^0.7.0 | Non verrouillé | Animation confettis (quiz, récompenses) | https://pub.dev/packages/confetti |
| connectivity_plus | ^6.1.3 | Non verrouillé | Détection état réseau / mode offline | https://pub.dev/packages/connectivity_plus |
| share_plus | ^10.1.2 | Non verrouillé | Partage score / stats | https://pub.dev/packages/share_plus |
| shared_preferences | ^2.3.3 | Non verrouillé | Stockage local (points, scans, historique) | https://pub.dev/packages/shared_preferences |
| path_provider | ^2.1.4 | Non verrouillé | Accès chemins système de fichiers | https://pub.dev/packages/path_provider |
| camera | ^0.11.0+2 | 0.11.4 | Caméra live pour scanner | https://pub.dev/packages/camera |
| image_picker | ^1.1.2 | Non verrouillé | Sélection image galerie | https://pub.dev/packages/image_picker |
| flutter_map | ^7.0.2 | Non verrouillé | Carte OpenStreetMap interactive | https://pub.dev/packages/flutter_map |
| latlong2 | ^0.9.1 | Non verrouillé | Coordonnées GPS LatLng pour flutter_map | https://pub.dev/packages/latlong2 |
| geolocator | ^13.0.2 | Non verrouillé | Géolocalisation GPS | https://pub.dev/packages/geolocator |
| firebase_core | ^3.6.0 | Non verrouillé | Initialisation Firebase SDK | https://firebase.flutter.dev |
| firebase_auth | ^5.3.1 | Non verrouillé | Auth Email + Google Sign-In | https://firebase.flutter.dev/docs/auth/overview |
| google_sign_in | ^6.2.1 | Non verrouillé | Connexion compte Google | https://pub.dev/packages/google_sign_in |
| cloud_firestore | ^5.4.3 | Non verrouillé | Base de données NoSQL temps réel | https://firebase.flutter.dev/docs/firestore/overview |
| url_launcher | ^6.3.1 | Non verrouillé | Ouverture liens externes | https://pub.dev/packages/url_launcher |
| tflite_flutter | ^0.12.1 | Non verrouillé | Inférence TFLite locale (EfficientNetB0) | https://pub.dev/packages/tflite_flutter |
| image | ^4.8.0 | Non verrouillé | Décodage/redimensionnement images | https://pub.dev/packages/image |
| dio | ^5.8.0 | Non verrouillé | Client HTTP avancé | https://pub.dev/packages/dio |
| mobile_scanner | ^6.0.5 | Non verrouillé | Scanner code-barres/QR | https://pub.dev/packages/mobile_scanner |
| firebase_messaging | ^15.2.10 | Non verrouillé | Notifications push FCM | https://firebase.flutter.dev/docs/messaging/overview |
| flutter_local_notifications | ^17.2.4 | Non verrouillé | Notifications locales planifiées | https://pub.dev/packages/flutter_local_notifications |
| timezone | ^0.9.4 | Non verrouillé | Fuseaux horaires (Africa/Casablanca) | https://pub.dev/packages/timezone |
| intl | ^0.20.1 | Non verrouillé | Internationalisation, formatage | https://pub.dev/packages/intl |
| cupertino_icons | ^1.0.8 | Non verrouillé | Icônes style iOS | https://pub.dev/packages/cupertino_icons |
| google_fonts | ^6.2.1 | Non verrouillé | Police Poppins | https://pub.dev/packages/google_fonts |
| flutter_localizations | SDK | SDK | Localisation Flutter (GlobalMaterial/Widgets/Cupertino delegates) | https://api.flutter.dev/flutter/flutter_localizations |

**Dev dependencies :**

| Outil | Version | Rôle | Source |
|-------|---------|------|--------|
| flutter_lints | ^6.0.0 | Règles linting Flutter | https://pub.dev/packages/flutter_lints |
| flutter_launcher_icons | ^0.14.3 | Génération icônes Android/iOS adaptatives | https://pub.dev/packages/flutter_launcher_icons |
| flutter_test | SDK | Tests unitaires Flutter | https://api.flutter.dev/flutter/flutter_test |

---

## Python / Backend Chatbot (requirements.txt)

| Outil | Version | Rôle | Source |
|-------|---------|------|--------|
| fastapi | Non verrouillé | Framework API REST asynchrone | https://fastapi.tiangolo.com |
| uvicorn[standard] | Non verrouillé | Serveur ASGI production | https://www.uvicorn.org |
| python-dotenv | Non verrouillé | Chargement variables d'environnement | https://pypi.org/project/python-dotenv |
| langchain | Non verrouillé | Framework orchestration LLM | https://docs.langchain.com |
| langchain-community | Non verrouillé | Intégrations communautaires | https://docs.langchain.com |
| langchain-core | Non verrouillé | Primitives LangChain (prompts, chains) | https://docs.langchain.com |
| langchain-chroma | Non verrouillé | Intégration ChromaDB ↔ LangChain | https://python.langchain.com/docs/integrations/vectorstores/chroma |
| langchain-google-genai | Non verrouillé | Intégration Gemini ↔ LangChain | https://ai.google.dev/docs |
| langchain-huggingface | Non verrouillé | Embeddings HuggingFace ↔ LangChain | https://huggingface.co |
| chromadb | Non verrouillé | Base de données vectorielle locale | https://docs.trychroma.com |
| sentence-transformers | Non verrouillé | Modèle embeddings `all-MiniLM-L6-v2` | https://www.sbert.net |
| torch | Non verrouillé | PyTorch (backend sentence-transformers) | https://pytorch.org |
| pydantic | Non verrouillé | Validation données (ChatRequest/Response) | https://docs.pydantic.dev |

---

## Python / Backend Scan API (requirements.txt)

| Outil | Version | Rôle | Source |
|-------|---------|------|--------|
| fastapi | Non verrouillé | Framework API REST | https://fastapi.tiangolo.com |
| uvicorn[standard] | Non verrouillé | Serveur ASGI | https://www.uvicorn.org |
| python-multipart | Non verrouillé | Upload multipart (images) | https://pypi.org/project/python-multipart |
| ultralytics | Non verrouillé | YOLOv8 inference (modèle local) | https://docs.ultralytics.com |
| huggingface_hub | Non verrouillé | Téléchargement modèle HuggingFace | https://huggingface.co/docs/huggingface_hub |
| Pillow | Non verrouillé | Traitement images (PIL.Image) | https://pillow.readthedocs.io |
| numpy | Non verrouillé | Calculs numériques | https://numpy.org |
| requests | Non verrouillé | Appels API Roboflow | https://requests.readthedocs.io |

---

## Services Cloud

| Service | Rôle dans EcoScan | Tier | Lien |
|---------|------------------|------|------|
| Firebase Auth | Authentification Email + Google Sign-In, 2FA, vérification email | Spark (gratuit) | https://firebase.google.com/docs/auth |
| Firebase Firestore | Profils users, points, scans, défis, récompenses, marketplace, notifications | Spark (gratuit) | https://firebase.google.com/docs/firestore |
| Firebase FCM | Tokens push, notifications serveur → app | Gratuit | https://firebase.google.com/docs/cloud-messaging |
| Render.com (Chatbot) | Hébergement FastAPI chatbot (`ecoscan-chatbot.onrender.com`) | Free (cold start ~60s) | https://render.com |
| Render.com (Scan API) | Hébergement FastAPI scan YOLOv8 (`ecoscan-model-online.onrender.com`) | Free (cold start ~60s) | https://render.com |
| OpenWeatherMap | Qualité air AQI (Air Pollution API) + Météo (Weather API) — Maroc | Free (1000 req/j) | https://openweathermap.org/api |
| OpenFoodFacts | Données produits alimentaires (Nutri-Score, Eco-Score, packaging) | Open data (gratuit) | https://openfoodfacts.github.io/openfoodfacts-server/api/ |
| Roboflow | YOLOv8 hosted inference (`yolov8-trash-detections-kgnug`) | Free (1000 credits/mois) | https://roboflow.com |
| Google Gemini API | LLM chatbot EcoBot (gemini-2.5-flash, temperature=0.3) | Free (15 req/min) | https://ai.google.dev |
| Cloudinary | Upload + hébergement images annonces Marketplace | Free (10 GB) | https://cloudinary.com |
| OpenStreetMap | Tuiles carte interactive (flutter_map) | Open data (gratuit) | https://www.openstreetmap.org |
| HuggingFace Hub | Modèle YOLOv8 fallback local (`turhancan97/yolov8-segment-trash-detection`) | Free | https://huggingface.co |
| GitHub | Versionnement code source | Free | https://github.com/BREETE5A/Ecoscan |

---

## IA & Modèles

| Outil/Modèle | Rôle | Format | Lien |
|--------------|------|--------|------|
| EfficientNetB0 (TFLite) | Classification locale déchets (8 classes) | `.tflite` float32, input 224×224 | https://www.tensorflow.org/api_docs/python/tf/keras/applications/EfficientNetB0 |
| `ecoscan_model_final.tflite` | Modèle embarqué dans l'app Flutter | TFLite, 8 classes | assets/models/ |
| YOLOv8m-seg (HuggingFace) | Détection objets fallback (44 classes TACO) | `.pt` PyTorch | https://huggingface.co/turhancan97/yolov8-segment-trash-detection |
| YOLOv8 Roboflow | Détection objets principale (TACO classes) | Hosted inference | https://universe.roboflow.com/detection-u0m2d/yolov8-trash-detections-kgnug |
| Gemini 2.5 Flash | LLM chatbot EcoBot (réponses RAG) | API Google | https://ai.google.dev/gemini-api/docs/models |
| all-MiniLM-L6-v2 | Embeddings textuels pour ChromaDB | SentenceTransformers | https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2 |
| ChromaDB | Vector store persistant (120+ documents) | Local SQLite + HNSW | https://docs.trychroma.com |

---

## Datasets

| Dataset | Rôle | Lien |
|---------|------|------|
| TACO (Trash Annotations in Context) | Dataset 60 classes déchets réels (base de turhancan97) | http://tacodataset.org |
| Dataset personnalisé EcoScan | 8 classes (cardboard, electronique, metal, organique, paper, plastique, trash, verre) — entraîné sur Google Colab | Google Colab |
| OpenFoodFacts | Base de données produits alimentaires (Nutri-Score, Eco-Score, packaging) — utilisée à la volée | https://fr.openfoodfacts.org |
| Knowledge base EcoScan (ChromaDB) | 120+ documents (navigation app, contacts opérateurs, guide tri, lois marocaines, impacts env.) — créés manuellement dans `ingest_guide.py` | Local |

---

## Outils de développement

| Outil | Version | Rôle | Lien |
|-------|---------|------|------|
| Flutter | SDK ^3.11.5 | Framework mobile | https://flutter.dev |
| Dart | SDK ^3.11.5 | Langage de programmation | https://dart.dev |
| Python | 3.13 (cpython) | Backend | https://python.python.org |
| FlutterFire CLI | — | Configuration Firebase multi-plateformes | https://firebase.flutter.dev/docs/cli |
| Google Colab | — | Entraînement modèle EfficientNetB0 | https://colab.research.google.com |
| Claude Sonnet 4.6 | — | Assistant IA développement | https://anthropic.com |
| VSCode | — | IDE principal | https://code.visualstudio.com |
| Git | — | Versionnement | https://git-scm.com |
| GitHub | — | Hébergement repo | https://github.com/BREETE5A/Ecoscan |

---

## Résumé chiffré

| Catégorie | Nombre |
|-----------|--------|
| Packages Flutter (directs) | 30 |
| Packages Python chatbot | 13 |
| Packages Python scan API | 8 |
| Écrans Flutter | 37 |
| Providers Riverpod | 19 |
| Services Flutter | 11 |
| Endpoints API | 7 |
| Services cloud externes | 15 |
| Classes TFLite | 8 |
| Classes YOLOv8 | 44 |
| Documents ChromaDB | 120+ |
| Langues supportées | 4 (FR/EN/AR/ES) |
| Commits git | 28 |
| Fichiers Dart | 88 |
| Fichiers Python | 6 |
