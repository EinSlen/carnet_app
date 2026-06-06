# 🐾 Carnet de Santé Animal

![Flutter](https://img.shields.io/badge/Flutter-Material%203-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)
![Plateforme](https://img.shields.io/badge/Android-local--first-3DDC84?logo=android&logoColor=white)
![Licence](https://img.shields.io/badge/Licence-MIT-green)
![Analyse](https://img.shields.io/badge/flutter%20analyze-0%20issue-success)

> **Le carnet de santé honnête pour les animaux qu'on aime** — pensé d'abord pour les animaux **malades chroniques et âgés**. 100 % sur le téléphone, sans pub, sans abonnement qui prend tes données en otage.

---

## ✨ Pourquoi cette app

Les apps de suivi santé animal existantes sont souvent **buguées, encombrées, et prennent les données en otage derrière un paywall** (le leader *11pets* s'est effondré à 2,1/5 pour ça). Ce projet prend le contre-pied :

- 🔒 **Vie privée d'abord** : tout est stocké **localement** sur l'appareil. Aucune donnée n'est envoyée.
- 🎯 **Niche claire** : conçu pour les propriétaires d'animaux **chroniques / âgés** (diabète, insuffisance rénale, épilepsie, arthrose…), qui ont besoin d'un suivi fiable.
- 🤝 **Honnête** : pas de pub, pas de notifications commerciales, et **on ne bloque jamais les données déjà saisies**.

### Les 3 promesses cœur
1. **Rappels de soins fiables** (notifications locales planifiées, le point faible de tous les concurrents).
2. **Saisie en 1 tap** (dose donnée, mesure, symptôme).
3. **Export PDF « prêt pour le véto »**.

---

## 📱 Fonctionnalités (MVP)

- ✅ Multi-animaux (chien, chat, lapin, rongeur, oiseau, reptile, cheval…)
- ✅ Profil complet (race, naissance, poids, n° de puce, maladies chroniques, allergies)
- ✅ Traitements + **rappels quotidiens fiables**
- ✅ **Journal en 1 tap** (médicament, symptôme, note)
- ✅ Mesures + **courbes** (poids, glycémie)
- ✅ **Export PDF** pour la consultation vétérinaire
- ✅ 100 % hors-ligne, sans compte

---

## 🎨 Design

Direction visuelle calme et rassurante (Material 3) : primaire **teal `#15807C`**, accent **corail `#F47A57`**, typographies **Nunito + Inter**.

➡️ **Aperçu des maquettes haute-fidélité** : [`docs/apercu-design.html`](docs/apercu-design.html)
➡️ **Spécifications & étude** : voir le dossier [`docs/`](docs/) (spec complète, design system, audits de marché et de concurrence).

---

## 🛠️ Stack technique

| Domaine | Choix |
|---|---|
| Framework | Flutter (Material 3) |
| Base locale | `sqflite` (relationnel, hors-ligne) |
| Rappels | `flutter_local_notifications` + `timezone` |
| Graphes | `fl_chart` |
| Export PDF | `pdf` + `printing` |
| Polices | `google_fonts` (Nunito / Inter) |

---

## 🚀 Lancer le projet

```bash
flutter pub get
flutter run
```

La configuration Android pour des rappels fiables (desugaring + permissions/receivers) est **déjà en place**.

## 🧪 Qualité

```bash
flutter analyze   # 0 issue
flutter test      # tous les tests passent
```

---

## 📂 Structure

```
lib/
  main.dart                     # entrée + thème + init notifications
  theme/app_theme.dart          # design system (palette, Material 3)
  data/
    models.dart                 # Animal, Treatment, LogEvent, Measure
    app_repository.dart         # base locale sqflite (CRUD)
  services/
    notification_service.dart   # rappels fiables
    pdf_service.dart            # export PDF véto
  screens/                      # accueil, fiche animal, formulaires, log, historique
test/
  models_test.dart              # tests unitaires des modèles
```

---

## 🗺️ Roadmap

- [ ] Vaccins & rendez-vous dédiés
- [ ] Écrans spécifiques niche : journal de crises (épilepsie), échelle de qualité de vie (senior)
- [ ] Photo de l'animal, sauvegarde/restauration, partage famille
- [ ] Version anglaise (i18n)
- [ ] Version premium (achat unique)

---

## 📄 Licence

[MIT](LICENSE) — © 2026 Valentin Damlencourt
