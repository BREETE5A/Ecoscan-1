from fpdf import FPDF
from fpdf.enums import XPos, YPos

FONT = "C:\\Windows\\Fonts\\"

# -- Couleurs ------------------------------------------------------------------
C_GREEN_DARK  = (27,  94,  32)
C_GREEN_MID   = (56, 142,  60)
C_GREEN_LIGHT = (200, 230, 201)
C_GREEN_BG    = (232, 245, 233)
C_BLUE_DARK   = (21,  101, 192)
C_BLUE_LIGHT  = (227, 242, 253)
C_PURPLE      = (74,  20, 140)
C_PURPLE_LIGHT= (243, 229, 245)
C_ORANGE      = (230,  81,   0)
C_TEAL        = (0,  105,  92)
C_TEAL_LIGHT  = (224, 242, 241)
C_RED_DARK    = (183,  28,  28)
C_GREY_LIGHT  = (245, 245, 245)
C_GREY_MID    = (200, 200, 200)
C_WHITE       = (255, 255, 255)
C_BLACK       = (33,  33,  33)
C_CODE_BG     = (30,  30,  30)
C_CODE_FG     = (220, 220, 220)
C_KEYWORD     = (86, 156, 214)
C_STRING      = (206, 145, 120)
C_COMMENT     = (106, 153,  85)
C_ARROW       = (78, 201, 176)

# -- Codes PlantUML -------------------------------------------------------------
DIAGRAMS = [
    {
        "id": "01",
        "title": "Diagramme de Cas d'Utilisation",
        "subtitle": "Acteurs, Packages, UC, include/extend, Systemes externes",
        "color": C_GREEN_DARK,
        "badge_color": C_GREEN_MID,
        "code": r"""@startuml EcoScan_CasUtilisation

left to right direction

skinparam backgroundColor #FAFAFA
skinparam actorStyle awesome
skinparam usecase {
  BackgroundColor #E8F5E9
  BorderColor #2E7D32
  ArrowColor #388E3C
  FontSize 11
}
skinparam actor {
  BackgroundColor #E3F2FD
  BorderColor #1565C0
  FontColor #1565C0
}
skinparam package {
  BackgroundColor #F1F8E9
  BorderColor #558B2F
  FontColor #33691E
  FontStyle bold
}

' === ACTEURS HUMAINS (gauche) ===
actor "Visiteur" as Guest
actor "Utilisateur\nConnecte" as User

User --|> Guest

rectangle "EcoScan" {

  package "1. Authentification" {
    usecase "S'inscrire (3 etapes)" as UC_Register
    usecase "Se connecter email/mdp" as UC_Login
    usecase "Se connecter via Google" as UC_Google
    usecase "Verifier son email" as UC_VerifyEmail
    usecase "Changer son mot de passe" as UC_ChangePass
    usecase "Activer la 2FA" as UC_2FA
  }

  package "2. Scan & Classification" {
    usecase "Scanner un dechet (camera)" as UC_Scan
    usecase "Classifier localement (TFLite)" as UC_Local
    usecase "Classifier via API (YOLOv8)" as UC_Cloud
    usecase "Consulter le resultat du scan" as UC_Result
    usecase "Scanner un code-barres" as UC_Barcode
    usecase "Recuperer infos produit (OFF)" as UC_FoodInfo
    usecase "Consulter l'historique des scans" as UC_History
    usecase "Supprimer l'historique" as UC_DeleteHistory
  }

  package "3. Statistiques & Gamification" {
    usecase "Consulter ses statistiques" as UC_Stats
    usecase "Consulter ses badges" as UC_Badges
    usecase "Progresser dans les defis" as UC_Challenges
    usecase "Defi : Utiliser EcoBot" as UC_ChallBot
    usecase "Defi : Ouvrir la carte" as UC_ChallMap
    usecase "Defi : Partager du contenu" as UC_ChallShare
    usecase "Consulter le classement" as UC_Leaderboard
    usecase "Echanger ses EcoPoints" as UC_Rewards
  }

  package "4. Donnees Environnementales" {
    usecase "Consulter la meteo" as UC_Weather
    usecase "Consulter la qualite de l'air (AQI)" as UC_AQI
    usecase "Consulter l'empreinte eau" as UC_Water
    usecase "Passer le quiz eco-educatif" as UC_Quiz
  }

  package "5. EcoBot & Guide" {
    usecase "Envoyer un message a EcoBot" as UC_Chat
    usecase "Reponse en ligne (Gemini RAG)" as UC_ChatOnline
    usecase "Reponse hors ligne (base locale)" as UC_ChatOffline
    usecase "Consulter le guide de tri" as UC_Guide
    usecase "Trouver un operateur de collecte" as UC_Operator
  }

  package "6. Marketplace" {
    usecase "Parcourir les annonces" as UC_Browse
    usecase "Consulter le detail d'une annonce" as UC_ListingDetail
    usecase "Publier une annonce (don/vente/echange)" as UC_Publish
    usecase "Uploader des photos" as UC_Upload
    usecase "Modifier / supprimer ses annonces" as UC_ManageAds
    usecase "Laisser un avis vendeur" as UC_Review
    usecase "Contacter un vendeur (tel/WhatsApp)" as UC_Contact
  }

  package "7. Carte & Geolocalisation" {
    usecase "Ouvrir la carte des points de collecte" as UC_Map
    usecase "Detecter sa position GPS" as UC_GPS
  }

  package "8. Profil & Parametres" {
    usecase "Modifier son profil (nom, ville, avatar)" as UC_EditProfile
    usecase "Changer la langue (FR/EN/AR/ES)" as UC_Language
    usecase "Changer le theme (clair/sombre)" as UC_Theme
    usecase "Gerer les notifications" as UC_ManageNotif
    usecase "Consulter les notifications recues" as UC_Notifs
  }

}

' === SYSTEMES EXTERNES (droite) ===
actor "Firebase Auth" as Firebase
actor "YOLOv8 / TFLite" as YOLO
actor "Gemini RAG" as Gemini
actor "OpenWeatherMap" as OWM
actor "Open Food Facts" as OFF
actor "Firestore" as FS
actor "Firebase FCM" as FCM
actor "Cloudinary" as CDN

' === RELATIONS : Acteurs humains ===
Guest --> UC_Register
Guest --> UC_Login
Guest --> UC_Google

User --> UC_VerifyEmail
User --> UC_ChangePass
User --> UC_2FA
User --> UC_Scan
User --> UC_Barcode
User --> UC_Result
User --> UC_History
User --> UC_DeleteHistory
User --> UC_Stats
User --> UC_Badges
User --> UC_Challenges
User --> UC_Leaderboard
User --> UC_Rewards
User --> UC_Weather
User --> UC_AQI
User --> UC_Water
User --> UC_Quiz
User --> UC_Chat
User --> UC_Guide
User --> UC_Operator
User --> UC_Browse
User --> UC_ListingDetail
User --> UC_Publish
User --> UC_ManageAds
User --> UC_Review
User --> UC_Contact
User --> UC_Map
User --> UC_EditProfile
User --> UC_Language
User --> UC_Theme
User --> UC_ManageNotif
User --> UC_Notifs

' === INCLUDE / EXTEND ===
UC_Register   ..> UC_VerifyEmail  : <<include>>
UC_Scan       ..> UC_Local        : <<include>>
UC_Scan       ..> UC_Cloud        : <<extend>>
UC_Scan       ..> UC_Result       : <<include>>
UC_Result     ..> UC_History      : <<include>>
UC_Barcode    ..> UC_FoodInfo     : <<include>>
UC_Challenges ..> UC_ChallBot     : <<include>>
UC_Challenges ..> UC_ChallMap     : <<include>>
UC_Challenges ..> UC_ChallShare   : <<include>>
UC_Publish    ..> UC_Upload       : <<include>>
UC_Chat       ..> UC_ChatOnline   : <<include>>
UC_Chat       ..> UC_ChatOffline  : <<extend>>
UC_Map        ..> UC_GPS          : <<include>>
UC_Weather    ..> UC_GPS          : <<extend>>
UC_AQI        ..> UC_GPS          : <<extend>>

' === RELATIONS : Systemes externes ===
UC_Login       --> Firebase
UC_Register    --> Firebase
UC_Google      --> Firebase
UC_ChangePass  --> Firebase
UC_2FA         --> Firebase
UC_Local       --> YOLO
UC_Cloud       --> YOLO
UC_ChatOnline  --> Gemini
UC_Weather     --> OWM
UC_AQI         --> OWM
UC_FoodInfo    --> OFF
UC_History     --> FS
UC_Stats       --> FS
UC_Leaderboard --> FS
UC_Challenges  --> FS
UC_Rewards     --> FS
UC_Publish     --> FS
UC_Browse      --> FS
UC_Review      --> FS
UC_ManageNotif --> FCM
UC_Notifs      --> FCM
UC_Upload      --> CDN

@enduml""",
    },
    {
        "id": "02",
        "title": "Diagramme de Sequence 1",
        "subtitle": "Scanner un dechet — Camera + ML (TFLite + YOLOv8)",
        "color": C_GREEN_DARK,
        "badge_color": C_GREEN_MID,
        "code": r"""@startuml Sequence1_Scanner_Dechet

skinparam backgroundColor #FAFAFA
skinparam sequenceMessageAlign center
skinparam responseMessageBelowArrow true
skinparam maxMessageSize 200
skinparam participant {
  BackgroundColor #E8F5E9
  BorderColor #2E7D32
  FontColor #1B5E20
  FontStyle bold
}
skinparam actor {
  BackgroundColor #E3F2FD
  BorderColor #1565C0
  FontColor #1565C0
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #E65100
  FontColor #BF360C
}
skinparam ArrowColor #388E3C
skinparam SequenceLifeLineBorderColor #2E7D32
skinparam SequenceDividerBackgroundColor #C8E6C9
skinparam SequenceGroupBackgroundColor #F1F8E9
skinparam SequenceGroupBorderColor #388E3C
skinparam NoteBackgroundColor #FFFDE7
skinparam NoteBorderColor #F9A825

title <b>Sequence 1 - Scanner un dechet (Camera + ML)</b>

actor       "Utilisateur"          as User
participant "ScanScreen"           as Scan
participant "ClassifierService"    as Clf
participant "ScanApiService"       as Api
participant "ScanResultScreen"     as Result
participant "StorageService"       as Store
participant "ScanHistoryProvider"  as HistProv
participant "UserProvider"         as UserProv
participant "ChallengesNotifier"   as Chall
database    "YOLOv8 API (Render)"  as YOLO
database    "Firestore"            as FS

== Capture de l'image ==

User  -> Scan   : Appuie sur le bouton Scan
activate Scan
Scan  -> Clf    : classify(imageFile)
activate Clf

note right of Clf
  Inference locale TFLite
  Modele : assets/models/
end note

Clf --> Scan    : ScanResultModel\n(categorie, binColor, confidence)
deactivate Clf

== Verification disponibilite API cloud ==

Scan  -> Api    : isAvailable()
activate Api
Api  --> Scan   : true / false
deactivate Api

alt API cloud disponible (confidence < 0.85)

  Scan  -> Api  : classify(imageFile)
  activate Api
  Api   -> YOLO : POST /scan [multipart image]
  activate YOLO
  YOLO --> Api  : { label, confidence }
  deactivate YOLO

  note right of Api
    Mapping : 44 classes TACO
    => 9 categories EcoScan
  end note

  Api  --> Scan : ScanResultModel (mode: cloud)
  deactivate Api

else API indisponible ou timeout

  note over Scan : Resultat TFLite local (mode: local)

end

== Affichage du resultat ==

Scan  -> Result : Navigation avec ScanResultModel
activate Result

note right of Result
  Affiche :
  - Categorie + icone poubelle
  - Score recyclabilite (0-100%)
  - CO2 economise (grammes)
  - EcoPoints gagnes
end note

== Sauvegarde du scan ==

Result -> Store : addScan(ScanEntry)
activate Store
Store -> FS     : setDoc(users/{uid}/scans/{id})
activate FS
FS    --> Store : OK
deactivate FS
Store -> HistProv : notifyListeners()
activate HistProv
HistProv -> UserProv : incrementScan() [+points, +co2]
activate UserProv
UserProv -> FS  : update(users/{uid}, {points, scans, co2, streak})
activate FS
FS      --> UserProv : OK
deactivate FS
deactivate UserProv
deactivate HistProv
deactivate Store

== Mise a jour des defis ==

Result -> Chall : incrementScan()
activate Chall
Chall  -> FS    : update challenges {dailyScans+1}
activate FS
FS    --> Chall : OK
deactivate FS
deactivate Chall
deactivate Result
deactivate Scan

User  <-- Result : Affichage complet du resultat

@enduml""",
    },
    {
        "id": "03",
        "title": "Diagramme de Sequence 2",
        "subtitle": "Authentification — Connexion email / mot de passe",
        "color": C_BLUE_DARK,
        "badge_color": C_BLUE_DARK,
        "code": r"""@startuml Sequence2_Login

skinparam backgroundColor #FAFAFA
skinparam sequenceMessageAlign center
skinparam responseMessageBelowArrow true
skinparam maxMessageSize 200
skinparam participant {
  BackgroundColor #E3F2FD
  BorderColor #1565C0
  FontColor #0D47A1
  FontStyle bold
}
skinparam actor {
  BackgroundColor #E3F2FD
  BorderColor #1565C0
  FontColor #1565C0
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #E65100
  FontColor #BF360C
}
skinparam ArrowColor #1565C0
skinparam SequenceLifeLineBorderColor #1565C0
skinparam SequenceDividerBackgroundColor #BBDEFB
skinparam SequenceGroupBackgroundColor #E3F2FD
skinparam SequenceGroupBorderColor #1565C0
skinparam NoteBackgroundColor #FFFDE7
skinparam NoteBorderColor #F9A825

title <b>Sequence 2 - Authentification (Login)</b>

actor       "Utilisateur"           as User
participant "LoginScreen"           as Login
participant "LoginNotifier"         as Notif
participant "currentUserProvider"   as CurUser
participant "UserProvider"          as UserProv
participant "HomeScreen"            as Home
database    "Firebase Auth"         as Auth
database    "Firestore"             as FS

== Saisie des identifiants ==

User  -> Login  : Saisit email + mot de passe
activate Login
User  -> Login  : Appuie sur "Se connecter"
Login -> Notif  : login(email, password)
activate Notif
Notif -> Notif  : state = AuthState.loading
Login <-- Notif : Indicateur de chargement

== Appel Firebase Auth ==

Notif -> Auth   : signInWithEmailAndPassword(email, password)
activate Auth

alt Connexion reussie

  Auth --> Notif  : UserCredential (uid, email)
  deactivate Auth
  Notif -> Notif  : state = AuthState.success

  Notif -> CurUser : setUser(AppUser)
  activate CurUser
  CurUser -> FS   : getDoc(users/{uid})
  activate FS
  FS     --> CurUser : UserModel complet
  deactivate FS
  CurUser -> UserProv : initialiser(UserModel)
  activate UserProv

  note right of UserProv
    Calcule :
    - level = points / 200
    - xp = points % 200
    - badges debloques
    - rang communautaire
  end note

  UserProv --> CurUser : OK
  deactivate UserProv
  deactivate CurUser
  Notif -> Home   : GoRouter.go('/home')
  activate Home
  Home  --> User  : Affiche HomeScreen
  deactivate Home

else Email non verifie

  Auth --> Notif  : emailVerified: false
  deactivate Auth
  Notif -> Login  : Redirection VerifyEmailScreen
  Login --> User  : "Verifiez votre boite mail"

else Mauvais identifiants

  Auth --> Notif  : FirebaseAuthException\n(wrong-password / user-not-found)
  deactivate Auth
  Notif -> Notif  : state = AuthState.error
  Notif --> Login : message erreur multilingue (FR/EN/AR/ES)
  Login --> User  : Champs en rouge + message

else Trop de tentatives

  Auth --> Notif  : too-many-requests
  deactivate Auth
  Notif --> Login : "Compte temporairement bloque"
  Login --> User  : Alerte + lien reset mdp

end

deactivate Notif
deactivate Login

@enduml""",
    },
    {
        "id": "04",
        "title": "Diagramme de Sequence 3",
        "subtitle": "Envoyer un message a EcoBot — Gemini RAG + Fallback offline",
        "color": C_PURPLE,
        "badge_color": C_PURPLE,
        "code": r"""@startuml Sequence3_EcoBot

skinparam backgroundColor #FAFAFA
skinparam sequenceMessageAlign center
skinparam responseMessageBelowArrow true
skinparam maxMessageSize 200
skinparam participant {
  BackgroundColor #EDE7F6
  BorderColor #4A148C
  FontColor #4A148C
  FontStyle bold
}
skinparam actor {
  BackgroundColor #E3F2FD
  BorderColor #1565C0
  FontColor #1565C0
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #E65100
  FontColor #BF360C
}
skinparam ArrowColor #6A1B9A
skinparam SequenceLifeLineBorderColor #7B1FA2
skinparam SequenceDividerBackgroundColor #CE93D8
skinparam SequenceGroupBackgroundColor #F3E5F5
skinparam SequenceGroupBorderColor #7B1FA2
skinparam NoteBackgroundColor #FFFDE7
skinparam NoteBorderColor #F9A825

title <b>Sequence 3 - Envoyer un message a EcoBot</b>

actor       "Utilisateur"          as User
participant "ChatScreen"           as Chat
participant "ChatNotifier"         as CN
participant "ChatService"          as CS
participant "ChallengesNotifier"   as Chall
database    "Gemini RAG Backend"   as Backend
database    "Firestore"            as FS

== Saisie du message ==

User -> Chat  : Saisit un message et envoie
activate Chat
Chat -> CN    : sendMessage(text)
activate CN
CN   -> CN    : Ajoute ChatMessage(isUser: true)
Chat <-- CN   : Affiche message utilisateur
CN   -> CN    : Ajoute ChatMessage(isLoading: true)
Chat <-- CN   : "EcoBot est en train d'ecrire..."

== Verification connectivite ==

CN   -> CS    : isHealthy()
activate CS
CS  --> CN    : true / false
deactivate CS

alt Connexion disponible - Reponse Gemini RAG

  CN  -> CS   : sendMessage(text, conversationHistory)
  activate CS

  CS  -> Backend : HTTP POST /chat\n{ "message": text, "history": [...] }
  activate Backend

  note right of Backend
    Pipeline RAG :
    1. Vectorise la question
    2. Recherche ChromaDB
    3. Prompt enrichi
    4. Appel Gemini 2.5 Flash
    5. Retourne reponse
  end note

  Backend -> Backend : Recherche vectorielle (ChromaDB)
  Backend -> Backend : Generation LLM (Gemini 2.5 Flash)
  Backend --> CS     : { "answer": "..." }
  deactivate Backend
  CS  --> CN  : texte de la reponse
  deactivate CS
  CN  -> CN   : Remplace isLoading par reponse bot
  Chat <-- CN : Affiche reponse EcoBot

else Pas de connexion - Fallback local

  CN  -> CS   : sendMessage() => exception
  activate CS
  CS  --> CN  : NetworkException
  deactivate CS
  CN  -> CN   : Selectionne reponse locale

  note right of CN
    Base offline (300+ reponses) :
    - Tri par categorie
    - Contacts operateurs
      (AVERDA, ARMA, ONEE...)
    - Lois 28-00, 77-15, 49-17
    - Navigation app
    FR / AR / ES / Darija
  end note

  CN  -> CN   : ChatMessage (reponse + badge offline)
  Chat <-- CN : Affiche reponse hors ligne

end

== Mise a jour du defi quotidien ==

CN  -> Chall  : useEcoBot()
activate Chall
Chall -> Chall : ecoBotUsed = true
Chall -> FS   : update { ecoBotUsed: true, dayKey }
activate FS
FS   --> Chall : OK
deactivate FS
deactivate Chall

== Feedback utilisateur (optionnel) ==

User -> Chat  : Pouce haut / bas
Chat -> CN    : setFeedback(messageId, bool)
CN   -> CN    : Met a jour ChatMessage.feedback

deactivate CN
deactivate Chat

@enduml""",
    },
    {
        "id": "05",
        "title": "Diagramme de Classes",
        "subtitle": "Modeles, Services, Providers (Riverpod), Enumerations et Relations",
        "color": C_PURPLE,
        "badge_color": C_PURPLE,
        "code": r"""@startuml EcoScan_ClassDiagram

skinparam backgroundColor #FAFAFA
skinparam classBackgroundColor #FFFFFF
skinparam classBorderColor #90A4AE
skinparam classArrowColor #37474F
skinparam classFontSize 11
skinparam classAttributeFontSize 9
skinparam packageBackgroundColor #F5F5F5
skinparam packageBorderColor #78909C
skinparam packageFontStyle bold
skinparam packageFontSize 11
skinparam NoteBackgroundColor #FFFDE7
skinparam NoteBorderColor #F9A825
skinparam linetype ortho

left to right direction

' ======================================
'  PACKAGE : MODELES
' ======================================
package "Modeles" #E8F5E9 {

  class UserModel {
    + id : String
    + name : String
    + city : String
    + points : int
    + scans : int
    + badges : int
    + rank : int
    + level : int
    + xp : int
    + xpMax : int
    + co2Saved : double
    + weeklyGoalKg : double
    + weeklyProgress : double
    + recentScans : List<Map>
    + streak : int
    --
    + fromMap(map: Map) : UserModel
    + toMap() : Map
    + copyWith(...) : UserModel
  }

  class ScanEntry {
    + id : String
    + name : String
    + category : String
    + recyclable : bool
    + dangerous : bool
    + points : int
    + co2Saved : double
    + recyclability : double
    + binColor : String
    + scannedAt : DateTime
    + mode : String
    --
    + fromMap(map: Map) : ScanEntry
    + toMap() : Map
  }

  class ScanResultModel {
    + rawClass : String
    + category : String
    + binColor : String
    + confidence : double
    + co2SavedPerKg : double
    + scannedAt : DateTime
  }

  class ChatMessage {
    + id : String
    + text : String
    + isUser : bool
    + timestamp : DateTime
    + isLoading : bool
    + feedback : bool?
  }

  class ListingModel {
    + id : String
    + title : String
    + description : String
    + type : String
    + category : String
    + price : double?
    + city : String
    + phone : String
    + whatsapp : String
    + imageUrls : List<String>
    + userId : String
    + userName : String
    + createdAt : DateTime
    + active : bool
    + reviewAvg : double
    + reviewCount : int
    + trustedSeller : bool
    + latitude : double?
    + longitude : double?
    --
    + fromMap(map: Map) : ListingModel
    + toMap() : Map
    + isTrustedSeller() : bool
  }

  class ReviewModel {
    + id : String
    + reviewerId : String
    + reviewerName : String
    + stars : int
    + comment : String
    + createdAt : DateTime
  }

  class FoodProduct {
    + barcode : String
    + name : String
    + brand : String
    + imageUrl : String
    + nutriScore : String
    + ecoScore : String
    + packaging : String
    + packagingTags : List<String>
    + packagingComponents : List<PackagingComponent>
    + ingredients : String
  }

  class PackagingComponent {
    + material : String
    + shape : String
    + recycling : String
  }

  class ChallengeProgress {
    + dailyScans : int
    + ecoBotUsed : bool
    + guideViews : int
    + mapOpened : bool
    + shared : bool
    + weeklyScans : int
    + dayKey : String
    + weekKey : String
  }

  class WeatherData {
    + city : String
    + temp : double
    + description : String
    + icon : String
    + humidity : int
    + windSpeed : double
    + uvIndex : int
    + condition : String
  }

  class AirQualityData {
    + aqi : int
    + city : String
    + level : String
    + levelAr : String
    + levelEn : String
    + levelEs : String
    + color : int
    + pollutants : Map<String, double>
  }

  class CommunityStats {
    + users : int
    + scans : int
    + kgRecycled : int
    + progress : double
  }
}

' ======================================
'  PACKAGE : SERVICES
' ======================================
package "Services" #E3F2FD {

  class ClassifierService {
    - _interpreter : Interpreter
    - _labels : List<String>
    --
    + loadModel() : void
    + classify(imageFile: File) : ScanResultModel
    - _preprocess(image) : List
    - _mapLabel(raw: String) : String
  }

  class ScanApiService {
    - _baseUrl : String
    - _client : Dio
    --
    + classify(file: File) : ScanResultModel
    + isAvailable() : bool
    - _mapTacoLabel(label: String) : String
  }

  class ChatService {
    - _endpoint : String
    - _client : Dio
    - _fallbackResponses : Map
    --
    + sendMessage(text: String, history: List) : String
    + isHealthy() : bool
    - _fallbackResponse(text: String) : String
  }

  class StorageService {
    - _prefs : SharedPreferences
    --
    + getScans() : List<ScanEntry>
    + addScan(entry: ScanEntry) : void
    + getPoints() : int
    + getCo2() : double
    + getHistory() : List<ScanEntry>
    + clearHistory() : void
    + reset() : void
    - _syncFirestore(uid: String) : void
  }

  class WeatherService {
    - _apiKey : String
    - _cache : WeatherData?
    --
    + fetchByLocation() : WeatherData
    + fetchByCity(city: String) : WeatherData
    - _buildUrl(lat: double, lon: double) : String
  }

  class AirQualityService {
    - _apiKey : String
    - _moroccanCities : Map
    --
    + fetchWithStatus() : AirQualityData
    + fetchByCityKey(key: String) : AirQualityData
    - _fetchOWM(lat, lng, city) : AirQualityData
    - _aqiLevel(aqi: int) : String
  }

  class FoodProductService {
    - _baseUrl : String
    --
    + fetch(barcode: String, locale: String) : FoodProduct
    - _parsePackaging(json: Map) : List<PackagingComponent>
  }

  class NotificationService {
    - _fcm : FirebaseMessaging
    - _localNotif : FlutterLocalNotificationsPlugin
    --
    + init() : void
    + scheduleDailyReminders() : void
    + scheduleWeeklyChallengeReminder() : void
    + showNewRewardUnlocked(title: String) : void
    + getNotifications() : List<Map>
    + markAsRead(id: String) : void
  }
}

' ======================================
'  PACKAGE : PROVIDERS (Riverpod)
' ======================================
package "Providers (Riverpod)" #F3E5F5 {

  abstract class StateNotifier<T> {
    # state : T
    + notifyListeners() : void
  }

  class LoginNotifier {
    --
    + login(email: String, password: String) : void
    + reset() : void
    - _translateError(code: String) : String
  }

  class RegisterNotifier {
    - _step : int
    --
    + register(firstName, lastName, email, password, city) : void
    + nextStep() : void
    + prevStep() : void
  }

  class GoogleSignInNotifier {
    --
    + signIn() : void
    - _createUserDocIfNew(uid: String) : void
  }

  class UserNotifier {
    - _storage : StorageService
    --
    + loadFromStorage() : void
    + recordScan(entry: ScanEntry) : void
    + updateProfile(name, city, avatar) : void
    + reset() : void
    - _computeBadges() : int
    - _computeLevel() : int
  }

  class ScanHistoryNotifier {
    - _storage : StorageService
    --
    + loadHistory() : void
    + addScan(entry: ScanEntry) : void
    + totalCo2Saved() : double
    + totalPoints() : int
    + recyclableCount() : int
  }

  class ChatNotifier {
    - _service : ChatService
    --
    + sendMessage(text: String) : void
    + setFeedback(id: String, value: bool) : void
    + clearChat() : void
    + updateWelcomeMessage() : void
  }

  class ChallengesNotifier {
    --
    + incrementScan() : void
    + useEcoBot() : void
    + viewGuide() : void
    + openMap() : void
    + shareContent() : void
    + load() : void
    - _resetIfNewDay() : void
    - _resetIfNewWeek() : void
  }

  class RewardsNotifier {
    --
    + redeem(rewardId: String, cost: int) : void
    + isRedeemed(id: String) : bool
    + load() : void
  }

  class MarketplaceActions {
    - _firestore : FirebaseFirestore
    --
    + addListing(listing: ListingModel, images: List<File>) : void
    + deleteListing(id: String) : void
    + addReview(listingId: String, review: ReviewModel) : void
    + hasReviewed(listingId: String, uid: String) : bool
    + isOwner(listing: ListingModel, uid: String) : bool
  }
}

' ======================================
'  ENUMERATIONS
' ======================================
package "Enumerations" #FFF8E1 {

  enum AuthStatus {
    idle
    loading
    success
    error
  }

  enum WasteCategory {
    verre
    plastique
    metal
    carton
    papier
    organique
    electronique
    dechet
    inconnu
  }

  enum ListingType {
    don
    vente
    echange
  }
}

' ======================================
'  RELATIONS
' ======================================

ListingModel    "1" *--> "0..*" ReviewModel
FoodProduct     "1" *--> "0..*" PackagingComponent

StateNotifier <|-- LoginNotifier
StateNotifier <|-- RegisterNotifier
StateNotifier <|-- GoogleSignInNotifier
StateNotifier <|-- UserNotifier
StateNotifier <|-- ScanHistoryNotifier
StateNotifier <|-- ChatNotifier
StateNotifier <|-- ChallengesNotifier
StateNotifier <|-- RewardsNotifier

UserNotifier        ..> StorageService    : utilise
UserNotifier        ..> UserModel         : gere
ScanHistoryNotifier ..> StorageService    : utilise
ScanHistoryNotifier ..> ScanEntry         : gere
ClassifierService   ..> ScanResultModel   : produit
ScanApiService      ..> ScanResultModel   : produit
ChatNotifier        ..> ChatService       : utilise
ChatNotifier        ..> ChatMessage       : gere
ChallengesNotifier  ..> ChallengeProgress : gere
MarketplaceActions  ..> ListingModel      : CRUD
MarketplaceActions  ..> ReviewModel       : ajoute
WeatherService      ..> WeatherData       : produit
AirQualityService   ..> AirQualityData    : produit
FoodProductService  ..> FoodProduct       : produit

LoginNotifier        ..> AuthStatus : etat
RegisterNotifier     ..> AuthStatus : etat
GoogleSignInNotifier ..> AuthStatus : etat
ListingModel         ..> ListingType : type
ScanApiService       ..> WasteCategory : mappe

@enduml""",
    },
]

# -- Classe PDF ----------------------------------------------------------------
class PlantUMLCodePDF(FPDF):
    def __init__(self):
        super().__init__(orientation="P", unit="mm", format="A4")
        self.set_auto_page_break(auto=True, margin=18)
        self.set_margins(12, 18, 12)
        self.add_font("Arial",  "",  FONT + "arial.ttf")
        self.add_font("Arial",  "B", FONT + "arialbd.ttf")
        self.add_font("Arial",  "I", FONT + "ariali.ttf")
        self.add_font("MonoFont","",  FONT + "cour.ttf")
        self.add_font("MonoFont","B", FONT + "courbd.ttf")
        self._current_color = C_GREEN_DARK

    def header(self):
        self.set_fill_color(*C_GREEN_DARK)
        self.rect(0, 0, 210, 14, "F")
        self.set_font("Arial", "B", 9)
        self.set_text_color(*C_WHITE)
        self.set_xy(12, 3)
        self.cell(100, 8, "EcoScan — Codes PlantUML", new_x=XPos.RIGHT, new_y=YPos.TOP)
        self.set_font("Arial", "I", 8)
        self.set_x(0)
        self.cell(198, 8, "Diagrammes UML — PFE 2025-2026", align="R", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        self.set_text_color(*C_BLACK)
        self.ln(6)

    def footer(self):
        self.set_y(-14)
        self.set_fill_color(*C_GREEN_LIGHT)
        self.rect(0, self.get_y(), 210, 14, "F")
        self.set_font("Arial", "I", 8)
        self.set_text_color(80, 80, 80)
        self.cell(0, 8, f"Page {self.page_no()}  |  EcoScan PlantUML", align="C")
        self.set_text_color(*C_BLACK)

    def diagram_header(self, diag):
        c = diag["color"]
        self.set_fill_color(*c)
        self.set_text_color(*C_WHITE)
        self.set_font("Arial", "B", 13)
        self.cell(0, 11, f"   Diagramme {diag['id']} — {diag['title']}", fill=True,
                  new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        # sous-titre
        r, g, b = c
        self.set_fill_color(min(r+40,255), min(g+40,255), min(b+40,255))
        self.set_font("Arial", "I", 9)
        self.cell(0, 7, f"   {diag['subtitle']}", fill=True,
                  new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        self.set_text_color(*C_BLACK)
        self.ln(3)

    def section_label(self, text, color):
        self.set_fill_color(*color)
        self.set_text_color(*C_WHITE)
        self.set_font("Arial", "B", 8.5)
        self.cell(0, 6, f"   {text}", fill=True,
                  new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        self.set_text_color(*C_BLACK)
        self.ln(1)

    def code_block(self, code, diag_color):
        lines = code.strip().split("\n")
        lh = 4.5
        pad = 3

        self.set_fill_color(*C_CODE_BG)
        self.set_draw_color(*diag_color)
        self.set_line_width(0.6)

        # Barre laterale coloree
        bar_x = self.l_margin
        start_y = self.get_y()

        self.set_x(bar_x + 4)

        for line in lines:
            if self.get_y() + lh > self.h - self.b_margin:
                # barre finale
                self.set_fill_color(*diag_color)
                self.rect(bar_x, start_y, 3, self.get_y() - start_y, "F")
                self.add_page()
                start_y = self.get_y()
                self.set_x(bar_x + 4)

            # Fond de ligne
            self.set_fill_color(*C_CODE_BG)
            self.set_x(bar_x + 4)

            stripped = line.rstrip()
            color, bold = self._line_color(stripped)

            self.set_text_color(*color)
            self.set_font("MonoFont", "B" if bold else "", 7.2)
            safe = stripped.replace("\t", "    ")
            self.cell(0, lh, safe, fill=True, new_x=XPos.LMARGIN, new_y=YPos.NEXT)

        # Barre laterale finale
        self.set_fill_color(*diag_color)
        self.rect(bar_x, start_y, 3, self.get_y() - start_y, "F")
        self.set_text_color(*C_BLACK)
        self.set_line_width(0.2)
        self.set_draw_color(0, 0, 0)
        self.ln(2)

    def _line_color(self, line):
        s = line.strip()
        # Commentaires
        if s.startswith("'") or s.startswith("//") or s.startswith("=="):
            return C_COMMENT, False
        # Directives @startuml / @enduml
        if s.startswith("@"):
            return C_KEYWORD, True
        # Mots-clés forts
        strong = ["skinparam", "left to right", "title", "package", "class ",
                  "abstract class", "enum ", "actor ", "usecase ", "participant ",
                  "database ", "rectangle ", "interface ", "note ", "end note",
                  "activate", "deactivate", "alt", "else", "end", "loop", "opt"]
        for kw in strong:
            if s.startswith(kw):
                return C_KEYWORD, True
        # Relations et fleches
        arrow_kws = ["-->", "->", "..>", "<|--", "*-->", "o-->", "--|>", "<--"]
        for a in arrow_kws:
            if a in line:
                return C_ARROW, False
        # Chaines entre guillemets
        if '"' in line:
            return C_STRING, False
        # Attributs / methodes (+, -)
        if s.startswith("+") or s.startswith("-") or s.startswith("#"):
            return (180, 220, 180), False
        # Defaut
        return C_CODE_FG, False


# =============================================================================
#  PAGE DE COUVERTURE
# =============================================================================
pdf = PlantUMLCodePDF()
pdf.add_page()

# Bande verte haute
pdf.set_fill_color(*C_GREEN_DARK)
pdf.rect(0, 14, 210, 60, "F")

# Titre
pdf.set_xy(15, 24)
pdf.set_font("Arial", "B", 28)
pdf.set_text_color(*C_WHITE)
pdf.cell(0, 14, "EcoScan")
pdf.set_xy(15, 40)
pdf.set_font("Arial", "", 13)
pdf.cell(0, 8, "Application Mobile — Gestion des Dechets & Recyclage")
pdf.set_xy(15, 51)
pdf.set_font("Arial", "B", 15)
pdf.set_text_color(200, 230, 201)
pdf.cell(0, 8, "Codes PlantUML — Diagrammes UML")

pdf.set_text_color(*C_BLACK)
pdf.set_xy(15, 82)
pdf.set_font("Arial", "B", 12)
pdf.cell(0, 8, "Contenu de ce document :")
pdf.ln(2)

cards = [
    (C_GREEN_DARK,  "01", "Cas d'Utilisation",  "8 packages, 35+ UC, acteurs humains & systemes externes"),
    (C_GREEN_MID,   "02", "Sequence 1",          "Scanner un dechet — Camera, TFLite, YOLOv8, Firestore"),
    (C_BLUE_DARK,   "03", "Sequence 2",          "Login — Firebase Auth, UserProvider, GoRouter"),
    (C_PURPLE,      "04", "Sequence 3",          "EcoBot — Gemini RAG, fallback offline, Defis"),
    (C_PURPLE,      "05", "Diagramme de Classes","Modeles, Services, Providers Riverpod, Enumerations"),
]

for col, num, title, desc in cards:
    pdf.set_fill_color(*col)
    pdf.set_text_color(*C_WHITE)
    pdf.set_font("Arial", "B", 10)
    pdf.cell(18, 9, f"  {num}", fill=True)
    pdf.set_fill_color(*C_GREY_LIGHT)
    pdf.set_text_color(*C_BLACK)
    pdf.set_font("Arial", "B", 9)
    pdf.cell(50, 9, f"  {title}", fill=True)
    pdf.set_font("Arial", "", 8.5)
    pdf.cell(0, 9, f"  {desc}", fill=True, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(1)

pdf.set_xy(15, 200)
pdf.set_font("Arial", "I", 8)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 6, "PFE 2025-2026  |  Hammoucha Badreddine  |  badreddinehammoucha@gmail.com  |  Flutter + Firebase + IA", align="C")

# --- Legende couleurs syntaxe -------------------------------------------------
pdf.set_xy(15, 215)
pdf.set_font("Arial", "B", 9)
pdf.set_text_color(*C_BLACK)
pdf.cell(0, 6, "Legende de la coloration syntaxique :", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
legend = [
    (C_KEYWORD,    "Mots-cles (@startuml, skinparam, class, package, actor...)"),
    (C_STRING,     "Chaines de caracteres (labels, titres entre guillemets)"),
    (C_COMMENT,    "Commentaires et separateurs (', //, ==...==)"),
    (C_ARROW,      "Relations et fleches (->, -->, ..>, <|--, *-->)"),
    ((180,220,180),"Attributs et methodes (+, -, #)"),
    (C_CODE_FG,    "Code general (noms de variables, types, valeurs)"),
]
for color, label in legend:
    pdf.set_fill_color(*color)
    pdf.rect(pdf.l_margin, pdf.get_y() + 1, 6, 4, "F")
    pdf.set_x(pdf.l_margin + 8)
    pdf.set_font("Arial", "", 8)
    pdf.cell(0, 6, label, new_x=XPos.LMARGIN, new_y=YPos.NEXT)


# =============================================================================
#  PAGES DE CODE
# =============================================================================
for diag in DIAGRAMS:
    pdf.add_page()
    pdf.diagram_header(diag)
    pdf.section_label(f"Code PlantUML complet — copiez-collez sur plantuml.com", diag["badge_color"])
    pdf.ln(1)
    pdf.code_block(diag["code"], diag["badge_color"])


# --- Sauvegarde ---------------------------------------------------------------
out = r"C:\Users\H.Badreddine\Desktop\PFE\ecoscan\EcoScan_PlantUML_Codes.pdf"
pdf.output(out)
print(f"PDF genere : {out}")
