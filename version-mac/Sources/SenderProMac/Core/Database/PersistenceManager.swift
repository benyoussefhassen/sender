import Foundation
import SQLite3

@MainActor
public final class PersistenceManager: ObservableObject {
    public static let shared = PersistenceManager()

    public let appSupportDir: URL
    public let sessionsDir: URL
    public let telegramSessionsDir: URL
    public let exportsDir: URL
    private var db: OpaquePointer?

    @Published public var isArabic: Bool = true {
        didSet { saveSettings() }
    }
    @Published public var isDarkMode: Bool = false {
        didSet { saveSettings() }
    }
    @Published public var securityConfig: SecurityConfig = SecurityConfig() {
        didSet { saveSettings() }
    }
    @Published public var socialAccounts: [SocialAccountRecord] = []
    @Published public var telegramSessions: [TelegramSessionRecord] = []
    @Published public var contentTemplates: [ContentTemplateRecord] = []
    @Published public var useRandomContent: Bool = true {
        didSet { saveSettings() }
    }
    @Published public var smtpAccounts: [SMTPAccountEntry] = []
    @Published public var activityLogs: [ToolActivityLog] = []

    // License & Account Time metadata (matching V10 04:20 Account Time popup)
    @Published public var marketingExpiryDate: String = "2027/11/04"
    @Published public var dataExpiryDate: String = "2027/11/04"
    @Published public var supportExpiryDate: String = "2027/11/04"
    @Published public var facebookSecretPoints: Int = 25000

    private init() {
        let fm = FileManager.default
        let candidate1 = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SenderProV4", isDirectory: true)
        let candidate2 = URL(fileURLWithPath: "/Users/hassen/AI/sender-pro-mac-v2/version-mac/AppData", isDirectory: true)
        let candidate3 = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            .appendingPathComponent("SenderProV4Data", isDirectory: true)

        var chosen = candidate2
        for cand in [candidate1, candidate2, candidate3] {
            try? fm.createDirectory(at: cand, withIntermediateDirectories: true)
            let probe = cand.appendingPathComponent(".write_test")
            if (try? "ok".write(to: probe, atomically: true, encoding: .utf8)) != nil {
                try? fm.removeItem(at: probe)
                chosen = cand
                break
            }
        }

        self.appSupportDir = chosen
        self.sessionsDir = chosen.appendingPathComponent("SenderProBrowsers", isDirectory: true)
        self.telegramSessionsDir = chosen.appendingPathComponent("TelegramSessions", isDirectory: true)
        self.exportsDir = chosen.appendingPathComponent("Exports", isDirectory: true)

        try? fm.createDirectory(at: sessionsDir, withIntermediateDirectories: true)
        try? fm.createDirectory(at: telegramSessionsDir, withIntermediateDirectories: true)
        try? fm.createDirectory(at: exportsDir, withIntermediateDirectories: true)

        openSQLiteDatabase()
        loadAllState()
        seedReferenceBrowserSessionsIfNeeded()
        saveSettings()
    }

    private func openSQLiteDatabase() {
        let dbPath = appSupportDir.appendingPathComponent("SenderPro.sqlite").path
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            let createTablesSQL = """
            CREATE TABLE IF NOT EXISTS activity_logs (
                id TEXT PRIMARY KEY,
                timestamp DOUBLE,
                user_email TEXT,
                platform TEXT,
                tool_name TEXT,
                op_type TEXT,
                status TEXT,
                items_count INTEGER,
                details TEXT
            );
            CREATE TABLE IF NOT EXISTS key_value_store (
                k TEXT PRIMARY KEY,
                v TEXT
            );
            CREATE TABLE IF NOT EXISTS facebook_secret_records (
                uid TEXT PRIMARY KEY,
                email TEXT,
                phone TEXT,
                religion TEXT,
                birth_date TEXT,
                gender TEXT,
                profile_link TEXT,
                first_name TEXT,
                last_name TEXT,
                username TEXT,
                job TEXT,
                hometown TEXT,
                current_city TEXT,
                specialization TEXT,
                university TEXT,
                status TEXT
            );
            """
            sqlite3_exec(db, createTablesSQL, nil, nil, nil)
        }
    }

    // MARK: - Real SQLite Indexing, Multi-Format Import & Multi-Criteria Lookup for Data Analysis (16 Columns)
    @discardableResult
    public func importFacebookDatasetLines(_ lines: [String]) -> Int {
        var importedCount = 0
        let sql = """
        INSERT OR REPLACE INTO facebook_secret_records (
            uid, email, phone, religion, birth_date, gender, profile_link,
            first_name, last_name, username, job, hometown, current_city,
            specialization, university, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            let delimiter: String = line.contains("|") ? "|" : (line.contains("\t") ? "\t" : (line.contains(";") ? ";" : ","))
            let parts = line.components(separatedBy: delimiter).map {
                $0.trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
            }
            guard let firstCol = parts.first, !firstCol.isEmpty, firstCol.lowercased() != "ids", firstCol.lowercased() != "uid" else {
                continue
            }
            var cols = Array(repeating: "N/A", count: 16)
            for i in 0..<min(parts.count, 16) {
                cols[i] = parts[i].isEmpty ? "N/A" : parts[i]
            }
            cols[0] = Self.normalizeFacebookUID(cols[0])
            if cols[6] == "N/A" {
                cols[6] = "https://www.facebook.com/\(cols[0])"
            }
            cols[15] = "Indexed (SQLite) ✓"

            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                for idx in 0..<16 {
                    sqlite3_bind_text(stmt, Int32(idx + 1), (cols[idx] as NSString).utf8String, -1, nil)
                }
                if sqlite3_step(stmt) == SQLITE_DONE {
                    importedCount += 1
                }
            }
            sqlite3_finalize(stmt)
        }
        return importedCount
    }

    @discardableResult
    public func importFacebookDatasetJSON(_ jsonData: Data) -> Int {
        guard let arr = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else { return 0 }
        var lines: [String] = []
        let keys = [
            "uid", "email", "phone", "religion", "birth_date", "gender",
            "profile_link", "first_name", "last_name", "username",
            "job", "hometown", "current_city", "specialization", "university", "status"
        ]
        for obj in arr {
            let row = keys.map { k -> String in
                if let v = obj[k] { return "\(v)" }
                if k == "uid", let idVal = obj["id"] { return "\(idVal)" }
                return "N/A"
            }
            lines.append(row.joined(separator: "|"))
        }
        return importFacebookDatasetLines(lines)
    }

    public nonisolated static func normalizeFacebookUID(_ rawInput: String) -> String {
        var s = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = s.range(of: "id=", options: .caseInsensitive) {
            s = String(s[range.upperBound...])
            if let amp = s.firstIndex(of: "&") {
                s = String(s[..<amp])
            }
        } else {
            s = s.replacingOccurrences(of: "https://www.facebook.com/", with: "")
                .replacingOccurrences(of: "https://facebook.com/", with: "")
                .replacingOccurrences(of: "https://m.facebook.com/", with: "")
                .replacingOccurrences(of: "profile.php?", with: "")
        }
        if let slash = s.firstIndex(of: "/") {
            s = String(s[..<slash])
        }
        if let q = s.firstIndex(of: "?") {
            s = String(s[..<q])
        }
        return s.trimmingCharacters(in: CharacterSet(charactersIn: " /\t\r\n"))
    }

    public func lookupFacebookUID(_ uidOrURL: String) -> [String]? {
        let cleanUID = Self.normalizeFacebookUID(uidOrURL)
        guard !cleanUID.isEmpty else { return nil }

        let sql = """
        SELECT uid, email, phone, religion, birth_date, gender, profile_link,
               first_name, last_name, username, job, hometown, current_city,
               specialization, university, status
        FROM facebook_secret_records
        WHERE uid = ? OR username = ? OR email = ? OR phone = ? LIMIT 1;
        """
        var stmt: OpaquePointer?
        var row: [String]?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for idx in 1...4 {
                sqlite3_bind_text(stmt, Int32(idx), (cleanUID as NSString).utf8String, -1, nil)
            }
            if sqlite3_step(stmt) == SQLITE_ROW {
                var cols: [String] = []
                for i in 0..<16 {
                    if let cStr = sqlite3_column_text(stmt, Int32(i)) {
                        cols.append(String(cString: cStr))
                    } else {
                        cols.append("N/A")
                    }
                }
                row = cols
            }
        }
        sqlite3_finalize(stmt)
        return row
    }

    public func searchIndexedFacebookRecords(keyword: String, cityFilter: String = "", jobFilter: String = "", genderFilter: String = "", limit: Int = 500) -> [[String]] {
        let sql = """
        SELECT uid, email, phone, religion, birth_date, gender, profile_link,
               first_name, last_name, username, job, hometown, current_city,
               specialization, university, status
        FROM facebook_secret_records
        LIMIT ?;
        """
        var stmt: OpaquePointer?
        var results: [[String]] = []
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(max(1, limit)))
            while sqlite3_step(stmt) == SQLITE_ROW {
                var cols: [String] = []
                for i in 0..<16 {
                    if let cStr = sqlite3_column_text(stmt, Int32(i)) {
                        cols.append(String(cString: cStr))
                    } else {
                        cols.append("N/A")
                    }
                }
                let joined = cols.joined(separator: " ")
                let kwOK = keyword.isEmpty || joined.localizedCaseInsensitiveContains(keyword)
                let cityOK = cityFilter.isEmpty || cols[11].localizedCaseInsensitiveContains(cityFilter) || cols[12].localizedCaseInsensitiveContains(cityFilter)
                let jobOK = jobFilter.isEmpty || cols[10].localizedCaseInsensitiveContains(jobFilter) || cols[13].localizedCaseInsensitiveContains(jobFilter)
                let genderOK = genderFilter.isEmpty || genderFilter == "ALL" || cols[5].caseInsensitiveCompare(genderFilter) == .orderedSame
                if kwOK && cityOK && jobOK && genderOK {
                    results.append(cols)
                }
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    public func countIndexedFacebookRecords() -> Int {
        let sql = "SELECT COUNT(*) FROM facebook_secret_records;"
        var stmt: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)
        return count
    }

    private func saveJSON<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value),
              let str = String(data: data, encoding: .utf8) else { return }
        let sql = "INSERT OR REPLACE INTO key_value_store (k, v) VALUES (?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (str as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    private func loadJSON<T: Decodable>(_ type: T.Type, key: String) -> T? {
        let sql = "SELECT v FROM key_value_store WHERE k = ? LIMIT 1;"
        var stmt: OpaquePointer?
        var result: T?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, nil)
            if sqlite3_step(stmt) == SQLITE_ROW, let cStr = sqlite3_column_text(stmt, 0) {
                let str = String(cString: cStr)
                if let data = str.data(using: .utf8) {
                    result = try? JSONDecoder().decode(type, from: data)
                }
            }
        }
        sqlite3_finalize(stmt)
        return result
    }

    public func saveSettings() {
        saveJSON(isArabic, key: "isArabic")
        saveJSON(isDarkMode, key: "isDarkMode")
        saveJSON(securityConfig, key: "securityConfig")
        saveJSON(useRandomContent, key: "useRandomContent")
        saveJSON(facebookSecretPoints, key: "facebookSecretPoints")

        let iniContent = """
        [GlobalSettings]
        RandomKeyWorkds = \(securityConfig.useRandomKeywords ? 1 : 0)
        MinTimer = \(securityConfig.minTimerSeconds)
        MaxTimer = \(securityConfig.maxTimerSeconds)
        Delay = \(securityConfig.defaultDelaySeconds)
        """
        let iniURL = appSupportDir.appendingPathComponent("globalSettings.ini")
        try? iniContent.write(to: iniURL, atomically: true, encoding: .utf8)
    }

    /// Saves social accounts while redacting and encrypting all passwords in CredentialVault (Keychain + AES-GCM).
    public func saveAccounts() {
        for idx in socialAccounts.indices {
            let acc = socialAccounts[idx]
            if !acc.password.isEmpty && !acc.password.hasPrefix("__VAULT_REF__:") {
                socialAccounts[idx].password = CredentialVault.shared.storeSecret(
                    acc.password,
                    forKey: "social_\(acc.platform)_\(acc.usernameOrEmail)"
                )
            }
            if !acc.proxyPassword.isEmpty && !acc.proxyPassword.hasPrefix("__VAULT_REF__:") {
                socialAccounts[idx].proxyPassword = CredentialVault.shared.storeSecret(
                    acc.proxyPassword,
                    forKey: "proxy_\(acc.platform)_\(acc.usernameOrEmail)"
                )
            }
        }
        saveJSON(socialAccounts, key: "socialAccounts")
    }

    public func saveTelegramSessions() {
        saveJSON(telegramSessions, key: "telegramSessions")
    }

    public func saveContentTemplates() {
        saveJSON(contentTemplates, key: "contentTemplates")
    }

    /// Saves SMTP accounts while redacting and encrypting all appPasswords in CredentialVault (Keychain + AES-GCM).
    public func saveSMTPAccounts() {
        for idx in smtpAccounts.indices {
            let acc = smtpAccounts[idx]
            if !acc.appPassword.isEmpty && !acc.appPassword.hasPrefix("__VAULT_REF__:") {
                smtpAccounts[idx].appPassword = CredentialVault.shared.storeSecret(
                    acc.appPassword,
                    forKey: "smtp_\(acc.email)"
                )
            }
        }
        saveJSON(smtpAccounts, key: "smtpAccounts")
    }

    public func recordActivity(platform: String, toolName: String, operationType: String, status: String, itemsCount: Int, details: String) {
        let log = ToolActivityLog(
            timestamp: Date(),
            userEmail: "benyoussef.hassen@gmail.com",
            platform: platform,
            toolName: toolName,
            operationType: operationType,
            status: status,
            itemsCount: itemsCount,
            details: details
        )
        activityLogs.insert(log, at: 0)
        saveJSON(activityLogs, key: "activityLogs")
    }

    public func clearActivityLogs() {
        activityLogs.removeAll()
        saveJSON(activityLogs, key: "activityLogs")
    }

    private func loadAllState() {
        if let ar = loadJSON(Bool.self, key: "isArabic") { isArabic = ar }
        if let dark = loadJSON(Bool.self, key: "isDarkMode") { isDarkMode = dark }
        if let sec = loadJSON(SecurityConfig.self, key: "securityConfig") { securityConfig = sec }
        if let rnd = loadJSON(Bool.self, key: "useRandomContent") { useRandomContent = rnd }
        if let pts = loadJSON(Int.self, key: "facebookSecretPoints") { facebookSecretPoints = pts }
        if let accs = loadJSON([SocialAccountRecord].self, key: "socialAccounts") { socialAccounts = accs }
        if let tgs = loadJSON([TelegramSessionRecord].self, key: "telegramSessions") { telegramSessions = tgs }
        if let tpls = loadJSON([ContentTemplateRecord].self, key: "contentTemplates"), !tpls.isEmpty {
            contentTemplates = tpls
        } else {
            contentTemplates = [
                ContentTemplateRecord(
                    name: "حملة التسويق الرئيسية - Main Offer",
                    content: "مرحبا بك يا أستاذ [Sender Name] 🌟\nنقدم لك أفضل عروض التسويق الإلكتروني عبر برنامج Sender Pro V4.\n[Random Text] - [Sender Date and Time]",
                    contentLabel: "Marketing",
                    mediaPaths: [],
                    useRandomMediaCount: 1,
                    isSelected: true
                ),
                ContentTemplateRecord(
                    name: "نشر المجموعات - Group Offer",
                    content: "تحية طيبة لكل أعضاء مجموعة [Group Name] الكرام 🚀\nيسعدنا تقديم خدماتنا المتكاملة بأفضل الأسعار.\n[Random Text] | [Sender Date and Time]",
                    contentLabel: "Groups",
                    mediaPaths: [],
                    useRandomMediaCount: 3,
                    isSelected: true
                )
            ]
            saveContentTemplates()
        }
        if let smtps = loadJSON([SMTPAccountEntry].self, key: "smtpAccounts") { smtpAccounts = smtps }
        if let logs = loadJSON([ToolActivityLog].self, key: "activityLogs"), !logs.isEmpty {
            activityLogs = logs
        } else {
            activityLogs = [
                ToolActivityLog(platform: "Facebook", toolName: "Facebook - استخراج المجموعات", operationType: "Extract", status: "Success", itemsCount: 120, details: "Extracted active public groups"),
                ToolActivityLog(platform: "Facebook", toolName: "Facebook - الموافقة على المنشورات", operationType: "Marketing", status: "Success", itemsCount: 45, details: "Processed pending group posts")
            ]
            saveJSON(activityLogs, key: "activityLogs")
        }
    }

    private func seedReferenceBrowserSessionsIfNeeded() {
        let refBrowsersDir = URL(fileURLWithPath: "/Users/hassen/AI/sender-pro-mac-v2/ref/Sender Pro Data/SenderProBrowsers")
        let fm = FileManager.default
        if let files = try? fm.contentsOfDirectory(at: refBrowsersDir, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "json" {
                let dest = sessionsDir.appendingPathComponent(file.lastPathComponent)
                if !fm.fileExists(atPath: dest.path) {
                    try? fm.copyItem(at: file, to: dest)
                }
            }
        }
    }
}
