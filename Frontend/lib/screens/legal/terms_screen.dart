import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import 'legal_widgets.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

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
              emoji: '📋',
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
          'appbar': 'Terms of Use',
          'title': 'Terms of Use',
          'subtitle': 'Last updated: May 2026',
          'sections': <(String, String)>[
            ('1. Acceptance',
              'By using EcoScan, you agree to these terms. '
              'If you do not agree, please do not use the application.'),
            ('2. Service description',
              'EcoScan allows you to:\n'
              '• Identify recyclable waste via the camera\n'
              '• Get sorting advice adapted to Morocco\n'
              '• Interact with EcoBot, AI recycling assistant\n'
              '• Track your environmental impact\n'
              '• Participate in community challenges'),
            ('3. Account creation',
              '• Minimum age: 13 years\n'
              '• Accurate information required\n'
              '• One account per person\n'
              '• You are responsible for the security of your credentials'),
            ('4. Acceptable use',
              'Allowed:\n'
              '• Personal non-commercial use\n'
              '• Sharing your statistics\n\n'
              'Prohibited:\n'
              '• Illegal or fraudulent use\n'
              '• Attempting to hack the application\n'
              '• Creating fake accounts\n'
              '• Using automated bots'),
            ('5. Accuracy of information',
              'EcoScan does not guarantee 100% accuracy of classifications. '
              'If in doubt, check with your municipality. '
              'EcoBot provides general information and does not replace professional advice.'),
            ('6. Limitation of liability',
              'EcoScan is not responsible for:\n'
              '• AI classification errors\n'
              '• Data loss due to technical issues\n'
              '• Service interruptions for maintenance'),
            ('7. Applicable law',
              'These terms are governed by Moroccan law. '
              'Any dispute will be submitted to the competent jurisdiction of Casablanca, Morocco.'),
            ('8. Contact',
              'EcoScan Morocco\n'
              'Faculty of Science and Technology of Mohammedia\n'
              'Email: ecoscan.maroc@gmail.com'),
          ],
        };

      case 'ar':
        return {
          'appbar': 'شروط الاستخدام',
          'title': 'شروط الاستخدام',
          'subtitle': 'آخر تحديث: مايو 2026',
          'sections': <(String, String)>[
            ('1. القبول',
              'باستخدامك لـ EcoScan، فإنك توافق على هذه الشروط. '
              'إذا كنت لا توافق، يرجى عدم استخدام التطبيق.'),
            ('2. وصف الخدمة',
              'يتيح لك EcoScan:\n'
              '• التعرف على النفايات القابلة لإعادة التدوير عبر الكاميرا\n'
              '• الحصول على نصائح الفرز المتكيفة مع المغرب\n'
              '• التفاعل مع EcoBot، المساعد الذكي لإعادة التدوير\n'
              '• تتبع تأثيرك البيئي\n'
              '• المشاركة في تحديات مجتمعية'),
            ('3. إنشاء الحساب',
              '• الحد الأدنى للعمر: 13 سنة\n'
              '• معلومات دقيقة مطلوبة\n'
              '• حساب واحد لكل شخص\n'
              '• أنت مسؤول عن أمان بيانات اعتمادك'),
            ('4. الاستخدام المقبول',
              'مسموح:\n'
              '• الاستخدام الشخصي غير التجاري\n'
              '• مشاركة إحصائياتك\n\n'
              'محظور:\n'
              '• الاستخدام غير القانوني أو الاحتيالي\n'
              '• محاولة اختراق التطبيق\n'
              '• إنشاء حسابات وهمية\n'
              '• استخدام الروبوتات الآلية'),
            ('5. دقة المعلومات',
              'لا يضمن EcoScan دقة 100% للتصنيفات. '
              'في حالة الشك، تحقق من بلديتك. '
              'يوفر EcoBot معلومات عامة ولا يحل محل النصيحة المهنية.'),
            ('6. تحديد المسؤولية',
              'EcoScan غير مسؤول عن:\n'
              '• أخطاء تصنيف الذكاء الاصطناعي\n'
              '• فقدان البيانات بسبب مشاكل تقنية\n'
              '• انقطاع الخدمة للصيانة'),
            ('7. القانون المطبق',
              'تخضع هذه الشروط للقانون المغربي. '
              'ستُحال أي نزاعات إلى الجهة القضائية المختصة في الدار البيضاء، المغرب.'),
            ('8. التواصل',
              'EcoScan المغرب\n'
              'كلية العلوم والتقنيات بالمحمدية\n'
              'البريد: ecoscan.maroc@gmail.com'),
          ],
        };

      case 'es':
        return {
          'appbar': 'Condiciones de Uso',
          'title': 'Condiciones de Uso',
          'subtitle': 'Última actualización: Mayo 2026',
          'sections': <(String, String)>[
            ('1. Aceptación',
              'Al usar EcoScan, acepta estas condiciones. '
              'Si no está de acuerdo, por favor no utilice la aplicación.'),
            ('2. Descripción del servicio',
              'EcoScan le permite:\n'
              '• Identificar residuos reciclables mediante la cámara\n'
              '• Obtener consejos de clasificación adaptados a Marruecos\n'
              '• Interactuar con EcoBot, asistente IA de reciclaje\n'
              '• Seguir su impacto ambiental\n'
              '• Participar en desafíos comunitarios'),
            ('3. Creación de cuenta',
              '• Edad mínima: 13 años\n'
              '• Se requiere información exacta\n'
              '• Una sola cuenta por persona\n'
              '• Usted es responsable de la seguridad de sus credenciales'),
            ('4. Uso aceptable',
              'Permitido:\n'
              '• Uso personal no comercial\n'
              '• Compartir sus estadísticas\n\n'
              'Prohibido:\n'
              '• Uso ilegal o fraudulento\n'
              '• Intentos de hackear la aplicación\n'
              '• Creación de cuentas falsas\n'
              '• Uso de bots automatizados'),
            ('5. Exactitud de la información',
              'EcoScan no garantiza la exactitud al 100% de las clasificaciones. '
              'En caso de duda, verifique con su municipio. '
              'EcoBot proporciona información general y no sustituye el asesoramiento profesional.'),
            ('6. Limitación de responsabilidad',
              'EcoScan no es responsable de:\n'
              '• Errores de clasificación por IA\n'
              '• Pérdida de datos por problemas técnicos\n'
              '• Interrupciones del servicio por mantenimiento'),
            ('7. Derecho aplicable',
              'Estas condiciones se rigen por el derecho marroquí. '
              'Cualquier disputa será sometida a la jurisdicción competente de Casablanca, Marruecos.'),
            ('8. Contacto',
              'EcoScan Marruecos\n'
              'Facultad de Ciencias y Técnicas de Mohammedia\n'
              'Email: ecoscan.maroc@gmail.com'),
          ],
        };

      default: // 'fr'
        return {
          'appbar': 'Conditions d\'utilisation',
          'title': 'Conditions d\'Utilisation',
          'subtitle': 'Dernière mise à jour : Mai 2026',
          'sections': <(String, String)>[
            ('1. Acceptation',
              'En utilisant EcoScan, vous acceptez ces conditions. '
              'Si vous n\'acceptez pas, veuillez ne pas utiliser l\'application.'),
            ('2. Description du service',
              'EcoScan permet de :\n'
              '• Identifier les déchets recyclables via la caméra\n'
              '• Obtenir des conseils de tri adaptés au Maroc\n'
              '• Interagir avec EcoBot, assistant IA recyclage\n'
              '• Suivre son impact environnemental\n'
              '• Participer à des défis communautaires'),
            ('3. Création de compte',
              '• Âge minimum : 13 ans\n'
              '• Informations exactes requises\n'
              '• Un seul compte par personne\n'
              '• Vous êtes responsable de la sécurité de vos identifiants'),
            ('4. Utilisation acceptable',
              'Autorisé :\n'
              '• Usage personnel non commercial\n'
              '• Partage de vos statistiques\n\n'
              'Interdit :\n'
              '• Usage illégal ou frauduleux\n'
              '• Tentative de piratage de l\'application\n'
              '• Création de faux comptes\n'
              '• Utilisation de robots automatisés'),
            ('5. Exactitude des informations',
              'EcoScan ne garantit pas l\'exactitude à 100% des classifications. '
              'En cas de doute, vérifiez auprès de votre commune. '
              'EcoBot fournit des informations générales et ne remplace pas un conseil professionnel.'),
            ('6. Limitation de responsabilité',
              'EcoScan n\'est pas responsable de :\n'
              '• Erreurs de classification par l\'IA\n'
              '• Perte de données due à des problèmes techniques\n'
              '• Interruptions de service pour maintenance'),
            ('7. Droit applicable',
              'Ces conditions sont régies par le droit marocain. '
              'Tout litige sera soumis à la juridiction compétente de Casablanca, Maroc.'),
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
