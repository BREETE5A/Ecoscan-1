import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'services/notification_service.dart';

/// Vérifie si le compte a été supprimé côté serveur.
/// Ne fait RIEN si l'appareil est hors ligne.
Future<void> _autoSignOutIfDeleted() async {
  final fbUser = FirebaseAuth.instance.currentUser;
  if (fbUser == null) return;

  // Vérifier la connectivité avant toute requête réseau
  try {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none) || result.isEmpty) return;
  } catch (_) {
    return;
  }

  try {
    await fbUser.reload();
  } on FirebaseAuthException catch (e) {
    // Déconnecter uniquement si le compte a été supprimé ou désactivé
    if (e.code == 'user-not-found' || e.code == 'user-disabled') {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    }
    return;
  } catch (_) {
    return;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(fbUser.uid)
        .get(const GetOptions(source: Source.server));
    if (!doc.exists) {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    }
  } on FirebaseException catch (_) {
    // Offline ou erreur réseau → ne pas déconnecter
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Attendre que Firebase Auth restaure la session locale avant de continuer.
  // Sans cet await, le router peut évaluer currentUser = null (pas encore chargé)
  // et rediriger vers /login même si l'utilisateur est connecté.
  await FirebaseAuth.instance.authStateChanges().first;

  await _autoSignOutIfDeleted();

  if (!kIsWeb) {
    await NotificationService.init();
    await NotificationService.scheduleDailyReminders();
    await NotificationService.scheduleWeeklyChallengeReminder();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: EcoScanApp()));
}

class EcoScanApp extends ConsumerWidget {
  const EcoScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'EcoScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: LocaleNotifier.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      routerConfig: appRouter,
    );
  }
}
