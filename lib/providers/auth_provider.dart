// Providers d'authentification — simulation sans Firebase
// Remplacer _mockLogin/_mockRegister par les appels Firebase réels plus tard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ── Modèle utilisateur ────────────────────────────────────────────────────────
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String city;
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.city,
  });
}

// ── État de l'écran login ─────────────────────────────────────────────────────
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

  AuthState copyWith({AuthStatus? status, String? errorMessage, AppUser? user}) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage,
        user: user ?? this.user,
      );
}

// ── Messages d'erreur Firebase → FR ──────────────────────────────────────────
String _translateFirebaseError(String code) => switch (code) {
      'user-not-found'          => 'Aucun compte avec cet email.',
      'wrong-password'          => 'Mot de passe incorrect.',
      'email-already-in-use'    => 'Cet email est déjà utilisé.',
      'weak-password'           => 'Mot de passe trop faible.',
      'network-request-failed'  => 'Vérifiez votre connexion internet.',
      'invalid-email'           => 'Adresse email invalide.',
      'too-many-requests'       => 'Trop de tentatives. Réessayez plus tard.',
      _                         => 'Une erreur est survenue. Réessayez.',
    };

// ── Provider utilisateur connecté (simule authStateChanges) ──────────────────
final currentUserProvider = StateProvider<AppUser?>((ref) => null);

// ── Notifier Login ────────────────────────────────────────────────────────────
class LoginNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  LoginNotifier(this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1600));

    // Simulation : email valide → succès, sinon erreur
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError('invalid-email'),
      );
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError('wrong-password'),
      );
      return;
    }

    final user = AppUser(
      uid: 'uid_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
      city: 'Casablanca',
    );
    _ref.read(currentUserProvider.notifier).state = user;
    state = state.copyWith(status: AuthStatus.success, user: user);
  }

  void reset() => state = const AuthState();
}

final loginProvider = StateNotifierProvider<LoginNotifier, AuthState>(
  (ref) => LoginNotifier(ref),
);

// ── État stepper pour l'inscription ──────────────────────────────────────────
class RegisterState {
  final int step;          // 0, 1, 2
  final AuthStatus status;
  final String? errorMessage;
  const RegisterState({
    this.step = 0,
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  RegisterState copyWith({int? step, AuthStatus? status, String? errorMessage}) =>
      RegisterState(
        step: step ?? this.step,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );
}

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
    await Future.delayed(const Duration(milliseconds: 1800));

    if (email.contains('taken')) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateFirebaseError('email-already-in-use'),
      );
      return;
    }

    final user = AppUser(
      uid: 'uid_${email.hashCode}',
      email: email,
      displayName: '$firstName $lastName',
      city: city,
    );
    _ref.read(currentUserProvider.notifier).state = user;
    state = state.copyWith(status: AuthStatus.success);
  }

  void reset() => state = const RegisterState();
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(ref),
);

// ── Provider connectivité ─────────────────────────────────────────────────────
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
    data: (result) => result == ConnectivityResult.none,
    orElse: () => false,
  );
});
