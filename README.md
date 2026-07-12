<div align="center">

# 🏍️ MotoStock Pro

**Système de gestion de stock pour pièces et périphériques moto**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?logo=supabase)](https://supabase.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](pubspec.yaml)

</div>

---

## 📋 À propos du projet

**MotoStock Pro** est une application de gestion de stock complète dédiée aux magasins et ateliers de pièces moto. Construite avec Flutter, elle offre une expérience fluide sur **Desktop (Windows, Linux)** et **Web**, avec une synchronisation cloud via Supabase.

---

## ✨ Fonctionnalités

| Module | Description |
|---|---|
| 📦 **Stock** | Gestion complète des pièces (entrées, sorties, inventaire) |
| 🔩 **Pièces** | Catalogue de pièces avec codes-barres et références |
| 🏪 **Fournisseurs** | Gestion des fournisseurs et contacts |
| 📋 **Commandes** | Suivi des commandes fournisseurs et clients |
| 🌐 **Commandes Web** | Interface de commande en ligne synchronisée |
| 💰 **Caisse** | Module de caisse et transactions |
| 📊 **Rapports** | Rapports PDF, statistiques et graphiques |
| 🔔 **Alertes** | Alertes de stock bas et notifications |
| 📈 **Dashboard** | Tableau de bord avec indicateurs clés |
| 🔐 **Auth** | Authentification sécurisée via Supabase |

---

## 🛠️ Stack technique

### Frontend
- **[Flutter](https://flutter.dev)** — Framework UI cross-platform
- **[Riverpod](https://riverpod.dev)** — Gestion d'état réactive
- **[Go Router](https://pub.dev/packages/go_router)** — Navigation déclarative
- **[FL Chart](https://pub.dev/packages/fl_chart)** — Graphiques et statistiques

### Base de données
- **[Drift](https://drift.simonbinder.eu/)** — ORM SQLite local (offline-first)
- **[SQLite3](https://pub.dev/packages/sqlite3_flutter_libs)** — Base de données embarquée

### Backend & Sync
- **[Supabase](https://supabase.io)** — Backend cloud (Auth + Realtime + PostgreSQL)

### PDF & Codes-barres
- **[pdf](https://pub.dev/packages/pdf)** + **[printing](https://pub.dev/packages/printing)** — Génération et impression PDF
- **[barcode_widget](https://pub.dev/packages/barcode_widget)** — Génération de codes-barres

---

## 🖥️ Plateformes supportées

| Plateforme | Support |
|---|---|
| 🪟 Windows | ✅ Supporté |
| 🐧 Linux | ✅ Supporté |
| 🌐 Web | ✅ Supporté |
| 📱 Mobile (iOS/Android) | 🚧 Non testé |

---

## 🚀 Installation & Démarrage

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- [Dart SDK](https://dart.dev/get-dart) `>=3.0.0`
- Un compte [Supabase](https://supabase.com) (pour la synchronisation cloud)

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-username/motostock-pro.git
cd motostock-pro
```

### 2. Configurer Supabase

Créez (ou modifiez) le fichier `lib/core/config/supabase_config.dart` :

```dart
class SupabaseConfig {
  static const String url = 'VOTRE_SUPABASE_URL';
  static const String anonKey = 'VOTRE_SUPABASE_ANON_KEY';
}
```

> ⚠️ **Ne committez jamais** vos clés Supabase dans le dépôt. Utilisez des variables d'environnement ou un fichier `.env` exclu du `.gitignore`.

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Générer le code (Drift + Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Lancer l'application

```bash
# Desktop (Windows)
flutter run -d windows

# Desktop (Linux)
flutter run -d linux

# Web
flutter run -d chrome
```

---

## 📂 Structure du projet

```
lib/
├── main.dart               # Point d'entrée de l'application
├── app.dart                # Configuration de l'app (router, thème)
├── core/
│   ├── config/             # Configuration (Supabase, constantes)
│   ├── database/           # Schéma Drift & DAOs
│   ├── router/             # Navigation (Go Router)
│   ├── services/           # Services métier
│   ├── theme/              # Thème de l'application
│   └── utils/              # Utilitaires
└── features/
    ├── alerts/             # Alertes de stock
    ├── auth/               # Authentification
    ├── caisse/             # Module caisse
    ├── commandes/          # Gestion des commandes
    ├── commandes_web/      # Commandes en ligne
    ├── dashboard/          # Tableau de bord
    ├── fournisseurs/       # Gestion fournisseurs
    ├── pieces/             # Catalogue pièces
    ├── rapports/           # Rapports & PDF
    └── stock/              # Gestion du stock
```

---

## 🔄 Génération de code

Ce projet utilise la génération de code avec `build_runner`. Après toute modification des fichiers `.dart` annotés (Drift, Riverpod), relancez :

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📜 Scripts utilitaires

| Script | Description |
|---|---|
| `clean_supabase.ps1` | Nettoyer le cache Supabase |
| `test_sync.ps1` | Tester la synchronisation |
| `download_drift.py` | Télécharger les dépendances Drift |
| `fix_wasm.py` | Correctif pour la compilation WASM (Web) |


---

## 📄 Licence

Ce projet est sous licence **MIT** — voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

<div align="center">

Made By Feres Ouerfelli

</div>
