import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'EcoScan'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcomeBack;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre assistant recyclage intelligent'**
  String get welcomeMessage;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyAccount;

  /// No description provided for @acceptTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les conditions d\'utilisation et la politique de confidentialité'**
  String get acceptTerms;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfUse;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get scan;

  /// No description provided for @chat.
  ///
  /// In fr, this message translates to:
  /// **'EcoBot'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @map.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get map;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un déchet'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pointez la caméra vers un déchet'**
  String get scanSubtitle;

  /// No description provided for @scanResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat du scan'**
  String get scanResult;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @binColor.
  ///
  /// In fr, this message translates to:
  /// **'Bac'**
  String get binColor;

  /// No description provided for @confidence.
  ///
  /// In fr, this message translates to:
  /// **'Précision'**
  String get confidence;

  /// No description provided for @co2Saved.
  ///
  /// In fr, this message translates to:
  /// **'CO₂ économisé'**
  String get co2Saved;

  /// No description provided for @scanAgain.
  ///
  /// In fr, this message translates to:
  /// **'Scanner à nouveau'**
  String get scanAgain;

  /// No description provided for @points.
  ///
  /// In fr, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @scans.
  ///
  /// In fr, this message translates to:
  /// **'Scans'**
  String get scans;

  /// No description provided for @badges.
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @rank.
  ///
  /// In fr, this message translates to:
  /// **'Rang'**
  String get rank;

  /// No description provided for @level.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get level;

  /// No description provided for @co2Impact.
  ///
  /// In fr, this message translates to:
  /// **'Impact CO₂'**
  String get co2Impact;

  /// No description provided for @weeklyGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif hebdomadaire'**
  String get weeklyGoal;

  /// No description provided for @recentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get recentActivity;

  /// No description provided for @noActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucun scan encore. Commencez à scanner !'**
  String get noActivity;

  /// No description provided for @communityImpact.
  ///
  /// In fr, this message translates to:
  /// **'Impact communautaire'**
  String get communityImpact;

  /// No description provided for @chatTitle.
  ///
  /// In fr, this message translates to:
  /// **'EcoBot'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Assistant recyclage'**
  String get chatSubtitle;

  /// No description provided for @chatHint.
  ///
  /// In fr, this message translates to:
  /// **'Posez votre question...'**
  String get chatHint;

  /// No description provided for @chatWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour ! Je suis EcoBot 🌿\nPosez-moi une question sur le recyclage au Maroc.'**
  String get chatWelcome;

  /// No description provided for @chatError.
  ///
  /// In fr, this message translates to:
  /// **'Désolé, je ne suis pas disponible. Vérifiez votre connexion.'**
  String get chatError;

  /// No description provided for @chatTyping.
  ///
  /// In fr, this message translates to:
  /// **'EcoBot écrit...'**
  String get chatTyping;

  /// No description provided for @newConversation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get newConversation;

  /// No description provided for @challenges.
  ///
  /// In fr, this message translates to:
  /// **'Défis'**
  String get challenges;

  /// No description provided for @dailyChallenge.
  ///
  /// In fr, this message translates to:
  /// **'Défi du jour'**
  String get dailyChallenge;

  /// No description provided for @challengeExpires.
  ///
  /// In fr, this message translates to:
  /// **'Expire dans'**
  String get challengeExpires;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Complété'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgress;

  /// No description provided for @rewards.
  ///
  /// In fr, this message translates to:
  /// **'Récompenses'**
  String get rewards;

  /// No description provided for @badges_title.
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get badges_title;

  /// No description provided for @unlocked.
  ///
  /// In fr, this message translates to:
  /// **'Débloqué'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillé'**
  String get locked;

  /// No description provided for @pointsRequired.
  ///
  /// In fr, this message translates to:
  /// **'points requis'**
  String get pointsRequired;

  /// No description provided for @leaderboard.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get leaderboard;

  /// No description provided for @myCity.
  ///
  /// In fr, this message translates to:
  /// **'Ma ville'**
  String get myCity;

  /// No description provided for @national.
  ///
  /// In fr, this message translates to:
  /// **'National'**
  String get national;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @changeEmail.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'email'**
  String get changeEmail;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @twoFactor.
  ///
  /// In fr, this message translates to:
  /// **'Authentification 2FA'**
  String get twoFactor;

  /// No description provided for @currentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get confirmNewPassword;

  /// No description provided for @didYouKnow.
  ///
  /// In fr, this message translates to:
  /// **'Le Saviez-Vous ?'**
  String get didYouKnow;

  /// No description provided for @nextIn.
  ///
  /// In fr, this message translates to:
  /// **'Prochain dans'**
  String get nextIn;

  /// No description provided for @source.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @ecoPoints.
  ///
  /// In fr, this message translates to:
  /// **'Éco-Points'**
  String get ecoPoints;

  /// No description provided for @nearby.
  ///
  /// In fr, this message translates to:
  /// **'À proximité'**
  String get nearby;

  /// No description provided for @ecoPoints_map.
  ///
  /// In fr, this message translates to:
  /// **'Éco-Points'**
  String get ecoPoints_map;

  /// No description provided for @directions.
  ///
  /// In fr, this message translates to:
  /// **'Y aller'**
  String get directions;

  /// No description provided for @distance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @plastic.
  ///
  /// In fr, this message translates to:
  /// **'Plastique'**
  String get plastic;

  /// No description provided for @glass.
  ///
  /// In fr, this message translates to:
  /// **'Verre'**
  String get glass;

  /// No description provided for @metal.
  ///
  /// In fr, this message translates to:
  /// **'Métal'**
  String get metal;

  /// No description provided for @paper.
  ///
  /// In fr, this message translates to:
  /// **'Papier'**
  String get paper;

  /// No description provided for @cardboard.
  ///
  /// In fr, this message translates to:
  /// **'Carton'**
  String get cardboard;

  /// No description provided for @organic.
  ///
  /// In fr, this message translates to:
  /// **'Organique'**
  String get organic;

  /// No description provided for @electronic.
  ///
  /// In fr, this message translates to:
  /// **'Électronique'**
  String get electronic;

  /// No description provided for @trash.
  ///
  /// In fr, this message translates to:
  /// **'Ordures'**
  String get trash;

  /// No description provided for @yellowBin.
  ///
  /// In fr, this message translates to:
  /// **'Bac jaune'**
  String get yellowBin;

  /// No description provided for @greenBin.
  ///
  /// In fr, this message translates to:
  /// **'Bac vert'**
  String get greenBin;

  /// No description provided for @blueBin.
  ///
  /// In fr, this message translates to:
  /// **'Bac bleu'**
  String get blueBin;

  /// No description provided for @blackBin.
  ///
  /// In fr, this message translates to:
  /// **'Bac noir'**
  String get blackBin;

  /// No description provided for @redBin.
  ///
  /// In fr, this message translates to:
  /// **'Bac rouge'**
  String get redBin;

  /// No description provided for @errorOccurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get tryAgain;

  /// No description provided for @noInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet'**
  String get noInternet;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get done;

  /// No description provided for @verifyEmail.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email'**
  String get verifyEmail;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un email de vérification a été envoyé à votre adresse.'**
  String get verifyEmailMessage;

  /// No description provided for @resendEmail.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer l\'email'**
  String get resendEmail;

  /// No description provided for @resendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans'**
  String get resendIn;

  /// No description provided for @emailVerified.
  ///
  /// In fr, this message translates to:
  /// **'Email vérifié !'**
  String get emailVerified;

  /// No description provided for @passwordResetSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de réinitialisation envoyé ✅'**
  String get passwordResetSent;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès ✅'**
  String get passwordChanged;

  /// No description provided for @emailChanged.
  ///
  /// In fr, this message translates to:
  /// **'Email modifié avec succès ✅'**
  String get emailChanged;

  /// No description provided for @accountDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get accountDeleted;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes vos données seront perdues.'**
  String get deleteAccountConfirm;

  /// No description provided for @onboardingTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Scannez vos déchets'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In fr, this message translates to:
  /// **'Identifiez instantanément les matériaux recyclables avec votre caméra'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Guidé par l\'IA'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In fr, this message translates to:
  /// **'EcoBot répond à toutes vos questions sur le recyclage au Maroc'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Mesurez votre impact'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre CO₂ économisé et progressez dans le classement'**
  String get onboardingDesc3;

  /// No description provided for @trees.
  ///
  /// In fr, this message translates to:
  /// **'arbres'**
  String get trees;

  /// No description provided for @liters.
  ///
  /// In fr, this message translates to:
  /// **'litres'**
  String get liters;

  /// No description provided for @kg.
  ///
  /// In fr, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @grams.
  ///
  /// In fr, this message translates to:
  /// **'g'**
  String get grams;

  /// No description provided for @hours.
  ///
  /// In fr, this message translates to:
  /// **'h'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In fr, this message translates to:
  /// **'min'**
  String get minutes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
