# TravelChatbot – Projet Intégré
Application mobile intelligente de chatbot de voyage, avec un backend Node.js utilisant l'API Gemini et MongoDB, et un frontend Flutter.
## ⚙️ Prérequis
- [Node.js](https://nodejs.org/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [MongoDB](https://www.mongodb.com/)
- Clé API Gemini (Google AI)
---

## Structure du projet

PROJET_INTERGRE/
├── backend/ → Node.js + Gemini + MongoDB
│ ├── index.js
│ ├── .env
│ ├── routes/
│ ├── controllers/
│ ├── services/
│ └── models/
│
└── flutter_application/ 
├── lib/
│ ├── main.dart
│ ├── pages/
│ │ └── chat_page.dart
│ └── services/
│ └── api_service.dart
└── pubspec.yaml

---

## Configuration

Crée un fichier `.env` dans le dossier `backend` avec les variables suivantes :

```env
GEMINI_API_KEY=ta_clé_api_gemini
MONGODB_URI=ton_url_mongodb
PORT=3000


### 🖥Lancer le Backend (Node.js)

Pour démarrer le serveur backend, exécutez la commande suivante :

bash:
cd backend && npm install && node index.js

### Lancer le Frontend (Flutter)

Pour démarrer l'application mobile, exécutez la commande suivante :

```bash
cd flutter_application && flutter pub get && flutter run

