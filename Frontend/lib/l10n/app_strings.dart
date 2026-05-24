class AppStrings {
  final String _locale;
  AppStrings(this._locale);

  static AppStrings of(String locale) => AppStrings(locale);

  String _t(String fr, String en, String ar, [String? es]) {
    switch (_locale) {
      case 'en': return en;
      case 'ar': return ar;
      case 'es': return es ?? fr;
      default:   return fr;
    }
  }

  // ── App ──────────────────────────────────────────────────────────────────
  String get appName     => 'EcoScan';
  String get tagline     => _t('Ensemble pour une planète plus verte',
                               'Together for a greener planet',
                               'معاً من أجل كوكب أكثر خضرة',
                               'Juntos por un planeta más verde');

  // ── Common ───────────────────────────────────────────────────────────────
  String get save        => _t('Enregistrer', 'Save', 'حفظ', 'Guardar');
  String get cancel      => _t('Annuler', 'Cancel', 'إلغاء', 'Cancelar');
  String get delete      => _t('Supprimer', 'Delete', 'حذف', 'Eliminar');
  String get next        => _t('Suivant', 'Next', 'التالي', 'Siguiente');
  String get skip        => _t('Passer', 'Skip', 'تخطي', 'Omitir');
  String get start       => _t('Commencer', 'Start', 'ابدأ', 'Comenzar');
  String get seeAll      => _t('Voir tout', 'See all', 'عرض الكل', 'Ver todo');
  String get loading     => _t('Chargement...', 'Loading...', 'جارٍ التحميل...', 'Cargando...');
  String get confirm     => _t('Confirmer', 'Confirm', 'تأكيد', 'Confirmar');
  String get search      => _t('Rechercher...', 'Search...', 'بحث...', 'Buscar...');
  String get close       => _t('Fermer', 'Close', 'إغلاق', 'Cerrar');
  String get yes         => _t('Oui', 'Yes', 'نعم', 'Sí');
  String get no          => _t('Non', 'No', 'لا', 'No');
  String get send        => _t('Envoyer', 'Send', 'إرسال', 'Enviar');
  String get update      => _t('Mettre à jour', 'Update', 'تحديث', 'Actualizar');
  String get retry       => _t('Réessayer', 'Retry', 'إعادة المحاولة', 'Reintentar');
  String get done        => _t('Terminé', 'Done', 'تم', 'Listo');
  String get back        => _t('Retour', 'Back', 'رجوع', 'Volver');
  String get share       => _t('Partager', 'Share', 'مشاركة', 'Compartir');

  // ── Navigation ───────────────────────────────────────────────────────────
  String get navHome       => _t('Accueil',   'Home',      'الرئيسية',  'Inicio');
  String get navMap        => _t('Carte',     'Map',       'الخريطة',   'Mapa');
  String get navScan       => _t('Scanner',   'Scan',      'مسح',       'Escanear');
  String get navChat       => _t('Assistant', 'Assistant', 'المساعد',   'Asistente');
  String get navProfile    => _t('Profil',    'Profile',   'الملف',     'Perfil');

  // ── Auth ─────────────────────────────────────────────────────────────────
  String get welcomeBack   => _t('Bon retour !', 'Welcome back!', 'مرحباً بعودتك!', '¡Bienvenido de nuevo!');
  String get loginSubtitle => _t('Connectez-vous pour continuer',
                                 'Sign in to continue',
                                 'سجّل دخولك للمتابعة',
                                 'Inicia sesión para continuar');
  String get email         => _t('Email', 'Email', 'البريد الإلكتروني', 'Correo');
  String get password      => _t('Mot de passe', 'Password', 'كلمة المرور', 'Contraseña');
  String get forgotPass    => _t('Mot de passe oublié ?', 'Forgot password?', 'نسيت كلمة المرور؟', '¿Olvidaste tu contraseña?');
  String get loginBtn      => _t('Se connecter', 'Login', 'تسجيل الدخول', 'Iniciar sesión');
  String get noAccount     => _t('Pas encore de compte ? ', "Don't have an account? ", 'ليس لديك حساب؟ ', '¿No tienes cuenta? ');
  String get registerLink  => _t("S'inscrire", 'Register', 'سجّل الآن', 'Regístrate');
  String get createAccount => _t('Créer un compte', 'Create account', 'إنشاء حساب', 'Crear cuenta');
  String get personalInfo  => _t('Vos informations personnelles',
                                 'Your personal information',
                                 'معلوماتك الشخصية',
                                 'Tu información personal');
  String get createPass    => _t('Créez votre mot de passe',
                                 'Create your password',
                                 'أنشئ كلمة المرور',
                                 'Crea tu contraseña');
  String get fullName      => _t('Nom complet', 'Full name', 'الاسم الكامل', 'Nombre completo');
  String get continue_     => _t('Continuer', 'Continue', 'متابعة', 'Continuar');
  String get alreadyAccount => _t('Déjà un compte ? ', 'Already have an account? ', 'لديك حساب؟ ', '¿Ya tienes cuenta? ');
  String get loginLink     => _t('Se connecter', 'Log in', 'تسجيل الدخول', 'Inicia sesión');
  String get youAre        => _t('Vous êtes ?', 'You are?', 'أنت؟', '¿Quién eres?');
  String get confirmPass   => _t('Confirmer le mot de passe', 'Confirm password', 'تأكيد كلمة المرور', 'Confirmar contraseña');
  String get yourIdentity  => _t('Votre identité', 'Your identity', 'هويتك', 'Tu identidad');
  String get yourAccess    => _t('Vos accès', 'Your access', 'بيانات الدخول', 'Tu acceso');
  String get yourLocation  => _t('Votre localisation', 'Your location', 'موقعك', 'Tu ubicación');
  String get invalidEmail  => _t('Email invalide', 'Invalid email', 'بريد إلكتروني غير صالح', 'Correo inválido');
  String get minPassword   => _t('Minimum 6 caractères', 'At least 6 characters', '6 أحرف على الأقل', 'Mínimo 6 caracteres');
  String get passwordsMismatch => _t('Les mots de passe ne correspondent pas',
                                    'Passwords do not match',
                                    'كلمتا المرور غير متطابقتين',
                                    'Las contraseñas no coinciden');
  String get cityRequired  => _t('Ville requise', 'City required', 'المدينة مطلوبة', 'Ciudad requerida');
  String get fieldRequired => _t('Requis', 'Required', 'مطلوب', 'Requerido');
  String get mustAcceptTerms => _t('Veuillez accepter les CGU', 'Please accept the terms', 'يرجى قبول الشروط', 'Por favor acepta los términos');
  String get accountCreated => _t('Votre compte a été créé avec succès.', 'Your account was created successfully.', 'تم إنشاء حسابك بنجاح.', 'Tu cuenta fue creada exitosamente.');
  String welcomeMsg(String name) => _t('Bienvenue $name ! 🌿', 'Welcome $name! 🌿', 'مرحباً $name! 🌿', '¡Bienvenido $name! 🌿');
  String get createAccount2=> _t('Créer mon compte 🌿', 'Create my account 🌿', 'إنشاء حسابي 🌿', 'Crear mi cuenta 🌿');
  String get acceptTerms   => _t("J'accepte les ", 'I accept the ', 'أوافق على ', 'Acepto los ');
  String get termsOfUse    => _t("Conditions d'utilisation", 'Terms of use', 'شروط الاستخدام', 'Términos de uso');
  String get andThe        => _t(' et la ', ' and the ', ' و ', ' y la ');
  String get privacyPolicyLink => _t('Politique de confidentialité', 'Privacy policy', 'سياسة الخصوصية', 'Política de privacidad');
  String get orContinueWith => _t('ou continuer avec', 'or continue with', 'أو تابع بـ', 'o continuar con');
  String get googleSignInError => _t('Erreur Google Sign-In', 'Google Sign-In error', 'خطأ في تسجيل الدخول بـ Google', 'Error Google Sign-In');
  String get forgotPassHint => _t('Entrez votre email pour réinitialiser le mot de passe',
                                  'Enter your email to reset your password',
                                  'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور',
                                  'Ingresa tu correo para restablecer tu contraseña');
  String get resetSent     => _t('Email de réinitialisation envoyé ✅',
                                 'Reset email sent ✅',
                                 'تم إرسال بريد إعادة التعيين ✅',
                                 'Correo de restablecimiento enviado ✅');
  String get sendError     => _t('Erreur lors de l\'envoi', 'Error sending email', 'خطأ في الإرسال', 'Error al enviar');
  String get taglineLogin  => _t('Triez mieux, vivez mieux 🌱',
                                 'Sort better, live better 🌱',
                                 'افرز أفضل، عش أفضل 🌱',
                                 'Clasifica mejor, vive mejor 🌱');

  // ── Verify Email ──────────────────────────────────────────────────────────
  String get verifyEmail      => _t('Vérifiez votre email', 'Verify your email', 'تحقق من بريدك الإلكتروني', 'Verifica tu correo');
  String get verifyEmailDesc  => _t('Ouvrez votre boîte mail et cliquez sur le lien.\nCette page se redirige automatiquement.',
                                    'Open your inbox and click the link.\nThis page redirects automatically.',
                                    'افتح بريدك الوارد وانقر على الرابط.\nتتم إعادة التوجيه تلقائياً.',
                                    'Abre tu bandeja y haz clic en el enlace.\nEsta página redirige automáticamente.');
  String get resendEmail      => _t('Renvoyer l\'email', 'Resend email', 'إعادة إرسال البريد', 'Reenviar correo');
  String get verifyBySms      => _t('Vérifier par SMS à la place', 'Verify by SMS instead', 'التحقق عبر الرسائل القصيرة', 'Verificar por SMS');
  String get changeAccount    => _t('Changer de compte', 'Change account', 'تغيير الحساب', 'Cambiar cuenta');
  String get waitingVerif     => _t('En attente de vérification…', 'Waiting for verification…', 'في انتظار التحقق…', 'Esperando verificación…');
  String get resendIn         => _t('Renvoyer dans', 'Resend in', 'إعادة الإرسال في', 'Reenviar en');

  // ── Two-Factor Auth ──────────────────────────────────────────────────────
  String get twoFactorTitle   => _t('Double authentification', 'Two-factor authentication', 'المصادقة الثنائية', 'Autenticación de dos factores');
  String get twoFactorSub     => _t('Liez votre numéro de téléphone', 'Link your phone number', 'ربط رقم هاتفك', 'Vincula tu número de teléfono');
  String get twoFactorDesc    => _t('Un SMS de vérification sera envoyé à ce numéro.',
                                    'A verification SMS will be sent to this number.',
                                    'سيتم إرسال رسالة تحقق إلى هذا الرقم.',
                                    'Se enviará un SMS de verificación a este número.');
  String get sendSmsCode      => _t('Envoyer le code SMS', 'Send SMS code', 'إرسال رمز SMS', 'Enviar código SMS');
  String get enterSmsCode     => _t('Entrez le code SMS', 'Enter the SMS code', 'أدخل رمز SMS', 'Ingresa el código SMS');
  String get verifyCode       => _t('Vérifier', 'Verify', 'تحقق', 'Verificar');
  String get resendCode       => _t('Renvoyer le code', 'Resend code', 'إعادة إرسال الرمز', 'Reenviar código');
  String get twoFactorDone    => _t('Double authentification activée !', 'Two-factor authentication enabled!', 'تم تفعيل المصادقة الثنائية!', '¡Autenticación de dos factores activada!');
  String get twoFactorDoneDesc=> _t('Votre compte est maintenant protégé par une vérification en deux étapes.',
                                    'Your account is now protected by two-step verification.',
                                    'حسابك الآن محمي بالتحقق بخطوتين.',
                                    'Tu cuenta ahora está protegida con verificación en dos pasos.');
  String get continueHome     => _t('Continuer vers l\'accueil', 'Continue to home', 'المتابعة إلى الرئيسية', 'Continuar al inicio');
  String get verifyCodeTitle  => _t('Code de vérification', 'Verification code', 'رمز التحقق', 'Código de verificación');
  String get invalidPhone     => _t('Numéro de téléphone invalide.', 'Invalid phone number.', 'رقم الهاتف غير صالح.', 'Número de teléfono inválido.');
  String get enterSixDigits   => _t('Entrez le code à 6 chiffres.', 'Enter the 6-digit code.', 'أدخل الرمز المكون من 6 أرقام.', 'Ingresa el código de 6 dígitos.');
  String get wrongOtp         => _t('Code incorrect. Réessayez.', 'Wrong code. Try again.', 'رمز خاطئ. حاول مجدداً.', 'Código incorrecto. Inténtalo de nuevo.');
  String get phoneLinkedOther => _t('Ce numéro est lié à un autre compte.', 'This number is linked to another account.', 'هذا الرقم مرتبط بحساب آخر.', 'Este número está vinculado a otra cuenta.');
  String get phoneAlreadyLinked => _t('Un numéro est déjà lié à ce compte.', 'A number is already linked to this account.', 'رقم مرتبط بالفعل بهذا الحساب.', 'Un número ya está vinculado a esta cuenta.');
  String codeSentTo(String phone) => _t('Code envoyé au $phone', 'Code sent to $phone', 'تم إرسال الرمز إلى $phone', 'Código enviado a $phone');
  String finalNumber(String n)    => _t('Numéro final : $n', 'Final number: $n', 'الرقم النهائي: $n', 'Número final: $n');
  String errorMsg(String msg)     => _t('Erreur : $msg', 'Error: $msg', 'خطأ: $msg', 'Error: $msg');

  // ── Onboarding ───────────────────────────────────────────────────────────
  String get ob1Title    => _t('Scannez & Identifiez',
                               'Scan & Identify',
                               'امسح وتعرّف',
                               'Escanea e Identifica');
  String get ob1Sub      => _t('Photographiez n\'importe quel déchet et notre IA l\'identifie instantanément pour vous indiquer la bonne poubelle.',
                               'Photograph any waste and our AI instantly identifies it to show you the right bin.',
                               'التقط صورة لأي نفايات وسيحددها نظام الذكاء الاصطناعي فوراً ليرشدك إلى الحاوية الصحيحة.',
                               'Fotografía cualquier residuo y nuestra IA lo identifica al instante para mostrarte el contenedor correcto.');
  String get ob2Title    => _t('Trouvez les Points de Collecte',
                               'Find Collection Points',
                               'ابحث عن نقاط الجمع',
                               'Encuentra Puntos de Recogida');
  String get ob2Sub      => _t('Localisez les bacs de tri, déchetteries et points de dépôt les plus proches autour de vous en temps réel.',
                               'Locate the nearest sorting bins, recycling centres and drop-off points in real time.',
                               'حدد موقع أقرب صناديق الفرز ومراكز إعادة التدوير ونقاط الإيداع في الوقت الفعلي.',
                               'Localiza los contenedores de reciclaje, ecoparques y puntos de depósito más cercanos en tiempo real.');
  String get ob3Title    => _t('Gagnez des Récompenses',
                               'Earn Rewards',
                               'اكسب مكافآت',
                               'Gana Recompensas');
  String get ob3Sub      => _t('Chaque action éco-responsable vous rapporte des points. Grimpez dans le classement et débloquez des badges exclusifs.',
                               'Every eco-responsible action earns you points. Climb the leaderboard and unlock exclusive badges.',
                               'كل إجراء بيئي مسؤول يمنحك نقاطاً. تصعّد في الترتيب وافتح شارات حصرية.',
                               'Cada acción eco-responsable te da puntos. Sube en el ranking y desbloquea insignias exclusivas.');

  // ── Home ─────────────────────────────────────────────────────────────────
  String get greetingPrefix  => _t('Bonjour', 'Hello', 'مرحباً', 'Hola');
  String get readySubtitle   => _t('Prêt à sauver la planète ?',
                                   'Ready to save the planet?',
                                   'هل أنت مستعد لإنقاذ الكوكب؟',
                                   '¿Listo para salvar el planeta?');
  String get weeklyGoal      => _t('OBJECTIF HEBDO', 'WEEKLY GOAL', 'الهدف الأسبوعي', 'META SEMANAL');
  String get recycled        => _t('de déchets recyclés', 'of recycled waste', 'من النفايات المُعاد تدويرها', 'de residuos reciclados');
  String get quickActions    => _t('Actions rapides', 'Quick actions', 'الإجراءات السريعة', 'Acciones rápidas');
  String get recentActivity  => _t('Activités récentes', 'Recent activities', 'الأنشطة الأخيرة', 'Actividades recientes');
  String get didYouKnow      => _t('Le saviez-vous ?', 'Did you know?', 'هل تعلم؟', '¿Sabías que?');
  String get ecoTipText      => _t('Recycler une canette d\'aluminium économise 95% d\'énergie comparé à en fabriquer une neuve.',
                                   'Recycling one aluminium can saves 95% of the energy needed to make a new one.',
                                   'إعادة تدوير علبة ألومنيوم واحدة توفر 95٪ من الطاقة اللازمة لتصنيع علبة جديدة.',
                                   'Reciclar una lata de aluminio ahorra el 95% de la energía necesaria para fabricar una nueva.');
  String get points          => _t('Points', 'Points', 'النقاط', 'Puntos');
  String get scans           => _t('Scans', 'Scans', 'المسوحات', 'Escaneos');
  String get co2Avoided      => _t('CO₂ Évité (g)', 'CO₂ Saved (g)', 'CO₂ موفور (غ)', 'CO₂ Ahorrado (g)');
  String get thisWeek        => _t('Cette semaine', 'This week', 'هذا الأسبوع', 'Esta semana');
  String get ofGoal          => _t('de l\'objectif', 'of goal', 'من الهدف', 'de la meta');
  String get noActivity      => _t('Aucune activité — scannez votre premier déchet !',
                                   'No activity — scan your first waste!',
                                   'لا نشاط — امسح نفاياتك الأولى!',
                                   'Sin actividad — ¡escanea tu primer residuo!');
  String get scanCategory    => _t('Scan', 'Scan', 'مسح', 'Escanear');
  String get co2Saved        => _t('CO₂ évité', 'CO₂ saved', 'CO₂ موفور', 'CO₂ ahorrado');
  String get waterSaved      => _t('Eau éco.', 'Water saved', 'ماء موفور', 'Agua ahorrada');
  String get communityImpact => _t('Impact communautaire', 'Community impact', 'التأثير المجتمعي', 'Impacto comunitario');
  String get totalScansComm  => _t('Scans totaux', 'Total scans', 'إجمالي المسوحات', 'Escaneos totales');
  String get kgRecycled      => _t('kg recyclés', 'kg recycled', 'كغ مُعاد تدويره', 'kg reciclados');
  String get users           => _t('Utilisateurs', 'Users', 'المستخدمون', 'Usuarios');
  String get dailyChallenge  => _t('Défi du jour', 'Daily challenge', 'تحدي اليوم', 'Desafío del día');
  String get dailyChallengeTask => _t('Scannez 3 articles en plastique',
                                      'Scan 3 plastic items',
                                      'امسح 3 عناصر بلاستيكية',
                                      'Escanear 3 artículos de plástico');
  String get challengeProgress1of3 => _t('1 sur 3 complété  ·  Expire dans 8 h',
                                         '1 of 3 completed  ·  Expires in 8h',
                                         '١ من ٣ مكتمل  ·  ينتهي في ٨ س',
                                         '1 de 3 completado  ·  Expira en 8h');
  String get communityLevelText => _t('68% vers le prochain niveau communautaire',
                                      '68% towards next community level',
                                      '٦٨٪ نحو المستوى المجتمعي التالي',
                                      '68% hacia el próximo nivel comunitario');
  String get sortingCategories => _t('Catégories de tri', 'Sorting categories', 'فئات الفرز', 'Categorías de reciclaje');
  String get scanProduct     => _t('Scanner un produit', 'Scan a product', 'مسح منتج', 'Escanear producto');
  String get analyzeEcoImpact => _t('Analysez l\'impact écologique', 'Analyze the ecological impact', 'تحليل التأثير البيئي', 'Analizar el impacto ecológico');

  // ── Quick actions ─────────────────────────────────────────────────────────
  String get qaBadges        => _t('Badges', 'Badges', 'الشارات', 'Insignias');
  String get qaGuide         => _t('Guide de Tri', 'Sorting Guide', 'دليل الفرز', 'Guía de reciclaje');
  String get qaLeaderboard   => _t('Classement', 'Leaderboard', 'الترتيب', 'Clasificación');
  String get qaStats         => _t('Statistiques', 'Statistics', 'الإحصائيات', 'Estadísticas');
  String get qaChallenges    => _t('Défis', 'Challenges', 'التحديات', 'Desafíos');
  String get qaHistory       => _t('Historique', 'History', 'السجل', 'Historial');
  String get qaRewards       => _t('Récompenses', 'Rewards', 'المكافآت', 'Recompensas');
  String get qaCalculator    => _t('Bilan CO₂', 'CO₂ Calculator', 'حاسبة CO₂', 'Calculadora CO₂');

  // ── Screen titles ─────────────────────────────────────────────────────────
  String get myStats         => _t('Mes Statistiques', 'My Statistics', 'إحصائياتي', 'Mis Estadísticas');
  String get myBadges        => _t('Mes Badges', 'My Badges', 'شاراتي', 'Mis Insignias');
  String get sortingGuide    => _t('Guide de Tri', 'Sorting Guide', 'دليل الفرز', 'Guía de Reciclaje');
  String get leaderboard     => _t('Classement', 'Leaderboard', 'لوحة الترتيب', 'Clasificación');
  String get notifications   => _t('Notifications', 'Notifications', 'الإشعارات', 'Notificaciones');
  String get settingsTitle   => _t('Paramètres', 'Settings', 'الإعدادات', 'Configuración');
  String get myProfile       => _t('Mon Profil', 'My Profile', 'ملفي الشخصي', 'Mi Perfil');
  String get editProfile     => _t('Modifier le profil', 'Edit profile', 'تعديل الملف', 'Editar perfil');
  String get scanResult      => _t('Résultat du scan', 'Scan result', 'نتيجة المسح', 'Resultado del escaneo');
  String get scanDechet      => _t('Scanner un déchet', 'Scan a waste', 'مسح نفايات', 'Escanear residuo');
  String get challengesTitle => _t('Défis Éco', 'Eco Challenges', 'التحديات البيئية', 'Desafíos Eco');
  String get historyTitle    => _t('Historique des Scans', 'Scan History', 'سجل المسوحات', 'Historial de escaneos');
  String get rewardsTitle    => _t('Mes Récompenses', 'My Rewards', 'مكافآتي', 'Mis Recompensas');
  String get languageTitle   => _t('Choisissez votre langue', 'Choose your language', 'اختر لغتك', 'Elige tu idioma');

  // ── Settings ──────────────────────────────────────────────────────────────
  String get appearance      => _t('Apparence', 'Appearance', 'المظهر', 'Apariencia');
  String get darkMode        => _t('Mode sombre', 'Dark mode', 'الوضع المظلم', 'Modo oscuro');
  String get darkModeDesc    => _t('Thème sombre pour vos yeux', 'Dark theme for your eyes', 'وضع داكن لراحة عيونك', 'Tema oscuro para tus ojos');
  String get language        => _t('Langue', 'Language', 'اللغة', 'Idioma');
  String get city            => _t('Ville', 'City', 'المدينة', 'Ciudad');
  String get privacy         => _t('Confidentialité', 'Privacy', 'الخصوصية', 'Privacidad');
  String get location        => _t('Localisation', 'Location', 'الموقع', 'Ubicación');
  String get locationDesc    => _t('Trouver les points proches', 'Find nearby points', 'البحث عن أقرب النقاط', 'Encontrar puntos cercanos');
  String get about           => _t('À propos', 'About', 'حول التطبيق', 'Acerca de');
  String get logout          => _t('Se déconnecter', 'Logout', 'تسجيل الخروج', 'Cerrar sesión');
  String get notifPush       => _t('Notifications push', 'Push notifications', 'إشعارات الدفع', 'Notificaciones push');
  String get notifDesc       => _t('Alertes, rappels et badges', 'Alerts, reminders and badges', 'تنبيهات وتذكيرات وشارات', 'Alertas, recordatorios e insignias');
  String get sound           => _t('Sons', 'Sounds', 'الأصوات', 'Sonidos');
  String get soundDesc       => _t('Sons de l\'application', 'App sounds', 'أصوات التطبيق', 'Sonidos de la app');
  String get weeklyReport    => _t('Rapport hebdomadaire', 'Weekly report', 'تقرير أسبوعي', 'Informe semanal');
  String get weeklyReportDesc=> _t('Résumé chaque lundi matin', 'Summary every Monday morning', 'ملخص كل صباح الاثنين', 'Resumen cada lunes por la mañana');
  String get customize       => _t('Personnalisez votre expérience', 'Customize your experience', 'خصّص تجربتك', 'Personaliza tu experiencia');
  String get exportData      => _t('Exporter mes données', 'Export my data', 'تصدير بياناتي', 'Exportar mis datos');
  String get deleteAccount   => _t('Supprimer mon compte', 'Delete my account', 'حذف حسابي', 'Eliminar mi cuenta');
  String get security        => _t('Sécurité', 'Security', 'الأمان', 'Seguridad');
  String get changePassword  => _t('Changer le mot de passe', 'Change password', 'تغيير كلمة المرور', 'Cambiar contraseña');
  String get changeEmail     => _t('Changer l\'email', 'Change email', 'تغيير البريد الإلكتروني', 'Cambiar correo');
  String get twoFactor       => _t('Double authentification', 'Two-factor auth', 'المصادقة الثنائية', 'Autenticación 2FA');
  String get appVersion      => _t('Version 1.0.0', 'Version 1.0.0', 'الإصدار 1.0.0', 'Versión 1.0.0');
  String get rateApp         => _t('Noter l\'application', 'Rate the app', 'تقييم التطبيق', 'Calificar app');
  String get privacyPolicy   => _t('Politique de confidentialité', 'Privacy policy', 'سياسة الخصوصية', 'Política de privacidad');
  String get deleteAccountConfirm => _t(
    'Cette action est irréversible. Confirmez avec votre mot de passe.',
    'This action is irreversible. Confirm with your password.',
    'هذا الإجراء لا رجعة فيه. أكد بكلمة المرور.',
    'Esta acción es irreversible. Confirma con tu contraseña.');
  String get wrongPassword   => _t('Mot de passe incorrect.', 'Wrong password.', 'كلمة مرور غير صحيحة.', 'Contraseña incorrecta.');
  String get currentPassword => _t('Mot de passe actuel', 'Current password', 'كلمة المرور الحالية', 'Contraseña actual');
  String get newPassword     => _t('Nouveau mot de passe', 'New password', 'كلمة مرور جديدة', 'Nueva contraseña');
  String get confirmNewPassword => _t('Confirmer le nouveau mot de passe', 'Confirm new password', 'تأكيد كلمة المرور الجديدة', 'Confirmar nueva contraseña');
  String get strengthWeak    => _t('Faible', 'Weak', 'ضعيف', 'Débil');
  String get strengthFair    => _t('Moyen', 'Fair', 'متوسط', 'Regular');
  String get strengthGood    => _t('Bon', 'Good', 'جيد', 'Bueno');
  String get strengthStrong  => _t('Fort', 'Strong', 'قوي', 'Fuerte');
  String get passwordUpdated => _t('Mot de passe mis à jour !', 'Password updated!', 'تم تحديث كلمة المرور!', '¡Contraseña actualizada!');
  String get changePassHint  => _t('Pour votre sécurité, entrez d\'abord votre mot de passe actuel.',
                                   'For your security, enter your current password first.',
                                   'لأمانك، أدخل كلمة المرور الحالية أولاً.',
                                   'Por tu seguridad, ingresa primero tu contraseña actual.');
  String get emailAlreadyUsed => _t('Cet email est déjà utilisé.', 'This email is already in use.', 'هذا البريد الإلكتروني مستخدم بالفعل.', 'Este correo ya está en uso.');
  String emailVerifConfirm(String email) => _t(
    'Vérifiez $email pour confirmer le changement.\nVotre email ne changera qu\'après confirmation.',
    'Check $email to confirm the change.\nYour email won\'t change until confirmed.',
    'تحقق من $email لتأكيد التغيير.\nلن يتغير بريدك حتى التأكيد.',
    'Revisa $email para confirmar el cambio.\nTu correo no cambiará hasta la confirmación.');
  String get clearConversation => _t('Effacer la conversation', 'Clear conversation', 'مسح المحادثة', 'Borrar conversación');
  String get botThinking     => _t('EcoBot réfléchit...', 'EcoBot is thinking...', 'EcoBot يفكر...', 'EcoBot está pensando...');
  String get catBatteries    => _t('Piles', 'Batteries', 'بطاريات', 'Pilas');
  String get catCompost      => _t('Compost', 'Compost', 'سماد', 'Compost');
  String get currentEmail    => _t('Email actuel', 'Current email', 'البريد الحالي', 'Correo actual');
  String get newEmail        => _t('Nouvel email', 'New email', 'بريد إلكتروني جديد', 'Nuevo correo');
  String get sendVerifLink   => _t('Envoyer le lien de vérification', 'Send verification link', 'إرسال رابط التحقق', 'Enviar enlace de verificación');
  String get emailVerifSent  => _t('Email de vérification envoyé', 'Verification email sent', 'تم إرسال بريد التحقق', 'Correo de verificación enviado');
  String get backToSettings  => _t('Retour aux paramètres', 'Back to settings', 'العودة إلى الإعدادات', 'Volver a configuración');
  String get profileUpdated  => _t('Profil mis à jour avec succès !', 'Profile updated successfully!', 'تم تحديث الملف الشخصي!', '¡Perfil actualizado con éxito!');
  String get personalInfoSection => _t('Informations personnelles', 'Personal information', 'المعلومات الشخصية', 'Información personal');
  String get bio             => _t('Bio', 'Bio', 'نبذة عني', 'Bio');
  String get displayedTitle  => _t('Titre affiché', 'Displayed title', 'اللقب المعروض', 'Título mostrado');
  String get saveChanges     => _t('Enregistrer les modifications', 'Save changes', 'حفظ التغييرات', 'Guardar cambios');
  String get titleBeginner   => _t('Débutant Vert', 'Green Beginner', 'مبتدئ أخضر', 'Principiante Verde');
  String get titleCitizen    => _t('Éco-Citoyen', 'Eco-Citizen', 'مواطن بيئي', 'Eco-Ciudadano');
  String get titleWarrior    => _t('Éco-Warrior', 'Eco-Warrior', 'محارب بيئي', 'Eco-Guerrero');
  String get titleGuardian   => _t('Gardien de la Planète', 'Planet Guardian', 'حارس الكوكب', 'Guardián del Planeta');
  String get titleMaster     => _t('Maître du Recyclage', 'Recycling Master', 'سيد إعادة التدوير', 'Maestro del Reciclaje');

  // ── Theme screen ──────────────────────────────────────────────────────────
  String get themeSystem     => _t('Système',  'System', 'النظام',  'Sistema');
  String get themeSystemDesc => _t('Suit le mode de votre téléphone', 'Follows your phone\'s mode', 'يتبع وضع هاتفك', 'Sigue el modo del teléfono');
  String get themeLight      => _t('Clair',   'Light',  'فاتح',    'Claro');
  String get themeLightDesc  => _t('Thème clair toujours activé', 'Always light theme', 'الوضع الفاتح دائماً', 'Tema claro siempre activo');
  String get themeDark       => _t('Sombre',  'Dark',   'داكن',    'Oscuro');
  String get themeDarkDesc   => _t('Thème sombre toujours activé', 'Always dark theme', 'الوضع الداكن دائماً', 'Tema oscuro siempre activo');

  // ── Language screen ───────────────────────────────────────────────────────
  String get chooseLang       => _t('Choisissez votre langue', 'Choose your language', 'اختر لغتك', 'Elige tu idioma');
  String get langSubtitle     => _t('Vous pourrez changer cela plus tard dans les paramètres.',
                                    'You can change this later in settings.',
                                    'يمكنك تغيير هذا لاحقاً في الإعدادات.',
                                    'Puedes cambiar esto más tarde en configuración.');
  String get systemLang       => _t('Langue du système', 'System language', 'لغة النظام', 'Idioma del sistema');
  String get systemLangDesc   => _t('Détectée automatiquement', 'Detected automatically', 'تم الكشف تلقائياً', 'Detectado automáticamente');

  // ── Profile ───────────────────────────────────────────────────────────────
  String get level            => _t('Niveau', 'Level', 'المستوى', 'Nivel');
  String get rank             => _t('Rang', 'Rank', 'الترتيب', 'Rango');
  String get recentBadges     => _t('Badges récents', 'Recent badges', 'الشارات الأخيرة', 'Insignias recientes');
  String get menu             => _t('Menu', 'Menu', 'القائمة', 'Menú');
  String get disconnect       => _t('Se déconnecter', 'Sign out', 'تسجيل الخروج', 'Cerrar sesión');
  String get takePhoto        => _t('Prendre une photo', 'Take a photo', 'التقاط صورة', 'Tomar foto');
  String get chooseGallery    => _t('Choisir depuis la galerie', 'Choose from gallery', 'اختيار من المعرض', 'Elegir de galería');
  String get badgeRecycleur   => _t('Recycleur', 'Recycler', 'معيد التدوير', 'Reciclador');
  String get badgeEau         => _t('Eau pure', 'Pure water', 'ماء نقي', 'Agua pura');
  String get badgeArbre       => _t('Arbre', 'Tree', 'شجرة', 'Árbol');
  String get badgeChampion    => _t('Champion', 'Champion', 'بطل', 'Campeón');
  String get menuStats        => _t('Mes statistiques', 'My statistics', 'إحصائياتي', 'Mis estadísticas');
  String get menuBadges       => _t('Mes badges', 'My badges', 'شاراتي', 'Mis insignias');
  String get menuGuide        => _t('Guide de tri', 'Sorting guide', 'دليل الفرز', 'Guía de reciclaje');
  String get menuLeaderboard  => _t('Classement', 'Leaderboard', 'لوحة الترتيب', 'Clasificación');
  String get menuNotifications=> _t('Notifications', 'Notifications', 'الإشعارات', 'Notificaciones');
  String get menuSettings     => _t('Paramètres', 'Settings', 'الإعدادات', 'Configuración');
  String xpProgressText(int current, int total) =>
      _t('$current / $total XP pour le prochain niveau',
         '$current / $total XP to next level',
         '$current / $total XP للمستوى التالي',
         '$current / $total XP para el siguiente nivel');
  String levelCity(int lvl, String city) =>
      _t('Niveau $lvl • $city', 'Level $lvl • $city', 'المستوى $lvl • $city', 'Nivel $lvl • $city');
  String nextLevelLabel(int n) =>
      _t('Niveau $n →', 'Level $n →', 'المستوى $n →', 'Nivel $n →');

  // ── Notifications ──────────────────────────────────────────────────────────
  String get noNotifications  => _t('Aucune notification pour le moment',
                                    'No notifications yet',
                                    'لا توجد إشعارات بعد',
                                    'Sin notificaciones por ahora');

  // ── Challenges ────────────────────────────────────────────────────────────
  String get daily           => _t('Quotidien', 'Daily', 'يومي', 'Diario');
  String get weekly          => _t('Hebdomadaire', 'Weekly', 'أسبوعي', 'Semanal');
  String get completed       => _t('Terminé', 'Completed', 'مكتمل', 'Completado');
  String get inProgress      => _t('En cours', 'In progress', 'قيد التنفيذ', 'En progreso');
  String get claim           => _t('Réclamer', 'Claim', 'استلام', 'Reclamar');
  String get challengesDone  => _t('défis complétés aujourd\'hui', 'challenges completed today', 'تحديات مكتملة اليوم', 'desafíos completados hoy');
  String get streak          => _t('jours de suite', 'day streak', 'أيام متتالية', 'días seguidos');
  String get pointsReward    => _t('pts à gagner', 'pts to earn', 'نقطة للربح', 'pts a ganar');
  String get resetIn         => _t('Réinitialisation dans', 'Resets in', 'يُعاد تعيينه في', 'Se reinicia en');

  // ── History ───────────────────────────────────────────────────────────────
  String get totalScans      => _t('Total Scans', 'Total Scans', 'إجمالي المسوحات', 'Escaneos totales');
  String get pointsEarned    => _t('Points Gagnés', 'Points Earned', 'النقاط المكتسبة', 'Puntos ganados');
  String get mostScanned     => _t('Plus scanné', 'Most scanned', 'الأكثر مسحاً', 'Más escaneado');
  String get filterAll       => _t('Tous', 'All', 'الكل', 'Todo');
  String get recyclable      => _t('Recyclable', 'Recyclable', 'قابل لإعادة التدوير', 'Reciclable');
  String get nonRecyclable   => _t('Non recyclable', 'Non recyclable', 'غير قابل لإعادة التدوير', 'No reciclable');
  String get noHistory       => _t('Aucun scan pour l\'instant', 'No scans yet', 'لا توجد مسوحات بعد', 'Sin escaneos aún');

  // ── Rewards ───────────────────────────────────────────────────────────────
  String get yourBalance     => _t('Votre solde', 'Your balance', 'رصيدك', 'Tu saldo');
  String get redeem          => _t('Échanger', 'Redeem', 'استبدال', 'Canjear');
  String get redeemed        => _t('Obtenu ✓', 'Redeemed ✓', 'تم الاستبدال ✓', 'Canjeado ✓');
  String get notEnoughPoints => _t('Points insuffisants', 'Not enough points', 'نقاط غير كافية', 'Puntos insuficientes');
  String get trees           => _t('Nature', 'Nature', 'طبيعة', 'Naturaleza');
  String get coupons         => _t('Coupons', 'Coupons', 'كوبونات', 'Cupones');
  String get donations       => _t('Dons', 'Donations', 'تبرعات', 'Donaciones');
  String get digital         => _t('Digital', 'Digital', 'رقمي', 'Digital');

  // ── Map ───────────────────────────────────────────────────────────────────
  String get searchCollection => _t('Rechercher un point de collecte...', 'Search a collection point...', 'البحث عن نقطة جمع...', 'Buscar punto de recogida...');
  String get directions       => _t('Itinéraire', 'Directions', 'الاتجاهات', 'Cómo llegar');
  String get nearbyPoints     => _t('Points de collecte proches', 'Nearby collection points', 'نقاط الجمع القريبة', 'Puntos de recogida cercanos');

  // ── Scan ──────────────────────────────────────────────────────────────────
  String get centerWaste      => _t('Centrez le déchet dans le cadre', 'Center the waste in the frame', 'ضع النفايات في منتصف الإطار', 'Centra el residuo en el marco');
  String get analyzing        => _t('Analyse en cours...', 'Analyzing...', 'جارٍ التحليل...', 'Analizando...');
  String get gallery          => _t('Galerie', 'Gallery', 'المعرض', 'Galería');
  String get history_         => _t('Historique', 'History', 'السجل', 'Historial');
  String get identified       => _t('Objet identifié !', 'Object identified!', 'تم التعرف على الكائن!', '¡Objeto identificado!');
  String get rescan           => _t('Re-scanner', 'Re-scan', 'إعادة المسح', 'Re-escanear');
  String get viewMap          => _t('Voir carte', 'View map', 'عرض الخريطة', 'Ver mapa');
  String get scanAnalysisLocal => _t('Analyse locale', 'Local analysis', 'تحليل محلي', 'Análisis local');
  String get loadingModel     => _t('Chargement du modèle IA...', 'Loading AI model...', 'جارٍ تحميل نموذج الذكاء الاصطناعي...', 'Cargando modelo IA...');
  String get recyclableDetected => _t('Recyclable détecté !', 'Recyclable detected!', 'تم اكتشاف قابل للتدوير!', '¡Reciclable detectado!');
  String get dangerousWaste   => _t('Déchet dangereux détecté', 'Dangerous waste detected', 'نفايات خطرة مكتشفة', 'Residuo peligroso detectado');
  String get imageLoaded      => _t('Image chargée — appuyez pour analyser', 'Image loaded — tap to analyze', 'تم تحميل الصورة — اضغط للتحليل', 'Imagen cargada — toca para analizar');
  String get noCameraAvailable => _t('Aucune caméra disponible', 'No camera available', 'لا توجد كاميرا متاحة', 'Sin cámara disponible');
  String get modelNotLoaded   => _t('Modèle IA non chargé. Vérifiez l\'installation.',
                                    'AI model not loaded. Check the installation.',
                                    'نموذج الذكاء الاصطناعي غير محمّل. تحقق من التثبيت.',
                                    'Modelo IA no cargado. Verifica la instalación.');
  String get noImageAvailable => _t('Aucune image disponible. Utilisez la caméra ou la galerie.',
                                    'No image available. Use camera or gallery.',
                                    'لا توجد صورة متاحة. استخدم الكاميرا أو المعرض.',
                                    'Sin imagen disponible. Usa la cámara o galería.');
  String get continueBtn      => _t('Continuer', 'Continue', 'متابعة', 'Continuar');
  String get recyclableResult => _t('Objet recyclable !', 'Recyclable object!', 'كائن قابل للتدوير!', '¡Objeto reciclable!');
  String get nonRecyclableResult => _t('Non recyclable', 'Non recyclable', 'غير قابل للتدوير', 'No reciclable');
  String get dangerousResult  => _t('Déchet dangereux', 'Dangerous waste', 'نفايات خطرة', 'Residuo peligroso');
  String get pointsEarnedScan => _t('Points gagnés', 'Points earned', 'النقاط المكتسبة', 'Puntos ganados');
  String get detailsTitle     => _t('Détails de l\'objet', 'Object details', 'تفاصيل الكائن', 'Detalles del objeto');
  String get recyclabilityLevel => _t('Niveau de recyclabilité', 'Recyclability level', 'مستوى قابلية إعادة التدوير', 'Nivel de reciclabilidad');
  String get nearbyCollectionPoints => _t('Points de collecte proches', 'Nearby collection points', 'نقاط الجمع القريبة', 'Puntos de recogida cercanos');
  String get shareResults     => _t('Partager mes résultats', 'Share my results', 'مشاركة نتائجي', 'Compartir mis resultados');
  String get bringToCollection => _t('Apportez ce déchet dans un point de collecte spécifique.',
                                    'Bring this waste to a specific collection point.',
                                    'أحضر هذه النفايات إلى نقطة جمع محددة.',
                                    'Lleva este residuo a un punto de recogida específico.');
  String get recyclableLabel   => _t('RECYCLABLE', 'RECYCLABLE', 'قابل للتدوير', 'RECICLABLE');
  String get dangerousLabel    => _t('DANGEREUX', 'DANGEROUS', 'خطر', 'PELIGROSO');
  String modelLoadError(String e) => _t('Erreur chargement modèle IA : $e',
                                        'AI model load error: $e',
                                        'خطأ في تحميل نموذج الذكاء الاصطناعي: $e',
                                        'Error al cargar el modelo IA: $e');
  String captureError(String e)   => _t('Impossible de capturer la photo : $e',
                                        'Unable to capture photo: $e',
                                        'تعذّر التقاط الصورة: $e',
                                        'No se pudo capturar la foto: $e');
  String analysisError(String e)  => _t('Erreur d\'analyse : $e',
                                        'Analysis error: $e',
                                        'خطأ في التحليل: $e',
                                        'Error de análisis: $e');

  // ── Guide ─────────────────────────────────────────────────────────────────
  String get sortingSubtitle  => _t('Apprenez à trier vos déchets correctement',
                                    'Learn how to sort your waste correctly',
                                    'تعلّم كيفية فرز نفاياتك بشكل صحيح',
                                    'Aprende a clasificar tus residuos correctamente');

  // ── Chat ──────────────────────────────────────────────────────────────────
  String get botGreeting      => _t('Bonjour ! Je suis EcoBot 🌿 Votre assistant de tri intelligent. Comment puis-je vous aider ?',
                                    'Hello! I\'m EcoBot 🌿 Your smart sorting assistant. How can I help you?',
                                    'مرحباً! أنا EcoBot 🌿 مساعدك الذكي للفرز. كيف يمكنني مساعدتك؟',
                                    '¡Hola! Soy EcoBot 🌿 Tu asistente inteligente de reciclaje. ¿Cómo puedo ayudarte?');
  String get typeMessage      => _t('Posez votre question...', 'Ask your question...', 'اطرح سؤالك...', 'Haz tu pregunta...');
  String get online           => _t('En ligne — Assistant IA', 'Online — AI Assistant', 'متصل — مساعد ذكاء اصطناعي', 'En línea — Asistente IA');
  String get onlineShort      => _t('En ligne', 'Online', 'متصل', 'En línea');
  String get newConversation  => _t('Nouvelle conversation', 'New conversation', 'محادثة جديدة', 'Nueva conversación');
  String get chatError        => _t('Désolé, je ne suis pas disponible. Vérifiez votre connexion.',
                                    'Sorry, I\'m not available. Check your connection.',
                                    'عذراً، لست متاحاً. تحقق من اتصالك.',
                                    'Lo siento, no estoy disponible. Verifica tu conexión.');

  // ── Stats ─────────────────────────────────────────────────────────────────
  String get impactSubtitle   => _t('Votre impact environnemental', 'Your environmental impact', 'تأثيرك البيئي', 'Tu impacto ambiental');
  String get byCategory       => _t('Par catégorie', 'By category', 'حسب الفئة', 'Por categoría');
  String get periodWeek       => _t('Semaine', 'Week', 'الأسبوع', 'Semana');
  String get periodMonth      => _t('Mois', 'Month', 'الشهر', 'Mes');
  String get periodYear       => _t('Année', 'Year', 'السنة', 'Año');
  String get recycledLabel    => _t('Recyclé', 'Recycled', 'مُعاد تدويره', 'Reciclado');
  String get co2AvoidedLabel  => _t('CO₂ évité', 'CO₂ avoided', 'CO₂ موفور', 'CO₂ evitado');
  String get sortingRate      => _t('Taux tri', 'Sort rate', 'معدل الفرز', 'Tasa de reciclaje');
  String get kgSorted         => _t('Kg triés', 'Kg sorted', 'كغ مفرزة', 'Kg clasificados');
  String get badgesUnlocked   => _t('Badges débloqués', 'Badges unlocked', 'شارات مفتوحة', 'Insignias desbloqueadas');
  String get badgeFirstScan   => _t('Premier scan', 'First scan', 'أول مسح', 'Primer escaneo');
  String get badge10Scans     => _t('10 scans', '10 scans', '10 مسوحات', '10 escaneos');
  String get badgeEcoWarrior  => _t('Éco-guerrier', 'Eco warrior', 'محارب بيئي', 'Eco guerrero');
  String get badge100pts      => _t('100 pts', '100 pts', '100 نقطة', '100 pts');
  String get badge500pts      => _t('500 pts', '500 pts', '500 نقطة', '500 pts');
  String get badge1kgSorted   => _t('1 kg trié', '1 kg sorted', '1 كغ مفرز', '1 kg clasificado');
  String get badge10kgSorted  => _t('10 kg triés', '10 kg sorted', '10 كغ مفرزة', '10 kg clasificados');
  String badgeObtained(int a, int b) => _t('$a/$b obtenus', '$a/$b obtained', '$a/$b محصّلة', '$a/$b obtenidos');
  String get weeklyLeaderboard => _t('Classement semaine', 'Weekly leaderboard', 'ترتيب الأسبوع', 'Clasificación semanal');
  String get top5             => _t('Top 5', 'Top 5', 'أفضل 5', 'Top 5');

  // ── Leaderboard ───────────────────────────────────────────────────────────
  String get myCity           => _t('Ma Ville', 'My City', 'مدينتي', 'Mi Ciudad');
  String get national         => _t('National', 'National', 'وطني', 'Nacional');
  String get bestEcoCitizens  => _t('Les meilleurs éco-citoyens', 'The best eco-citizens', 'أفضل المواطنين البيئيين', 'Los mejores eco-ciudadanos');
  String get youLabel         => _t('Vous', 'You', 'أنت', 'Tú');

  // ── Waste categories ──────────────────────────────────────────────────────
  String get catPlastic      => _t('Plastique', 'Plastic',     'بلاستيك',     'Plástico');
  String get catGlass        => _t('Verre',     'Glass',       'زجاج',        'Vidrio');
  String get catMetal        => _t('Métal',     'Metal',       'معدن',        'Metal');
  String get catPaper        => _t('Papier',    'Paper',       'ورق',         'Papel');
  String get catCardboard    => _t('Carton',    'Cardboard',   'كرتون',       'Cartón');
  String get catOrganic      => _t('Organique', 'Organic',     'عضوي',        'Orgánico');
  String get treesEquiv      => _t('Arbres éq.', 'Trees equiv.', 'أشجار مكافئة', 'Árboles equiv.');
  String get catElectronic   => _t('Électronique', 'Electronic', 'إلكترونيات', 'Electrónico');
  String get catTrash        => _t('Ordures',   'Trash',       'نفايات',      'Basura');
  String get catDangerous    => _t('Dangereux', 'Dangerous',   'خطرة',        'Peligrosos');
  String get catTextile      => _t('Textile',   'Textile',     'نسيج',        'Textil');
  String get catAll          => _t('Tous',      'All',         'الكل',        'Todo');

  // ── Guide extra ───────────────────────────────────────────────────────────────
  String get navGuide        => _t('Guide',     'Guide',       'الدليل',      'Guía');
  String get guideTabWaste   => _t('Déchets',   'Waste',       'النفايات',    'Residuos');
  String get guideTabTips    => _t('Consignes', 'Tips',        'نصائح',       'Consejos');
  String get searchWaste     => _t('Rechercher un déchet...', 'Search a waste...', 'ابحث عن نفاية...', 'Buscar un residuo...');
  String get noResults       => _t('Aucun résultat trouvé', 'No results found', 'لا توجد نتائج', 'Sin resultados');
  String get statusYes       => _t('OUI',              'YES',            'نعم',         'SÍ');
  String get statusNo        => _t('NON',              'NO',             'لا',          'NO');
  String get statusSpecial   => _t('COLLECTE SPÉCIALE','SPECIAL PICKUP', 'جمع خاص',    'RECOGIDA ESPECIAL');
  String get statusBanned    => _t('INTERDIT',         'BANNED',         'محظور',       'PROHIBIDO');
  String guideWasteCount(int n) => _t('$n déchets', '$n wastes', '$n نفاية', '$n residuos');

  // ── Challenges extra ──────────────────────────────────────────────────────────
  String get challengeTabDaily  => _t('Quotidiens',    'Daily',   'يومية',    'Diarios');
  String get challengeTabWeekly => _t('Hebdomadaires', 'Weekly',  'أسبوعية',  'Semanales');
  String streakDays(int n)      => _t('Série de $n jours !', '$n-day streak!', 'سلسلة $n أيام!', '¡Racha de $n días!');
  String get streakBadge        => _t('Continuez pour débloquer un badge spécial',
                                      'Keep going to unlock a special badge',
                                      'استمر لفتح شارة خاصة',
                                      'Sigue para desbloquear una insignia especial');
  String streakMore(int n)      => _t('$n de plus', '$n more', '$n أكثر', '$n más');
  String get completedLabel     => _t('Complété !', 'Completed!', 'مكتمل!', '¡Completado!');

  // ── Offline ───────────────────────────────────────────────────────────────────
  String get offlineBanner   => _t('Mode hors-ligne — Analyse TFLite locale activée',
                                   'Offline mode — Local TFLite analysis active',
                                   'وضع عدم الاتصال — تحليل TFLite المحلي نشط',
                                   'Modo sin conexión — Análisis TFLite local activo');

  // ── Settings extra ────────────────────────────────────────────────────────────
  String get menuEditProfile    => _t('Modifier le profil', 'Edit profile', 'تعديل الملف الشخصي', 'Editar perfil');
  String get account            => _t('Compte', 'Account', 'الحساب', 'Cuenta');
  String get shareApp           => _t('Partager l\'application', 'Share the app', 'مشاركة التطبيق', 'Compartir la app');
  String get shareAppDesc       => _t('Invitez vos amis à rejoindre EcoScan', 'Invite friends to join EcoScan', 'ادعُ أصدقاءك للانضمام إلى EcoScan', 'Invita a tus amigos a EcoScan');
  String get clearHistory       => _t('Effacer l\'historique', 'Clear history', 'مسح السجل', 'Borrar historial');
  String get clearHistoryDesc   => _t('Supprimer tous les scans sauvegardés', 'Delete all saved scans', 'حذف جميع المسوحات المحفوظة', 'Eliminar todos los escaneos');
  String get clearHistoryConfirm => _t('Supprimer tout l\'historique de scan ?', 'Delete all scan history?', 'حذف كل سجل المسح؟', '¿Borrar todo el historial de escaneo?');
  String get clearDone          => _t('Historique effacé', 'History cleared', 'تم مسح السجل', 'Historial borrado');
  String get feedbackEmail      => _t('Envoyer un retour', 'Send feedback', 'إرسال ملاحظات', 'Enviar comentarios');
  String get feedbackDesc       => _t('Signaler un bug ou suggérer une amélioration', 'Report a bug or suggest an improvement', 'الإبلاغ عن خطأ أو اقتراح تحسين', 'Reportar error o sugerir mejora');
  String get tools              => _t('Outils', 'Tools', 'الأدوات', 'Herramientas');

  // ── Guide Consignes tab ───────────────────────────────────────────────────────
  String get quickAccess        => _t('Accès rapide', 'Quick access', 'وصول سريع', 'Acceso rápido');
  String get guideSortingBins   => _t('Bacs de tri', 'Sorting bins', 'حاويات الفرز', 'Contenedores');
  String get guideLegalFrame    => _t('Cadre légal', 'Legal', 'القانوني', 'Legal');
  String get guideEcoImpact     => _t('Impact éco', 'Eco impact', 'تأثير بيئي', 'Impacto eco');
  String get guideOperators     => _t('Opérateurs', 'Operators', 'مشغلون', 'Operadores');
  String get guideGoldenRules   => _t('Règles d\'or', 'Golden rules', 'قواعد ذهبية', 'Reglas de oro');
  String get guideContacts      => _t('Contacts', 'Contacts', 'جهات اتصال', 'Contactos');

  String get guideSortingBinsSection => _t('Bacs de tri au Maroc', 'Sorting bins in Morocco', 'حاويات الفرز في المغرب', 'Contenedores en Marruecos');
  String get guideLegalSection       => _t('Cadre légal marocain', 'Moroccan legal framework', 'الإطار القانوني المغربي', 'Marco legal marroquí');
  String get guideOperatorsSection   => _t('Opérateurs & contacts', 'Operators & contacts', 'المشغلون وجهات الاتصال', 'Operadores y contactos');
  String get guideGoldenRulesSection => _t('Règles d\'or du tri', 'Golden rules of sorting', 'القواعد الذهبية للفرز', 'Reglas de oro del reciclaje');
  String get guideImpactSection      => _t('Impact environnemental', 'Environmental impact', 'التأثير البيئي', 'Impacto ambiental');

  String get guideSortingBinsSubtitle   => _t('Au Maroc — ECOVAL et collectes locales', 'In Morocco — ECOVAL and local collections', 'في المغرب — ECOVAL والجمع المحلي', 'En Marruecos — ECOVAL y recogidas locales');
  String get guideLegalSubtitle         => _t('Lois et réglementations marocaines', 'Moroccan laws and regulations', 'القوانين واللوائح المغربية', 'Leyes y reglamentos marroquíes');
  String get guideEcoImpactSubtitle     => _t('CO₂ économisé · Énergie · Décomposition', 'CO₂ saved · Energy · Decomposition', 'ثاني أكسيد الكربون الموفر · الطاقة · التحلل', 'CO₂ ahorrado · Energía · Descomposición');
  String get guideOperatorsSubtitle     => _t('Entreprises, régies et associations', 'Companies, agencies and associations', 'شركات ووكالات وجمعيات', 'Empresas, agencias y asociaciones');
  String get guideGoldenRulesSubtitle   => _t('Les bons gestes du tri', 'Good sorting practices', 'الممارسات الجيدة للفرز', 'Buenas prácticas');
  String get guideContactsSubtitle      => _t('Opérateurs et services utiles', 'Operators and useful services', 'المشغلون والخدمات المفيدة', 'Operadores y servicios útiles');
  String get guideNatOperators          => _t('Opérateurs Nationaux (présence multi-régions)', 'National Operators (multi-region)', 'المشغلون الوطنيون (متعدد الأقاليم)', 'Operadores Nacionales (multi-regional)');
  String get guideRegDir               => _t('Répertoire par Région Administrative', 'Directory by Administrative Region', 'دليل حسب الجهة الإدارية', 'Directorio por Región Administrativa');
  String get guideLegalBanner          => _t('Le Maroc dispose d\'un cadre légal complet pour la gestion des déchets. Le non-respect de ces lois expose à des sanctions pénales et financières.', 'Morocco has a comprehensive legal framework for waste management. Non-compliance with these laws exposes you to criminal and financial penalties.', 'يتوفر المغرب على إطار قانوني شامل لتدبير النفايات. عدم الامتثال لهذه القوانين يعرض للعقوبات الجنائية والمالية.', 'Marruecos dispone de un marco legal completo para la gestión de residuos. El incumplimiento de estas leyes expone a sanciones penales y económicas.');
  String get guideSanctionsHeader      => _t('Infractions & Sanctions (Loi 28-00 — mise à jour Décret 2020)', 'Offences & Penalties (Law 28-00 — updated Decree 2020)', 'المخالفات والعقوبات (القانون 28-00 — المحدَّث بمرسوم 2020)', 'Infracciones y Sanciones (Ley 28-00 — actualización Decreto 2020)');
  String get guideMoroccanStandards     => _t('Normes Marocaines (NM) applicables', 'Applicable Moroccan Standards (NM)', 'المعايير المغربية (NM) المعمول بها', 'Normas Marroquíes (NM) aplicables');
  String get guideImpactPositive        => _t('Impact positif', 'Positive impact', 'تأثير إيجابي', 'Impacto positivo');
  String get guideIfNotRecycled         => _t('Si non recyclé', 'If not recycled', 'إذا لم يُعاد تدويره', 'Si no se recicla');
  String get guideDecompLabel           => _t('Décomposition', 'Decomposition', 'وقت التحلل', 'Descomposición');

  // ── Auth hints ────────────────────────────────────────────────────────────────
  String get hintFirstName      => _t('Fatima', 'Fatima', 'فاطمة', 'Fátima');
  String get hintLastName       => _t('Benali', 'Benali', 'بناني', 'Benali');
  String get hintCity           => _t('Ex : Casablanca', 'E.g. Casablanca', 'مثال: الدار البيضاء', 'Ej.: Casablanca');
  String get hintEmail          => _t('exemple@email.com', 'example@email.com', 'مثال@بريد.com', 'ejemplo@email.com');
  String get guideOrganicFact => _t(
    'Si tous les Marocains triaient leurs déchets organiques (65% du volume), le Maroc pourrait réduire ses émissions de méthane de 30% — l\'équivalent de retirer 500 000 voitures de la route.',
    'If all Moroccans sorted their organic waste (65% of volume), Morocco could reduce methane emissions by 30% — equivalent to removing 500,000 cars from the road.',
    'لو فرز جميع المغاربة نفاياتهم العضوية (65% من الحجم)، يمكن للمغرب تقليل انبعاثات الميثان بنسبة 30% — ما يعادل إزالة 500,000 سيارة من الطرق.',
    'Si todos los marroquíes clasificaran sus residuos orgánicos (65% del volumen), Marruecos podría reducir las emisiones de metano un 30% — equivalente a retirar 500.000 coches de la carretera.',
  );
  // ── Onboarding ────────────────────────────────────────────────────────────────
  String get startBtn      => _t('Commencer',        'Get started',     'ابدأ',         'Empezar');
  String get nextBtn       => _t('Suivant',           'Next',            'التالي',       'Siguiente');
  String get skipBtn       => _t('Passer',            'Skip',            'تخطي',         'Omitir');
  String get answerFirst   => _t('Répondre d\'abord', 'Answer first',    'أجب أولاً',   'Responde primero');
  String get validateBtn   => _t('Valider',           'Validate',        'تأكيد',        'Validar');

  String get obTitle1      => _t('Scannez & Identifiez', 'Scan & Identify', 'امسح واعرف', 'Escanea e Identifica');
  String get obSubtitle1   => _t(
    'Photographiez n\'importe quel déchet et notre IA l\'identifie instantanément pour vous indiquer la bonne poubelle.',
    'Photograph any waste item and our AI instantly identifies it to tell you the right bin.',
    'صوّر أي نفاية وستحددها الذكاء الاصطناعي فوراً لتخبرك بالحاوية الصحيحة.',
    'Fotografía cualquier residuo y nuestra IA lo identifica al instante para indicarte el contenedor correcto.',
  );
  String get obTitle2      => _t('Les 6 Catégories',   'The 6 Categories',  'الفئات الست',        'Las 6 Categorías');
  String get obSubtitle2   => _t(
    'Apprenez les 6 grandes familles de déchets pour bien trier.',
    'Learn the 6 main waste families to sort correctly.',
    'تعرّف على الفئات الست الرئيسية للنفايات للفرز الصحيح.',
    'Aprende las 6 grandes familias de residuos para clasificar correctamente.',
  );
  String get obTitle3      => _t('Gagnez des Récompenses', 'Earn Rewards', 'اكسب المكافآت', 'Gana Recompensas');
  String get obSubtitle3   => _t(
    'Chaque action éco-responsable vous rapporte des points. Grimpez dans le classement et débloquez des badges exclusifs.',
    'Every eco-responsible action earns you points. Climb the rankings and unlock exclusive badges.',
    'كل فعل بيئي مسؤول يمنحك نقاطاً. ارتقِ في التصنيف وافتح شارات حصرية.',
    'Cada acción eco-responsable te da puntos. Sube en el ranking y desbloquea insignias exclusivas.',
  );
  String get obTitle4      => _t('Quiz Rapide',         'Quick Quiz',        'اختبار سريع',        'Quiz Rápido');
  String get obSubtitle4   => _t(
    'Testez vos connaissances avant de commencer !',
    'Test your knowledge before you start!',
    'اختبر معلوماتك قبل البدء!',
    '¡Pon a prueba tus conocimientos antes de empezar!',
  );
  String get catDeee        => _t('DEEE', 'WEEE', 'نفايات إلكترونية', 'RAEE');
  String get binYellow      => _t('Bac jaune', 'Yellow bin', 'الحاوية الصفراء', 'Contenedor amarillo');
  String get binGreen       => _t('Bac vert', 'Green bin', 'الحاوية الخضراء', 'Contenedor verde');
  String get binBlue        => _t('Bac bleu', 'Blue bin', 'الحاوية الزرقاء', 'Contenedor azul');
  String get binBlack       => _t('Bac noir', 'Black bin', 'الحاوية السوداء', 'Contenedor negro');
  String get collectPoint   => _t('Point collecte', 'Collection point', 'نقطة جمع', 'Punto de recogida');
  String get obQuizQuestion => _t(
    'Dans quel bac met-on une bouteille en verre ?',
    'Which bin should a glass bottle go in?',
    'في أي حاوية توضع زجاجة الزجاج؟',
    '¿En qué contenedor va una botella de vidrio?',
  );
  String get obQuizCorrect  => _t(
    'Bravo ! Le verre va bien dans le bac vert.',
    'Well done! Glass goes in the green bin.',
    'أحسنت! الزجاج يذهب إلى الحاوية الخضراء.',
    '¡Bien hecho! El vidrio va en el contenedor verde.',
  );
  String get obQuizWrong    => _t(
    'Pas tout à fait ! Le verre va dans le bac vert.',
    'Not quite! Glass goes in the green bin.',
    'ليس تماماً! الزجاج يذهب إلى الحاوية الخضراء.',
    '¡No del todo! El vidrio va en el contenedor verde.',
  );

  // ── Scan Result ────────────────────────────────────────────────────────────
  String get scanResultTitle     => _t('Résultat du scan',      'Scan result',           'نتيجة الفحص',              'Resultado del escaneo');
  String get heroDangerous       => _t('⚠️ Déchet dangereux',   '⚠️ Dangerous waste',    '⚠️ نفاية خطرة',            '⚠️ Residuo peligroso');
  String get heroRecyclable      => _t('✅ Objet recyclable !',  '✅ Recyclable item!',   '✅ عنصر قابل للتدوير!',    '✅ ¡Artículo reciclable!');
  String get heroNotRecyclable   => _t('❌ Non recyclable',      '❌ Not recyclable',     '❌ غير قابل للتدوير',       '❌ No reciclable');
  String get modeCloud           => _t('Identifié par YOLOv8 Cloud (97% confiance)',  'Identified by YOLOv8 Cloud (97% confidence)',  'تم التعرف بواسطة YOLOv8 Cloud (دقة 97%)',    'Identificado por YOLOv8 Cloud (97% confianza)');
  String get modeLocal           => _t('Identifié par TFLite Local (hors-ligne)',      'Identified by TFLite Local (offline)',         'تم التعرف بواسطة TFLite المحلي (بدون اتصال)', 'Identificado por TFLite Local (sin conexión)');
  String get levelExcellent      => _t('🌿 Excellent',           '🌿 Excellent',          '🌿 ممتاز',                  '🌿 Excelente');
  String get levelAcceptable     => _t('♻️ Acceptable',          '♻️ Acceptable',         '♻️ مقبول',                  '♻️ Aceptable');
  String get levelLow            => _t('⚠️ Faible',              '⚠️ Low',                '⚠️ منخفض',                  '⚠️ Bajo');
  String get co2SavedLabel       => _t('CO₂ économisé',          'CO₂ saved',             'ثاني أكسيد الكربون الموفَّر', 'CO₂ ahorrado');
  String get itemDetails         => _t('Détails de l\'objet',    'Item details',          'تفاصيل العنصر',             'Detalles del artículo');
  String get labelType           => _t('Type',                   'Type',                  'النوع',                     'Tipo');
  String get labelRecyclable     => _t('Recyclable',             'Recyclable',            'قابل للتدوير',               'Reciclable');
  String get valueYes            => _t('Oui ✓',                  'Yes ✓',                 'نعم ✓',                     'Sí ✓');
  String get valueNo             => _t('Non ✗',                  'No ✗',                  'لا ✗',                      'No ✗');
  String get sortingInstruction  => _t('Consigne de tri',         'Sorting instruction',   'تعليمات الفرز',             'Instrucción de clasificación');
  String get binLabel            => _t('Bac',                    'Bin',                   'حاوية',                     'Contenedor');
  String get aiConfidence        => _t('Confiance IA',           'AI Confidence',         'دقة الذكاء الاصطناعي',      'Confianza IA');
  String get attentionLabel      => _t('⚠️ Attention',           '⚠️ Warning',            '⚠️ تنبيه',                  '⚠️ Atención');
  String get bringToPoint        => _t('Apportez ce déchet dans un point de collecte spécifique.', 'Bring this waste to a specific collection point.', 'أحضر هذه النفاية إلى نقطة جمع محددة.', 'Lleva este residuo a un punto de recogida específico.');
  String binInstruction(String name, String bin) => _t(
    'Déposez $name dans le bac ${bin.toLowerCase()}. Pensez à le rincer avant.',
    'Place $name in the ${bin.toLowerCase()} bin. Remember to rinse it first.',
    'ضع $name في الحاوية ${bin.toLowerCase()}. تذكر شطفه أولاً.',
    'Deposita $name en el contenedor ${bin.toLowerCase()}. Recuerda enjuagarlo primero.',
  );
  String shareText(String name, bool recyclable, int recyclability, int co2, int pts) => _t(
    '🌿 J\'ai scanné "$name" avec EcoScan !\n♻️ ${recyclable ? "Recyclable" : "Non recyclable"} — $recyclability% recyclabilité\n💚 CO₂ économisé : $co2 g\n⭐ +$pts pts gagnés\n\n#EcoScan #Recyclage #EcoResponsable',
    '🌿 I scanned "$name" with EcoScan!\n♻️ ${recyclable ? "Recyclable" : "Not recyclable"} — $recyclability% recyclability\n💚 CO₂ saved: $co2 g\n⭐ +$pts pts earned\n\n#EcoScan #Recycling #EcoResponsible',
    '🌿 فحصت "$name" باستخدام EcoScan!\n♻️ ${recyclable ? "قابل لإعادة التدوير" : "غير قابل لإعادة التدوير"} — $recyclability% قابلية\n💚 CO₂ موفَّر: $co2 g\n⭐ +$pts نقطة\n\n#EcoScan #إعادة_التدوير',
    '🌿 Escaneé "$name" con EcoScan!\n♻️ ${recyclable ? "Reciclable" : "No reciclable"} — $recyclability% reciclabilidad\n💚 CO₂ ahorrado: $co2 g\n⭐ +$pts pts ganados\n\n#EcoScan #Reciclaje #EcoResponsable',
  );

  String get guidePlasticBanFact => _t(
    'Le Maroc a interdit les sacs plastique en 2016 — l\'une des premières lois anti-plastique au monde (Loi 77-15). Contribuez : utilisez toujours un sac en tissu ou un panier.',
    'Morocco banned plastic bags in 2016 — one of the world\'s first anti-plastic laws (Law 77-15). Contribute: always use a fabric bag or basket.',
    'حظر المغرب الأكياس البلاستيكية عام 2016 — من أوائل القوانين المناهضة للبلاستيك في العالم (القانون 77-15). ساهم: استخدم دائماً حقيبة قماشية أو سلة.',
    'Marruecos prohibió las bolsas de plástico en 2016 — una de las primeras leyes anti-plástico del mundo (Ley 77-15). Contribuye: usa siempre una bolsa de tela o una cesta.',
  );
}
