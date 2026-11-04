# Spécifications Techniques & Architecture de `Sender Pro V4.65.6` pour macOS

## 1. Principes Directeurs d'Ingénierie

Pour garantir une parité fonctionnelle et ergonomique totale avec la version Windows **`Sender Pro V4.65.6`** observée dans les 11 vidéos locales et les binaires `.exe` / `.pdb` de `ref/`, la version macOS (`/Users/hassen/AI/sender-pro-mac-v2/version-mac`) est conçue comme une **application native macOS en Swift / SwiftUI + AppKit** compilée pour **Apple Silicon (`arm64`)** (et compatible Universal Binary), intégrant :

1. **Quatre Espaces de Travail Unifiés (ou Fenêtres Indépendantes via le Launcher)** :
   * **`Sender Pro Launcher`** : Portail de lancement affichant l'état des versions (`Start` / `Update`) pour les 3 programmes (`Sender Pro V4 Marketing`, `Sender Pro B2B`, `Sender Pro Data Analysis`) + le gestionnaire des **15 Extensions Chrome/Brave**.
   * **`Sender Pro V4 Marketing`** : Les 20 entrées de la barre latérale observées dans V01–V10 (`Dashboard` [avec sous-menus `Security` et `Account`], `Facebook`, `Whatsapp`, `Instagram`, `Threads`, `Twitter`, `X Plus`, `LinkedIn`, `Telegram`, `Premium`, `SnapChat`, `Imo`, `Pinterest`, `Send Emails`, `Google` [`SMS`, `Google Rate`, `Contacts`], `Vk`, `Reddit`, `Auto Point` [`Like4Like`, `Getlike`, `Other`], `Other Tools` [`Download`, `Haraj Rate`, `Magic Editor`, `Text Editor`, `Text As vcf`, `Generate`, `Hashtags`]).
   * **`Sender Pro B2B` (`Sender Pro Data`)** : Les 29 extracteurs B2B observés dans V11 avec workflow en 2 étapes (`Scrap Links` -> `Extract Data`), ouverture du site cible, extraction Email/WhatsApp sur Google Maps et export direct `.xlsx` / `.csv` / `.txt`.
   * **`Sender Pro Data Analysis`** : Résolveur démographique Facebook à 16 colonnes (`UID` -> Email, Téléphone, Religion, Date de naissance, Genre, Lien profil, Prénom, Nom, Username, Profession, Ville d'origine, Ville actuelle, Spécialité, Université).

2. **Fidélité Absolue aux Composants Transversaux Observés dans V01–V11** :
   * **En-tête à 7 actions globales** :
     1. Tableau de bord analytique **`ToolsDashboard`** (avec graphiques Succès/Échec, Timeline, journal d'activité filtrable, export CSV et serveur HTTP local optionnel sur le port `31111`).
     2. Centre de tutoriels vidéo.
     3. Enregistreur d'écran natif macOS (`ScreenCaptureKit` / `AVFoundation`).
     4. Popover **`Account Time - الوقت المتبقي`** (`Marketing`, `Data`, `Support`).
     5. **`Support Center`** (`SupportCenter`).
     6. Contrôles de fenêtre.
   * **Modales `Manage Browsers` (Modes A & B) et `Manage Telegram` (Mode C)** :
     * Gestion réelle de multiples fenêtres/sessions navigateur (`WKWebView` isolées par `WKWebsiteDataStore` **et** lancement de Google Chrome / Brave / Chromium sur macOS avec `--user-data-dir` et `--proxy-server` par session, sauvegarde/chargement de sessions `.json`/`.sbd`, désactivation d'images).
     * Gestion des sessions Telegram `.session` avec `Api ID`, `Api Hash`, numéro de téléphone, code OTP et mot de passe 2FA.
   * **Modales `+ Manage Content` et `+ Content Editor`** :
     * Création, édition, suppression, recherche, filtrage par label, import en masse (`Bulk Import`), sélection multiple (`Use Selected`), rotation aléatoire (`Use Random Content`), bouton **`Translate`** (traduction automatique AR/EN/FR), insertion des variables (`[Sender Name]`, `[Group Name]`, `[Sender Date and Time]`, `[Random Text]`), et attachement de jusqu'à 30 fichiers médias.
   * **Moteur d'Exécution & Validations Métier Réelles** :
     * Vérification systématique des prérequis avant démarrage (sessions ouvertes, contenu sélectionné, URL/mot-clé saisi, fichier de sortie choisi) avec affichage des alertes bilingues exactes observées dans les vidéos.
     * Exécution asynchrone annulable (`Start` / `Pause` / `Stop`), compteurs temps réel (`Count / N` ou `Processed / Total / Failed`), pause périodique (`Stop On Count` / `Wait For Minutes`), délai fixe (`Time`) + délai aléatoire (`Random Time` configuré dans `Dashboard > Security`).
     * Persistance SQLite/JSON locale dans `~/Library/Application Support/SenderPro/` et export réel en `.xlsx` (OpenXML), `.csv` (UTF-8 avec BOM pour Excel) et `.vcf` (vCard 3.0).
   * **Pied de page Bilingue (`Arabic` / `English`) & Thème (`Light` / `Dark`)** :
     * Commutateurs temps réel en pied de fenêtre adaptant immédiatement tous les libellés et les couleurs de l'interface.
