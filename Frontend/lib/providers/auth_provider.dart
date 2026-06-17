import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'user_provider.dart';
import 'scan_history_provider.dart';
import 'locale_provider.dart';
import '../services/n8n_service.dart';
import '../services/storage_service.dart';

// ── Raccourcis ────────────────────────────────────────────────────────────────
final _auth        = FirebaseAuth.instance;
final _db          = FirebaseFirestore.instance;
final _googleSignIn = GoogleSignIn(forceCodeForRefreshToken: true);

// ── Modèle utilisateur ────────────────────────────────────────────────────────
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String city;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.city,
    this.photoUrl,
  });

  factory AppUser.fromFirebase(User fbUser, {String city = ''}) => AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ??
            (fbUser.email?.split('@').first ?? 'Utilisateur'),
        city: city,
        photoUrl: fbUser.photoURL,
      );
}

// ── Statuts et états ──────────────────────────────────────────────────────────
enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final AppUser? user;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    AppUser? user,
  }) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage,
        user: user ?? this.user,
      );
}

class RegisterState {
  final int step;
  final AuthStatus status;
  final String? errorMessage;

  const RegisterState({
    this.step = 0,
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  RegisterState copyWith({
    int? step,
    AuthStatus? status,
    String? errorMessage,
  }) =>
      RegisterState(
        step: step ?? this.step,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );
}

// ── Traduction erreurs Firebase (FR/EN/AR/ES) ─────────────────────────────────
String _translateFirebaseError(String code, String locale) {
  const msgs = <String, Map<String, String>>{
    'user-not-found': {
      'fr': 'Aucun compte avec cet email.',
      'en': 'No account found with this email.',
      'ar': 'لا يوجد حساب بهذا البريد الإلكتروني.',
      'es': 'No se encontró ninguna cuenta con este correo.',
    },
    'wrong-password': {
      'fr': 'Mot de passe incorrect.',
      'en': 'Incorrect password.',
      'ar': 'كلمة المرور غير صحيحة.',
      'es': 'Contraseña incorrecta.',
    },
    'invalid-credential': {
      'fr': 'Email ou mot de passe incorrect.',
      'en': 'Invalid email or password.',
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'es': 'Email o contraseña incorrectos.',
    },
    'email-already-in-use': {
      'fr': 'Cette adresse email est déjà associée à un compte. Connectez-vous ou utilisez une autre adresse.',
      'en': 'This email is already in use. Sign in or use a different address.',
      'ar': 'هذا البريد مرتبط بحساب آخر. سجّل الدخول أو استخدم بريدًا آخر.',
      'es': 'Este correo ya está en uso. Inicia sesión o usa otro correo.',
    },
    'weak-password': {
      'fr': 'Mot de passe trop faible (min. 6 caractères).',
      'en': 'Password too weak (min. 6 characters).',
      'ar': 'كلمة المرور ضعيفة جدًا (6 أحرف على الأقل).',
      'es': 'Contraseña demasiado débil (mín. 6 caracteres).',
    },
    'network-request-failed': {
      'fr': 'Vérifiez votre connexion internet.',
      'en': 'Check your internet connection.',
      'ar': 'تحقق من اتصالك بالإنترنت.',
      'es': 'Verifica tu conexión a internet.',
    },
    'invalid-email': {
      'fr': 'Adresse email invalide.',
      'en': 'Invalid email address.',
      'ar': 'عنوان البريد الإلكتروني غير صالح.',
      'es': 'Dirección de correo electrónico inválida.',
    },
    'too-many-requests': {
      'fr': 'Trop de tentatives. Réessayez plus tard.',
      'en': 'Too many attempts. Try again later.',
      'ar': 'محاولات كثيرة جدًا. حاول مجددًا لاحقًا.',
      'es': 'Demasiados intentos. Inténtalo más tarde.',
    },
    'account-exists-with-different-credential': {
      'fr': 'Un compte existe déjà avec cette adresse email. Connectez-vous avec votre mot de passe.',
      'en': 'An account already exists with this email. Sign in with your password.',
      'ar': 'يوجد حساب آخر بهذا البريد. سجّل الدخول بكلمة المرور.',
      'es': 'Ya existe una cuenta con este correo. Inicia sesión con tu contraseña.',
    },
  };
  const fallback = <String, String>{
    'fr': 'Une erreur est survenue. Réessayez.',
    'en': 'An error occurred. Please try again.',
    'ar': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
    'es': 'Ocurrió un error. Inténtalo de nuevo.',
  };
  return msgs[code]?[locale] ?? msgs[code]?['fr'] ?? fallback[locale] ?? fallback['fr']!;
}

String _genericError(String locale) {
  const m = <String, String>{
    'fr': 'Une erreur est survenue. Réessayez.',
    'en': 'An error occurred. Please try again.',
    'ar': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
    'es': 'Ocurrió un error. Inténtalo de nuevo.',
  };
  return m[locale] ?? m['fr']!;
}

String _googleError(String locale) {
  const m = <String, String>{
    'fr': 'Connexion Google échouée. Réessayez.',
    'en': 'Google sign-in failed. Please try again.',
    'ar': 'فشل تسجيل الدخول بـ Google. حاول مجددًا.',
    'es': 'Error al iniciar sesión con Google. Inténtalo de nuevo.',
  };
  return m[locale] ?? m['fr']!;
}

// ── Utilitaire : lire la ville dans Firestore ─────────────────────────────────
Future<String> _fetchCity(String uid) async {
  try {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['city'] as String?) ?? '';
  } catch (_) {
    return '';
  }
}

// ── Provider utilisateur connecté ─────────────────────────────────────────────
final currentUserProvider = StateProvider<AppUser?>((ref) => null);

// ── Stream Firebase authStateChanges (optionnel, pour écoute globale) ─────────
final authStateProvider = StreamProvider<User?>((ref) {
  return _auth.authStateChanges();
});

// ── Login Email / Mot de passe ────────────────────────────────────────────────
class LoginNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  LoginNotifier(this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;
      final city = await _fetchCity(fbUser.uid);
      // Marque la dernière connexion — sert au comptage communautaire
      _db.collection('users').doc(fbUser.uid).set(
        {'lastSeen': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      ).catchError((_) {});
      final user = AppUser.fromFirebase(fbUser, city: city);
      _ref.read(currentUserProvider.notifier).state = user;
      // Invalider le stream et le provider avant de charger le nouveau profil
      _ref.invalidate(userStatsStreamProvider);
      _ref.invalidate(userProvider);
      state = state.copyWith(status: AuthStatus.success, user: user);
      // Pont : alimenter userProvider avec le vrai profil Firebase
      await _ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: user.displayName,
        firebaseUid:  user.uid,
        firebaseCity: user.city,
      );
    } on FirebaseAuthException catch (e) {
      final lang = _ref.read(localeProvider).languageCode;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError(e.code, lang),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Login error: $e');
      final lang = _ref.read(localeProvider).languageCode;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _genericError(lang),
      );
    }
  }

  void reset() => state = const AuthState();
}

final loginProvider = StateNotifierProvider<LoginNotifier, AuthState>(
  (ref) => LoginNotifier(ref),
);

// ── Inscription ───────────────────────────────────────────────────────────────
class RegisterNotifier extends StateNotifier<RegisterState> {
  final Ref _ref;
  RegisterNotifier(this._ref) : super(const RegisterState());

  void nextStep() {
    if (state.step < 2) state = state.copyWith(step: state.step + 1);
  }

  void prevStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String city,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // 1. Créer le compte
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;

      // 2. Mettre à jour le nom d'affichage
      await fbUser.updateDisplayName('$firstName $lastName');

      // 3. Sauvegarder le profil dans Firestore
      await _db.collection('users').doc(fbUser.uid).set({
        'uid':         fbUser.uid,
        'email':       email.trim(),
        'firstName':   firstName,
        'lastName':    lastName,
        'displayName': '$firstName $lastName',
        'city':        city,
        'photoUrl':    '',
        'createdAt':   FieldValue.serverTimestamp(),
        'ecoPoints':   0,
        'scansCount':  0,
        'badges':      [],
      });
      // 4. Incrémenter le compteur global d'utilisateurs
      _db.collection('community_totals').doc('stats').set(
        {'userCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      ).catchError((_) {});

      final user = AppUser(
        uid:         fbUser.uid,
        email:       email.trim(),
        displayName: '$firstName $lastName',
        city:        city,
      );
      _ref.read(currentUserProvider.notifier).state = user;
      // Invalider le stream et le provider avant de charger le nouveau profil
      _ref.invalidate(userStatsStreamProvider);
      _ref.invalidate(userProvider);
      state = state.copyWith(status: AuthStatus.success);
      // Envoyer l'email de vérification
      try { await fbUser.sendEmailVerification(); } catch (_) {}
      // Déclencher le workflow d'accueil n8n
      N8nService.bienvenue(
        userId: fbUser.uid,
        nom:    '$firstName $lastName',
        email:  email.trim(),
      ).catchError((_) {});
      // Pont : alimenter userProvider avec le vrai profil Firebase
      await _ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: user.displayName,
        firebaseUid:  user.uid,
        firebaseCity: user.city,
      );
    } on FirebaseAuthException catch (e) {
      final lang = _ref.read(localeProvider).languageCode;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError(e.code, lang),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Register error: $e');
      final lang = _ref.read(localeProvider).languageCode;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _genericError(lang),
      );
    }
  }

  void reset() => state = const RegisterState();
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(ref),
);

// ── Google Sign-In ────────────────────────────────────────────────────────────
class GoogleSignInNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  GoogleSignInNotifier(this._ref) : super(const AuthState());

  Future<void> signIn() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // 1. Pop-up sélection compte Google
      await _googleSignIn.signOut(); // efface le compte mémorisé
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // L'utilisateur a annulé
        state = const AuthState();
        return;
      }

      // 2. Récupérer les tokens Google
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      // 3. Connexion Firebase avec le credential Google
      final result = await _auth.signInWithCredential(credential);
      final fbUser = result.user!;

      // 4. Créer le document Firestore si premier login
      final userRef = _db.collection('users').doc(fbUser.uid);
      final docSnap = await userRef.get();
      String city = '';

      if (!docSnap.exists) {
        final nameParts = (fbUser.displayName ?? '').split(' ');
        await userRef.set({
          'uid':         fbUser.uid,
          'email':       fbUser.email ?? '',
          'firstName':   nameParts.isNotEmpty ? nameParts.first : '',
          'lastName':    nameParts.length > 1 ? nameParts.last : '',
          'displayName': fbUser.displayName ?? '',
          'city':        '',
          'photoUrl':    fbUser.photoURL ?? '',
          'createdAt':   FieldValue.serverTimestamp(),
          'lastSeen':    FieldValue.serverTimestamp(),
          'ecoPoints':   0,
          'scansCount':  0,
          'badges':      [],
        });
        // Incrémenter le compteur global d'utilisateurs (identique à l'inscription email)
        _db.collection('community_totals').doc('stats').set(
          {'userCount': FieldValue.increment(1)},
          SetOptions(merge: true),
        ).catchError((_) {});
        N8nService.bienvenue(
          userId: fbUser.uid,
          nom:    fbUser.displayName ?? '',
          email:  fbUser.email ?? '',
        ).catchError((_) {});
      } else {
        city = (docSnap.data()?['city'] as String?) ?? '';
        final existingName = ((docSnap.data()?['displayName'] as String?) ?? '').trim();
        final updateData = <String, dynamic>{'lastSeen': FieldValue.serverTimestamp()};
        // Si le doc n'a pas de displayName, le compléter avec le nom du compte Google
        if (existingName.isEmpty && (fbUser.displayName?.trim().isNotEmpty == true)) {
          updateData['displayName'] = fbUser.displayName!.trim();
        }
        userRef.update(updateData).catchError((_) {});
      }

      final user = AppUser.fromFirebase(fbUser, city: city);
      _ref.read(currentUserProvider.notifier).state = user;
      // Invalider le stream et le provider avant de charger le nouveau profil
      _ref.invalidate(userStatsStreamProvider);
      _ref.invalidate(userProvider);
      state = state.copyWith(status: AuthStatus.success, user: user);
      // Pont : alimenter userProvider avec le vrai profil Firebase
      await _ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: user.displayName,
        firebaseUid:  user.uid,
        firebaseCity: user.city,
      );
    } on FirebaseAuthException catch (e) {
      final lang = _ref.read(localeProvider).languageCode;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError(e.code, lang),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Google Sign-In error: $e');
      final lang = _ref.read(localeProvider).languageCode;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _googleError(lang),
      );
    }
  }

  void reset() => state = const AuthState();
}

final googleSignInProvider =
    StateNotifierProvider<GoogleSignInNotifier, AuthState>(
  (ref) => GoogleSignInNotifier(ref),
);

// ── Déconnexion ───────────────────────────────────────────────────────────────
Future<void> signOut(Ref ref) async {
  await StorageService.reset();
  await _googleSignIn.signOut();
  await _auth.signOut();
  ref.invalidate(userStatsStreamProvider);
  ref.invalidate(userProvider);
  ref.invalidate(scanHistoryProvider);
  ref.invalidate(scanHistoryStreamProvider);
  ref.read(currentUserProvider.notifier).state = null;
}

Future<void> signOutUser(WidgetRef ref) async {
  await StorageService.reset();
  ref.read(userProvider.notifier).reset();
  await _googleSignIn.signOut();
  await _auth.signOut();
  ref.invalidate(userStatsStreamProvider);
  ref.invalidate(userProvider);
  ref.invalidate(scanHistoryProvider);
  ref.invalidate(scanHistoryStreamProvider);
  ref.read(currentUserProvider.notifier).state = null;
}

// ── Connectivité ──────────────────────────────────────────────────────────────
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
  );
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
    data: (result) => result == ConnectivityResult.none,
    orElse: () => false,
  );
});
