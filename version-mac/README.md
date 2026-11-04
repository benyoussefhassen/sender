# Sender Pro V4.65.6 — Édition Native macOS (Apple Silicon ARM64 & Intel Universal)

Application native macOS complète (**Swift / SwiftUI + AppKit + WebKit + SQLite3 + Network**) reproduisant fidèlement l'intégralité des fonctionnalités, des interfaces, des modales et des workflows de la suite Windows **Sender Pro V4.65.6** (analysée à partir des binaires et symboles `.pdb` de `ref/`, de la documentation officielle [Sender Pro](https://senderprov.com/blog/categories/features), des tutoriels [YouTube @senderprov](https://www.youtube.com/@senderprov/videos) et des **11 enregistrements vidéo locaux** de l'application Windows en fonctionnement réel).

---

## 1. Livrables Disponibles dans `version-mac/`

- **Application macOS native (`.app` Universal Binary `arm64` + `x86_64`)** : [`dist/Sender Pro.app`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/Sender%20Pro.app)
- **Archive distribuable prête à l'installation (`.app.zip`)** : [`dist/SenderPro-V4.65.6-macOS-Universal.app.zip`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/SenderPro-V4.65.6-macOS-Universal.app.zip)
- **Binaire natif Apple Silicon (`arm64`)** : [`dist/SenderProMac-arm64`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/SenderProMac-arm64)
- **Binaire natif Intel (`x86_64`)** : [`dist/SenderProMac-x86_64`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/SenderProMac-x86_64)
- **Binaire Universel (`arm64` + `x86_64`)** : [`dist/SenderProMac-Universal`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/SenderProMac-Universal)
- **Script de compilation et packaging** : [`Scripts/build_app_and_dmg.sh`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/Scripts/build_app_and_dmg.sh)

### Documentation Technique & Rapports d'Audit

- **Rapport d'Audit Technique & Analyse des 11 Vidéos Windows** : [`docs/AUDIT_TECHNIQUE_ET_VIDEOS_WINDOWS.md`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/docs/AUDIT_TECHNIQUE_ET_VIDEOS_WINDOWS.md)
- **Matrice Exhaustive de Parité Fonctionnelle (Code C# × Vidéos × macOS)** : [`docs/MATRICE_PARITE_FONCTIONNELLE.md`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/docs/MATRICE_PARITE_FONCTIONNELLE.md)
- **Spécifications d'Architecture macOS** : [`docs/SPECIFICATIONS_ARCHITECTURE_MACOS.md`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/docs/SPECIFICATIONS_ARCHITECTURE_MACOS.md)
- **Rapport de Compatibilité, Fonctionnalités Migrées & Tests Fonctionnels** : [`docs/RAPPORT_COMPATIBILITE_ET_TESTS.md`](file:///Users/hassen/AI/sender-pro-mac-v2/version-mac/docs/RAPPORT_COMPATIBILITE_ET_TESTS.md)

---

## 2. Architecture du Projet (`version-mac/`)

```text
/Users/hassen/AI/sender-pro-mac-v2/version-mac/
├── Package.swift
├── README.md
├── Scripts/
│   └── build_app_and_dmg.sh
├── Sources/SenderProMac/
│   ├── App/
│   │   └── SenderProMacApp.swift                  # Point d'entrée, Menus natifs, Raccourcis (⌘1..⌘4, ⌘B, ⌘M, ⌘D, ⌘K, ⌘L), Positionnement Dual-Screen
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── AppModels.swift                    # Modèles de données, 20 plateformes Marketing, 29 connecteurs B2B, UIState
│   │   │   └── ToolCatalog.swift                  # Catalogue complet des 86+ outils Marketing, 29 portails B2B et 18 serveurs SMTP/POP3
│   │   ├── Database/
│   │   │   └── PersistenceManager.swift           # Base SQLite3 (SenderPro.sqlite), globalSettings.ini, sessions JSON/MTProto
│   │   └── Export/
│   │       └── ExportService.swift                # Générateur natif Excel (.xlsx OpenXML), CSV (UTF-8 BOM), VCF (vCard 3.0) et TXT
│   ├── Engines/
│   │   ├── BrowserAutomation/
│   │   │   └── BrowserSessionManager.swift        # Navigateur automatisé côte à côte (WKWebView multi-sessions + Chrome/Brave CLI)
│   │   └── Automation/
│   │       └── ExecutionEngine.swift              # Scraping DOM/HTTP temps réel, Spintax/Variables, Pause anti-ban, Serveur HTTP ToolsDashboard (:31111)
│   └── UI/
│       ├── Components/
│       │   └── HeaderAndFooterViews.swift         # En-tête à 7 icônes (Analytics, Vidéos, Account Time, Support) & Pied de page (AR/EN, Light/Dark)
│       ├── Modals/
│       │   └── ManageBrowsersAndContentModals.swift # Important Warning, Manage Browsers (Modes A/B/C), + Manage Content & + Content Editor (Translate), ToolsDashboard
│       └── Workspaces/
│           ├── MarketingWorkspaceView.swift       # Espace Marketing (20 sections, Dashboard > Security & Account 3×3, Grilles d'outils)
│           ├── ToolExecutionPanelView.swift       # Panneaux d'exécution spécialisés (Login, WhatsApp Filter, SMTP 4-Step Wizard, Magic Editor, Text Editor, VCF, etc.)
│           └── B2BAndAnalysisAndExtensionsViews.swift # Sender Pro B2B (29 connecteurs), Data Analysis (16 colonnes), 15 Extensions Chrome/Brave, Launcher
├── Tests/SenderProMacTests/
│   └── SenderProMacTests.swift
├── dist/
│   ├── Sender Pro.app                             # Bundle macOS complet avec AppIcon.icns et binaire universel
│   ├── SenderPro-V4.65.6-macOS-Universal.app.zip  # Archive distribuable
│   ├── SenderProMac-Universal                     # Binaire Mach-O Universal (arm64 + x86_64)
│   ├── SenderProMac-arm64                         # Binaire Mach-O Apple Silicon (arm64)
│   └── SenderProMac-x86_64                        # Binaire Mach-O Intel (x86_64)
└── docs/
    ├── AUDIT_TECHNIQUE_ET_VIDEOS_WINDOWS.md
    ├── MATRICE_PARITE_FONCTIONNELLE.md
    ├── SPECIFICATIONS_ARCHITECTURE_MACOS.md
    └── RAPPORT_COMPATIBILITE_ET_TESTS.md
```

---

## 3. Installation et Lancement

### Lancer directement l'application `.app`
```bash
open "/Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/Sender Pro.app"
```
Vous pouvez également glisser-déposer `Sender Pro.app` dans votre dossier `/Applications`.

### Raccourcis Clavier macOS Natifs
- `⌘1` : Ouvrir **Sender Pro V4 Marketing** (20 plateformes sociales)
- `⌘2` : Ouvrir **Sender Pro B2B** (29 extracteurs d'annuaires B2B et Google Maps)
- `⌘3` : Ouvrir **Sender Pro Data Analysis** (Résolveur démographique Facebook à 16 colonnes)
- `⌘4` : Ouvrir **Chrome & Brave Extensions** (Gestionnaire des 15 extensions Manifest V3)
- `⌘0` : Ouvrir **Sender Pro Launcher**
- `⌘B` : Ouvrir **Manage Browsers / Manage Telegram**
- `⌘M` : Ouvrir **+ Manage Content / + Content Editor**
- `⌘D` : Ouvrir **ToolsDashboard** (et accessible via navigateur sur `http://127.0.0.1:31111/ToolsDashboard.html`)
- `⌘K` : Afficher la fenêtre du **Navigateur Automatisé du Programme** côte à côte (moitié gauche de l'écran)
- `⌘L` : Basculer instantanément la langue **Arabic ↔ English**
- `⇧⌘T` : Basculer le thème **Light ↔ Dark**

---

## 4. Compilation et Développement

Pour recompiler les binaires `arm64`, `x86_64`, le binaire universel et reconstruire `dist/Sender Pro.app` :
```bash
cd /Users/hassen/AI/sender-pro-mac-v2/version-mac
./Scripts/build_app_and_dmg.sh
```
