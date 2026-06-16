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
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'services/notification_service.dart';

Future<void> _autoSignOutIfDeleted() async {
  final fbUser = FirebaseAuth.instance.currentUser;
  if (fbUser == null) return;
  try {
    // Vérifier côté serveur si le compte Auth existe encore
    await fbUser.reload();
  } on FirebaseAuthException catch (e) {
    // Déconnecter uniquement si le compte a été supprimé ou désactivé
    if (e.code == 'user-not-found' || e.code == 'user-disabled') {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    }
    // Toute autre erreur FirebaseAuth (token expiré, etc.) → ne pas déconnecter
    return;
  } catch (_) {
    // Erreur réseau (offline) → ne pas déconnecter, laisser l'utilisateur connecté
    return;
  }
  try {
    // Forcer la vérification côté serveur uniquement (pas le cache)
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
