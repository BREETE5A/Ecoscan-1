import 'package:flutter/material.dart';
import 'legal_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LegalHeader(
              emoji: '🔒',
              title: 'Politique de Confidentialité',
              subtitle: 'Dernière mise à jour : Mai 2026',
            ),
            LegalSection(
              title: '1. Introduction',
              content:
                'EcoScan est une application mobile développée dans le cadre d\'un projet de fin d\'études (PFE) à la Faculté des Sciences et Techniques de Mohammedia, Université Hassan II de Casablanca.\n\n'
                'Nous accordons une grande importance à la protection de vos données personnelles.',
            ),
            LegalSection(
              title: '2. Données collectées',
              content:
                '• Prénom, nom et adresse email\n'
                '• Ville de résidence\n'
                '• Photo de profil (optionnelle)\n'
                '• Numéro de téléphone (si 2FA activé)\n'
                '• Historique des déchets scannés\n'
                '• Localisation (avec votre autorisation uniquement)\n\n'
                'Nous ne collectons pas vos données bancaires et ne vendons jamais vos données à des tiers.',
            ),
            LegalSection(
              title: '3. Utilisation des données',
              content:
                'Vos données sont utilisées pour :\n'
                '• Personnaliser votre expérience\n'
                '• Calculer votre impact environnemental\n'
                '• Sécuriser votre compte\n'
                '• Vous envoyer des notifications utiles',
            ),
            LegalSection(
              title: '4. Partage des données',
              content:
                'Vos données peuvent être partagées avec :\n'
                '• Firebase (Google) : hébergement et authentification\n'
                '• Google Maps : affichage des éco-points\n'
                '• Gemini API : traitement anonymisé des questions EcoBot\n\n'
                'Ces services sont soumis aux politiques de Google.',
            ),
            LegalSection(
              title: '5. Sécurité',
              content:
                '• Données stockées sur Firebase (Google Cloud)\n'
                '• Transmission chiffrée via HTTPS/TLS\n'
                '• Mots de passe hachés, jamais stockés en clair\n'
                '• Authentification 2FA disponible',
            ),
            LegalSection(
              title: '6. Vos droits',
              content:
                'Vous pouvez à tout moment :\n'
                '• Accéder à vos données\n'
                '• Modifier vos informations (Paramètres)\n'
                '• Supprimer votre compte (Paramètres → Supprimer mon compte)\n'
                '• Désactiver la localisation (Paramètres du téléphone)\n\n'
                'Contact : ecoscan.maroc@gmail.com',
            ),
            LegalSection(
              title: '7. Données des mineurs',
              content:
                'EcoScan est destiné aux utilisateurs de 13 ans et plus. '
                'Nous ne collectons pas sciemment de données sur des enfants de moins de 13 ans.',
            ),
            LegalSection(
              title: '8. Contact',
              content:
                'EcoScan Maroc\n'
                'Faculté des Sciences et Techniques de Mohammedia\n'
                'Université Hassan II de Casablanca\n'
                'Email : ecoscan.maroc@gmail.com',
            ),
          ],
        ),
      ),
    );
  }
}
