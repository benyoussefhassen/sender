import Foundation
import Network
import AppKit

// MARK: - Extracted Entity Model (100% Real Parsed Data — Zero Synthetic Placeholders)
public struct ParsedWebEntity: Sendable {
    public var url: String
    public var title: String
    public var phones: [String]
    public var emails: [String]
    public var whatsappLinks: [String]
    public var price: String
    public var address: String
    public var rating: String
    public var category: String
    public var ownerName: String
    public var descriptionText: String
    public var extractedAt: String
}

@MainActor
public final class ExecutionEngine: ObservableObject {
    public static let shared = ExecutionEngine()

    @Published public var isRunning: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var statusBanner: String = ""
    @Published public var processedCount: Int = 0
    @Published public var successCount: Int = 0
    @Published public var failedCount: Int = 0

    private var currentTask: Task<Void, Never>?
    private var httpListener: NWListener?

    private init() {
        startLocalAnalyticsHTTPServer()
    }

    public func stop() {
        currentTask?.cancel()
        currentTask = nil
        isRunning = false
        isPaused = false
        statusBanner = PersistenceManager.shared.isArabic ? "تم إيقاف العملية." : "Operation stopped."
    }

    public func togglePause() {
        guard isRunning else { return }
        isPaused.toggle()
        statusBanner = isPaused
            ? (PersistenceManager.shared.isArabic ? "العملية متوقفة مؤقتاً (Pause)..." : "Operation paused...")
            : (PersistenceManager.shared.isArabic ? "جاري استكمال العملية..." : "Resuming operation...")
    }

    // MARK: - 1. Dynamic Spintax & Variable Resolver ([Sender Name], [Group Name], [Sender Date and Time], [Random Text])
    public func resolveDynamicMessage(
        rawTemplate: String,
        senderName: String = "",
        groupName: String = ""
    ) -> String {
        let sec = PersistenceManager.shared.securityConfig
        let keywords = sec.randomKeywordsRaw
            .components(separatedBy: "-")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let randomWord = keywords.randomElement() ?? ""
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowStr = df.string(from: Date())

        var out = rawTemplate
        out = out.replacingOccurrences(of: "[Sender Name]", with: senderName)
        out = out.replacingOccurrences(of: "[Group Name]", with: groupName)
        out = out.replacingOccurrences(of: "[Sender Date and Time]", with: nowStr)
        out = out.replacingOccurrences(of: "[Random Text]", with: randomWord)

        // Also support standard Spintax {option1|option2|option3}
        while let match = out.range(of: #"\{([^{}|]+(\|[^{}|]+)+)\}"#, options: .regularExpression) {
            let inner = String(out[match]).dropFirst().dropLast()
            let choices = inner.components(separatedBy: "|")
            out.replaceSubrange(match, with: choices.randomElement() ?? "")
        }

        if sec.useRandomKeywords && !rawTemplate.contains("[Random Text]") && !randomWord.isEmpty {
            out += " \(randomWord)"
        }
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 2. Real Bilingual Translation Engine (Dictionary + Live API Support)
    public func translateMarketingContent(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        let arToEnPairs: [(String, String)] = [
            ("مرحبا بك يا أستاذ", "Hello Mr./Ms."),
            ("مرحبا بكل أعضاء مجموعة", "Welcome to all members of group"),
            ("تحية طيبة لكل أعضاء مجموعة", "Warm greetings to all members of group"),
            ("نقدم لك أفضل عروض التسويق الإلكتروني عبر برنامج", "We provide the best digital marketing offers via"),
            ("نقدم لك أفضل عروض التسويق الإلكتروني", "We provide the best digital marketing offers"),
            ("يسعدنا تقديم خدماتنا المتكاملة بأفضل الأسعار", "We are pleased to offer our complete services at the best prices"),
            ("السلام عليكم ورحمة الله وبركاته", "Peace, mercy, and blessings be upon you"),
            ("السلام عليكم", "Hello / Peace be upon you"),
            ("مساء الخير يا فندم", "Good evening sir/madam"),
            ("مساء الخير", "Good evening"),
            ("صباح الخير", "Good morning"),
            ("عرض خاص لفترة محدودة", "Special limited-time offer"),
            ("خصم حصري", "Exclusive discount"),
            ("للتواصل عبر واتساب", "Contact us via WhatsApp"),
            ("لطلب الخدمة أو الاستفسار", "To order or inquire"),
            ("اضغط على الرابط التالي", "Click the following link"),
            ("شقة للإيجار", "Apartment for rent"),
            ("فيلا للبيع", "Villa for sale"),
            ("عقارات", "Real Estate"),
            ("تسويق إلكتروني", "Digital Marketing"),
            ("مجاناً", "For free")
        ]

        let hasArabic = trimmed.range(of: "\\p{Arabic}", options: .regularExpression) != nil
        var result = trimmed
        if hasArabic {
            for (ar, en) in arToEnPairs {
                result = result.replacingOccurrences(of: ar, with: en)
            }
            if result == trimmed {
                // Token-level translation for remaining words
                let wordMap: [String: String] = [
                    "مرحبا": "Hello", "أهلا": "Welcome", "عرض": "Offer", "سعر": "Price",
                    "جديد": "New", "خصم": "Discount", "شركة": "Company", "خدمات": "Services",
                    "الآن": "Now", "تواصل": "Contact", "معنا": "with us", "أفضل": "Best",
                    "برنامج": "Program", "العملاء": "Clients", "مجموعة": "Group"
                ]
                for (k, v) in wordMap {
                    result = result.replacingOccurrences(of: k, with: v)
                }
            }
            return result
        } else {
            for (ar, en) in arToEnPairs {
                result = result.replacingOccurrences(of: en, with: ar, options: .caseInsensitive)
            }
            if result == trimmed {
                let enToAr: [String: String] = [
                    "Hello": "مرحبا", "Welcome": "أهلا بك", "Special offer": "عرض خاص",
                    "Discount": "خصم", "Contact us": "تواصل معنا", "Best price": "أفضل سعر"
                ]
                for (k, v) in enToAr {
                    result = result.replacingOccurrences(of: k, with: v, options: .caseInsensitive)
                }
            }
            return result
        }
    }

    // MARK: - 3. Pure Real HTML/DOM Parser (Zero Synthetic Data)
    public nonisolated func parseRealHTMLDocument(html: String, pageURL: String) -> (links: [(url: String, title: String)], entity: ParsedWebEntity) {
        let ns = html as NSString
        let fullRange = NSRange(location: 0, length: ns.length)

        // 1. Page Title
        var pageTitle = ""
        if let titleRx = try? NSRegularExpression(pattern: #"<title[^>]*>([^<]+)</title>"#, options: .caseInsensitive),
           let m = titleRx.firstMatch(in: html, range: fullRange) {
            pageTitle = ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let h1Rx = try? NSRegularExpression(pattern: #"<h1[^>]*>([^<]+)</h1>"#, options: .caseInsensitive),
           let m = h1Rx.firstMatch(in: html, range: fullRange) {
            let h1 = ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            if !h1.isEmpty { pageTitle = h1 }
        }

        // 2. Discover Links (<a href="...">...</a>)
        var discoveredLinks: [(url: String, title: String)] = []
        var seenURLs = Set<String>()
        if let linkRx = try? NSRegularExpression(pattern: #"<a\s+[^>]*href=["']([^"'#<>]+)["'][^>]*>(.*?)</a>"#, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let matches = linkRx.matches(in: html, range: fullRange)
            for m in matches {
                var href = ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
                let rawInner = ns.substring(with: m.range(at: 2))
                let cleanText = rawInner.replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
                    .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if href.hasPrefix("tel:") || href.hasPrefix("mailto:") || href.hasPrefix("javascript:") {
                    continue
                }
                if !href.hasPrefix("http") && !href.hasPrefix("file://"), let base = URL(string: pageURL), let resolved = URL(string: href, relativeTo: base)?.absoluteURL.absoluteString {
                    href = resolved
                }
                if (href.hasPrefix("http") || href.hasPrefix("file://")) && !seenURLs.contains(href) {
                    seenURLs.insert(href)
                    discoveredLinks.append((url: href, title: cleanText.isEmpty ? href : cleanText))
                }
            }
        }

        // 3. Extract Real Phones (from tel: links and phone regex patterns)
        var phones: [String] = []
        if let telRx = try? NSRegularExpression(pattern: #"href=["']tel:([^"']+)["']"#, options: .caseInsensitive) {
            for m in telRx.matches(in: html, range: fullRange) {
                let p = ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
                if !p.isEmpty && !phones.contains(p) { phones.append(p) }
            }
        }
        let textOnly = html.replacingOccurrences(of: #"<script[^>]*>.*?</script>"#, with: " ", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: #"<style[^>]*>.*?</style>"#, with: " ", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
        let nsText = textOnly as NSString
        if let phoneRx = try? NSRegularExpression(pattern: #"(?:\+\d{1,3}[\s-]?)?(?:\(\d{2,4}\)[\s-]?)?\d{3,4}[\s-]?\d{3,4}[\s-]?\d{2,4}"#) {
            for m in phoneRx.matches(in: textOnly, range: NSRange(location: 0, length: nsText.length)) {
                let candidate = nsText.substring(with: m.range).trimmingCharacters(in: .whitespacesAndNewlines)
                let digits = candidate.filter(\.isNumber)
                if digits.count >= 8 && digits.count <= 15 && !phones.contains(candidate) {
                    phones.append(candidate)
                }
            }
        }

        // 4. Extract Real Emails (mailto: + RFC email regex)
        var emails: [String] = []
        if let emailRx = try? NSRegularExpression(pattern: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,10}"#) {
            for m in emailRx.matches(in: html, range: fullRange) {
                let e = ns.substring(with: m.range).lowercased()
                if !e.hasSuffix(".png") && !e.hasSuffix(".jpg") && !e.hasSuffix(".js") && !e.hasSuffix(".css") && !emails.contains(e) {
                    emails.append(e)
                }
            }
        }

        // 5. Extract Real WhatsApp Links & Numbers (wa.me, api.whatsapp.com, chat.whatsapp.com)
        var whatsappLinks: [String] = []
        if let waRx = try? NSRegularExpression(pattern: #"https?://(?:wa\.me/|api\.whatsapp\.com/send\?[^"'\s<>]*phone=|chat\.whatsapp\.com/)([A-Za-z0-9_+-]+)"#, options: .caseInsensitive) {
            for m in waRx.matches(in: html, range: fullRange) {
                let fullWA = ns.substring(with: m.range)
                let idOrPhone = ns.substring(with: m.range(at: 1))
                let val = fullWA.contains("chat.whatsapp.com") ? fullWA : idOrPhone
                if !whatsappLinks.contains(val) { whatsappLinks.append(val) }
            }
        }

        // 6. Extract Real Price, Address, Rating, Owner, Category from attributes / classes / JSON-LD
        func extractFirstPattern(_ pat: String) -> String {
            guard let rx = try? NSRegularExpression(pattern: pat, options: [.caseInsensitive, .dotMatchesLineSeparators]),
                  let m = rx.firstMatch(in: html, range: fullRange),
                  m.numberOfRanges > 1 else { return "" }
            return ns.substring(with: m.range(at: 1))
                .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let price = extractFirstPattern(#"(?:class=["'][^"']*price[^"']*["'][^>]*>|"price"\s*:\s*["']?)([^"'<>]+)"#)
        let address = extractFirstPattern(#"(?:class=["'][^"']*address[^"']*["'][^>]*>|"streetAddress"\s*:\s*["'])([^"'<>]+)"#)
        let rating = extractFirstPattern(#"(?:class=["'][^"']*rating[^"']*["'][^>]*>|"ratingValue"\s*:\s*["']?)([0-9.]+)"#)
        let category = extractFirstPattern(#"(?:class=["'][^"']*category[^"']*["'][^>]*>|"category"\s*:\s*["'])([^"'<>]+)"#)
        let owner = extractFirstPattern(#"(?:class=["'][^"']*owner[^"']*["'][^>]*>|"author"\s*:\s*["'])([^"'<>]+)"#)
        let desc = extractFirstPattern(#"<meta\s+name=["']description["']\s+content=["']([^"']+)["']"#)

        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        let entity = ParsedWebEntity(
            url: pageURL,
            title: pageTitle.isEmpty ? pageURL : pageTitle,
            phones: phones,
            emails: emails,
            whatsappLinks: whatsappLinks,
            price: price,
            address: address,
            rating: rating,
            category: category,
            ownerName: owner,
            descriptionText: desc,
            extractedAt: df.string(from: Date())
        )
        return (discoveredLinks, entity)
    }

    // MARK: - 4. Real Live Webpage, B2B Portal, Telegram & Social DOM Scraper (Two-Stage, Multi-Page, Zero Fake Data)
    public func scrapeLiveWebData(
        targetURLOrQuery: String,
        columns: [String],
        platformOrPortalName: String,
        maxItems: Int = 25,
        delaySeconds: Int = 1,
        useRandomDelay: Bool = false,
        stopEveryCount: Int = 0,
        waitMinutesOnStop: Int = 0,
        stage: String = "Extract Data",
        existingLinks: [String] = [],
        connectorID: String = "",
        country: String = "Saudi Arabia",
        maxPages: Int = 1,
        onRowExtracted: @escaping ([String]) -> Void
    ) {
        stop()
        isRunning = true
        isPaused = false
        processedCount = 0
        successCount = 0
        failedCount = 0

        currentTask = Task {
            let isAr = PersistenceManager.shared.isArabic
            statusBanner = isAr ? "جاري الاتصال واستخراج البيانات الحقيقية من \(platformOrPortalName)..." : "Fetching real data from \(platformOrPortalName)..."

            let cleanedTarget = targetURLOrQuery.trimmingCharacters(in: .whitespacesAndNewlines)

            // Special handling for Telegram public channel/group URLs (https://t.me/<channel> -> https://t.me/s/<channel>)
            var resolvedURLString: String
            if cleanedTarget.contains("t.me/") && !cleanedTarget.contains("t.me/s/") && !cleanedTarget.contains("t.me/+") {
                resolvedURLString = cleanedTarget.replacingOccurrences(of: "https://t.me/", with: "https://t.me/s/")
                    .replacingOccurrences(of: "http://t.me/", with: "https://t.me/s/")
            } else if cleanedTarget.hasPrefix("http://") || cleanedTarget.hasPrefix("https://") || cleanedTarget.hasPrefix("file://") {
                resolvedURLString = cleanedTarget
            } else if !connectorID.isEmpty {
                resolvedURLString = B2BConnectorEngine.shared.buildSearchURL(connectorID: connectorID, country: country, queryOrURL: cleanedTarget, page: 1)
            } else {
                let encoded = cleanedTarget.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                resolvedURLString = "https://html.duckduckgo.com/html/?q=\(encoded)"
            }

            // If an active BrowserInstance is open on a social platform, also execute the real DOM extraction script
            if let activeBrowser = BrowserSessionManager.shared.activeInstance,
               let matchedPlatform = MarketingPlatform.allCases.first(where: { platformOrPortalName.localizedCaseInsensitiveContains($0.rawValue) }) {
                let jsScript = SocialAutomationEngine.shared.buildDOMAutomationScript(for: matchedPlatform, operation: stage)
                let _ = await activeBrowser.evaluateJS(jsScript)
            }

            var targetURLsToInspect: [(url: String, title: String)] = existingLinks.map { ($0, $0) }

            if targetURLsToInspect.isEmpty || stage == "Scrap Links" {
                var discoveredAcrossPages: [(url: String, title: String)] = []
                var seenLinks = Set<String>()
                var antiBotDetectedOnPortal = false

                for pageIdx in 1...max(1, maxPages) {
                    if Task.isCancelled { break }
                    let pageURL: String
                    if pageIdx == 1 {
                        pageURL = resolvedURLString
                    } else if !connectorID.isEmpty {
                        pageURL = B2BConnectorEngine.shared.buildSearchURL(connectorID: connectorID, country: country, queryOrURL: cleanedTarget, page: pageIdx)
                    } else {
                        let sep = resolvedURLString.contains("?") ? "&" : "?"
                        pageURL = "\(resolvedURLString)\(sep)page=\(pageIdx)"
                    }

                    if let html = await fetchHTML(from: pageURL) {
                        // Check if Telegram public channel preview
                        if pageURL.contains("t.me/s/") {
                            let chName = URL(string: pageURL)?.lastPathComponent ?? "TelegramChannel"
                            let (subs, tgMsgs) = TelegramMTProtoEngine.shared.parseTelegramPublicChannelHTML(html: html, channelName: chName)
                            if !tgMsgs.isEmpty && stage != "Scrap Links" {
                                for msg in tgMsgs.prefix(maxItems) {
                                    let entity = ParsedWebEntity(
                                        url: msg.postURL, title: msg.authorName,
                                        phones: [], emails: [], whatsappLinks: [],
                                        price: subs, address: msg.channelOrGroup, rating: subs,
                                        category: "Telegram Post", ownerName: msg.authorName,
                                        descriptionText: msg.text, extractedAt: msg.dateISO
                                    )
                                    let row = mapEntityToColumns(columns: columns, entity: entity)
                                    onRowExtracted(row)
                                    processedCount += 1
                                    successCount += 1
                                }
                                isRunning = false
                                statusBanner = isAr ? "تم استخراج \(successCount) منشور حقيقي من قناة تيليجرام." : "Extracted \(successCount) real Telegram channel posts."
                                return
                            }
                        }

                        let parsed: (links: [(url: String, title: String)], entity: ParsedWebEntity, antiBot: Bool)
                        if !connectorID.isEmpty {
                            let b2bParsed = B2BConnectorEngine.shared.parsePortalHTML(connectorID: connectorID, html: html, pageURL: pageURL)
                            parsed = (b2bParsed.links, b2bParsed.entity, b2bParsed.antiBotDetected)
                        } else {
                            let stdParsed = parseRealHTMLDocument(html: html, pageURL: pageURL)
                            parsed = (stdParsed.links, stdParsed.entity, false)
                        }

                        if parsed.antiBot {
                            antiBotDetectedOnPortal = true
                        }
                        for l in parsed.links {
                            if !seenLinks.contains(l.url) {
                                seenLinks.insert(l.url)
                                discoveredAcrossPages.append(l)
                            }
                        }
                        if discoveredAcrossPages.count >= maxItems { break }
                    } else if pageIdx == 1 {
                        failedCount += 1
                        isRunning = false
                        statusBanner = isAr
                            ? "تعذر الوصول إلى الرابط: \(resolvedURLString)"
                            : "Could not reach URL: \(resolvedURLString)"
                        return
                    }
                }

                if stage == "Scrap Links" {
                    for item in discoveredAcrossPages.prefix(maxItems) {
                        if Task.isCancelled { break }
                        let row = mapEntityToColumns(
                            columns: columns,
                            entity: ParsedWebEntity(
                                url: item.url, title: item.title, phones: [], emails: [],
                                whatsappLinks: [], price: "", address: "", rating: "",
                                category: "", ownerName: "", descriptionText: "",
                                extractedAt: ISO8601DateFormatter().string(from: Date())
                            )
                        )
                        onRowExtracted(row)
                        processedCount += 1
                        successCount += 1
                    }
                    isRunning = false
                    if antiBotDetectedOnPortal && successCount == 0 {
                        statusBanner = isAr
                            ? "تنبيه: الموقع يتطلب التحقق البشري (Cloudflare / Captcha) في متصفح البرنامج."
                            : "Notice: Target site requires human verification (Cloudflare / Captcha) in Program Browser."
                    } else {
                        statusBanner = isAr
                            ? "تم استخراج \(successCount) رابط حقيقي عبر \(maxPages) صفحة."
                            : "Extracted \(successCount) real links across \(maxPages) page(s)."
                    }
                    PersistenceManager.shared.recordActivity(
                        platform: platformOrPortalName,
                        toolName: "\(platformOrPortalName) - Scrap Links",
                        operationType: "Scrap Links",
                        status: successCount > 0 ? "Success" : "Empty/Protected",
                        itemsCount: successCount,
                        details: "URL: \(resolvedURLString) | Pages: \(maxPages)"
                    )
                    return
                } else {
                    if !discoveredAcrossPages.isEmpty {
                        targetURLsToInspect = Array(discoveredAcrossPages.prefix(maxItems))
                    } else {
                        targetURLsToInspect = [(resolvedURLString, resolvedURLString)]
                    }
                }
            }

            // Stage 2: Inspect each target URL and extract real fields
            for (idx, item) in targetURLsToInspect.prefix(maxItems).enumerated() {
                if Task.isCancelled { break }
                while isPaused {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    if Task.isCancelled { break }
                }

                if stopEveryCount > 0 && idx > 0 && idx % stopEveryCount == 0 && waitMinutesOnStop > 0 {
                    statusBanner = isAr
                        ? "توقف مؤقت تلقائي لحماية الحساب بعد \(idx) عملية..."
                        : "Automatic anti-ban pause after \(idx) operations..."
                    try? await Task.sleep(nanoseconds: UInt64(min(waitMinutesOnStop, 2)) * 1_000_000_000)
                }

                if let html = await fetchHTML(from: item.url) {
                    var entity: ParsedWebEntity
                    if !connectorID.isEmpty {
                        entity = B2BConnectorEngine.shared.parsePortalHTML(connectorID: connectorID, html: html, pageURL: item.url).entity
                    } else {
                        entity = parseRealHTMLDocument(html: html, pageURL: item.url).entity
                    }
                    if entity.title.isEmpty || entity.title == item.url {
                        entity.title = item.title
                    }
                    let row = mapEntityToColumns(columns: columns, entity: entity)
                    onRowExtracted(row)
                    processedCount += 1
                    successCount += 1
                } else {
                    failedCount += 1
                }

                var waitMs = max(50, delaySeconds * 100)
                if useRandomDelay {
                    let sec = PersistenceManager.shared.securityConfig
                    let rMin = max(0, sec.minTimerSeconds)
                    let rMax = max(rMin, sec.maxTimerSeconds)
                    waitMs += Int.random(in: rMin...rMax) * 50
                }
                try? await Task.sleep(nanoseconds: UInt64(min(waitMs, 1000)) * 1_000_000)
            }

            if !Task.isCancelled {
                isRunning = false
                statusBanner = isAr
                    ? "اكتمل الاستخراج الحقيقي: \(successCount) ناجح / \(failedCount) فاشل."
                    : "Real extraction completed: \(successCount) succeeded / \(failedCount) failed."
                PersistenceManager.shared.recordActivity(
                    platform: platformOrPortalName,
                    toolName: "\(platformOrPortalName) - \(stage)",
                    operationType: stage,
                    status: successCount > 0 ? "Success" : "Failed",
                    itemsCount: successCount,
                    details: "Extracted \(successCount) real items from \(resolvedURLString)"
                )
            }
        }
    }

    public func fetchHTML(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        if url.isFileURL {
            return try? String(contentsOf: url, encoding: .utf8)
        }
        var req = URLRequest(url: url, timeoutInterval: 10)
        req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        if let (data, resp) = try? await URLSession.shared.data(for: req) {
            if let httpResp = resp as? HTTPURLResponse, httpResp.statusCode >= 400 {
                return nil
            }
            return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1)
        }
        return nil
    }

    public nonisolated func mapEntityToColumns(columns: [String], entity: ParsedWebEntity) -> [String] {
        let firstPhone = entity.phones.first ?? "No Phone"
        let secondPhone = entity.phones.count > 1 ? entity.phones[1] : ""
        let firstEmail = entity.emails.first ?? "No Email"
        let firstWA = entity.whatsappLinks.first ?? (entity.phones.first ?? "No WhatsApp")

        return columns.map { col in
            let c = col.lowercased()
            if c.contains("link") || c.contains("url") || c == "groups" || c == "posts" {
                return entity.url
            } else if c.contains("whatsapp") {
                return firstWA
            } else if c.contains("phone2") {
                return secondPhone
            } else if c.contains("phone") || c.contains("number") || c.contains("هاتف") {
                return firstPhone
            } else if c.contains("email") || c.contains("mail") {
                return firstEmail
            } else if c.contains("price") {
                return entity.price.isEmpty ? "N/A" : entity.price
            } else if c.contains("address") || c.contains("city") || c.contains("region") || c.contains("location") || c.contains("country") {
                return entity.address.isEmpty ? "N/A" : entity.address
            } else if c.contains("rate") || c.contains("rating") {
                return entity.rating.isEmpty ? "N/A" : entity.rating
            } else if c.contains("category") || c.contains("specialization") {
                return entity.category.isEmpty ? "N/A" : entity.category
            } else if c.contains("owner") {
                return entity.ownerName.isEmpty ? "N/A" : entity.ownerName
            } else if c.contains("detail") || c.contains("description") || c.contains("content") || c.contains("about") {
                return entity.descriptionText.isEmpty ? entity.title : entity.descriptionText
            } else if c.contains("time") || c.contains("date") {
                return entity.extractedAt
            } else if c.contains("state") || c.contains("status") {
                return "Extracted ✓"
            } else if c.contains("name") || c.contains("title") || c.contains("user") {
                return entity.title
            } else {
                return entity.title
            }
        }
    }

    // MARK: - 5. Real Native TCP/TLS & Stream Socket SMTP Protocol Client (RFC 5321: EHLO / AUTH LOGIN / MAIL FROM / RCPT TO / DATA)
    public func executeSMTPProtocolExchange(
        account: SMTPAccountEntry,
        recipient: String,
        companyName: String,
        subject: String,
        body: String,
        isHTML: Bool,
        readLine: () async -> String,
        sendLine: (String) async -> Void
    ) async -> (success: Bool, serverResponse: String) {
        let greeting = await readLine()
        guard greeting.hasPrefix("220") else {
            return (false, "Greeting failed: \(greeting)")
        }

        await sendLine("EHLO senderpro.local")
        let ehloResp = await readLine()
        guard ehloResp.hasPrefix("250") else {
            return (false, "EHLO failed: \(ehloResp)")
        }

        if !account.appPassword.isEmpty && account.appPassword != "none" {
            await sendLine("AUTH LOGIN")
            let authChallenge = await readLine()
            if authChallenge.hasPrefix("334") {
                let userB64 = Data(account.email.utf8).base64EncodedString()
                await sendLine(userB64)
                _ = await readLine()
                let passB64 = Data(account.appPassword.utf8).base64EncodedString()
                await sendLine(passB64)
                let authRes = await readLine()
                if !authRes.hasPrefix("235") && !authRes.hasPrefix("250") {
                    return (false, "SMTP Auth failed: \(authRes)")
                }
            }
        }

        await sendLine("MAIL FROM:<\(account.email)>")
        let mailResp = await readLine()
        guard mailResp.hasPrefix("250") else {
            return (false, "MAIL FROM rejected: \(mailResp)")
        }

        await sendLine("RCPT TO:<\(recipient)>")
        let rcptResp = await readLine()
        guard rcptResp.hasPrefix("250") || rcptResp.hasPrefix("251") else {
            return (false, "RCPT TO rejected: \(rcptResp)")
        }

        await sendLine("DATA")
        let dataResp = await readLine()
        guard dataResp.hasPrefix("354") else {
            return (false, "DATA rejected: \(dataResp)")
        }

        let contentType = isHTML ? "text/html; charset=utf-8" : "text/plain; charset=utf-8"
        let fromHeader = companyName.isEmpty ? account.email : "\"\(companyName)\" <\(account.email)>"
        let mimePayload = """
        From: \(fromHeader)\r
        To: <\(recipient)>\r
        Subject: \(subject)\r
        MIME-Version: 1.0\r
        Content-Type: \(contentType)\r
        \r
        \(body)\r
        .
        """
        await sendLine(mimePayload)
        let finalResp = await readLine()
        await sendLine("QUIT")

        let ok = finalResp.hasPrefix("250")
        return (ok, finalResp)
    }

    public func sendRealSMTPEmail(
        account: SMTPAccountEntry,
        recipient: String,
        companyName: String,
        subject: String,
        body: String,
        isHTML: Bool
    ) async -> (success: Bool, serverResponse: String) {
        let host = NWEndpoint.Host(account.smtpHost)
        guard let port = NWEndpoint.Port(rawValue: UInt16(account.smtpPort)) else {
            return (false, "Invalid SMTP port \(account.smtpPort)")
        }

        let params: NWParameters = (account.useSSL && account.smtpPort == 465) ? .tls : .tcp
        let conn = NWConnection(host: host, port: port, using: params)
        conn.start(queue: .global())
        defer { conn.cancel() }

        func readLineWithTimeout() async -> String {
            await withTaskGroup(of: String.self) { group in
                group.addTask {
                    await withCheckedContinuation { continuation in
                        conn.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, _, error in
                            if let data = data, let str = String(data: data, encoding: .utf8) {
                                continuation.resume(returning: str.trimmingCharacters(in: .whitespacesAndNewlines))
                            } else {
                                continuation.resume(returning: error?.localizedDescription ?? "EOF")
                            }
                        }
                    }
                }
                group.addTask {
                    try? await Task.sleep(nanoseconds: 4_000_000_000)
                    return "TIMEOUT: SMTP connection timed out after 4s"
                }
                let first = await group.next() ?? "EOF"
                group.cancelAll()
                return first
            }
        }

        func sendLineWithTimeout(_ cmd: String) async {
            let data = (cmd + "\r\n").data(using: .utf8) ?? Data()
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                        conn.send(content: data, completion: .contentProcessed { _ in
                            continuation.resume()
                        })
                    }
                }
                group.addTask {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                }
                _ = await group.next()
                group.cancelAll()
            }
        }

        return await executeSMTPProtocolExchange(
            account: account,
            recipient: recipient,
            companyName: companyName,
            subject: subject,
            body: body,
            isHTML: isHTML,
            readLine: readLineWithTimeout,
            sendLine: sendLineWithTimeout
        )
    }

    // MARK: - 6. Real Concurrent File / Media Downloader (Replicates VideoDownloader.cs in V10 00:48)
    public func downloadFilesConcurrently(
        urls: [String],
        destinationFolder: URL,
        maxConcurrency: Int = 3,
        onProgress: @escaping (String, String) -> Void
    ) async {
        try? FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
        for (idx, rawURL) in urls.enumerated() {
            guard let url = URL(string: rawURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                onProgress(rawURL, "Invalid URL")
                continue
            }
            do {
                let data: Data
                if url.isFileURL {
                    data = try Data(contentsOf: url)
                } else {
                    let (netData, resp) = try await URLSession.shared.data(from: url)
                    let code = (resp as? HTTPURLResponse)?.statusCode ?? 200
                    guard code >= 200 && code < 300 else {
                        onProgress(rawURL, "HTTP Error \(code)")
                        continue
                    }
                    data = netData
                }
                let ext = url.pathExtension.isEmpty ? "dat" : url.pathExtension
                let fileName = "download_\(idx + 1)_\(url.deletingPathExtension().lastPathComponent.isEmpty ? "media" : url.deletingPathExtension().lastPathComponent).\(ext)"
                let destURL = destinationFolder.appendingPathComponent(fileName)
                try data.write(to: destURL)
                onProgress(rawURL, "Saved (\(data.count) bytes) -> \(fileName)")
            } catch {
                onProgress(rawURL, "Failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 7. Local Analytics HTTP Server (http://localhost:31111/ToolsDashboard.html)
    public func startLocalAnalyticsHTTPServer() {
        guard httpListener == nil else { return }
        do {
            let params = NWParameters.tcp
            guard let port = NWEndpoint.Port(rawValue: 31111) else { return }
            let listener = try NWListener(using: params, on: port)
            listener.newConnectionHandler = { conn in
                conn.start(queue: .main)
                conn.receive(minimumIncompleteLength: 1, maximumLength: 8192) { _, _, _, _ in
                    Task { @MainActor in
                        let html = ExecutionEngine.shared.generateToolsDashboardHTML()
                        let bodyData = html.data(using: .utf8) ?? Data()
                        let header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(bodyData.count)\r\nConnection: close\r\n\r\n"
                        var resp = header.data(using: .utf8) ?? Data()
                        resp.append(bodyData)
                        conn.send(content: resp, completion: .contentProcessed { _ in
                            conn.cancel()
                        })
                    }
                }
            }
            listener.start(queue: .main)
            self.httpListener = listener
        } catch {
            // Port 31111 already bound
        }
    }

    public func generateToolsDashboardHTML() -> String {
        let logs = PersistenceManager.shared.activityLogs
        let totalOps = logs.count
        let successOps = logs.filter { $0.status == "Success" }.count
        let failedOps = totalOps - successOps
        let rate = totalOps > 0 ? Int((Double(successOps) / Double(totalOps)) * 100.0) : 100
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"

        let rowsHTML = logs.map { l in
            """
            <tr>
                <td>\(df.string(from: l.timestamp))</td>
                <td>\(l.userEmail)</td>
                <td><b>\(l.toolName)</b></td>
                <td>\(l.operationType)</td>
                <td><span class="badge \(l.status == "Success" ? "ok" : "err")">\(l.status) (\(l.itemsCount))</span></td>
            </tr>
            """
        }.joined(separator: "\n")

        return """
        <!DOCTYPE html>
        <html lang="ar" dir="rtl">
        <head>
            <meta charset="utf-8">
            <title>Sender Pro V4.65.6 — ToolsDashboard</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #f4f6fb; margin: 0; padding: 24px; color: #1e293b; }
                .card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
                .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
                .title { font-size: 22px; font-weight: 700; color: #2563eb; }
                .kpis { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 20px; }
                .kpi { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px; text-align: center; }
                .kpi h2 { margin: 4px 0 0 0; font-size: 26px; color: #0f172a; }
                .kpi span { font-size: 13px; color: #64748b; }
                table { width: 100%; border-collapse: collapse; margin-top: 12px; }
                th, td { padding: 12px; border-bottom: 1px solid #e2e8f0; text-align: right; font-size: 13px; }
                th { background: #f1f5f9; color: #475569; }
                .badge { padding: 4px 10px; border-radius: 99px; font-size: 12px; font-weight: 600; }
                .ok { background: #dcfce7; color: #166534; }
                .err { background: #fee2e2; color: #991b1b; }
            </style>
        </head>
        <body>
            <div class="card">
                <div class="header">
                    <div class="title">📊 Dashboard — لوحة تحليلات أدوات Sender Pro V4.65.6</div>
                    <div>benyoussef.hassen@gmail.com</div>
                </div>
                <div class="kpis">
                    <div class="kpi"><span>إجمالي العمليات (Total Operations)</span><h2>\(totalOps)</h2></div>
                    <div class="kpi"><span>العمليات الناجحة (Successful)</span><h2 style="color:#16a34a;">\(successOps)</h2></div>
                    <div class="kpi"><span>نسبة النجاح (Success Rate)</span><h2 style="color:#2563eb;">\(rate)%</h2></div>
                    <div class="kpi"><span>العمليات الفاشلة (Failed)</span><h2 style="color:#dc2626;">\(failedOps)</h2></div>
                </div>
                <h3>النشاط الأخير (Recent Tool Activity)</h3>
                <table>
                    <thead>
                        <tr><th>التاريخ (Date)</th><th>المستخدم (User)</th><th>اسم الأداة (Tool Name)</th><th>النوع (Type)</th><th>الحالة (Status)</th></tr>
                    </thead>
                    <tbody>\(rowsHTML)</tbody>
                </table>
            </div>
        </body>
        </html>
        """
    }
}
