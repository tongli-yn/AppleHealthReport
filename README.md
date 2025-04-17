# 🍏 Apple HealthReport

**Un générateur intelligent de rapports de santé basé sur Apple HealthKit et SwiftUI**

---

## 📱 À propos du projet

**Apple HealthReport** est une application iOS développée avec **SwiftUI**, destinée à extraire, analyser et synthétiser les données de santé personnelles issues d’**Apple HealthKit**. L’application permet de :

- Afficher les principales métriques de santé quotidiennes (fréquence cardiaque, sommeil, nutrition, activité physique, etc.)
- Générer un **rapport PDF** structuré et personnalisé
- Intégrer une **synthèse intelligente** grâce à l'API **GPT-4** pour offrir des conseils personnalisés en français

Le projet a été réalisé dans le cadre du programme AI Clinic à **Aivancity**, en collaboration avec **AIDiagMe**.

---

## 🧰 Technologies utilisées

- `SwiftUI` – Interface utilisateur moderne et réactive
- `HealthKit` – Accès aux données de santé de l’utilisateur
- `Charts` – Visualisation de données avec graphiques intégrés
- `PDFKit` – Génération dynamique de rapports PDF
- `OpenAI GPT-4` – Génération de résumé personnalisé via API
- `TestFlight` – Distribution pour tests en conditions réelles
- `GitHub` – Gestion du code source et du versioning

---

## 🔍 Fonctionnalités principales

- 📊 Tableaux de bord pour : cœur, activité, nutrition, sommeil, signes vitaux
- 📈 Visualisation des tendances avec Swift Charts (FC, pas, sommeil, etc.)
- 📄 Export d’un **rapport PDF** complet avec conseils personnalisés
- 🧠 Résumé généré par **GPT-4** selon les données du jour
- 🛌 Lecture des sessions de sommeil, pleine conscience et activité
- 🚀 Déploiement via **TestFlight** (pour testeurs externes)

---

## 🔐 Autorisations nécessaires

L’application demande l’autorisation d’accéder à certaines données HealthKit :
- Données de fréquence cardiaque, sommeil, activité, nutrition
- Informations personnelles (âge, sexe biologique)

---

## 📦 Installation & Test (via TestFlight)

1. Télécharger l’application **TestFlight** sur votre iPhone
2. Accepter l’invitation reçue par mail (depuis App Store Connect)
3. Installer **Apple HealthReport** depuis TestFlight
4. Donner l'autorisation HealthKit lors du premier lancement

---

## 📄 Rapport PDF généré

Le rapport PDF contient :
- Informations personnelles (âge, sexe, taille, poids)
- Résumé des indicateurs de santé clés (IMC, sommeil, FC, etc.)
- Analyse par section : cardiovasculaire, nutrition, activité, sommeil
- Synthèse intelligente générée par GPT-4 en français

---

## 🛠️ En cours / Futures améliorations

- ✅ Localisation multilingue (anglais, chinois)
- ✅ Analyse plus fine du sommeil (durée, régularité, qualité)
- 🔜 Ajout de CoreML pour prédictions personnalisées
- 🔜 Intégration avec iCloud pour synchronisation des rapports
- 🔜 Support multi-utilisateur pour usage familial

---

## 👨‍💻 Équipe

- **Tong Li** – Étudiant PGE 4 – Aivancity  
  GitHub : [@tongli-yn](https://github.com/tongli-yn)  
  Contact : litong@aivancity.ai

---

## 🤝 Partenaire

Ce projet a été réalisé en collaboration avec **[AIDiagMe](https://www.aidiagme.com/)**, dans le cadre du programme AI Clinic – Aivancity 2025.

---

## 📜 Licence

Projet académique – Non destiné à une distribution commerciale.

