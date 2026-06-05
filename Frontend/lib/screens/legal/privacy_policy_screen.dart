import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import 'legal_widgets.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final data = _content(lang);
    return Scaffold(
      appBar: AppBar(
        title: Text(data['appbar']!),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LegalHeader(
              emoji: '🔒',
              title: data['title']!,
              subtitle: data['subtitle']!,
            ),
            ...(data['sections'] as List<(String, String)>)
                .map((s) => LegalSection(title: s.$1, content: s.$2)),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _content(String lang) {
    switch (lang) {
      case 'en':
        return {
          'appbar': 'Privacy Policy',
          'title': 'Privacy Policy',
          'subtitle': 'Last updated: May 2026',
          'sections': <(String, String)>[
            ('1. Introduction',
              'EcoScan is a mobile application developed as part of a final year project (PFE) at the Faculty of Science and Technology of Mohammedia, Hassan II University of Casablanca.\n\n'
              'We attach great importance to the protection of your personal data.'),
            ('2. Data collected',
              '• First name, last name and email address\n'
              '• City of residence\n'
              '• Profile picture (optional)\n'
              '• Phone number (if 2FA enabled)\n'
              '• History of scanned waste\n'
              '• Location (with your permission only)\n\n'
              'We do not collect your banking details and never sell your data to third parties.'),
            ('3. Use of data',
              'Your data is used to:\n'
              '• Personalize your experience\n'
              '• Calculate your environmental impact\n'
              '• Secure your account\n'
              '• Send you useful notifications'),
            ('4. Data sharing',
              'Your data may be shared with:\n'
              '• Firebase (Google): hosting and authentication\n'
              '• Google Maps: display of eco-points\n'
              '• Gemini API: anonymized processing of EcoBot questions\n\n'
              'These services are subject to Google policies.'),
            ('5. Security',
              '• Data stored on Firebase (Google Cloud)\n'
              '• Encrypted transmission via HTTPS/TLS\n'
              '• Passwords hashed, never stored in plain text\n'
              '• 2FA authentication available'),
            ('6. Your rights',
              'You can at any time:\n'
              '• Access your data\n'
              '• Edit your information (Settings)\n'
              '• Delete your account (Settings → Delete my account)\n'
              '• Disable location (Phone settings)\n\n'
              'Contact: ecoscan.maroc@gmail.com'),
            ('7. Minors data',
              'EcoScan is intended for users aged 13 and over. '
              'We do not knowingly collect data about children under 13.'),
            ('8. Contact',
              'EcoScan Morocco\n'
              'Faculty of Science and Technology of Mohammedia\n'
              'Hassan II University of Casablanca\n'
              'Email: ecoscan.maroc@gmail.com'),
          ],
        };

      case 'ar':
        return {
          'appbar': 'سياسة الخصوصية',
          'title': 'سياسة الخصوصية',
          'subtitle': 'آخر تحديث: مايو 2026',
          'sections': <(String, String)>[
            ('1. مقدمة',
              'EcoScan هو تطبيق جوال تم تطويره في إطار مشروع التخرج (PFE) بكلية العلوم والتقنيات بالمحمدية، جامعة الحسن الثاني بالدار البيضاء.\n\n'
              'نولي أهمية كبيرة لحماية بياناتك الشخصية.'),
            ('2. البيانات المجمعة',
              '• الاسم الأول والأخير وعنوان البريد الإلكتروني\n'
              '• مدينة الإقامة\n'
              '• صورة الملف الشخصي (اختياري)\n'
              '• رقم الهاتف (إذا تم تفعيل التحقق الثنائي)\n'
              '• سجل النفايات الممسوحة\n'
              '• الموقع الجغرافي (بإذنك فقط)\n\n'
              'لا نجمع بياناتك المصرفية ولا نبيع بياناتك أبدًا لأطراف ثالثة.'),
            ('3. استخدام البيانات',
              'تُستخدم بياناتك من أجل:\n'
              '• تخصيص تجربتك\n'
              '• حساب تأثيرك البيئي\n'
              '• تأمين حسابك\n'
              '• إرسال إشعارات مفيدة إليك'),
            ('4. مشاركة البيانات',
              'قد تُشارَك بياناتك مع:\n'
              '• Firebase (Google): الاستضافة والمصادقة\n'
              '• Google Maps: عرض النقاط البيئية\n'
              '• Gemini API: معالجة مجهولة لأسئلة EcoBot\n\n'
              'تخضع هذه الخدمات لسياسات Google.'),
            ('5. الأمان',
              '• البيانات مخزنة على Firebase (Google Cloud)\n'
              '• النقل مشفر عبر HTTPS/TLS\n'
              '• كلمات المرور مجزأة، لا تُخزَّن نصًا صريحًا\n'
              '• المصادقة الثنائية متاحة'),
            ('6. حقوقك',
              'يمكنك في أي وقت:\n'
              '• الوصول إلى بياناتك\n'
              '• تعديل معلوماتك (الإعدادات)\n'
              '• حذف حسابك (الإعدادات ← حذف حسابي)\n'
              '• تعطيل الموقع (إعدادات الهاتف)\n\n'
              'التواصل: ecoscan.maroc@gmail.com'),
            ('7. بيانات القاصرين',
              'EcoScan مخصص للمستخدمين من عمر 13 سنة فأكثر. '
              'لا نجمع بيانات الأطفال دون 13 سنة عن علم.'),
            ('8. التواصل',
              'EcoScan المغرب\n'
              'كلية العلوم والتقنيات بالمحمدية\n'
              'جامعة الحسن الثاني بالدار البيضاء\n'
              'البريد: ecoscan.maroc@gmail.com'),
          ],
        };

      case 'es':
        return {
          'appbar': 'Política de Privacidad',
          'title': 'Política de Privacidad',
          'subtitle': 'Última actualización: Mayo 2026',
          'sections': <(String, String)>[
            ('1. Introducción',
              'EcoScan es una aplicación móvil desarrollada en el marco de un proyecto de fin de estudios (PFE) en la Facultad de Ciencias y Técnicas de Mohammedia, Universidad Hassan II de Casablanca.\n\n'
              'Damos gran importancia a la protección de sus datos personales.'),
            ('2. Datos recopilados',
              '• Nombre, apellido y correo electrónico\n'
              '• Ciudad de residencia\n'
              '• Foto de perfil (opcional)\n'
              '• Número de teléfono (si 2FA activado)\n'
              '• Historial de residuos escaneados\n'
              '• Ubicación (solo con su permiso)\n\n'
              'No recopilamos sus datos bancarios y nunca vendemos sus datos a terceros.'),
            ('3. Uso de datos',
              'Sus datos se utilizan para:\n'
              '• Personalizar su experiencia\n'
              '• Calcular su impacto ambiental\n'
              '• Proteger su cuenta\n'
              '• Enviarle notificaciones útiles'),
            ('4. Compartición de datos',
              'Sus datos pueden compartirse con:\n'
              '• Firebase (Google): alojamiento y autenticación\n'
              '• Google Maps: visualización de eco-puntos\n'
              '• Gemini API: procesamiento anónimo de preguntas EcoBot\n\n'
              'Estos servicios están sujetos a las políticas de Google.'),
            ('5. Seguridad',
              '• Datos almacenados en Firebase (Google Cloud)\n'
              '• Transmisión cifrada mediante HTTPS/TLS\n'
              '• Contraseñas hash, nunca almacenadas en texto claro\n'
              '• Autenticación 2FA disponible'),
            ('6. Sus derechos',
              'Puede en cualquier momento:\n'
              '• Acceder a sus datos\n'
              '• Modificar su información (Configuración)\n'
              '• Eliminar su cuenta (Configuración → Eliminar mi cuenta)\n'
              '• Desactivar la ubicación (Configuración del teléfono)\n\n'
              'Contacto: ecoscan.maroc@gmail.com'),
            ('7. Datos de menores',
              'EcoScan está destinado a usuarios de 13 años o más. '
              'No recopilamos conscientemente datos de menores de 13 años.'),
            ('8. Contacto',
              'EcoScan Marruecos\n'
              'Facultad de Ciencias y Técnicas de Mohammedia\n'
              'Universidad Hassan II de Casablanca\n'
              'Email: ecoscan.maroc@gmail.com'),
          ],
        };

      default: // 'fr'
        return {
          'appbar': 'Politique de confidentialité',
          'title': 'Politique de Confidentialité',
          'subtitle': 'Dernière mise à jour : Mai 2026',
          'sections': <(String, String)>[
            ('1. Introduction',
              'EcoScan est une application mobile développée dans le cadre d\'un projet de fin d\'études (PFE) à la Faculté des Sciences et Techniques de Mohammedia, Université Hassan II de Casablanca.\n\n'
              'Nous accordons une grande importance à la protection de vos données personnelles.'),
            ('2. Données collectées',
              '• Prénom, nom et adresse email\n'
              '• Ville de résidence\n'
              '• Photo de profil (optionnelle)\n'
              '• Numéro de téléphone (si 2FA activé)\n'
              '• Historique des déchets scannés\n'
              '• Localisation (avec votre autorisation uniquement)\n\n'
              'Nous ne collectons pas vos données bancaires et ne vendons jamais vos données à des tiers.'),
            ('3. Utilisation des données',
              'Vos données sont utilisées pour :\n'
              '• Personnaliser votre expérience\n'
              '• Calculer votre impact environnemental\n'
              '• Sécuriser votre compte\n'
              '• Vous envoyer des notifications utiles'),
            ('4. Partage des données',
              'Vos données peuvent être partagées avec :\n'
              '• Firebase (Google) : hébergement et authentification\n'
              '• Google Maps : affichage des éco-points\n'
              '• Gemini API : traitement anonymisé des questions EcoBot\n\n'
              'Ces services sont soumis aux politiques de Google.'),
            ('5. Sécurité',
              '• Données stockées sur Firebase (Google Cloud)\n'
              '• Transmission chiffrée via HTTPS/TLS\n'
              '• Mots de passe hachés, jamais stockés en clair\n'
              '• Authentification 2FA disponible'),
            ('6. Vos droits',
              'Vous pouvez à tout moment :\n'
              '• Accéder à vos données\n'
              '• Modifier vos informations (Paramètres)\n'
              '• Supprimer votre compte (Paramètres → Supprimer mon compte)\n'
              '• Désactiver la localisation (Paramètres du téléphone)\n\n'
              'Contact : ecoscan.maroc@gmail.com'),
            ('7. Données des mineurs',
              'EcoScan est destiné aux utilisateurs de 13 ans et plus. '
              'Nous ne collectons pas sciemment de données sur des enfants de moins de 13 ans.'),
            ('8. Contact',
              'EcoScan Maroc\n'
              'Faculté des Sciences et Techniques de Mohammedia\n'
              'Université Hassan II de Casablanca\n'
              'Email : ecoscan.maroc@gmail.com'),
          ],
        };
    }
  }
}
