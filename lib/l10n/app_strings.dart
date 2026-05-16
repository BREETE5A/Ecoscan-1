class AppStrings {
  final String _locale;
  AppStrings(this._locale);

  static AppStrings of(String locale) => AppStrings(locale);

  String _t(String fr, String en, String ar) {
    switch (_locale) {
      case 'en': return en;
      case 'ar': return ar;
      default:   return fr;
    }
  }

  // ── App ──────────────────────────────────────────────────────────────────
  String get appName     => 'EcoScan';
  String get tagline     => _t('Ensemble pour une planète plus verte',
                               'Together for a greener planet',
                               'معاً من أجل كوكب أكثر خضرة');

  // ── Common ───────────────────────────────────────────────────────────────
  String get save        => _t('Enregistrer', 'Save', 'حفظ');
  String get cancel      => _t('Annuler', 'Cancel', 'إلغاء');
  String get next        => _t('Suivant', 'Next', 'التالي');
  String get skip        => _t('Passer', 'Skip', 'تخطي');
  String get start       => _t('Commencer', 'Start', 'ابدأ');
  String get seeAll      => _t('Voir tout', 'See all', 'عرض الكل');
  String get loading     => _t('Chargement...', 'Loading...', 'جارٍ التحميل...');
  String get confirm     => _t('Confirmer', 'Confirm', 'تأكيد');
  String get search      => _t('Rechercher...', 'Search...', 'بحث...');
  String get close       => _t('Fermer', 'Close', 'إغلاق');
  String get yes         => _t('Oui', 'Yes', 'نعم');
  String get no          => _t('Non', 'No', 'لا');

  // ── Navigation ───────────────────────────────────────────────────────────
  String get navHome       => _t('Accueil',   'Home',      'الرئيسية');
  String get navMap        => _t('Carte',     'Map',       'الخريطة');
  String get navScan       => _t('Scanner',   'Scan',      'مسح');
  String get navChat       => _t('Assistant', 'Assistant', 'المساعد');
  String get navProfile    => _t('Profil',    'Profile',   'الملف');

  // ── Auth ─────────────────────────────────────────────────────────────────
  String get welcomeBack   => _t('Bon retour !', 'Welcome back!', 'مرحباً بعودتك!');
  String get loginSubtitle => _t('Connectez-vous pour continuer',
                                 'Sign in to continue',
                                 'سجّل دخولك للمتابعة');
  String get email         => _t('Email', 'Email', 'البريد الإلكتروني');
  String get password      => _t('Mot de passe', 'Password', 'كلمة المرور');
  String get forgotPass    => _t('Mot de passe oublié ?', 'Forgot password?', 'نسيت كلمة المرور؟');
  String get loginBtn      => _t('Se connecter', 'Login', 'تسجيل الدخول');
  String get noAccount     => _t('Pas encore de compte ? ', "Don't have an account? ", 'ليس لديك حساب؟ ');
  String get registerLink  => _t("S'inscrire", 'Register', 'سجّل الآن');
  String get createAccount => _t('Créer un compte', 'Create account', 'إنشاء حساب');
  String get personalInfo  => _t('Vos informations personnelles',
                                 'Your personal information',
                                 'معلوماتك الشخصية');
  String get createPass    => _t('Créez votre mot de passe',
                                 'Create your password',
                                 'أنشئ كلمة المرور');
  String get fullName      => _t('Nom complet', 'Full name', 'الاسم الكامل');
  String get continue_     => _t('Continuer', 'Continue', 'متابعة');
  String get alreadyAccount => _t('Déjà un compte ? ', 'Already have an account? ', 'لديك حساب؟ ');
  String get loginLink     => _t('Se connecter', 'Log in', 'تسجيل الدخول');
  String get youAre        => _t('Vous êtes ?', 'You are?', 'أنت؟');
  String get confirmPass   => _t('Confirmer le mot de passe', 'Confirm password', 'تأكيد كلمة المرور');

  // ── Onboarding ───────────────────────────────────────────────────────────
  String get ob1Title    => _t('Scannez & Identifiez',
                               'Scan & Identify',
                               'امسح وتعرّف');
  String get ob1Sub      => _t('Photographiez n\'importe quel déchet et notre IA l\'identifie instantanément pour vous indiquer la bonne poubelle.',
                               'Photograph any waste and our AI instantly identifies it to show you the right bin.',
                               'التقط صورة لأي نفايات وسيحددها نظام الذكاء الاصطناعي فوراً ليرشدك إلى الحاوية الصحيحة.');
  String get ob2Title    => _t('Trouvez les Points de Collecte',
                               'Find Collection Points',
                               'ابحث عن نقاط الجمع');
  String get ob2Sub      => _t('Localisez les bacs de tri, déchetteries et points de dépôt les plus proches autour de vous en temps réel.',
                               'Locate the nearest sorting bins, recycling centres and drop-off points in real time.',
                               'حدد موقع أقرب صناديق الفرز ومراكز إعادة التدوير ونقاط الإيداع في الوقت الفعلي.');
  String get ob3Title    => _t('Gagnez des Récompenses',
                               'Earn Rewards',
                               'اكسب مكافآت');
  String get ob3Sub      => _t('Chaque action éco-responsable vous rapporte des points. Grimpez dans le classement et débloquez des badges exclusifs.',
                               'Every eco-responsible action earns you points. Climb the leaderboard and unlock exclusive badges.',
                               'كل إجراء بيئي مسؤول يمنحك نقاطاً. تصعّد في الترتيب وافتح شارات حصرية.');

  // ── Home ─────────────────────────────────────────────────────────────────
  String get greetingPrefix  => _t('Bonjour', 'Hello', 'مرحباً');
  String get readySubtitle   => _t('Prêt à sauver la planète ?',
                                   'Ready to save the planet?',
                                   'هل أنت مستعد لإنقاذ الكوكب؟');
  String get weeklyGoal      => _t('OBJECTIF HEBDO', 'WEEKLY GOAL', 'الهدف الأسبوعي');
  String get recycled        => _t('de déchets recyclés', 'of recycled waste', 'من النفايات المُعاد تدويرها');
  String get quickActions    => _t('Actions rapides', 'Quick actions', 'الإجراءات السريعة');
  String get recentActivity  => _t('Activités récentes', 'Recent activities', 'الأنشطة الأخيرة');
  String get didYouKnow      => _t('Le saviez-vous ?', 'Did you know?', 'هل تعلم؟');
  String get ecoTipText      => _t('Recycler une canette d\'aluminium économise 95% d\'énergie comparé à en fabriquer une neuve.',
                                   'Recycling one aluminium can saves 95% of the energy needed to make a new one.',
                                   'إعادة تدوير علبة ألومنيوم واحدة توفر 95٪ من الطاقة اللازمة لتصنيع علبة جديدة.');
  String get points          => _t('Points', 'Points', 'النقاط');
  String get scans           => _t('Scans', 'Scans', 'المسوحات');
  String get co2Avoided      => _t('CO₂ Évité (g)', 'CO₂ Saved (g)', 'CO₂ موفور (غ)');
  String get thisWeek        => _t('Cette semaine', 'This week', 'هذا الأسبوع');
  String get ofGoal          => _t('de l\'objectif', 'of goal', 'من الهدف');

  // ── Quick actions ─────────────────────────────────────────────────────────
  String get qaBadges        => _t('Badges', 'Badges', 'الشارات');
  String get qaGuide         => _t('Guide de Tri', 'Sorting Guide', 'دليل الفرز');
  String get qaLeaderboard   => _t('Classement', 'Leaderboard', 'الترتيب');
  String get qaStats         => _t('Statistiques', 'Statistics', 'الإحصائيات');
  String get qaChallenges    => _t('Défis', 'Challenges', 'التحديات');
  String get qaHistory       => _t('Historique', 'History', 'السجل');
  String get qaRewards       => _t('Récompenses', 'Rewards', 'المكافآت');
  String get qaCalculator    => _t('Bilan CO₂', 'CO₂ Calculator', 'حاسبة CO₂');

  // ── Screens titles ────────────────────────────────────────────────────────
  String get myStats         => _t('Mes Statistiques', 'My Statistics', 'إحصائياتي');
  String get myBadges        => _t('Mes Badges', 'My Badges', 'شاراتي');
  String get sortingGuide    => _t('Guide de Tri', 'Sorting Guide', 'دليل الفرز');
  String get leaderboard     => _t('Classement', 'Leaderboard', 'لوحة الترتيب');
  String get notifications   => _t('Notifications', 'Notifications', 'الإشعارات');
  String get settingsTitle   => _t('Paramètres', 'Settings', 'الإعدادات');
  String get myProfile       => _t('Mon Profil', 'My Profile', 'ملفي الشخصي');
  String get editProfile     => _t('Modifier le profil', 'Edit profile', 'تعديل الملف');
  String get scanResult      => _t('Résultat du scan', 'Scan result', 'نتيجة المسح');
  String get scanDechet      => _t('Scanner un déchet', 'Scan a waste', 'مسح نفايات');
  String get challengesTitle => _t('Défis Éco', 'Eco Challenges', 'التحديات البيئية');
  String get historyTitle    => _t('Historique des Scans', 'Scan History', 'سجل المسوحات');
  String get rewardsTitle    => _t('Mes Récompenses', 'My Rewards', 'مكافآتي');
  String get languageTitle   => _t('Choisissez votre langue', 'Choose your language', 'اختر لغتك');

  // ── Settings ──────────────────────────────────────────────────────────────
  String get appearance      => _t('Apparence', 'Appearance', 'المظهر');
  String get darkMode        => _t('Mode sombre', 'Dark mode', 'الوضع المظلم');
  String get darkModeDesc    => _t('Thème sombre pour vos yeux', 'Dark theme for your eyes', 'وضع داكن لراحة عيونك');
  String get language        => _t('Langue', 'Language', 'اللغة');
  String get city            => _t('Ville', 'City', 'المدينة');
  String get privacy         => _t('Confidentialité', 'Privacy', 'الخصوصية');
  String get location        => _t('Localisation', 'Location', 'الموقع');
  String get locationDesc    => _t('Trouver les points proches', 'Find nearby points', 'البحث عن أقرب النقاط');
  String get about           => _t('À propos', 'About', 'حول التطبيق');
  String get logout          => _t('Se déconnecter', 'Logout', 'تسجيل الخروج');
  String get notifPush       => _t('Notifications push', 'Push notifications', 'إشعارات الدفع');
  String get notifDesc       => _t('Alertes, rappels et badges', 'Alerts, reminders and badges', 'تنبيهات وتذكيرات وشارات');
  String get sound           => _t('Sons', 'Sounds', 'الأصوات');
  String get soundDesc       => _t('Sons de l\'application', 'App sounds', 'أصوات التطبيق');
  String get weeklyReport    => _t('Rapport hebdomadaire', 'Weekly report', 'تقرير أسبوعي');
  String get weeklyReportDesc=> _t('Résumé chaque lundi matin', 'Summary every Monday morning', 'ملخص كل صباح الاثنين');
  String get customize       => _t('Personnalisez votre expérience', 'Customize your experience', 'خصّص تجربتك');
  String get exportData      => _t('Exporter mes données', 'Export my data', 'تصدير بياناتي');
  String get deleteAccount   => _t('Supprimer mon compte', 'Delete my account', 'حذف حسابي');

  // ── Challenges ────────────────────────────────────────────────────────────
  String get daily           => _t('Quotidien', 'Daily', 'يومي');
  String get weekly          => _t('Hebdomadaire', 'Weekly', 'أسبوعي');
  String get completed       => _t('Terminé', 'Completed', 'مكتمل');
  String get inProgress      => _t('En cours', 'In progress', 'قيد التنفيذ');
  String get claim           => _t('Réclamer', 'Claim', 'استلام');
  String get challengesDone  => _t('défis complétés aujourd\'hui', 'challenges completed today', 'تحديات مكتملة اليوم');
  String get streak          => _t('jours de suite', 'day streak', 'أيام متتالية');
  String get pointsReward    => _t('pts à gagner', 'pts to earn', 'نقطة للربح');
  String get resetIn         => _t('Réinitialisation dans', 'Resets in', 'يُعاد تعيينه في');

  // ── History ───────────────────────────────────────────────────────────────
  String get totalScans      => _t('Total Scans', 'Total Scans', 'إجمالي المسوحات');
  String get pointsEarned    => _t('Points Gagnés', 'Points Earned', 'النقاط المكتسبة');
  String get mostScanned     => _t('Plus scanné', 'Most scanned', 'الأكثر مسحاً');
  String get filterAll       => _t('Tous', 'All', 'الكل');
  String get recyclable      => _t('Recyclable', 'Recyclable', 'قابل لإعادة التدوير');
  String get nonRecyclable   => _t('Non recyclable', 'Non recyclable', 'غير قابل لإعادة التدوير');
  String get noHistory       => _t('Aucun scan pour l\'instant', 'No scans yet', 'لا توجد مسوحات بعد');

  // ── Rewards ───────────────────────────────────────────────────────────────
  String get yourBalance     => _t('Votre solde', 'Your balance', 'رصيدك');
  String get redeem          => _t('Échanger', 'Redeem', 'استبدال');
  String get redeemed        => _t('Obtenu ✓', 'Redeemed ✓', 'تم الاستبدال ✓');
  String get notEnoughPoints => _t('Points insuffisants', 'Not enough points', 'نقاط غير كافية');
  String get trees           => _t('Nature', 'Nature', 'طبيعة');
  String get coupons         => _t('Coupons', 'Coupons', 'كوبونات');
  String get donations       => _t('Dons', 'Donations', 'تبرعات');
  String get digital         => _t('Digital', 'Digital', 'رقمي');

  // ── Map ───────────────────────────────────────────────────────────────────
  String get searchCollection => _t('Rechercher un point de collecte...', 'Search a collection point...', 'البحث عن نقطة جمع...');
  String get directions       => _t('Itinéraire', 'Directions', 'الاتجاهات');
  String get nearbyPoints     => _t('Points de collecte proches', 'Nearby collection points', 'نقاط الجمع القريبة');

  // ── Scan ──────────────────────────────────────────────────────────────────
  String get centerWaste      => _t('Centrez le déchet dans le cadre', 'Center the waste in the frame', 'ضع النفايات في منتصف الإطار');
  String get analyzing        => _t('Analyse en cours...', 'Analyzing...', 'جارٍ التحليل...');
  String get gallery          => _t('Galerie', 'Gallery', 'المعرض');
  String get history_         => _t('Historique', 'History', 'السجل');
  String get identified       => _t('Objet identifié !', 'Object identified!', 'تم التعرف على الكائن!');
  String get rescan           => _t('Re-scanner', 'Re-scan', 'إعادة المسح');
  String get viewMap          => _t('Voir carte', 'View map', 'عرض الخريطة');

  // ── Guide ─────────────────────────────────────────────────────────────────
  String get sortingSubtitle  => _t('Apprenez à trier vos déchets correctement',
                                    'Learn how to sort your waste correctly',
                                    'تعلّم كيفية فرز نفاياتك بشكل صحيح');

  // ── Chat ──────────────────────────────────────────────────────────────────
  String get botGreeting      => _t('Bonjour ! Je suis EcoBot 🌿 Votre assistant de tri intelligent. Comment puis-je vous aider ?',
                                    'Hello! I\'m EcoBot 🌿 Your smart sorting assistant. How can I help you?',
                                    'مرحباً! أنا EcoBot 🌿 مساعدك الذكي للفرز. كيف يمكنني مساعدتك؟');
  String get typeMessage      => _t('Posez votre question...', 'Ask your question...', 'اطرح سؤالك...');
  String get online           => _t('En ligne — Assistant IA', 'Online — AI Assistant', 'متصل — مساعد ذكاء اصطناعي');

  // ── Profile ───────────────────────────────────────────────────────────────
  String get level            => _t('Niveau', 'Level', 'المستوى');
  String get rank             => _t('Rang', 'Rank', 'الترتيب');
  String get recentBadges     => _t('Badges récents', 'Recent badges', 'الشارات الأخيرة');
  String get menu             => _t('Menu', 'Menu', 'القائمة');
  String get disconnect       => _t('Se déconnecter', 'Sign out', 'تسجيل الخروج');

  // ── Stats ─────────────────────────────────────────────────────────────────
  String get impactSubtitle   => _t('Votre impact environnemental', 'Your environmental impact', 'تأثيرك البيئي');
  String get byCategory       => _t('Par catégorie', 'By category', 'حسب الفئة');
  String get periodWeek       => _t('Semaine', 'Week', 'الأسبوع');
  String get periodMonth      => _t('Mois', 'Month', 'الشهر');
  String get periodYear       => _t('Année', 'Year', 'السنة');

  // ── Leaderboard ───────────────────────────────────────────────────────────
  String get myCity           => _t('Ma Ville', 'My City', 'مدينتي');
  String get national         => _t('National', 'National', 'وطني');
  String get bestCitizens     => _t('Les meilleurs éco-citoyens', 'The best eco-citizens', 'أفضل المواطنين البيئيين');
  String get youLabel         => _t('Vous', 'You', 'أنت');

  // ── Language screen ───────────────────────────────────────────────────────
  String get chooseLang       => _t('Choisissez votre langue', 'Choose your language', 'اختر لغتك');
  String get langSubtitle     => _t('Vous pourrez changer cela plus tard dans les paramètres.',
                                    'You can change this later in settings.',
                                    'يمكنك تغيير هذا لاحقاً في الإعدادات.');
}
