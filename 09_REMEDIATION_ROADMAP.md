# 09 — FEUILLE DE ROUTE DE REMÉDIATION (ORDRE EXACT DES TRAVAUX)

**Date de l'audit :** 2026-04-06  
**Statut actuel :** Audit en lecture seule terminé — **Aucune modification de code n'a été effectuée.**  
**Condition préalable :** Cette feuille de route définit l'ordre exact des corrections à exécuter **uniquement après validation explicite de l'utilisateur**.

---

## Vue d'ensemble des priorités

Les travaux de remédiation sont structurés en **6 phases séquentielles**, ordonnées selon la gravité des risques (Sécurité -> Câblage architectural des moteurs -> Courriel SMTP/POP3 -> Connecteurs B2B -> Automatisation sociale & WebKit -> Telegram & Modules complémentaires).

---

## PHASE 1 — Correction Immédiate des Failles de Sécurité & Hygiène du Code (Priorité P0 — Critique)

**Objectif :** Éliminer toute fuite de secrets en clair sur le disque et nettoyer les données personnelles codées en dur avant tout test réseau réel.

1. **Supprimer le fichier `.vault_master_key` en clair (`CredentialVault.swift` L96–134) :**
   - Retirer définitivement le fallback qui écrit la clé symétrique AES-GCM 256 bits dans `AppData/.vault_master_key`.
   - Stocker la clé exclusivement dans le **Keychain macOS** (`kSecClassGenericPassword`, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`) et gérer proprement les erreurs sans jamais écrire la clé sur le système de fichiers.
2. **Supprimer le fichier temporaire de mot de passe SMTP en clair (`RealSMTPEngine.swift` L223–243) :**
   - Dans `sendEmailViaPythonBridge`, ne plus jamais écrire `password` dans `/var/folders/.../T/smtp_cfg_<UUID>.json`.
   - Transmettre la configuration JSON (incluant le mot de passe déchiffré en mémoire) directement via le tube standard **`stdin` (`Pipe`)** du processus Python, ou utiliser exclusivement le client Swift `NWConnection` après fiabilisation de sa machine à états TLS.
3. **Chiffrer les secrets résiduels en base et sur disque :**
   - Chiffrer les fichiers de cookies JSON exportés dans `AppData/SenderProBrowsers/ browser_<UUID>_cookies.json` via `CredentialVault` (`BrowserSessionManager.swift` L325–352).
   - Chiffrer le champ `twoFactorSecret` des sessions Telegram avant insertion dans SQLite (`ManageBrowsersAndContentModals.swift` L584–607).
4. **Purger les données personnelles codées en dur & Initialiser Git :**
   - Remplacer `"hassenshili@gmail.com"` dans `AppModels.swift` (L315) et `PersistenceManager.swift` (L375) par une chaîne vide `""`.
   - Initialiser un dépôt Git propre dans `/Users/hassen/AI/sender-pro-mac-v2/version-mac` avec un `.gitignore` excluant `.build/`, `dist/`, `*.app`, `*.zip`, `*.dmg` et `AppData/`.
   - Nettoyer `Scripts/build_app_and_dmg.sh` pour supprimer les `|| true` et `2>/dev/null` qui masquent les erreurs de compilation ou de signature.

---

## PHASE 2 — Réparation du Moteur SMTP / POP3 et de l'Assistant Email (Priorité P0 — Critique)

**Objectif :** Garantir un envoi d'emails réel, sécurisé, contrôlable (`Stop` fonctionnel) et conforme aux RFC.

1. **Bloquer le downgrade silencieux `STARTTLS` (`RealSMTPEngine.swift` L382–406) :**
   - Lorsque `account.useTLS && account.port != 465`, exiger la présence de `250-STARTTLS` et la réponse `220` avant d'envoyer `AUTH`. Si le serveur ne propose pas `STARTTLS` ou si la commande échoue, interrompre immédiatement la connexion avec une erreur explicite (`STARTTLS_REQUIRED_BUT_NOT_SUPPORTED`) sans jamais envoyer les identifiants en clair.
2. **Ajouter les champs `SMTP Host`, `SMTP Port`, `POP3 Host`, `POP3 Port` et `TLS Mode` à l'étape 1 du Wizard (`ToolExecutionPanelView.swift` L768–806) :**
   - Permettre à l'utilisateur de saisir et modifier l'hôte et le port de n'importe quel serveur SMTP/POP3 (au lieu de dépendre uniquement de la détection automatique sur Gmail/Outlook/Yahoo/iCloud).
   - Appeler `PersistenceManager.shared.saveSMTPAccount(...)` lors de la validation du compte.
3. **Réparer le bouton `Stop`, la limite d'envoi (`sendLimitCount`), la vérification préalable (`verifyBeforeSend`) et les copies `CC`/`BCC` (`ToolExecutionPanelView.swift` L875–979) :**
   - Exécuter la boucle de campagne dans une `Task` gérée par `ExecutionEngine` (`engine.isRunning = true`, `engine.activeTask`) afin que le bouton `Stop` s'affiche et interrompe immédiatement l'envoi (`Task.isCancelled`).
   - Appliquer `Int(sendLimitCount)` et, si `verifyBeforeSend` est activé, filtrer chaque adresse via `EmailVerifierEngine.shared.verifyEmail(...)` avant l'envoi.
   - N'inclure `ccList` et `bccList` que sur le premier envoi ou permettre un envoi groupé configurable, au lieu de renvoyer une copie aux adresses `CC` à chaque destinataire de la boucle.
   - Interpoler les variables `[Name]`, `[Email]`, `[C1]`..`[C5]` et le Spintax `{A|B}` dans l'objet et le corps HTML/texte de chaque email.

---

## PHASE 3 — Déblocage Architectural de `ExecutionEngine` & `WKWebView` (Priorité P1 — Majeure)

**Objectif :** Connecter réellement les sessions `WKWebView` authentifiées aux moteurs d'extraction et d'action, et supprimer les simulations des tests.

1. **Exploiter réellement le DOM `WKWebView` dans `scrapeLiveWebData` (`ExecutionEngine.swift` L278–320) :**
   - Remplacer `let _ = await activeBrowser.evaluateJS(jsScript)` (L306) par la lecture effective du JSON extrait directement dans le DOM vivant du `WKWebView` (qui possède les cookies de session de l'utilisateur et exécute le JavaScript des SPA).
   - Synchroniser les cookies du `WKWebsiteDataStore` (`httpCookieStore.getAllCookies()`) vers une configuration `URLSessionConfiguration.ephemeral` dédiée lorsque des requêtes HTTP complémentaires sont nécessaires.
2. **Appliquer réellement les Proxys aux navigateurs (`BrowserSessionManager.swift` L215–260) :**
   - Sur macOS 14+, traduire `proxyHostPort` (HTTP Connect ou SOCKS5) en `ProxyConfiguration(httpConnectProxy: ...)` ou `ProxyConfiguration(socksv5Proxy: ...)` et l'affecter à `websiteDataStore.proxyConfigurations` avant de créer le `WKWebView`.
3. **Supprimer le court-circuit de test `SENDERPRO_HEADLESS_TEST=1` (`BrowserSessionManager.swift` L176–186) :**
   - Retirer le bloc qui retourne `"MESSAGE_INJECTED_IN_DOM"` sur simple présence du mot `"contenteditable"` dans `lastLoadedHTML`. Exiger que `webView.evaluateJavaScript` s'exécute réellement.

---

## PHASE 4 — Finalisation Individuelle des 29 Connecteurs B2B (Priorité P1 — Majeure)

**Objectif :** Rendre chaque connecteur B2B réellement fonctionnel sur son site cible et corriger le mapping des colonnes.

1. **Corriger le mapping des colonnes B2B (`B2BConnectorEngine.swift` L49 & `ExecutionEngine.swift` L520–561) :**
   - Étendre `B2BExtractedEntity` avec un dictionnaire typé `attributes: [String: String]` (`website`, `email`, `specialty`, `crNumber`, `licenseNumber`, `seller`, `agent`, `company`, `brand`, `category`, `price`, `date`, `whatsapp`).
   - Mettre à jour `mapEntityToColumns` (L520–561) pour associer chaque colonne à son attribut réel et **ne plus jamais retourner `entity.title` par défaut** (retourner `""` si un champ est absent sur une fiche).
2. **Router les connecteurs SPA JavaScript et à numéros masqués vers `WKWebView` :**
   - Pour `Google Maps` (#1), `Google Travel` (#2), `Maroof SA` (#6), `Ejaar` (#7), `Haraj` (#8), `Bayut` (#9), `Property Finder` (#10), `Dubizzle` (#11–#17) et `OpenSooq` (#18–#22) : charger l'URL dans une instance `WKWebView`, attendre la stabilisation du DOM, exécuter le script de défilement et de révélation des numéros, puis extraire les cartes structurées via `evaluateJS`.
   - Dans le panneau Google Maps (`ToolExecutionPanelView.swift` L114–116 & L669–740), câbler effectivement `extractEmailEnabled` (visite du site web de l'établissement trouvé pour en extraire l'email) et `extractWhatsAppEnabled`, ainsi que le navigateur choisi `selectedGoogleMapsBrowser`.
3. **Remplacer le test synthétique de la Suite 04 par un banc d'essai individuel réel :**
   - Supprimer la chaîne HTML synthétique unique de `runAll29ConnectorsIndividualAudit` (`B2BConnectorEngine.swift` L498–519) et tester chaque connecteur individuellement avec rapport détaillé (statut HTTP réel, champs extraits, pagination, ou `BLOCKED_EXTERNAL` documenté si anti-bot).

---

## PHASE 5 — Câblage Complet des 145 Outils Marketing & Automatisation Sociale (Priorité P1 — Majeure)

**Objectif :** Sortir les 74 outils d'action de l'état `UI_ONLY` en routant les 23 `ToolPanelKind` vers de vrais workflows d'automatisation DOM dans `WKWebView`.

1. **Câbler les 15 `ToolPanelKind` manquants dans `ToolExecutionPanelView.swift` (L111–132) :**
   - Ajouter les vues et contrôleurs dédiés pour `.groupMembersExtractor`, `.socialLeadExtractor`, `.bulkGroupJoiner`, `.socialPostPublisher`, `.socialEngagementBot`, `.commentMentionBot`, `.telegramAccountManager`, `.telegramChannelScraper`, `.whatsappGroupSender`, `.whatsappGroupTools`, `.communityBroadcast`, `.videoTrendScraper`, `.marketplaceScraper` et `.jobCompanyScraper`.
2. **Séparer l'exécution des outils d'Action et des outils d'Extraction dans `startToolExecution()` (`ToolExecutionPanelView.swift` L1359) :**
   - Lorsque l'outil est un outil d'action (`Broadcast`, `Marketing`, `Mention`, `Post In Groups`, `Follow`, `Add User`, `Vote`, `Upload`), ne plus appeler `scrapeLiveWebData()`.
   - Récupérer le modèle de message actif dans `Manage Content`, appliquer le moteur Spintax (`{A|B}`), remplacer `[Name]` et les colonnes magiques `[C1]`..`[C5]` (`magicColumnIndex`), et invoquer un nouveau pipeline `ExecutionEngine.runSocialActionCampaign(...)`.
3. **Implémenter le clic d'action et la vérification post-action dans `SocialAutomationEngine.swift` (L333–385) :**
   - Compléter `buildDOMAutomationScript` pour non seulement injecter le message dans le champ de saisie, mais aussi localiser et déclencher le clic (`.click()` / `KeyboardEvent('Enter')`) sur le bouton d'envoi, de publication, de réaction (`selectedReactionType`), de suivi (`Follow`) ou de vote, puis vérifier dans le DOM l'apparition du message envoyé ou le changement d'état du bouton avant de compter `successCount += 1`.
4. **Implémenter le planificateur (`Scheduled Tasks`) :**
   - Remplacer le bouton factice `Confirm Schedule` (`ToolExecutionPanelView.swift` L327–342) par un vrai `Timer` / `Task.sleep` géré dans `ExecutionEngine` avec liste des tâches planifiées annulables.

---

## PHASE 6 — Telegram (Bot API + Décision Architecture MTProto) & Formats de Fichiers (Priorité P2)

1. **Telegram :**
   - Câbler immédiatement `callOfficialTelegramBotAPI` (`TelegramMTProtoEngine.swift` L230) à l'interface pour permettre l'envoi réel via Bot API (`sendMessage`, `sendPhoto`, `sendDocument`) lorsque l'utilisateur fournit un Bot Token.
   - Supprimer les simulations dans `ManageBrowsersModalView.swift` (`"100% active"` en dur à la ligne 538 et sauvegarde OTP fictive à la ligne 584) ainsi que le blob factice `0xAB` de la Suite 06.
   - Pour les fonctionnalités de compte utilisateur Telegram (MTProto), intégrer `TDLib` (`libtdjson` / `TDLibKit`) ou piloter `web.telegram.org/k/` via `WKWebView` authentifié avec automatisation DOM réelle.
2. **Formats PDF / XLSX & Vérification WhatsApp :**
   - Utiliser `PDFKit` natif macOS dans `importRecordsFromFile` pour extraire le texte des fichiers `.pdf` binaires.
   - Ajouter le support de lecture/écriture `.xlsx` (via `CoreXLSX` / XML OpenPackaging) si requis pour l'échange direct de fichiers avec la version Windows.
   - Connecter le filtre de numéros WhatsApp (`phoneFilter`) à une vérification DOM réelle dans une session `web.whatsapp.com` authentifiée au lieu d'une simple regex de longueur.
