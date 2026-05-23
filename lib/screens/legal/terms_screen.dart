import 'package:flutter/material.dart';
import 'legal_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LegalHeader(
              emoji: '📋',
              title: 'Conditions d\'Utilisation',
              subtitle: 'Dernière mise à jour : Mai 2026',
            ),
            LegalSection(
              title: '1. Acceptation',
              content:
                'En utilisant EcoScan, vous acceptez ces conditions. '
                'Si vous n\'acceptez pas, veuillez ne pas utiliser l\'application.',
            ),
            LegalSection(
              title: '2. Description du service',
              content:
                'EcoScan permet de :\n'
                '• Identifier les déchets recyclables via la caméra\n'
                '• Obtenir des conseils de tri adaptés au Maroc\n'
                '• Interagir avec EcoBot, assistant IA recyclage\n'
                '• Suivre son impact environnemental\n'
                '• Participer à des défis communautaires',
            ),
            LegalSection(
              title: '3. Création de compte',
              content:
                '• Âge minimum : 13 ans\n'
                '• Informations exactes requises\n'
                '• Un seul compte par personne\n'
                '• Vous êtes responsable de la sécurité de vos identifiants',
            ),
            LegalSection(
              title: '4. Utilisation acceptable',
              content:
                'Autorisé :\n'
                '• Usage personnel non commercial\n'
                '• Partage de vos statistiques\n\n'
                'Interdit :\n'
                '• Usage illégal ou frauduleux\n'
                '• Tentative de piratage de l\'application\n'
                '• Création de faux comptes\n'
                '• Utilisation de robots automatisés',
            ),
            LegalSection(
              title: '5. Exactitude des informations',
              content:
                'EcoScan ne garantit pas l\'exactitude à 100% des classifications. '
                'En cas de doute, vérifiez auprès de votre commune. '
                'EcoBot fournit des informations générales et ne remplace pas un conseil professionnel.',
            ),
            LegalSection(
              title: '6. Limitation de responsabilité',
              content:
                'EcoScan n\'est pas responsable de :\n'
                '• Erreurs de classification par l\'IA\n'
                '• Perte de données due à des problèmes techniques\n'
                '• Interruptions de service pour maintenance',
            ),
            LegalSection(
              title: '7. Droit applicable',
              content:
                'Ces conditions sont régies par le droit marocain. '
                'Tout litige sera soumis à la juridiction compétente de Casablanca, Maroc.',
            ),
            LegalSection(
              title: '8. Contact',
              content:
                'EcoScan Maroc\n'
                'Faculté des Sciences et Techniques de Mohammedia\n'
                'Email : ecoscan.maroc@gmail.com',
            ),
          ],
        ),
      ),
    );
  }
}
