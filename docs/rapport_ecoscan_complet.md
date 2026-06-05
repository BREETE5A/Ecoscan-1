# Rapport Technique Complet — EcoScan
## Généré automatiquement par analyse exhaustive du codebase
### Date de génération : 2026-06-03

---

## 0. Historique du développement (reconstitué depuis git)

### Timeline des sessions

| Date | Hash | Fonctionnalité implémentée |
|------|------|---------------------------|
| 2026-05-15 | `407a3f9` | Initial commit Flutter — auth, scanner, carte, chatbot, onboarding, gamification |
| 2026-05-15 | `9413f1b` | Mise à jour du code |
| 2026-05-16 | `b38cf2a` | Ajout backend chatbot Python (FastAPI + LangChain + ChromaDB) + intégration Flutter |
| 2026-05-16 | `c267a72` | Résolution conflit de merge + intégration projet EcoScan |
| 2026-05-18 | `53e522c` | Ajout plateforme iOS, caméra réelle, carte, icône chatbot, corrections UI |
| 2026-05-18 | `44e8d17` | Fix: ajout `__init__.py`, `.env.example`, dossier `ios/` |
| 2026-05-18 | `d9abbdd` | Guide de tri complet, chatbot orange, nouvelle icône feuille |
| 2026-05-23 | `6b6cc63` | Initial commit (nouvelle organisation) |
| 2026-05-23 | `d9dbcde` | Ajout écrans Privacy Policy & Terms, liens légaux dans login/register |
| 2026-05-23 | `746daa0` | Fix: vérification `FirebaseAuth.instance.currentUser` au splash |
| 2026-05-24 | `a60665f` | i18n 4 langues (FR/EN/AR/ES) avec ARB + gen-l10n |
| 2026-05-24 | `5f77d06` | i18n 4 langues complète pour toute l'app + onboarding |
| 2026-05-24 | `31b0cc6` | Refactor: déplacement projet Flutter vers `Frontend/` |
| 2026-05-24 | `8643fc0` | i18n guide complet, support web (TFLite stub + guards kIsWeb) |
| 2026-05-24 | `3993d27` | Config Firebase iOS (appId/apiKey/iosClientId + URL scheme Google Sign-In) |
| 2026-05-24 | `97bb2ac` | Ajout firebase.json (flutterfire configure) |
| 2026-05-24 | `17cde23` | Config Firebase web + Google Sign-In clientId web |
| 2026-05-24 | `1883280` | Mise à jour google-services.json (sync flutterfire configure) |
| 2026-05-24 | `1a807ed` | Traductions arabes pour toutes les consignes du guide |
| 2026-05-24 | `8171c38` | i18n complète 4 langues — écrans guide et carte |
| 2026-05-25 | `a11f6a5` | i18n guide complet, propagation photo profil, corrections sécurité |
| 2026-05-25 | `8521886` | Fix: suppression compte Google Sign-In |
| 2026-05-25 | `f38ea0d` | Fix: email verification wait, 2FA active state, avatar propagation |
| 2026-05-25 | `c83c099` | Fix: email change flow, traduction 2FA, sécurité Google delete, nettoyage profil |
| 2026-05-29 | `ea18437` | Leaderboard Firestore, suivi challenges, rewards Firestore, streak, rang, notifications FCM, scan API online, chatbot multilingue + historique + suggestions + feedback |
| 2026-05-30 | `55370dc` | Badges env, scanner code-barres, sélecteur ville qualité air, conseils météo, quiz 25 questions |
| 2026-05-31 | `2efe97a` | Header nature animé, citation brush script, suppression stat cards |
| 2026-05-31 | `cdf0682` | Fix: données statiques → Firestore réel, icône disparue Samsung, empreinte eau persistante |

### Ce qui a été fait session par session

**Session 1 (15-16 mai 2026) — Fondations**
- Squelette Flutter complet avec authentification Firebase (Email + Google)
- Scanner de déchets avec caméra, overlay AR animé
- Carte interactive avec points de collecte statiques
- Chatbot EcoBot (UI flutter + backend FastAPI + LangChain + ChromaDB)
- Onboarding interactif
- Gamification de base (points, badges, classement)

**Session 2 (18 mai 2026) — Guide + iOS**
- Guide de tri complet avec 70+ items
- Support plateforme iOS
- Corrections UI majeures

**Session 3 (23-24 mai 2026) — i18n + Firebase**
- Internationalisation complète 4 langues (FR/EN/AR/ES) avec ARB
- RTL pour l'arabe
- Configuration Firebase multi-plateformes (Android, iOS, Web)
- Pages légales (Politique de confidentialité, CGU)

**Session 4 (25 mai 2026) — Auth avancée**
- 2FA (Authentification à 2 facteurs)
- Changement email sécurisé
- Propagation avatar profil
- Sécurité suppression compte

**Session 5 (29 mai 2026) — Backend + Gamification avancée**
- Leaderboard temps réel depuis Firestore
- Suivi challenges quotidiens/hebdomadaires
- Système récompenses (redeem points → Firestore)
- Streak de scans
- Rang calculé dynamiquement
- Notifications FCM + notifications planifiées locales
- Connexion au Scan API YOLOv8 en ligne (Render)
- Chatbot multilingue avec historique, suggestions, feedback

**Session 6 (30 mai 2026) — Environnement + Marketplace**
- Qualité de l'air (OpenWeatherMap)
- Météo avec conseils écologiques
- Empreinte eau
- Quiz écologique 25 questions 4 langues
- Scanner code-barres (OpenFoodFacts — Nutri-Score, Eco-Score)
- Marketplace complet (Cloudinary pour images)

**Session 7 (31 mai 2026) — Polissage**
- Header animé (vagues, arbres, feuilles, particules)
- Remplacement toutes les données statiques par des streams Firestore temps réel
- Fix icône launcher Samsung
- Fix empreinte eau persistence

---

## 1. Vue d'ensemble du projet

### 1.1 Description générale

EcoScan est une application mobile cross-platform (Android/iOS) développée avec Flutter, dédiée au tri sélectif intelligent des déchets au Maroc. Elle combine intelligence artificielle (vision par ordinateur + RAG LLM) et gamification pour encourager les citoyens à recycler.

**Utilisateurs cibles :** Citoyens marocains francophones, arabophones, anglophones et hispanophones.

**Objectif final :** Devenir l'assistant de tri sélectif numéro 1 au Maroc.

### 1.2 Architecture globale

```
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION FLUTTER (Frontend/)               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │
│  │  Camera   │  │ TFLite   │  │ Firebase │  │   Riverpod   │   │
│  │ Scanner   │  │ Offline  │  │ Auth +   │  │ State Mgmt   │   │
│  │(YOLOv8   │  │ EfficientN│  │ Firestore│  │              │   │
│  │ online)  │  │ B0 local) │  │  + FCM   │  │              │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┘   │
└─────────────────────────────────────────────────────────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌─────────────┐
│  Scan API    │   │  Chatbot API     │   │  Firebase   │
│  (Render)   │   │  (Render)        │   │  (Google)   │
│             │   │                  │   │             │
│ FastAPI +   │   │ FastAPI +        │   │ Auth        │
│ YOLOv8      │   │ LangChain +      │   │ Firestore   │
│ Roboflow /  │   │ ChromaDB +       │   │ FCM         │
│ HuggingFace │   │ Gemini 2.5 Flash │   │             │
└──────────────┘   └──────────────────┘   └─────────────┘
```

### 1.3 Flux de données complet

**Flux Scan photo :**
```
Caméra → Image capturée → POST /scan (Render, timeout 60s)
    → YOLOv8 Roboflow/HuggingFace → label + confiance
    → Si serveur injoignable → TFLite local (EfficientNetB0)
    → ScanResultScreen → Firestore (ecoPoints++, scansCount++, co2Saved++)
    → SharedPreferences (cache local)
```

**Flux Chatbot :**
```
Message utilisateur → enrichissement darija → POST /chat (Render, timeout 90s)
    → ChromaDB retrieval (k=6 documents) → Gemini 2.5 Flash
    → Réponse texte → nettoyage markdown → affichage UI
    → Si hors ligne → réponses locales prédéfinies
```

**Flux Scanner code-barres :**
```
mobile_scanner → EAN/UPC/QR → GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json
    → FoodProduct (nom, marque, Nutri-Score, Eco-Score, emballage) → ScanResultScreen
```

---

## 2. Frontend Flutter

### 2.1 Arborescence complète des fichiers

```
Frontend/
├── lib/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── data/
│   │   ├── challenges_data.dart
│   │   ├── did_you_know_data.dart
│   │   └── rewards_data.dart
│   ├── firebase_options.dart
│   ├── l10n/
│   │   ├── app_ar.arb
│   │   ├── app_en.arb
│   │   ├── app_es.arb
│   │   ├── app_fr.arb
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_ar.dart
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_es.dart
│   │   ├── app_localizations_fr.dart
│   │   └── app_strings.dart
│   ├── main.dart
│   ├── models/
│   │   ├── chat_message.dart
│   │   ├── listing_model.dart
│   │   ├── scan_entry.dart
│   │   ├── scan_result_model.dart
│   │   └── user_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── avatar_provider.dart
│   │   ├── challenges_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── community_stats_provider.dart
│   │   ├── environment_providers.dart
│   │   ├── locale_provider.dart
│   │   ├── marketplace_provider.dart
│   │   ├── rewards_provider.dart
│   │   ├── scan_history_provider.dart
│   │   ├── theme_provider.dart
│   │   └── user_provider.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── phone_verify_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── two_factor_screen.dart
│   │   │   └── verify_email_screen.dart
│   │   ├── badges/badges_screen.dart
│   │   ├── challenges/challenges_screen.dart
│   │   ├── chat/chat_screen.dart
│   │   ├── environment/
│   │   │   ├── air_quality_screen.dart
│   │   │   ├── quiz_screen.dart
│   │   │   ├── water_footprint_screen.dart
│   │   │   └── weather_screen.dart
│   │   ├── guide/guide_screen.dart
│   │   ├── history/history_screen.dart
│   │   ├── home/home_screen.dart
│   │   ├── language/language_screen.dart
│   │   ├── leaderboard/leaderboard_screen.dart
│   │   ├── legal/
│   │   │   ├── legal_widgets.dart
│   │   │   ├── privacy_policy_screen.dart
│   │   │   └── terms_screen.dart
│   │   ├── map/map_screen.dart
│   │   ├── marketplace/
│   │   │   ├── listing_detail_screen.dart
│   │   │   ├── marketplace_screen.dart
│   │   │   └── my_ads_screen.dart
│   │   ├── notifications/notifications_screen.dart
│   │   ├── onboarding/onboarding_screen.dart
│   │   ├── profile/
│   │   │   ├── edit_profile_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── rewards/rewards_screen.dart
│   │   ├── scan/
│   │   │   ├── barcode_scan_screen.dart
│   │   │   ├── scan_result_screen.dart
│   │   │   └── scan_screen.dart
│   │   ├── settings/
│   │   │   ├── change_email_screen.dart
│   │   │   ├── change_password_screen.dart
│   │   │   ├── language_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── theme_screen.dart
│   │   ├── splash/
│   │   │   ├── splash_screen.dart
│   │   │   └── welcome_splash_screen.dart
│   │   └── stats/stats_screen.dart
│   ├── services/
│   │   ├── air_quality_service.dart
│   │   ├── chat_service.dart
│   │   ├── classifier_service.dart
│   │   ├── classifier_service_io.dart
│   │   ├── classifier_service_stub.dart
│   │   ├── food_product_service.dart
│   │   ├── notification_service.dart
│   │   ├── rotation_service.dart
│   │   ├── scan_api_service.dart
│   │   ├── storage_service.dart
│   │   └── weather_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── custom_text_field.dart
│       ├── did_you_know_card.dart
│       ├── loading_overlay.dart
│       ├── main_scaffold.dart
│       └── no_connection_overlay.dart
└── assets/
    ├── icons/app_icon.png
    └── models/
        └── ecoscan_model_final.tflite
```

### 2.2 Tous les packages utilisés

| Package | Version (pubspec.yaml) | Version (lock) | Rôle dans l'app | Documentation |
|---------|----------------------|----------------|-----------------|---------------|
| flutter_riverpod | ^2.6.1 | Non spécifié | State management global (providers, notifiers) | https://pub.dev/packages/flutter_riverpod |
| go_router | ^14.6.2 | Non spécifié | Navigation déclarative, routes protégées | https://pub.dev/packages/go_router |
| flutter_animate | ^4.5.2 | Non spécifié | Animations fluides (fade, slide, scale) | https://pub.dev/packages/flutter_animate |
| fl_chart | ^0.70.0 | Non spécifié | Graphiques (barres, camembert) dans StatsScreen | https://pub.dev/packages/fl_chart |
| shimmer | ^3.0.0 | Non spécifié | Squelettes de chargement | https://pub.dev/packages/shimmer |
| confetti | ^0.7.0 | Non spécifié | Animation confettis (quiz réussi, reward) | https://pub.dev/packages/confetti |
| connectivity_plus | ^6.1.3 | Non spécifié | Détection état réseau, mode hors-ligne | https://pub.dev/packages/connectivity_plus |
| share_plus | ^10.1.2 | Non spécifié | Partage score/stats sur réseaux sociaux | https://pub.dev/packages/share_plus |
| shared_preferences | ^2.3.3 | Non spécifié | Stockage local (points, scans, historique) | https://pub.dev/packages/shared_preferences |
| path_provider | ^2.1.4 | Non spécifié | Chemins système de fichiers | https://pub.dev/packages/path_provider |
| camera | ^0.11.0+2 | 0.11.4 | Accès caméra en temps réel pour le scan | https://pub.dev/packages/camera |
| image_picker | ^1.1.2 | Non spécifié | Sélection image depuis galerie | https://pub.dev/packages/image_picker |
| flutter_map | ^7.0.2 | Non spécifié | Carte OpenStreetMap interactive (points de collecte) | https://pub.dev/packages/flutter_map |
| latlong2 | ^0.9.1 | Non spécifié | Coordonnées GPS (LatLng) pour flutter_map | https://pub.dev/packages/latlong2 |
| geolocator | ^13.0.2 | Non spécifié | Géolocalisation GPS (qualité air, météo) | https://pub.dev/packages/geolocator |
| firebase_core | ^3.6.0 | Non spécifié | Initialisation Firebase | https://firebase.flutter.dev |
| firebase_auth | ^5.3.1 | Non spécifié | Authentification (Email, Google) | https://firebase.flutter.dev/docs/auth/overview |
| google_sign_in | ^6.2.1 | Non spécifié | Connexion avec compte Google | https://pub.dev/packages/google_sign_in |
| cloud_firestore | ^5.4.3 | Non spécifié | Base de données NoSQL temps réel | https://firebase.flutter.dev/docs/firestore/overview |
| url_launcher | ^6.3.1 | Non spécifié | Ouverture liens (navigateur, téléphone) | https://pub.dev/packages/url_launcher |
| tflite_flutter | ^0.12.1 | Non spécifié | Inférence TFLite locale (EfficientNetB0) | https://pub.dev/packages/tflite_flutter |
| image | ^4.8.0 | Non spécifié | Redimensionnement/décodage image pour TFLite | https://pub.dev/packages/image |
| dio | ^5.8.0 | Non spécifié | Client HTTP (appels Chatbot API, Scan API, OWM, OFF) | https://pub.dev/packages/dio |
| mobile_scanner | ^6.0.5 | Non spécifié | Scanner code-barres/QR (OpenFoodFacts) | https://pub.dev/packages/mobile_scanner |
| firebase_messaging | ^15.2.10 | Non spécifié | Notifications push FCM | https://firebase.flutter.dev/docs/messaging/overview |
| flutter_local_notifications | ^17.2.4 | Non spécifié | Notifications locales planifiées | https://pub.dev/packages/flutter_local_notifications |
| timezone | ^0.9.4 | Non spécifié | Gestion fuseaux horaires (Maroc: Africa/Casablanca) | https://pub.dev/packages/timezone |
| intl | ^0.20.1 | Non spécifié | Internationalisation, formatage dates/nombres | https://pub.dev/packages/intl |
| cupertino_icons | ^1.0.8 | Non spécifié | Icônes style iOS | https://pub.dev/packages/cupertino_icons |
| google_fonts | ^6.2.1 | Non spécifié | Police Poppins (typographie principale) | https://pub.dev/packages/google_fonts |

**Dev dependencies :**

| Package | Version | Rôle |
|---------|---------|------|
| flutter_lints | ^6.0.0 | Règles de linting Flutter | 
| flutter_launcher_icons | ^0.14.3 | Génération icônes app Android/iOS | 

### 2.3 Écrans implémentés (37 écrans)

| Écran | Fichier | Route GoRouter | Fonctionnalités |
|-------|---------|---------------|-----------------|
| SplashScreen | screens/splash/splash_screen.dart | /splash | Vérification auth Firebase, redirection |
| WelcomeSplashScreen | screens/splash/welcome_splash_screen.dart | /welcome | Écran de bienvenue animé |
| LanguageScreen | screens/language/language_screen.dart | /language | Sélection langue initiale (FR/EN/AR/ES) |
| OnboardingScreen | screens/onboarding/onboarding_screen.dart | /onboarding | 3 slides d'introduction (i18n) |
| LoginScreen | screens/auth/login_screen.dart | /login | Email+mdp, Google Sign-In, lien inscription |
| RegisterScreen | screens/auth/register_screen.dart | /register | Inscription 3 étapes (prénom, ville, email+mdp) |
| VerifyEmailScreen | screens/auth/verify_email_screen.dart | /verify-email | Vérification email envoyé |
| TwoFactorScreen | screens/auth/two_factor_screen.dart | /two-factor-setup | Configuration 2FA |
| PhoneVerifyScreen | screens/auth/phone_verify_screen.dart | Non routé | Vérification téléphone (non terminé) |
| PrivacyPolicyScreen | screens/legal/privacy_policy_screen.dart | /privacy-policy | Politique de confidentialité i18n |
| TermsScreen | screens/legal/terms_screen.dart | /terms | Conditions générales i18n |
| HomeScreen | screens/home/home_screen.dart | /home | Header animé, stats communautaires Firestore, challenges progress, badges env |
| ScanScreen | screens/scan/scan_screen.dart | /scan | Caméra live, overlay AR animé, TFLite + fallback YOLOv8 online |
| ScanResultScreen | screens/scan/scan_result_screen.dart | /scan/result | Résultat scan, instructions tri, points gagnés |
| BarcodeScanScreen | screens/scan/barcode_scan_screen.dart | /barcode | Scanner EAN/UPC, Nutri-Score A→E, Eco-Score A→E, recyclabilité emballage |
| MapScreen | screens/map/map_screen.dart | /map | Carte OpenStreetMap, 50+ points de collecte statiques, filtres par catégorie, géolocalisation |
| ChatScreen | screens/chat/chat_screen.dart | /chat | EcoBot RAG (6 langues, historique, suggestions, feedback) |
| ProfileScreen | screens/profile/profile_screen.dart | /profile | Stats utilisateur, badges, menu accès fonctionnalités |
| EditProfileScreen | screens/profile/edit_profile_screen.dart | /profile/edit | Modification nom, ville, photo profil |
| StatsScreen | screens/stats/stats_screen.dart | /stats | Graphiques scans semaine/mois/année, ratios par catégorie (données Firestore réelles) |
| BadgesScreen | screens/badges/badges_screen.dart | /badges | Collection de badges avec critères débloquage |
| GuideScreen | screens/guide/guide_screen.dart | /guide | Guide tri 70+ items, recherche, filtres catégorie, i18n |
| NotificationsScreen | screens/notifications/notifications_screen.dart | /notifications | Liste notifications FCM (Firestore) |
| SettingsScreen | screens/settings/settings_screen.dart | /settings | Langue, thème, sécurité, suppression compte |
| ChangeEmailScreen | screens/settings/change_email_screen.dart | /change-email | Changement email (ré-authentification requise) |
| ChangePasswordScreen | screens/settings/change_password_screen.dart | /change-password | Changement mot de passe sécurisé |
| ThemeScreen | screens/settings/theme_screen.dart | Non routé | Sélection thème clair/sombre/système |
| LeaderboardScreen | screens/leaderboard/leaderboard_screen.dart | /leaderboard | Top 5 temps réel Firestore, position utilisateur |
| ChallengesScreen | screens/challenges/challenges_screen.dart | /challenges | 20 défis (scan + eco), progression temps réel Firestore |
| HistoryScreen | screens/history/history_screen.dart | /history | Historique 50 derniers scans (SharedPreferences) |
| RewardsScreen | screens/rewards/rewards_screen.dart | /rewards | Catalogue récompenses, échange points, Firestore |
| AirQualityScreen | screens/environment/air_quality_screen.dart | /air-quality | AQI par ville marocaine (GPS + sélecteur 12 villes), polluants PM2.5/PM10/NO₂/O₃/CO/SO₂/NH₃ |
| WaterFootprintScreen | screens/environment/water_footprint_screen.dart | /water-footprint | Calculateur empreinte eau (sliders persistants SharedPreferences) |
| WeatherScreen | screens/environment/weather_screen.dart | /weather | Météo GPS + conseils écologiques par condition |
| QuizScreen | screens/environment/quiz_screen.dart | /quiz | 25 questions recyclage 4 langues, score, explications |
| MarketplaceScreen | screens/marketplace/marketplace_screen.dart | /marketplace | Annonces vente/don/échange objets recyclés, stream Firestore |
| ListingDetailScreen | screens/marketplace/listing_detail_screen.dart | /marketplace/:id | Détail annonce, avis/notes, système review |
| MyAdsScreen | screens/marketplace/my_ads_screen.dart | /marketplace/my | Gestion annonces de l'utilisateur |

### 2.4 Gestion d'état — Riverpod

| Provider | Fichier | Type | Rôle |
|----------|---------|------|------|
| `loginProvider` | auth_provider.dart | StateNotifierProvider\<LoginNotifier, AuthState\> | Connexion email/mdp |
| `registerProvider` | auth_provider.dart | StateNotifierProvider\<RegisterNotifier, RegisterState\> | Inscription 3 étapes |
| `googleSignInProvider` | auth_provider.dart | StateNotifierProvider\<GoogleSignInNotifier, AuthState\> | Connexion Google |
| `currentUserProvider` | auth_provider.dart | StateProvider\<AppUser?\> | Utilisateur connecté en mémoire |
| `authStateProvider` | auth_provider.dart | StreamProvider\<User?\> | Stream authStateChanges Firebase |
| `connectivityProvider` | auth_provider.dart | StreamProvider\<ConnectivityResult\> | État réseau |
| `isOfflineProvider` | auth_provider.dart | Provider\<bool\> | Dérivé de connectivityProvider |
| `userProvider` | user_provider.dart | StateNotifierProvider\<UserNotifier, UserModel\> | Profil complet (Firestore + SharedPreferences) |
| `challengesProvider` | challenges_provider.dart | StateNotifierProvider\<ChallengesNotifier, ChallengeProgress\> | Suivi défis quotidiens/hebdo (Firestore) |
| `rewardsProvider` | rewards_provider.dart | StateNotifierProvider\<RewardsNotifier, Set\<String\>\> | Récompenses échangées (Firestore) |
| `scanHistoryProvider` | scan_history_provider.dart | StateNotifierProvider\<ScanHistoryNotifier, List\<ScanEntry\>\> | Historique session |
| `currentScanProvider` | scan_history_provider.dart | StateProvider\<ScanEntry?\> | Dernier scan pour ScanResultScreen |
| `communityStatsProvider` | community_stats_provider.dart | StreamProvider\<CommunityStats\> | Stats communautaires temps réel (top 100 users Firestore) |
| `marketplaceProvider` | marketplace_provider.dart | StreamProvider\<List\<ListingModel\>\> | Annonces actives temps réel |
| `reviewsProvider` | marketplace_provider.dart | StreamProvider.family\<List\<ReviewModel\>, String\> | Avis par annonce |
| `marketplaceActionsProvider` | marketplace_provider.dart | Provider\<MarketplaceActions\> | CRUD annonces + reviews |
| `themeProvider` | theme_provider.dart | StateNotifierProvider | Thème clair/sombre/système |
| `localeProvider` | locale_provider.dart | StateNotifierProvider\<LocaleNotifier, Locale\> | Langue actuelle |
| `avatarProvider` | avatar_provider.dart | StateProvider | URL avatar profil |

### 2.5 Authentification Firebase

**Méthodes implémentées :**
- Email + Mot de passe (createUserWithEmailAndPassword + signInWithEmailAndPassword)
- Google Sign-In (via `google_sign_in` + Firebase credential)
- Vérification email (sendEmailVerification + polling vérification)
- 2FA (configuration basique, TwoFactorScreen)

**Fichiers concernés :**
- `Frontend/lib/providers/auth_provider.dart` — LoginNotifier, RegisterNotifier, GoogleSignInNotifier
- `Frontend/lib/screens/auth/login_screen.dart`, `register_screen.dart`, `verify_email_screen.dart`, `two_factor_screen.dart`

**Firestore document utilisateur :**
```json
{
  "uid": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "displayName": "string",
  "city": "string",
  "photoUrl": "string",
  "createdAt": "Timestamp",
  "ecoPoints": 0,
  "scansCount": 0,
  "co2Saved": 0.0,
  "streak": 0,
  "lastScanAt": "Timestamp",
  "fcmToken": "string",
  "tokenUpdatedAt": "Timestamp",
  "badges": [],
  "redeemedRewards": []
}
```

**Source :** https://firebase.flutter.dev/docs/auth/overview

### 2.6 Vision par ordinateur — TFLite

**Modèle :** `ecoscan_model_final.tflite` (Frontend/assets/models/)

**Architecture :** EfficientNetB0 (entraîné via Google Colab, converti en TFLite float32)

**8 classes détectées (ordre alphabétique Keras) :**
| Index | Classe | Nom affiché | Bac | Points | CO₂ économisé |
|-------|--------|-------------|-----|--------|---------------|
| 0 | cardboard | Carton recyclable | Bleu | 10 | 30g |
| 1 | electronique | Appareil DEEE | Éco-point | 40 | 0g |
| 2 | metal | Métal recyclable | Jaune | 20 | 80g |
| 3 | organique | Déchet organique | Marron | 8 | 20g |
| 4 | paper | Papier recyclable | Bleu | 10 | 30g |
| 5 | plastique | Plastique recyclable | Jaune | 15 | 45g |
| 6 | trash | Déchet non recyclable | Noir | 5 | 0g |
| 7 | verre | Verre recyclable | Vert | 25 | 55g |

**Pipeline complet :**
1. `camera` capture image → `File` temporaire
2. `image.dart` décode + redimensionne en 224×224 pixels
3. Normalisation pixels : Float32 → [0.0, 1.0] (modèle contient couches Rescaling internes)
4. `Interpreter.run()` → vecteur de 8 scores
5. Application softmax si sum ≠ 1.0
6. Seuil confiance : ≥ 0.45 → label retourné, sinon → "unknown"
7. Fallback : si confiance < 0.45, essai avec le serveur YOLOv8

**Fichier source :** `Frontend/lib/services/classifier_service_io.dart`

**Source :** https://pub.dev/packages/tflite_flutter

### 2.7 Intégration caméra

**Packages :**
- `camera: ^0.11.0+2` — Preview live + capture photo
- `image_picker: ^1.1.2` — Sélection depuis galerie
- `mobile_scanner: ^6.0.5` — Scanner code-barres/QR (BarcodeScanScreen uniquement)

**Flux de capture (ScanScreen) :**
1. `CameraController` initialisé avec résolution medium
2. Preview live avec overlay AR (scan line animée + pulse + ripple)
3. Bouton capture → `_cameraCtrl.takePicture()` → `File`
4. Envoi vers `ScanApiService.classify()` (YOLOv8 online, timeout 60s)
5. Si null retourné → `ClassifierService.classify()` (TFLite local)
6. Résultat → navigation vers `/scan/result`

**Source :** https://pub.dev/packages/camera

### 2.8 Chatbot EcoBot — Interface Flutter

**Écran :** `Frontend/lib/screens/chat/chat_screen.dart`

**Fonctionnalités :**
- Interface chat complète avec bulles utilisateur/bot
- Historique de conversation (6 derniers messages envoyés au backend)
- Suggestions de questions rapides (3 suggestions aléatoires)
- Bouton feedback (👍 / 👎 par message)
- Indicateur online/offline
- Nettoyage markdown automatique (**, *, ##, __)

**Appel API :** `POST https://ecoscan-chatbot.onrender.com/chat`
- Timeout connexion : 90 secondes (cold start Render)
- Body : `{"message": "...", "history": [{"role": "user|bot", "content": "..."}]}`
- Réponse : `{"response": "..."}`

**Mode hors-ligne :** `ChatService._offlineFallback()` — réponses prédéfinies pour 25+ catégories (tri, navigation app, contacts opérateurs, lois) en 6 langues

**Source :** https://pub.dev/packages/dio

### 2.9 Carte interactive

**Package :** `flutter_map: ^7.0.2` avec tuiles OpenStreetMap (pas Google Maps)

**URL tuiles :** `https://tile.openstreetmap.org/{z}/{x}/{y}.png`

**Points de collecte statiques (50+ points) :**
- Geocycle : 4 plateformes industrielles (Bouskoura, El Gara, Tanger, Oum Azza)
- Eco Zalagh : 2 bases logistiques (Casablanca, Tanger)
- SMRR : 4 dépôts (Casablanca, Tanger, Agadir, Marrakech)
- Bacs ECOVAL : Marjane, Carrefour, Cosmos Electro (8+ villes)
- Colonnes vertes, bornes textiles, collecteurs piles, déchetteries
- Sources : geocycle.com/fr/maroc, ecozalagh.com, smrr.ma, pndm.environnement.gov.ma, marjane.ma

**Filtres :** Tous / Plastique / Verre / Papier / Compost / Piles / Électronique / Textile / Huiles / Métal

**Géolocalisation :** Position GPS utilisateur affichée sur la carte + comptage points proches

**Source :** https://pub.dev/packages/flutter_map

### 2.10 Notifications Push — FCM

**Fichier :** `Frontend/lib/services/notification_service.dart`

**Types de notifications configurées :**
| Type | ID | Déclencheur | Contenu |
|------|-----|-------------|---------|
| Rappel journalier | 10 | 8h00 chaque jour (Africa/Casablanca) | "Triez vos déchets aujourd'hui !" |
| Défis hebdomadaires | 11 | Lundi 8h00 | "De nouveaux défis vous attendent !" |
| Récompense disponible | Dynamique | Points suffisants | "Vous pouvez débloquer [récompense]" |
| Notifications FCM push | Automatique | Depuis Firebase Console | Titre + Body depuis Firestore users/{uid}/notifications |

**FCM Token :** Sauvegardé dans Firestore `users/{uid}.fcmToken` à chaque refresh

**Source :** https://firebase.google.com/docs/cloud-messaging

### 2.11 Stockage local — SharedPreferences

**Fichier :** `Frontend/lib/services/storage_service.dart`

**Clés configurées :**
| Clé SharedPreferences | Type | Contenu |
|-----------------------|------|---------|
| `user_scans_count` | int | Nombre total de scans |
| `user_points` | int | Points éco accumulés |
| `user_co2_grams` | double | CO₂ économisé en grammes |
| `scan_history` | String (JSON) | 50 derniers scans (liste JSON) |
| `aq_city_key` | String | Ville sélectionnée pour qualité air |
| `aq_city_ts` | int | Timestamp dernière détection ville |
| `weather_city` | String | Ville pour météo |
| `weather_city_ts` | int | Timestamp dernière ville météo |

**Synchronisation :** SharedPreferences ↔ Firestore à chaque scan (réconciliation bidirectionnelle)

**Source :** https://pub.dev/packages/shared_preferences

### 2.12 Internationalisation

**Langues supportées :** Français (fr), Anglais (en), Arabe (ar, RTL), Espagnol (es)

**Fichiers ARB :**
- `Frontend/lib/l10n/app_fr.arb`
- `Frontend/lib/l10n/app_en.arb`
- `Frontend/lib/l10n/app_ar.arb`
- `Frontend/lib/l10n/app_es.arb`

**Classes générées :** `app_localizations.dart`, `app_localizations_ar.dart`, `app_localizations_en.dart`, `app_localizations_es.dart`, `app_localizations_fr.dart`

**Classe AppStrings :** `Frontend/lib/l10n/app_strings.dart` — Système parallèle de traductions inline (pas ARB) pour les chaînes non encore migrées. Méthode `_t(fr, en, ar, es)`.

**Support RTL :** `Directionality(textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr)` dans `MaterialApp.router`

**Source :** https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization

### 2.13 Design System

**Typographie :** Poppins (via `google_fonts: ^6.2.1`)

**Material Design 3 :** `useMaterial3: true`

**Palette de couleurs :**
| Couleur | Hex | Usage |
|---------|-----|-------|
| primary | `#27AE60` | Couleur principale verte |
| primaryLight | `#2ECC71` | Variante claire |
| primaryDark | `#1E8449` | Variante foncée |
| teal | `#1ABC9C` | Secondaire, gradient |
| mint | `#A8E6CF` | Accents doux |
| accent | `#F39C12` | Orange accent, avertissements |
| accentLight | `#F9CA24` | Or, badges |
| purple | `#9B59B6` | Défi Ambassadeur Vert |
| danger | `#E74C3C` | Erreurs, dangereux |
| info | `#3498DB` | Info |
| background | `#F0FDF4` | Fond light |
| surface | `#FFFFFF` | Cartes light |
| textPrimary | `#1A2E1A` | Texte light |
| textSecondary | `#546E7A` | Labels, hints |
| darkBackground | `#0D1F12` | Fond dark |
| darkSurface | `#1A3320` | Surface dark |
| darkCard | `#1F3D26` | Cartes dark |

**Catégories matériaux :**
| Catégorie | Hex |
|-----------|-----|
| plastic | `#3498DB` |
| paper | `#9B59B6` |
| organic | `#795548` |
| glass | `#00BCD4` |
| metal | `#607D8B` |
| electronics | `#FF5722` |

---

## 3. Backend FastAPI

### 3.1 Arborescence complète

**Backend Chatbot (ChatBot_ameliorer-1/ChatBot_ameliorer/Backend/) :**
```
Backend/
├── app/
│   ├── main.py          — FastAPI app, CORS, routes /root, /health, /chat
│   ├── rag_chatbot.py   — EcoScanRAGChatbot class (LangChain + ChromaDB + Gemini)
│   └── schemas.py       — Pydantic: MessageHistory, ChatRequest, ChatResponse
├── chroma_ecoscan/
│   └── 47aa7961-1999-437a-9b53-69bb66a66524/
│       ├── data_level0.bin
│       ├── header.bin
│       ├── length.bin
│       └── link_lists.bin
│   └── chroma.sqlite3
├── ingest_guide.py      — Script d'ingestion données dans ChromaDB (120+ documents)
├── requirements.txt     — Dépendances Python
├── Dockerfile           — Container Docker
└── start.sh             — Script démarrage Uvicorn
```

**Backend Scan API (ecoscan-scan-api/) :**
```
ecoscan-scan-api/
├── app/
│   ├── __init__.py
│   ├── main.py          — FastAPI app, /root, /health, /classes, /scan
│   └── model.py         — YOLOv8 Roboflow + HuggingFace inference
├── Dockerfile
├── requirements.txt
└── start.sh
```

### 3.2 Toutes les dépendances Python

**Chatbot Backend (requirements.txt) :**

| Package | Rôle | Source |
|---------|------|--------|
| fastapi | Framework API REST | https://fastapi.tiangolo.com |
| uvicorn[standard] | Serveur ASGI | https://www.uvicorn.org |
| python-dotenv | Variables d'environnement (.env) | https://pypi.org/project/python-dotenv |
| langchain | Framework orchestration LLM | https://docs.langchain.com |
| langchain-community | Intégrations communautaires LangChain | https://docs.langchain.com |
| langchain-core | Composants core LangChain | https://docs.langchain.com |
| langchain-chroma | Intégration ChromaDB pour LangChain | https://python.langchain.com/docs/integrations/vectorstores/chroma |
| langchain-google-genai | Intégration Gemini pour LangChain | https://ai.google.dev/docs |
| langchain-huggingface | Embeddings HuggingFace pour LangChain | https://huggingface.co |
| chromadb | Base de données vectorielle | https://docs.trychroma.com |
| sentence-transformers | Modèle d'embeddings (all-MiniLM-L6-v2) | https://www.sbert.net |
| torch | PyTorch (requis par sentence-transformers) | https://pytorch.org |
| pydantic | Validation des données (schémas) | https://docs.pydantic.dev |

**Scan API Backend (requirements.txt) :**

| Package | Rôle | Source |
|---------|------|--------|
| fastapi | Framework API REST | https://fastapi.tiangolo.com |
| uvicorn[standard] | Serveur ASGI | https://www.uvicorn.org |
| python-multipart | Upload fichiers multipart (images) | https://pypi.org/project/python-multipart |
| ultralytics | YOLOv8 inference | https://docs.ultralytics.com |
| huggingface_hub | Téléchargement modèle HuggingFace | https://huggingface.co/docs/huggingface_hub |
| Pillow | Traitement d'images (PIL) | https://pillow.readthedocs.io |
| numpy | Calculs numériques | https://numpy.org |
| requests | Requêtes HTTP (Roboflow API) | https://requests.readthedocs.io |

### 3.3 Tous les endpoints implémentés

**Chatbot API (https://ecoscan-chatbot.onrender.com) :**

| Méthode | URL | Description | Paramètres | Réponse |
|---------|-----|-------------|------------|---------|
| GET | `/` | Info API | — | `{"message": "EcoScan Chatbot API fonctionne correctement."}` |
| GET | `/health` | Health check | — | `{"status": "healthy"}` |
| POST | `/chat` | Envoi message au chatbot RAG | Body: `ChatRequest {message: str, history: List[MessageHistory]}` | `ChatResponse {response: str}` |

**Scan API (https://ecoscan-model-online.onrender.com) :**

| Méthode | URL | Description | Paramètres | Réponse |
|---------|-----|-------------|------------|---------|
| GET | `/` | Info API | — | `{"message": "EcoScan Scan API fonctionne correctement."}` |
| GET | `/health` | Health check + mode (roboflow/local) | — | `{"status": "healthy", "mode": "roboflow\|local"}` |
| GET | `/classes` | Liste des classes du modèle | — | `{"classes": {...}}` |
| POST | `/scan` | Détection déchet dans image | `file: UploadFile (image/*)` | `{detections, count, top_label, top_confidence, source}` |

**Format réponse /scan :**
```json
{
  "detections": [
    {"label": "plastique", "confidence": 0.847, "box": {"x1": 10, "y1": 20, "x2": 100, "y2": 200}}
  ],
  "count": 1,
  "top_label": "plastique",
  "top_confidence": 0.847,
  "source": "roboflow"
}
```

### 3.4 Modèles de données (Pydantic)

```python
class MessageHistory(BaseModel):
    role: str      # "user" ou "bot"
    content: str

class ChatRequest(BaseModel):
    message: str
    history: Optional[List[MessageHistory]] = []

class ChatResponse(BaseModel):
    response: str
```

### 3.5 YOLOv8 — Inférence serveur

**Source principale (Roboflow hosted) :**
- Modèle ID : `yolov8-trash-detections-kgnug`
- Version : 1
- API URL : `https://detect.roboflow.com/yolov8-trash-detections-kgnug/1`
- Seuil confiance : 0.25
- Source : https://roboflow.com

**Fallback local (HuggingFace) :**
- Repo : `turhancan97/yolov8-segment-trash-detection`
- Fichier : `yolov8m-seg.pt` (YOLO medium segmentation)
- Chargé via `hf_hub_download()`
- 44 classes TACO (voir tableau 3.5.1)

**44 classes exactes (turhancan97/yolov8-segment-trash-detection) :**

| Classe YOLOv8 | Catégorie EcoScan |
|---------------|------------------|
| Glass bottle, Glass jar, Broken glass | verre |
| Clear/Other plastic bottle, Plastic bag & wrapper, Plastic straw, Plastic utensils, Other plastic, Cup, Foam cup/container, Polystyrene food container, Six pack rings, Spread tub, Squeezable tube, Tupperware, Lid, Styrofoam piece, Carded blister pack | plastique |
| Drink can, Aluminium foil, Aluminium blister pack, Metal bottle cap, Metal lid, Pop tab, Scrap metal, Food Can | metal |
| Corrugated/Drink/Egg/Meal/Other carton | cardboard |
| Paper bag, Paper cup, Magazine paper, Normal paper, Tissue | paper |
| Food waste | organique |
| Battery | electronique |
| Cigarette, Rope & strings, Unlabeled litter | trash |

**Pipeline :**
1. Réception image multipart
2. Si `ROBOFLOW_API_KEY` défini → appel Roboflow API (timeout 30s)
3. Sinon → inférence locale YOLOv8 (conf=0.25)
4. Traduction labels → catégories EcoScan (table 60+ entrées dans `scan_api_service.dart`)
5. Seuil client Flutter : confiance ≥ 0.40 côté Flutter

**Source :** https://docs.ultralytics.com

### 3.6 Agent conversationnel EcoBot — Architecture RAG

**Framework :** LangChain — https://docs.langchain.com

**LLM :** Gemini 2.5 Flash (`gemini-2.5-flash`) — temperature=0.3

**Vector Store :** ChromaDB (`./chroma_ecoscan`, collection `ecoscan_knowledge`)

**Embeddings :** `sentence-transformers/all-MiniLM-L6-v2` (normalize_embeddings=True)

**Retriever :** `k=6` documents récupérés par requête

**Pipeline LangChain :**
```python
chain = {
    "context": (lambda x: x["question"]) | retriever | _format_documents,
    "question": lambda x: x["question"],
    "history": lambda x: x["history"],
} | prompt | llm | StrOutputParser()
```

**Enrichissement darija :** 70+ termes darija marocaine → équivalents français/arabes pour améliorer la recherche vectorielle

**Capacités linguistiques :** Détection automatique + réponse en : Français, Anglais, Arabe MSA, Espagnol, Darija marocaine, Franco-arabe

**Historique de conversation :** 6 derniers messages inclus dans le contexte

**Contenu ChromaDB (120+ documents ingérés via `ingest_guide.py`) :**
| Catégorie | Nombre | Contenu |
|-----------|--------|---------|
| NAV_DOCS | 18 | Navigation de l'app (toutes les routes) |
| OPERATOR_DOCS | 9 | Contacts opérateurs recyclage Maroc (AVERDA, ARMA, SMRR, Eco Zalagh, ECOVAL, Zéro Zbel...) |
| GUIDE_ITEMS | ~70 | Items tri détaillés (métal, verre, plastique, papier, électronique, textile, organique, dangereux) |
| BIN_DOCS | 6 | Types de bacs (jaune ECOVAL, vert, bleu/ferracha, marron, textile, DEEE) |
| LAW_DOCS | 9 | Lois marocaines (28-00, 77-15, 49-17, 99-12, DEEE, SNRVD, Paris, Bâle, économie circulaire) |
| IMPACT_DOCS | 8 | Impacts environnementaux par matériau (CO₂, temps décomposition) |

**Source LangChain :** https://docs.langchain.com
**Source Gemini :** https://ai.google.dev/docs
**Source ChromaDB :** https://docs.trychroma.com
**Source SentenceTransformers :** https://www.sbert.net

### 3.7 Authentification backend

Les backends **n'ont pas de middleware Firebase Auth** — ils sont publics (CORS `*`). La sécurité est gérée côté Flutter (GoRouter redirect) et côté Firestore (Security Rules à configurer).

### 3.8 Base de données Firestore (NoSQL)

**Collections principales :**

| Collection | Document | Sous-collections | Champs clés |
|------------|----------|-----------------|-------------|
| `users` | `{uid}` | `progress`, `scans`, `notifications` | ecoPoints, scansCount, co2Saved, streak, fcmToken, badges, redeemedRewards, lastScanAt |
| `users/{uid}/progress` | `challenges` | — | dailyScans, ecoBotUsed, guideViews, mapOpened, shared, weeklyScans, dayKey, weekKey |
| `users/{uid}/scans` | `{auto}` | — | category, binColor, confidence, co2Saved, scannedAt |
| `users/{uid}/notifications` | `{auto}` | — | title, body, data, read, createdAt |
| `marketplace` | `{listingId}` | `reviews` | title, description, type, category, price, city, phone, whatsapp, imageUrls, userId, active, reviewAvg |
| `marketplace/{id}/reviews` | `{reviewId}` | — | reviewerId, stars, comment, createdAt |

**Source :** https://firebase.flutter.dev/docs/firestore/overview

### 3.9 Cloudinary (Images Marketplace)

- Cloud name : `dfuhrnnxx`
- Upload preset : `ecoscan_marketplace`
- URL upload : `https://api.cloudinary.com/v1_1/dfuhrnnxx/image/upload`
- Dossier Cloudinary : `marketplace/`
- Points accordés : +15 pts si annonce "don", +5 pts sinon

---

## 4. Intelligence Artificielle

### 4.1 YOLOv8

**Version :** Ultralytics YOLOv8 (version exacte non spécifiée dans requirements.txt — `ultralytics` sans version)

**Mode principal :** Roboflow hosted inference (`yolov8-trash-detections-kgnug`, version 1)

**Mode fallback :** YOLOv8m-seg local depuis HuggingFace (`turhancan97/yolov8-segment-trash-detection`)

**Format final :** `.pt` (PyTorch weights) — inférence via Ultralytics Python

**Dataset :** TACO (Trash Annotations in Context) — http://tacodataset.org

**Classes :** 44 classes (voir §3.5)

**Sources :**
- Ultralytics : https://docs.ultralytics.com
- TACO Dataset : http://tacodataset.org
- Roboflow : https://roboflow.com

### 4.2 EfficientNetB0 — TFLite (Modèle local)

**Architecture :** EfficientNetB0 (fine-tuné sur dataset personnalisé)

**Fichier :** `Frontend/assets/models/ecoscan_model_final.tflite`

**Input :** 224×224×3, float32 (pixels normalisés 0.0-1.0)

**Output :** 8 scores de classification

**8 Classes :** cardboard, electronique, metal, organique, paper, plastique, trash, verre

**Preprocessing exact :**
- Décodage image → `img.decodeImage(bytes)`
- Resize : 224×224 avec interpolation linéaire
- Normalisation : `pixel.r / 255.0` (float32 path)
- Reshape : `[1, 224, 224, 3]`
- Post-processing : softmax si sum ≠ 1.0
- Seuil : 0.45

**Environnement d'entraînement :** Google Colab

**Source :** https://colab.research.google.com, https://pub.dev/packages/tflite_flutter

### 4.3 EcoBot — Pipeline RAG Complet

| Composant | Valeur | Source |
|-----------|--------|--------|
| Framework | LangChain | https://docs.langchain.com |
| LLM principal | Gemini 2.5 Flash (gemini-2.5-flash) | https://ai.google.dev/docs |
| LLM temperature | 0.3 | — |
| Vector store | ChromaDB (local, ./chroma_ecoscan) | https://docs.trychroma.com |
| Collection ChromaDB | ecoscan_knowledge | — |
| Embedding model | sentence-transformers/all-MiniLM-L6-v2 | https://www.sbert.net |
| Normalize embeddings | True | — |
| k retrieval | 6 documents | — |
| Historique | 6 derniers messages | — |
| Langues détectées | 6 (FR, EN, AR MSA, ES, Darija, Franco-arabe) | — |
| Documents ChromaDB | 120+ | ingest_guide.py |

---

## 5. Automatisation n8n

**Non trouvé dans le code** — Aucun fichier `*.json` de workflow n8n ni dossier n8n dans les répertoires du projet. Cette fonctionnalité n'est pas implémentée dans le code source actuel.

---

## 6. Tous les services et APIs externes

| Service | Usage exact | Plan/Tier | URL/Endpoint | Documentation |
|---------|-------------|-----------|--------------|---------------|
| Firebase Auth | Authentification Email + Google Sign-In | Spark (gratuit) | — | https://firebase.flutter.dev/docs/auth/overview |
| Firebase Firestore | Profils, points, scans, défis, récompenses, marketplace, notifications | Spark (gratuit) | — | https://firebase.flutter.dev/docs/firestore/overview |
| Firebase FCM | Notifications push (token stocké dans Firestore) | Gratuit | — | https://firebase.google.com/docs/cloud-messaging |
| OpenWeatherMap Air Pollution API | Qualité de l'air AQI par coordonnées GPS (12 villes maroc) | Free (1000 req/j) | `https://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lng}&appid={key}` | https://openweathermap.org/api/air-pollution |
| OpenWeatherMap Weather API | Météo actuelle par ville/GPS | Free | `https://api.openweathermap.org/data/2.5/weather?q={city},MA&appid={key}&units=metric&lang=fr` | https://openweathermap.org/current |
| OpenFoodFacts API | Nutri-Score, Eco-Score, packaging par code-barres | Open data (gratuit) | `https://world.openfoodfacts.org/api/v2/product/{barcode}.json` | https://openfoodfacts.github.io/openfoodfacts-server/api/ |
| EcoScan Chatbot API | RAG chatbot (Gemini 2.5 Flash + ChromaDB) | Self-hosted Render free | `https://ecoscan-chatbot.onrender.com` | — |
| EcoScan Scan API | Détection YOLOv8 (Roboflow + HuggingFace) | Self-hosted Render free | `https://ecoscan-model-online.onrender.com` | — |
| Roboflow Inference API | YOLOv8 hosted inference | Free (1000 credits/mois) | `https://detect.roboflow.com/yolov8-trash-detections-kgnug/1` | https://roboflow.com |
| HuggingFace Hub | Téléchargement modèle YOLOv8 (fallback) | Free | `turhancan97/yolov8-segment-trash-detection` | https://huggingface.co |
| Google Gemini API | LLM chatbot (2.5 Flash) | Free tier (15 req/min) | `https://generativelanguage.googleapis.com` | https://ai.google.dev/docs |
| SentenceTransformers | Embeddings textuels ChromaDB | Open source, local | `sentence-transformers/all-MiniLM-L6-v2` | https://www.sbert.net |
| Cloudinary | Hébergement images Marketplace | Free (10 GB) | `https://api.cloudinary.com/v1_1/dfuhrnnxx/image/upload` | https://cloudinary.com/documentation |
| OpenStreetMap | Tuiles carte interactive (flutter_map) | Open data (gratuit) | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` | https://www.openstreetmap.org |
| Render | Hébergement backends FastAPI | Free tier (cold start ~30-60s) | — | https://render.com |

---

## 7. Configuration et déploiement

### 7.1 Variables d'environnement

**Chatbot Backend (.env) :**
| Variable | Valeur par défaut | Rôle |
|----------|------------------|------|
| `GOOGLE_API_KEY` | (requis) | Clé API Gemini |
| `CHROMA_PATH` | `./chroma_ecoscan` | Chemin ChromaDB |
| `COLLECTION_NAME` | `ecoscan_knowledge` | Nom collection ChromaDB |
| `EMBEDDING_MODEL` | `sentence-transformers/all-MiniLM-L6-v2` | Modèle embeddings |
| `GEMINI_MODEL` | `gemini-2.5-flash` | Modèle LLM Gemini |

**Scan API Backend (.env) :**
| Variable | Valeur par défaut | Rôle |
|----------|------------------|------|
| `ROBOFLOW_API_KEY` | `""` (optionnel) | Clé Roboflow (si vide → modèle local) |

**Flutter (hardcodé dans les services — à externaliser) :**
| Variable | Valeur | Fichier |
|----------|--------|---------|
| `_owmKey` | `40bbb318e5d3379c017f100b4a79b9b9` | air_quality_service.dart, weather_service.dart |
| `_cloudName` | `dfuhrnnxx` | marketplace_provider.dart |
| `_uploadPreset` | `ecoscan_marketplace` | marketplace_provider.dart |
| Chatbot base URL | `https://ecoscan-chatbot.onrender.com` | api_constants.dart |
| Scan API base URL | `https://ecoscan-model-online.onrender.com` | api_constants.dart |

### 7.2 Docker

**Chatbot Backend (Dockerfile présent, contenu non lu)** — Déployé sur Render.com

**Scan API Backend (Dockerfile présent, contenu non lu)** — Déployé sur Render.com

### 7.3 Firebase

**Projet Firebase :** `ecoscan` (configuré via FlutterFire CLI)

**Plateformes configurées :**
- Android : `Frontend/android/app/google-services.json`
- iOS : `Frontend/ios/Runner/GoogleService-Info.plist`
- Web : `Frontend/web/index.html` + `Frontend/firebase.json`

**Configuration multi-plateformes :** `Frontend/lib/firebase_options.dart` (généré par FlutterFire CLI)

### 7.4 GitHub

**Repo :** https://github.com/BREETE5A/Ecoscan

**Branche principale :** `main`

---

## 8. Sécurité implémentée

### 8.1 Authentification et autorisations
- Firebase Auth JWT vérifié à chaque requête Firestore (côté SDK)
- Redirect GoRouter : toutes les routes sauf {/splash, /login, /register, /onboarding, /welcome, /privacy-policy, /terms} redirigent vers `/login` si non authentifié
- Ré-authentification requise avant changement email ou suppression compte
- Vérification email obligatoire après inscription

### 8.2 Validation des données
- Pydantic schemas côté backend (`ChatRequest`, `ChatResponse`, `MessageHistory`)
- Seuils de confiance côté client (TFLite: 0.45, YOLOv8: 0.40)
- Validation format fichier image (`content_type.startswith("image/")`) côté Scan API
- Seuil de confiance minimum côté Roboflow (0.25)

### 8.3 Sécurité côté Flutter
- `forceCodeForRefreshToken: true` pour GoogleSignIn
- `await _googleSignIn.signOut()` avant chaque Sign-In (évite account caching)
- Traduction erreurs Firebase en messages utilisateur (pas de codes techniques exposés)
- Marketplace : `if (uid == sellerId) return false` pour empêcher auto-review

### 8.4 CORS
- Backends FastAPI : `allow_origins=["*"]` (ouvert, à restreindre en production)

### 8.5 Données sensibles
- Clé OpenWeatherMap hardcodée dans le code Flutter (à externaliser via `--dart-define`)
- Cloudinary upload preset public (sécurité assurée par le preset `unsigned`)
- Les backends ne vérifient pas les tokens Firebase Auth (à ajouter en production)

---

## 9. État d'avancement réel

### Fonctionnalités complètement implémentées ✅

- Authentification Firebase (Email + Google Sign-In + vérification email + 2FA)
- Internationalisation 4 langues (FR/EN/AR/ES) avec RTL arabe
- Scanner de déchets avec caméra (TFLite local + YOLOv8 online, fallback automatique)
- Scanner code-barres OpenFoodFacts (Nutri-Score + Eco-Score + packaging)
- Chatbot EcoBot RAG (Gemini 2.5 Flash + ChromaDB, 6 langues, historique, mode offline)
- Carte interactive OpenStreetMap (50+ points statiques, géolocalisation, filtres)
- Gamification complète (points, niveaux, XP, badges, streak, rang)
- Leaderboard temps réel Firestore (top 5 + position utilisateur)
- 20 défis quotidiens/hebdomadaires (suivi Firestore, reset automatique)
- Système récompenses (échange points → Firestore)
- Qualité de l'air (OpenWeatherMap, 12 villes marocaines, 7 polluants)
- Météo avec conseils écologiques (OpenWeatherMap)
- Empreinte eau (calculateur avec sliders persistants)
- Quiz écologique 25 questions 4 langues
- Marketplace complet (Cloudinary, CRUD annonces, reviews, géolocalisation)
- Notifications FCM + notifications planifiées locales (rappel journalier 8h + hebdo lundi)
- Guide de tri 70+ items 4 langues
- Stats utilisateur avec graphiques réels Firestore
- Profil utilisateur complet (édition, photo, suppression compte)
- Navigation complete (37 écrans, GoRouter, animations fade+slide)
- Mode hors-ligne (réponses chatbot locales, connectivity_plus)
- Thème clair/sombre

### Fonctionnalités partiellement implémentées ⚠️

- Authentification téléphone (PhoneVerifyScreen présent mais route non branchée dans GoRouter)
- 2FA (écran TwoFactorScreen créé mais logique TOTP non terminée)
- Marketplace géolocalisation (champs latitude/longitude dans modèle mais non utilisés pour filtrage distance)
- Firebase Security Rules (Firestore/Storage rules non documentées dans le repo)
- Historique scans (50 max, basé SharedPreferences — pas encore migré vers Firestore complètement)

### Fonctionnalités prévues mais absentes du code ❌

- n8n (aucun workflow présent)
- Firebase Storage (utilisé via Cloudinary pour marketplace, Storage Firebase non branché)
- Notifications push depuis serveur (FCM token sauvegardé mais envoi push serveur → app non implémenté)
- Backend PostgreSQL (aucune base de données relationnelle, tout est Firestore)
- Alembic migrations (pas de SQL dans le projet)
- Authentification backend (pas de validation Firebase JWT côté FastAPI)
- Rate limiting API (pas de protection contre abus)
- Tests unitaires/d'intégration (aucun fichier test trouvé dans lib/)

---

## Statistiques du rapport

- **Fichiers Dart analysés :** 88 fichiers dans `Frontend/lib/`
- **Fichiers Python analysés :** 6 fichiers Python (2 backends)
- **Packages Flutter (directs) :** 30 packages
- **Dépendances Python (chatbot) :** 13 packages
- **Dépendances Python (scan API) :** 8 packages
- **Écrans implémentés :** 37 écrans
- **Providers Riverpod :** 19 providers
- **Services Flutter :** 11 services
- **Endpoints API :** 7 endpoints (3 chatbot + 4 scan API)
- **Documents ChromaDB :** 120+ documents (6 catégories)
- **Services/APIs externes :** 15 services
- **Commits git :** 28 commits (2026-05-15 → 2026-05-31)
- **Langues supportées :** 4 (FR, EN, AR, ES)
- **Classes TFLite :** 8 classes
- **Classes YOLOv8 :** 44 classes TACO
- **Points de collecte carte :** 50+ points statiques
- **Défis gamification :** 20 défis
- **Items guide de tri :** 70+ items
