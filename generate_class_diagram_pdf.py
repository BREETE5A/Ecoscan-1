from fpdf import FPDF, XPos, YPos

GREEN       = (34, 139, 34)
GREEN_DARK  = (20, 90, 20)
GREEN_LIGHT = (235, 247, 235)
WHITE       = (255, 255, 255)
BLACK       = (0, 0, 0)
GREY        = (100, 100, 100)
GREY_LIGHT  = (248, 248, 248)

class PDF(FPDF):
    def header(self):
        self.set_fill_color(*GREEN)
        self.rect(0, 0, 210, 22, 'F')
        self.set_font('Helvetica', 'B', 14)
        self.set_text_color(*WHITE)
        self.set_y(6)
        self.cell(0, 10, 'EcoScan  -  Diagramme de Classes', align='C',
                  new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        self.set_text_color(*BLACK)
        self.ln(14)

    def footer(self):
        self.set_y(-13)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(*GREY)
        self.cell(0, 10, f'EcoScan  -  Diagramme de Classes  |  Page {self.page_no()}', align='C')

# ── Helpers ────────────────────────────────────────────────────────────────────

def section_title(pdf, number, class_name, arrow, impl):
    """Titre de classe style '### 1. Categorie → implémenté via ...' """
    pdf.ln(4)
    pdf.set_fill_color(*GREEN_DARK)
    pdf.set_font('Helvetica', 'B', 11)
    pdf.set_text_color(*WHITE)
    pdf.cell(0, 10, f'  {number}.  {class_name}  ->  {arrow}',
             fill=True, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.set_font('Helvetica', 'I', 8)
    pdf.set_text_color(*GREY)
    pdf.cell(0, 5, f'     Implemente dans : {impl}',
             new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.set_text_color(*BLACK)
    pdf.ln(2)

def sub_header(pdf, text):
    """Sous-titre 'Attributs :' ou 'Methodes :' """
    pdf.set_font('Helvetica', 'B', 9)
    pdf.set_fill_color(*GREEN)
    pdf.set_text_color(*WHITE)
    pdf.cell(0, 7, f'   {text}', fill=True,
             new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.set_text_color(*BLACK)

def table(pdf, col_widths, headers, rows):
    """
    Tableau generique avec en-tete vert et lignes alternees.
    col_widths : liste de largeurs en mm (somme = 190)
    headers    : liste de strings
    rows       : liste de listes de strings
    """
    # En-tete
    pdf.set_fill_color(*GREEN)
    pdf.set_font('Helvetica', 'B', 8)
    pdf.set_text_color(*WHITE)
    for w, h in zip(col_widths, headers):
        pdf.cell(w, 7, f' {h}', border=1, fill=True)
    pdf.ln(7)
    pdf.set_text_color(*BLACK)

    # Lignes
    for idx, row in enumerate(rows):
        bg = GREEN_LIGHT if idx % 2 == 0 else GREY_LIGHT

        # Calculer la hauteur de la ligne (multi_cell le plus haut)
        pdf.set_font('Helvetica', '', 8)
        max_lines = 1
        for w, cell_txt in zip(col_widths, row):
            # Nombre de lignes qu'occupera ce texte
            nb = len(pdf.multi_cell(w - 3, 5, str(cell_txt),
                                    dry_run=True, output='LINES'))
            if nb > max_lines:
                max_lines = nb
        row_h = max_lines * 5 + 2

        # Verifier qu'on a assez de place sur la page
        if pdf.get_y() + row_h > pdf.h - pdf.b_margin - 5:
            pdf.add_page()

        x_start = pdf.get_x()
        y_start = pdf.get_y()

        for w, cell_txt in zip(col_widths, row):
            pdf.set_fill_color(*bg)
            pdf.rect(x_start, y_start, w, row_h, style='DF')
            pdf.set_xy(x_start + 1.5, y_start + 1)
            pdf.multi_cell(w - 3, 5, str(cell_txt), border=0, align='L')
            x_start += w

        pdf.set_xy(pdf.l_margin, y_start + row_h)

    pdf.ln(3)

# ══════════════════════════════════════════════════════════════════════════════
pdf = PDF()
pdf.set_auto_page_break(auto=True, margin=15)
pdf.add_page()

# ── Intro ─────────────────────────────────────────────────────────────────────
pdf.set_font('Helvetica', 'B', 10)
pdf.set_text_color(*GREEN_DARK)
pdf.cell(0, 7, 'Description des 10 classes du diagramme UML - implementation reelle',
         new_x=XPos.LMARGIN, new_y=YPos.NEXT)
pdf.set_text_color(*BLACK)
pdf.set_font('Helvetica', '', 9)
pdf.multi_cell(0, 5,
    'Ce document reproduit fidelement le diagramme de classes de l\'application EcoScan avec '
    'les attributs et methodes reels tels qu\'implantes dans le code Flutter/Dart. '
    'Chaque classe UML est mise en correspondance avec le(s) fichier(s) source qui l\'implementent.')
pdf.ln(5)

# ══════════════════════════════════════════════════════════════════════════════
#  1. CATEGORIE
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 1, 'Categorie',
              'implemente via ScanEntry._categoryData',
              'Frontend/lib/models/scan_entry.dart  (ligne 28)')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut', 'Type', 'Valeurs / Description'],
    rows=[
        ['id  (category)',    'String',
         "Identifiant de categorie : 'cardboard', 'plastique', 'verre', 'metal', 'organique', 'paper', 'electronique', 'trash', 'unknown', 'chaussures', 'vetement'"],
        ['nom  (name)',       'String',
         "'Carton recyclable', 'Plastique recyclable', 'Verre recyclable', 'Metal recyclable',\n'Dechet organique', 'Papier recyclable', 'Appareil DEEE', 'Dechet non recyclable',\n'Objet non reconnu', 'Chaussures usagees', 'Vetement / Textile'"],
        ['ConsigneTri  (binColor)', 'String',
         "Couleur de poubelle recommandee : 'Bleu', 'Jaune', 'Vert', 'Marron', 'Noir', 'Eco-point'"],
        ['recyclable',       'bool',   'true / false - indique si le dechet est recyclable'],
        ['dangerous',        'bool',   'true pour DEEE (electronique), false pour les autres'],
        ['points',           'int',    'Points gagnes par scan : de 0 (unknown) a 40 (electronique)'],
        ['co2Saved',         'double', 'CO2 evite en grammes : de 0.0 (trash) a 80.0 (metal)'],
        ['recyclability',    'double', 'Taux de recyclabilite : 0.0 a 1.0 (verre = 1.0, metal = 0.97)'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode', 'Description'],
    rows=[
        ['afficherConsigne()  ->  ScanEntry.fromClassification()',
         'fromClassification(String label, double confidence) -> ScanEntry\nRetourne un ScanEntry complet avec binColor (consigne de tri) calcule depuis le label YOLOv8'],
        ['toJson()  ->  Map<String, dynamic>',
         'Serialise le ScanEntry en JSON pour stockage SharedPreferences et Firestore'],
        ['fromJson()  ->  factory ScanEntry',
         'factory ScanEntry.fromJson(Map<String, dynamic> json) -> ScanEntry\nDeserialisition depuis JSON (SharedPreferences ou Firestore)'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  2. CENTRE TRI
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 2, 'CentreTri',
              'Donnees statiques dans la carte',
              'Frontend/lib/screens/map/map_screen.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut', 'Type', 'Description'],
    rows=[
        ['id',         'String', 'Identifiant unique du centre de tri'],
        ['nom',        'String', "Ex : 'Geocycle Casablanca', 'Eco Zalagh Sidi Hajaj', 'SMRR Tit Mellil'"],
        ['adresse',    'String', 'Adresse complete du centre'],
        ['latitude',   'double', 'Coordonnee GPS latitude'],
        ['longitude',  'double', 'Coordonnee GPS longitude  (note : ecrit longtitude dans le diagramme)'],
        ['categories', 'List<String>',
         "Types de dechets acceptes : 'Plastique', 'Verre', 'Papier', 'Compost', 'Piles', 'Electronique', 'Textile', 'Huiles', 'Metal'"],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode', 'Description'],
    rows=[
        ['afficherlocalisation()',
         'Affiche le centre sur la carte interactive (flutter_map + OpenStreetMap) avec un marqueur cliquable'],
        ['Filtrage par categorie',
         'Permet de filtrer les centres affiches sur la carte par type de dechet accepte (9 filtres disponibles)'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  3. ECOBOT
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 3, 'EcoBot',
              'ChatService  +  ChatNotifier',
              'Frontend/lib/services/chat_service.dart  |  Frontend/lib/providers/chat_provider.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 38, 110],
    headers=['Attribut', 'Type', 'Description'],
    rows=[
        ['id  (_dio)',          'Dio',
         'Client HTTP configure vers le backend Gemini RAG (ecoscan-chatbot.onrender.com)'],
        ['BaseConnaissance\n(_offlineFallback)', 'String (fonction)',
         'Base de connaissances hors-ligne integree : reponses sur le tri des dechets, la navigation dans l\'app et les contacts operateurs (FR / EN / AR / ES / Darija)'],
        ['history',            'List<ChatMessage>',
         'Historique des messages de la session en cours (envoye au backend pour contexte)'],
        ['baseUrl',            'String',
         'URL du backend depuis ApiConstants (ecoscan-chatbot.onrender.com)'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode', 'Signature / Description'],
    rows=[
        ['repondreQuestion()  ->  sendMessage()',
         'sendMessage(String message, {List<Map> history = const []}) -> Future<String>\nEnvoi du message au backend Gemini, retour nettoye (sans markdown **)'],
        ['fournirConseil()  ->  _offlineFallback()',
         '_offlineFallback(String message) -> String\nRepond localement si le backend est indisponible : 20+ categories (dechets, navigation, contacts)'],
        ['isHealthy()',
         'Future<bool>  -  Ping /health pour verifier la disponibilite du serveur backend'],
        ['_cleanMarkdown()',
         'Supprime les symboles markdown generes par Gemini : **, __, ##, *'],
        ['_containsAny()',
         '_containsAny(String text, List<String> keywords) -> bool  -  Detection de mots-cles'],
        ['reset()  (ChatNotifier)',
         'Vide l\'historique de conversation et reinitialise l\'etat du chat'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  4. UTILISATEUR
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 4, 'Utilisateur',
              'AppUser  +  UserModel',
              'Frontend/lib/providers/auth_provider.dart  |  Frontend/lib/models/user_model.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Description'],
    rows=[
        ['id',          'String',  'uid  -  Identifiant unique Firebase Auth'],
        ['nom',         'String',  'displayName  -  Prenom + Nom de l\'utilisateur'],
        ['email',       'String',  'email  -  Adresse email (Firebase Auth)'],
        ['MotDePasse',  'String',  'Gere par Firebase Auth - non stocke en clair dans l\'app'],
        ['-',           'String',  'city  -  Ville de l\'utilisateur (stockee dans Firestore)'],
        ['-',           'String?', 'photoUrl  -  URL photo de profil (nullable)'],
        ['-',           'int',     'points  -  Points eco cumules'],
        ['-',           'int',     'scans  -  Nombre total de scans effectues'],
        ['-',           'int',     'badges  -  Nombre de badges debloques'],
        ['-',           'int',     'rank  -  Classement dans le leaderboard communautaire'],
        ['-',           'int',     'level / xp / xpMax  -  Niveau et points d\'experience (xpMax defaut : 200)'],
        ['-',           'double',  'co2Saved  -  CO2 total evite en grammes'],
        ['-',           'int',     'streak  -  Nombre de jours consecutifs d\'utilisation'],
        ['-',           'double',  'weeklyGoalKg / weeklyProgress  -  Objectif et avancement hebdomadaire'],
        ['-',           'List<Map>','recentScans  -  Derniers scans de l\'utilisateur'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['sAuthentifier()',
         'login(String email, String password) -> Future<void>  |  Google signIn()\nAuthentification Firebase + chargement du profil depuis Firestore'],
        ['scannerDechet()',
         'ScanApiService.classify(File imageFile) -> Future<ScanApiResult?>\nAppel API YOLOv8 cloud pour analyser l\'image du dechet'],
        ['consulterHistorique()',
         'ScanHistoryNotifier.loadHistory() -> Future<void>\nCharge l\'historique depuis SharedPreferences puis Firestore si vide'],
        ['consulterStatistiques()',
         'Stream userProvider + communityStatsProvider\nFlux temps reel : points, scans, co2, streak, level, classement'],
        ['dialoguerAvecEcoBot()',
         'ChatService.sendMessage(String message, {List history}) -> Future<String>'],
        ['register()',
         'register({firstName, lastName, email, password, city}) -> Future<void>\nCreation compte Firebase + document Firestore + email de verification'],
        ['signOut()',
         'Efface SharedPreferences + deconnexion Google + Firebase Auth'],
        ['copyWith()',
         'UserModel.copyWith(...) -> UserModel  -  Mise a jour partielle du modele utilisateur'],
        ['AppUser.fromFirebase()',
         'factory AppUser.fromFirebase(User fbUser, {String city}) -> AppUser\nConvertit un utilisateur Firebase en AppUser'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  5. RESULTAT SCAN
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 5, 'ResultatScan',
              'ScanEntry',
              'Frontend/lib/models/scan_entry.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[45, 28, 117],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Description'],
    rows=[
        ['id',             'String',   'id  -  Timestamp en millisecondes (identifiant unique du scan)'],
        ['scoreconfiance', 'double',   'recyclability  -  Score de recyclabilite 0.0 -> 1.0\n(confiance YOLOv8 x taux de la categorie)'],
        ['consigneTri',    'String',   "binColor  -  Couleur de poubelle recommandee :\n'Bleu', 'Jaune', 'Vert', 'Marron', 'Noir', 'Eco-point'"],
        ['-',              'String',   "name  -  Nom lisible : 'Plastique recyclable', 'Verre recyclable'..."],
        ['-',              'String',   "category  -  Label interne : 'plastique', 'verre', 'metal'..."],
        ['-',              'bool',     'recyclable  -  true si le dechet est recyclable'],
        ['-',              'bool',     'dangerous  -  true pour les DEEE (appareils electroniques)'],
        ['-',              'int',      'points  -  Points gagnes (ajuste par confidence : pts * conf, clamp a pts/2..pts)'],
        ['-',              'double',   'co2Saved  -  CO2 evite en grammes (ajuste par confidence)'],
        ['-',              'DateTime', 'scannedAt  -  Horodatage du scan'],
        ['-',              'String',   "mode  -  'cloud' (YOLOv8 API) ou 'local' (TFLite embarque)"],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['afficherResultat()',
         'ScanResultScreen  -  Affiche name, binColor, points, co2Saved, recyclability\navec code couleur et icone de la categorie'],
        ['fromClassification()',
         'static fromClassification(String label, double confidence) -> ScanEntry\nConstruit un ScanEntry complet depuis le label YOLOv8 et le score de confiance'],
        ['toJson()',
         'Map<String, dynamic>  -  Serialisation pour SharedPreferences et Firestore'],
        ['fromJson()',
         'factory ScanEntry.fromJson(Map<String, dynamic> json) -> ScanEntry\nDeserialisation depuis JSON'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  6. SCAN
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 6, 'Scan',
              'ScanApiService  +  ClassifierService',
              'Frontend/lib/services/scan_api_service.dart  |  Frontend/lib/services/classifier_service_io.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 38, 110],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Description'],
    rows=[
        ['id  (topLabel)',    'String',
         'Label principal detecte par YOLOv8 (traduit en categorie EcoScan via _translateLabel)'],
        ['DateScan',         'DateTime',
         'scannedAt dans le ScanEntry resultant  -  date et heure du scan'],
        ['-',                'double',
         'topConfidence  -  Score de confiance YOLOv8 (seuil minimum client : 0.40)'],
        ['-',                'List<Detection>',
         'detections  -  Liste de toutes les detections dans l\'image (label + confidence)'],
        ['-',                'Dio (static)',
         '_dio  -  Client HTTP vers ecoscan-model-online.onrender.com\n(timeout connect 30s, receive 60s pour Render cold start)'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['analyserImage()',
         'static classify(File imageFile) -> Future<ScanApiResult?>\nEnvoi de l\'image au backend YOLOv8 via multipart/form-data\nRetourne null si serveur indisponible (fallback TFLite)'],
        ['obtenirConsignes()',
         'static _translateLabel(String label) -> String\nTraduction de 80+ labels YOLO/TACO vers les categories EcoScan\n(Glass bottle -> verre, Drink can -> metal, etc.)'],
        ['isAvailable()',
         'static Future<bool>  -  Ping /health pour reveiller le serveur Render (cold start)\nA appeler au demarrage de l\'app'],
        ['ClassifierService.classify()',
         'Fallback TFLite local (EfficientNetV2B0) si le cloud YOLOv8 est indisponible'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  7. HISTORIQUE SCAN
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 7, 'HistoriqueScan',
              'ScanHistoryNotifier',
              'Frontend/lib/providers/scan_history_provider.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 38, 110],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Description'],
    rows=[
        ['id',           'String',
         'UID Firebase de l\'utilisateur  -  cle Firestore users/{uid}/scans'],
        ['listescans',   'List<ScanEntry>',
         'state  -  Liste des entrees de scan\n(max 200 via Firestore stream, 50 charges initialement)'],
        ['-',            'double (getter)',
         'totalCo2Saved  -  Somme du CO2 evite de tous les scans'],
        ['-',            'int (getter)',
         'totalPoints  -  Somme des points gagnes sur tous les scans'],
        ['-',            'int (getter)',
         'recyclableCount  -  Nombre de scans avec un dechet recyclable'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['ajouterScan()',
         'addScan(ScanEntry entry) -> void\nAjoute le scan en tete de liste + persist en JSON dans SharedPreferences'],
        ['ConsulterHistorique()',
         'loadHistory() -> Future<void>\n1. Charge depuis SharedPreferences (rapide, hors-ligne)\n2. Si vide : charge depuis Firestore (users/{uid}/scans, limit 50)'],
        ['_loadFromFirestore()',
         '_loadFromFirestore(String uid) -> Future<void>\nSynchronisation Firestore -> etat local + sauvegarde SharedPreferences'],
        ['_saveToPrefs()',
         'Serialise l\'etat complet (List<ScanEntry>) en JSON dans SharedPreferences'],
        ['scanHistoryStreamProvider',
         'StreamProvider<List<ScanEntry>>  -  Flux Firestore temps reel (limit 200)\npour les ecrans de statistiques'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  8. STATISTIQUE
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 8, 'Statistique',
              'CommunityStats  +  UserModel',
              'Frontend/lib/providers/community_stats_provider.dart')

sub_header(pdf, 'Attributs - Statistiques communautaires (CommunityStats) :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Calcul'],
    rows=[
        ['id',          'Firestore',
         'Document community_totals/stats  -  cle du document des totaux globaux'],
        ['nombreScans', 'int',
         'scans  -  Calcule : totalPoints / 10  (10 pts en moyenne par scan)'],
        ['co2Evite',    'int',
         'kgRecycled  -  Calcule : scans x 0.35 kg de CO2 evite'],
        ['point',       'int',
         'users  -  Nombre d\'utilisateurs actifs via Firestore count()'],
        ['-',           'double',
         'progress  -  Progression objectif communautaire 50 000 pts (0.0 -> 1.0)'],
    ])

pdf.ln(2)
sub_header(pdf, 'Attributs - Statistiques utilisateur (UserModel) :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Description'],
    rows=[
        ['nombreScans', 'int',    'scans  -  Nombre total de scans de l\'utilisateur'],
        ['co2Evite',    'double', 'co2Saved  -  CO2 total evite en grammes'],
        ['point',       'int',    'points  -  Points eco cumules'],
        ['-',           'int',    'streak  -  Jours consecutifs d\'utilisation'],
        ['-',           'int',    'level / xp  -  Niveau et experience de l\'utilisateur'],
        ['-',           'double', 'weeklyProgress  -  Avancement objectif hebdomadaire (defaut : 10 kg)'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['calculerImpact()',
         'communityStatsProvider (StreamProvider)\nAggregation automatique Firestore : points top 100 utilisateurs + deletedPoints\n(impact communautaire preserve apres suppression de comptes)'],
        ['afficherStatistiques()',
         'StatsScreen  -  Affiche graphiques CO2, points, tendances,\nprogression hebdomadaire et contributions communautaires'],
        ['copyWith()',
         'UserModel.copyWith(...) -> UserModel  -  Mise a jour partielle des statistiques'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  9. MESSAGE CHAT
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 9, 'MessageChat',
              'ChatMessage',
              'Frontend/lib/models/chat_message.dart')

sub_header(pdf, 'Attributs :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut UML', 'Type', 'Attribut Dart / Description'],
    rows=[
        ['id',      'String',   'id  -  Timestamp en microsecondes (identifiant unique du message)'],
        ['contenu', 'String',   'text  -  Texte du message (utilisateur ou EcoBot)'],
        ['type',    'bool',     'isUser  -  true = message utilisateur  |  false = message EcoBot'],
        ['date',    'DateTime', 'timestamp  -  Horodatage de creation du message'],
        ['-',       'bool',     'isLoading  -  true : animation de chargement (bot en train de repondre)'],
        ['-',       'bool?',    'feedback  -  null = non note  |  true = pouce haut  |  false = pouce bas'],
    ])

sub_header(pdf, 'Methodes :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['envoyerMessage()',
         'factory ChatMessage.user(String text) -> ChatMessage\nCree un message utilisateur avec id unique et timestamp automatique'],
        ['afficherMessage()',
         'factory ChatMessage.bot(String text) -> ChatMessage\nCree un message EcoBot avec id unique et timestamp automatique'],
        ['-',
         'factory ChatMessage.loading() -> ChatMessage\nCree un message d\'attente avec animation (isLoading = true)'],
        ['-',
         'static getter ChatMessage.welcome -> ChatMessage\nMessage d\'accueil : "Bonjour ! Je suis EcoBot..."'],
        ['-',
         'copyWith({String? text, bool? isLoading, bool? feedback}) -> ChatMessage\nMise a jour partielle d\'un message existant'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
#  10. NOTIFICATION
# ══════════════════════════════════════════════════════════════════════════════
section_title(pdf, 10, 'Notification',
              'NotificationService  +  Firestore',
              'Frontend/lib/services/notification_service.dart')

sub_header(pdf, 'Attributs (document Firestore : users/{uid}/notifications/{id}) :')
table(pdf,
    col_widths=[42, 28, 120],
    headers=['Attribut UML', 'Type', 'Champ Firestore / Description'],
    rows=[
        ['id',      'String',    'id (doc.id)  -  Identifiant document Firestore genere automatiquement'],
        ['titre',   'String',    'title  -  Titre de la notification push ou locale'],
        ['message', 'String',    'body  -  Corps du message de notification'],
        ['-',       'Map',       'data  -  Donnees FCM supplementaires (routing, payload)'],
        ['-',       'bool',      'read  -  false = non lue  |  true = lue par l\'utilisateur'],
        ['date',    'Timestamp', 'createdAt  -  Timestamp serveur Firestore (FieldValue.serverTimestamp())'],
        ['-',       'String',    'fcmToken  -  Token FCM de l\'appareil (stocke dans users/{uid})'],
    ])

sub_header(pdf, 'Methodes (toutes static dans NotificationService) :')
table(pdf,
    col_widths=[65, 125],
    headers=['Methode UML', 'Methode Dart / Description'],
    rows=[
        ['envoyerNotification()',
         '_showLocal({String title, String body}) -> Future<void>\nAffiche une notification locale via FlutterLocalNotificationsPlugin'],
        ['-',
         'static Future<void> init()\nInitialise FCM + permissions Android/iOS + timezone Africa/Casablanca\n+ canal ecoscan_channel + ecoute token refresh'],
        ['-',
         'static Future<void> scheduleDailyReminders()\nPlanifie un rappel quotidien a 8h00 : "Triez vos dechets aujourd\'hui et gagnez des points !"'],
        ['-',
         'static Future<void> scheduleWeeklyChallengeReminder()\nPlanifie un rappel chaque lundi a 8h00 : "Nouveaux defis hebdomadaires !"'],
        ['-',
         'static Future<void> showNewRewardUnlocked(String rewardName)\nAffiche une notification "Recompense disponible" quand l\'utilisateur a assez de points'],
        ['-',
         'static Future<void> markAsRead(String notificationId)\nMet a jour read = true dans Firestore pour la notification donnee'],
        ['-',
         'static Stream<List<Map>> getNotifications()\nFlux temps reel des 50 dernieres notifications de l\'utilisateur\n(ordonnees par createdAt descendant)'],
    ])

# ══════════════════════════════════════════════════════════════════════════════
out = r'c:\Users\H.Badreddine\Desktop\PFE\ecoscan\EcoScan_DiagrammeClasses.pdf'
pdf.output(out)
print(f'PDF genere : {out}')
