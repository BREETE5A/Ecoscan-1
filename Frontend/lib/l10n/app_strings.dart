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
  String get navHome        => _t('Accueil',     'Home',        'الرئيسية',    'Inicio');
  String get navMap         => _t('Carte',       'Map',         'الخريطة',     'Mapa');
  String get navScan        => _t('Scanner',     'Scan',        'مسح',         'Escanear');
  String get navChat        => _t('Assistant',   'Assistant',   'المساعد',     'Asistente');
  String get navProfile     => _t('Profil',      'Profile',     'الملف',       'Perfil');
  String get navMarketplace => _t('Marché',      'Market',      'السوق',       'Mercado');

  // ── Marketplace ──────────────────────────────────────────────────────────
  String get marketplaceTitle    => _t('Éco-Marché', 'Eco-Market', 'السوق البيئي', 'Eco-Mercado');
  String get marketplaceSub      => _t('Donnez, vendez ou échangez vos objets recyclables',
                                       'Give, sell or exchange your recyclable items',
                                       'تبرع أو بيع أو بادل مواد قابلة لإعادة التدوير',
                                       'Dona, vende o intercambia tus artículos reciclables');
  String get addListing          => _t('Publier une annonce', 'Post an ad', 'نشر إعلان', 'Publicar anuncio');
  String get listingTypeDon      => _t('Don',    'Free',     'تبرع',   'Donación');
  String get listingTypeVente    => _t('Vente',  'Sale',     'بيع',    'Venta');
  String get listingTypeEchange  => _t('Échange','Swap',     'مبادلة', 'Intercambio');
  String get listingTitle        => _t('Titre',  'Title',    'العنوان','Título');
  String get listingDesc         => _t('Description', 'Description', 'الوصف', 'Descripción');
  String get listingPrice        => _t('Prix (DH)', 'Price (MAD)', 'السعر (درهم)', 'Precio (MAD)');
  String get listingCity         => _t('Ville',  'City',     'المدينة','Ciudad');
  String get listingPhone        => _t('Téléphone', 'Phone', 'الهاتف', 'Teléfono');
  String get listingWhatsapp     => _t('WhatsApp', 'WhatsApp', 'واتساب', 'WhatsApp');
  String get listingCategory     => _t('Catégorie', 'Category', 'الفئة', 'Categoría');
  String get callSeller          => _t('Appeler', 'Call', 'اتصال', 'Llamar');
  String get whatsappSeller      => _t('WhatsApp', 'WhatsApp', 'واتساب', 'WhatsApp');
  String get deleteAd            => _t('Supprimer', 'Delete', 'حذف', 'Eliminar');
  String get myAds               => _t('Mes annonces', 'My ads', 'إعلاناتي', 'Mis anuncios');
  String get publishAd           => _t('Publier', 'Publish', 'نشر', 'Publicar');
  String get freeLabel           => _t('Gratuit', 'Free', 'مجاني', 'Gratis');
  String get swapLabel           => _t('Échange', 'Swap', 'مبادلة', 'Intercambio');
  String get contactSeller       => _t('Contacter le vendeur', 'Contact seller', 'اتصل بالبائع', 'Contactar vendedor');
  String get noListings          => _t('Aucune annonce pour le moment.\nSoyez le premier à publier !',
                                       'No ads yet.\nBe the first to post!',
                                       'لا إعلانات حتى الآن.\nكن أول من ينشر!',
                                       'Sin anuncios aún.\n¡Sé el primero!');
  String get addPhoto            => _t('Ajouter une photo', 'Add a photo', 'إضافة صورة', 'Agregar foto');
  String get confirmDelete       => _t('Supprimer cette annonce ?', 'Delete this ad?', 'حذف هذا الإعلان؟', '¿Eliminar este anuncio?');
  // Recherche & badges
  String get searchHint          => _t('Rechercher titre, catégorie, ville…', 'Search title, category, city…', 'ابحث بالعنوان أو الفئة أو المدينة…', 'Buscar título, categoría, ciudad…');
  String get trustedLabel        => _t('Fiable', 'Trusted', 'موثوق', 'Fiable');
  String get trustedSellerLabel  => _t('✓ Vendeur fiable', '✓ Trusted seller', '✓ بائع موثوق', '✓ Vendedor fiable');
  // Photos
  String get cameraLabel         => _t('Caméra', 'Camera', 'الكاميرا', 'Cámara');
  String get galleryMultiple     => _t('Galerie (plusieurs)', 'Gallery (multiple)', 'المعرض (متعدد)', 'Galería (múltiple)');
  // EcoPoints
  String get ecoPointsDon       => _t('+15 EcoPoints pour ce don ! 🌿', '+15 EcoPoints for this donation! 🌿', '+15 نقطة EcoPoints لهذه التبرع! 🌿', '+15 EcoPoints por esta donación! 🌿');
  String ecoPointsAd(int pts)   => _t('+$pts EcoPoints pour cette annonce 🌿', '+$pts EcoPoints for this ad 🌿', '+$pts نقطة EcoPoints لهذا الإعلان 🌿', '+$pts EcoPoints por este anuncio 🌿');
  String listingPublished(int pts) => _t('Annonce publiée ! +$pts pts EcoPoints 🌿', 'Ad published! +$pts EcoPoints 🌿', 'تم نشر الإعلان! +$pts نقطة EcoPoints 🌿', '¡Anuncio publicado! +$pts EcoPoints 🌿');
  // Avis
  String get leaveReview         => _t('Laisser un avis', 'Leave a review', 'اترك تقييماً', 'Dejar una reseña');
  String reviewsCount(int n)     => _t('Avis ($n)', 'Reviews ($n)', 'التقييمات ($n)', 'Reseñas ($n)');
  String reviewCountSuffix(int n)=> _t(' ($n avis)', ' ($n reviews)', ' ($n تقييم)', ' ($n reseñas)');
  String get commentHint         => _t('Votre commentaire (optionnel)', 'Your comment (optional)', 'تعليقك (اختياري)', 'Tu comentario (opcional)');
  String get publishReview       => _t('Publier l\'avis', 'Publish review', 'نشر التقييم', 'Publicar reseña');
  String get reviewPublished     => _t('Avis publié ! ⭐', 'Review published! ⭐', 'تم نشر التقييم! ⭐', '¡Reseña publicada! ⭐');
  // WhatsApp
  String whatsappInterest(String title) => _t('Bonjour, je suis intéressé(e) par : $title', 'Hello, I\'m interested in: $title', 'مرحباً، أنا مهتم بـ: $title', 'Hola, estoy interesado/a en: $title');
  // Tri & filtres
  String get sortRecent         => _t('Récent',    'Recent',   'الأحدث',  'Reciente');
  String get sortPriceAsc       => _t('Prix ↑',    'Price ↑',  'السعر ↑', 'Precio ↑');
  String get sortDistance       => _t('Distance',  'Distance', 'المسافة', 'Distancia');
  String get filterByCity       => _t('Filtrer par ville', 'Filter by city', 'تصفية حسب المدينة', 'Filtrar por ciudad');
  String get searchCityHint     => _t('Rechercher une ville…', 'Search a city…', 'ابحث عن مدينة…', 'Buscar una ciudad…');
  String get showAll            => _t('Tout afficher', 'Show all', 'عرض الكل', 'Mostrar todo');
  // Formulaire annonce
  String get countryCodeLabel   => _t('Indicatif pays', 'Country code', 'مفتاح البلد', 'Código de país');
  String get cityRequiredErr    => _t('Ville requise', 'City required', 'المدينة مطلوبة', 'Ciudad requerida');
  String get phoneRequiredErr   => _t('Téléphone requis', 'Phone required', 'الهاتف مطلوب', 'Teléfono requerido');
  String get phone9DigitsErr    => _t('Entrez exactement 9 chiffres', 'Enter exactly 9 digits', 'أدخل 9 أرقام بالضبط', 'Introduce exactamente 9 dígitos');

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
  String get ecoHeaderQuote  => _t(
    '🌿 La nature est un trésor fragile — chaque geste compte.',
    '🌿 Nature is a fragile treasure — every action matters.',
    '🌿 الطبيعة كنز هش — كل تصرف له أثره.',
    '🌿 La naturaleza es un tesoro frágil — cada gesto cuenta.');
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
  String challengeProgressOf(int done, int total) => _t(
    '$done sur $total complété',
    '$done of $total completed',
    '$done من $total مكتمل',
    '$done de $total completado',
  );
  String communityLevelPct(int pct) => _t(
    '$pct% vers le prochain niveau communautaire',
    '$pct% towards next community level',
    '$pct% نحو المستوى المجتمعي التالي',
    '$pct% hacia el próximo nivel comunitario',
  );
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
  String get qaAirQuality    => _t('Qualité de l\'air', 'Air quality',    'جودة الهواء',       'Calidad del aire');
  String get qaWaterFootprint=> _t('Empreinte eau',     'Water footprint', 'بصمة الماء',        'Huella hídrica');
  String get qaWeather       => _t('Météo',             'Weather',         'الطقس',             'Clima');
  String get qaQuiz          => _t('Quiz recyclage',    'Recycling quiz',  'اختبار التدوير',    'Quiz de reciclaje');
  String get qaBarcode       => _t('Code-barres',       'Barcode',         'الرمز الشريطي',     'Código de barras');

  // ── Weather ───────────────────────────────────────────────────────────────
  String get weatherTitle        => _t('Météo Éco',                    'Eco Weather',              'الطقس البيئي',                  'Clima Eco');
  String get weatherLoadError    => _t('Impossible de charger la météo','Cannot load weather',      'تعذّر تحميل الطقس',              'No se pudo cargar el tiempo');
  String get weatherHumidity     => _t('Humidité',                     'Humidity',                 'رطوبة',                          'Humedad');
  String get weatherWind         => _t('Vent',                         'Wind',                     'رياح',                           'Viento');
  String get weatherEcoTipsTitle => _t('Conseils éco du jour',         'Eco Tips',                 'نصائح بيئية',                   'Consejos eco del día');
  String get weatherHydTitle     => _t('💧 Hydratation du jour',       '💧 Daily Hydration',       '💧 الترطيب اليومي',             '💧 Hidratación diaria');
  String weatherHydMsg(int temp, int liters) => _t(
    'Par $temp°C, buvez au moins $liters litres d\'eau aujourd\'hui.',
    'At $temp°C, drink at least $liters liters of water today.',
    'بدرجة حرارة $temp°C، اشرب $liters لترات على الأقل من الماء اليوم.',
    'Con $temp°C, bebe al menos $liters litros de agua hoy.',
  );

  // ── Eco-tips météo — 7 catégories selon température + condition ─────────────

  // < 5°C — Très froid
  List<String> get weatherTipsVeryCold { switch (_locale) {
    case 'en': return ['Avoid using diesel heaters — prefer electric or gas', 'Insulate your home well to save energy', 'Choose public transport — engines pollute more in cold weather'];
    case 'ar': return ['تجنب المدافئ الديزل — يُفضَّل الكهربائي أو الغاز', 'عازل منزلك جيداً لتوفير الطاقة', 'فضّل وسائل النقل العام — المحركات تلوث أكثر في البرد'];
    case 'es': return ['Evita calefactores de gasóleo — prefiere eléctrico o gas', 'Aísla bien tu hogar para ahorrar energía', 'Elige transporte público — los motores contaminan más con frío'];
    default:   return ['Évitez les chauffages au fioul — préférez l\'électrique ou le gaz', 'Isolez bien votre logement pour économiser l\'énergie', 'Choisissez les transports en commun — les moteurs polluent plus par le froid'];
  }}

  // 5–15°C — Frais
  List<String> get weatherTipsCold { switch (_locale) {
    case 'en': return ['Good weather to air out your home without heating', 'Wear layers to avoid overheating — saves energy', 'Day suitable for composting outdoors'];
    case 'ar': return ['طقس مناسب لتهوية منزلك دون تدفئة', 'ارتدِ طبقات لتجنب التدفئة الزائدة — يوفر الطاقة', 'يوم مناسب للتسميد في الخارج'];
    case 'es': return ['Buen tiempo para ventilar tu hogar sin calefacción', 'Viste en capas para evitar sobrecalentar — ahorra energía', 'Día adecuado para compostar en exterior'];
    default:   return ['Beau temps pour aérer votre logement sans chauffer', 'Portez des couches pour éviter de surchauffer — ça économise l\'énergie', 'Journée propice au compostage en extérieur'];
  }}

  // 15–25°C — Agréable
  List<String> get weatherTipsMild { switch (_locale) {
    case 'en': return ['Perfect day to walk or cycle instead of driving', 'Choose local seasonal products to reduce your carbon footprint', 'Keep up your daily recycling and sorting habits'];
    case 'ar': return ['يوم مثالي للمشي أو ركوب الدراجة عوضاً عن السيارة', 'اختر المنتجات المحلية الموسمية لتقليل بصمتك الكربونية', 'استمر في عادات فرز النفايات اليومية'];
    case 'es': return ['Día perfecto para caminar o ir en bici en lugar de conducir', 'Elige productos locales de temporada para reducir tu huella', 'Mantén tus hábitos diarios de clasificación de residuos'];
    default:   return ['Journée idéale pour marcher ou vélo plutôt que prendre la voiture', 'Choisissez des produits locaux de saison pour réduire votre empreinte', 'Continuez vos bonnes habitudes quotidiennes de tri'];
  }}

  // 25–35°C — Chaud
  List<String> get weatherTipsWarm { switch (_locale) {
    case 'en': return ['Water your garden in the evening to reduce evaporation', 'Avoid outdoor burning — heat concentrates pollutants', 'Use public transport or cycle to limit urban heat islands'];
    case 'ar': return ['اسقِ حديقتك مساءً لتقليل التبخر', 'تجنب الحرق الخارجي — الحرارة تركز الملوثات', 'استخدم وسائل النقل العام أو الدراجة للحد من جزر الحرارة الحضرية'];
    case 'es': return ['Riega tu jardín por la tarde para reducir la evaporación', 'Evita quemas al aire libre — el calor concentra contaminantes', 'Usa transporte público o bici para limitar islas de calor urbano'];
    default:   return ['Arrosez votre jardin le soir pour réduire l\'évaporation', 'Évitez les brûlages extérieurs — la chaleur concentre les polluants', 'Utilisez les transports en commun ou le vélo pour limiter les îlots de chaleur'];
  }}

  // > 35°C — Très chaud
  List<String> get weatherTipsHot { switch (_locale) {
    case 'en': return ['Never burn waste — extreme heat makes pollution extremely dangerous', 'Water plants early morning or late evening only', 'Limit car use — engines are major heat sources in cities', 'Drink water from a reusable bottle — avoid single-use plastic'];
    case 'ar': return ['لا تحرق النفايات أبداً — الحر الشديد يجعل التلوث خطيراً للغاية', 'اسقِ النباتات فقط صباحاً باكراً أو مساءً متأخراً', 'قلّل من استخدام السيارة — المحركات مصدر رئيسي للحرارة في المدن', 'اشرب الماء من زجاجة قابلة لإعادة الاستخدام — تجنب البلاستيك أحادي الاستخدام'];
    case 'es': return ['Nunca quemes residuos — el calor extremo hace la contaminación muy peligrosa', 'Riega plantas solo de madrugada o al anochecer', 'Limita el uso del coche — los motores son fuentes de calor en ciudades', 'Bebe agua en botella reutilizable — evita el plástico de un solo uso'];
    default:   return ['Ne brûlez jamais de déchets — la chaleur extrême rend la pollution très dangereuse', 'Arrosez les plantes uniquement tôt le matin ou tard le soir', 'Limitez la voiture — les moteurs sont une source majeure de chaleur en ville', 'Buvez l\'eau dans une gourde réutilisable — évitez le plastique à usage unique'];
  }}

  // Pluie
  List<String> get weatherTipsRainy { switch (_locale) {
    case 'en': return ['Collect rainwater to water your garden', 'Avoid pesticides — rain washes them into groundwater', 'Good day for indoor composting or sorting recycling'];
    case 'ar': return ['اجمع مياه الأمطار لسقي حديقتك', 'تجنب المبيدات — المطر يجرفها إلى المياه الجوفية', 'يوم جيد للتسميد الداخلي أو فرز النفايات'];
    case 'es': return ['Recoge agua de lluvia para regar tu jardín', 'Evita pesticidas — la lluvia los arrastra a las aguas subterráneas', 'Buen día para compostar en interior o clasificar reciclaje'];
    default:   return ['Récupérez l\'eau de pluie pour arroser votre jardin', 'Évitez les pesticides — la pluie les entraîne dans les nappes phréatiques', 'Bonne journée pour composter à l\'intérieur ou trier vos recyclables'];
  }}

  // Orage
  List<String> get weatherTipsStormy { switch (_locale) {
    case 'en': return ['Stay indoors — lightning is dangerous near water or open areas', 'Unplug appliances to save energy during the storm', 'After the storm, check for waste blown into nature and pick it up'];
    case 'ar': return ['ابقَ في المنزل — البرق خطير بالقرب من المياه أو المناطق المفتوحة', 'افصل الأجهزة الكهربائية لتوفير الطاقة خلال العاصفة', 'بعد العاصفة، تحقق من النفايات المبعثرة في الطبيعة وانقلها'];
    case 'es': return ['Quédate en casa — los rayos son peligrosos cerca del agua o espacios abiertos', 'Desenchufa aparatos para ahorrar energía durante la tormenta', 'Tras la tormenta, recoge residuos arrastrados a la naturaleza'];
    default:   return ['Restez chez vous — la foudre est dangereuse près de l\'eau ou en plein air', 'Débranchez les appareils pour économiser l\'énergie pendant la tempête', 'Après l\'orage, ramassez les déchets dispersés dans la nature'];
  }}

  // Neige
  List<String> get weatherTipsSnow { switch (_locale) {
    case 'en': return ['Avoid rock salt on paths — it damages soil and water', 'Do not burn waste to heat yourself — inhaling smoke is dangerous', 'Use an eco-friendly snow-melt product or plain hot water'];
    case 'ar': return ['تجنب ملح الصخر على الممرات — يضر التربة والمياه', 'لا تحرق النفايات لتدفئة نفسك — استنشاق الدخان خطير', 'استخدم منتجاً صديقاً للبيئة لإذابة الجليد أو الماء الساخن العادي'];
    case 'es': return ['Evita la sal de roca en los caminos — daña el suelo y el agua', 'No quemes residuos para calentarte — inhalar humo es peligroso', 'Usa un producto fundanieve ecológico o simplemente agua caliente'];
    default:   return ['Évitez le sel de déneigement sur les chemins — il abîme les sols et l\'eau', 'Ne brûlez pas de déchets pour vous chauffer — inhaler la fumée est dangereux', 'Utilisez un produit déverglaçant écologique ou simplement de l\'eau chaude'];
  }}

  // Brouillard / Nuages
  List<String> get weatherTipsMist { switch (_locale) {
    case 'en': return ['Reduce car speed and prefer public transport on foggy days', 'Fog can trap air pollution — avoid strenuous outdoor activity', 'Good day for indoor eco activities: sorting, composting, repairing'];
    case 'ar': return ['قلل سرعة السيارة وفضّل النقل العام في أيام الضباب', 'الضباب يحجز تلوث الهواء — تجنب الأنشطة الخارجية المكثفة', 'يوم جيد للأنشطة البيئية الداخلية: الفرز والتسميد والإصلاح'];
    case 'es': return ['Reduce velocidad y prefiere transporte público en días de niebla', 'La niebla puede atrapar contaminación — evita actividad intensa al aire libre', 'Buen día para actividades eco en interior: clasificar, compostar, reparar'];
    default:   return ['Réduisez la vitesse et préférez les transports en commun par temps de brouillard', 'Le brouillard piège la pollution — évitez les efforts physiques en extérieur', 'Bonne journée pour les activités éco en intérieur : tri, compostage, réparation'];
  }}

  // ── Quiz ──────────────────────────────────────────────────────────────────
  String get quizTitle       => _t('Quiz Recyclage',           'Recycling Quiz',          'اختبار التدوير',            'Quiz de Reciclaje');
  String get quizNext        => _t('Suivant',                  'Next',                    'التالي',                    'Siguiente');
  String get quizResult_     => _t('Résultat',                 'Result',                  'النتيجة',                   'Resultado');
  String get quizExcellent   => _t('Excellent !',              'Excellent!',              'ممتاز!',                    '¡Excelente!');
  String get quizWellDone    => _t('Bien joué !',              'Well done!',              'جيد جداً!',                 '¡Bien hecho!');
  String get quizKeepLearning=> _t('Continuez à apprendre !', 'Keep learning!',          'استمر في التعلم!',          '¡Sigue aprendiendo!');
  String get quizRetry       => _t('Recommencer',              'Try again',               'إعادة المحاولة',            'Intentar de nuevo');
  String quizScore(int c, int t) => _t(
    '$c/$t bonnes réponses', '$c/$t correct answers',
    '$c/$t إجابة صحيحة',    '$c/$t respuestas correctas',
  );

  // ── Barcode ───────────────────────────────────────────────────────────────
  String get barcodeTitle         => _t('Scanner code-barres',              'Barcode Scanner',                'مسح الرمز الشريطي',                 'Escáner de código de barras');
  String get barcodeCamHint       => _t('Pointez la caméra vers le code-barres du produit', 'Point the camera at the product barcode', 'وجّه الكاميرا نحو الرمز الشريطي للمنتج', 'Apunta la cámara al código de barras del producto');
  String get barcodeNotFound      => _t('Produit introuvable dans la base de données', 'Product not found in the database', 'لم يُعثر على المنتج في قاعدة البيانات', 'Producto no encontrado en la base de datos');
  String get barcodeScanAgain     => _t('Scanner à nouveau',  'Scan again',      'مسح مجدداً',    'Escanear de nuevo');
  String get barcodeUnknown       => _t('Produit inconnu',    'Unknown product', 'منتج غير معروف','Producto desconocido');
  String get barcodePackaging     => _t('Emballage',          'Packaging',       'التغليف',       'Envase');
  String get barcodeOrigin        => _t('Pays d\'origine',    'Origin',          'بلد المنشأ',    'País de origen');
  String get barcodeIngred        => _t('Ingrédients',        'Ingredients',     'المكونات',      'Ingredientes');
  String get barcodeRecyclable    => _t('Recyclable ✓',       'Recyclable ✓',    'قابل للتدوير ✓','Reciclable ✓');
  String get barcodeNotRecyclable => _t('Non recyclable ✗',   'Not recyclable ✗','غير قابل للتدوير ✗','No reciclable ✗');
  String get barcodeEcoImpact     => _t('Impact environnemental', 'Environmental impact', 'التأثير البيئي', 'Impacto ambiental');
  String get barcodeCtaLabel      => _t('Scanner code-barres',  'Scan barcode',  'مسح الباركود',  'Escanear código de barras');
  String get barcodeCtaSub        => _t('Infos produit & recyclabilité', 'Product info & recyclability', 'معلومات المنتج وقابلية التدوير', 'Info producto y reciclabilidad');
  String get barcodeDisposalTip   => _t('Consigne de tri',  'Sorting instruction', 'تعليمات الفرز', 'Instrucción de clasificación');
  String get barcodeHowToRecycle  => _t('Comment recycler ?',   'How to recycle?',       'كيف تُعيد التدوير؟',      '¿Cómo reciclar?');
  String get barcodeMaterial      => _t('Matériau identifié',   'Identified material',   'المادة المُحددة',         'Material identificado');
  String get barcodeBin           => _t('Bac recommandé',       'Recommended bin',       'الحاوية الموصى بها',      'Contenedor recomendado');
  String get barcodeNutriTitle    => _t('Nutri-Score',          'Nutri-Score',           'نيوتري-سكور',             'Nutri-Score');
  String get barcodeEcoTitle      => _t('Eco-Score',            'Eco-Score',             'إيكو-سكور',               'Eco-Score');
  String get barcodeNutriSubtitle => _t('Qualité nutritionnelle du produit', 'Product nutritional quality', 'الجودة الغذائية للمنتج', 'Calidad nutricional del producto');
  String get barcodeEcoSubtitle   => _t('Impact environnemental du produit', 'Product environmental impact', 'التأثير البيئي للمنتج', 'Impacto ambiental del producto');

  // Explication Nutri-Score A→E (4 langues)
  String nutriExplain(String grade) {
    switch (grade) {
      case 'A': return _t('Excellente qualité nutritionnelle',   'Excellent nutritional quality',   'جودة غذائية ممتازة',      'Excelente calidad nutricional');
      case 'B': return _t('Bonne qualité nutritionnelle',        'Good nutritional quality',        'جودة غذائية جيدة',        'Buena calidad nutricional');
      case 'C': return _t('Qualité nutritionnelle moyenne',      'Average nutritional quality',     'جودة غذائية متوسطة',      'Calidad nutricional media');
      case 'D': return _t('Mauvaise qualité nutritionnelle',     'Poor nutritional quality',        'جودة غذائية ضعيفة',       'Mala calidad nutricional');
      case 'E': return _t('Très mauvaise qualité nutritionnelle','Very poor nutritional quality',   'جودة غذائية سيئة جداً',   'Muy mala calidad nutricional');
      default:  return _t('Non évalué',                          'Not evaluated',                   'غير مُقيَّم',             'No evaluado');
    }
  }

  // Explication Eco-Score A→E (4 langues)
  String ecoExplain(String grade) {
    switch (grade) {
      case 'A': return _t('Très faible impact environnemental',  'Very low environmental impact',   'تأثير بيئي منخفض جداً',   'Impacto ambiental muy bajo');
      case 'B': return _t('Faible impact environnemental',       'Low environmental impact',        'تأثير بيئي منخفض',        'Bajo impacto ambiental');
      case 'C': return _t('Impact environnemental modéré',       'Moderate environmental impact',   'تأثير بيئي معتدل',        'Impacto ambiental moderado');
      case 'D': return _t('Fort impact environnemental',         'High environmental impact',       'تأثير بيئي مرتفع',        'Alto impacto ambiental');
      case 'E': return _t('Très fort impact environnemental',    'Very high environmental impact',  'تأثير بيئي مرتفع جداً',   'Impacto ambiental muy alto');
      default:  return _t('Non évalué',                          'Not evaluated',                   'غير مُقيَّم',             'No evaluado');
    }
  }

  String get barcodeCategories       => _t('Catégories',            'Categories',            'الفئات',                  'Categorías');
  String get barcodeScanAgainBtn     => _t('Nouveau scan',          'New scan',              'مسح جديد',                'Nuevo escaneo');
  String get packagingTypeLabel      => _t("Type d'emballage",      'Packaging type',        'نوع التغليف',             'Tipo de envase');
  String get packagingMaterialLabel  => _t('Matière',               'Material',              'المادة',                  'Material');
  String get packagingNotSpecified   => _t('Non renseigné',         'Not specified',         'غير محدد',                'No especificado');

  // Instructions par matériau (4 langues)
  List<String> barcodeGlassSteps() { switch(_locale) {
    case 'en': return ['Empty the bottle completely', 'Remove the plastic cap (recycle separately)', 'Do not break the glass', 'Deposit in the green glass column'];
    case 'ar': return ['أفرغ الزجاجة تماماً', 'أزل الغطاء البلاستيكي (أعد تدويره منفصلاً)', 'لا تكسر الزجاج', 'ضعها في عمود الزجاج الأخضر'];
    case 'es': return ['Vacía la botella completamente', 'Retira el tapón de plástico (recícla aparte)', 'No romper el vidrio', 'Deposita en la columna verde de vidrio'];
    default:   return ['Videz la bouteille complètement', 'Retirez le bouchon plastique (recycler séparément)', 'Ne cassez pas le verre', 'Déposez dans la colonne verre verte'];
  }}
  List<String> barcodePlasticSteps() { switch(_locale) {
    case 'en': return ['Empty and rinse the container', 'Crush it to save space', 'Put the cap back on', 'Drop in the yellow ECOVAL bin'];
    case 'ar': return ['أفرغ العبوة واشطفها', 'اسحقها لتوفير المساحة', 'أعد وضع الغطاء', 'ضعها في الحاوية الصفراء ECOVAL'];
    case 'es': return ['Vacía y enjuaga el envase', 'Aplástalo para ahorrar espacio', 'Pon el tapón', 'Deposita en el contenedor amarillo ECOVAL'];
    default:   return ['Videz et rincez l\'emballage', 'Écrasez-le pour gagner de la place', 'Remettez le bouchon', 'Déposez dans le bac jaune ECOVAL'];
  }}
  List<String> barcodeMetalSteps() { switch(_locale) {
    case 'en': return ['Empty the can or tin completely', 'Rinse if greasy', 'Crush if possible', 'Drop in the yellow ECOVAL bin'];
    case 'ar': return ['أفرغ العلبة تماماً', 'اشطفها إذا كانت دهنية', 'اسحقها إذا أمكن', 'ضعها في الحاوية الصفراء ECOVAL'];
    case 'es': return ['Vacía la lata completamente', 'Enjuaga si está grasosa', 'Aplástala si es posible', 'Deposita en el contenedor amarillo ECOVAL'];
    default:   return ['Videz entièrement la boîte ou canette', 'Rincez si elle est grasse', 'Écrasez si possible', 'Déposez dans le bac jaune ECOVAL'];
  }}
  List<String> barcodeCardboardSteps() { switch(_locale) {
    case 'en': return ['Empty and flatten the box', 'Remove plastic windows or labels if possible', 'Do not mix with wet cardboard', 'Drop in the blue bin'];
    case 'ar': return ['أفرغ العلبة واطوِها', 'أزل النوافذ البلاستيكية إن أمكن', 'لا تخلطه بالكرتون المبلل', 'ضعه في الحاوية الزرقاء'];
    case 'es': return ['Vacía y aplana la caja', 'Quita ventanas plásticas si es posible', 'No mezclar con cartón mojado', 'Deposita en el contenedor azul'];
    default:   return ['Videz et aplatissez la boîte', 'Retirez les fenêtres plastiques si possible', 'Ne mélangez pas avec du carton mouillé', 'Déposez dans le bac bleu'];
  }}
  List<String> barcodeNonRecyclableSteps() { switch(_locale) {
    case 'en': return ['This packaging cannot be recycled', 'Place in the black general waste bin', 'Try to favour products with recyclable packaging next time'];
    case 'ar': return ['هذا التغليف غير قابل للتدوير', 'ضعه في الحاوية السوداء للنفايات العامة', 'حاول اختيار منتجات بتغليف قابل للتدوير في المرة القادمة'];
    case 'es': return ['Este envase no es reciclable', 'Colócalo en el contenedor negro de residuos generales', 'Intenta elegir productos con envase reciclable la próxima vez'];
    default:   return ['Cet emballage n\'est pas recyclable', 'Déposez-le dans le bac noir des ordures ménagères', 'Essayez de privilégier des produits à emballage recyclable la prochaine fois'];
  }}

  // ── Home badges environnement ─────────────────────────────────────────────
  String get badgeWater        => _t('Eau',    'Water',  'الماء',   'Agua');
  String get badgeWaterStatus  => _t('Normal', 'Normal', 'عادي',    'Normal');

  // Statuts température
  String tempStatus(double temp) {
    if (temp < 0)  return _t('Très froid', 'Very cold',  'بارد جداً', 'Muy frío');
    if (temp < 15) return _t('Frais',      'Fresh',      'بارد',      'Fresco');
    if (temp < 25) return _t('Agréable',   'Pleasant',   'معتدل',     'Agradable');
    if (temp < 35) return _t('Chaud',      'Warm',       'دافئ',      'Cálido');
    return               _t('Très chaud',  'Very hot',   'حار جداً',  'Muy caliente');
  }

  // Statuts AQI (selon tableau OMS)
  String aqiStatus(int aqi) {
    if (aqi <= 50)  return _t('Bon',           'Good',                    'جيد',            'Bueno');
    if (aqi <= 100) return _t('Modéré',         'Moderate',               'معتدل',           'Moderado');
    if (aqi <= 150) return _t('Sensibles',       'Sensitive groups',       'حساسون',          'Sensibles');
    if (aqi <= 200) return _t('Mauvais',         'Unhealthy',              'غير صحي',         'No saludable');
    if (aqi <= 300) return _t('Très mauvais',    'Very unhealthy',         'سيء جداً',        'Muy malo');
    return               _t('Dangereux',         'Hazardous',              'خطر',             'Peligroso');
  }

  // ── Profil — outils éco ───────────────────────────────────────────────────
  String get profileEcoTools   => _t('Outils éco',    'Eco tools',    'أدوات بيئية',   'Herramientas eco');
  String get airQualityGpsError    => _t(
    'GPS désactivé — données de Casablanca affichées',
    'GPS disabled — showing Casablanca data',
    'GPS معطّل — عرض بيانات الدار البيضاء',
    'GPS desactivado — mostrando datos de Casablanca');
  String get airQualityGpsHint     => _t(
    'Activez le GPS pour voir la qualité de l\'air de votre ville',
    'Enable GPS to see your city\'s air quality',
    'فعّل GPS لعرض جودة هواء مدينتك',
    'Activa el GPS para ver la calidad del aire de tu ciudad');
  String get airQualityPermError   => _t(
    'Permission GPS refusée — données de Casablanca',
    'GPS permission denied — Casablanca data',
    'تم رفض إذن GPS — بيانات الدار البيضاء',
    'Permiso GPS denegado — datos de Casablanca');
  String get airQualityNetError    => _t(
    'Impossible de charger les données. Vérifiez votre connexion.',
    'Cannot load data. Check your connection.',
    'تعذّر تحميل البيانات. تحقق من اتصالك.',
    'No se pueden cargar los datos. Verifica tu conexión.');
  String get menuWeather       => _t('Météo',          'Weather',      'الطقس',         'Clima');
  String get menuAirQuality    => _t('Qualité de l\'air', 'Air quality', 'جودة الهواء', 'Calidad del aire');
  String get menuWaterFoot     => _t('Empreinte eau',  'Water footprint', 'بصمة الماء', 'Huella hídrica');
  String get menuQuiz          => _t('Quiz recyclage', 'Recycling quiz',  'اختبار التدوير', 'Quiz de reciclaje');
  String get menuBarcodeScanner=> _t('Code-barres produit', 'Product barcode', 'باركود المنتج', 'Código de barras');

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
  String get deleteAccountGoogleConfirm => _t(
    '⚠️ Cette action est irréversible.\nToutes vos données seront définitivement supprimées.\n\nÊtes-vous sûr de vouloir supprimer votre compte ?',
    '⚠️ This action is irreversible.\nAll your data will be permanently deleted.\n\nAre you sure you want to delete your account?',
    '⚠️ هذا الإجراء لا رجعة فيه.\nسيتم حذف جميع بياناتك نهائياً.\n\nهل أنت متأكد من حذف حسابك؟',
    '⚠️ Esta acción es irreversible.\nTodos tus datos serán eliminados permanentemente.\n\n¿Estás seguro de que quieres eliminar tu cuenta?');
  String get emailUpdatedRelogin => _t(
    'Email mis à jour ! Reconnectez-vous avec votre nouvelle adresse.',
    'Email updated! Please sign in with your new address.',
    'تم تحديث البريد الإلكتروني! يرجى تسجيل الدخول بعنوانك الجديد.',
    '¡Correo actualizado! Inicia sesión con tu nueva dirección.');
  String get changePhoneNumber   => _t('Changer le numéro', 'Change number', 'تغيير الرقم', 'Cambiar número');
  String get disable2FA          => _t('Désactiver la 2FA', 'Disable 2FA', 'تعطيل المصادقة الثنائية', 'Desactivar 2FA');
  String get wrongGoogleAccount  => _t(
    'Compte Google incorrect. Veuillez choisir le compte associé à cette application.',
    'Wrong Google account. Please select the account linked to this app.',
    'حساب Google خاطئ. يرجى اختيار الحساب المرتبط بهذا التطبيق.',
    'Cuenta Google incorrecta. Selecciona la cuenta vinculada a esta app.');
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
  String get menuRewards      => _t('Récompenses', 'Rewards', 'المكافآت', 'Recompensas');
  String get menuHistory      => _t('Historique', 'History', 'السجل', 'Historial');
  String get menuChallenges   => _t('Défis', 'Challenges', 'التحديات', 'Desafíos');
  // Sections profil
  String get profileSectionAccount     => _t('Mon compte', 'My account', 'حسابي', 'Mi cuenta');
  String get profileSectionEducation   => _t('Éducation', 'Education', 'التعليم', 'Educación');
  String get profileSectionEnvironment => _t('Environnement', 'Environment', 'البيئة', 'Medio ambiente');
  String get profileSectionActivity    => _t('Activité & Récompenses', 'Activity & Rewards', 'النشاط والمكافآت', 'Actividad y Recompensas');
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
  String get searchCollection  => _t('Rechercher un point de collecte...', 'Search a collection point...', 'البحث عن نقطة جمع...', 'Buscar punto de recogida...');
  String get directions        => _t('Itinéraire', 'Directions', 'الاتجاهات', 'Cómo llegar');
  String get nearbyPoints      => _t('Points de collecte proches', 'Nearby collection points', 'نقاط الجمع القريبة', 'Puntos de recogida cercanos');
  String get locatingText      => _t('Localisation en cours...', 'Locating...', 'جارٍ تحديد الموقع...', 'Localizando...');
  String get legendGeneral     => _t('Général', 'General', 'عام', 'General');
  String get legendElectro     => _t('Électro.', 'Electro.', 'إلكترو.', 'Electro.');
  String pointsInRadius(int n) => _t('$n points dans un rayon de 5 km', '$n points within 5 km', '$n نقطة في نطاق 5 كم', '$n puntos en radio de 5 km');
  String pointsAvailable(int n) => _t('$n points disponibles', '$n points available', '$n نقطة متاحة', '$n puntos disponibles');

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
  String get catOil          => _t('Huiles',    'Used oil',    'زيوت',        'Aceites');
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
