# EcoScan — Application Mobile de Tri des Déchets Recyclables

EcoScan est une application mobile Flutter qui aide les utilisateurs à identifier et trier correctement leurs déchets grâce à l'intelligence artificielle. L'utilisateur prend une photo d'un déchet, l'IA détecte les composantes de l'objet (corps, bouchon, étiquette…) et indique comment recycler chaque partie.

## Fonctionnalités principales

- **Scan IA** : détection des composantes d'un déchet par photo (Claude Vision)
- **Scan code-barres** : identification de produits par QR code / code-barres
- **Chatbot EcoBot** : assistant conversationnel intelligent (RAG + LangChain)
- **Carte des points de collecte** : localisation GPS des 6 CEV officiels PNDM
- **Historique des scans** : consultation des scans précédents avec images et résultats
- **Classement & badges** : système de points, défis et récompenses pour encourager le tri
- **Météo environnementale** : données météo et qualité de l'air en temps réel
- **Guide de tri** : fiches pratiques par type de déchet
- **Marketplace** : espace d'échange de produits recyclés
- **4 langues** : français, anglais, arabe, espagnol
- **Authentification** : email/mot de passe, Google Sign-In, vérification email, 2FA

## Architecture

```
EcoScan/
├── Frontend/          # Application Flutter (Android/iOS)
├── Backend/           # API principale (FastAPI) — auth, historique, météo
```

Le projet utilise **3 services backend** déployés indépendamment :

| Service | Rôle | Dépôt |
|---|---|---|
| Backend principal | Authentification, historique, météo, communauté | Ce dépôt (`/Backend`) |
| Scan API | Détection IA des déchets via Claude Vision | [ecoscan-model-online-](https://github.com/BREETE5A/ecoscan-model-online-) |
| Chatbot API | EcoBot — RAG avec LangChain + ChromaDB | [Ecoscan-chatbot](https://github.com/BREETE5A/Ecoscan-chatbot) |

## Stack technique

**Frontend**
- Flutter 3 / Dart
- Riverpod (gestion d'état)
- Firebase Auth + Firestore
- GoRouter, flutter_map, fl_chart

**Backend**
- Python / FastAPI
- Firebase Admin SDK
- PostgreSQL (via SQLAlchemy)
- ChromaDB (base vectorielle pour le chatbot)
- LangChain + Google Gemini

**IA**
- Claude Haiku 4.5 (Anthropic) — analyse visuelle des déchets
- Sentence Transformers — embeddings pour le RAG
- Google Gemini — génération de réponses du chatbot

**Infrastructure**
- Déployé sur Render
- Firebase pour l'authentification et la base de données
- n8n pour les workflows d'automatisation (emails de bienvenue)

## Lancer le projet en local

### Prérequis
- Flutter SDK >= 3.x
- Python >= 3.10
- Un fichier `.env` avec les clés API (à demander au développeur)

### Frontend
```bash
cd Frontend
flutter pub get
flutter run
```

### Backend principal
```bash
cd Backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Versions

- Application : v1.1.0+10
- Scan API : v4.0.0
- Chatbot API : v1.0.0

## Auteur

**Hammoucha Badreddine** — Projet de Fin d'Études (PFE)
