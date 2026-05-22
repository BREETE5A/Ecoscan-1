import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'user_provider.dart';

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

// ── Traduction erreurs Firebase → Français ────────────────────────────────────
String _translateFirebaseError(String code) => switch (code) {
      'user-not-found'          => 'Aucun compte avec cet email.',
      'wrong-password'          => 'Mot de passe incorrect.',
      'invalid-credential'      => 'Email ou mot de passe incorrect.',
      'email-already-in-use'    => 'Cet email est déjà utilisé.',
      'weak-password'           => 'Mot de passe trop faible (min. 6 caractères).',
      'network-request-failed'  => 'Vérifiez votre connexion internet.',
      'invalid-email'           => 'Adresse email invalide.',
      'too-many-requests'       => 'Trop de tentatives. Réessayez plus tard.',
      'account-exists-with-different-credential' =>
          'Un compte existe déjà avec cet email.',
      _ => 'Une erreur est survenue. Réessayez.',
    };

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
      final user = AppUser.fromFirebase(fbUser, city: city);
      _ref.read(currentUserProvider.notifier).state = user;
      state = state.copyWith(status: AuthStatus.success, user: user);
      // Pont : alimenter userProvider avec le vrai profil Firebase
      await _ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: user.displayName,
        firebaseUid:  user.uid,
        firebaseCity: user.city,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('Login error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur est survenue. Réessayez.',
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

      final user = AppUser(
        uid:         fbUser.uid,
        email:       email.trim(),
        displayName: '$firstName $lastName',
        city:        city,
      );
      _ref.read(currentUserProvider.notifier).state = user;
      state = state.copyWith(status: AuthStatus.success);
      // Envoyer l'email de vérification
      try { await fbUser.sendEmailVerification(); } catch (_) {}
      // Pont : alimenter userProvider avec le vrai profil Firebase
      await _ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: user.displayName,
        firebaseUid:  user.uid,
        firebaseCity: user.city,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('Register error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur est survenue. Réessayez.',
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
          'ecoPoints':   0,
          'scansCount':  0,
          'badges':      [],
        });
      } else {
        city = (docSnap.data()?['city'] as String?) ?? '';
      }

      final user = AppUser.fromFirebase(fbUser, city: city);
      _ref.read(currentUserProvider.notifier).state = user;
      state = state.copyWith(status: AuthStatus.success, user: user);
      // Pont : alimenter userProvider avec le vrai profil Firebase
      await _ref.read(userProvider.notifier).loadFromStorage(
        firebaseName: user.displayName,
        firebaseUid:  user.uid,
        firebaseCity: user.city,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Connexion Google échouée. Réessayez.',
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
  await _googleSignIn.signOut();
  await _auth.signOut();
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
