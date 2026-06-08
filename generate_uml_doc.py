from fpdf import FPDF
import os

# ─── Couleurs ────────────────────────────────────────────────────────────────
GREEN_DARK   = (27,  94,  32)
GREEN_MID    = (56, 142,  60)
GREEN_LIGHT  = (200, 230, 201)
GREEN_BG     = (232, 245, 233)
BLUE_DARK    = (21,  101, 192)
BLUE_LIGHT   = (227, 242, 253)
GREY_LIGHT   = (245, 245, 245)
GREY_MID     = (224, 224, 224)
WHITE        = (255, 255, 255)
BLACK        = (33,  33,  33)
ORANGE       = (230, 81,   0)
PURPLE       = (74,  20, 140)
TEAL         = (0,  105, 92)

FONT_PATH = "C:\\Windows\\Fonts\\"

class EcoScanPDF(FPDF):
    def __init__(self):
        super().__init__(orientation="L", unit="mm", format="A4")
        self.set_auto_page_break(auto=True, margin=15)
        self.set_margins(15, 15, 15)
        self.add_font("Arial", "",  FONT_PATH + "arial.ttf")
        self.add_font("Arial", "B", FONT_PATH + "arialbd.ttf")
        self.add_font("Arial", "I", FONT_PATH + "ariali.ttf")

    # ── En-tête de page ──────────────────────────────────────────────────────
    def header(self):
        self.set_fill_color(*GREEN_DARK)
        self.rect(0, 0, 297, 12, "F")
        self.set_font("Arial", "B", 9)
        self.set_text_color(*WHITE)
        self.set_xy(15, 2)
        self.cell(0, 8, "EcoScan — Documentation UML", ln=False)
        self.set_xy(0, 2)
        self.cell(282, 8, "Diagrammes : Cas d'Utilisation | Sequences | Classes", align="R")
        self.set_text_color(*BLACK)
        self.ln(14)

    # ── Pied de page ─────────────────────────────────────────────────────────
    def footer(self):
        self.set_y(-12)
        self.set_fill_color(*GREEN_LIGHT)
        self.rect(0, self.get_y(), 297, 12, "F")
        self.set_font("Arial", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(0, 8, f"Page {self.page_no()}", align="C")
        self.set_text_color(*BLACK)

    # ── Titre de section principale ──────────────────────────────────────────
    def section_title(self, num, title, color=GREEN_DARK):
        self.ln(4)
        self.set_fill_color(*color)
        self.set_text_color(*WHITE)
        self.set_font("Arial", "B", 13)
        self.cell(0, 10, f"  {num}  {title}", ln=True, fill=True)
        self.set_text_color(*BLACK)
        self.ln(3)

    # ── Titre de sous-section ────────────────────────────────────────────────
    def subsection_title(self, title, color=GREEN_MID):
        self.ln(2)
        self.set_fill_color(*color)
        self.set_text_color(*WHITE)
        self.set_font("Arial", "B", 10)
        self.cell(0, 7, f"   {title}", ln=True, fill=True)
        self.set_text_color(*BLACK)
        self.ln(2)

    # ── Titre de groupe (package) ────────────────────────────────────────────
    def group_title(self, title, color=BLUE_DARK):
        self.set_fill_color(*BLUE_LIGHT)
        self.set_draw_color(*color)
        self.set_line_width(0.5)
        self.set_font("Arial", "B", 9)
        self.set_text_color(*color)
        self.cell(0, 6, f"  {title}", ln=True, fill=True, border="LB")
        self.set_text_color(*BLACK)
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.2)
        self.ln(1)

    # ── Item de liste ────────────────────────────────────────────────────────
    def list_item(self, text, indent=8, bullet="•", color=GREEN_MID):
        self.set_font("Arial", "", 8.5)
        self.set_text_color(*color)
        self.set_x(self.l_margin + indent)
        self.cell(5, 5.5, bullet)
        self.set_text_color(*BLACK)
        self.set_font("Arial", "", 8.5)
        self.multi_cell(0, 5.5, text)

    # ── Item avec badge (include/extend) ────────────────────────────────────
    def list_item_badge(self, text, badge, indent=16):
        self.set_font("Arial", "", 8.5)
        self.set_x(self.l_margin + indent)
        self.cell(3, 5.5, "")
        bw = 22
        if badge == "include":
            self.set_fill_color(21, 101, 192)
        else:
            self.set_fill_color(230, 81, 0)
        self.set_text_color(*WHITE)
        self.set_font("Arial", "B", 7)
        self.cell(bw, 5.5, f"<<{badge}>>", fill=True, align="C")
        self.set_text_color(*BLACK)
        self.set_font("Arial", "", 8.5)
        self.cell(0, 5.5, f"  {text}", ln=True)

    # ── Cellule tableau ──────────────────────────────────────────────────────
    def table_header(self, cols):
        self.set_fill_color(*GREEN_DARK)
        self.set_text_color(*WHITE)
        self.set_font("Arial", "B", 8.5)
        for text, w in cols:
            self.cell(w, 7, f"  {text}", border=1, fill=True)
        self.ln()
        self.set_text_color(*BLACK)

    def table_row(self, cells, cols_w, shade=False):
        self.set_fill_color(*GREY_LIGHT if shade else WHITE)
        self.set_font("Arial", "", 8)
        for (text, w) in zip(cells, cols_w):
            self.cell(w, 6, f"  {text}", border=1, fill=True)
        self.ln()

    # ── Bloc de code / séquence ──────────────────────────────────────────────
    def code_line(self, text, indent=0, color=BLACK, bold=False):
        self.set_fill_color(*GREY_LIGHT)
        self.set_font("Arial", "B" if bold else "", 8)
        self.set_text_color(*color)
        self.set_x(self.l_margin + indent)
        self.cell(0, 5.5, text, ln=True, fill=True)
        self.set_text_color(*BLACK)

    def actor_badge(self, label, kind="human"):
        color = BLUE_DARK if kind == "human" else TEAL
        self.set_fill_color(*color)
        self.set_text_color(*WHITE)
        self.set_font("Arial", "B", 8)
        self.cell(60, 6, f"  {label}", fill=True, border=0)
        self.set_text_color(*BLACK)
        self.ln()


# ═════════════════════════════════════════════════════════════════════════════
#   PAGE DE TITRE
# ═════════════════════════════════════════════════════════════════════════════
pdf = EcoScanPDF()
pdf.add_page()

# Bande verte haute
pdf.set_fill_color(*GREEN_DARK)
pdf.rect(0, 12, 297, 55, "F")

# Logo / icone
pdf.set_fill_color(*GREEN_LIGHT)
pdf.rect(15, 18, 30, 30, "F")
pdf.set_font("Arial", "B", 18)
pdf.set_text_color(*GREEN_DARK)
pdf.set_xy(15, 25)
pdf.cell(30, 16, "ECO", align="C")

# Titre
pdf.set_xy(52, 18)
pdf.set_font("Arial", "B", 26)
pdf.set_text_color(*WHITE)
pdf.cell(0, 14, "EcoScan")
pdf.set_xy(52, 34)
pdf.set_font("Arial", "", 13)
pdf.cell(0, 8, "Application Mobile de Gestion des Dechets et Recyclage")
pdf.set_xy(52, 44)
pdf.set_font("Arial", "I", 10)
pdf.set_text_color(200, 230, 201)
pdf.cell(0, 7, "Plateforme Flutter  |  Firebase  |  IA / ML  |  Communaute")

# Sous-titre doc
pdf.set_text_color(*BLACK)
pdf.set_xy(15, 75)
pdf.set_font("Arial", "B", 14)
pdf.set_fill_color(*GREEN_LIGHT)
pdf.cell(267, 10, "  Documentation UML — Diagrammes de Conception", fill=True)

# 3 cartes
card_y = 92
cards = [
    (GREEN_DARK,  "01", "Cas d'Utilisation", "Acteurs, Use Cases, include/extend, systemes externes"),
    (BLUE_DARK,   "02", "Sequences",          "3 scenarios : Scanner, Login, EcoBot"),
    (PURPLE,      "03", "Classes",            "Modeles, Services, Providers et relations"),
]
for i, (col, num, title, desc) in enumerate(cards):
    x = 15 + i * 89
    pdf.set_fill_color(*col)
    pdf.rect(x, card_y, 85, 40, "F")
    pdf.set_xy(x + 3, card_y + 4)
    pdf.set_font("Arial", "B", 22)
    pdf.set_text_color(*WHITE)
    pdf.cell(20, 14, num)
    pdf.set_xy(x + 3, card_y + 18)
    pdf.set_font("Arial", "B", 10)
    pdf.cell(79, 7, title)
    pdf.set_xy(x + 3, card_y + 27)
    pdf.set_font("Arial", "I", 7.5)
    pdf.set_text_color(220, 240, 220 if col == GREEN_DARK else 220)
    pdf.multi_cell(79, 5, desc)

pdf.set_text_color(*BLACK)
pdf.set_xy(15, 140)
pdf.set_font("Arial", "", 8.5)
pdf.set_text_color(100, 100, 100)
pdf.cell(0, 6, "PFE 2025-2026   |   Hammoucha Badreddine   |   badreddinehammoucha@gmail.com", align="C")


# ═════════════════════════════════════════════════════════════════════════════
#   PARTIE 1 — CAS D'UTILISATION
# ═════════════════════════════════════════════════════════════════════════════
pdf.add_page()
pdf.section_title("PARTIE 1", "Diagramme de Cas d'Utilisation", GREEN_DARK)

# ── Acteurs ──────────────────────────────────────────────────────────────────
pdf.subsection_title("Acteurs")

pdf.set_font("Arial", "B", 9)
pdf.set_fill_color(*BLUE_DARK)
pdf.set_text_color(*WHITE)
pdf.cell(60, 6, "  Acteurs Humains", fill=True)
pdf.ln(8)

human_actors = [
    ("Utilisateur (non connecte)", "Acteur principal — peut s'inscrire, se connecter"),
    ("Utilisateur Connecte",       "Herite de Utilisateur — acces a toutes les fonctionnalites"),
]
for name, desc in human_actors:
    pdf.set_fill_color(*BLUE_LIGHT)
    pdf.set_font("Arial", "B", 8.5)
    pdf.set_x(self_margin := 8 + pdf.l_margin)
    pdf.cell(55, 6, f"  {name}", fill=True, border="L")
    pdf.set_font("Arial", "I", 8)
    pdf.set_fill_color(*GREY_LIGHT)
    pdf.cell(0, 6, f"  {desc}", fill=True)
    pdf.ln()
pdf.ln(3)

pdf.set_font("Arial", "B", 9)
pdf.set_fill_color(*TEAL)
pdf.set_text_color(*WHITE)
pdf.cell(60, 6, "  Systemes Externes (acteurs)", fill=True)
pdf.ln(8)
pdf.set_text_color(*BLACK)

ext_actors = [
    ("Firebase Auth",       "Authentification email, Google, 2FA, changement mot de passe"),
    ("YOLOv8 API / TFLite", "Classification des dechets (ML cloud + on-device)"),
    ("Gemini RAG API",      "LLM pour le chatbot EcoBot avec ChromaDB"),
    ("OpenWeatherMap API",  "Meteo en temps reel et qualite de l'air (AQI)"),
    ("Open Food Facts API", "Donnees produits alimentaires via code-barres"),
    ("Firestore",           "Base de donnees principale (scans, users, marketplace, defis)"),
    ("Firebase FCM",        "Push notifications (rappels quotidiens, evenements)"),
    ("Cloudinary",          "CDN images pour les annonces du marketplace"),
]
cols_w = [55, 0]
for i, (name, desc) in enumerate(ext_actors):
    pdf.set_fill_color(*GREY_LIGHT if i % 2 == 0 else WHITE)
    pdf.set_x(pdf.l_margin + 8)
    pdf.set_font("Arial", "B", 8.5)
    pdf.set_fill_color(232, 245, 233)
    pdf.cell(58, 6, f"  {name}", fill=True, border="L")
    pdf.set_font("Arial", "", 8)
    pdf.set_fill_color(*GREY_LIGHT if i % 2 == 0 else WHITE)
    pdf.cell(0, 6, f"  {desc}", fill=True)
    pdf.ln()
pdf.ln(4)

# ── Packages de cas d'utilisation ────────────────────────────────────────────
packages = [
    {
        "title": "Package 1 — Authentification",
        "color": GREEN_DARK,
        "items": [
            ("normal",   "S'inscrire (3 etapes : informations personnelles, ville, verification email)"),
            ("normal",   "Se connecter (email / mot de passe)"),
            ("normal",   "Se connecter via Google"),
            ("normal",   "Verifier son adresse email"),
            ("normal",   "Changer son mot de passe"),
            ("normal",   "Activer la double authentification (2FA)"),
        ]
    },
    {
        "title": "Package 2 — Scan & Classification",
        "color": BLUE_DARK,
        "items": [
            ("normal",  "Scanner un dechet (camera + ML)"),
            ("include", "Classifier localement (TFLite)"),
            ("extend",  "Classifier via API cloud (YOLOv8)"),
            ("normal",  "Consulter le resultat du scan (categorie, poubelle, CO2 economise, EcoPoints)"),
            ("normal",  "Scanner un code-barres (produit alimentaire)"),
            ("include", "Recuperer infos produit (Open Food Facts) — NutriScore, EcoScore, emballage"),
            ("normal",  "Consulter l'historique des scans"),
            ("normal",  "Supprimer l'historique"),
        ]
    },
    {
        "title": "Package 3 — Statistiques & Gamification",
        "color": PURPLE,
        "items": [
            ("normal",  "Consulter ses statistiques personnelles (CO2, points, niveau, XP, streak)"),
            ("normal",  "Consulter ses badges (debloques selon jalons : 1, 5, 10, 50 scans...)"),
            ("normal",  "Consulter et progresser dans les defis quotidiens / hebdomadaires"),
            ("include", "Defi : Utiliser EcoBot (1 fois par jour)"),
            ("include", "Defi : Ouvrir la carte (1 fois par jour)"),
            ("include", "Defi : Partager du contenu (1 fois par jour)"),
            ("normal",  "Consulter le classement communautaire (Leaderboard — top 100)"),
            ("normal",  "Echanger ses EcoPoints contre des recompenses"),
        ]
    },
    {
        "title": "Package 4 — Donnees Environnementales",
        "color": TEAL,
        "items": [
            ("normal", "Consulter la meteo (geolocalisation GPS ou saisie ville)"),
            ("normal", "Consulter la qualite de l'air — AQI, PM2.5, PM10, NO2, O3, CO, SO2, NH3"),
            ("normal", "Consulter l'empreinte eau personnelle"),
            ("normal", "Passer le quiz eco-educatif (25 questions avec EcoPoints a la cle)"),
        ]
    },
    {
        "title": "Package 5 — EcoBot & Guide",
        "color": (130, 0, 0),
        "items": [
            ("normal",  "Envoyer un message a EcoBot"),
            ("include", "Reponse en ligne via Gemini RAG (ChromaDB + LangChain)"),
            ("extend",  "Reponse hors ligne — base de reponses locales (FR/AR/ES/Darija)"),
            ("normal",  "Consulter le guide de tri des dechets (par categorie)"),
            ("normal",  "Trouver un operateur de collecte (AVERDA, ARMA, ONEE, Eco Zalagh...)"),
        ]
    },
    {
        "title": "Package 6 — Marketplace (Eco-Marche)",
        "color": ORANGE,
        "items": [
            ("normal",  "Parcourir les annonces (recherche, filtre par categorie, tri par date/prix)"),
            ("normal",  "Consulter le detail d'une annonce (photos, description, vendeur, avis)"),
            ("normal",  "Publier une annonce (don +15pts, vente +5pts, echange +5pts)"),
            ("include", "Uploader des photos via Cloudinary CDN"),
            ("normal",  "Modifier / supprimer ses propres annonces"),
            ("normal",  "Laisser un avis sur un vendeur (etoiles 1-5 + commentaire)"),
            ("normal",  "Contacter un vendeur (telephone / WhatsApp)"),
        ]
    },
    {
        "title": "Package 7 — Carte & Geolocalisation",
        "color": (0, 77, 64),
        "items": [
            ("normal",  "Ouvrir la carte des points de collecte (OpenStreetMap + clustering)"),
            ("include", "Detecter sa position GPS (avec fallback Casablanca)"),
        ]
    },
    {
        "title": "Package 8 — Profil & Parametres",
        "color": (50, 50, 120),
        "items": [
            ("normal", "Modifier son profil (nom, ville, avatar photo)"),
            ("normal", "Changer la langue de l'application (FR / EN / AR / ES)"),
            ("normal", "Changer le theme visuel (clair / sombre / systeme)"),
            ("normal", "Gerer les notifications (activer / desactiver rappels)"),
            ("normal", "Consulter les notifications recues"),
        ]
    },
]

for pkg in packages:
    pdf.group_title(pkg["title"], pkg["color"])
    for kind, text in pkg["items"]:
        if kind == "normal":
            pdf.list_item(text)
        else:
            pdf.list_item_badge(text, kind)
    pdf.ln(2)

# ── Relations include/extend résumé ─────────────────────────────────────────
pdf.add_page()
pdf.section_title("1.2", "Relations Include / Extend — Resume", BLUE_DARK)

includes = [
    ("S'inscrire",                    "Verifier son email"),
    ("Scanner un dechet",             "Classifier localement (TFLite)"),
    ("Scanner un dechet",             "Consulter le resultat du scan"),
    ("Scanner un code-barres",        "Recuperer infos produit (OFF)"),
    ("Progresser dans les defis",     "Defi : Utiliser EcoBot"),
    ("Progresser dans les defis",     "Defi : Ouvrir la carte"),
    ("Progresser dans les defis",     "Defi : Partager du contenu"),
    ("Publier une annonce",           "Uploader des photos (Cloudinary)"),
    ("Envoyer message EcoBot",        "Reponse en ligne (Gemini RAG)"),
    ("Ouvrir la carte",               "Detecter position GPS"),
]
extends = [
    ("Scanner un dechet",       "Classifier via API cloud (YOLOv8)"),
    ("Envoyer message EcoBot",  "Reponse hors ligne (base locale)"),
    ("Consulter la meteo",      "Detecter position GPS"),
    ("Consulter qualite air",   "Detecter position GPS"),
]

pdf.subsection_title("Relations <<include>> — comportement obligatoire", BLUE_DARK)
pdf.table_header([("Cas de base", 110), ("Cas inclus", 130)])
for i, (base, inc) in enumerate(includes):
    pdf.table_row([base, inc], [110, 130], i % 2 == 0)

pdf.ln(4)
pdf.subsection_title("Relations <<extend>> — comportement conditionnel", (200, 80, 0))
pdf.table_header([("Cas de base", 110), ("Cas d'extension", 130)])
for i, (base, ext) in enumerate(extends):
    pdf.table_row([base, ext], [110, 130], i % 2 == 0)


# ═════════════════════════════════════════════════════════════════════════════
#   PARTIE 2 — DIAGRAMMES DE SEQUENCES
# ═════════════════════════════════════════════════════════════════════════════
pdf.add_page()
pdf.section_title("PARTIE 2", "Diagrammes de Sequences", BLUE_DARK)

sequences = [
    {
        "num": "Sequence 1",
        "title": "Scanner un dechet (Scan & Classification)",
        "color": GREEN_DARK,
        "steps": [
            ("Utilisateur",          "ScanScreen",            "Capture image via camera",                   False),
            ("ScanScreen",           "ClassifierService",     "classify(imageFile)  [TFLite local]",        False),
            ("ClassifierService",    "ScanApiService",        "classify(file)  [si API disponible]",        True),
            ("ScanApiService",       "YOLOv8 API",            "POST /scan  — image multipart",              False),
            ("YOLOv8 API",           "ScanApiService",        "Retourne : categorie + confidence",          False),
            ("ScanApiService",       "ScanScreen",            "ScanResultModel (categorie, binColor, CO2)", False),
            ("ScanScreen",           "ScanResultScreen",      "Navigation avec resultat",                   False),
            ("ScanResultScreen",     "StorageService",        "addScan(entry)",                             False),
            ("StorageService",       "Firestore",             "Enregistre ScanEntry (users/{id}/scans)",    False),
            ("StorageService",       "ScanHistoryProvider",   "Mise a jour liste scans",                    False),
            ("ScanHistoryProvider",  "UserProvider",          "Mise a jour points + CO2",                   False),
            ("UserProvider",         "Firestore",             "Sync stats utilisateur (points, scans, CO2)",False),
            ("ScanResultScreen",     "ChallengesNotifier",    "incrementScan()  [defi quotidien]",          False),
            ("ChallengesNotifier",   "Firestore",             "Mise a jour progression defi",               False),
        ]
    },
    {
        "num": "Sequence 2",
        "title": "Authentification — Connexion (Login)",
        "color": BLUE_DARK,
        "steps": [
            ("Utilisateur",       "LoginScreen",         "Saisie email + mot de passe",                False),
            ("LoginScreen",       "LoginNotifier",       "login(email, password)",                     False),
            ("LoginNotifier",     "Firebase Auth",       "signInWithEmailAndPassword()",               False),
            ("Firebase Auth",     "LoginNotifier",       "[Succes] UserCredential",                    False),
            ("Firebase Auth",     "LoginNotifier",       "[Echec] FirebaseAuthException",              True),
            ("LoginNotifier",     "currentUserProvider", "[Succes] setUser(AppUser)",                  False),
            ("currentUserProvider","Firestore",          "Charge UserModel depuis users/{uid}",        False),
            ("Firestore",         "UserProvider",        "Initialise etat utilisateur",                False),
            ("UserProvider",      "HomeScreen",          "Redirection via GoRouter",                   False),
            ("LoginNotifier",     "LoginScreen",         "[Echec] Affiche message erreur multi-langue",True),
        ]
    },
    {
        "num": "Sequence 3",
        "title": "Envoyer un message a EcoBot",
        "color": PURPLE,
        "steps": [
            ("Utilisateur",         "ChatScreen",           "Saisit et envoie un message",                False),
            ("ChatScreen",          "ChatNotifier",         "sendMessage(text)",                          False),
            ("ChatNotifier",        "ChatScreen",           "Affiche ChatMessage(isLoading: true)",        False),
            ("ChatNotifier",        "ChatService",          "sendMessage(text, history)",                  False),
            ("ChatService",         "Gemini RAG Backend",   "HTTP POST /chat  {message, history}",         False),
            ("Gemini RAG Backend",  "ChatService",          "[Succes] Reponse JSON {answer}",              False),
            ("Gemini RAG Backend",  "ChatService",          "[Echec reseau] Exception",                    True),
            ("ChatService",         "ChatNotifier",         "[Fallback] Reponse locale codee",             True),
            ("ChatNotifier",        "ChatScreen",           "Affiche ChatMessage bot",                     False),
            ("ChatScreen",          "ChallengesNotifier",   "useEcoBot()  [defi : EcoBot utilise]",        False),
            ("ChallengesNotifier",  "Firestore",            "Mise a jour ecoBotUsed = true",               False),
        ]
    },
]

for seq in sequences:
    pdf.subsection_title(f"{seq['num']} : {seq['title']}", seq["color"])

    # Participants
    participants = list(dict.fromkeys(
        [s[0] for s in seq["steps"]] + [s[1] for s in seq["steps"]]
    ))
    pdf.set_font("Arial", "B", 8)
    pdf.set_text_color(80, 80, 80)
    pdf.cell(25, 5, "Participants : ")
    pdf.set_font("Arial", "", 8)
    pdf.set_text_color(*BLACK)
    pdf.cell(0, 5, "  |  ".join(participants), ln=True)
    pdf.ln(1)

    # Tableau des etapes
    pdf.table_header([("#", 8), ("Emetteur", 50), ("Recepteur", 55), ("Message / Action", 115), ("Alt", 19)])
    for i, (src, dst, msg, alt) in enumerate(seq["steps"]):
        alt_txt = "ALT" if alt else ""
        pdf.set_fill_color(255, 248, 225 if alt else (245 if i%2==0 else 255))
        pdf.set_fill_color(*(255, 248, 225) if alt else (GREY_LIGHT if i%2==0 else WHITE))
        pdf.set_font("Arial", "", 8)
        pdf.cell(8,  5.5, f"  {i+1}", border=1, fill=True)
        pdf.cell(50, 5.5, f"  {src}", border=1, fill=True)
        pdf.cell(55, 5.5, f"  {dst}", border=1, fill=True)
        pdf.cell(115,5.5, f"  {msg}", border=1, fill=True)
        if alt:
            pdf.set_fill_color(255, 220, 150)
            pdf.set_font("Arial", "B", 7)
        pdf.cell(19, 5.5, f"  {alt_txt}", border=1, fill=True, align="C")
        pdf.ln()
        pdf.set_text_color(*BLACK)
    pdf.ln(5)


# ═════════════════════════════════════════════════════════════════════════════
#   PARTIE 3 — DIAGRAMME DE CLASSES
# ═════════════════════════════════════════════════════════════════════════════
pdf.add_page()
pdf.section_title("PARTIE 3", "Diagramme de Classes", PURPLE)

# ── 3.1 Modeles ──────────────────────────────────────────────────────────────
pdf.subsection_title("3.1  Modeles (Entites)", PURPLE)

models = [
    {
        "name": "UserModel",
        "color": GREEN_DARK,
        "attrs": [
            "id : String", "name : String", "city : String",
            "points : int", "scans : int", "badges : int",
            "rank : int", "level : int", "xp : int", "xpMax : int",
            "co2Saved : double", "weeklyGoalKg : double",
            "weeklyProgress : double", "recentScans : List<Map>",
            "streak : int",
        ],
        "methods": ["fromMap(Map) : UserModel", "toMap() : Map", "copyWith(...) : UserModel"],
    },
    {
        "name": "ScanEntry",
        "color": BLUE_DARK,
        "attrs": [
            "id : String", "name : String",
            "category : String", "recyclable : bool",
            "dangerous : bool", "points : int",
            "co2Saved : double", "recyclability : double",
            "binColor : String", "scannedAt : DateTime", "mode : String",
        ],
        "methods": ["fromMap(Map) : ScanEntry", "toMap() : Map"],
    },
    {
        "name": "ScanResultModel",
        "color": TEAL,
        "attrs": [
            "rawClass : String", "category : String",
            "binColor : String", "confidence : double",
            "co2SavedPerKg : double", "scannedAt : DateTime",
        ],
        "methods": [],
    },
    {
        "name": "ChatMessage",
        "color": PURPLE,
        "attrs": [
            "id : String", "text : String", "isUser : bool",
            "timestamp : DateTime", "isLoading : bool",
            "feedback : bool?",
        ],
        "methods": [],
    },
    {
        "name": "ListingModel",
        "color": ORANGE,
        "attrs": [
            "id : String", "title : String", "description : String",
            "type : String", "category : String", "price : double?",
            "city : String", "phone : String", "whatsapp : String",
            "imageUrls : List<String>", "userId : String",
            "userName : String", "createdAt : DateTime",
            "active : bool", "reviewAvg : double",
            "reviewCount : int", "trustedSeller : bool",
            "latitude : double?", "longitude : double?",
        ],
        "methods": ["fromMap(Map) : ListingModel", "toMap() : Map", "isTrustedSeller() : bool"],
    },
    {
        "name": "ReviewModel",
        "color": (130, 60, 0),
        "attrs": [
            "id : String", "reviewerId : String",
            "reviewerName : String", "stars : int",
            "comment : String", "createdAt : DateTime",
        ],
        "methods": [],
    },
    {
        "name": "FoodProduct",
        "color": (0, 100, 80),
        "attrs": [
            "barcode : String", "name : String", "brand : String",
            "imageUrl : String", "nutriScore : String",
            "ecoScore : String", "packaging : String",
            "packagingTags : List<String>",
            "packagingComponents : List<PackagingComponent>",
            "ingredients : String",
        ],
        "methods": [],
    },
    {
        "name": "ChallengeProgress",
        "color": (80, 0, 80),
        "attrs": [
            "dailyScans : int", "ecoBotUsed : bool",
            "guideViews : int", "mapOpened : bool",
            "shared : bool", "weeklyScans : int",
            "dayKey : String", "weekKey : String",
        ],
        "methods": [],
    },
    {
        "name": "WeatherData",
        "color": (0, 120, 180),
        "attrs": [
            "city : String", "temp : double",
            "description : String", "icon : String",
            "humidity : int", "windSpeed : double",
            "uvIndex : int", "condition : String",
        ],
        "methods": [],
    },
    {
        "name": "AirQualityData",
        "color": (100, 30, 0),
        "attrs": [
            "aqi : int", "city : String",
            "level : String", "levelAr : String",
            "levelEn : String", "levelEs : String",
            "color : int",
            "pollutants : Map<String, double>",
        ],
        "methods": [],
    },
    {
        "name": "CommunityStats",
        "color": (20, 80, 20),
        "attrs": [
            "users : int", "scans : int",
            "kgRecycled : int", "progress : double",
        ],
        "methods": [],
    },
]

def draw_class_card(pdf, model, x, y, w):
    h_head = 8
    h_attr = 5.2 * len(model["attrs"])
    h_meth = 5.2 * len(model["methods"]) if model["methods"] else 0
    sep = 3 if model["methods"] else 0

    # En-tete
    pdf.set_fill_color(*model["color"])
    pdf.set_draw_color(*model["color"])
    pdf.set_text_color(*WHITE)
    pdf.set_font("Arial", "B", 9)
    pdf.set_xy(x, y)
    pdf.cell(w, h_head, f"  {model['name']}", fill=True, border=1)
    pdf.ln()

    # Attributs
    pdf.set_fill_color(*GREY_LIGHT)
    pdf.set_draw_color(180, 180, 180)
    pdf.set_text_color(*BLACK)
    pdf.set_font("Arial", "", 7.5)
    for attr in model["attrs"]:
        pdf.set_xy(x, pdf.get_y())
        pdf.cell(w, 5.2, f"   - {attr}", fill=True, border="LR")
        pdf.ln()

    if model["methods"]:
        pdf.set_xy(x, pdf.get_y())
        pdf.set_fill_color(*model["color"])
        r, g, b = model["color"]
        pdf.set_fill_color(min(r+40,255), min(g+40,255), min(b+40,255))
        pdf.set_text_color(*WHITE)
        pdf.set_font("Arial", "B", 7.5)
        pdf.cell(w, 5, "  Methodes", fill=True, border="LR")
        pdf.ln()
        pdf.set_fill_color(245, 250, 245)
        pdf.set_text_color(*BLACK)
        pdf.set_font("Arial", "I", 7.5)
        for m in model["methods"]:
            pdf.set_xy(x, pdf.get_y())
            pdf.cell(w, 5.2, f"   + {m}", fill=True, border="LR")
            pdf.ln()

    pdf.set_xy(x, pdf.get_y())
    pdf.set_fill_color(*model["color"])
    pdf.cell(w, 2, "", fill=True, border="LRB")
    pdf.ln()

# Disposition en grille 3 colonnes
col_w = 83
gap   = 4
cols  = 3
rows_per_page = 4
start_x = [pdf.l_margin, pdf.l_margin + col_w + gap, pdf.l_margin + 2*(col_w+gap)]

col_idx = 0
row_start_y = [pdf.get_y(), pdf.get_y(), pdf.get_y()]

for model in models:
    x = start_x[col_idx]
    y = row_start_y[col_idx]
    if y > 165:
        col_idx = (col_idx + 1) % cols
        if col_idx == 0:
            pdf.add_page()
            pdf.section_title("3.1 (suite)", "Modeles (suite)", PURPLE)
            row_start_y = [pdf.get_y(), pdf.get_y(), pdf.get_y()]
        x = start_x[col_idx]
        y = row_start_y[col_idx]

    draw_class_card(pdf, model, x, y, col_w)
    row_start_y[col_idx] = pdf.get_y() + 3
    col_idx = (col_idx + 1) % cols


# ── 3.2 Services ─────────────────────────────────────────────────────────────
pdf.add_page()
pdf.section_title("3.2", "Classes de Service", TEAL)

services = [
    {
        "name": "ClassifierService",
        "color": GREEN_DARK,
        "methods": [
            "loadModel() : void",
            "classify(imageFile: File) : ScanResultModel",
        ],
        "assoc": "YOLOv8 API / TFLite",
        "note": "Classification locale (TFLite) avec fallback API cloud",
    },
    {
        "name": "ScanApiService",
        "color": GREEN_MID,
        "methods": [
            "classify(file: File) : ScanResultModel",
            "isAvailable() : bool",
        ],
        "assoc": "YOLOv8 API (Render)",
        "note": "44 classes TACO supportees, mapping vers 9 categories EcoScan",
    },
    {
        "name": "ChatService",
        "color": PURPLE,
        "methods": [
            "sendMessage(text: String, history: List) : String",
            "isHealthy() : bool",
        ],
        "assoc": "Gemini RAG + ChromaDB",
        "note": "Fallback offline : 300+ reponses codees FR/AR/ES/Darija",
    },
    {
        "name": "StorageService",
        "color": BLUE_DARK,
        "methods": [
            "getScans() : List<ScanEntry>",
            "addScan(entry: ScanEntry) : void",
            "getPoints() : int",
            "getCo2() : double",
            "getHistory() : List<ScanEntry>",
            "clearHistory() : void",
            "reset() : void",
        ],
        "assoc": "Firestore + SharedPreferences",
        "note": "Cache local + sync Firestore pour mode hors ligne",
    },
    {
        "name": "WeatherService",
        "color": (0, 120, 180),
        "methods": [
            "fetchByLocation() : WeatherData",
            "fetchByCity(city: String) : WeatherData",
        ],
        "assoc": "OpenWeatherMap API",
        "note": "Cache 1h, fallback coordonnees sauvegardees ou Casablanca",
    },
    {
        "name": "AirQualityService",
        "color": (100, 30, 0),
        "methods": [
            "fetchWithStatus() : AirQualityData",
            "fetchByCityKey(key: String) : AirQualityData",
        ],
        "assoc": "OpenWeatherMap Air Pollution API",
        "note": "12 villes marocaines, 7 polluants, 6 niveaux AQI multilingues",
    },
    {
        "name": "FoodProductService",
        "color": ORANGE,
        "methods": [
            "fetch(barcode: String, locale: String) : FoodProduct",
        ],
        "assoc": "Open Food Facts API",
        "note": "NutriScore, EcoScore, materiaux d'emballage, recyclabilite",
    },
    {
        "name": "NotificationService",
        "color": (130, 0, 50),
        "methods": [
            "init() : void",
            "scheduleDailyReminders() : void",
            "scheduleWeeklyChallengeReminder() : void",
            "showNewRewardUnlocked() : void",
            "getNotifications() : List",
            "markAsRead(id: String) : void",
        ],
        "assoc": "Firebase FCM + flutter_local_notifications",
        "note": "Rappel quotidien 8h, defi hebdo lundi 8h, fuseau Africa/Casablanca",
    },
]

col_w_s = 125
gap_s   = 4

for i, svc in enumerate(services):
    pdf.set_fill_color(*svc["color"])
    pdf.set_text_color(*WHITE)
    pdf.set_font("Arial", "B", 10)
    pdf.cell(0, 7, f"   {svc['name']}", fill=True, ln=True)
    pdf.set_text_color(*BLACK)

    # Methodes
    pdf.set_font("Arial", "B", 8.5)
    pdf.set_x(pdf.l_margin + 4)
    pdf.cell(30, 5.5, "Methodes :")
    pdf.set_font("Arial", "", 8.5)
    for j, m in enumerate(svc["methods"]):
        if j > 0:
            pdf.set_x(pdf.l_margin + 34)
        pdf.cell(0, 5.5, m, ln=True)
        if j == 0 and len(svc["methods"]) > 1:
            pdf.set_x(pdf.l_margin + 34)

    # Association + note
    pdf.set_x(pdf.l_margin + 4)
    pdf.set_font("Arial", "B", 8)
    pdf.set_text_color(*TEAL)
    pdf.cell(30, 5, "Associe a :")
    pdf.set_font("Arial", "I", 8)
    pdf.set_text_color(*BLACK)
    pdf.cell(80, 5, svc["assoc"])
    pdf.set_font("Arial", "I", 7.5)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 5, f"  Note : {svc['note']}", ln=True)
    pdf.set_text_color(*BLACK)
    pdf.set_draw_color(*GREY_MID)
    pdf.line(pdf.l_margin, pdf.get_y(), pdf.l_margin + 267, pdf.get_y())
    pdf.ln(2)


# ── 3.3 Providers ────────────────────────────────────────────────────────────
pdf.add_page()
pdf.section_title("3.3", "Providers / StateNotifiers (Riverpod)", (50, 50, 120))

providers = [
    ("LoginNotifier",          "StateNotifier<AuthState>",            "AuthState",                "login(), reset()",                                 "idle | loading | success | error"),
    ("RegisterNotifier",       "StateNotifier<RegisterState>",        "RegisterState",            "register(), nextStep(), prevStep()",               "3 etapes d'inscription"),
    ("GoogleSignInNotifier",   "StateNotifier<AuthState>",            "AuthState",                "signIn()",                                         "Connexion Google OAuth"),
    ("UserNotifier",           "StateNotifier<UserModel>",            "UserModel",                "loadFromStorage(), recordScan(), updateProfile(), reset()", "Calcul badges, rang, niveau"),
    ("ScanHistoryNotifier",    "StateNotifier<List<ScanEntry>>",      "List<ScanEntry>",          "loadHistory(), addScan()",                         "totalCo2Saved, totalPoints, recyclableCount"),
    ("ChatNotifier",           "StateNotifier<List<ChatMessage>>",    "List<ChatMessage>",        "sendMessage(), setFeedback(), clearChat()",        "Historique messages + feedback"),
    ("ChallengesNotifier",     "StateNotifier<ChallengeProgress>",    "ChallengeProgress",        "incrementScan(), useEcoBot(), viewGuide(), openMap(), shareContent(), load()", "Reset auto minuit/lundi"),
    ("RewardsNotifier",        "StateNotifier<Set<String>>",          "Set<String>",              "redeem(rewardId, cost), isRedeemed(id), load()",   "IDs des recompenses rachetees"),
    ("MarketplaceActions",     "Provider",                            "Actions CRUD",             "addListing(), deleteListing(), addReview(), hasReviewed(), isOwner()", "Upload Cloudinary, +EcoPoints"),
]

col_widths = [38, 45, 32, 80, 62]
headers = [("Nom", 38), ("Type Riverpod", 45), ("Etat gere", 32), ("Methodes principales", 80), ("Notes", 62)]
pdf.table_header(headers)
for i, row in enumerate(providers):
    pdf.set_fill_color(*(GREY_LIGHT if i % 2 == 0 else WHITE))
    pdf.set_font("Arial", "", 7.5)
    for text, w in zip(row, col_widths):
        pdf.cell(w, 6, f"  {text}", border=1, fill=True)
    pdf.ln()

pdf.ln(6)

# ── 3.4 Relations ────────────────────────────────────────────────────────────
pdf.subsection_title("3.4  Relations entre Classes", (50, 50, 120))

relations = [
    ("UserNotifier",       "utilise",    "StorageService",        "Charge et sauvegarde UserModel"),
    ("UserNotifier",       "gere",       "UserModel",             "Etat principal de l'utilisateur"),
    ("ScanHistoryNotifier","utilise",    "StorageService",        "Persiste les ScanEntry"),
    ("ScanHistoryNotifier","gere",       "List<ScanEntry>",       "Historique des scans"),
    ("ClassifierService",  "produit",    "ScanResultModel",       "Resultat de classification"),
    ("ScanApiService",     "produit",    "ScanResultModel",       "Resultat YOLOv8 cloud"),
    ("ChatNotifier",       "utilise",    "ChatService",           "Appels API Gemini RAG"),
    ("ChatNotifier",       "gere",       "List<ChatMessage>",     "Historique conversation"),
    ("ChallengesNotifier", "gere",       "ChallengeProgress",     "Progression defis"),
    ("ChallengesNotifier", "sync avec",  "Firestore",             "Persistance Firestore"),
    ("ListingModel",       "contient",   "List<ReviewModel>",     "Avis des acheteurs"),
    ("FoodProduct",        "contient",   "List<PackagingComponent>","Composants d'emballage"),
    ("AirQualityData",     "contient",   "Map<String, double>",   "Polluants : PM2.5, PM10, NO2..."),
    ("UserModel",          "sync avec",  "Firestore",             "Via StorageService (points, scans, CO2)"),
    ("ScanEntry",          "stockee dans","Firestore + Cache",    "SharedPreferences en mode hors ligne"),
]

rel_widths = [52, 30, 52, 113]
pdf.table_header([("Classe A", 52), ("Relation", 30), ("Classe B", 52), ("Description", 113)])
for i, row in enumerate(relations):
    shade = i % 2 == 0
    pdf.set_fill_color(*(GREY_LIGHT if shade else WHITE))
    pdf.set_font("Arial", "", 8)
    pdf.cell(52,  5.5, f"  {row[0]}", border=1, fill=True)
    pdf.set_fill_color(232, 245, 233)
    pdf.set_font("Arial", "BI", 7.5)
    pdf.cell(30,  5.5, f"  {row[1]}", border=1, fill=True)
    pdf.set_fill_color(*(GREY_LIGHT if shade else WHITE))
    pdf.set_font("Arial", "", 8)
    pdf.cell(52,  5.5, f"  {row[2]}", border=1, fill=True)
    pdf.cell(113, 5.5, f"  {row[3]}", border=1, fill=True)
    pdf.ln()


# ═════════════════════════════════════════════════════════════════════════════
#   PAGE FINALE — RESUME ARCHITECTURE
# ═════════════════════════════════════════════════════════════════════════════
pdf.add_page()
pdf.section_title("RESUME", "Architecture Generale — Stack Technologique", GREEN_DARK)

layers = [
    {
        "name": "Interface Utilisateur (Flutter / Dart)",
        "color": GREEN_DARK,
        "items": [
            "40+ ecrans organises en 8 modules (Auth, Scan, Stats, Env, EcoBot, Marketplace, Carte, Profil)",
            "Riverpod : gestion d'etat reactif (12 providers)",
            "GoRouter : navigation declarative avec deep linking",
            "Support multilingue : FR / EN / AR (RTL) / ES via AppStrings",
            "Theme clair / sombre / systeme, notifications push locales",
        ]
    },
    {
        "name": "Services & Logique Metier",
        "color": BLUE_DARK,
        "items": [
            "ClassifierService : inference TFLite locale + fallback YOLOv8 API (9 categories, 44 classes TACO)",
            "ChatService : Gemini RAG online + 300+ reponses offline (FR/AR/ES/Darija)",
            "StorageService : cache SharedPreferences + sync Firestore bidirectionnelle",
            "WeatherService & AirQualityService : OpenWeatherMap avec cache intelligent",
            "NotificationService : FCM + flutter_local_notifications (rappels planifies)",
        ]
    },
    {
        "name": "Backend Python / FastAPI",
        "color": PURPLE,
        "items": [
            "FastAPI : API REST /chat endpoint",
            "LangChain + Gemini 2.5 Flash : orchestration LLM",
            "ChromaDB : base vectorielle pour RAG (retrieval-augmented generation)",
            "HuggingFace Embeddings : vectorisation du corpus de connaissances",
        ]
    },
    {
        "name": "Infrastructure & APIs Externes",
        "color": TEAL,
        "items": [
            "Firebase : Auth, Firestore, Cloud Messaging (FCM), Cloud Storage",
            "OpenWeatherMap : meteo temps reel + pollution de l'air (12 villes marocaines)",
            "Open Food Facts : base de donnees produits alimentaires open source",
            "Cloudinary : CDN images pour le marketplace (upload multi-photos)",
            "YOLOv8 (Render) : API de detection d'objets pour classification dechets",
        ]
    },
    {
        "name": "Base de Donnees",
        "color": ORANGE,
        "items": [
            "Firestore : collections users, scans, challenges, marketplace, rewards, leaderboard",
            "SharedPreferences : cache local offline (scans, points, CO2, preferences)",
            "ChromaDB : vecteurs du chatbot EcoBot (connaissances tri dechets, operateurs)",
        ]
    },
]

for layer in layers:
    pdf.set_fill_color(*layer["color"])
    pdf.set_text_color(*WHITE)
    pdf.set_font("Arial", "B", 10)
    pdf.cell(0, 8, f"   {layer['name']}", fill=True, ln=True)
    pdf.set_text_color(*BLACK)
    pdf.set_fill_color(*GREY_LIGHT)
    for item in layer["items"]:
        pdf.set_font("Arial", "", 8.5)
        pdf.set_x(pdf.l_margin + 6)
        pdf.cell(5, 5.5, "->")
        pdf.multi_cell(0, 5.5, item, fill=True)
    pdf.ln(2)


# ─── Sauvegarde ──────────────────────────────────────────────────────────────
output_path = r"C:\Users\H.Badreddine\Desktop\PFE\ecoscan\EcoScan_Diagrammes_UML.pdf"
pdf.output(output_path)
print(f"PDF genere : {output_path}")
