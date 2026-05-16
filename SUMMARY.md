# EcoScan — Résumé technique de l'implémentation

## Fichiers créés / modifiés

| Fichier | Rôle |
|---|---|
| `lib/providers/auth_provider.dart` | Providers Riverpod (login, register, connectivité) |
| `lib/widgets/custom_text_field.dart` | Champ texte avec shake, bordure erreur animée, message slide-down |
| `lib/widgets/loading_overlay.dart` | Overlay feuilles orbitales + texte rotatif + barre verte |
| `lib/widgets/no_connection_overlay.dart` | Overlay hors-ligne avec antenne WiFi animée et toast reconnexion |
| `lib/screens/auth/login_screen.dart` | Page de connexion — réécriture complète |
| `lib/screens/auth/register_screen.dart` | Page d'inscription — réécriture complète (3 étapes) |

## Animations implémentées

### login_screen.dart
- **Fade-in + slide séquentiel** : logo → slogan → carte → boutons, délai 150 ms par élément (`flutter_animate`)
- **`_AnimatedLogo`** : `Hero` tag `ecoscan_logo`, anneau rotatif en `RotationTransition` (3 s/cycle), scale elasticOut à l'entrée
- **`_LoadingButton`** : `AnimatedContainer` (gradient vert), `_OrbitingLeaves` — 2 feuilles `Icons.eco_rounded` tournant en orbite via trigonométrie (`AnimationController.repeat`)
- **Shake formulaire** : `TweenSequence` 5 oscillations dans `_FormCard` déclenché sur erreur de validation ou erreur Firebase
- **`_WavePainter`** : vague SVG double couche en bas d'écran (`CustomPainter`, `quadraticBezierTo`)
- **`_AnimatedDivider`** : séparateur "ou continuer avec" fade-in
- **`_GoogleButton`** : logo Google dessiné en `CustomPainter` (4 arcs colorés)

### register_screen.dart
- **`_StepIndicator`** : 3 cercles `AnimatedContainer` (taille, couleur, ombre) + barres connectrices colorées selon progression, checkmark sur étape validée
- **Transition entre étapes** : `SlideTransition` + `FadeTransition` via `_stepEnterCtrl` (slide 0.1→0 horizontal)
- **Avatar initiales** : `AnimatedContainer` gradient vert, mis à jour en temps réel pendant la frappe, scale elasticOut sur changement
- **`_PasswordStrength`** : 4 barres `AnimatedContainer` (couleur rouge→orange→jaune→vert selon score 1‒4)
- **Checkmark confirmation mdp** : `AnimatedSwitcher` (fade 250 ms) quand les deux champs correspondent
- **Dropdown ville** : `AnimatedSize` (expand/collapse 250 ms) pour la liste de suggestions
- **`_TermsCheckbox`** : `InkWell` ripple + `AnimatedContainer` (remplissage vert, checkmark)
- **Confetti** : `ConfettiController` (2.5 s, 40 particules, couleurs vertes) au succès de l'inscription
- **`_WelcomeBanner`** : scale elasticOut + fadeIn overlay blanc semi-transparent

### custom_text_field.dart
- **Shake horizontal** : `TweenSequence` 5 oscillations amorties, `AnimationController` déclenché via `didUpdateWidget`
- **Bordure rouge** : `ColorTween` transparent→`AppColors.danger` en 300 ms
- **Icône erreur** : `ScaleTransition` avec `Curves.elasticOut`
- **Message erreur slide-down** : translate Y -8→0 + fade via `AnimationController`

### loading_overlay.dart
- **Feuilles orbitales** : 3 `Icons.eco_rounded` en orbite avec délai de phase `i * 2π/3`, `RotationTransition` individuel
- **Texte rotatif** : `FadeTransition` + timer 1.5 s cyclique (3 messages)
- **`AnimatedSwitcher`** : affichage/masquage de l'overlay en 300 ms

### no_connection_overlay.dart
- **`SlideTransition`** : panneau monte depuis `Offset(0, 1)` → `Offset.zero` quand hors-ligne
- **`_WifiPainter`** : 3 arcs semi-circulaires avec opacité cyclique (`AnimationController.repeat`) simulant les ondes WiFi qui s'estompent
- **Pulse bouton Réessayer** : `ScaleTransition` 1.0↔1.06, 1 s répété
- **Toast "Connexion rétablie"** : `FadeTransition` vert, auto-disparition après 2 s

## Packages utilisés

| Package | Pourquoi |
|---|---|
| `flutter_riverpod ^2.6.1` | Gestion d'état sans setState, providers typés (`StateNotifier`, `StreamProvider`) |
| `flutter_animate ^4.5.2` | API déclarative pour fade/slide/scale séquentiel — moins verbeux que `AnimationController` brut |
| `confetti ^0.7.0` | Explosion de confettis verts au succès de l'inscription |
| `connectivity_plus ^6.1.3` | Stream `onConnectivityChanged` pour détecter hors-ligne en temps réel |
| `go_router ^14.6.2` | Navigation déclarative ; `GoRouter.of(context)` capturé avant les gaps async |

## Choix techniques justifiés

| Choix | Justification |
|---|---|
| **`StateNotifier` plutôt qu'`AsyncNotifier`** | L'état login/register contient plusieurs champs (status + errorMessage + user) ; `AsyncNotifier` est plus adapté aux états purement async sans data complémentaire |
| **Mock auth sans Firebase** | Firebase n'est pas dans `pubspec.yaml` ; l'architecture `LoginNotifier.login()` est identique à un appel `FirebaseAuth.signInWithEmailAndPassword()` — le remplacement se fait en 3 lignes |
| **`CustomPainter` pour la vague** | Pas de dépendance SVG externe ; la vague double couche est légère et responsive |
| **`TweenSequence` pour le shake** | 5 oscillations amorties (10 → -10 → 8 → -8 → 0) plus naturelles qu'un simple sinus |
| **Avatar à initiales** | Pas besoin de `image_picker` pour un MVP ; l'avatar se met à jour en temps réel pendant la frappe grâce à `TextEditingController.addListener` |
| **`AnimatedSize` pour le dropdown ville** | Plus simple que `OverlayEntry` pour une liste courte (≤ 5 suggestions) |
| **`GoRouter.of(context)` capturé avant `Future.delayed`** | Évite l'utilisation de `context` à travers un gap async (lint `use_build_context_synchronously`) |

## Ce qui reste à faire

### Backend & Auth
- [ ] Ajouter `firebase_auth`, `google_sign_in` dans `pubspec.yaml`
- [ ] Remplacer `_mockLogin` / `_mockRegister` dans `auth_provider.dart` par les appels Firebase réels
- [ ] Implémenter `Google Sign-In` dans `_GoogleButton.onTap`
- [ ] Ajouter la réinitialisation de mot de passe (écran dédié)
- [ ] Persistance de session : lire `FirebaseAuth.instance.currentUser` au démarrage

### Internationalisation
- [ ] Déplacer tous les textes en dur vers `lib/l10n/app_strings.dart`
- [ ] Ajouter les clés AR/EN pour les nouveaux écrans
- [ ] Gérer la direction RTL pour l'arabe dans les champs et le stepper

### Tests
- [ ] Tests unitaires des `StateNotifier` (login, register) avec `ProviderContainer`
- [ ] Tests widget de `CustomTextField` (shake, erreur, validation)
- [ ] Tests d'intégration du flux complet login → home

### UX & polish
- [ ] `local_auth` (biométrie) pour la reconnexion rapide
- [ ] `lottie` pour remplacer les `CustomPainter` par des animations Lottie
- [ ] Upload photo de profil (remplacement de l'avatar à initiales)
- [ ] `flutter_secure_storage` pour stocker le token de session
