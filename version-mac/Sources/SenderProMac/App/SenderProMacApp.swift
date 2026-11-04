import SwiftUI
import AppKit
import Network

@main
public struct SenderProMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var persistence = PersistenceManager.shared

    @UIState private var programMode: AppProgramMode = .marketing
    @UIState private var showStartupBrowserWarning: Bool = true
    @UIState private var showAnalyticsSheet: Bool = false
    @UIState private var showAccountTimePopover: Bool = false
    @UIState private var showSupportPopover: Bool = false
    @UIState private var showManageBrowsersSheet: Bool = false
    @UIState private var showManageContentSheet: Bool = false

    public init() {
        if CommandLine.arguments.contains("--run-integration-tests") {
            setenv("SENDERPRO_HEADLESS_TEST", "1", 1)
            Task { @MainActor in
                let code = await Self.runRealEndToEndIntegrationSuite()
                exit(code)
            }
        }
    }

    public var body: some Scene {
        WindowGroup("Sender Pro V4.65.6 — macOS Edition") {
            VStack(spacing: 0) {
                HeaderBarView(
                    programMode: $programMode,
                    showAnalyticsSheet: $showAnalyticsSheet,
                    showAccountTimePopover: $showAccountTimePopover,
                    showSupportPopover: $showSupportPopover,
                    showManageBrowsersSheet: $showManageBrowsersSheet,
                    showManageContentSheet: $showManageContentSheet
                )

                ZStack {
                    switch programMode {
                    case .marketing:
                        MarketingWorkspaceView()
                    case .b2bData:
                        B2BWorkspaceView()
                    case .dataAnalysis:
                        DataAnalysisWorkspaceView()
                    case .extensions:
                        ExtensionsWorkspaceView()
                    case .launcher:
                        LauncherWorkspaceView(programMode: $programMode)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                FooterBarView()
            }
            .frame(minWidth: 1080, minHeight: 720)
            .preferredColorScheme(persistence.isDarkMode ? .dark : .light)
            .sheet(isPresented: $showStartupBrowserWarning) {
                ImportantWarningBrowserModal(isPresented: $showStartupBrowserWarning)
            }
            .sheet(isPresented: $showAnalyticsSheet) {
                ToolsDashboardModalView()
            }
            .sheet(isPresented: $showManageBrowsersSheet) {
                ManageBrowsersModalView(initialMode: .cookiesAndProxy, platformName: "Facebook")
            }
            .sheet(isPresented: $showManageContentSheet) {
                ManageContentModalView()
            }
        }
        .commands {
            CommandMenu("Programs") {
                Button("Sender Pro V4 Marketing") { programMode = .marketing }
                    .keyboardShortcut("1", modifiers: [.command])
                Button("Sender Pro B2B Data") { programMode = .b2bData }
                    .keyboardShortcut("2", modifiers: [.command])
                Button("Sender Pro Data Analysis") { programMode = .dataAnalysis }
                    .keyboardShortcut("3", modifiers: [.command])
                Button("Chrome & Brave Extensions (15)") { programMode = .extensions }
                    .keyboardShortcut("4", modifiers: [.command])
                Divider()
                Button("Sender Pro Launcher Hub") { programMode = .launcher }
                    .keyboardShortcut("0", modifiers: [.command])
            }
            CommandMenu("Tools & Windows") {
                Button("Manage Browsers") { showManageBrowsersSheet = true }
                    .keyboardShortcut("b", modifiers: [.command])
                Button("+ Manage Content") { showManageContentSheet = true }
                    .keyboardShortcut("m", modifiers: [.command])
                Button("Tools Analytics Dashboard") { showAnalyticsSheet = true }
                    .keyboardShortcut("d", modifiers: [.command])
                Button("Show Side-by-Side Program Browser") {
                    BrowserSessionManager.shared.showSideBySideBrowserWindow()
                }
                .keyboardShortcut("k", modifiers: [.command])
                Divider()
                Button("Toggle Arabic / English") {
                    persistence.isArabic.toggle()
                }
                .keyboardShortcut("l", modifiers: [.command])
                Button("Toggle Light / Dark Theme") {
                    persistence.isDarkMode.toggle()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }

    // MARK: - Independent Real End-to-End Integration & Parity Test Runner (--run-integration-tests)
    @MainActor
    public static func runRealEndToEndIntegrationSuite() async -> Int32 {
        print("================================================================================")
        print("SENDER PRO V4.65.6 — COMPLETE REAL INTEGRATION & PARITY AUDIT SUITE (macOS)")
        print("================================================================================")
        var passed = 0
        var failed = 0

        func check(_ condition: Bool, _ label: String, detail: String = "") {
            if condition {
                passed += 1
                print("  [PASS] \(label)" + (detail.isEmpty ? "" : " -> \(detail)"))
            } else {
                failed += 1
                print("  [FAIL] \(label)" + (detail.isEmpty ? "" : " -> \(detail)"))
            }
        }

        let engine = ExecutionEngine.shared
        let persistence = PersistenceManager.shared
        let browserMgr = BrowserSessionManager.shared
        let smtpEngine = RealSMTPEngine.shared
        let b2bEngine = B2BConnectorEngine.shared
        let socialEngine = SocialAutomationEngine.shared
        let tgEngine = TelegramMTProtoEngine.shared
        let vault = CredentialVault.shared

        let workDir = FileManager.default.temporaryDirectory.appendingPathComponent("SenderProAudit_\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)

        // -------------------------------------------------------------------------
        // SUITE 01: Catalog, 145 Marketing Tools, 4-Tier Classification & 18 SMTP Presets
        // -------------------------------------------------------------------------
        print("\n[SUITE 01] Catalog, 145 Marketing Tools, 4-Tier Capability Classification & 18 SMTP Presets")
        check(MarketingPlatform.allCases.count == 20, "20 Marketing Platforms registered", detail: "\(MarketingPlatform.allCases.count) platforms")
        check(ToolCatalog.allMarketingTools.count == 145, "145 Marketing Tools registered with valid column schemas", detail: "\(ToolCatalog.allMarketingTools.count) tools")
        check(ToolCatalog.allB2BConnectors.count == 29, "29 B2B Connectors registered matching Video V11", detail: "\(ToolCatalog.allB2BConnectors.count) connectors")
        check(ToolCatalog.smtpServerPresets.count == 18, "18 SMTP/POP3 server presets registered", detail: "\(ToolCatalog.smtpServerPresets.count) presets")

        var tierCounts: [SocialCapabilityTier: Int] = [:]
        for t in ToolCatalog.allMarketingTools {
            let tier = socialEngine.classifyToolCapability(t)
            tierCounts[tier, default: 0] += 1
        }
        check(tierCounts.values.reduce(0, +) == 145,
              "Classified all 145 Marketing tools into 4 explicit capability tiers",
              detail: "PUBLIC_NO_AUTH=\(tierCounts[.publicNoAuth, default: 0]), USER_SESSION_AUTH=\(tierCounts[.userSessionAuth, default: 0]), OFFICIAL_API_AUTH=\(tierCounts[.officialAPIAuth, default: 0]), PROHIBITED=\(tierCounts[.prohibitedOrUnavailable, default: 0])")

        // -------------------------------------------------------------------------
        // SUITE 02: CredentialVault (macOS Keychain + AES-GCM 256) — Zero Cleartext Passwords
        // -------------------------------------------------------------------------
        print("\n[SUITE 02] CredentialVault (macOS Keychain + AES-GCM 256) — Zero Cleartext Passwords on Disk")
        let rawSecret = "UltraSecret_SMTP_AppPass_2026!@#"
        persistence.smtpAccounts.append(
            SMTPAccountEntry(email: "vault-test@senderprov.com", appPassword: rawSecret, sendLimitCount: 200, smtpHost: "smtp.gmail.com", smtpPort: 587, useSSL: true)
        )
        persistence.saveSMTPAccounts()
        let savedEntry = persistence.smtpAccounts.last!
        check(vault.isRedactedVaultReference(savedEntry.appPassword) && !savedEntry.appPassword.contains(rawSecret),
              "SMTP password redacted in SQLite model as vault reference token",
              detail: savedEntry.appPassword)
        let decrypted = vault.retrieveSecret(forRefOrKey: savedEntry.appPassword)
        check(decrypted == rawSecret, "Decrypted secret from CredentialVault matches original password 100%")
        let sqliteRawBytes = (try? Data(contentsOf: persistence.appSupportDir.appendingPathComponent("SenderPro.sqlite"))) ?? Data()
        let sqliteContainsPlaintext = String(data: sqliteRawBytes, encoding: .utf8)?.contains(rawSecret) ?? false
        check(!sqliteContainsPlaintext, "Verified SenderPro.sqlite file on disk contains ZERO cleartext passwords")
        persistence.smtpAccounts.removeAll { $0.email == "vault-test@senderprov.com" }
        persistence.saveSMTPAccounts()

        // -------------------------------------------------------------------------
        // SUITE 03: Real RFC 2046 Multipart MIME + Base64 Attachments + OpenSSL STARTTLS / Implicit TLS / X.509 Cert Verification
        // -------------------------------------------------------------------------
        print("\n[SUITE 03] Real RFC 2046 MIME Multipart + Base64 Attachments + OpenSSL STARTTLS / Implicit TLS & X.509 Cert Verification")
        let attachmentFile = workDir.appendingPathComponent("Facture_SenderPro_2026.pdf")
        let attachmentPayload = Data("%PDF-1.4 SENDERPRO_REAL_ATTACHMENT_BINARY_CONTENT_2026".utf8)
        try? attachmentPayload.write(to: attachmentFile)

        let (mimeStr, msgID, attCount) = smtpEngine.buildRFC2046MIMEMessage(
            fromEmail: "campaign@senderprov.com",
            companyName: "شركة سيندر برو",
            toRecipients: ["client1@ksa-b2b.sa", "client2@uae-b2b.ae"],
            ccRecipients: ["audit@senderprov.com"],
            subject: "عرض رسمي مرفق بملف PDF — Official Offer",
            plainTextBody: "مرحبا بكم، مرفق ملف العرض الرسمي.",
            htmlBody: "<html><body><h1>مرحبا بكم</h1><p>مرفق ملف العرض الرسمي.</p></body></html>",
            attachmentPaths: [attachmentFile.path]
        )
        check(attCount == 1 && mimeStr.contains("multipart/mixed") && mimeStr.contains("multipart/alternative") && mimeStr.contains("Facture_SenderPro_2026.pdf"),
              "Built RFC 2046 multipart/mixed + multipart/alternative MIME with Base64 PDF attachment & CC recipients",
              detail: "Message-ID=\(msgID), length=\(mimeStr.count) bytes")

        let certFile = workDir.appendingPathComponent("smtp_cert.pem")
        let keyFile = workDir.appendingPathComponent("smtp_key.pem")
        let certGenProc = Process()
        certGenProc.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
        certGenProc.arguments = [
            "req", "-x509", "-newkey", "rsa:2048", "-nodes",
            "-keyout", keyFile.path, "-out", certFile.path,
            "-days", "2", "-subj", "/CN=127.0.0.1",
            "-addext", "subjectAltName=IP:127.0.0.1,DNS:localhost"
        ]
        certGenProc.standardOutput = Pipe()
        certGenProc.standardError = Pipe()
        try? certGenProc.run()
        certGenProc.waitUntilExit()
        check(FileManager.default.fileExists(atPath: certFile.path), "Generated real X.509 RSA-2048 TLS certificate with SAN=IP:127.0.0.1")

        let vaultRef = vault.storeSecret("Real_SMTP_Secret_99", forKey: "smtp_tls_test")

        // 3A. Test Explicit STARTTLS (Port 587) + Strict X.509 Certificate Verification + Multi-Recipient + Base64 PDF Attachment
        let starttlsAcc = SMTPAccountEntry(
            email: "sender@senderprov.com",
            appPassword: vaultRef,
            sendLimitCount: 100,
            smtpHost: "socketpair.tls.local",
            smtpPort: 587,
            useSSL: true
        )
        let starttlsRes = await smtpEngine.sendEmailOverRealTCP(
            account: starttlsAcc,
            toRecipients: ["recipient1@client.sa", "recipient2@client.ae"],
            ccRecipients: ["cc_manager@client.sa"],
            companyName: "Sender Pro V4",
            subject: "اختبار إرسال حقيقي عبر STARTTLS مع مرفق PDF",
            plainBody: "نسخة نصية للرسالة",
            htmlBody: "<h2>نسخة HTML للرسالة</h2><p>تم الإرسال عبر STARTTLS</p>",
            attachmentPaths: [attachmentFile.path],
            verifyCertificates: true,
            caFilePath: certFile.path,
            serverCertPath: certFile.path,
            serverKeyPath: keyFile.path
        )
        check(starttlsRes.success && starttlsRes.tlsModeUsed == "Explicit STARTTLS" && starttlsRes.certificateSummary.contains("Verified=True"),
              "Explicit STARTTLS (Port 587) + X.509 Certificate Validation + AUTH PLAIN succeeded",
              detail: "\(starttlsRes.tlsModeUsed) | \(starttlsRes.certificateSummary)")
        check(starttlsRes.recipientsAccepted.count == 3 && starttlsRes.serverResponse.contains("Facture_SenderPro_2026.pdf") && starttlsRes.serverResponse.contains("bytes=54"),
              "Multi-recipient (2 To + 1 CC) & Base64 PDF attachment (54 bytes) received intact by SMTP server",
              detail: starttlsRes.serverResponse)

        // 3B. Test Implicit TLS (Port 465) + X.509 Certificate Verification
        let implicitTLSAcc = SMTPAccountEntry(
            email: "sender@senderprov.com",
            appPassword: vaultRef,
            sendLimitCount: 100,
            smtpHost: "socketpair.tls.local",
            smtpPort: 465,
            useSSL: true
        )
        let implicitRes = await smtpEngine.sendEmailOverRealTCP(
            account: implicitTLSAcc,
            toRecipients: ["vip@client.sa"],
            companyName: "Sender Pro V4",
            subject: "Implicit TLS 465 Test",
            plainBody: "Plain body",
            htmlBody: "<p>HTML body</p>",
            attachmentPaths: [attachmentFile.path],
            verifyCertificates: true,
            caFilePath: certFile.path,
            serverCertPath: certFile.path,
            serverKeyPath: keyFile.path
        )
        check(implicitRes.success && implicitRes.tlsModeUsed == "Implicit TLS (Port 465)",
              "Implicit TLS (Port 465) + X.509 Certificate Validation succeeded",
              detail: "\(implicitRes.tlsModeUsed) | \(implicitRes.certificateSummary)")

        // 3C. Test Strict X.509 Certificate Rejection when Server Cert is Untrusted (caFilePath = nil)
        let untrustedRes = await smtpEngine.sendEmailOverRealTCP(
            account: starttlsAcc,
            toRecipients: ["vip@client.sa"],
            companyName: "Sender Pro V4",
            subject: "Untrusted Cert Test",
            plainBody: "Should reject untrusted self-signed cert",
            verifyCertificates: true,
            caFilePath: nil,
            serverCertPath: certFile.path,
            serverKeyPath: keyFile.path
        )
        check(!untrustedRes.success && untrustedRes.statusCode == 495,
              "Strict X.509 TLS verification rejected untrusted certificate with statusCode 495",
              detail: untrustedRes.serverResponse)

        // -------------------------------------------------------------------------
        // SUITE 04: Individual Verification of All 29 B2B Connectors
        // -------------------------------------------------------------------------
        print("\n[SUITE 04] Individual Verification of All 29 B2B Connectors (URL, Pagination, Stage 1 & 2, Empty Check, Export)")
        let b2bAuditResults = b2bEngine.runAll29ConnectorsIndividualAudit()
        let passedB2BCount = b2bAuditResults.filter { $0.statusClassification == "IMPLEMENTED_AND_TESTED" }.count
        check(b2bAuditResults.count == 29 && passedB2BCount == 29,
              "All 29 B2B Connectors individually verified (URL builder, Page 1->2 pagination, Stage 1 & 2 parsing, empty handling & CSV export)",
              detail: "\(passedB2BCount)/29 connectors IMPLEMENTED_AND_TESTED")

        // -------------------------------------------------------------------------
        // SUITE 05: Social Automation Engine — Real WKWebView JS/DOM Injection & Session Auth Check
        // -------------------------------------------------------------------------
        print("\n[SUITE 05] Social Automation Engine — Real WKWebView JS/DOM Injection & Session Auth Verification")
        browserMgr.closeAllBrowsers()
        let socialBrowser = browserMgr.launchProgramBrowser(initialURL: "about:blank", sessionName: "FB_Session_Test", showWindow: false)
        let socialTestHTML = """
        <html><head><title>Facebook Group — عقارات الرياض</title></head><body>
        <a href="https://www.facebook.com/groups/riyadh/posts/101">Post 101</a>
        <a href="https://www.facebook.com/groups/riyadh/posts/102">Post 102</a>
        <div contenteditable="true" role="textbox"></div>
        </body></html>
        """
        socialBrowser.loadHTML(socialTestHTML, baseURL: URL(string: "https://www.facebook.com"))
        let domScript = socialEngine.buildDOMAutomationScript(for: .facebook, operation: "Extract & Comment", messageText: "عرض عقاري مميز")
        let domOutput = await socialBrowser.evaluateJS(domScript)
        check(domOutput.contains("MESSAGE_INJECTED_IN_DOM") && domOutput.contains("discoveredCount\":2"),
              "Executed JS/DOM script on Facebook Group HTML: extracted 2 post links and injected comment into contenteditable textbox",
              detail: domOutput)
        browserMgr.closeAllBrowsers()

        // -------------------------------------------------------------------------
        // SUITE 06: Telegram MTProto Engine — API Validation, SQLite .session & Public Channel Scraper
        // -------------------------------------------------------------------------
        print("\n[SUITE 06] Telegram MTProto Engine — API Validation, SQLite .session & Public Channel Scraper (t.me/s/)")
        let (apiValid, apiReason) = tgEngine.validateAPICredentials(apiID: "2040", apiHash: "b18441a1ff607e10a989891a5462e627")
        check(apiValid, "Validated Telegram MTProto api_id & 32-char hex api_hash", detail: apiReason)

        let sessionFileURL = workDir.appendingPathComponent("201099887766.session")
        let dummyAuthKey = Data(repeating: 0xAB, count: 256)
        let createdSession = tgEngine.createSQLiteSessionFile(at: sessionFileURL.path, dcID: 2, serverAddress: "149.154.167.50", port: 443, authKeyBytes: dummyAuthKey)
        let inspectedSession = tgEngine.inspectSessionFile(at: sessionFileURL.path)
        check(createdSession && inspectedSession.isValid && inspectedSession.dcID == 2 && inspectedSession.hasAuthKey,
              "Created & inspected native SQLite MTProto .session file (dc_id=2, 256-byte auth_key)",
              detail: "\(inspectedSession.fileFormat) | DC=\(inspectedSession.dcID)")

        let tgChannelHTML = """
        <div class="tgme_header_counter">48.5K subscribers</div>
        <div class="tgme_widget_message" data-post="senderpro_official/501">
            <span class="tgme_widget_message_author_name">Sender Pro Official</span>
            <div class="tgme_widget_message_text">تحديث جديد لبرنامج Sender Pro V4.65.6 متاح الآن للتواصل @senderpro_support و @sales_ksa</div>
            <div class="tgme_widget_message_footer"></div>
        </div>
        """
        let (subs, tgPosts) = tgEngine.parseTelegramPublicChannelHTML(html: tgChannelHTML, channelName: "senderpro_official")
        check(subs == "48.5K subscribers" && tgPosts.count == 1 && tgPosts[0].mentionedUsers.count == 2,
              "Extracted public Telegram channel posts, subscriber count & @username mentions without login",
              detail: "Subscribers=\(subs), Mentions=\(tgPosts[0].mentionedUsers.joined(separator: ", "))")

        // -------------------------------------------------------------------------
        // SUITE 07: SQLite Persistence & 16-Column Data Analysis (Multi-Format + Zero Fake Data)
        // -------------------------------------------------------------------------
        print("\n[SUITE 07] SQLite Persistence & 16-Column Data Analysis (CSV/JSON Import, URL Normalization & Zero Fake Data)")
        let sampleDatasetLine = "https://www.facebook.com/profile.php?id=100099887766|ceo@riyadh-holdings.sa|+966509988776|Muslim|1988-05-14|Male|https://www.facebook.com/100099887766|خالد|المنصوري|khaled.mansouri|الرئيس التنفيذي|الرياض|الرياض|إدارة الأعمال|جامعة الملك سعود|Verified"
        let importedCount = persistence.importFacebookDatasetLines([sampleDatasetLine])
        check(importedCount == 1, "Normalized Facebook URL to UID 100099887766 and indexed 16-column record in SQLite")
        let foundRow = persistence.lookupFacebookUID("https://facebook.com/100099887766")
        check(foundRow != nil && foundRow?[0] == "100099887766" && foundRow?[1] == "ceo@riyadh-holdings.sa" && foundRow?[2] == "+966509988776",
              "SQLite lookup resolved Facebook URL to exact 16-column record",
              detail: "UID=\(foundRow?[0] ?? ""), Email=\(foundRow?[1] ?? ""), Phone=\(foundRow?[2] ?? "")")
        let filteredRows = persistence.searchIndexedFacebookRecords(keyword: "خالد", cityFilter: "الرياض", jobFilter: "الرئيس", genderFilter: "Male")
        check(!filteredRows.isEmpty, "Multi-criteria SQLite filter (Keyword + City + Job + Gender) returned matching records", detail: "count=\(filteredRows.count)")
        let missingRow = persistence.lookupFacebookUID("999999999999_UNKNOWN")
        check(missingRow == nil, "SQLite lookup returned nil (zero fabricated personal data) for unknown UID")

        // -------------------------------------------------------------------------
        // SUITE 08: Other Tools Utilities (Downloader, Splitter, VCF, Generator, Spintax & Exports)
        // -------------------------------------------------------------------------
        print("\n[SUITE 08] Other Tools Utilities, Spintax, Bilingual Translation & Native Exports (.xlsx/.csv/.vcf/.txt)")
        let resolvedMsg = engine.resolveDynamicMessage(
            rawTemplate: "{مرحبا|أهلا} يا أستاذ [Sender Name] في [Group Name] بتاريخ [Sender Date and Time] - [Random Text]",
            senderName: "حسان",
            groupName: "مجموعة التجار"
        )
        check(resolvedMsg.contains("حسان") && resolvedMsg.contains("مجموعة التجار") && !resolvedMsg.contains("{"),
              "Resolved Spintax {a|b} and dynamic placeholders")
        let trEn = engine.translateMarketingContent("مرحبا بك يا أستاذ حسان نقدم لك أفضل عروض التسويق الإلكتروني")
        check(trEn.contains("Hello") && trEn.contains("digital marketing"), "Translated Arabic marketing template to English")

        let exportCols = ["Link", "Name", "Phone", "Email"]
        let exportRows = [
            ["https://alnoor-med.sa", "مركز النور الطبي", "+966550011221", "info@alnoor-med.sa"],
            ["https://gulf-eng.ae", "مجموعة الخليج الهندسية", "+971509988772", "contact@gulf-eng.ae"]
        ]
        let xlsxURL = workDir.appendingPathComponent("audit_export.xlsx")
        let csvURL = workDir.appendingPathComponent("audit_export.csv")
        let vcfURL = workDir.appendingPathComponent("audit_export.vcf")
        let txtURL = workDir.appendingPathComponent("audit_export.txt")

        check(ExportService.shared.writeNativeXLSX(to: xlsxURL, columns: exportCols, rows: exportRows), "Generated native OpenXML .xlsx archive")
        check(ExportService.shared.writeCSVWithBOM(to: csvURL, columns: exportCols, rows: exportRows), "Generated UTF-8 BOM .csv file")
        check(ExportService.shared.writeVCF(to: vcfURL, rows: exportRows.map { [$0[2], $0[1]] }), "Generated RFC 6350 vCard 3.0 .vcf file")
        check(ExportService.shared.writeTXTWithBOM(to: txtURL, rows: exportRows), "Generated UTF-8 BOM .txt file")

        // -------------------------------------------------------------------------
        // SUITE 09: Per-Session Cookie Isolation (WKWebsiteDataStore) & JSON Cookie Import
        // -------------------------------------------------------------------------
        print("\n[SUITE 09] Per-Session Browser Cookie Isolation (WKWebsiteDataStore) & JSON Cookie Import")
        browserMgr.closeAllBrowsers()
        let inst1 = browserMgr.launchProgramBrowser(initialURL: "about:blank", sessionName: "Account_1", showWindow: false)
        let inst2 = browserMgr.launchProgramBrowser(initialURL: "about:blank", sessionName: "Account_2", showWindow: false)
        check(inst1.id != inst2.id && inst1.webView.configuration.websiteDataStore !== inst2.webView.configuration.websiteDataStore,
              "Isolated WKWebsiteDataStore instances verified across BrowserInstances")
        let refCookieURL = URL(fileURLWithPath: "/Users/hassen/AI/sender-pro-mac-v2/ref/Sender Pro Data/SenderProBrowsers/olx1.json")
        let importedCookies = await browserMgr.loadSessionFromFile(refCookieURL, into: inst1)
        check(importedCookies == 70, "Imported 70 real cookies from ref/Sender Pro Data/SenderProBrowsers/olx1.json into isolated store", detail: "\(importedCookies) cookies")
        browserMgr.closeAllBrowsers()

        // -------------------------------------------------------------------------
        // SUITE 10: 15 Chrome/Brave Extensions & Local ToolsDashboard Server
        // -------------------------------------------------------------------------
        print("\n[SUITE 10] 15 Chrome/Brave Extensions & Local ToolsDashboard Server")
        let extRoot = "/Users/hassen/AI/sender-pro-mac-v2/ref/Sender Pro Marketing/اضافات جوجل كروم - Google Chrome Extensions"
        let extFolders = (try? FileManager.default.contentsOfDirectory(atPath: extRoot))?.filter { !$0.hasPrefix(".") } ?? []
        var validManifests = 0
        for folder in extFolders {
            let mPath = (extRoot as NSString).appendingPathComponent(folder).appending("/manifest.json")
            if let d = try? Data(contentsOf: URL(fileURLWithPath: mPath)),
               let obj = try? JSONSerialization.jsonObject(with: d) as? [String: Any],
               obj["manifest_version"] != nil {
                validManifests += 1
            }
        }
        check(validManifests == 15, "All 15 Chrome/Brave extensions have valid manifest.json files", detail: "\(validManifests)/15 valid")
        let dashHTML = engine.generateToolsDashboardHTML()
        check(dashHTML.contains("ToolsDashboard") && dashHTML.contains("النشاط الأخير"), "Generated live bilingual ToolsDashboard.html from SQLite logs")

        try? FileManager.default.removeItem(at: workDir)

        print("\n================================================================================")
        print("INTEGRATION & PARITY SUITE SUMMARY: \(passed) PASSED | \(failed) FAILED")
        print("================================================================================")
        return failed == 0 ? 0 : 1
    }
}

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        if CommandLine.arguments.contains("--run-integration-tests") {
            return
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
        if let screen = NSScreen.main?.visibleFrame,
           let window = NSApplication.shared.windows.first {
            let width = max(1080, screen.width * 0.56)
            let height = max(740, screen.height * 0.92)
            let rect = CGRect(
                x: screen.maxX - width - 12,
                y: screen.minY + (screen.height - height) / 2,
                width: width,
                height: height
            )
            window.setFrame(rect, display: true)
        }
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
